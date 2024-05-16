codeunit 147107 "CD Red Storno"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryCDTracking: Codeunit "Library - CD Tracking";
        LibraryItemTracking: Codeunit "Library - Item Tracking";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryERM: Codeunit "Library - ERM";
        LibraryCosting: Codeunit "Library - Costing";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        Assert: Codeunit Assert;
        isInitialized: Boolean;
        WrongValueErr: Label 'Wrong value of field %1 in table %2.';

    [Test]
    [Scope('OnPrem')]
    procedure TestRedStorno()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemTrackingCode: Record "Item Tracking Code";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Customer: Record Customer;
        Vendor: Record Vendor;
        Item: Record Item;
        ReservationEntry: Record "Reservation Entry";
        ItemJournalLine: Record "Item Journal Line";
        Location: Record Location;
        CDNo: Code[50];
        Qty: Integer;
    begin
        Initialize();

        LibraryCDTracking.CreateForeignVendor(Vendor);
        LibrarySales.CreateCustomer(Customer);
        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(Location);
        LibraryItemTracking.CreateItemTrackingCode(ItemTrackingCode, false, false, true);

        LibraryItemTracking.CreateItemWithItemTrackingCode(Item, ItemTrackingCode);

        CDNo := CreatePackageInfo(Item."No.");

        LibraryPurchase.CreatePurchaseOrderWithLocation(PurchaseHeader, Vendor."No.", Location.Code);
        Qty := LibraryRandom.RandInt(3);
        LibraryPurchase.CreatePurchaseLineWithUnitCost(
          PurchaseLine, PurchaseHeader, Item."No.", LibraryRandom.RandDec(100, 2), Qty);
        LibraryItemTracking.CreatePurchOrderItemTracking(ReservationEntry, PurchaseLine, '', '', CDNo, Qty);
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        LibraryItemTracking.CheckLastItemLedgerEntry(ItemLedgerEntry, Item."No.", Location.Code, '', '', CDNo, Qty);

        LibraryCDTracking.CreateItemJnlLine(ItemJournalLine, "Item Ledger Entry Type"::Purchase, WorkDate(), Item."No.", -Qty, Location.Code);
        ItemJournalLine."Red Storno" := true;
        ItemJournalLine.Modify();

        LibraryItemTracking.CreateItemJournalLineItemTracking(ReservationEntry, ItemJournalLine, '', '', CDNo, -Qty);
        ReservationEntry.Validate("Appl.-to Item Entry", ItemLedgerEntry."Entry No.");
        ReservationEntry.Modify();
        LibraryCDTracking.PostItemJnlLine(ItemJournalLine);

        LibraryItemTracking.CheckLastItemLedgerEntry(ItemLedgerEntry, Item."No.", Location.Code, '', '', CDNo, -Qty);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TFS336176_Ship()
    var
        InvtDocumentHeader: Record "Invt. Document Header";
    begin
        TFS336176_ShipReceipt(InvtDocumentHeader."Document Type"::Shipment);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TFS336176_Receipt()
    var
        InvtDocumentHeader: Record "Invt. Document Header";
    begin
        TFS336176_ShipReceipt(InvtDocumentHeader."Document Type"::Receipt);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TFS336176_CheckErrNoApplyEntry()
    var
        ItemJnlLine: Record "Item Journal Line";
        ItemCode: Code[20];
        LocationCode: Code[10];
        ItemQty: Integer;
        Amount: Decimal;
    begin
        Initialize();
        ItemQty := LibraryRandom.RandInt(3);
        Amount := LibraryRandom.RandDec(100, 2);

        ItemCode := LibraryInventory.CreateItemNo();
        LocationCode := CreateLocation();
        CreateInventoryPostingSetup(LocationCode, GetItemGroupCode(ItemCode));

        CreatePostItemJnlLine(ItemCode, LocationCode, ItemQty, Amount);
        CreatePostInvtDocument("Invt. Doc. Document Type"::Shipment, LocationCode, ItemCode, ItemQty, Amount);
        asserterror CreatePostShipCorrItDocNoApply(LocationCode, ItemCode, ItemQty, Amount);
        Assert.ExpectedTestFieldError(ItemJnlLine.FieldCaption("Applies-from Entry"), '');
    end;

    local procedure TFS336176_ShipReceipt(DocType: Enum "Invt. Doc. Document Type")
    var
        Amount: Decimal;
    begin
        Initialize();
        Amount := LibraryRandom.RandDec(100, 2);
        CreateDocRunAdjustCostEntries(DocType, Amount);
        VerifyPostedGLEntries(DocType, Amount);
    end;

    [Test]
    [HandlerFunctions('SalesInvoiceLinesModalPageHandler,CorrectionTypeStrMenuHandler')]
    [Scope('OnPrem')]
    procedure BlankAppliesFromEntryForCorrCrMemoWithTracking()
    var
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ReservationEntry: Record "Reservation Entry";
        ItemTrackingCode: Record "Item Tracking Code";
        CorrectiveDocumentMgt: Codeunit "Corrective Document Mgt.";
        InvoiceNo: Code[20];
        CDNo: Code[50];
    begin
        // [FEATURE] [Sales] [Correction] [Credit Memo] [Item Tracking]
        // [SCENARIO 206411] Function "Get Corr. Lines" of Corrective Sales Credit Memo does not assign "Applies-From Item Entry No." automatically if tracking exists

        Initialize();

        // [GIVEN] Inventory Setup "Enable Red Storno" = TRUE.
        // [GIVEN] Posted Sales Invoice "I" with Item Tracking for "Package No."

        LibraryItemTracking.CreateItemTrackingCode(ItemTrackingCode, false, false, true);
        CreateItemWithTrackingCode(Item, ItemTrackingCode.Code);
        CDNo := CreatePackageInfo(Item."No.");

        LibrarySales.CreateSalesOrderWithLocation(SalesHeader, LibrarySales.CreateCustomerNo(), '');
        LibrarySales.CreateSalesLineWithUnitPrice(
          SalesLine, SalesHeader, LibraryInventory.CreateItemNo(), LibraryRandom.RandDec(100, 2), LibraryRandom.RandIntInRange(100, 200));
        LibraryItemTracking.CreateSalesOrderItemTracking(ReservationEntry, SalesLine, '', '', CDNo, SalesLine.Quantity);
        InvoiceNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [GIVEN] Create Corrective Sales Credit Memo with "Corrective Doc. Type" = Revision. Use "Get Corr. Doc. Lines" from posted invoice "I".
        LibrarySales.CreateCorrSalesCrMemoByInvNo(SalesHeader, SalesHeader."Bill-to Customer No.", InvoiceNo);

        // [WHEN] Invoke function "Get Corr. Lines" against Corrective Sales Credit Memo and select line from Posted Sales Invoice
        // Selection handled by SalesInvoiceLinesModalPageHandler
        CorrectiveDocumentMgt.SetSalesHeader(SalesHeader."Document Type".AsInteger(), SalesHeader."No.");
        CorrectiveDocumentMgt.SelectPstdSalesDocLines();

        // [THEN] Sales Line is copied from Posted Sales Invoice to Corrective Sales Credit Memo and "Applies-From Item Entry No. is blank
        FindSalesLine(SalesLine, SalesHeader."Document Type", SalesHeader."No.");
        SalesLine.TestField("Appl.-from Item Entry", 0);
    end;

    local procedure Initialize()
    begin
        if isInitialized then
            exit;

        LibraryCDTracking.UpdateERMCountryData();

        EnableRedStorno();
        DisableStockoutWarning();

        isInitialized := true;
    end;

    local procedure EnableRedStorno()
    var
        InventorySetup: Record "Inventory Setup";
    begin
        InventorySetup.Get();
        InventorySetup."Enable Red Storno" := true;
        InventorySetup.Modify(true);
    end;

    local procedure DisableStockoutWarning()
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup.Validate("Stockout Warning", false);
        SalesReceivablesSetup.Modify(true);
    end;

    local procedure CreateInventoryPostingSetup(LocationCode: Code[10]; PostGroupCode: Code[20])
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
    begin
        with InventoryPostingSetup do begin
            LibraryInventory.CreateInventoryPostingSetup(InventoryPostingSetup, LocationCode, PostGroupCode);
            Validate("Inventory Account", LibraryERM.CreateGLAccountNo());
            Modify(true);
        end;
    end;

    local procedure CreatePostItemJnlLine(ItemNo: Code[20]; LocationCode: Code[10]; Qty: Decimal; UnitAmt: Decimal)
    var
        ItemJournalLine: Record "Item Journal Line";
    begin
        CreateItemJnlLine(ItemJournalLine, ItemNo, LocationCode, ItemJournalLine."Entry Type"::"Positive Adjmt.", Qty, UnitAmt);
        LibraryInventory.PostItemJournalLine(ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name");
    end;

    local procedure CreateItemJnlLine(var ItemJournalLine: Record "Item Journal Line"; ItemNo: Code[20]; LocationCode: Code[10]; EntryType: Enum "Item Ledger Entry Type"; Qty: Decimal; UnitAmt: Decimal)
    var
        ItemJournalBatch: Record "Item Journal Batch";
        TemplateName: Code[10];
        ItemJnlTemplateType: Option Item,Transfer,"Phys. Inventory",Revaluation,Consumption,Output,Capacity,"Prod.Order";
    begin
        TemplateName := FindItemJnlTemplate(ItemJnlTemplateType::Item);
        LibraryInventory.CreateItemJournalBatch(ItemJournalBatch, TemplateName);

        with ItemJournalLine do begin
            LibraryInventory.CreateItemJournalLine(
              ItemJournalLine, TemplateName, ItemJournalBatch.Name, EntryType, ItemNo, Qty);
            Validate("Location Code", LocationCode);
            Validate("Unit Amount", UnitAmt);
            Modify(true);
        end;
    end;

    local procedure CreateLocation(): Code[10]
    var
        Location: Record Location;
    begin
        LibraryWarehouse.CreateLocation(Location);
        exit(Location.Code);
    end;

    local procedure FindItemJnlTemplate(ItemJnlTemplateType: Option): Code[10]
    var
        ItemJournalTemplate: Record "Item Journal Template";
    begin
        ItemJournalTemplate.SetRange(Type, ItemJnlTemplateType);
        ItemJournalTemplate.SetRange(Recurring, false);
        ItemJournalTemplate.FindFirst();
        exit(ItemJournalTemplate.Name);
    end;

    local procedure FindSalesLine(var SalesLine: Record "Sales Line"; DocType: Enum "Sales Document Type"; DocNo: Code[20])
    begin
        SalesLine.SetRange("Document Type", DocType);
        SalesLine.SetRange("Document No.", DocNo);
        SalesLine.FindFirst();
    end;

    local procedure GetItemGroupCode(ItemCode: Code[20]): Code[20]
    var
        Item: Record Item;
    begin
        Item.Get(ItemCode);
        exit(Item."Inventory Posting Group");
    end;

    local procedure GetItemLedgEntryNo(ItemNo: Code[20]; LocationCode: Code[10]): Integer
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        with ItemLedgerEntry do begin
            SetRange("Item No.", ItemNo);
            SetRange("Location Code", LocationCode);
            if FindLast() then
                exit("Entry No.");
        end;
    end;

    local procedure CreatePostShipCorrItDocNoApply(LocationCode: Code[10]; ItemNo: Code[20]; Qty: Decimal; UnitAmt: Decimal)
    var
        InvtDocumentHeader: Record "Invt. Document Header";
    begin
        CreatePostCorrInvtDocument(InvtDocumentHeader."Document Type"::Shipment, LocationCode, ItemNo, Qty, UnitAmt, 0);
    end;

    local procedure CreatePostCorrInvtDocument(DocType: Enum "Invt. Doc. Document Type"; LocationCode: Code[10]; ItemNo: Code[20]; Qty: Decimal; UnitAmt: Decimal; ApplyEntry: Integer)
    var
        InvtDocumentHeader: Record "Invt. Document Header";
        InvtDocumentLine: Record "Invt. Document Line";
    begin
        with InvtDocumentHeader do begin
            CreateInvtDocument(InvtDocumentHeader, DocType, LocationCode);
            Validate(Correction, true);
            Modify(true);
        end;

        with InvtDocumentLine do begin
            CreateInvtDocumentLine(InvtDocumentHeader, InvtDocumentLine, ItemNo, Qty, UnitAmt);
            if "Document Type" = "Document Type"::Shipment then
                Validate("Applies-from Entry", ApplyEntry)
            else
                Validate("Applies-to Entry", ApplyEntry);
            Modify(true);
        end;
        LibraryInventory.PostInvtDocument(InvtDocumentHeader);
    end;

    local procedure CreatePostInvtDocument(DocumentType: Enum "Invt. Doc. Document Type"; LocationCode: Code[10]; ItemNo: Code[20]; Qty: Decimal; UnitAmt: Decimal)
    var
        InvtDocumentHeader: Record "Invt. Document Header";
        InvtDocumentLine: Record "Invt. Document Line";
    begin
        CreateInvtDocument(InvtDocumentHeader, DocumentType, LocationCode);
        CreateInvtDocumentLine(InvtDocumentHeader, InvtDocumentLine, ItemNo, Qty, UnitAmt);
        LibraryInventory.PostInvtDocument(InvtDocumentHeader);
    end;

    local procedure CreateInvtDocument(var InvtDocumentHeader: Record "Invt. Document Header"; DocumentType: Enum "Invt. Doc. Document Type"; LocationCode: Code[10])
    begin
        with InvtDocumentHeader do begin
            Init();
            "Document Type" := DocumentType;
            Insert(true);
            Validate("Location Code", LocationCode);
            Modify();
        end;
    end;

    local procedure CreateInvtDocumentLine(var InvtDocumentHeader: Record "Invt. Document Header"; var InvtDocumentLine: Record "Invt. Document Line"; ItemNo: Code[20]; Qty: Decimal; UnitAmt: Decimal)
    var
        TableRecordRef: RecordRef;
    begin
        with InvtDocumentLine do begin
            Init();
            Validate("Document Type", InvtDocumentHeader."Document Type");
            Validate("Document No.", InvtDocumentHeader."No.");
            TableRecordRef.GetTable(InvtDocumentLine);
            Validate("Line No.", LibraryUtility.GetNewLineNo(TableRecordRef, FieldNo("Line No.")));
            Insert(true);
            Validate("Item No.", ItemNo);
            Validate(Quantity, Qty);
            Validate("Unit Amount", UnitAmt);
            Modify(true);
        end;
    end;

    local procedure CreatePackageInfo(ItemNo: Code[20]) CDNo: Code[50]
    var
        CountryRegion: Record "Country/Region";
        CDNumberHeader: Record "CD Number Header";
        PackageNoInformation: Record "Package No. Information";
    begin
        LibraryERM.CreateCountryRegion(CountryRegion);
        LibraryCDTracking.CreateCDNumberHeader(CDNumberHeader, CountryRegion.Code);
        CDNo := LibraryUtility.GenerateGUID();
        LibraryCDTracking.UpdatePackageInfo(CDNumberHeader, PackageNoInformation, ItemNo, CDNo);
        exit(CDNo);
    end;

    local procedure CreateItemWithTrackingCode(var Item: Record Item; TrackingCode: Code[10])
    begin
        LibraryInventory.CreateItem(Item);
        Item.Validate("Item Tracking Code", TrackingCode);
        Item.Modify(true);
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure SalesInvoiceLinesModalPageHandler(var SalesInvoiceLines: TestPage "Sales Invoice Lines")
    begin
        SalesInvoiceLines.OK().Invoke();
    end;

    [StrMenuHandler]
    [Scope('OnPrem')]
    procedure CorrectionTypeStrMenuHandler(Options: Text; var Choice: Integer; Instruction: Text)
    begin
        Choice := 1; // Quantity
    end;

    local procedure VerifyPostedGLEntries(DocType: Enum "Invt. Doc. Document Type"; ExpectedAmount: Decimal)
    var
        InvtDocumentHeader: Record "Invt. Document Header";
        GLRegister: Record "G/L Register";
        GLEntry: Record "G/L Entry";
    begin
        GLRegister.FindLast();
        with GLEntry do begin
            Ascending(DocType = InvtDocumentHeader."Document Type"::Shipment);
            SetRange("Entry No.", GLRegister."From Entry No.", GLRegister."To Entry No.");
            FindSet();
            Assert.AreEqual(
              "Credit Amount", ExpectedAmount, StrSubstNo(WrongValueErr, FieldCaption("Credit Amount"), TableCaption));
            Next();
            Assert.AreEqual(
              "Debit Amount", ExpectedAmount, StrSubstNo(WrongValueErr, FieldCaption("Debit Amount"), TableCaption));
        end;
    end;

    local procedure CreateDocRunAdjustCostEntries(DocType: Enum "Invt. Doc. Document Type"; Amount: Decimal)
    var
        ItemCode: Code[20];
        LocationCode: Code[10];
        ItemQty: Integer;
        i: Integer;
    begin
        ItemCode := LibraryInventory.CreateItemNo();
        ItemQty := LibraryRandom.RandInt(3);
        LocationCode := CreateLocation();
        CreateInventoryPostingSetup(LocationCode, GetItemGroupCode(ItemCode));

        CreatePostItemJnlLine(ItemCode, LocationCode, ItemQty, Amount);
        CreatePostInvtDocument(DocType, LocationCode, ItemCode, ItemQty, Amount);
        CreatePostCorrInvtDocument(DocType, LocationCode, ItemCode, ItemQty, Amount, GetItemLedgEntryNo(ItemCode, LocationCode));
        for i := 1 to ItemQty do
            CreatePostInvtDocument(DocType, LocationCode, ItemCode, 1, Amount);
        LibraryCosting.AdjustCostItemEntries(ItemCode, '');
    end;
}

