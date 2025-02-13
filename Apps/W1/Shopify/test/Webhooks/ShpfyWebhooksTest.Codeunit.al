codeunit 139612 "Shpfy Webhooks Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Shopify]
        IsInitialized := false;
    end;

    var
        LibraryAssert: Codeunit "Library Assert";
        LibraryRandom: Codeunit "Library - Random";
        Any: Codeunit Any;

        WebhooksSubcriber: Codeunit "Shpfy Webhooks Subscriber";
        BulkOpSubscriber: Codeunit "Shpfy Bulk Op. Subscriber";
        SubscriptionId: Text;
        BulkOperationTopicLbl: Label 'bulk_operations/finish', Locked = true;
        OrdersCreateTopicLbl: Label 'orders/create', Locked = true;
        IsInitialized: Boolean;

    local procedure Initialize()

    begin
        if IsInitialized then
            exit;
        IsInitialized := true;
        Codeunit.Run(Codeunit::"Shpfy Initialize Test");
        SubscriptionId := Any.AlphanumericText(10);
        UnbindSubscription(WebhooksSubcriber);
    end;

    local procedure Clear()
    var
        JobQueueEntry: Record "Job Queue Entry";
        WebhookNotification: Record "Webhook Notification";
    begin
        UnbindSubscription(WebhooksSubcriber);
        UnbindSubscription(BulkOpSubscriber);
        JobQueueEntry.DeleteAll();
        WebhookNotification.DeleteAll();
    end;

    [Test]
    procedure TestEnableOrderCreatedWebhooks()
    var
        Shop: Record "Shpfy Shop";
        WebhookSubscription: Record "Webhook Subscription";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
    begin
        // [SCENARIO] Enabling order created webhooks registers webhook with Shopify and creates a subscription

        // [GINVEN] A Shop record
        Initialize();
        WebhooksSubcriber.InitCreateWebhookResponse(CreateShopifyWebhookCreateJson(OrdersCreateTopicLbl), CreateShopifyWebhookDeleteJson(), CreateShopifyEmptyWebhookJson());
        Shop := CommunicationMgt.GetShopRecord();
        BindSubscription(WebhooksSubcriber);

        // [WHEN] Order created webhooks are enabled
        Shop.Validate("Order Created Webhooks", true);

        // [THEN] Subscription is created and id field is filled
        LibraryAssert.AreEqual(Shop."Order Created Webhook Id", SubscriptionId, 'Subscription id should be filled.');
        WebhookSubscription.SetRange(Endpoint, OrdersCreateTopicLbl);
        LibraryAssert.RecordCount(WebhookSubscription, 1);
        Clear();
    end;

    [Test]
    procedure TestDisableOrderCreatedWebhooks()
    var
        Shop: Record "Shpfy Shop";
        WebhookSubscription: Record "Webhook Subscription";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
    begin
        // [SCENARIO] Disabling order created webhooks deletes the webhook from Shopify and deletes the subscription

        // [GINVEN] A Shop record with order created webhooks enabled
        Initialize();
        WebhooksSubcriber.InitCreateWebhookResponse(CreateShopifyWebhookCreateJson(OrdersCreateTopicLbl), CreateShopifyWebhookDeleteJson(), CreateShopifyEmptyWebhookJson());
        Shop := CommunicationMgt.GetShopRecord();
        BindSubscription(WebhooksSubcriber);
        if not Shop."Order Created Webhooks" then begin
            Shop.Validate("Order Created Webhooks", true);
            Shop.Modify();
        end;

        // [WHEN] Order created webhooks are disabled
        Shop.Validate("Order Created Webhooks", false);

        // [THEN] Subscription is deleted and id field is cleared
        LibraryAssert.AreEqual(Shop."Order Created Webhook Id", '', 'Subscription id should be cleared.');
        WebhookSubscription.SetRange(Endpoint, OrdersCreateTopicLbl);
        LibraryAssert.RecordIsEmpty(WebhookSubscription);
        Clear();
    end;

    [Test]
    procedure TestNotificationSchedulesOrderSyncJob()
    var
        Shop: Record "Shpfy Shop";
        JobQueueEntry: Record "Job Queue Entry";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
    begin
        // [SCENARIO] Creating a webhook notification for orders/create schedules order sync

        // [GINVEN] A Shop record with order created webhooks enabled
        Initialize();
        WebhooksSubcriber.InitCreateWebhookResponse(CreateShopifyWebhookCreateJson(OrdersCreateTopicLbl), CreateShopifyWebhookDeleteJson(), CreateShopifyEmptyWebhookJson());
        Shop := CommunicationMgt.GetShopRecord();
        BindSubscription(WebhooksSubcriber);
        if not Shop."Order Created Webhooks" then begin
            Shop.Validate("Order Created Webhooks", true);
            Shop.Modify();
        end;

        // [WHEN] A notification is inserted
        InsertNotification(Shop."Shopify URL", OrdersCreateTopicLbl, '');

        // [THEN] Job queue entry is created
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Report);
        JobQueueEntry.SetRange("Object ID to Run", Report::"Shpfy Sync Orders from Shopify");
        JobQueueEntry.FindFirst();
        LibraryAssert.AreEqual(JobQueueEntry."Job Queue Category Code", 'SHPFY', 'Job queue category should be SHPFY.');
        Clear();
    end;

    [Test]
    procedure TestNotificationDoesNotScheduleOrderSyncJobIfAlreadyExists()
    var
        Shop: Record "Shpfy Shop";
        JobQueueEntry: Record "Job Queue Entry";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JobQueueEntryId: Guid;
    begin
        // [SCENARIO] Creating a webhook notification for orders/create does not schedule order sync if there is a ready job queue already

        // [GINVEN] A Shop record with order created webhooks enabled and a ready job queue entry
        Initialize();
        WebhooksSubcriber.InitCreateWebhookResponse(CreateShopifyWebhookCreateJson(OrdersCreateTopicLbl), CreateShopifyWebhookDeleteJson(), CreateShopifyEmptyWebhookJson());
        Shop := CommunicationMgt.GetShopRecord();
        BindSubscription(WebhooksSubcriber);
        if not Shop."Order Created Webhooks" then begin
            Shop.Validate("Order Created Webhooks", true);
            Shop.Modify();
        end;
        JobQueueEntryId := CreateJobQueueEntry(Shop, Report::"Shpfy Sync Orders from Shopify");

        // [WHEN] A notification is inserted
        InsertNotification(Shop."Shopify URL", OrdersCreateTopicLbl, '');

        // [THEN] Job queue entry is not created
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Report);
        JobQueueEntry.SetRange("Object ID to Run", Report::"Shpfy Sync Orders from Shopify");
        LibraryAssert.RecordCount(JobQueueEntry, 1);
        Clear();
    end;

    [Test]
    procedure TestEnableBulkOperationWebhook()
    var
        Shop: Record "Shpfy Shop";
        WebhookSubscription: Record "Webhook Subscription";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        BulkOperationMgt: Codeunit "Shpfy Bulk Operation Mgt.";
    begin
        // [SCENARIO] Enabling connection registers webhook with Shopify and creates a subscription

        // [GINVEN] A Shop record
        Initialize();
        WebhooksSubcriber.InitCreateWebhookResponse(CreateShopifyWebhookCreateJson(BulkOperationTopicLbl), CreateShopifyWebhookDeleteJson(), CreateShopifyEmptyWebhookJson());
        Shop := CommunicationMgt.GetShopRecord();
        BindSubscription(WebhooksSubcriber);
        BindSubscription(BulkOpSubscriber);
        WebhookSubscription.DeleteAll();

        // [WHEN] Shop is enabled
        BulkOperationMgt.EnableBulkOperations(Shop);

        // [THEN] Subscription is created and id field is filled
        LibraryAssert.AreEqual(Shop."Bulk Operation Webhook Id", SubscriptionId, 'Subscription id should be filled.');
        WebhookSubscription.SetRange(Endpoint, BulkOperationTopicLbl);
        LibraryAssert.RecordCount(WebhookSubscription, 1);
        Clear();
    end;

    [Test]
    procedure TestDisableBulkOperationWebhooks()
    var
        Shop: Record "Shpfy Shop";
        WebhookSubscription: Record "Webhook Subscription";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
    begin
        // [SCENARIO] Disabling shop deletes the webhook from Shopify and deletes the subscription

        // [GINVEN] A Shop record
        Initialize();
        Shop := CommunicationMgt.GetShopRecord();
        BindSubscription(WebhooksSubcriber);

        // [WHEN] Shop is disabled
        Shop.Validate(Enabled, false);

        // [THEN] Subscription is deleted and id field is cleared
        LibraryAssert.AreEqual(Shop."Bulk Operation Webhook Id", '', 'Subscription id should be cleared.');
        WebhookSubscription.SetRange(Endpoint, BulkOperationTopicLbl);
        LibraryAssert.RecordIsEmpty(WebhookSubscription);
        Clear();
    end;

    [Test]
    procedure TestBulkOperationNotification()
    var
        Shop: Record "Shpfy Shop";
        BulkOperation: Record "Shpfy Bulk Operation";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        BulkOperationMgt: Codeunit "Shpfy Bulk Operation Mgt.";
        BulkOperationId: BigInteger;
        BulkOperationSystemId: Guid;
    begin
        // [SCENARIO] Creating a webhook notification for 'bulk_operations/finish' updates the bulk operation

        // [GINVEN] A Shop record and a bulk operation
        Initialize();
        WebhooksSubcriber.InitCreateWebhookResponse(CreateShopifyWebhookCreateJson(BulkOperationTopicLbl), CreateShopifyWebhookDeleteJson(), CreateShopifyEmptyWebhookJson());
        Shop := CommunicationMgt.GetShopRecord();
        BindSubscription(WebhooksSubcriber);
        BindSubscription(BulkOpSubscriber);
        BulkOperationId := LibraryRandom.RandIntInRange(100000, 999999);
        BulkOperationSystemId := CreateBulkOperation(Shop, BulkOperationId);

        // [WHEN] A notification is inserted
        BulkOperationMgt.EnableBulkOperations(Shop);
        InsertNotification(Shop."Shopify URL", BulkOperationTopicLbl, CreateBulkOperationNotificationJson(BulkOperationId));

        // [THEN] Bulk operation status and completed at is updated
        BulkOperation.GetBySystemId(BulkOperationSystemId);
        LibraryAssert.AreEqual(BulkOperation.Status, BulkOperation.Status::Completed, 'Bulk operation status should be completed.');
        LibraryAssert.AreNotEqual(BulkOperation."Completed At", 0DT, 'Bulk operation completed at should be filled.');
    end;

    local procedure InsertNotification(ShopifyURL: Text[250]; Topic: Text[250]; Notification: Text)
    var
        WebhookNotification: Record "Webhook Notification";
        NotificationStream: OutStream;
    begin
        WebhookNotification.Init();
        WebhookNotification."Subscription ID" := GetShopDomain(ShopifyURL);
        WebhookNotification."Resource Type Name" := Topic;
        WebhookNotification."Sequence Number" := -1;
        if Notification <> '' then begin
            WebhookNotification.Notification.CreateOutStream(NotificationStream, TextEncoding::UTF8);
            NotificationStream.WriteText(Notification);
        end;
        WebhookNotification.Insert();
    end;

    local procedure CreateJobQueueEntry(Shop: Record "Shpfy Shop"; ReportId: Integer): Guid
    var
        JobQueueEntry: Record "Job Queue Entry";
        OrderParametersTxt: Label '<?xml version="1.0" standalone="yes"?><ReportParameters name="Sync Orders from Shopify" id="30104"><DataItems><DataItem name="Shop">%1</DataItem><DataItem name="OrdersToImport">VERSION(1) SORTING(Field1)</DataItem></DataItems></ReportParameters>', Comment = '%1 = Shop Record View', Locked = true;
    begin
        Shop.SetFilter(Code, Shop.Code);
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Report;
        JobQueueEntry."Object ID to Run" := ReportId;
        JobQueueEntry."Report Output Type" := JobQueueEntry."Report Output Type"::"None (Processing only)";
        JobQueueEntry."No. of Attempts to Run" := 5;
        JobQueueEntry."Job Queue Category Code" := 'SHPFY';
        JobQueueEntry.Status := JobQueueEntry.Status::Ready;
        JobQueueEntry.Insert();
        JobQueueEntry.SetXmlContent(StrSubstNo(OrderParametersTxt, Shop.GetView()));
        exit(JobQueueEntry.ID);
    end;

    local procedure CreateShopifyWebhookCreateJson(Topic: Text): JsonObject
    var
        JData: JsonObject;
        JWebhook: JsonObject;
    begin
        JWebhook.Add('id', SubscriptionId);
        JWebhook.Add('address', 'https://example.app/api/webhooks');
        JWebhook.Add('topic', Topic);
        JWebhook.Add('format', 'JSON');
        JData.Add('webhook', JWebhook);
        exit(JData);
    end;

    local procedure CreateBulkOperationNotificationJson(BulkOperationId: BigInteger): Text
    var
        Result: Text;
        JNotification: JsonObject;
        JToken: JsonToken;
    begin
        JNotification.Add('admin_graphql_api_id', 'gid://shopify/BulkOperation/' + Format(BulkOperationId));
        JNotification.Add('completed_at', '2019-08-29T17:23:25Z');
        JNotification.Add('error_code', JToken);
        JNotification.Add('status', 'completed');
        JNotification.Add('type', 'mutation');
        JNotification.WriteTo(Result);
        exit(Result);
    end;

    local procedure CreateBulkOperation(Shop: Record "Shpfy Shop"; BulkOperationId: BigInteger): Guid
    var
        BulkOperation: Record "Shpfy Bulk Operation";
    begin
        BulkOperation."Bulk Operation Id" := BulkOperationId;
        BulkOperation."Shop Code" := Shop.Code;
        BulkOperation.Type := BulkOperation.Type::mutation;
        BulkOperation.Status := BulkOperation.Status::Created;
        BulkOperation.Insert();
        exit(BulkOperation.SystemId)
    end;

    local procedure CreateShopifyWebhookDeleteJson(): JsonObject
    var
        JData: JsonObject;
    begin
        exit(JData);
    end;

    local procedure CreateShopifyEmptyWebhookJson(): JsonObject
    var
        JData: JsonObject;
        JWebhooks: JsonArray;
    begin
        JData.Add('webhooks', JWebhooks);
        exit(JData);
    end;

    local procedure GetShopDomain(ShopUrl: Text[250]): Text
    begin
        exit(ShopUrl.Replace('https://', '').Replace('.myshopify.com', '').TrimEnd('/'));
    end;
}