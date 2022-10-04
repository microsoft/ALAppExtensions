codeunit 139550 "Intrastat Report Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Intrastat]
        IsInitialized := false;
    end;

    var
        Assert: Codeunit Assert;
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryIntrastat: Codeunit "Library - Intrastat";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryFixedAsset: Codeunit "Library - Fixed Asset";
        LibraryERM: Codeunit "Library - ERM";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySales: Codeunit "Library - Sales";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryRandom: Codeunit "Library - Random";
        LibraryMarketing: Codeunit "Library - Marketing";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        IsInitialized: Boolean;
        ValidationErr: Label '%1 must be %2 in %3.', Comment = '%1 = FieldCaption(Quantity),%2 = SalesLine.Quantity,%3 = TableCaption(SalesShipmentLine).';
        LineNotExistErr: Label 'Intrastat Report Lines incorrectly created.';
        LineCountErr: Label 'The number of %1 entries is incorrect.', Comment = '%1 = Intrastat Report Line table';
        InternetURLTxt: Label 'www.microsoft.com';
        InvalidURLTxt: Label 'URL must be prefix with http.';
        PackageTrackingNoErr: Label 'Package Tracking No does not exist.';
        HttpTxt: Label 'http://';
        OnDelIntrastatContactErr: Label 'You cannot delete contact number %1 because it is set up as an Intrastat contact in the Intrastat Setup window.', Comment = '%1 - Contact No';
        OnDelVendorIntrastatContactErr: Label 'You cannot delete vendor number %1 because it is set up as an Intrastat contact in the Intrastat Setup window.', Comment = '%1 - Vendor No';
        StatPeriodFormatErr: Label '%1 must be 4 characters, for example, 9410 for October, 1994.', Comment = '%1 - field caption';
        StatPeriodMonthErr: Label 'Please check the month number.';

    [Test]
    [Scope('OnPrem')]
    procedure ItemLedgerEntryForPurchase()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO] Check Item Ledger Entry after posting Purchase Order.

        // [GIVEN] Posted Purchase Order
        Initialize();
        DocumentNo := CreateAndPostPurchaseOrder(PurchaseLine, WorkDate());

        // [THEN] Verify Item Ledger Entry
        VerifyItemLedgerEntry(ItemLedgerEntry."Document Type"::"Purchase Receipt", DocumentNo, GetCountryRegionCode(), PurchaseLine.Quantity);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    procedure IntrastatReportLineForPurchase()
    var
        PurchaseLine: Record "Purchase Line";
        IntrastatReportLine: Record "Intrastat Report Line";
        DocumentNo: Code[20];
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO] Check Intrastat Report Line for posted Purchase Order.

        // [GIVEN] Posted Purchase Order
        Initialize();
        DocumentNo := CreateAndPostPurchaseOrder(PurchaseLine, WorkDate());

        // [WHEN] Get Intrastat Report Line for Purchase Order
        // [THEN] Verify Intrastat Report Line
        CreateAndVerifyIntrastatLine(DocumentNo, PurchaseLine."No.", PurchaseLine.Quantity, IntrastatReportLine.Type::Receipt);
    end;

    [Test]
    [HandlerFunctions('UndoDocumentConfirmHandler,IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure IntrastatLineAfterUndoPurchase()
    var
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO] Check that no Intrastat Report Line exist for the Item for which Undo Purchase Receipt has done.

        // [GIVEN] Create and Post Purchase Order
        Initialize();
        DocumentNo := CreateAndPostPurchaseOrder(PurchaseLine, WorkDate());

        // [WHEN] Undo Purchase Receipt Line
        UndoPurchaseReceiptLine(DocumentNo, PurchaseLine."No.");

        // [WHEN] Create Intrastat Report and Get Entries for Intrastat Report Line
        // [THEN] Verify no entry exists for posted Item.
        GetEntriesAndVerifyNoItemLine(DocumentNo);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ItemLedgerEntryForSales()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [FEATURE] [Sales] 
        // [SCENARIO] Check Item Ledger Entry after posting Sales Order.

        // [GIVEN] Create and Post Sales Order
        Initialize();
        DocumentNo := CreateAndPostSalesOrder(SalesLine, WorkDate());

        // [THEN] Verify Item Ledger Entry
        VerifyItemLedgerEntry(ItemLedgerEntry."Document Type"::"Sales Shipment", DocumentNo, GetCountryRegionCode(), -SalesLine.Quantity);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    procedure IntrastatLineForSales()
    var
        SalesLine: Record "Sales Line";
        IntrastatReportLine: Record "Intrastat Report Line";
        DocumentNo: Code[20];
    begin
        // [FEATURE] [Sales]
        // [SCENARIO] Check Intrastat Report Line for posted Sales Order.

        // [GIVEN] Create and Post Sales Order
        Initialize();
        DocumentNo := CreateAndPostSalesOrder(SalesLine, WorkDate());

        // [WHEN] Get Intrastat Report Lines for Sales Order
        // [THEN] Verify Intrastat Report Line
        CreateAndVerifyIntrastatLine(DocumentNo, SalesLine."No.", SalesLine.Quantity, IntrastatReportLine.Type::Shipment);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    procedure NoIntrastatLineForSales()
    var
        SalesLine: Record "Sales Line";
    begin
        // [FEATURE] [Sales]
        // [SCENARIO] Check no Intrastat Report Line exist after Deleting them for Sales Shipment.

        // [GIVEN] Take Starting Date as WORKDATE.
        Initialize();
        CreateAndPostSalesOrder(SalesLine, WorkDate());

        // [WHEN] Intrastat Report Lines, Delete them
        // [THEN] Verify that no lines exist for Posted Sales Order.
        DeleteAndVerifyNoIntrastatLine(SalesLine."Document No.");
    end;

    [Test]
    [HandlerFunctions('UndoDocumentConfirmHandler')]
    [Scope('OnPrem')]
    procedure UndoSalesShipment()
    var
        SalesLine: Record "Sales Line";
        SalesShipmentLine: Record "Sales Shipment Line";
        DocumentNo: Code[20];
    begin
        // [FEATURE] [Sales]
        // [SCENARIO] Check Quantity on Sales Shipment Line after doing Undo Sales Shipment.

        // [GIVEN] Posted Sales Order
        Initialize();
        DocumentNo := CreateAndPostSalesOrder(SalesLine, WorkDate());

        // [WHEN] Undo Sales Shipment Line
        UndoSalesShipmentLine(DocumentNo, SalesLine."No.");

        // [THEN] Verify Undone Quantity on Sales Shipment Line.
        SalesShipmentLine.SetRange("Document No.", DocumentNo);
        SalesShipmentLine.SetFilter("Appl.-from Item Entry", '<>0');
        SalesShipmentLine.FindFirst();
        Assert.AreEqual(
          -SalesLine.Quantity, SalesShipmentLine.Quantity,
          StrSubstNo(ValidationErr, SalesShipmentLine.FieldCaption(Quantity), -SalesLine.Quantity, SalesShipmentLine.TableCaption()));
    end;

    [Test]
    [HandlerFunctions('UndoDocumentConfirmHandler,IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure IntrastatLineAfterUndoSales()
    var
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // [FEATURE] [Sales]
        // [SCENARIO] Check that no Intrastat Line exist for the Item for which Undo Sales Shipment has done.

        // [GIVEN] Create and Post Sales Order and undo Sales Shipment Line.
        Initialize();
        DocumentNo := CreateAndPostSalesOrder(SalesLine, WorkDate());
        UndoSalesShipmentLine(DocumentNo, SalesLine."No.");

        // [WHEN] Create Intrastat Journal Template, Batch and Get Entries for Intrastat Report Line
        // [THEN] Verify no entry exists for posted Item.
        GetEntriesAndVerifyNoItemLine(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesShowingItemChargesPageHandler')]
    [Scope('OnPrem')]
    procedure IntrastatReportWithPurchaseOrder()
    var
        PurchaseLine: Record "Purchase Line";
        IntrastatReportLine: Record "Intrastat Report Line";
        NewPostingDate: Date;
        IntrastatReportNo1: Code[20];
        IntrastatReportNo2: Code[20];
        DocumentNo: Code[20];
    begin
        // [FEATURE] [Purchase] 
        // [SCENARIO] Check Intrastat Report Entries after Posting Purchase Order and Get Entries with New Posting Date.

        // [GIVEN] Create Purchase Order with New Posting Date and Create New Intratsat Report with difference with 1 Year.
        Initialize();
        NewPostingDate := CalcDate('<' + Format(LibraryRandom.RandInt(5)) + 'Y>', WorkDate());
        DocumentNo := CreateAndPostPurchaseOrder(PurchaseLine, NewPostingDate);

        // [GIVEN] Two Intrastat Reports for the same period
        Commit();  // Commit is required to commit the posted entries.
        LibraryVariableStorage.Enqueue(true); // Show Item Charge entries
        CreateIntrastatReportAndSuggestLines(NewPostingDate, IntrastatReportNo1);
        LibraryVariableStorage.Enqueue(true); // Show Item Charge entries
        CreateIntrastatReportAndSuggestLines(NewPostingDate, IntrastatReportNo2);

        Commit();
        // [WHEN] Get Entries from Intrastat Report pages for two Reports with the same period with "Show item charge entries" options set to TRUE
        // [THEN] Verify that Entry values on Intrastat Report Page match Purchase Line values
        VerifyIntrastatReportLine(DocumentNo, IntrastatReportNo1, IntrastatReportLine.Type::Receipt,
            GetCountryRegionCode(), PurchaseLine."No.", PurchaseLine.Quantity);

        // [THEN] No Entries suggested in a second Intrastat Journal
        VerifyIntrastatReportLineExist(IntrastatReportNo2, PurchaseLine."No.", false);

        LibraryIntrastat.DeleteIntrastatReport(IntrastatReportNo1);
        LibraryIntrastat.DeleteIntrastatReport(IntrastatReportNo2);
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesShowingItemChargesPageHandler')]
    [Scope('OnPrem')]
    procedure IntrastatReportWithItemChargeAssignmentAfterPurchaseCreditMemo()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ChargeIntrastatReportLine: Record "Intrastat Report Line";
        ChargePurchaseLine: Record "Purchase Line";
        NewPostingDate: Date;
        DocumentNo: Code[20];
        IntrastatReportNo1: Code[20];
        IntrastatReportNo2: Code[20];

    begin
        // [FEATURE] [Purchase]
        // [SCENARIO] Check Intrastat Report Entries after Posting Purchase Order, Purchase Credit Memo with Item Charge Assignment and Get Entries with New Posting Date.
        Initialize();

        // [GIVEN] Create and Post Purchase Order on January with Amount = "X" and location code "Y"
        NewPostingDate := CalcDate('<' + Format(LibraryRandom.RandInt(5)) + 'Y>', WorkDate());
        DocumentNo := CreateAndPostPurchaseOrder(PurchaseLine, NewPostingDate);

        // [GIVEN] Create and Post Purchase Credit Memo with Item Charge Assignment on February.
        CreatePurchaseHeader(
          PurchaseHeader, PurchaseHeader."Document Type"::"Credit Memo",
          CalcDate('<1M>', NewPostingDate), CreateVendor(GetCountryRegionCode()));
        PurchaseHeader.Validate("Vendor Cr. Memo No.", PurchaseHeader."No.");
        PurchaseHeader.Modify(true);
        CreatePurchaseLine(
          PurchaseHeader, ChargePurchaseLine, ChargePurchaseLine.Type::"Charge (Item)", LibraryInventory.CreateItemChargeNo());
        CreateItemChargeAssignmentForPurchaseCreditMemo(ChargePurchaseLine, DocumentNo);
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);

        // [GIVEN] Two Reports for January and February with "Show item charge entries" options set to TRUE
        // [WHEN] User runs Get Entries in Intrastat Report for January and February
        LibraryVariableStorage.Enqueue(true); // Show Item Charge entries
        CreateIntrastatReportAndSuggestLines(NewPostingDate, IntrastatReportNo1);
        LibraryVariableStorage.Enqueue(true); // Show Item Charge entries
        CreateIntrastatReportAndSuggestLines(PurchaseHeader."Posting Date", IntrastatReportNo2);

        Commit();

        // [THEN] Item Charge Entry suggested for February, "Intrastat Report Line" has Amount = "X" for January
        VerifyIntrastatReportLine(DocumentNo, IntrastatReportNo1, ChargeIntrastatReportLine.Type::Receipt,
           GetCountryRegionCode(), PurchaseLine."No.", PurchaseLine.Quantity);

        GetIntrastatReportLine(DocumentNo, IntrastatReportNo1, ChargeIntrastatReportLine);
        Assert.AreEqual(PurchaseLine.Amount, ChargeIntrastatReportLine.Amount, '');

        // [THEN] "Location Code" is "Y" in the Intrastat Report Line
        // BUG 384736: "Location Code" copies to the Intrastat Report Line from the source documents
        Assert.AreEqual(PurchaseLine."Location Code", ChargeIntrastatReportLine."Location Code", '');

        LibraryIntrastat.DeleteIntrastatReport(IntrastatReportNo1);
        LibraryIntrastat.DeleteIntrastatReport(IntrastatReportNo2);
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesShowingItemChargesPageHandler')]
    [Scope('OnPrem')]
    procedure IntrastatReportWithSalesOrder()
    var
        SalesLine: Record "Sales Line";
        IntrastatReportLine: Record "Intrastat Report Line";
        NewPostingDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Sales] 
        // [SCENARIO] Check Intrastat Report Lines after Posting Sales Order and Get Entries with New Posting Date.

        // [GIVEN] Create Sales Order with New Posting Date and Create Intrastat Report.
        Initialize();
        NewPostingDate := CalcDate('<' + Format(LibraryRandom.RandInt(5)) + 'Y>', WorkDate());
        CreateAndPostSalesOrder(SalesLine, NewPostingDate);

        Commit();  // Commit is required to commit the posted entries.

        // [WHEN] Get Entries from Intrastat Report page with "Show item charge entries" options set to TRUE.
        LibraryVariableStorage.Enqueue(true); // Show Item Charge entries
        CreateIntrastatReportAndSuggestLines(NewPostingDate, IntrastatReportNo);

        // [THEN] Verify Intrastat Report Lines.
        IntrastatReportLine.SetRange("Item No.", SalesLine."No.");
        IntrastatReportLine.SetRange(Type, IntrastatReportLine.Type::Shipment);
        IntrastatReportLine.SetRange(Quantity, SalesLine.Quantity);
        IntrastatReportLine.SetRange(Date, NewPostingDate);

        Assert.IsTrue(IntrastatReportLine.FindFirst(), '');

        IntrastatReportLine.Delete(true);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TotalWeightOnIntrastatReportLine()
    var
        IntrastatReportLine: Record "Intrastat Report Line";
        NetWeight: Decimal;
    begin
        // [SCENARIO] Check Intrastat Report Total Weight after entering Quantity on Intrastat Report Line.

        // [GIVEN] Intrastat Report Line 
        Initialize();
        LibraryIntrastat.CreateIntrastatReportLine(IntrastatReportLine);
        LibraryIntrastat.CreateIntrastatReportLine(IntrastatReportLine);

        // [WHEN] Create and Update Quantity on Intrastat Report Line.
        NetWeight := UseItemNonZeroNetWeight(IntrastatReportLine);

        // [THEN] Verify Total Weight correctly calculated on Intrastat Report Line.
        IntrastatReportLine.TestField("Total Weight", IntrastatReportLine.Quantity * NetWeight);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPackageNoIsIncludedInInternetAddressLink()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        ShippingAgent: Record "Shipping Agent";
    begin
        Initialize();
        CreateSalesShipmentHeader(SalesShipmentHeader, '%1');
        ShippingAgent.Get(SalesShipmentHeader."Shipping Agent Code");
        Assert.AreEqual(
          SalesShipmentHeader."Package Tracking No.",
          CopyStr(ShippingAgent.GetTrackingInternetAddr(SalesShipmentHeader."Package Tracking No."), StrLen(HttpTxt) + 1),
          PackageTrackingNoErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInternetAddressWithoutHttp()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        ShippingAgent: Record "Shipping Agent";
    begin
        Initialize();
        CreateSalesShipmentHeader(SalesShipmentHeader, InternetURLTxt);
        ShippingAgent.Get(SalesShipmentHeader."Shipping Agent Code");
        Assert.AreEqual(HttpTxt + InternetURLTxt, ShippingAgent.GetTrackingInternetAddr(SalesShipmentHeader."Package Tracking No."), InvalidURLTxt);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInternetAddressWithHttp()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        ShippingAgent: Record "Shipping Agent";
    begin
        Initialize();
        CreateSalesShipmentHeader(SalesShipmentHeader, HttpTxt + InternetURLTxt);
        ShippingAgent.Get(SalesShipmentHeader."Shipping Agent Code");
        Assert.AreEqual(HttpTxt + InternetURLTxt, ShippingAgent.GetTrackingInternetAddr(SalesShipmentHeader."Package Tracking No."), InvalidURLTxt);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestNoPackageNoExistIfNoPlaceHolderExistInURL()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        ShippingAgent: Record "Shipping Agent";
    begin
        Initialize();
        CreateSalesShipmentHeader(SalesShipmentHeader, InternetURLTxt);
        ShippingAgent.Get(SalesShipmentHeader."Shipping Agent Code");
        Assert.IsTrue(
          StrPos(ShippingAgent.GetTrackingInternetAddr(SalesShipmentHeader."Package Tracking No."), SalesShipmentHeader."Package Tracking No.") = 0, PackageTrackingNoErr);
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesShowingItemChargesPageHandler')]
    [Scope('OnPrem')]
    procedure VerifyIntrastatReportLineSuggestedForNonCrossedBoardItemChargeInNextPeriod()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ItemCharge: Record "Item Charge";
        CompanyInformation: Record "Company Information";
        DocumentNo1: Code[20];
        DocumentNo2: Code[20];
        InvoicePostingDate: Date;
        IntrastatNo1: Code[20];
        IntrastatNo2: Code[20];
    begin
        // [FEATURE] [Purchase] [Item Charge]
        // [SCENARIO 376161] Invoice and Item Charge not suggested for Intrastat Report in different Periods - Not Cross-Border
        Initialize();
        InvoicePostingDate := CalcDate('<' + Format(LibraryRandom.RandInt(5)) + 'Y>', WorkDate());

        // [GIVEN] Posted Purchase Invoice in "Y" period - Not Cross-border
        CompanyInformation.Get();
        CreatePurchaseHeader(
          PurchaseHeader, PurchaseHeader."Document Type"::Order, InvoicePostingDate,
          CreateVendor(CompanyInformation."Country/Region Code"));
        CreatePurchaseLine(PurchaseHeader, PurchaseLine, PurchaseLine.Type::Item, CreateItem());
        DocumentNo1 := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);

        // [GIVEN] Posted Item Charge in "F" period
        CreatePurchaseHeader(
          PurchaseHeader, PurchaseHeader."Document Type"::Invoice, CalcDate('<1M>', InvoicePostingDate),
          PurchaseHeader."Buy-from Vendor No.");
        LibraryInventory.CreateItemCharge(ItemCharge);
        CreatePurchaseLine(PurchaseHeader, PurchaseLine, PurchaseLine.Type::"Charge (Item)", ItemCharge."No.");
        CreateItemChargeAssignmentForPurchaseCreditMemo(PurchaseLine, DocumentNo1);
        DocumentNo2 := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);

        // [GIVEN] Intrastat Batches for "Y" and "F" period
        LibraryVariableStorage.Enqueue(true); // Show Item Charge entries
        CreateIntrastatReportAndSuggestLines(InvoicePostingDate, IntrastatNo1);

        LibraryVariableStorage.Enqueue(true); // Show Item Charge entries
        CreateIntrastatReportAndSuggestLines(PurchaseHeader."Posting Date", IntrastatNo2);

        // [WHEN] Entries suggested to Intrastat Report "J" and "F" with "Show item charge entries" options set to TRUE
        // [THEN] Intrastat Report "J" contains no lines
        // [THEN] Intrastat Report "F" contains no lines
        VerifyIntrastatReportLineExist(IntrastatNo1, DocumentNo1, false);
        VerifyIntrastatReportLineExist(IntrastatNo2, DocumentNo2, false);
    end;

    [Test]
    [HandlerFunctions('UndoDocumentConfirmHandler,IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure IntrastatGetEntriesUndoReceiptSameItem()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        NoOfPurchaseLines: Integer;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 121966] Get Entries for Intrastat doesn't suggest Purchase Receipt lines that were Corrected
        Initialize();

        // [GIVEN] Posted(Receipt) Purchase Order with lines for the same Item
        NoOfPurchaseLines := LibraryRandom.RandIntInRange(2, 10);
        DocumentNo :=
          CreateAndPostPurchaseDocumentMultiLine(
            PurchaseLine, PurchaseHeader."Document Type"::Order, WorkDate(), PurchaseLine.Type::Item, CreateItem(), NoOfPurchaseLines);

        // [GIVEN] Undo Receipt for one of the lines (random) and finally post Purchase Order
        UndoPurchaseReceiptLineByLineNo(DocumentNo, LibraryRandom.RandInt(NoOfPurchaseLines));
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, true);

        // [WHEN] User runs Get Entries for Intrastat Report
        CreateIntrastatReportAndSuggestLines(WorkDate(), IntrastatReportNo);

        // [THEN] Only lines for which Undo Receipt was not done are suggested
        VerifyNoOfIntrastatLinesForDocumentNo(IntrastatReportNo, DocumentNo, NoOfPurchaseLines - 1);
    end;

    [Test]
    [HandlerFunctions('UndoDocumentConfirmHandler,IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure IntrastatGetEntriesUndoShipmentSameItem()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
        NoOfSalesLines: Integer;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 121966] Get Entries for Intrastat doesn't suggest Sales Shipment lines that were Corrected
        Initialize();
        NoOfSalesLines := LibraryRandom.RandIntInRange(2, 10);

        // [GIVEN] Posted(Shipment) Sales Order with lines for the same Item
        DocumentNo :=
          CreateAndPostSalesDocumentMultiLine(
            SalesLine, SalesLine."Document Type"::Order, WorkDate(), SalesLine.Type::Item, CreateItem(), NoOfSalesLines);

        // [GIVEN] Undo Receipt for one of the lines (random) and finally post Sales Order
        UndoSalesShipmentLineByLineNo(DocumentNo, LibraryRandom.RandInt(NoOfSalesLines));
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        LibrarySales.PostSalesDocument(SalesHeader, false, true);

        // [WHEN] User runs Get Entries for Intrastat Report
        CreateIntrastatReportAndSuggestLines(WorkDate(), IntrastatReportNo);

        // [THEN] Only lines for which Undo Receipt was not done are suggested
        VerifyNoOfIntrastatLinesForDocumentNo(IntrastatReportNo, DocumentNo, NoOfSalesLines - 1);
    end;

    [Test]
    [HandlerFunctions('UndoDocumentConfirmHandler,IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure IntrastatGetEntriesUndoReturnShipmentSameItem()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo: Code[20];
        NoOfPurchaseLines: Integer;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 121966] Get Entries for Intrastat doesn't suggest Return Shipment lines that were Corrected
        Initialize();

        // [GIVEN] Posted(Shipment) Purchase Order with lines for the same Item
        NoOfPurchaseLines := LibraryRandom.RandIntInRange(2, 10);
        DocumentNo :=
          CreateAndPostPurchaseDocumentMultiLine(
            PurchaseLine, PurchaseHeader."Document Type"::"Return Order", WorkDate(), PurchaseLine.Type::Item, CreateItem(), NoOfPurchaseLines);

        // [GIVEN] Undo Receipt for one of the lines (random) and finally post Return Order
        UndoReturnShipmentLineByLineNo(DocumentNo, LibraryRandom.RandInt(NoOfPurchaseLines));
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        PurchaseHeader.Validate("Vendor Cr. Memo No.", PurchaseHeader."No.");
        PurchaseHeader.Modify(true);
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, true);

        // [WHEN] User runs Get Entries for Intrastat Report
        CreateIntrastatReportAndSuggestLines(WorkDate(), IntrastatReportNo);

        // [THEN] Only lines for which Undo Receipt was not done are suggested
        VerifyNoOfIntrastatLinesForDocumentNo(IntrastatReportNo, DocumentNo, NoOfPurchaseLines - 1);
    end;

    [Test]
    [HandlerFunctions('UndoDocumentConfirmHandler,IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure IntrastatGetEntriesUndoReturnReceiptSameItem()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
        NoOfSalesLines: Integer;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 121966] Get Entries for Intrastat doesn't suggest Return Receipt lines that were Corrected
        Initialize();
        // [GIVEN] Posted(Receipt) Sales Return Order with lines for the same Item
        NoOfSalesLines := LibraryRandom.RandIntInRange(2, 10);
        DocumentNo :=
          CreateAndPostSalesDocumentMultiLine(
            SalesLine, SalesLine."Document Type"::"Return Order", WorkDate(), SalesLine.Type::Item, CreateItem(), NoOfSalesLines);

        // [GIVEN] Undo Receipt for one of the lines (random) and finally post Return Order
        UndoReturnReceiptLineByLineNo(DocumentNo, LibraryRandom.RandInt(NoOfSalesLines));
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        LibrarySales.PostSalesDocument(SalesHeader, false, true);

        // [WHEN] User runs Get Entries for Intrastat Report
        CreateIntrastatReportAndSuggestLines(WorkDate(), IntrastatReportNo);

        // [THEN] Only lines for which Undo Receipt was not done are suggested
        VerifyNoOfIntrastatLinesForDocumentNo(IntrastatReportNo, DocumentNo, NoOfSalesLines - 1);
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure NotToShowItemCharges()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ItemCharge: Record "Item Charge";
        DocumentNo: Code[20];
        InvoicePostingDate: Date;
        IntrastatReportNo1: Code[20];
        IntrastatReportNo2: Code[20];
    begin
        // [FEATURE] [Purchase] [Item Charge]
        // [SCENARIO 377846] No Item Charge entries should be suggested to Intrastat Report if "Show item charge entries" option is set to FALSE

        Initialize();

        // [GIVEN] Posted Purchase Invoice in "Y" period
        InvoicePostingDate := CalcDate('<' + Format(LibraryRandom.RandInt(5)) + 'Y>', WorkDate());
        DocumentNo := CreateAndPostPurchaseOrder(PurchaseLine, InvoicePostingDate);

        // [GIVEN] Posted Item Charge in "F" period
        CreatePurchaseHeader(
          PurchaseHeader, PurchaseHeader."Document Type"::Invoice, CalcDate('<1M>', InvoicePostingDate),
          CreateVendor(GetCountryRegionCode()));
        LibraryInventory.CreateItemCharge(ItemCharge);
        CreatePurchaseLine(PurchaseHeader, PurchaseLine, PurchaseLine.Type::"Charge (Item)", ItemCharge."No.");
        CreateItemChargeAssignmentForPurchaseCreditMemo(PurchaseLine, DocumentNo);
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);

        // [GIVEN] Intrastat Reports for "Y" and "F" period

        // [WHEN] Suggest Entries to Intrastat Report "Y" and "F" with "Show item charge entries" options set to FALSE
        // [THEN] Intrastat Report "Y" contains 1 line for Posted Invoice
        // [THEN] Intrastat Report "F" does not contain lines for Posted Item Charge
        LibraryVariableStorage.Enqueue(false); // Show Item Charge entries
        CreateIntrastatReportAndSuggestLines(InvoicePostingDate, IntrastatReportNo1);
        LibraryVariableStorage.Enqueue(false); // Show Item Charge entries
        CreateIntrastatReportAndSuggestLines(PurchaseHeader."Posting Date", IntrastatReportNo2);

        VerifyIntrastatReportLineExist(IntrastatReportNo2, DocumentNo, false)
    end;

    [Test]
    [Scope('OnPrem')]
    procedure IntrastatReportHeader_GetStatisticsStartDate()
    var
        IntrastatReportHeader: Record "Intrastat Report Header";
    begin
        // [FEATURE] [UT]
        // [SCENARIO 255730] TAB 262 "Intrastat Report Header".GetStatisticsStartDate() returns statistics period ("YYMM") start date ("01MMYY")
        Initialize();

        // TESTFIELD("Statistics Period")
        IntrastatReportHeader.Init();
        asserterror IntrastatReportHeader.GetStatisticsStartDate();
        Assert.ExpectedErrorCode('TestField');
        Assert.ExpectedError(IntrastatReportHeader.FieldName("Statistics Period"));

        // 01-01-00
        IntrastatReportHeader."Statistics Period" := '0001';
        Assert.AreEqual(DMY2Date(1, 1, 2000), IntrastatReportHeader.GetStatisticsStartDate(), '');

        // 01-01-18
        IntrastatReportHeader."Statistics Period" := '1801';
        Assert.AreEqual(DMY2Date(1, 1, 2018), IntrastatReportHeader.GetStatisticsStartDate(), '');

        // 01-12-18
        IntrastatReportHeader."Statistics Period" := '1812';
        Assert.AreEqual(DMY2Date(1, 12, 2018), IntrastatReportHeader.GetStatisticsStartDate(), '');

        // 01-12-99
        IntrastatReportHeader."Statistics Period" := '9912';
        Assert.AreEqual(DMY2Date(1, 12, 2099), IntrastatReportHeader.GetStatisticsStartDate(), '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure IntrastatContact_ChangeType()
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
        Contact: Record Contact;
        Vendor: Record Vendor;
    begin
        // [FEATURE] [Intrastat Report Setup] [UT]
        // [SCENARIO 255730] "Intrastat Contact No." is blanked when change "Intrastat Contact Type" field value
        Initialize();

        LibraryMarketing.CreateCompanyContact(Contact);
        LibraryPurchase.CreateVendor(Vendor);
        with IntrastatReportSetup do begin
            Validate("Intrastat Contact Type", "Intrastat Contact Type"::Contact);
            Validate("Intrastat Contact No.", Contact."No.");
            Validate("Intrastat Contact Type", "Intrastat Contact Type"::Vendor);
            TestField("Intrastat Contact No.", '');
            Validate("Intrastat Contact No.", Vendor."No.");
            Validate("Intrastat Contact Type", "Intrastat Contact Type"::Contact);
            TestField("Intrastat Contact No.", '');
            Validate("Intrastat Contact No.", Contact."No.");
            Validate("Intrastat Contact Type", "Intrastat Contact Type"::" ");
            TestField("Intrastat Contact No.", '');
            Validate("Intrastat Contact Type", "Intrastat Contact Type"::Vendor);
            Validate("Intrastat Contact No.", Vendor."No.");
            Validate("Intrastat Contact Type", "Intrastat Contact Type"::" ");
            TestField("Intrastat Contact No.", '');
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure IntrastatContact_UI_Set()
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
        Contact: Record Contact;
        Vendor: Record Vendor;
        IntrastatContactNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report Setup] [UT] [UI]
        // [SCENARIO 255730] Set "Intrastat Contact Type" and "Intrastat Contact No." fields via "Intrastat Report Setup" page
        // TODO - Failing - The field Intrastat Contact No. of table Intrastat Report Setup contains a value (GL00000289) that cannot be found in the related table 
        Initialize();

        // Set "Intrastat Contact Type" = "Contact"
        IntrastatContactNo := LibraryIntrastat.CreateIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Contact);
        SetIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Contact, IntrastatContactNo);
        VerifyIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Contact, IntrastatContactNo);

        // Set "Intrastat Contact Type" = "Vendor"
        IntrastatContactNo := LibraryIntrastat.CreateIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Vendor);
        SetIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Vendor, IntrastatContactNo);
        VerifyIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Vendor, IntrastatContactNo);

        // Trying to set "Intrastat Contact Type" = "Contact" with vendor
        Vendor.Get(LibraryPurchase.CreateIntrastatContact(''));
        asserterror SetIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Contact, Vendor."No.");
        Assert.ExpectedErrorCode('DB:PrimRecordNotFound');
        Assert.ExpectedError(Contact.TableCaption());

        // Trying to set "Intrastat Contact Type" = "Vendor" with contact
        Contact.Get(LibraryMarketing.CreateIntrastatContact(''));
        asserterror SetIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Vendor, Contact."No.");
        Assert.ExpectedErrorCode('DB:PrimRecordNotFound');
        Assert.ExpectedError(Vendor.TableCaption());
    end;

    [Test]
    [HandlerFunctions('ContactList_MPH,VendorList_MPH')]
    [Scope('OnPrem')]
    procedure IntrastatContact_UI_Lookup()
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
        IntrastatContactNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report Setup] [UT] [UI]
        // [SCENARIO 255730] Lookup "Intrastat Contact No." via "Intrastat Report Setup" page
        Initialize();

        // Lookup "Intrastat Contact Type" = "" do nothing
        LookupIntrastatContactViaPage(IntrastatReportSetup."Intrastat Contact Type"::" ");

        // Lookup "Intrastat Contact Type" = "Contact" opens "Contact List" page
        IntrastatContactNo := LibraryIntrastat.CreateIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Contact);
        LibraryVariableStorage.Enqueue(IntrastatContactNo);
        LookupIntrastatContactViaPage(IntrastatReportSetup."Intrastat Contact Type"::Contact);
        VerifyIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Contact, IntrastatContactNo);

        // Lookup "Intrastat Contact Type" = "Vendor" opens "Vendor List" page
        IntrastatContactNo := LibraryIntrastat.CreateIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Vendor);
        LibraryVariableStorage.Enqueue(IntrastatContactNo);
        LookupIntrastatContactViaPage(IntrastatReportSetup."Intrastat Contact Type"::Vendor);
        VerifyIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Vendor, IntrastatContactNo);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure IntrastatContact_DeleteContact()
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
        Contact: array[2] of Record Contact;
    begin
        // [FEATURE] [Intrastat Report Setup] [UT]
        // [SCENARIO 255730] An error has been shown trying to delete contact specified in the Intrastat Report Setup as an intrastat contact
        // TO DO - Missing IntrastatSetup.CheckDeleteIntrastatContact(IntrastatSetup."Intrastat Contact Type"::Contact, "No.");
        Initialize();

        // Empty setup record
        IntrastatReportSetup.Delete();
        Assert.RecordIsEmpty(IntrastatReportSetup);
        LibraryMarketing.CreateCompanyContact(Contact[1]);
        Contact[1].Delete(true);

        // Existing setup with other contact
        IntrastatSetupEnableReportReceipts();
        LibraryMarketing.CreateCompanyContact(Contact[1]);
        LibraryMarketing.CreateCompanyContact(Contact[2]);
        ValidateIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Contact, Contact[1]."No.");
        Contact[2].Delete(true);

        // Existing setup with the same contact
        asserterror Contact[1].Delete(true);
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(StrSubstNo(OnDelIntrastatContactErr, Contact[1]."No."));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure IntrastatContact_DeleteVendor()
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
        Vendor: array[2] of Record Vendor;
    begin
        // [FEATURE] [Intrastat Report Setup] [UT]
        // [SCENARIO 255730] An error has been shown trying to delete vendor specified in the Intrastat Report Setup as an intrastat contact
        // TO DO - Missing IntrastatSetup.CheckDeleteIntrastatVendor(IntrastatSetup."Intrastat Contact Type"::Contact, "No.");
        Initialize();

        // Empty setup record
        IntrastatReportSetup.Delete();
        LibraryPurchase.CreateVendor(Vendor[1]);
        Vendor[1].Delete(true);

        // Existing setup with other contact
        IntrastatSetupEnableReportReceipts();
        LibraryPurchase.CreateVendor(Vendor[1]);
        LibraryPurchase.CreateVendor(Vendor[2]);
        IntrastatReportSetup.Get();
        ValidateIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Vendor, Vendor[1]."No.");
        Vendor[2].Delete(true);

        // Existing setup with the same contact
        asserterror Vendor[1].Delete(true);
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(StrSubstNo(OnDelVendorIntrastatContactErr, Vendor[1]."No."));
    end;

    [MessageHandler]
    [Scope('OnPrem')]
    procedure CreateFileMessageHandler(Message: Text)
    begin
        Assert.AreEqual('One or more errors were found. You must resolve all the errors before you can proceed.', Message, '');
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesShowingItemChargesPageHandler')]
    [Scope('OnPrem')]
    procedure IntrastatReportWithItemChargeInvoiced()
    var
        IntrastatReportLine: Record "Intrastat Report Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        PostingDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [SCENARIO 286107] Item Charge entry posted by Sales Invoice must be reported as Shipment in Intrastat Report
        Initialize();

        // [GIVEN] Item Ledger Entry with Quantity < 0
        PostingDate := CalcDate('<' + Format(LibraryRandom.RandInt(5)) + 'Y>', WorkDate());
        CreateItemLedgerEntry(
          ItemLedgerEntry,
          PostingDate,
          LibraryInventory.CreateItemNo(),
          -LibraryRandom.RandInt(100),
          ItemLedgerEntry."Entry Type"::Sale);
        // [GIVEN] Value Entry with "Document Type" != "Sales Credit Memo" and "Item Charge No" posted in <1M>
        PostingDate := CalcDate('<1M>', PostingDate);

        CreateValueEntry(ValueEntry, ItemLedgerEntry, ValueEntry."Document Type"::"Sales Invoice", PostingDate);

        // [WHEN] Get Intrastat Entries on second posting date
        LibraryVariableStorage.Enqueue(true); // Show Item Charge entries
        CreateIntrastatReportAndSuggestLines(PostingDate, IntrastatReportNo);

        // [THEN] Intrastat line for Item Charge from Value Entry has type Shipment
        IntrastatReportLine.SetRange("Item No.", ItemLedgerEntry."Item No.");
        IntrastatReportLine.FindFirst();
        IntrastatReportLine.TestField(Type, IntrastatReportLine.Type::Shipment);
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure IntrastatReportWithServiceItem()
    var
        IntrastatReportLine: Record "Intrastat Report Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        Item: Record Item;
        IntrastatReportNo: Code[20];
    begin
        // [SCENARIO 295736] Item Ledger Entry with Item Type = Service should not be suggested for Intrastat Report
        Initialize();

        // [GIVEN] Item Ledger Entry with Service Type Item
        LibraryInventory.CreateServiceTypeItem(Item);
        CreateItemLedgerEntry(
          ItemLedgerEntry,
          WorkDate(),
          Item."No.",
          LibraryRandom.RandInt(100),
          ItemLedgerEntry."Entry Type"::Sale);

        // [WHEN] Get Intrastat Entries
        CreateIntrastatReportAndSuggestLines(WorkDate(), IntrastatReportNo);

        // [THEN] There is no Intrastat Line with Item
        IntrastatReportLine.SetRange("Item No.", ItemLedgerEntry."Item No.");
        Assert.RecordIsEmpty(IntrastatReportLine);
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure IntrastatReportGetEntriesProcessesLinesWithoutLocation()
    var
        CountryRegion: Record "Country/Region";
        Location: Record Location;
        LocationEU: Record Location;
        TransferLine: Record "Transfer Line";
        IntrastatReportLine: Record "Intrastat Report Line";
        ItemNo: Code[20];
        IntrastatReportNo: Code[20];
    begin
        // [SCENARIO 315430] "Get Item Ledger Entries" report generates Intrastat Jnl. Lines when transit Item Ledger Entries have no Location.
        Initialize();

        // [GIVEN] Posted sales order with "Location Code" = "X"
        CreateCountryRegion(CountryRegion, true);
        ItemNo := CreateItem();
        CreateFromToLocations(Location, LocationEU, CountryRegion.Code);
        CreateAndPostPurchaseItemJournalLine(Location.Code, ItemNo);
        CreateAndPostSalesOrderWithCountryAndLocation(CountryRegion.Code, Location.Code, ItemNo);
        // [GIVEN] Posted transfer order with blank transit location.
        CreateAndPostTransferOrder(TransferLine, Location.Code, LocationEU.Code, ItemNo);

        // [WHEN] Open "Intrastat Report" page.
        CreateIntrastatReportAndSuggestLines(CalcDate('<CM>', WorkDate()), IntrastatReportNo);

        // [THEN] "Intrastat Jnl. Line" is created for posted sales order.
        IntrastatReportLine.Reset();
        IntrastatReportLine.SetRange("Item No.", ItemNo);
        Assert.IsTrue(IntrastatReportLine.FindFirst(), '');

        // [THEN] "Intrastat Jnl. Line" has "Location Code" = "X"
        // BUG 384736: "Location Code" copies to the Intrastat Report Line from the source documents
        IntrastatReportLine.TestField("Location Code", Location.Code);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetCountryOfOriginFromItem()
    var
        Item: Record Item;
        IntrastatReportLine: Record "Intrastat Report Line";
    begin
        // [FEATURE] [UT]
        // [SCENARIO 373278] GetCountryOfOriginCode takes value from Item when it is not blank
        Item."No." := LibraryUtility.GenerateGUID();
        Item."Country/Region of Origin Code" :=
          LibraryUtility.GenerateRandomCode(Item.FieldNo("Country/Region of Origin Code"), DATABASE::Item);
        Item.Insert();
        IntrastatReportLine.Init();
        IntrastatReportLine."Item No." := Item."No.";

        Assert.AreEqual(
          Item."Country/Region of Origin Code", IntrastatReportLine.GetCountryOfOriginCode(), '');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler,IntrastatReportGetLinesPageHandler')]
    procedure GetPartnerIDFromVATRegNoOfSalesInvoice()
    var
        SellToCustomer: Record Customer;
        BillToCustomer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        IntrastatReportHeader: Record "Intrastat Report Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        DocumentNo: Code[20];
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Sales] [Shipment]
        // [SCENARIO 422720] Partner VAT ID is taken as VAT Registration No from Sell-to Customer No. of Sales Invoice
        Initialize();

        // [GIVEN] G/L Setup "Bill-to/Sell-to VAT Calc." = "Bill-to/Pay-to No."
        // [GIVEN] Shipment on Sales Invoice = false
        UpdateShipmentOnInvoiceSalesSetup(false);

        // [GIVEN] Sell-to Customer with VAT Registration No = 'AT0123456'
        // [GIVEN] Bill-to Customer with VAT Registration No = 'DE1234567'
        // [GIVEN] Sales Invoice with different Sell-to and Bill-To customers
        SellToCustomer.Get(CreateCustomerWithVATRegNo(true));
        BillToCustomer.Get(CreateCustomerWithVATRegNo(true));
        CreateSalesDocument(
            SalesHeader, SalesLine, SellToCustomer."No.", WorkDate(), SalesLine."Document Type"::Invoice,
            SalesLine.Type::Item, CreateItem(), 1);
        SalesHeader.Validate("Bill-to Customer No.", BillToCustomer."No.");
        SalesHeader.Modify(true);

        // [GIVEN] Post the invoice
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [WHEN] Suggest Intrastat Report Lines
        CreateIntrastatReportAndSuggestLines(WorkDate(), IntrastatReportNo);
        IntrastatReportHeader.Get(IntrastatReportNo);

        // [THEN] Posted Sales Invoice has VAT Registration No. = 'DE1234567'
        // [THEN] Partner VAT ID  = 'AT0123456' in Intrastat Report Line
        SalesInvoiceHeader.Get(DocumentNo);
        SalesInvoiceHeader.TestField("VAT Registration No.", BillToCustomer."VAT Registration No.");
        VerifyPartnerID(IntrastatReportHeader, SalesLine."No.", SellToCustomer."VAT Registration No.");
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ConfirmHandler,IntrastatReportGetLinesPageHandler')]
    procedure GetPartnerIDFromVATRegNoOfSalesShipment()
    var
        SellToCustomer: Record Customer;
        BillToCustomer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        IntrastatReportHeader: Record "Intrastat Report Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Sales] [Shipment]
        // [SCENARIO 422720] Partner VAT ID is taken as VAT Registration No from Sell-to Customer No. of Sales Shipment
        Initialize();

        // [GIVEN] G/L Setup "Bill-to/Sell-to VAT Calc." = "Bill-to/Pay-to No."
        // [GIVEN] Shipment on Sales Invoice = true
        UpdateShipmentOnInvoiceSalesSetup(true);

        // [GIVEN] Sell-to Customer with VAT Registration No = 'AT0123456'
        // [GIVEN] Bill-to Customer with VAT Registration No = 'DE1234567'
        // [GIVEN] Sales Invoice with different Sell-to and Bill-To customers
        SellToCustomer.Get(CreateCustomerWithVATRegNo(true));
        BillToCustomer.Get(CreateCustomerWithVATRegNo(true));
        CreateSalesDocument(
             SalesHeader, SalesLine, SellToCustomer."No.", WorkDate(), SalesLine."Document Type"::Invoice,
             SalesLine.Type::Item, CreateItem(), 1);
        SalesHeader.Validate("Bill-to Customer No.", BillToCustomer."No.");
        SalesHeader.Modify(true);

        // [GIVEN] Post the invoice
        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [WHEN] Suggest Intrastat Report Lines
        CreateIntrastatReportAndSuggestLines(WorkDate(), IntrastatReportNo);
        IntrastatReportHeader.Get(IntrastatReportNo);

        // [THEN] Posted Sales Shipment has VAT Registration No. = 'DE1234567'
        // [THEN] Partner VAT ID  = 'AT0123456' in Intrastat Report Line
        SalesShipmentHeader.SetRange("Bill-to Customer No.", BillToCustomer."No.");
        SalesShipmentHeader.FindFirst();
        SalesShipmentHeader.TestField("VAT Registration No.", BillToCustomer."VAT Registration No.");
        VerifyPartnerID(IntrastatReportHeader, SalesLine."No.", SellToCustomer."VAT Registration No.");
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    procedure GetPartnerIDFromVATRegNoOfPurchaseCrMemo()
    var
        Vendor: Record Vendor;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        IntrastatReportHeader: Record "Intrastat Report Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Purchase] [Return Shipment]
        // [SCENARIO 373278] Partner VAT ID is taken as VAT Registration No from Pay-to Vendor No. of Purchase Credit Memo
        Initialize();

        // [GIVEN] Return Shipment on Credit Memo = false
        UpdateRetShpmtOnCrMemoPurchSetup(false);

        // [GIVEN] Pay-to Vendor with VAT Registration No = 'AT0123456'
        Vendor.Get(CreateVendorWithVATRegNo(true));
        CreatePurchaseHeader(PurchaseHeader, PurchaseHeader."Document Type"::"Credit Memo", WorkDate(), Vendor."No.");
        CreatePurchaseLine(PurchaseHeader, PurchaseLine, PurchaseLine.Type::Item, CreateItem());
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [WHEN] Intrastat Report Line is created
        CreateIntrastatReportAndSuggestLines(WorkDate(), IntrastatReportNo);
        IntrastatReportHeader.Get(IntrastatReportNo);

        // [THEN] Partner VAT ID  = 'AT0123456' in Intrastat Report Line
        PurchCrMemoHdr.SetRange("Pay-to Vendor No.", Vendor."No.");
        PurchCrMemoHdr.FindFirst();
        VerifyPartnerID(IntrastatReportHeader, PurchaseLine."No.", Vendor."VAT Registration No.");
        VerifyPartnerID(IntrastatReportHeader, PurchaseLine."No.", PurchCrMemoHdr."VAT Registration No.");
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    procedure GetPartnerIDFromVATRegNoOfPurchaseReturnOrder()
    var
        Vendor: Record Vendor;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        IntrastatReportHeader: Record "Intrastat Report Header";
        ReturnShipmentHeader: Record "Return Shipment Header";
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Purchase] [Return Shipment]
        // [SCENARIO 373278] Partner VAT ID is taken as VAT Registration No from Pay-to Vendor No. of Purchase Return Order
        Initialize();

        // [GIVEN] Return Shipment on Credit Memo = true
        UpdateRetShpmtOnCrMemoPurchSetup(true);

        // [GIVEN] Pay-to Vendor with VAT Registration No = 'AT0123456'
        Vendor.Get(CreateVendorWithVATRegNo(true));
        CreatePurchaseHeader(PurchaseHeader, PurchaseHeader."Document Type"::"Credit Memo", WorkDate(), Vendor."No.");
        CreatePurchaseLine(PurchaseHeader, PurchaseLine, PurchaseLine.Type::Item, CreateItem());
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [WHEN] Intrastat Report Line is created
        CreateIntrastatReportAndSuggestLines(WorkDate(), IntrastatReportNo);
        IntrastatReportHeader.Get(IntrastatReportNo);

        // [THEN] Partner VAT ID  = 'AT0123456' in Intrastat Report Line
        ReturnShipmentHeader.SetRange("Buy-from Vendor No.", Vendor."No.");
        ReturnShipmentHeader.FindFirst();
        VerifyPartnerID(IntrastatReportHeader, PurchaseLine."No.", Vendor."VAT Registration No.");
        VerifyPartnerID(IntrastatReportHeader, PurchaseLine."No.", ReturnShipmentHeader."VAT Registration No.");
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    procedure GetPartnerIDFromVATRegNoOfPurchaseReceipt()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        IntrastatReportHeader: Record "Intrastat Report Header";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        VendorNo: Code[20];
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Purchase] [Receipt]
        // [SCENARIO 389253] Partner VAT ID is blank for Purchase Receipt
        Initialize();

        // [GIVEN] Posted purchase order with Pay-to Vendor with VAT Registration No = 'AT0123456'
        VendorNo := CreateVendorWithVATRegNo(true);
        CreatePurchaseHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, WorkDate(), VendorNo);
        CreatePurchaseLine(PurchaseHeader, PurchaseLine, PurchaseLine.Type::Item, CreateItem());
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [WHEN] Intrastat Report Line is created
        CreateIntrastatReportAndSuggestLines(WorkDate(), IntrastatReportNo);
        IntrastatReportHeader.Get(IntrastatReportNo);

        // [THEN] Partner VAT ID  = '' in Intrastat Report Line
        PurchRcptHeader.SetRange("Buy-from Vendor No.", VendorNo);
        PurchRcptHeader.FindFirst();
        VerifyPartnerID(IntrastatReportHeader, PurchaseLine."No.", '');
    end;

    [Test]
    procedure FieldReportedIsCheckedOnModify()
    var
        IntrastatReportHeader: Record "Intrastat Report Header";
        IntrastatReportLine: Record "Intrastat Report Line";
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [UT]
        // [SCENARIO 402692] Intrastat Report batch "Reported" should be False on Modify the journal line

        // Positive
        LibraryIntrastat.CreateIntrastatReportLine(IntrastatReportLine);
        IntrastatReportLine.Modify(true);

        // Negative
        LibraryIntrastat.CreateIntrastatReport(WorkDate(), IntrastatReportNo);
        IntrastatReportHeader.Get(IntrastatReportNo);
        LibraryIntrastat.CreateIntrastatReportLineinIntrastatReport(IntrastatReportLine, IntrastatReportNo);
        IntrastatReportHeader.Status := IntrastatReportHeader.Status::Released;
        IntrastatReportHeader.Modify();

        asserterror IntrastatReportLine.Modify(true);
        Assert.ExpectedErrorCode('TestField');
        Assert.ExpectedError(IntrastatReportHeader.FieldName(Status));
    end;

    [Test]
    procedure FieldReportedIsCheckedOnRename()
    var
        IntrastatReportLine: Record "Intrastat Report Line";
        IntrastatReportHeader: Record "Intrastat Report Header";
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [UT]
        // [SCENARIO 402692] Intrastat Report batch "Reported" should be False on Rename the journal line

        // Positive
        LibraryIntrastat.CreateIntrastatReportLine(IntrastatReportLine);
        IntrastatReportLine.Rename(
          IntrastatReportLine."Intrastat No.", IntrastatReportLine."Line No." + 10000);

        // Negative
        LibraryIntrastat.CreateIntrastatReport(WorkDate(), IntrastatReportNo);
        IntrastatReportHeader.Get(IntrastatReportNo);
        LibraryIntrastat.CreateIntrastatReportLineinIntrastatReport(IntrastatReportLine, IntrastatReportNo);
        IntrastatReportHeader.Status := IntrastatReportHeader.Status::Released;
        IntrastatReportHeader.Modify();

        asserterror IntrastatReportLine.Rename(
            IntrastatReportLine."Intrastat No.", IntrastatReportLine."Line No." + 10000);
        Assert.ExpectedErrorCode('TestField');
        Assert.ExpectedError(IntrastatReportHeader.FieldName(Status));
    end;

    [Test]
    procedure FieldReportedIsCheckedOnDelete()
    var
        IntrastatReportHeader: Record "Intrastat Report Header";
        IntrastatReportLine: Record "Intrastat Report Line";
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [UT]
        // [SCENARIO 402692] Intrastat Report batch "Reported" should be False on Delete the journal line

        // Positive        
        LibraryIntrastat.CreateIntrastatReport(WorkDate(), IntrastatReportNo);
        LibraryIntrastat.CreateIntrastatReportLineinIntrastatReport(IntrastatReportLine, IntrastatReportNo);
        IntrastatReportLine.Delete(true);

        // Negative
        LibraryIntrastat.CreateIntrastatReport(WorkDate(), IntrastatReportNo);
        IntrastatReportHeader.Get(IntrastatReportNo);
        LibraryIntrastat.CreateIntrastatReportLineinIntrastatReport(IntrastatReportLine, IntrastatReportNo);
        IntrastatReportHeader.Status := IntrastatReportHeader.Status::Released;
        IntrastatReportHeader.Modify();

        asserterror IntrastatReportLine.Delete(true);
        Assert.ExpectedErrorCode('TestField');
        Assert.ExpectedError(IntrastatReportHeader.FieldName(Status));
    end;

    [Test]
    procedure BatchStatisticsPeriodFormatValidation()
    var
        IntrastatReportHeader: Record "Intrastat Report Header";
    begin
        // [FEATURE] [UI] [UT]
        // [SCENARIO 419963] Intrastat Report batch "Statistics Period" validation
        Initialize();

        asserterror IntrastatReportHeader.Validate("Statistics Period", '12345');
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(StrSubstNo(StatPeriodFormatErr, IntrastatReportHeader.FieldCaption("Statistics Period")));

        asserterror IntrastatReportHeader.Validate("Statistics Period", '0122');
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(StatPeriodMonthErr);

        IntrastatReportHeader.Validate("Statistics Period", '2201'); // YYMM
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    procedure IntrastatReportLineForFixedAssetPurchase()
    var
        PurchaseLine: Record "Purchase Line";
        IntrastatReportLine: Record "Intrastat Report Line";
        DocumentNo: Code[20];
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO] Check Intrastat Report Line for Fixed Asset posted Purchase Order.

        // [GIVEN] Posted Purchase Order
        Initialize();
        DocumentNo := CreateAndPostFixedAssetPurchaseOrder(PurchaseLine, WorkDate());
        // [WHEN] Get Intrastat Report Line for Fixed Asset Purchase Order
        // [THEN] Verify Intrastat Report Line
        CreateAndVerifyIntrastatLine(DocumentNo, PurchaseLine."No.", PurchaseLine.Quantity, IntrastatReportLine.Type::Receipt);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    procedure IntrastatReportLineForFixedAssetSale()
    var
        PurchaseLine: Record "Purchase Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        IntrastatReportLine: Record "Intrastat Report Line";
        DocumentNo: Code[20];
    begin
        // [FEATURE] [Sales]
        // [SCENARIO] Check Intrastat Report Line for Fixed Asset for posted Sales Order.

        Initialize();
        // [GIVEN] Create and post Aquisition Purchase Order
        DocumentNo := CreateAndPostFixedAssetPurchaseOrder(PurchaseLine, WorkDate());
        // [GIVEN] Create and Post Disposal Sales Order
        DocumentNo := CreateAndPostSalesDocumentMultiLine(
            SalesLine, SalesHeader."Document Type"::Order, WorkDate(), SalesLine.Type::"Fixed Asset", PurchaseLine."No.", 1);

        // [WHEN] Get Intrastat Report Lines for Sales Order
        // [THEN] Verify Intrastat Report Line
        CreateAndVerifyIntrastatLine(DocumentNo, SalesLine."No.", SalesLine.Quantity, IntrastatReportLine.Type::Shipment);
    end;

    local procedure Initialize()
    var
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        GLSetupVATCalculation: Enum "G/L Setup VAT Calculation";
    begin
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"Intrastat Report Test");
        LibraryVariableStorage.Clear();

        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(CODEUNIT::"Intrastat Report Test");
        UpdateIntrastatCodeInCountryRegion();
        LibraryERMCountryData.CreateVATData();
        LibraryERMCountryData.CreateGeneralPostingSetupData();
        LibraryERMCountryData.UpdateSalesReceivablesSetup();
        LibraryERMCountryData.UpdatePurchasesPayablesSetup();
        LibraryERMCountryData.UpdateGeneralPostingSetup();
        LibraryERM.SetBillToSellToVATCalc(GLSetupVATCalculation::"Bill-to/Pay-to No.");
        LibraryIntrastat.CreateIntrastatReportSetup();

        IsInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"Intrastat Report Test");
    end;

    local procedure VerifyIntrastatReportLineExist(IntrastatReportNo: Code[20]; DocumentNo: Code[20]; MustExist: Boolean)
    var
        IntrastatReportLine: Record "Intrastat Report Line";
    begin
        Commit();  // Commit is required to commit the posted entries.
        // Verify: Verify Intrastat Report Line with No entires.
        IntrastatReportLine.SetFilter("Intrastat No.", IntrastatReportNo);
        IntrastatReportLine.SetFilter("Document No.", DocumentNo);
        Assert.AreEqual(MustExist, IntrastatReportLine.FindFirst(), LineNotExistErr);
    end;

    local procedure CreateCountryRegion(var CountryRegion: Record "Country/Region"; IsEUCountry: Boolean)
    begin
        CountryRegion.Code := LibraryUtility.GenerateRandomCodeWithLength(CountryRegion.FieldNo(Code), Database::"Country/Region", 3);
        CountryRegion.Validate("Intrastat Code", CopyStr(LibraryUtility.GenerateRandomAlphabeticText(3, 0), 1, 3));
        if IsEUCountry then
            CountryRegion.Validate("EU Country/Region Code", CopyStr(LibraryUtility.GenerateRandomAlphabeticText(3, 0), 1, 3));
        CountryRegion.Insert(true);
    end;

    local procedure CreateCountryRegionWithIntrastatCode(IsEUIntrastat: Boolean): Code[10]
    var
        CountryRegion: Record "Country/Region";
    begin
        CreateCountryRegion(CountryRegion, IsEUIntrastat);
        exit(CountryRegion.Code);
    end;

    local procedure CreateCustomer(): Code[20]
    var
        Customer: Record Customer;
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Country/Region Code", GetCountryRegionCode());
        Customer.Modify(true);
        exit(Customer."No.");
    end;

    local procedure CreateFromToLocations(var LocationFrom: Record Location; var LocationTo: Record Location; CountryRegionCode: Code[10])
    begin
        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(LocationFrom);
        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(LocationTo);
        LocationTo.Validate("Country/Region Code", CountryRegionCode);
        LocationTo.Modify(true);
    end;

    local procedure CreateItem(): Code[20]
    var
        Item: Record Item;
    begin
        LibraryInventory.CreateItemWithTariffNo(Item, LibraryUtility.CreateCodeRecord(DATABASE::"Tariff Number"));
        exit(Item."No.");
    end;

    local procedure CreateFixedAsset(): Code[20]
    var
        FixedAsset: Record "Fixed Asset";
    begin
        LibraryFixedAsset.CreateFixedAsset(FixedAsset);
        exit(FixedAsset."No.");
    end;

    local procedure CreateItemChargeAssignmentForPurchaseCreditMemo(PurchaseLine: Record "Purchase Line"; DocumentNo: Code[20])
    var
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        ItemChargeAssgntPurch: Codeunit "Item Charge Assgnt. (Purch.)";
    begin
        ItemChargeAssignmentPurch.Init();
        ItemChargeAssignmentPurch.Validate("Document Type", PurchaseLine."Document Type");
        ItemChargeAssignmentPurch.Validate("Document No.", PurchaseLine."Document No.");
        ItemChargeAssignmentPurch.Validate("Document Line No.", PurchaseLine."Line No.");
        ItemChargeAssignmentPurch.Validate("Item Charge No.", PurchaseLine."No.");
        ItemChargeAssignmentPurch.Validate("Unit Cost", PurchaseLine."Direct Unit Cost");
        PurchRcptLine.SetRange("Document No.", DocumentNo);
        PurchRcptLine.FindFirst();
        ItemChargeAssgntPurch.CreateRcptChargeAssgnt(PurchRcptLine, ItemChargeAssignmentPurch);
        UpdatePurchaseItemChargeQtyToAssign(PurchaseLine);
    end;

    local procedure CreatePurchaseHeader(var PurchaseHeader: Record "Purchase Header"; DocumentType: Enum "Purchase Document Type"; PostingDate: Date;
                                                                                                         VendorNo: Code[20])
    var
        Location: Record Location;
    begin
        // Create Purchase Order With Random Quantity and Direct Unit Cost.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, DocumentType, VendorNo);
        with PurchaseHeader do begin
            Validate("Posting Date", PostingDate);
            LibraryWarehouse.CreateLocationWithInventoryPostingSetup(Location);
            Validate("Location Code", Location.Code);
            Modify(true);
        end;
    end;

    local procedure CreatePurchaseLine(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; Type: Enum "Purchase Line Type"; No: Code[20])
    var
        DepreciationBook: Record "Depreciation Book";
        FADepreciationBook: Record "FA Depreciation Book";
        FAPostingGroup: Record "FA Posting Group";
    begin
        // Take Random Values for Purchase Line.
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, Type, No, LibraryRandom.RandDec(10, 2));
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDec(100, 2));

        if PurchaseLine.Type = PurchaseLine.Type::"Fixed Asset" then begin
            LibraryFixedAsset.CreateDepreciationBook(DepreciationBook);
            DepreciationBook.Validate("G/L Integration - Acq. Cost", true);
            DepreciationBook.Validate("G/L Integration - Disposal", true);
            DepreciationBook.Modify(true);

            LibraryFixedAsset.CreateFADepreciationBook(FADepreciationBook, No, DepreciationBook.Code);
            LibraryFixedAsset.CreateFAPostingGroup(FAPostingGroup);
            FADepreciationBook.Validate("FA Posting Group", FAPostingGroup.Code);
            FADepreciationBook.Modify(true);

            PurchaseLine.Validate("Depreciation Book Code", DepreciationBook.Code);
            PurchaseLine.Validate(Quantity, 1);
        end;

        PurchaseLine.Modify(true);
    end;

    local procedure CreateAndPostPurchaseItemJournalLine(LocationCode: Code[10]; ItemNo: Code[20])
    var
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalLine: Record "Item Journal Line";
    begin
        LibraryInventory.CreateItemJournalTemplate(ItemJournalTemplate);
        LibraryInventory.CreateItemJournalBatch(ItemJournalBatch, ItemJournalTemplate.Name);
        LibraryInventory.CreateItemJournalLine(
          ItemJournalLine,
          ItemJournalTemplate.Name,
          ItemJournalBatch.Name,
          ItemJournalLine."Entry Type"::Purchase,
          ItemNo,
          LibraryRandom.RandIntInRange(10, 1000));
        ItemJournalLine.Validate("Location Code", LocationCode);
        ItemJournalLine.Modify(true);
        LibraryInventory.PostItemJournalLine(ItemJournalTemplate.Name, ItemJournalBatch.Name);
    end;

    local procedure CreateAndPostPurchaseOrder(var PurchaseLine: Record "Purchase Line"; PostingDate: Date): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        exit(
          CreateAndPostPurchaseDocumentMultiLine(
            PurchaseLine, PurchaseHeader."Document Type"::Order, PostingDate, PurchaseLine.Type::Item, CreateItem(), 1));
    end;

    local procedure CreateAndPostPurchaseDocumentMultiLine(var PurchaseLine: Record "Purchase Line"; DocumentType: Enum "Purchase Document Type"; PostingDate: Date; LineType: Enum "Purchase Line Type";
                                                                                                                       ItemNo: Code[20];
                                                                                                                       NoOfLines: Integer): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
        i: Integer;
    begin
        CreatePurchaseHeader(PurchaseHeader, DocumentType, PostingDate, CreateVendor(GetCountryRegionCode()));
        for i := 1 to NoOfLines do
            CreatePurchaseLine(PurchaseHeader, PurchaseLine, LineType, ItemNo);
        if LineType = LineType::"Fixed Asset" then
            exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true))
        else
            exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false));
    end;

    local procedure CreateAndPostSalesOrder(var SalesLine: Record "Sales Line"; PostingDate: Date): Code[20]
    var
        SalesHeader: Record "Sales Header";
    begin
        exit(
          CreateAndPostSalesDocumentMultiLine(
            SalesLine, SalesHeader."Document Type"::Order, PostingDate, SalesLine.Type::Item, CreateItem(), 1));
    end;

    local procedure CreateAndPostSalesOrderWithCountryAndLocation(CountryRegionCode: Code[10]; LocationCode: Code[10]; ItemNo: Code[20])
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        LibrarySales.CreateCustomerWithLocationCode(Customer, LocationCode);
        Customer.Validate("Country/Region Code", CountryRegionCode);
        Customer.Modify(true);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        SalesHeader.Validate("Location Code", LocationCode);
        SalesHeader.Validate("VAT Country/Region Code", CountryRegionCode);
        SalesHeader.Modify(true);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, ItemNo, 1);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
    end;

    local procedure CreateAndPostSalesDocumentMultiLine(var SalesLine: Record "Sales Line"; DocumentType: Enum "Sales Document Type"; PostingDate: Date; LineType: Enum "Sales Line Type";
                                                                                                              ItemNo: Code[20];
                                                                                                              NoOfSalesLines: Integer): Code[20]
    var
        SalesHeader: Record "Sales Header";
    begin
        CreateSalesDocument(SalesHeader, SalesLine, CreateCustomer(), PostingDate, DocumentType, LineType, ItemNo, NoOfSalesLines);
        if LineType = LineType::"Fixed Asset" then
            exit(LibrarySales.PostSalesDocument(SalesHeader, true, true))
        else
            exit(LibrarySales.PostSalesDocument(SalesHeader, true, false));
    end;

    local procedure CreateAndPostTransferOrder(var TransferLine: Record "Transfer Line"; FromLocation: Code[10]; ToLocation: Code[10]; ItemNo: Code[20])
    var
        TransferHeader: Record "Transfer Header";
    begin
        LibraryWarehouse.CreateTransferHeader(TransferHeader, FromLocation, ToLocation, '');
        TransferHeader.Validate("Direct Transfer", true);
        TransferHeader.Modify(true);
        LibraryWarehouse.CreateTransferLine(TransferHeader, TransferLine, ItemNo, 1);
        LibraryWarehouse.PostTransferOrder(TransferHeader, true, true);
    end;

    local procedure CreateShippingAgent(ShippingInternetAddress: Text[250]): Code[10]
    var
        ShippingAgent: Record "Shipping Agent";
    begin
        LibraryInventory.CreateShippingAgent(ShippingAgent);
        ShippingAgent."Internet Address" := ShippingInternetAddress;
        ShippingAgent.Modify();
        exit(ShippingAgent.Code);
    end;

    local procedure UseItemNonZeroNetWeight(var IntrastatReportLine: Record "Intrastat Report Line"): Decimal
    var
        Item: Record Item;
    begin
        Item.Get(CreateItem());
        IntrastatReportLine.Validate("Item No.", Item."No.");
        IntrastatReportLine.Validate(Quantity, LibraryRandom.RandDecInRange(10, 20, 2));
        IntrastatReportLine.Modify(true);
        exit(Item."Net Weight");
    end;

    local procedure CreateVendor(CountryRegionCode: Code[10]): Code[20]
    var
        Vendor: Record Vendor;
    begin
        LibraryPurchase.CreateVendor(Vendor);
        Vendor.Validate("Country/Region Code", CountryRegionCode);
        Vendor.Modify(true);
        exit(Vendor."No.");
    end;

    local procedure CreateAndVerifyIntrastatLine(DocumentNo: Code[20]; ItemNo: Code[20]; Quantity: Decimal; IntrastatReportLineType: Enum "Intrastat Report Line Type")
    var
        IntrastatReportNo: Code[20];
    begin
        // Exercise: Run Get Item Entries. Take Report Date as WORKDATE
        CreateIntrastatReportAndSuggestLines(WorkDate(), IntrastatReportNo);

        // Verify.
        VerifyIntrastatReportLine(DocumentNo, IntrastatReportNo, IntrastatReportLineType, GetCountryRegionCode(), ItemNo, Quantity);
    end;

    local procedure CreateSalesDocument(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; CustomerNo: Code[20]; PostingDate: Date; DocumentType: Enum "Sales Document Type"; Type: Enum "Sales Line Type"; No: Code[20];
                                                                                                                                                                               NoOfLines: Integer)
    var
        FADepreciationBook: Record "FA Depreciation Book";
        i: Integer;
    begin
        // Create Sales Order with Random Quantity and Unit Price.
        CreateSalesHeader(SalesHeader, CustomerNo, PostingDate, DocumentType);
        for i := 1 to NoOfLines do begin
            LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Type, No, LibraryRandom.RandDec(10, 2));
            SalesLine.Validate("Unit Price", LibraryRandom.RandDec(100, 2));
            if SalesLine.Type = SalesLine.Type::"Fixed Asset" then begin
                FADepreciationBook.SetRange("FA No.", No);
                FADepreciationBook.FindFirst();
                SalesLine.Validate("Depreciation Book Code", FADepreciationBook."Depreciation Book Code");
                SalesLine.Validate(Quantity, 1);
            end;
            SalesLine.Modify(true);
        end;
    end;

    local procedure CreateSalesShipmentHeader(var SalesShipmentHeader: Record "Sales Shipment Header"; ShippingInternetAddress: Text[250])
    begin
        SalesShipmentHeader.Init();
        SalesShipmentHeader."Package Tracking No." := LibraryUtility.GenerateGUID();
        SalesShipmentHeader."Shipping Agent Code" := CreateShippingAgent(ShippingInternetAddress);
    end;

    local procedure CreateSalesHeader(var SalesHeader: Record "Sales Header"; CustomerNo: Code[20]; PostingDate: Date; DocumentType: Enum "Sales Document Type")
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, CustomerNo);
        SalesHeader.Validate("Posting Date", PostingDate);
        SalesHeader.Modify(true);
    end;

    local procedure CreateItemLedgerEntry(var ItemLedgerEntry: Record "Item Ledger Entry"; PostingDate: Date; ItemNo: Code[20]; Quantity: Decimal; ILEEntryType: Enum "Item Ledger Entry Type")
    var
        ItemLedgerEntryNo: Integer;
    begin
        ItemLedgerEntryNo := LibraryUtility.GetNewRecNo(ItemLedgerEntry, ItemLedgerEntry.FieldNo("Entry No."));
        Clear(ItemLedgerEntry);
        ItemLedgerEntry."Entry No." := ItemLedgerEntryNo;
        ItemLedgerEntry."Item No." := ItemNo;
        ItemLedgerEntry."Posting Date" := PostingDate;
        ItemLedgerEntry."Entry Type" := ILEEntryType;
        ItemLedgerEntry.Quantity := Quantity;
        ItemLedgerEntry."Country/Region Code" := GetCountryRegionCode();
        ItemLedgerEntry.Insert();
    end;

    local procedure CreateValueEntry(var ValueEntry: Record "Value Entry"; var ItemLedgerEntry: Record "Item Ledger Entry"; DocumentType: Enum "Item Ledger Document Type"; PostingDate: Date)
    var
        ValueEntryNo: Integer;
    begin
        ValueEntryNo := LibraryUtility.GetNewRecNo(ValueEntry, ValueEntry.FieldNo("Entry No."));
        Clear(ValueEntry);
        ValueEntry."Entry No." := ValueEntryNo;
        ValueEntry."Item No." := ItemLedgerEntry."Item No.";
        ValueEntry."Posting Date" := PostingDate;
        ValueEntry."Entry Type" := ValueEntry."Entry Type"::"Direct Cost";
        ValueEntry."Item Ledger Entry Type" := ItemLedgerEntry."Entry Type";
        ValueEntry."Item Ledger Entry No." := ItemLedgerEntry."Entry No.";
        ValueEntry."Item Charge No." := LibraryInventory.CreateItemChargeNo();
        ValueEntry."Document Type" := DocumentType;
        ValueEntry.Insert();
    end;

    local procedure CreateCustomerWithVATRegNo(IsEUCountry: Boolean): Code[20]
    var
        Customer: Record Customer;
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Country/Region Code", CreateCountryRegionWithIntrastatCode(IsEUCountry));
        Customer.Validate("VAT Registration No.", LibraryERM.GenerateVATRegistrationNo(Customer."Country/Region Code"));
        Customer.Modify(true);
        exit(Customer."No.");
    end;

    local procedure CreateVendorWithVATRegNo(IsEUCountry: Boolean): Code[20]
    var
        Vendor: Record Vendor;
    begin
        LibraryPurchase.CreateVendor(Vendor);
        Vendor.Validate("Country/Region Code", CreateCountryRegionWithIntrastatCode(IsEUCountry));
        Vendor.Validate("VAT Registration No.", LibraryERM.GenerateVATRegistrationNo(Vendor."Country/Region Code"));
        Vendor.Modify(true);
        exit(Vendor."No.");
    end;

    local procedure DeleteAndVerifyNoIntrastatLine(DocumentNo: Code[20])
    var
        IntrastatReportLine: Record "Intrastat Report Line";
        IntrastatReportNo: Code[20];
    begin
        // Create and Get Intrastat Report Lines. Take Random Ending Date based on WORKDATE.
        CreateIntrastatReportAndSuggestLines(WorkDate(), IntrastatReportNo);

        // Exercise: Delete all entries from Intrastat Report Lines.
        IntrastatReportLine.SetRange("Document No.", DocumentNo);
        IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportNo);
        LibraryIntrastat.ClearIntrastatReportLines(IntrastatReportNo);

        // Verify.
        VerifyIntrastatLineForItemExist(DocumentNo, IntrastatReportNo);
    end;

    local procedure GetCountryRegionCode(): Code[10]
    var
        CountryRegion: Record "Country/Region";
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CountryRegion.SetFilter(Code, '<>%1', CompanyInformation."Country/Region Code");
        CountryRegion.SetFilter("Intrastat Code", '<>''''');
        CountryRegion.FindFirst();
        exit(CountryRegion.Code);
    end;

    local procedure GetEntriesAndVerifyNoItemLine(DocumentNo: Code[20])
    var
        IntrastatReportNo: Code[20];
    begin
        // Exercise: Run Get Item Entries. Take Starting Date as WORKDATE and Random Ending Date based on WORKDATE.
        CreateIntrastatReportAndSuggestLines(WorkDate(), IntrastatReportNo);

        // Verify:
        VerifyIntrastatLineForItemExist(DocumentNo, IntrastatReportNo);
    end;

    local procedure ValidateIntrastatContact(ContactType: Enum "Intrastat Report Contact Type"; ContactNo: Code[20])
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
    begin
        with IntrastatReportSetup do begin
            Get();
            Validate("Intrastat Contact Type", ContactType);
            Validate("Intrastat Contact No.", ContactNo);
            Modify(true);
        end;
    end;

    local procedure SetIntrastatContact(ContactType: Enum "Intrastat Report Contact Type"; ContactNo: Code[20])
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
    begin
        IntrastatReportSetup.Get();
        IntrastatReportSetup.Validate("Intrastat Contact Type", ContactType);
        IntrastatReportSetup.Validate("Intrastat Contact No.", ContactNo);
        IntrastatReportSetup.Modify();
    end;

    local procedure LookupIntrastatContactViaPage(ContactType: Enum "Intrastat Report Contact Type")
    var
        IntrastatReportSetup: TestPage "Intrastat Report Setup";
    begin
        BindSubscription(LibraryIntrastat);
        IntrastatReportSetup.OpenEdit();
        IntrastatReportSetup."Intrastat Contact Type".SetValue(ContactType);
        IntrastatReportSetup."Intrastat Contact No.".Lookup();
        IntrastatReportSetup.Close();
        UnbindSubscription(LibraryIntrastat);
    end;

    local procedure UpdateIntrastatCodeInCountryRegion()
    var
        CompanyInformation: Record "Company Information";
        CountryRegion: Record "Country/Region";
    begin
        CompanyInformation.Get();
        CompanyInformation."Bank Account No." := '';
        CompanyInformation.Modify();
        CountryRegion.Get(CompanyInformation."Country/Region Code");
        if CountryRegion."Intrastat Code" = '' then begin
            CountryRegion.Validate("Intrastat Code", CountryRegion.Code);
            CountryRegion.Modify(true);
        end;
    end;

    local procedure UpdatePurchaseItemChargeQtyToAssign(PurchaseLine: Record "Purchase Line")
    var
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
    begin
        ItemChargeAssignmentPurch.Get(
          PurchaseLine."Document Type", PurchaseLine."Document No.", PurchaseLine."Line No.", PurchaseLine."Line No.");
        ItemChargeAssignmentPurch.Validate("Qty. to Assign", PurchaseLine.Quantity);
        ItemChargeAssignmentPurch.Modify(true);
    end;

    local procedure UndoPurchaseReceiptLine(DocumentNo: Code[20]; No: Code[20])
    var
        PurchRcptLine: Record "Purch. Rcpt. Line";
    begin
        PurchRcptLine.SetRange("Document No.", DocumentNo);
        PurchRcptLine.SetRange("No.", No);
        PurchRcptLine.FindFirst();
        LibraryPurchase.UndoPurchaseReceiptLine(PurchRcptLine);
    end;

    local procedure UndoPurchaseReceiptLineByLineNo(DocumentNo: Code[20]; LineNo: Integer)
    var
        PurchRcptLine: Record "Purch. Rcpt. Line";
    begin
        with PurchRcptLine do begin
            SetRange("Document No.", DocumentNo);
            FindSet();
            Next(LineNo - 1);
            SetRecFilter();
        end;
        LibraryPurchase.UndoPurchaseReceiptLine(PurchRcptLine);
    end;

    local procedure UndoReturnShipmentLineByLineNo(DocumentNo: Code[20]; LineNo: Integer)
    var
        ReturnShipmentLine: Record "Return Shipment Line";
    begin
        with ReturnShipmentLine do begin
            SetRange("Document No.", DocumentNo);
            FindSet();
            Next(LineNo - 1);
            SetRecFilter();
        end;
        LibraryPurchase.UndoReturnShipmentLine(ReturnShipmentLine);
    end;

    local procedure UndoSalesShipmentLine(DocumentNo: Code[20]; No: Code[20])
    var
        SalesShipmentLine: Record "Sales Shipment Line";
    begin
        SalesShipmentLine.SetRange("Document No.", DocumentNo);
        SalesShipmentLine.SetRange("No.", No);
        SalesShipmentLine.FindFirst();
        LibrarySales.UndoSalesShipmentLine(SalesShipmentLine);
    end;

    local procedure UndoSalesShipmentLineByLineNo(DocumentNo: Code[20]; LineNo: Integer)
    var
        SalesShipmentLine: Record "Sales Shipment Line";
    begin
        with SalesShipmentLine do begin
            SetRange("Document No.", DocumentNo);
            FindSet();
            Next(LineNo - 1);
            SetRecFilter();
        end;
        LibrarySales.UndoSalesShipmentLine(SalesShipmentLine);
    end;

    local procedure UndoReturnReceiptLineByLineNo(DocumentNo: Code[20]; LineNo: Integer)
    var
        ReturnReceiptLine: Record "Return Receipt Line";
    begin
        with ReturnReceiptLine do begin
            SetRange("Document No.", DocumentNo);
            FindSet();
            Next(LineNo - 1);
            SetRecFilter();
        end;
        LibrarySales.UndoReturnReceiptLine(ReturnReceiptLine);
    end;

    local procedure UpdateShipmentOnInvoiceSalesSetup(ShipmentOnInvoice: Boolean)
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup.Validate("Shipment on Invoice", ShipmentOnInvoice);
        SalesReceivablesSetup.Modify(true);
    end;

    local procedure UpdateRetShpmtOnCrMemoPurchSetup(RetShpmtOnCrMemo: Boolean)
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.Validate("Return Shipment on Credit Memo", RetShpmtOnCrMemo);
        PurchasesPayablesSetup.Modify(true);
    end;

    local procedure GetIntrastatReportLine(DocumentNo: Code[20]; IntrastatReportNo: Code[20]; var IntrastatReportLine: Record "Intrastat Report Line")
    begin
        IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportNo);
        IntrastatReportLine.SetRange("Document No.", DocumentNo);
        DocumentNo := IntrastatReportNo;
        IntrastatReportLine.FindFirst();
    end;

    local procedure IntrastatSetupEnableReportReceipts()
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
    begin
        with IntrastatReportSetup do begin
            if not Get() then
                LibraryIntrastat.CreateIntrastatReportSetup();
            get();
            "Report Receipts" := true;
            Modify();
        end;
    end;

    local procedure VerifyIntrastatReportLine(DocumentNo: Code[20]; IntrastatReportNo: Code[20]; Type: Enum "Intrastat Report Line Type"; CountryRegionCode: Code[10]; ItemNo: Code[20]; Quantity: Decimal)
    var
        IntrastatReportLine: Record "Intrastat Report Line";
    begin
        GetIntrastatReportLine(DocumentNo, IntrastatReportNo, IntrastatReportLine);

        Assert.AreEqual(
          Type, IntrastatReportLine.Type,
          StrSubstNo(ValidationErr, IntrastatReportLine.FieldCaption(Type), Type, IntrastatReportLine.TableCaption()));

        Assert.AreEqual(
          Quantity, IntrastatReportLine.Quantity,
          StrSubstNo(ValidationErr, IntrastatReportLine.FieldCaption(Quantity), Quantity, IntrastatReportLine.TableCaption()));

        Assert.AreEqual(
            CountryRegionCode, IntrastatReportLine."Country/Region Code", StrSubstNo(ValidationErr,
            IntrastatReportLine.FieldCaption("Country/Region Code"), CountryRegionCode, IntrastatReportLine.TableCaption()));

        Assert.AreEqual(
            ItemNo, IntrastatReportLine."Item No.", StrSubstNo(ValidationErr,
            IntrastatReportLine.FieldCaption("Country/Region Code"), CountryRegionCode, IntrastatReportLine.TableCaption()));
    end;

    local procedure VerifyItemLedgerEntry(DocumentType: Enum "Item Ledger Document Type"; DocumentNo: Code[20];
                                                            CountryRegionCode: Code[10];
                                                            Quantity: Decimal)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.SetRange("Document Type", DocumentType);
        ItemLedgerEntry.SetRange("Document No.", DocumentNo);
        ItemLedgerEntry.FindFirst();

        Assert.AreEqual(
          CountryRegionCode, ItemLedgerEntry."Country/Region Code", StrSubstNo(ValidationErr,
            ItemLedgerEntry.FieldCaption("Country/Region Code"), CountryRegionCode, ItemLedgerEntry.TableCaption()));

        Assert.AreEqual(
          Quantity, ItemLedgerEntry.Quantity,
          StrSubstNo(ValidationErr, ItemLedgerEntry.FieldCaption(Quantity), Quantity, ItemLedgerEntry.TableCaption()));

        Assert.AreEqual(
          0, ItemLedgerEntry."Invoiced Quantity",
          StrSubstNo(ValidationErr, ItemLedgerEntry.FieldCaption("Invoiced Quantity"), 0, ItemLedgerEntry.TableCaption()));

        Assert.AreEqual(
          Quantity, ItemLedgerEntry."Remaining Quantity",
          StrSubstNo(ValidationErr, ItemLedgerEntry.FieldCaption("Remaining Quantity"), Quantity, ItemLedgerEntry.TableCaption()));
    end;

    local procedure VerifyIntrastatLineForItemExist(DocumentNo: Code[20]; IntrastatNo: Code[20])
    var
        IntrastatReportLine: Record "Intrastat Report Line";
    begin
        IntrastatReportLine.SetRange("Document No.", DocumentNo);
        IntrastatReportLine.SetRange("Intrastat No.", IntrastatNo);
        Assert.IsFalse(IntrastatReportLine.FindFirst(), LineNotExistErr);
    end;

    local procedure VerifyNoOfIntrastatLinesForDocumentNo(IntrastatReportNo: Code[20]; DocumentNo: Code[20]; LineCount: Integer)
    var
        IntrastatReportLine: Record "Intrastat Report Line";
    begin
        with IntrastatReportLine do begin
            SetRange("Intrastat No.", IntrastatReportNo);
            SetRange("Document No.", DocumentNo);
            Assert.AreEqual(
              LineCount, Count,
              StrSubstNo(LineCountErr, TableCaption));
        end;
    end;

    local procedure VerifyIntrastatContact(ContactType: Enum "Intrastat Report Contact Type"; ContactNo: Code[20])
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
    begin
        with IntrastatReportSetup do begin
            Get();
            TestField("Intrastat Contact Type", ContactType);
            TestField("Intrastat Contact No.", ContactNo);
        end;
    end;

    local procedure VerifyPartnerID(IntrastatReportHeader: Record "Intrastat Report Header"; ItemNo: Code[20]; PartnerID: Text[50])
    var
        IntrastatReportLine: Record "Intrastat Report Line";
    begin
        IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportHeader."No.");
        IntrastatReportLine.SetRange("Item No.", ItemNo);
        IntrastatReportLine.FindFirst();
        IntrastatReportLine.TestField("Partner VAT ID", PartnerID);
    end;

    local procedure CreateAndPostFixedAssetPurchaseOrder(var PurchaseLine: Record "Purchase Line"; PostingDate: Date): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        exit(
          CreateAndPostPurchaseDocumentMultiLine(
            PurchaseLine, PurchaseHeader."Document Type"::Order, PostingDate, PurchaseLine.Type::"Fixed Asset", CreateFixedAsset(), 1));
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure IntrastatReportListPageHandler(var IntrastatReportList: TestPage "Intrastat Report List")
    var
        NoVariant: Variant;
    begin
        LibraryVariableStorage.Dequeue(NoVariant);
        IntrastatReportList.FILTER.SetFilter("No.", NoVariant);
        IntrastatReportList.OK().Invoke();
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure GetItemLedgerEntriesReportHandler(var GetItemLedgerEntries: TestRequestPage "Get Item Ledger Entries")
    begin
        GetItemLedgerEntries.ShowingItemCharges.SetValue(LibraryVariableStorage.DequeueBoolean());
        GetItemLedgerEntries.OK().Invoke();
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure UndoDocumentConfirmHandler(Message: Text[1024]; var Reply: Boolean)
    begin
        // Send Reply = TRUE for Confirmation Message.
        Reply := true;
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure ContactList_MPH(var ContactList: TestPage "Contact List")
    begin
        ContactList.FILTER.SetFilter("No.", LibraryVariableStorage.DequeueText());
        ContactList.OK().Invoke();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure VendorList_MPH(var VendorLookup: TestPage "Vendor Lookup")
    begin
        VendorLookup.FILTER.SetFilter("No.", LibraryVariableStorage.DequeueText());
        VendorLookup.OK().Invoke();
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmHandler(Message: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    [Scope('OnPrem')]
    procedure MessageHandler(Msg: Text[1024])
    begin
        Assert.IsTrue(
          StrPos(Msg, 'The journal lines were successfully posted.') = 1,
          StrSubstNo('Unexpected Message: %1', Msg))
    end;

    [MessageHandler]
    [Scope('OnPrem')]
    procedure MessageHandlerEmpty(Msg: Text[1024])
    begin
    end;

    procedure CreateIntrastatReportAndSuggestLines(ReportDate: Date; var IntrastatReportNo: Code[20])
    begin
        LibraryIntrastat.CreateIntrastatReport(ReportDate, IntrastatReportNo);
        InvokeSuggestLinesOnIntrastatReport(IntrastatReportNo);
    end;


    procedure InvokeSuggestLinesOnIntrastatReport(IntrastatReportNo: Code[20])
    var
        IntrastatReport: TestPage "Intrastat Report";
    begin
        IntrastatReport.OpenEdit();
        IntrastatReport.Filter.SetFilter("No.", IntrastatReportNo);
        IntrastatReport.GetEntries.Invoke();
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure IntrastatReportGetLinesPageHandler(var IntrastatReportGetLines: TestRequestPage "Intrastat Report Get Lines")
    begin
        IntrastatReportGetLines.OK().Invoke();
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure IntrastatReportGetLinesShowingItemChargesPageHandler(var IntrastatReportGetLines: TestRequestPage "Intrastat Report Get Lines")
    begin
        IntrastatReportGetLines.ShowingItemCharges.SetValue(LibraryVariableStorage.DequeueBoolean());
        IntrastatReportGetLines.OK().Invoke();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure IntrastatReportModalPageHandler(var IntrastatReport: TestPage "Intrastat Report")
    var
        IntrastatReportNoVariant: Variant;
    begin
        LibraryVariableStorage.Dequeue(IntrastatReportNoVariant);
        IntrastatReport."No.".SetValue(IntrastatReportNoVariant);
        IntrastatReport.First();
        IntrastatReport.OK().Invoke();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure IntrastatReportChecklistModalPageHandler(var IntrastatReportChecklist: TestPage "Intrastat Report Checklist")
    var
    begin
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure IntrastatReportSetupModalPageHandler(var IntrastatReportSetupPage: TestPage "Intrastat Report Setup")
    var
    begin
    end;
}
