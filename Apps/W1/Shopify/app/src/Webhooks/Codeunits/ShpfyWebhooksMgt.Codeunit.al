namespace Microsoft.Integration.Shopify;

using System.Integration;
using System.Telemetry;
using System.Threading;

codeunit 30269 "Shpfy Webhooks Mgt."
{
    Access = Internal;
    Permissions = TableData "Webhook Subscription" = rimd;

    var
        ProcessingWebhookNotificationTxt: Label 'Processing webhook notification.', Locked = true;
        WebhookSubscriptionNotFoundTxt: Label 'Webhook subscription is not found.', Locked = true;
        ShopNotFoundTxt: Label 'Shop is not found.', Locked = true;
        ProcessingNotificationTxt: Label 'Processing notification.', Locked = true;
        ReadyJobFoundTxt: Label 'A job queue entry in ready state already exists. Skipping notification.', Locked = true;
        CategoryTok: Label 'Shopify Integration', Locked = true;
        JobQueueCategoryLbl: Label 'SHPFY', Locked = true;
        WebhookRegistrationFailedErr: Label 'Failed to register webhook with Shopify';

        BulkOperationTopicLbl: Label 'bulk_operations/finish', Locked = true;
        OrdersCreateTopicLbl: Label 'orders/create', Locked = true;
        BulkOperationNotificationReceivedLbl: Label 'Bulk operation notification received for shop %1', Comment = '%1 = Shop code', Locked = true;

    [EventSubscriber(ObjectType::Table, Database::"Webhook Notification", 'OnAfterInsertEvent', '', false, false)]
    local procedure HandleOnWebhookNotificationInsert(var Rec: Record "Webhook Notification"; RunTrigger: Boolean);
    var
        WebhookSubscription: Record "Webhook Subscription";
        Shop: Record "Shpfy Shop";
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        if Rec.IsTemporary() then
            exit;

        Session.LogMessage('0000K8G', ProcessingWebhookNotificationTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

        WebhookSubscription.SetRange("Subscription ID", Rec."Subscription ID");
        WebhookSubscription.SetRange(Endpoint, Rec."Resource Type Name");
        if WebhookSubscription.IsEmpty() then begin
            Session.LogMessage('0000K8H', WebhookSubscriptionNotFoundTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit;
        end;

        Shop.SetRange("Shopify URL", GetShopUrl(Rec."Subscription ID"));
        if not Shop.FindFirst() then begin
            Shop.SetRange("Shopify URL", GetShopUrl(Rec."Subscription ID").TrimEnd('/'));
            if not Shop.FindFirst() then begin
                Session.LogMessage('0000K8I', ShopNotFoundTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                exit;
            end;
        end;

        Session.LogMessage('0000K8J', ProcessingNotificationTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

        case Rec."Resource Type Name" of
            OrdersCreateTopicLbl:
                if Shop."Order Created Webhooks" then begin
                    FeatureTelemetry.LogUptake('0000K8D', 'Shopify Webhooks', Enum::"Feature Uptake Status"::Used);
                    FeatureTelemetry.LogUsage('0000K8F', 'Shopify Webhooks', 'Shopify sales order webhooks enabled.');
                    ProcessOrderCreatedNotification(Shop);
                    Commit();
                    exit;
                end else
                    Session.LogMessage('0000KUD', ShopNotFoundTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            BulkOperationTopicLbl:
                begin
                    ProcessBulkOperationNotification(Shop, Rec);
                    Commit();
                    exit;
                end;
        end;
    end;

    internal procedure EnableWebhook(var Shop: Record "Shpfy Shop"; Topic: Text[250]; UserId: Guid): Text
    var
        ShpfyWebhooksAPI: Codeunit "Shpfy Webhooks API";
        SubscriptionId: Text;
    begin
        if ShpfyWebhooksAPI.GetWebhookSubscription(Shop, Topic, SubscriptionId) then
            ShpfyWebhooksAPI.DeleteWebhookSubscription(Shop, SubscriptionId);
        SubscriptionId := ShpfyWebhooksAPI.RegisterWebhookSubscription(Shop, Topic);
        if SubscriptionId <> '' then begin
            CreateWebhookSubscription(Shop, Topic, UserId);
            exit(SubscriptionId);
        end else
            Error(WebhookRegistrationFailedErr);
    end;

    internal procedure EnableBulkOperationWebhook(var Shop: Record "Shpfy Shop")
    begin
        Shop."Bulk Operation Webhook Id" := CopyStr(EnableWebhook(Shop, BulkOperationTopicLbl, Shop."Bulk Operation Webhook User Id"), 1, MaxStrLen(Shop."Order Created Webhook Id"));
        Shop.Modify();
    end;

    internal procedure DisableBulkOperationsWebhook(var Shop: Record "Shpfy Shop")
    var
        WebhookSubscription: Record "Webhook Subscription";
        ShpfyWebhooksAPI: Codeunit "Shpfy Webhooks API";
    begin
        WebhookSubscription.SetRange("Subscription ID", GetShopDomain(Shop."Shopify URL"));
        WebhookSubscription.SetRange("Company Name", CopyStr(CompanyName(), 1, MaxStrLen(WebhookSubscription."Company Name")));
        WebhookSubscription.SetRange(Endpoint, BulkOperationTopicLbl);
        if WebhookSubscription.FindFirst() then begin
            ShpfyWebhooksAPI.DeleteWebhookSubscription(Shop, Shop."Bulk Operation Webhook Id");
            Clear(Shop."Bulk Operation Webhook Id");
            Shop.Modify();
            WebhookSubscription.Delete();
        end;
    end;

    internal procedure EnableOrderCreatedWebhook(var Shop: Record "Shpfy Shop")
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        Shop."Order Created Webhook Id" := CopyStr(EnableWebhook(Shop, OrdersCreateTopicLbl, GetOrderCreatedWebhookUser(Shop)), 1, MaxStrLen(Shop."Order Created Webhook Id"));
        Shop.Modify();
        FeatureTelemetry.LogUptake('0000K8E', 'Shopify Webhooks', Enum::"Feature Uptake Status"::"Set up");
    end;

    internal procedure DisableOrderCreatedWebhook(var Shop: Record "Shpfy Shop")
    var
        WebhookSubscription: Record "Webhook Subscription";
        ShpfyWebhooksAPI: Codeunit "Shpfy Webhooks API";
    begin
        WebhookSubscription.SetRange("Subscription ID", GetShopDomain(Shop."Shopify URL"));
        WebhookSubscription.SetRange("Company Name", CopyStr(CompanyName(), 1, MaxStrLen(WebhookSubscription."Company Name")));
        WebhookSubscription.SetRange(Endpoint, OrdersCreateTopicLbl);
        if WebhookSubscription.FindFirst() then begin
            ShpfyWebhooksAPI.DeleteWebhookSubscription(Shop, Shop."Order Created Webhook Id");
            Clear(Shop."Order Created Webhook Id");
            Shop.Modify();
            WebhookSubscription.Delete();
        end;
    end;

    local procedure CreateWebhookSubscription(var Shop: Record "Shpfy Shop"; Endpoint: Text[250]; UserId: Guid)
    var
        WebhookSubscription: Record "Webhook Subscription";
    begin
        WebhookSubscription."Subscription ID" := CopyStr(GetShopDomain(Shop."Shopify URL"), 1, MaxStrLen(WebhookSubscription."Subscription ID"));
        WebhookSubscription."Created By" := Shop.Code;
        WebhookSubscription."Company Name" := CopyStr(CompanyName(), 1, MaxStrLen(WebhookSubscription."Company Name"));
        WebhookSubscription.Endpoint := Endpoint;
        WebhookSubscription."Run Notification As" := UserId;
        WebhookSubscription.Insert();
    end;

    local procedure SetOrderCreatedWebhookSubscriptionUserAsCurrentUser(var Shop: Record "Shpfy Shop"): Guid
    var
        WebhookManagement: Codeunit "Webhook Management";
    begin
        if Shop."Order Created Webhook User Id" <> UserSecurityID() then
            if WebhookManagement.IsValidNotificationRunAsUser(UserSecurityID()) then begin
                Shop.Validate("Order Created Webhook User Id", UserSecurityID());
                Shop.Modify();
            end;

        exit(Shop."Order Created Webhook User Id");
    end;

    local procedure GetOrderCreatedWebhookUser(var Shop: Record "Shpfy Shop"): Guid
    begin
        if not IsNullGuid(Shop."Order Created Webhook User Id") then
            exit(Shop."Order Created Webhook User Id")
        else
            exit(SetOrderCreatedWebhookSubscriptionUserAsCurrentUser(Shop));
    end;

    local procedure ProcessOrderCreatedNotification(Shop: Record "Shpfy Shop")
    var
        JobQueueEntry: Record "Job Queue Entry";
        BackgroundSyncs: Codeunit "Shpfy Background Syncs";
    begin
        Shop.SetFilter(Code, Shop.Code);
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Report);
        JobQueueEntry.SetRange("Object ID to Run", Report::"Shpfy Sync Orders from Shopify");
        JobQueueEntry.SetRange("Job Queue Category Code", JobQueueCategoryLbl);
        JobQueueEntry.SetRange(Status, JobQueueEntry.Status::Ready);
        if JobQueueEntry.FindSet() then
            repeat
                if JobQueueEntry.GetXmlContent().Contains(Shop.GetView()) then begin // There is already a ready job for this shop, therefor no need to schedule a new one
                    Session.LogMessage('0000K8K', ReadyJobFoundTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                    exit;
                end;
            until JobQueueEntry.Next() = 0;
        BackgroundSyncs.SyncAllOrders(Shop);
    end;

    local procedure ProcessBulkOperationNotification(Shop: Record "Shpfy Shop"; var WebhookNotification: Record "Webhook Notification")
    var
        BulkOperationMgt: Codeunit "Shpfy Bulk Operation Mgt.";
        NotificationInStream: InStream;
        JNotification: JsonObject;
        NotificationText: Text;
    begin
        WebhookNotification.Notification.CreateInStream(NotificationInStream);
        NotificationInStream.ReadText(NotificationText);
        JNotification.ReadFrom(NotificationText);

        Session.LogMessage('0000KZD', BulkOperationNotificationReceivedLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        BulkOperationMgt.ProcessBulkOperationNotification(Shop, JNotification);
    end;

    local procedure GetShopDomain(ShopUrl: Text[250]): Text
    begin
        exit(ShopUrl.Replace('https://', '').Replace('.myshopify.com', '').TrimEnd('/'));
    end;

    local procedure GetShopUrl(ShopDomain: Text): Text
    begin
        exit('https://' + ShopDomain + '.myshopify.com/');
    end;
}