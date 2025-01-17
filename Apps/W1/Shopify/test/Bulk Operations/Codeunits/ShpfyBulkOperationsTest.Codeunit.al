codeunit 139633 "Shpfy Bulk Operations Test"
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
        Any: Codeunit Any;

        BulkOpSubscriber: Codeunit "Shpfy Bulk Op. Subscriber";
        IsInitialized: Boolean;
        BulkOperationId1: BigInteger;
        BulkOperationId2: BigInteger;

    local procedure Initialize()

    begin
        if IsInitialized then
            exit;
        IsInitialized := true;
        Codeunit.Run(Codeunit::"Shpfy Initialize Test");
        BulkOperationId1 := Any.IntegerInRange(100000, 555555);
        BulkOperationId2 := Any.IntegerInRange(555555, 999999);
        if BindSubscription(BulkOpSubscriber) then;
    end;

    local procedure Clear()
    var
        BulkOperation: Record "Shpfy Bulk Operation";
    begin
        BulkOperation.DeleteAll();
        BulkOpSubscriber.SetBulkOperationRunning(false);
        BulkOpSubscriber.SetBulkUploadFail(false);
    end;


    [Test]
    [HandlerFunctions('BulkMessageHandler')]
    procedure TestSendBulkOperation()
    var
        Shop: Record "Shpfy Shop";
        BulkOperation: Record "Shpfy Bulk Operation";
        BulkOperationMgt: Codeunit "Shpfy Bulk Operation Mgt.";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        BulkOperationType: Enum "Shpfy Bulk Operation Type";
        IBulkOperation: Interface "Shpfy IBulk Operation";
        tb: TextBuilder;
    begin
        // [SCENARIO] Sending a bulk operation creates a bulk operation record

        // [GIVEN] A Shop record
        Initialize();
        Shop := CommunicationMgt.GetShopRecord();

        // [WHEN] A bulk operation is sent
        BulkOpSubscriber.SetBulkOperationId(BulkOperationId1);
        IBulkOperation := BulkOperationType::AddProduct;
        tb.AppendLine(StrSubstNo(IBulkOperation.GetInput(), 'Sweet new snowboard 1', 'Snowboard', 'JadedPixel'));
        tb.AppendLine(StrSubstNo(IBulkOperation.GetInput(), 'Sweet new snowboard 2', 'Snowboard', 'JadedPixel'));
        tb.AppendLine(StrSubstNo(IBulkOperation.GetInput(), 'Sweet new snowboard 3', 'Snowboard', 'JadedPixel'));
        LibraryAssert.IsTrue(BulkOperationMgt.SendBulkMutation(Shop, BulkOperationType::AddProduct, tb.ToText()), 'Bulk operation should be sent.');

        // [THEN] A bulk operation record is created
        BulkOperation.Get(BulkOperationId1, Shop.Code, BulkOperation.Type::mutation);
        LibraryAssert.AreEqual(BulkOperation.Status, BulkOperation.Status::Created, 'Bulk operation should be created.');
        Clear();
    end;

    [Test]
    [HandlerFunctions('BulkMessageHandler')]
    procedure TestSendBulkOperationAfterPreviousCompleted()
    var
        Shop: Record "Shpfy Shop";
        BulkOperation: Record "Shpfy Bulk Operation";
        BulkOperationMgt: Codeunit "Shpfy Bulk Operation Mgt.";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        BulkOperationType: Enum "Shpfy Bulk Operation Type";
        IBulkOperation: Interface "Shpfy IBulk Operation";
        tb: TextBuilder;
    begin
        // [SCENARIO] Sending a bulk operation after previous one completed creates a bulk operation record

        // [GIVEN] A Shop record
        Initialize();
        Shop := CommunicationMgt.GetShopRecord();

        // [WHEN] A bulk operation is sent and completed
        BulkOpSubscriber.SetBulkOperationId(BulkOperationId1);
        IBulkOperation := BulkOperationType::AddProduct;
        tb.AppendLine(StrSubstNo(IBulkOperation.GetInput(), 'Sweet new snowboard 1', 'Snowboard', 'JadedPixel'));
        tb.AppendLine(StrSubstNo(IBulkOperation.GetInput(), 'Sweet new snowboard 2', 'Snowboard', 'JadedPixel'));
        tb.AppendLine(StrSubstNo(IBulkOperation.GetInput(), 'Sweet new snowboard 3', 'Snowboard', 'JadedPixel'));
        BulkOperationMgt.SendBulkMutation(Shop, BulkOperationType::AddProduct, tb.ToText());
        BulkOperation.Get(BulkOperationId1, Shop.Code, BulkOperation.Type::mutation);
        BulkOperation.Status := BulkOperation.Status::Completed;
        BulkOperation.Modify();
        // [WHEN] A second bulk operation is sent
        BulkOpSubscriber.SetBulkOperationId(BulkOperationId2);
        tb.Clear();
        tb.AppendLine('{ "input": { "title": "Sweet new snowboard 4", "productType": "Snowboard", "vendor": "JadedPixel" } }');
        tb.AppendLine('{ "input": { "title": "Sweet new snowboard 5", "productType": "Snowboard", "vendor": "JadedPixel" } }');
        tb.AppendLine('{ "input": { "title": "Sweet new snowboard 6", "productType": "Snowboard", "vendor": "JadedPixel" } }');
        LibraryAssert.IsTrue(BulkOperationMgt.SendBulkMutation(Shop, BulkOperationType::AddProduct, tb.ToText()), 'Bulk operation should be sent.');

        // [THEN] A bulk operation record is created
        BulkOperation.Get(BulkOperationId2, Shop.Code, BulkOperation.Type::mutation);
        LibraryAssert.AreEqual(BulkOperation.Status, BulkOperation.Status::Created, 'Bulk operation should be created.');
        Clear();
    end;

    [Test]
    [HandlerFunctions('BulkMessageHandler')]
    procedure TestSendBulkOperationBeforePreviousCompleted()
    var
        Shop: Record "Shpfy Shop";
        BulkOperation: Record "Shpfy Bulk Operation";
        BulkOperationMgt: Codeunit "Shpfy Bulk Operation Mgt.";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        BulkOperationType: Enum "Shpfy Bulk Operation Type";
        IBulkOperation: Interface "Shpfy IBulk Operation";
        tb: TextBuilder;
    begin
        // [SCENARIO] Sending a bulk operation after previous one has not complete does not create a bulk operation record

        // [GIVEN] A Shop record
        Initialize();
        Shop := CommunicationMgt.GetShopRecord();

        // [WHEN] A bulk operation is sent and not completed
        BulkOpSubscriber.SetBulkOperationId(BulkOperationId1);
        IBulkOperation := BulkOperationType::AddProduct;
        tb.AppendLine(StrSubstNo(IBulkOperation.GetInput(), 'Sweet new snowboard 1', 'Snowboard', 'JadedPixel'));
        tb.AppendLine(StrSubstNo(IBulkOperation.GetInput(), 'Sweet new snowboard 2', 'Snowboard', 'JadedPixel'));
        tb.AppendLine(StrSubstNo(IBulkOperation.GetInput(), 'Sweet new snowboard 3', 'Snowboard', 'JadedPixel'));
        BulkOperationMgt.SendBulkMutation(Shop, BulkOperationType::AddProduct, tb.ToText());
        // [WHEN] A second bulk operation is sent
        BulkOpSubscriber.SetBulkOperationRunning(true);
        BulkOpSubscriber.SetBulkOperationId(BulkOperationId2);
        tb.Clear();
        tb.AppendLine('{ "input": { "title": "Sweet new snowboard 4", "productType": "Snowboard", "vendor": "JadedPixel" } }');
        tb.AppendLine('{ "input": { "title": "Sweet new snowboard 5", "productType": "Snowboard", "vendor": "JadedPixel" } }');
        tb.AppendLine('{ "input": { "title": "Sweet new snowboard 6", "productType": "Snowboard", "vendor": "JadedPixel" } }');
        LibraryAssert.IsFalse(BulkOperationMgt.SendBulkMutation(Shop, BulkOperationType::AddProduct, tb.ToText()), 'Bulk operation should be sent.');

        // [THEN] A bulk operation record is not created
        LibraryAssert.RecordCount(BulkOperation, 1);
        Clear();
    end;

    [Test]
    procedure TestBulkOperationUploadFailSilent()
    var
        Shop: Record "Shpfy Shop";
        BulkOperationMgt: Codeunit "Shpfy Bulk Operation Mgt.";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        BulkOperationType: Enum "Shpfy Bulk Operation Type";
        IBulkOperation: Interface "Shpfy IBulk Operation";
        tb: TextBuilder;
    begin
        // [SCENARIO] Sending a faulty bulk operation fails silently

        // [GIVEN] A Shop record
        Initialize();
        Shop := CommunicationMgt.GetShopRecord();

        // [WHEN] A bulk operation is sent with upload failure
        BulkOpSubscriber.SetBulkUploadFail(true);
        BulkOpSubscriber.SetBulkOperationId(BulkOperationId1);
        IBulkOperation := BulkOperationType::AddProduct;
        tb.AppendLine(StrSubstNo(IBulkOperation.GetInput(), 'Sweet new snowboard 1', 'Snowboard', 'JadedPixel'));
        tb.AppendLine(StrSubstNo(IBulkOperation.GetInput(), 'Sweet new snowboard 2', 'Snowboard', 'JadedPixel'));
        tb.AppendLine(StrSubstNo(IBulkOperation.GetInput(), 'Sweet new snowboard 3', 'Snowboard', 'JadedPixel'));

        // [THEN] A bulk operation fails silently
        LibraryAssert.IsFalse(BulkOperationMgt.SendBulkMutation(Shop, BulkOperationType::AddProduct, tb.ToText()), 'Bulk operation should be sent.');
        Clear();
    end;

    [MessageHandler]
    procedure BulkMessageHandler(Message: Text[1024])
    var
        BulkOperationMsg: Label 'A bulk request was sent to Shopify. You can check the status of the synchronization in the Shopify Bulk Operations page.', Locked = true;
    begin
        LibraryAssert.ExpectedMessage(BulkOperationMsg, Message);
    end;
}