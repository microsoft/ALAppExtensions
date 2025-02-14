codeunit 30363 "Shpfy Webhook Notification"
{
    TableNo = "Webhook Notification";

    trigger OnRun()
    begin
        HandleOnShopifyWebhookNotificationInsert(Rec);
    end;

    var
        ShopNotFoundTxt: Label 'Shop is not found in company %1.', Comment = '%1 = Company name', Locked = true;
        ProcessingNotificationTxt: Label 'Processing notification in company %1.', Comment = '%1 = Company name', Locked = true;
        BulkOperationTopicLbl: Label 'BULK_OPERATIONS_FINISH', Locked = true;
        OrdersCreateTopicLbl: Label 'ORDERS_CREATE', Locked = true;
        CategoryTok: Label 'Shopify Integration', Locked = true;

    local procedure HandleOnShopifyWebhookNotificationInsert(var WebhookNotification: Record "Webhook Notification")
    var
        Shop: Record "Shpfy Shop";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        WebhooksMgt: Codeunit "Shpfy Webhooks Mgt.";
    begin
        Shop.SetRange(Enabled, true);
        Shop.SetRange("Shopify URL", GetShopUrl(WebhookNotification."Subscription ID"));
        if Shop.IsEmpty() then begin
            Shop.SetRange("Shopify URL", GetShopUrl(WebhookNotification."Subscription ID").TrimEnd('/'));
            if Shop.IsEmpty() then begin
                Session.LogMessage('0000K8I', StrSubstNo(ShopNotFoundTxt, CompanyName), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                exit;
            end;
        end;

        Session.LogMessage('0000K8J', StrSubstNo(ProcessingNotificationTxt, CompanyName), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

        if Shop.FindSet() then
            repeat
                case WebhookNotification."Resource Type Name" of
                    OrdersCreateTopicLbl:
                        if Shop."Order Created Webhooks" then begin
                            FeatureTelemetry.LogUptake('0000K8D', 'Shopify Webhooks', Enum::"Feature Uptake Status"::Used);
                            FeatureTelemetry.LogUsage('0000K8F', 'Shopify Webhooks', 'Shopify sales order webhooks enabled.');
                            WebhooksMgt.ProcessOrderCreatedNotification(Shop);
                            Commit();
                        end else
                            Session.LogMessage('0000KUD', StrSubstNo(ShopNotFoundTxt, CompanyName), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                    BulkOperationTopicLbl:
                        begin
                            WebhooksMgt.ProcessBulkOperationNotification(Shop, WebhookNotification);
                            Commit();
                        end;
                end;
            until Shop.Next() = 0;
    end;

    local procedure GetShopUrl(ShopDomain: Text): Text
    begin
        exit('https://' + ShopDomain + '.myshopify.com/');
    end;
}