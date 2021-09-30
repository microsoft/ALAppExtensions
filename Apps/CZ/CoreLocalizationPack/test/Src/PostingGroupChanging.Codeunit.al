codeunit 148055 "Posting Group Changing CZL"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Core] [Posting Group]
        isInitialized := false;
    end;

    var
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        OriginCustomerPostingGroup: Record "Customer Posting Group";
        NewCustomerPostingGroup: Record "Customer Posting Group";
        OriginVendorPostingGroup: Record "Vendor Posting Group";
        NewVendorPostingGroup: Record "Vendor Posting Group";
        Customer: Record Customer;
        Vendor: Record Vendor;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        OriginBankAccountPostingGroup: Record "Bank Account Posting Group";
        NewBankAccountPostingGroup: Record "Bank Account Posting Group";
        BankAccount: Record "Bank Account";
        OriginInventoryPostingGroup: Record "Inventory Posting Group";
        NewInventoryPostingGroup: Record "Inventory Posting Group";
        Item: Record Item;
        ItemJournalLine: Record "Item Journal Line";
        Location: Record Location;
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalBatch: Record "Item Journal Batch";
        LibraryERM: Codeunit "Library - ERM";
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryRandom: Codeunit "Library - Random";
        Assert: Codeunit Assert;
        SalesInvNo: Code[20];
        PurchInvNo: Code[20];
        DocumentType: Enum "Gen. Journal Document Type";
        AccountType: Enum "Gen. Journal Account Type";
        isInitialized: Boolean;

    local procedure Initialize();
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Posting Group Changing CZL");
        LibraryRandom.Init();
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Posting Group Changing CZL");

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Posting Group Changing CZL");
    end;

    [Test]
    procedure CustomerPostingGroupChangeDisabled()
    begin
        // [SCENARIO] Change Customer Posting Group Disabled
        Initialize();

        // [GIVEN] New Customer Posting Groups have been created
        LibrarySales.CreateCustomerPostingGroup(OriginCustomerPostingGroup);
        LibrarySales.CreateCustomerPostingGroup(NewCustomerPostingGroup);

        // [GIVEN] New Customer has been created
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate(Customer."Customer Posting Group", OriginCustomerPostingGroup.Code);
        Customer.Modify();

        // [GIVEN] Sales Invoice has been created and posted
        LibrarySales.CreateSalesInvoiceForCustomerNo(SalesHeader, Customer."No.");
        SalesInvNo := LibrarySales.PostSalesDocument(SalesHeader, false, false);

        // [WHEN] Customer Posting Group Change 
        asserterror Customer.Validate("Customer Posting Group", NewCustomerPostingGroup.Code);

        // [THEN] Error will occurs to Posting Group must be origin
        Assert.AreEqual(Customer."Customer Posting Group", OriginCustomerPostingGroup.Code, Customer.FieldCaption(Customer."Customer Posting Group"));
    end;

    [Test]
    procedure CustomerPostingGroupChangeEnabled()
    begin
        // [SCENARIO] Change Customer Posting Group Enabled
        Initialize();

        // [GIVEN] New Customer Posting Groups have been created
        LibrarySales.CreateCustomerPostingGroup(OriginCustomerPostingGroup);
        LibrarySales.CreateCustomerPostingGroup(NewCustomerPostingGroup);

        // [GIVEN] New Customer has been created
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate(Customer."Customer Posting Group", OriginCustomerPostingGroup.Code);
        Customer.Modify();

        // [GIVEN] Sales Invoice has been created and posted
        LibrarySales.CreateSalesInvoiceForCustomerNo(SalesHeader, Customer."No.");
        SalesInvNo := LibrarySales.PostSalesDocument(SalesHeader, false, false);

        // [GIVEN] Sales Invoice has been applied
        SalesInvoiceHeader.Get(SalesInvNo);
        SalesInvoiceHeader.CalcFields("Amount Including VAT");
        LibrarySales.CreatePaymentAndApplytoInvoice(GenJournalLine, Customer."No.", SalesInvNo, -SalesInvoiceHeader."Amount Including VAT");

        // [WHEN] Customer Posting Group Change 
        Customer.Validate("Customer Posting Group", NewCustomerPostingGroup.Code);

        // [THEN] Customer Posting Group will be succesfully changed
        Assert.AreEqual(Customer."Customer Posting Group", NewCustomerPostingGroup.Code, Customer.FieldCaption(Customer."Customer Posting Group"));
    end;

    [Test]
    procedure VendorPostingGroupChangeDisabled()
    begin
        // [SCENARIO] Change Vendor Posting Group Disabled 
        Initialize();

        // [GIVEN] New Vendor Posting Groups have been created
        LibraryPurchase.CreateVendorPostingGroup(OriginVendorPostingGroup);
        LibraryPurchase.CreateVendorPostingGroup(NewVendorPostingGroup);

        // [GIVEN] New Vendor has been created
        LibraryPurchase.CreateVendor(Vendor);
        Vendor.Validate(Vendor."Vendor Posting Group", OriginVendorPostingGroup.Code);
        Vendor.Modify();

        // [GIVEN] Purchase Invoice has been created and posted
        LibraryPurchase.CreatePurchaseInvoiceForVendorNo(PurchaseHeader, Vendor."No.");
        PurchInvNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, false);

        // [WHEN] Vendor Posting Group Change 
        asserterror Vendor.Validate("Vendor Posting Group", NewVendorPostingGroup.Code);

        // [THEN] Error will occurs to Posting Group must be origin
        Assert.AreEqual(Vendor."Vendor Posting Group", OriginVendorPostingGroup.Code, Vendor.FieldCaption(Vendor."Vendor Posting Group"));
    end;

    [Test]
    procedure VendorPostingGroupChangeEnabled()
    begin
        // [SCENARIO] Change Vendor Posting Group Enabled 
        Initialize();

        // [GIVEN] New Vendor Posting Groups have been created
        LibraryPurchase.CreateVendorPostingGroup(OriginVendorPostingGroup);
        LibraryPurchase.CreateVendorPostingGroup(NewVendorPostingGroup);

        // [GIVEN] New Vendor has been created
        LibraryPurchase.CreateVendor(Vendor);
        Vendor.Validate(Vendor."Vendor Posting Group", OriginVendorPostingGroup.Code);
        Vendor.Modify();

        // [GIVEN] Purchase Invoice has been created and posted
        LibraryPurchase.CreatePurchaseInvoiceForVendorNo(PurchaseHeader, Vendor."No.");
        PurchInvNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, false);

        // [GIVEN] Purchase Invoice has been applied
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        PurchInvHeader.Get(PurchInvNo);
        PurchInvHeader.CalcFields("Amount Including VAT");
        LibraryERM.CreateGeneralJnlLine(GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name,
                        DocumentType::"Payment", AccountType::Vendor, Vendor."No.", PurchInvHeader."Amount Including VAT");
        GenJournalLine.Validate(GenJournalLine."Applies-to Doc. Type", GenJournalLine."Applies-to Doc. Type"::Invoice);
        GenJournalLine.Validate(GenJournalLine."Applies-to Doc. No.", PurchInvNo);
        GenJournalLine.Validate(GenJournalLine."Bal. Account No.", LibraryERM.CreateGLAccountNo());
        GenJournalLine.Modify(true);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [WHEN] Vendor Posting Group Change 
        Vendor.Validate("Vendor Posting Group", NewVendorPostingGroup.Code);

        // [THEN] Vendor Posting Group will be succesfully changed
        Assert.AreEqual(Vendor."Vendor Posting Group", NewVendorPostingGroup.Code, Vendor.FieldCaption(Vendor."Vendor Posting Group"));
    end;

    [Test]
    procedure BankAccPostingGroupChangeDisabled()
    begin
        // [SCENARIO] Change Bank Account Posting Group Disabled
        Initialize();

        // [GIVEN] New Bank Account Posting Groups have been created
        LibraryERM.CreateBankAccountPostingGroup(OriginBankAccountPostingGroup);
        LibraryERM.CreateBankAccountPostingGroup(NewBankAccountPostingGroup);
        OriginBankAccountPostingGroup.Validate(OriginBankAccountPostingGroup."G/L Account No.", LibraryERM.CreateGLAccountNo());
        OriginBankAccountPostingGroup.Modify(true);
        NewBankAccountPostingGroup.Validate(NewBankAccountPostingGroup."G/L Account No.", LibraryERM.CreateGLAccountNo());
        NewBankAccountPostingGroup.Modify(true);

        // [GIVEN] New Bank Account has been created
        LibraryERM.CreateBankAccount(BankAccount);
        BankAccount.Validate(BankAccount."Bank Acc. Posting Group", OriginBankAccountPostingGroup.Code);
        BankAccount.Modify(true);

        // [GIVEN] Gen. Journal Line has been created and posted
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        LibraryERM.CreateGeneralJnlLine(GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name,
                        DocumentType::" ", AccountType::"Bank Account", BankAccount."No.", 100);
        GenJournalLine.Validate(GenJournalLine."Bal. Account Type", GenJournalLine."Bal. Account Type"::"G/L Account");
        GenJournalLine.Validate(GenJournalLine."Bal. Account No.", LibraryERM.CreateGLAccountNo());
        GenJournalLine.Modify(true);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [WHEN] Bank Account Posting Group Change 
        asserterror BankAccount.Validate("Bank Acc. Posting Group", NewBankAccountPostingGroup.Code);

        // [THEN] Error will occurs to Posting Group must be origin
        Assert.AreEqual(BankAccount."Bank Acc. Posting Group", OriginBankAccountPostingGroup.Code, BankAccount.FieldCaption(BankAccount."Bank Acc. Posting Group"));
    end;

    [Test]
    procedure BankAccPostingGroupChangeEnabled()
    begin
        // [SCENARIO] Change Bank Account Posting Group Enabled
        Initialize();

        // [GIVEN] New Bank Account Posting Groups have been created
        LibraryERM.CreateBankAccountPostingGroup(OriginBankAccountPostingGroup);
        LibraryERM.CreateBankAccountPostingGroup(NewBankAccountPostingGroup);
        OriginBankAccountPostingGroup.Validate(OriginBankAccountPostingGroup."G/L Account No.", LibraryERM.CreateGLAccountNo());
        OriginBankAccountPostingGroup.Modify(true);
        NewBankAccountPostingGroup.Validate(NewBankAccountPostingGroup."G/L Account No.", LibraryERM.CreateGLAccountNo());
        NewBankAccountPostingGroup.Modify(true);

        // [GIVEN] New Bank Account has been created
        LibraryERM.CreateBankAccount(BankAccount);
        BankAccount.Validate(BankAccount."Bank Acc. Posting Group", OriginBankAccountPostingGroup.Code);
        BankAccount.Modify(true);

        // [GIVEN] Gen. Journal Line has been created and posted
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        LibraryERM.CreateGeneralJnlLine(GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name,
                        DocumentType::" ", AccountType::"Bank Account", BankAccount."No.", 100);
        GenJournalLine.Validate(GenJournalLine."Bal. Account Type", GenJournalLine."Bal. Account Type"::"G/L Account");
        GenJournalLine.Validate(GenJournalLine."Bal. Account No.", LibraryERM.CreateGLAccountNo());
        GenJournalLine.Modify(true);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [GIVEN] Bank Account has been posted to zero
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        LibraryERM.CreateGeneralJnlLine(GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name,
                        DocumentType::"Payment", AccountType::"Bank Account", BankAccount."No.", -100);
        GenJournalLine.Validate(GenJournalLine."Bal. Account Type", GenJournalLine."Bal. Account Type"::"G/L Account");
        GenJournalLine.Validate(GenJournalLine."Bal. Account No.", LibraryERM.CreateGLAccountNo());
        GenJournalLine.Modify(true);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [WHEN] Bank Account Posting Group Change 
        BankAccount.Validate("Bank Acc. Posting Group", NewBankAccountPostingGroup.Code);

        // [THEN] Bank Account Posting Group will be succesfully changed
        Assert.AreEqual(BankAccount."Bank Acc. Posting Group", NewBankAccountPostingGroup.Code, BankAccount.FieldCaption(BankAccount."Bank Acc. Posting Group"));
    end;

    [Test]
    procedure InventoryPostingGroupChangeDisabled()
    begin
        // [SCENARIO] Change Inventory Posting Group Disabled
        Initialize();

        // [GIVEN] New Inventory Posting Groups have been created
        LibraryInventory.CreateInventoryPostingGroup(OriginInventoryPostingGroup);
        LibraryInventory.CreateInventoryPostingGroup(NewInventoryPostingGroup);

        // [GIVEN] New Item has been created
        LibraryInventory.CreateItem(Item);
        Item.Validate(Item."Inventory Posting Group", OriginInventoryPostingGroup.Code);
        Item.Modify(true);

        // [GIVEN] New Location has been created and set up
        Location.Init();
        Location.Code := CopyStr(LibraryRandom.RandText(10), 1, 10);
        Location.Insert(true);
        LibraryInventory.UpdateInventoryPostingSetup(Location);

        // [GIVEN] Item Journal Line positive has been created and posted
        LibraryInventory.CreateItemJournalLineInItemTemplate(ItemJournalLine, Item."No.", Location.Code, '', 2);
        LibraryInventory.PostItemJournalLine(ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name");

        // [WHEN] Item Posting Group Change
        asserterror Item.Validate("Inventory Posting Group", NewInventoryPostingGroup.Code);

        // [THEN] Error will occurs to Posting Group must be origin
        Assert.AreEqual(Item."Inventory Posting Group", OriginInventoryPostingGroup.Code, Item.FieldCaption(Item."Inventory Posting Group"));
    end;

    [Test]
    procedure InventoryPostingGroupChangeEnabled()
    begin
        // [SCENARIO] Change Inventory Posting Group Enabled
        Initialize();

        // [GIVEN] New Inventory Posting Groups have been created
        LibraryInventory.CreateInventoryPostingGroup(OriginInventoryPostingGroup);
        LibraryInventory.CreateInventoryPostingGroup(NewInventoryPostingGroup);

        // [GIVEN] New Item has been created
        LibraryInventory.CreateItem(Item);
        Item.Validate(Item."Inventory Posting Group", OriginInventoryPostingGroup.Code);
        Item.Modify(true);

        // [GIVEN] New Location has been created and set up
        Location.Init();
        Location.Code := CopyStr(LibraryRandom.RandText(10), 1, 10);
        Location.Insert(true);
        LibraryInventory.UpdateInventoryPostingSetup(Location);

        // [GIVEN] Item Journal Line positive has been created and posted
        LibraryInventory.CreateItemJournalLineInItemTemplate(ItemJournalLine, Item."No.", Location.Code, '', 2);
        LibraryInventory.PostItemJournalLine(ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name");

        // [GIVEN] Item has been posted to zero
        LibraryInventory.SelectItemJournalTemplateName(ItemJournalTemplate, ItemJournalTemplate.Type::Item);
        LibraryInventory.SelectItemJournalBatchName(ItemJournalBatch, ItemJournalTemplate.Type::Item, ItemJournalTemplate.Name);
        LibraryInventory.CreateItemJournalLine(
          ItemJournalLine, ItemJournalTemplate.Name, ItemJournalBatch.Name, ItemJournalLine."Entry Type"::"Negative Adjmt.", Item."No.", 2);
        ItemJournalLine.Validate("Location Code", Location.Code);
        ItemJournalLine.Modify(true);
        LibraryInventory.PostItemJournalLine(ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name");

        // [WHEN] Item Posting Group Change 
        Item.Validate("Inventory Posting Group", NewInventoryPostingGroup.Code);

        // [THEN] Item Posting Group will be succesfully changed
        Assert.AreEqual(Item."Inventory Posting Group", NewInventoryPostingGroup.Code, Item.FieldCaption(Item."Inventory Posting Group"));
    end;
}
