codeunit 148094 "Posting Groups CZA"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        Assert: Codeunit Assert;
        LibraryDialogHandler: Codeunit "Library - Dialog Handler";
        LibraryERM: Codeunit "Library - ERM";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        isInitialized: Boolean;
        ChangeCustPostGrErr: Label 'Customer Posting Group  cannot be changed in Customer No.=''%1''.', Comment = '%1=Customer No.';
        ChangeVendPostGrErr: Label 'Vendor Posting Group  cannot be changed in Vendor No.=''%1''.', Comment = '%1=Vendor No.';
        ChangeRecAccountQst: Label 'Do you really want to change %1 although open entries exist?', Comment = '%1=FIELDCAPTION';

    local procedure Initialize();
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Posting Groups CZA");
        LibraryRandom.Init();
        LibraryDialogHandler.ClearVariableStorage();
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Posting Groups CZA");

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Posting Groups CZA");
    end;

    [Test]
    procedure ChangePostingGroupOnCustomerWithoutEntries()
    var
        Customer: Record Customer;
        CustomerPostingGroup: Record "Customer Posting Group";
    begin
        Initialize();

        // [GIVEN] The customer without some entries has been created.
        LibrarySales.CreateCustomer(Customer);

        // [GIVEN] The customer posting group has been created.
        LibrarySales.CreateCustomerPostingGroup(CustomerPostingGroup);

        // [WHEN] Change customer posting group in customer.
        Customer.Validate("Customer Posting Group", CustomerPostingGroup.Code);

        // [THEN] Any error occur
    end;

    [Test]
    procedure ChangePostingGroupOnCustomerWithOpenEntries()
    var
        Customer: Record Customer;
        CustomerPostingGroup: Record "Customer Posting Group";
    begin
        Initialize();

        // [GIVEN] The customer has been created.
        LibrarySales.CreateCustomer(Customer);

        // [GIVEN] The customer posting group has been created.
        LibrarySales.CreateCustomerPostingGroup(CustomerPostingGroup);

        // [GIVEN] The customer ledger entry has been created.
        CreateCustomerLedgerEntry(Customer);

        // [WHEN] Change customer posting group in customer.
        asserterror Customer.Validate("Customer Posting Group", CustomerPostingGroup.Code);

        // [THEN] The error occurs
        Assert.ExpectedError(StrSubstNo(ChangeCustPostGrErr, Customer."No."));
    end;

    [Test]
    procedure ChangePostingGroupOnVendorWithoutEntries()
    var
        Vendor: Record Vendor;
        VendorPostingGroup: Record "Vendor Posting Group";
    begin
        Initialize();

        // [GIVEN] The vendor without some entries has been created.
        LibraryPurchase.CreateVendor(Vendor);

        // [GIVEN] The vendor posting group has been created.
        LibraryPurchase.CreateVendorPostingGroup(VendorPostingGroup);

        // [WHEN] Change vendor posting group in vendor.
        Vendor.Validate("Vendor Posting Group", VendorPostingGroup.Code);
    end;

    [Test]
    procedure ChangePostingGroupOnVendorWithOpenEntries()
    var
        Vendor: Record Vendor;
        VendorPostingGroup: Record "Vendor Posting Group";
    begin
        Initialize();

        // [GIVEN] The vendor has been created.
        LibraryPurchase.CreateVendor(Vendor);

        // [GIVEN] The vendor posting group has been created.
        LibraryPurchase.CreateVendorPostingGroup(VendorPostingGroup);

        // [GIVEN] The vendor ledger entry has been created.
        CreateVendorLedgerEntry(Vendor);

        // [WHEN] Change vendor posting group in vendor.
        asserterror Vendor.Validate("Vendor Posting Group", VendorPostingGroup.Code);

        // [THEN] An error occurs
        Assert.ExpectedError(StrSubstNo(ChangeVendPostGrErr, Vendor."No."));
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure ChangeReceivablesAccountOnCustomerPostingGroup()
    var
        Customer: Record Customer;
        CustomerPostingGroup: Record "Customer Posting Group";
    begin
        Initialize();

        // [GIVEN] The customer posting group has been created.
        LibrarySales.CreateCustomerPostingGroup(CustomerPostingGroup);

        // [GIVEN] The customer with created posting group has been created.
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Customer Posting Group", CustomerPostingGroup.Code);
        Customer.Modify();

        // [GIVEN] The customer ledger entry has been created.
        CreateCustomerLedgerEntry(Customer);

        // [WHEN] Change receivables account in customer posting group.
        LibraryDialogHandler.SetExpectedConfirm(StrSubstNo(ChangeRecAccountQst, CustomerPostingGroup.FieldCaption("Receivables Account")), true);
        CustomerPostingGroup.Validate("Receivables Account", LibraryERM.CreateGLAccountNo());

        // [THEN] A confirm dialog will pop up
        // The verification of correct confirm message is in confirm handler
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure ChangeReceivablesAccountOnVendorPostingGroup()
    var
        Vendor: Record Vendor;
        VendorPostingGroup: Record "Vendor Posting Group";
    begin
        Initialize();

        // [GIVEN] The vendor posting group has been created.
        LibraryPurchase.CreateVendorPostingGroup(VendorPostingGroup);

        // [GIVEN] The vendor with created posting group has been created.
        LibraryPurchase.CreateVendor(Vendor);
        Vendor.Validate("Vendor Posting Group", VendorPostingGroup.Code);
        Vendor.Modify();

        // [GIVEN] The vendor ledger entry has been created.
        CreateVendorLedgerEntry(Vendor);

        // [WHEN] Change payables account in vendor posting group.
        LibraryDialogHandler.SetExpectedConfirm(StrSubstNo(ChangeRecAccountQst, VendorPostingGroup.FieldCaption("Payables Account")), true);
        VendorPostingGroup.Validate("Payables Account", LibraryERM.CreateGLAccountNo());

        // [THEN] A confirm dialog will pop up
        // The verification of correct confirm message is in confirm handler
    end;

    [Test]
    procedure AddingDefGenBusPostGroupsForTransferOrder()
    var
        TransferHeader: Record "Transfer Header";
        TransferRoute: Record "Transfer Route";
    begin
        Initialize();

        // [GIVEN] The transfer route has been created.
        CreateAndModifyTransferRoute(TransferRoute);

        // [WHEN] Create transfer header and use the created transfer route.
        LibraryWarehouse.CreateTransferHeader(TransferHeader, TransferRoute."Transfer-from Code", TransferRoute."Transfer-to Code", '');

        // [THEN] The general business posting groups from transfer route will be used.
        TransferHeader.TestField("Gen.Bus.Post.Group Receive CZA", TransferRoute."Gen.Bus.Post.Group Receive CZA");
        TransferHeader.TestField("Gen.Bus.Post.Group Ship CZA", TransferRoute."Gen.Bus.Post.Group Ship CZA");
    end;

    [Test]
    procedure AddingDefGenBusPostGroupsForItemJnlTemplate()
    var
        ItemJournalLine: Record "Item Journal Line";
        InvtMovementTemplateCZL: Record "Invt. Movement Template CZL";
    begin
        Initialize();

        // [GIVEN] The inventory movement template has been created.
        CreateInvtMovementTemplate(InvtMovementTemplateCZL);

        // [GIVEN] The item journal line has been created.
        CreateItemJnlLine(ItemJournalLine);

        // [WHEN] Validate inventory movement template in item journal line
        ItemJournalLine.Validate("Invt. Movement Template CZL", InvtMovementTemplateCZL.Name);

        // [THEN] The entry type and general business posting group from invt. movement template will be used.
        ItemJournalLine.TestField("Entry Type", InvtMovementTemplateCZL."Entry Type");
        ItemJournalLine.TestField("Gen. Bus. Posting Group", InvtMovementTemplateCZL."Gen. Bus. Posting Group");
    end;

    local procedure CreateAndModifyTransferRoute(var TransferRoute: Record "Transfer Route")
    var
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
        Location: Record Location;
        InTransitLocation: Record Location;
        ShippingAgent: Record "Shipping Agent";
        ShippingAgentServices: Record "Shipping Agent Services";
        ShippingTime: DateFormula;
    begin
        LibraryWarehouse.CreateLocation(Location);
        LibraryWarehouse.CreateInTransitLocation(InTransitLocation);
        LibraryInventory.CreateShippingAgent(ShippingAgent);
        Evaluate(ShippingTime, '<' + Format(LibraryRandom.RandInt(5)) + 'D>');  // Use Random value for Shipping Time.
        LibraryInventory.CreateShippingAgentService(ShippingAgentServices, ShippingAgent.Code, ShippingTime);
        LibraryERM.CreateGenBusPostingGroup(GenBusinessPostingGroup);
        LibraryWarehouse.CreateAndUpdateTransferRoute(
          TransferRoute, Location.Code, GetFirstLocation(false), InTransitLocation.Code, ShippingAgent.Code, ShippingAgentServices.Code);
        TransferRoute.Validate("Gen.Bus.Post.Group Receive CZA", GenBusinessPostingGroup.Code);
        TransferRoute.Validate("Gen.Bus.Post.Group Ship CZA", GenBusinessPostingGroup.Code);
        TransferRoute.Modify();
    end;

    local procedure CreateCustomerLedgerEntry(Customer: Record Customer)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        LibraryERM.SelectGenJnlBatch(GenJournalBatch);
        LibraryERM.CreateGeneralJnlLine(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, Enum::"Gen. Journal Document Type"::" ",
          GenJournalLine."Account Type"::Customer, Customer."No.",
          LibraryRandom.RandDec(1000, 2));
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreateItemJnlLine(var ItemJournalLine: Record "Item Journal Line")
    var
        Item: Record Item;
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalTemplate: Record "Item Journal Template";
    begin
        LibraryInventory.CreateItemJournalTemplate(ItemJournalTemplate);
        LibraryInventory.CreateItemJournalBatch(ItemJournalBatch, ItemJournalTemplate.Name);
        LibraryInventory.CreateItem(Item);
        LibraryInventory.CreateItemJournalLine(
          ItemJournalLine, ItemJournalBatch."Journal Template Name", ItemJournalBatch.Name, "Gen. Journal Document Type"::" ", Item."No.", 1);
    end;

    local procedure CreateVendorLedgerEntry(Vendor: Record Vendor)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        LibraryERM.SelectGenJnlBatch(GenJournalBatch);
        LibraryERM.CreateGeneralJnlLine(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, "Gen. Journal Document Type"::" ",
          GenJournalLine."Account Type"::Vendor, Vendor."No.",
          LibraryRandom.RandDec(1000, 2));
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreateInvtMovementTemplate(var InvtMovementTemplateCZL: Record "Invt. Movement Template CZL")
    var
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
    begin
        LibraryERM.CreateGenBusPostingGroup(GenBusinessPostingGroup);
        InvtMovementTemplateCZL.Init();
        InvtMovementTemplateCZL.Validate(
          Name,
          CopyStr(LibraryUtility.GenerateRandomCode(InvtMovementTemplateCZL.FieldNo(Name), Database::"Invt. Movement Template CZL"),
            1, LibraryUtility.GetFieldLength(Database::"Invt. Movement Template CZL", InvtMovementTemplateCZL.FieldNo(Name))));
        InvtMovementTemplateCZL.Validate("Entry Type", InvtMovementTemplateCZL."Entry Type"::"Negative Adjmt.");
        InvtMovementTemplateCZL.Validate("Gen. Bus. Posting Group", GenBusinessPostingGroup.Code);
        InvtMovementTemplateCZL.Insert();
    end;

    local procedure GetFirstLocation(UseAsInTransit: Boolean): Code[10]
    var
        Location: Record Location;
    begin
        if not Location.Get('A') then begin
            Location.Init();
            Location.Validate(Code, 'A');
            Location.Validate(Name, 'A');
            Location.Insert(true);
            LibraryInventory.UpdateInventoryPostingSetup(Location);
        end;

        Location.Validate("Use As In-Transit", UseAsInTransit);
        Location.Modify(true);

        exit(Location.Code);
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        LibraryDialogHandler.HandleConfirm(Question, Reply);
    end;
}

