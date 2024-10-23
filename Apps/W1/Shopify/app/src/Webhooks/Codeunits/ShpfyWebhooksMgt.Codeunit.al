namespace Microsoft.Integration.Shopify;

using System.Integration;
using System.Telemetry;
using System.Threading;
using System.Environment;

codeunit 30269 "Shpfy Webhooks Mgt."
{
    Access = Internal;
    Permissions = TableData "Webhook Subscription" = rimd;

    var
        ProcessingWebhookNotificationTxt: Label 'Processing webhook notification.', Locked = true;
        WebhookSubscriptionNotFoundTxt: Label 'Webhook subscription is not found.', Locked = true;
        ReadyJobFoundTxt: Label 'A job queue entry in ready state already exists. Skipping notification.', Locked = true;
        CategoryTok: Label 'Shopify Integration', Locked = true;
        JobQueueCategoryLbl: Label 'SHPFY', Locked = true;
        WebhookRegistrationFailedErr: Label 'Failed to register webhook with Shopify';
        BulkOperationTopicLbl: Label 'bulk_operations/finish', Locked = true;
        OrdersCreateTopicLbl: Label 'orders/create', Locked = true;
        BulkOperationNotificationReceivedLbl: Label 'Bulk operation notification received for shop %1', Comment = '%1 = Shop code', Locked = true;

    [EventSubscriber(ObjectType::Table, Database::"Webhook Notification", 'OnAfterInsertEvent', '', false, false)]
    local procedure HandleOnWebhookNotificationInsert(var Rec: Record "Webhook Notification"; RunTrigger: Boolean)
    var
        WebhookSubscription: Record "Webhook Subscription";
        Company: Record Company;
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

        Company.FindSet();
        repeat
            ProcessCompanyWebhookNotification(Company, Rec);
        until Company.Next() = 0;
    end;

    local procedure ProcessCompanyWebhookNotification(Company: Record Company; var WebhookNotification: Record "Webhook Notification")
    var
        IsTestInProgress: Boolean;
    begin
        OnScheduleWebhookNotificationTask(IsTestInProgress);
        if IsTestInProgress then begin
            Codeunit.Run(Codeunit::"Shpfy Webhook Notification", WebhookNotification);
            exit;
        end;

        if TaskScheduler.CanCreateTask() then
            TaskScheduler.CreateTask(Codeunit::"Shpfy Webhook Notification", 0, true, Company.Name, CurrentDateTime(), WebhookNotification.RecordId);
    end;

    internal procedure EnableWebhook(var Shop: Record "Shpfy Shop"; Topic: Text[250]; UserId: Guid): Text
    var
        WebhookSubscription: Record "Webhook Subscription";
        WebhooksAPI: Codeunit "Shpfy Webhooks API";
        SubscriptionId: Text;
        PrevUserId: Guid;
    begin
        if WebhookSubscription.Get(GetShopDomain(Shop."Shopify URL"), Topic) then begin
            PrevUserId := WebhookSubscription."Run Notification As";
            WebhookSubscription.Delete();
        end;
        if WebhooksAPI.GetWebhookSubscription(Shop, Topic, SubscriptionId) then
            WebhooksAPI.DeleteWebhookSubscription(Shop, SubscriptionId);
        SubscriptionId := WebhooksAPI.RegisterWebhookSubscription(Shop, Topic);
        if SubscriptionId <> '' then begin
            CreateWebhookSubscription(Shop, Topic, UserId);
            if PrevUserId <> UserId then
                ChangePrevWebhookUserId(Topic, PrevUserId, UserId, Shop."Shopify URL", Shop.Code);
            exit(SubscriptionId);
        end else
            Error(WebhookRegistrationFailedErr);
    end;

    internal procedure EnableBulkOperationWebhook(var Shop: Record "Shpfy Shop")
    begin
        Shop."Bulk Operation Webhook Id" := CopyStr(EnableWebhook(Shop, BulkOperationTopicLbl, Shop."Bulk Operation Webhook User Id"), 1, MaxStrLen(Shop."Bulk Operation Webhook Id"));
        Shop.Modify();
    end;

    internal procedure DisableBulkOperationsWebhook(var Shop: Record "Shpfy Shop")
    var
        WebhookSubscription: Record "Webhook Subscription";
        SearchShop: Record "Shpfy Shop";
        Company: Record Company;
        WebhooksAPI: Codeunit "Shpfy Webhooks API";
        FoundCompany: Text[30];
    begin
        if WebhookSubscription.Get(GetShopDomain(Shop."Shopify URL"), BulkOperationTopicLbl) then
            if WebhookSubscription."Company Name" = CompanyName() then begin // checks if this webhook is also enabled for another company
                Company.FindSet();
                repeat
                    if SearchShop.ChangeCompany(Company.Name) then begin
                        SearchShop.SetRange("Shopify URL", Shop."Shopify URL");
                        if Company.Name = CompanyName() then
                            SearchShop.SetFilter(Code, '<>%1', Shop.Code);

                        if SearchShop.FindSet() then
                            repeat
                                if SearchShop."Bulk Operation Webhook Id" <> '' then begin
                                    FoundCompany := Company.Name;
                                    break;
                                end;
                            until SearchShop.Next() = 0;
                    end;

                    if FoundCompany <> '' then
                        break;
                until Company.Next() = 0;

                if FoundCompany = '' then begin
                    WebhookSubscription.Delete();
                    WebhooksAPI.DeleteWebhookSubscription(Shop, Shop."Bulk Operation Webhook Id");
                end else
                    if FoundCompany <> WebhookSubscription."Company Name" then begin
                        WebhookSubscription."Company Name" := FoundCompany;
                        WebhookSubscription.Modify();
                    end;
            end;

        if Shop."Bulk Operation Webhook Id" <> '' then begin
            Clear(Shop."Bulk Operation Webhook Id");
            Shop.Modify();
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
        SearchShop: Record "Shpfy Shop";
        Company: Record Company;
        WebhooksAPI: Codeunit "Shpfy Webhooks API";
        FoundCompany: Text[30];
    begin
        if WebhookSubscription.Get(GetShopDomain(Shop."Shopify URL"), OrdersCreateTopicLbl) then
            if WebhookSubscription."Company Name" = CompanyName() then begin // checks if this webhook is also enabled for another company
                Company.FindSet();
                repeat
                    if SearchShop.ChangeCompany(Company.Name) then begin
                        SearchShop.SetRange("Shopify URL", Shop."Shopify URL");
                        if Company.Name = CompanyName() then
                            SearchShop.SetFilter(Code, '<>%1', Shop.Code);

                        if SearchShop.FindSet() then
                            repeat
                                if SearchShop."Order Created Webhook Id" <> '' then begin
                                    FoundCompany := Company.Name;
                                    break;
                                end;
                            until SearchShop.Next() = 0;
                    end;

                    if FoundCompany <> '' then
                        break;
                until Company.Next() = 0;

                if FoundCompany = '' then begin
                    WebhookSubscription.Delete();
                    WebhooksAPI.DeleteWebhookSubscription(Shop, Shop."Order Created Webhook Id");
                end else
                    if FoundCompany <> WebhookSubscription."Company Name" then begin
                        WebhookSubscription."Company Name" := FoundCompany;
                        WebhookSubscription.Modify();
                    end;
            end;

        if Shop."Order Created Webhook Id" <> '' then begin
            Clear(Shop."Order Created Webhook Id");
            Shop.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Company, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure HandleOnCompanyBeforeDelete(var Rec: Record Company; RunTrigger: Boolean)
    var
        Shop: Record "Shpfy Shop";
        TenantLicenseState: Codeunit "Tenant License State";
        EnumTenantLicenseState: Enum "Tenant License State";
    begin
        if Rec.IsTemporary() then
            exit;

        if Shop.ChangeCompany(Rec.Name) then begin
            if not GuiAllowed() then
                if TenantLicenseState.GetLicenseState() in [EnumTenantLicenseState::Suspended, EnumTenantLicenseState::Deleted, EnumTenantLicenseState::LockedOut] then
                    exit;
            Shop.SetRange(Enabled, true);
            if Shop.FindSet() then
                repeat
                    DisableOrderCreatedWebhook(Shop);
                    DisableBulkOperationsWebhook(Shop);
                until Shop.Next() = 0;
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

    internal procedure ProcessOrderCreatedNotification(Shop: Record "Shpfy Shop")
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

    internal procedure ProcessBulkOperationNotification(Shop: Record "Shpfy Shop"; var WebhookNotification: Record "Webhook Notification")
    var
        BulkOperationMgt: Codeunit "Shpfy Bulk Operation Mgt.";
        NotificationInStream: InStream;
        JNotification: JsonObject;
        NotificationText: Text;
    begin
        WebhookNotification.CalcFields(Notification);
        WebhookNotification.Notification.CreateInStream(NotificationInStream);
        NotificationInStream.ReadText(NotificationText);
        JNotification.ReadFrom(NotificationText);

        Session.LogMessage('0000KZD', BulkOperationNotificationReceivedLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        BulkOperationMgt.ProcessBulkOperationNotification(Shop, JNotification);
    end;

    local procedure ChangePrevWebhookUserId(Topic: Text[250]; PrevUserId: Guid; UserId: Guid; ShopUrl: Text[250]; ShopCode: Code[20])
    var
        Shop: Record "Shpfy Shop";
    begin
        case Topic of
            OrdersCreateTopicLbl:
                begin
                    Shop.SetFilter(Code, '<>%1', ShopCode);
                    Shop.SetRange("Shopify URL", ShopUrl);
                    Shop.SetRange(Enabled, true);
                    Shop.SetRange("Order Created Webhooks", true);
                    Shop.SetRange("Order Created Webhook User Id", PrevUserId);
                    if Shop.FindSet() then
                        repeat
                            Shop.Validate("Order Created Webhook User Id", UserId);
                            Shop.Modify();
                        until Shop.Next() = 0;
                end;
            BulkOperationTopicLbl:
                begin
                    Shop.SetFilter(Code, '<>%1', ShopCode);
                    Shop.SetRange("Shopify URL", ShopUrl);
                    Shop.SetRange(Enabled, true);
                    Shop.SetRange("Bulk Operation Webhook User Id", PrevUserId);
                    if Shop.FindSet() then
                        repeat
                            Shop.Validate("Bulk Operation Webhook User Id", UserId);
                            Shop.Modify();
                        until Shop.Next() = 0;
                end;
        end;
    end;

    local procedure GetShopDomain(ShopUrl: Text[250]): Text
    begin
        exit(ShopUrl.Replace('https://', '').Replace('.myshopify.com', '').TrimEnd('/'));
    end;

    [InternalEvent(false)]
    internal procedure OnScheduleWebhookNotificationTask(var IsTestInProgress: Boolean)
    begin
    end;
}