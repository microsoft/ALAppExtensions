codeunit 147104 "CD Fixed Assets"
{
    // Fixed Assets PO - Full Cycle
    // 1. Test case to check CD mixed PO (FA + Item)
    //   a. Create a new foreign vendor
    //   b. Create a new FA
    //   c. Create a new item
    //   d. Create a new CD
    //   e. Purchase new item and FA
    //   f. Check Item Ledger Entry
    //   g. Release FA
    //   h. Create a new VAT Purchase Ledger
    //   i. Check VAT Purchase Ledger Lines
    // 2. Test case to check CD for Sale and Return FA
    //   a. Create a new foreign vendor
    //   b. Create a new customer
    //   c. Create a new FA
    //   d. Create a new CD
    //   e. Purchase the FA
    //   f. Release FA
    //   h. Create a new VAT Purchase Ledger
    //   i. Writeoff FA
    //   j. Create a new sale order for FA
    //   k. Create sales return order
    //   l. Check VAT Purchase Ledger Lines
    TestPermissions = NonRestrictive;
    Subtype = Test;

    var
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryCDTracking: Codeunit "Library - CD Tracking";
        LibraryItemTracking: Codeunit "Library - Item Tracking";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        Assert: Codeunit Assert;
        VATLedgerErr: Label 'Couldn''t find Purchase VAT Ledger Line with CDNo';
        isInitialized: Boolean;

    [Normal]
    local procedure Initialize()
    begin
        if isInitialized then
            exit;

        LibraryCDTracking.UpdateERMCountryData();

        isInitialized := true;
        Commit();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PurchOrderWithFAAndItem()
    var
        Item: Record Item;
        Vendor: Record Vendor;
        Location: Record Location;
        Customer: Record Customer;
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemTrackingCode: Record "Item Tracking Code";
        CDLocationSetup: Record "CD Location Setup";
        CDNumberHeader: Record "CD Number Header";
        PackageNoInformation: Record "Package No. Information";
        PurchaseHeader: Record "Purchase Header";
        FixedAsset: Record "Fixed Asset";
        PurchaseLine: Record "Purchase Line";
        ReservationEntry: Record "Reservation Entry";
        FADocumentHeader: Record "FA Document Header";
        CDFAInformation: Record "CD FA Information";
        VATLedgerCode: Code[20];
        CDNo: array[2] of Code[30];
        ReleaseDate: Date;
        StartDate: Date;
        EndDate: Date;
        Qty: Integer;
        i: Integer;
    begin
        Initialize();
        StartDate := WorkDate();
        EndDate := CalcDate('<CM>', StartDate);

        LibraryCDTracking.CreateForeignVendor(Vendor);
        LibrarySales.CreateCustomer(Customer);
        LibraryCDTracking.CreateFixedAsset(FixedAsset);
        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(Location);
        LibraryItemTracking.CreateItemTrackingCode(ItemTrackingCode, false, false, true);
        LibraryCDTracking.CreateCDTracking(CDLocationSetup, ItemTrackingCode.Code, Location.Code);
        LibraryItemTracking.CreateItemTrackingCode(ItemTrackingCode, false, false, true);
        LibraryItemTracking.CreateItemWithItemTrackingCode(Item, ItemTrackingCode);

        LibraryCDTracking.CreateCDNumberHeaderWithCountryRegion(CDNumberHeader);
        for i := 1 to ArrayLen(CDNo) do
            CDNo[i] := LibraryUtility.GenerateGUID();
        LibraryCDTracking.CreateCDFAInformation(CDNumberHeader, CDFAInformation, FixedAsset."No.", CDNo[1]);
        FixedAsset.Validate("CD Number", CDNo[1]);
        FixedAsset.Modify();
        LibraryCDTracking.UpdatePackageInfo(CDNumberHeader, PackageNoInformation, Item."No.", CDNo[2]);

        LibraryPurchase.CreatePurchaseOrderWithLocation(PurchaseHeader, Vendor."No.", Location.Code);
        Qty := 5;
        LibraryCDTracking.CreatePurchLineFA(PurchaseLine, PurchaseHeader, FixedAsset."No.", 10000, Qty);
        LibraryPurchase.CreatePurchaseLineWithUnitCost(PurchaseLine, PurchaseHeader, Item."No.", 100, Qty);
        DisableUnrealizedVATPostingSetup(PurchaseLine);
        LibraryItemTracking.CreatePurchOrderItemTracking(ReservationEntry, PurchaseLine, '', '', CDNo[2], Qty);
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        LibraryItemTracking.CheckLastItemLedgerEntry(ItemLedgerEntry, Item."No.", Location.Code, '', '', CDNo[2], 5);

        ReleaseDate := CalcDate('<+1D>', WorkDate());
        LibraryCDTracking.CreateFAReleaseAct(FADocumentHeader, FixedAsset."No.", ReleaseDate);
        LibraryCDTracking.PostFAReleaseAct(FADocumentHeader);

        VATLedgerCode := LibraryCDTracking.CreateVATPurchaseLedger(StartDate, EndDate, '');
        CheckPurchaseLedger(VATLedgerCode);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SalesOrderWithFA()
    var
        Vendor: Record Vendor;
        Location: Record Location;
        Customer: Record Customer;
        CDNumberHeader: Record "CD Number Header";
        PurchaseHeader: Record "Purchase Header";
        FixedAsset: Record "Fixed Asset";
        CDFAInformation: Record "CD FA Information";
        PurchaseLine: Record "Purchase Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        FADocumentHeader: Record "FA Document Header";
        CopySalesDocument: Report "Copy Sales Document";
        VATLedgerCode: Code[20];
        CDNo: Code[50];
        WriteoffDate: Date;
        ReleaseDate: Date;
        Qty: Integer;
        StartDate: Date;
        EndDate: Date;
    begin
        Initialize();
        StartDate := WorkDate();
        EndDate := CalcDate('<CM>', StartDate);

        LibraryCDTracking.CreateForeignVendor(Vendor);
        LibrarySales.CreateCustomer(Customer);
        LibraryCDTracking.CreateFixedAsset(FixedAsset);

        LibraryCDTracking.CreateCDNumberHeaderWithCountryRegion(CDNumberHeader);
        CDNo := LibraryUtility.GenerateGUID();
        LibraryCDTracking.CreateCDFAInformation(CDNumberHeader, CDFAInformation, FixedAsset."No.", CDNo);
        FixedAsset.Validate("CD Number", CDNo);
        FixedAsset.Modify();

        LibraryPurchase.CreatePurchaseOrderWithLocation(PurchaseHeader, Vendor."No.", '');

        Qty := 1;
        LibraryCDTracking.CreatePurchLineFA(PurchaseLine, PurchaseHeader, FixedAsset."No.", 10000, Qty);
        DisableUnrealizedVATPostingSetup(PurchaseLine);
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        ReleaseDate := CalcDate('<+1D>', WorkDate());
        LibraryCDTracking.CreateFAReleaseAct(FADocumentHeader, FixedAsset."No.", ReleaseDate);
        LibraryCDTracking.PostFAReleaseAct(FADocumentHeader);

        VATLedgerCode := LibraryCDTracking.CreateVATPurchaseLedger(StartDate, EndDate, '');

        WriteoffDate := CalcDate('<+1D>', ReleaseDate);
        LibraryCDTracking.CreateFAWriteOffAct(FADocumentHeader, FixedAsset."No.", WriteoffDate);
        LibraryCDTracking.PostFAWriteOffAct(FADocumentHeader);

        WorkDate := CalcDate('<+1D>', WriteoffDate);
        LibrarySales.CreateSalesOrderWithLocation(SalesHeader, Customer."No.", '');
        LibraryCDTracking.CreateSalesLineFA(SalesLine, SalesHeader, FixedAsset."No.", 10000, 1);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        WorkDate := CalcDate('<+1D>', WorkDate());
        SalesInvoiceHeader.SetCurrentKey("Sell-to Customer No.");
        SalesInvoiceHeader.SetRange("Sell-to Customer No.", Customer."No.");
        SalesInvoiceHeader.FindLast();

        LibrarySales.CreateSalesReturnOrderWithLocation(SalesHeader, Customer."No.", Location.Code);
        CopySalesDocument.SetSalesHeader(SalesHeader);
        CopySalesDocument.SetParameters("Sales Document Type From"::"Posted Invoice", SalesInvoiceHeader."No.", true, true);
        CopySalesDocument.UseRequestPage(false);
        CopySalesDocument.Run();

        SalesHeader."Include In Purch. VAT Ledger" := true;
        SalesHeader.Modify();

        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        CheckPurchaseLedger(VATLedgerCode);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure "1FAWriteOffLot_2ItemsIR"()
    var
        CDLocationSetup: Record "CD Location Setup";
        Vendor: Record Vendor;
        Location: Record Location;
        Customer: Record Customer;
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemTrackingCode: Record "Item Tracking Code";
        CDNumberHeader: Record "CD Number Header";
        PurchaseHeader: Record "Purchase Header";
        FixedAsset: Record "Fixed Asset";
        PurchaseLine: Record "Purchase Line";
        ReservationEntry: Record "Reservation Entry";
        Item: array[2] of Record Item;
        InvtDocumentHeader: Record "Invt. Document Header";
        InvtDocumentLine: array[2] of Record "Invt. Document Line";
        FADocumentHeader: Record "FA Document Header";
        FADocumentLine: Record "FA Document Line";
        CDFAInformation: Record "CD FA Information";
        CDNo: array[2] of Code[50];
        QtyFA: Integer;
        ItemReceiptNo: Code[20];
        LotNo: Code[50];
        i: Integer;
    begin
        Initialize();
        LibraryCDTracking.CreateForeignVendor(Vendor);
        LotNo := LibraryUtility.GenerateGUID();
        LibrarySales.CreateCustomer(Customer);
        LibraryCDTracking.CreateFixedAsset(FixedAsset);
        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(Location);
        LibraryItemTracking.CreateItemTrackingCode(ItemTrackingCode, false, true, false);
        LibraryCDTracking.CreateCDTracking(CDLocationSetup, ItemTrackingCode.Code, Location.Code);
        for i := 1 to 2 do
            LibraryItemTracking.CreateItemWithItemTrackingCode(Item[i], ItemTrackingCode);

        LibraryCDTracking.CreateCDNumberHeaderWithCountryRegion(CDNumberHeader);
        CDNo[1] := LibraryUtility.GenerateGUID();
        LibraryCDTracking.CreateCDFAInformation(CDNumberHeader, CDFAInformation, FixedAsset."No.", CDNo[1]);
        FixedAsset.Validate("CD Number", CDNo[1]);
        FixedAsset.Modify();

        LibraryPurchase.CreatePurchaseOrderWithLocation(PurchaseHeader, Vendor."No.", Location.Code);
        QtyFA := 1;
        LibraryCDTracking.CreatePurchLineFA(
          PurchaseLine, PurchaseHeader, FixedAsset."No.", LibraryRandom.RandDec(100, 2), QtyFA);
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        LibraryCDTracking.CreateFAReleaseAct(FADocumentHeader, FixedAsset."No.", CalcDate('<+1D>', WorkDate()));
        LibraryCDTracking.PostFAReleaseAct(FADocumentHeader);

        LibraryInventory.CreateInvtDocument(InvtDocumentHeader, InvtDocumentHeader."Document Type"::Receipt, Location.Code);
        LibraryInventory.CreateInvtDocumentLine(InvtDocumentHeader, InvtDocumentLine[1], Item[1]."No.", 20, 1);
        LibraryInventory.CreateInvtDocumentLine(InvtDocumentHeader, InvtDocumentLine[2], Item[2]."No.", 30, 1);
        LibraryItemTracking.CreateItemReceiptItemTracking(ReservationEntry, InvtDocumentLine[1], '', LotNo, '', 1);
        LibraryItemTracking.CreateItemReceiptItemTracking(ReservationEntry, InvtDocumentLine[2], '', LotNo, '', 1);
        ItemReceiptNo := InvtDocumentHeader."No.";

        LibraryCDTracking.CreateFAWriteOffAct(FADocumentHeader, FixedAsset."No.", CalcDate('<+2D>', WorkDate()));
        FADocumentLine.SetRange("Document No.", FADocumentHeader."No.");
        FADocumentLine.SetRange("Document Type", FADocumentHeader."Document Type");
        FADocumentLine.FindFirst();
        FADocumentLine.Validate("Item Receipt No.", ItemReceiptNo);
        LibraryCDTracking.PostFAWriteOffAct(FADocumentHeader);

        LibraryInventory.PostInvtDocument(InvtDocumentHeader);

        CheckILEs(ItemLedgerEntry, ItemLedgerEntry."Entry Type"::"Positive Adjmt.", Item[1]."No.", Location.Code, LotNo, '', 1);
        CheckILEs(ItemLedgerEntry, ItemLedgerEntry."Entry Type"::"Positive Adjmt.", Item[2]."No.", Location.Code, LotNo, '', 1);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure "1FAWriteOffCD_2ItemsIR"()
    var
        CDLocationSetup: Record "CD Location Setup";
        Vendor: Record Vendor;
        Location: Record Location;
        Customer: Record Customer;
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemTrackingCode: Record "Item Tracking Code";
        CDNumberHeader: Record "CD Number Header";
        PackageNoInformation: Record "Package No. Information";
        PurchaseHeader: Record "Purchase Header";
        FixedAsset: Record "Fixed Asset";
        CDFAInformation: Record "CD FA Information";
        PurchaseLine: Record "Purchase Line";
        ReservationEntry: Record "Reservation Entry";
        Item: array[2] of Record Item;
        InvtDocumentHeader: Record "Invt. Document Header";
        InvtDocumentLine: array[2] of Record "Invt. Document Line";
        FADocumentHeader: Record "FA Document Header";
        FADocumentLine: Record "FA Document Line";
        CDNo: array[2] of Code[50];
        QtyFA: Integer;
        ItemReceiptNo: Code[20];
        i: Integer;
    begin
        Initialize();
        LibraryCDTracking.CreateForeignVendor(Vendor);
        LibrarySales.CreateCustomer(Customer);
        LibraryCDTracking.CreateFixedAsset(FixedAsset);
        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(Location);
        LibraryItemTracking.CreateItemTrackingCode(ItemTrackingCode, false, false, true);
        LibraryCDTracking.CreateCDTracking(CDLocationSetup, ItemTrackingCode.Code, Location.Code);
        for i := 1 to ArrayLen(Item) do
            LibraryItemTracking.CreateItemWithItemTrackingCode(Item[i], ItemTrackingCode);

        LibraryCDTracking.CreateCDNumberHeaderWithCountryRegion(CDNumberHeader);
        CDNo[1] := LibraryUtility.GenerateGUID();
        LibraryCDTracking.CreateCDFAInformation(CDNumberHeader, CDFAInformation, FixedAsset."No.", CDNo[1]);
        FixedAsset.Validate("CD Number", CDNo[1]);
        FixedAsset.Modify();
        for i := 1 to ArrayLen(Item) do
            LibraryItemTracking.CreatePackageNoInformation(PackageNoInformation, Item[i]."No.", CDNo[1]);

        LibraryPurchase.CreatePurchaseOrderWithLocation(PurchaseHeader, Vendor."No.", Location.Code);
        QtyFA := 1;
        LibraryCDTracking.CreatePurchLineFA(
          PurchaseLine, PurchaseHeader, FixedAsset."No.", LibraryRandom.RandDec(100, 2), QtyFA);
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        LibraryCDTracking.CreateFAReleaseAct(FADocumentHeader, FixedAsset."No.", CalcDate('<+1D>', WorkDate()));
        LibraryCDTracking.PostFAReleaseAct(FADocumentHeader);

        LibraryInventory.CreateInvtDocument(InvtDocumentHeader, InvtDocumentHeader."Document Type"::Receipt, Location.Code);
        LibraryInventory.CreateInvtDocumentLine(InvtDocumentHeader, InvtDocumentLine[1], Item[1]."No.", 20, 1);
        LibraryInventory.CreateInvtDocumentLine(InvtDocumentHeader, InvtDocumentLine[2], Item[2]."No.", 30, 1);
        LibraryItemTracking.CreateItemReceiptItemTracking(ReservationEntry, InvtDocumentLine[1], '', '', CDNo[1], 1);
        LibraryItemTracking.CreateItemReceiptItemTracking(ReservationEntry, InvtDocumentLine[2], '', '', CDNo[1], 1);
        ItemReceiptNo := InvtDocumentHeader."No.";

        LibraryCDTracking.CreateFAWriteOffAct(FADocumentHeader, FixedAsset."No.", CalcDate('<+2D>', WorkDate()));
        FADocumentLine.SetRange("Document No.", FADocumentHeader."No.");
        FADocumentLine.SetRange("Document Type", FADocumentHeader."Document Type");
        FADocumentLine.FindFirst();
        FADocumentLine.Validate("Item Receipt No.", ItemReceiptNo);
        LibraryCDTracking.PostFAWriteOffAct(FADocumentHeader);
        LibraryInventory.PostInvtDocument(InvtDocumentHeader);

        for i := 1 to ArrayLen(Item) do
            CheckILEs(
              ItemLedgerEntry, ItemLedgerEntry."Entry Type"::"Positive Adjmt.", Item[i]."No.", Location.Code, '', CDNo[1], 1);
    end;

    local procedure CheckILEs(var ItemLedgerEntry: Record "Item Ledger Entry"; EntryType: Enum "Item Ledger Entry Type"; ItemNo: Code[20]; LocationCode: Code[10]; LotNo: Code[50]; CDNo: Code[50]; Qty: Decimal)
    begin
        ItemLedgerEntry.SetRange("Entry Type", EntryType);
        LibraryItemTracking.CheckLastItemLedgerEntry(ItemLedgerEntry, ItemNo, LocationCode, '', LotNo, CDNo, Qty);
    end;

    local procedure CheckPurchaseLedger(DocNo: Code[50])
    var
        VATLedgerLine: Record "VAT Ledger Line";
    begin
        VATLedgerLine.Reset();
        VATLedgerLine.SetCurrentKey(Type, Code, "Line No.");
        VATLedgerLine.SetRange(Code, DocNo);
        Assert.IsFalse(VATLedgerLine.IsEmpty(), VATLedgerErr);
    end;

    local procedure DisableUnrealizedVATPostingSetup(PurchaseLine: Record "Purchase Line")
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        VATPostingSetup.Get(PurchaseLine."VAT Bus. Posting Group", PurchaseLine."VAT Prod. Posting Group");
        VATPostingSetup.Validate("Unrealized VAT Type", 0);
        VATPostingSetup.Modify(true);
    end;
}

