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
        LibraryERM: Codeunit "Library - ERM";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySales: Codeunit "Library - Sales";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryPatterns: Codeunit "Library - Patterns";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryRandom: Codeunit "Library - Random";
        LibraryMarketing: Codeunit "Library - Marketing";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        LibraryItemTracking: Codeunit "Library - Item Tracking";
        IsInitialized: Boolean;
        ValidationErr: Label '%1 must be %2 in %3.', Comment = '%1 = FieldCaption(Quantity),%2 = SalesLine.Quantity,%3 = TableCaption(SalesShipmentLine).';
        LineNotExistErr: Label 'Intrastat Report Lines incorrectly created.';
        LineCountErr: Label 'The number of %1 entries is incorrect.', Comment = '%1 = Intrastat Report Line table';
        InternetURLTxt: Label 'www.microsoft.com';
        InvalidURLTxt: Label 'URL must be prefix with http.';
        PackageTrackingNoErr: Label 'Package Tracking No does not exist.';
        TariffItemInfoDifferentErr: Label '%1 on %2 and %3 is different.', Comment = '%1 - field name, %2 - Item Table Caption, %3 - Tariff Number Table Caption';
        HttpTxt: Label 'http://';
        OnDelIntrastatContactErr: Label 'You cannot delete contact number %1 because it is set up as an Intrastat contact in the Intrastat Setup window.', Comment = '%1 - Contact No';
        OnDelVendorIntrastatContactErr: Label 'You cannot delete vendor number %1 because it is set up as an Intrastat contact in the Intrastat Setup window.', Comment = '%1 - Vendor No';
        ShptMethodCodeErr: Label 'Wrong Shipment Method Code';
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
        DocumentNo := LibraryIntrastat.CreateAndPostPurchaseOrder(PurchaseLine, WorkDate());

        // [THEN] Verify Item Ledger Entry
        VerifyItemLedgerEntry(ItemLedgerEntry."Document Type"::"Purchase Receipt", DocumentNo, LibraryIntrastat.GetCountryRegionCode(), PurchaseLine.Quantity);
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
        DocumentNo := LibraryIntrastat.CreateAndPostPurchaseOrder(PurchaseLine, WorkDate());

        // [WHEN] Get Intrastat Report Line for Purchase Order
        // [THEN] Verify Intrastat Report Line
        CreateAndVerifyIntrastatLine(DocumentNo, PurchaseLine."No.", PurchaseLine.Quantity, IntrastatReportLine.Type::Receipt);
    end;

    [Test]
    [HandlerFunctions('UndoDocumentConfirmHandler,IntrastatReportGetLinesPageHandler,NoLinesMsgHandler')]
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
        DocumentNo := LibraryIntrastat.CreateAndPostPurchaseOrder(PurchaseLine, WorkDate());

        // [WHEN] Undo Purchase Receipt Line
        LibraryIntrastat.UndoPurchaseReceiptLine(DocumentNo, PurchaseLine."No.");

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
        DocumentNo := LibraryIntrastat.CreateAndPostSalesOrder(SalesLine, WorkDate());

        // [THEN] Verify Item Ledger Entry
        VerifyItemLedgerEntry(ItemLedgerEntry."Document Type"::"Sales Shipment", DocumentNo, LibraryIntrastat.GetCountryRegionCode(), -SalesLine.Quantity);
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
        DocumentNo := LibraryIntrastat.CreateAndPostSalesOrder(SalesLine, WorkDate());

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
        LibraryIntrastat.CreateAndPostSalesOrder(SalesLine, WorkDate());

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
        DocumentNo := LibraryIntrastat.CreateAndPostSalesOrder(SalesLine, WorkDate());

        // [WHEN] Undo Sales Shipment Line
        LibraryIntrastat.UndoSalesShipmentLine(DocumentNo, SalesLine."No.");

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
        DocumentNo := LibraryIntrastat.CreateAndPostSalesOrder(SalesLine, WorkDate());
        LibraryIntrastat.UndoSalesShipmentLine(DocumentNo, SalesLine."No.");

        // [WHEN] Create Intrastat Journal Template, Batch and Get Entries for Intrastat Report Line
        // [THEN] Verify no entry exists for posted Item.
        GetEntriesAndVerifyNoItemLine(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler,NoLinesMsgHandler')]
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
        DocumentNo := LibraryIntrastat.CreateAndPostPurchaseOrder(PurchaseLine, NewPostingDate);

        // [GIVEN] Two Intrastat Reports for the same period
        Commit();  // Commit is required to commit the posted entries.
        CreateIntrastatReportAndSuggestLines(NewPostingDate, IntrastatReportNo1);
        CreateIntrastatReportAndSuggestLines(NewPostingDate, IntrastatReportNo2);

        Commit();
        // [WHEN] Get Entries from Intrastat Report pages for two Reports with the same period
        // [THEN] Verify that Entry values on Intrastat Report Page match Purchase Line values
        VerifyIntrastatReportLine(DocumentNo, IntrastatReportNo1, IntrastatReportLine.Type::Receipt,
            LibraryIntrastat.GetCountryRegionCode(), PurchaseLine."No.", PurchaseLine.Quantity);

        // [THEN] No Entries suggested in a second Intrastat Journal
        VerifyIntrastatReportLineExist(IntrastatReportNo2, PurchaseLine."No.", false);

        LibraryIntrastat.DeleteIntrastatReport(IntrastatReportNo1);
        LibraryIntrastat.DeleteIntrastatReport(IntrastatReportNo2);
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler,NoLinesMsgHandler')]
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
        DocumentNo := LibraryIntrastat.CreateAndPostPurchaseOrder(PurchaseLine, NewPostingDate);

        // [GIVEN] Create and Post Purchase Credit Memo with Item Charge Assignment on February.
        LibraryIntrastat.CreatePurchaseHeader(
          PurchaseHeader, PurchaseHeader."Document Type"::"Credit Memo",
          CalcDate('<1M>', NewPostingDate), LibraryIntrastat.CreateVendor(LibraryIntrastat.GetCountryRegionCode()));
        PurchaseHeader.Validate("Vendor Cr. Memo No.", PurchaseHeader."No.");
        PurchaseHeader.Modify(true);
        LibraryIntrastat.CreatePurchaseLine(
          PurchaseHeader, ChargePurchaseLine, ChargePurchaseLine.Type::"Charge (Item)", LibraryInventory.CreateItemChargeNo());
        LibraryIntrastat.CreateItemChargeAssignmentForPurchaseCreditMemo(ChargePurchaseLine, DocumentNo);
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);

        // [GIVEN] Two Reports for January and February
        // [WHEN] User runs Get Entries in Intrastat Report for January and February
        CreateIntrastatReportAndSuggestLines(NewPostingDate, IntrastatReportNo1);
        CreateIntrastatReportAndSuggestLines(PurchaseHeader."Posting Date", IntrastatReportNo2);

        Commit();

        // [THEN] "Intrastat Report Line" suggested for January  has Amount = "X" + Item Charge from February
        VerifyIntrastatReportLine(DocumentNo, IntrastatReportNo1, ChargeIntrastatReportLine.Type::Receipt,
           LibraryIntrastat.GetCountryRegionCode(), PurchaseLine."No.", PurchaseLine.Quantity);

        LibraryIntrastat.GetIntrastatReportLine(DocumentNo, IntrastatReportNo1, ChargeIntrastatReportLine);
        Assert.AreEqual(Abs(PurchaseLine.Amount - ChargePurchaseLine.Amount), ChargeIntrastatReportLine.Amount, '');

        // [THEN] "Location Code" is "Y" in the Intrastat Report Line
        // BUG 384736: "Location Code" copies to the Intrastat Report Line from the source documents
        Assert.AreEqual(PurchaseLine."Location Code", ChargeIntrastatReportLine."Location Code", '');

        // [THEN] and no entries suggested in a second Intrastat Journal for February
        VerifyIntrastatReportLineExist(IntrastatReportNo2, PurchaseLine."No.", false);

        LibraryIntrastat.DeleteIntrastatReport(IntrastatReportNo1);
        LibraryIntrastat.DeleteIntrastatReport(IntrastatReportNo2);
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler,NoLinesMsgHandler')]
    [Scope('OnPrem')]
    procedure IntrastatReportWithItemChargeAssignmentAfterSalesCreditMemo()
    var
        SalesHeader: Record "Sales Header";
        SalesLine, ChargeSalesLine : Record "Sales Line";
        ChargeIntrastatReportLine: Record "Intrastat Report Line";
        NewPostingDate: Date;
        DocumentNo: Code[20];
        IntrastatReportNo1, IntrastatReportNo2 : Code[20];
    begin
        // [FEATURE] [Sales] [Item Charge] 
        // [SCENARIO] Check Intrastat Report Lines after Posting Sales Order, Sales Credit Memo with Item Charge Assignment and Get Entries with New Posting Date.

        // [GIVEN] Create and Post Sales Order with New Posting Date with different 1 Year.
        Initialize();
        NewPostingDate := CalcDate('<' + Format(LibraryRandom.RandInt(5)) + 'Y>', WorkDate());
        DocumentNo := LibraryIntrastat.CreateAndPostSalesOrder(SalesLine, NewPostingDate);

        // [GIVEN] Create and post Sales Credit Memo with Item Charge Assignment with different Posting Date. 1M is required for Sales Credit Memo.
        LibraryIntrastat.CreateSalesDocument(
            SalesHeader, ChargeSalesLine, LibraryIntrastat.CreateCustomer(), CalcDate('<1M>', NewPostingDate), ChargeSalesLine."Document Type"::"Credit Memo",
            ChargeSalesLine.Type::"Charge (Item)", LibraryInventory.CreateItemChargeNo(), 1);
        LibraryIntrastat.CreateItemChargeAssignmentForSalesCreditMemo(ChargeSalesLine, DocumentNo);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        CreateIntrastatReportAndSuggestLines(NewPostingDate, IntrastatReportNo1);
        CreateIntrastatReportAndSuggestLines(SalesHeader."Posting Date", IntrastatReportNo2);

        Commit();

        // [WHEN] Open Intrastat Report Line Page and Get Entries
        // [THEN] "Intrastat Report Line" has Amount = "X" + Item Charge 
        VerifyIntrastatReportLine(DocumentNo, IntrastatReportNo1, ChargeIntrastatReportLine.Type::Shipment,
           LibraryIntrastat.GetCountryRegionCode(), SalesLine."No.", SalesLine.Quantity);

        LibraryIntrastat.GetIntrastatReportLine(DocumentNo, IntrastatReportNo1, ChargeIntrastatReportLine);
        Assert.AreEqual(Abs(SalesLine.Amount - ChargeSalesLine.Amount), ChargeIntrastatReportLine.Amount, '');

        // [THEN] Verify Intrastat Report Line for item charge does not exist
        VerifyIntrastatReportLineExist(IntrastatReportNo2, DocumentNo, false);

        LibraryIntrastat.DeleteIntrastatReport(IntrastatReportNo1);
        LibraryIntrastat.DeleteIntrastatReport(IntrastatReportNo2);
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
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
        LibraryIntrastat.CreateAndPostSalesOrder(SalesLine, NewPostingDate);

        Commit();  // Commit is required to commit the posted entries.

        // [WHEN] Get Entries from Intrastat Report page
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
        NetWeight := LibraryIntrastat.UseItemNonZeroNetWeight(IntrastatReportLine);

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
        LibraryIntrastat.CreateSalesShipmentHeader(SalesShipmentHeader, '%1');
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
        LibraryIntrastat.CreateSalesShipmentHeader(SalesShipmentHeader, InternetURLTxt);
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
        LibraryIntrastat.CreateSalesShipmentHeader(SalesShipmentHeader, HttpTxt + InternetURLTxt);
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
        LibraryIntrastat.CreateSalesShipmentHeader(SalesShipmentHeader, InternetURLTxt);
        ShippingAgent.Get(SalesShipmentHeader."Shipping Agent Code");
        Assert.IsTrue(
          StrPos(ShippingAgent.GetTrackingInternetAddr(SalesShipmentHeader."Package Tracking No."), SalesShipmentHeader."Package Tracking No.") = 0, PackageTrackingNoErr);
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler,NoLinesMsgHandler')]
    [Scope('OnPrem')]
    procedure VerifyNoIntraLinesCreatedForCrossedBoardItemChargeInNextPeriod()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        DocumentNo1: Code[20];
        DocumentNo2: Code[20];
        InvoicePostingDate: Date;
        IntrastatNo1: Code[20];
        IntrastatNo2: Code[20];
    begin
        // [FEATURE] [Purchase] [Item Charge]
        // [SCENARIO 376161] Invoice and Item Charge suggested for Intrastat Report in different Periods - Cross-Border
        Initialize();

        // [GIVEN] Posted Purchase Invoice in "Y" period - Cross-border
        InvoicePostingDate := CalcDate('<' + Format(LibraryRandom.RandInt(5)) + 'Y>', WorkDate());
        DocumentNo1 := LibraryIntrastat.CreateAndPostPurchaseOrder(PurchaseLine, InvoicePostingDate);

        // [GIVEN] Posted Item Charge in "F" period
        LibraryIntrastat.CreatePurchaseHeader(
          PurchaseHeader, PurchaseHeader."Document Type"::Invoice,
          CalcDate('<1M>', InvoicePostingDate), LibraryIntrastat.CreateVendor(LibraryIntrastat.GetCountryRegionCode()));
        LibraryIntrastat.CreatePurchaseLine(
          PurchaseHeader, PurchaseLine, PurchaseLine.Type::"Charge (Item)", LibraryInventory.CreateItemChargeNo());
        LibraryIntrastat.CreateItemChargeAssignmentForPurchaseCreditMemo(PurchaseLine, DocumentNo1);
        DocumentNo2 := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);

        // [GIVEN] Intrastat Batches for "Y" and "F" period
        CreateIntrastatReportAndSuggestLines(InvoicePostingDate, IntrastatNo1);
        CreateIntrastatReportAndSuggestLines(PurchaseHeader."Posting Date", IntrastatNo2);

        // [WHEN] Entries suggested to Intrastat Report "J" and "F"
        // [THEN] Intrastat Report "J" contains 1 line for Posted Invoice
        // [THEN] Intrastat Report "F" contains no lines for Posted Item Charge
        VerifyIntrastatReportLineExist(IntrastatNo1, DocumentNo1, true);
        VerifyIntrastatReportLineExist(IntrastatNo2, DocumentNo2, false);
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler,NoLinesMsgHandler')]
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
        LibraryIntrastat.CreatePurchaseHeader(
          PurchaseHeader, PurchaseHeader."Document Type"::Order, InvoicePostingDate,
          LibraryIntrastat.CreateVendor(CompanyInformation."Country/Region Code"));
        LibraryIntrastat.CreatePurchaseLine(PurchaseHeader, PurchaseLine, PurchaseLine.Type::Item, LibraryIntrastat.CreateItem());
        DocumentNo1 := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);

        // [GIVEN] Posted Item Charge in "F" period
        LibraryIntrastat.CreatePurchaseHeader(
          PurchaseHeader, PurchaseHeader."Document Type"::Invoice, CalcDate('<1M>', InvoicePostingDate),
          PurchaseHeader."Buy-from Vendor No.");
        LibraryInventory.CreateItemCharge(ItemCharge);
        LibraryIntrastat.CreatePurchaseLine(PurchaseHeader, PurchaseLine, PurchaseLine.Type::"Charge (Item)", ItemCharge."No.");
        LibraryIntrastat.CreateItemChargeAssignmentForPurchaseCreditMemo(PurchaseLine, DocumentNo1);
        DocumentNo2 := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);

        // [GIVEN] Intrastat Batches for "Y" and "F" period
        CreateIntrastatReportAndSuggestLines(InvoicePostingDate, IntrastatNo1);
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
          LibraryIntrastat.CreateAndPostPurchaseDocumentMultiLine(
            PurchaseLine, PurchaseHeader."Document Type"::Order, WorkDate(), PurchaseLine.Type::Item, LibraryIntrastat.CreateItem(), NoOfPurchaseLines);

        // [GIVEN] Undo Receipt for one of the lines (random) and finally post Purchase Order
        LibraryIntrastat.UndoPurchaseReceiptLineByLineNo(DocumentNo, LibraryRandom.RandInt(NoOfPurchaseLines));
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
          LibraryIntrastat.CreateAndPostSalesDocumentMultiLine(
            SalesLine, SalesLine."Document Type"::Order, WorkDate(), SalesLine.Type::Item, LibraryIntrastat.CreateItem(), NoOfSalesLines);

        // [GIVEN] Undo Receipt for one of the lines (random) and finally post Sales Order
        LibraryIntrastat.UndoSalesShipmentLineByLineNo(DocumentNo, LibraryRandom.RandInt(NoOfSalesLines));
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
          LibraryIntrastat.CreateAndPostPurchaseDocumentMultiLine(
            PurchaseLine, PurchaseHeader."Document Type"::"Return Order", WorkDate(), PurchaseLine.Type::Item, LibraryIntrastat.CreateItem(), NoOfPurchaseLines);

        // [GIVEN] Undo Receipt for one of the lines (random) and finally post Return Order
        LibraryIntrastat.UndoReturnShipmentLineByLineNo(DocumentNo, LibraryRandom.RandInt(NoOfPurchaseLines));
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
          LibraryIntrastat.CreateAndPostSalesDocumentMultiLine(
            SalesLine, SalesLine."Document Type"::"Return Order", WorkDate(), SalesLine.Type::Item, LibraryIntrastat.CreateItem(), NoOfSalesLines);

        // [GIVEN] Undo Receipt for one of the lines (random) and finally post Return Order
        LibraryIntrastat.UndoReturnReceiptLineByLineNo(DocumentNo, LibraryRandom.RandInt(NoOfSalesLines));
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        LibrarySales.PostSalesDocument(SalesHeader, false, true);

        // [WHEN] User runs Get Entries for Intrastat Report
        CreateIntrastatReportAndSuggestLines(WorkDate(), IntrastatReportNo);

        // [THEN] Only lines for which Undo Receipt was not done are suggested
        VerifyNoOfIntrastatLinesForDocumentNo(IntrastatReportNo, DocumentNo, NoOfSalesLines - 1);
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler,NoLinesMsgHandler')]
    [Scope('OnPrem')]
    procedure IntrastatReportWithItemChargeOnStartDate()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        IntrastatReportNo: Code[20];
        DocumentNo: Code[20];
    begin
        // [FEATURE] [Purchase] [Item Charge]
        // [SCENARIO] GetEntries for Intrastat should not create line for National Purchase order with Item Charge posted on StartDate of Period
        Initialize();

        // [GIVEN] Purchase Order with empty Country/Region Code on 01.Jan with Item "X"
        LibraryPurchase.CreatePurchHeader(
          PurchaseHeader, PurchaseHeader."Document Type"::Order, LibraryIntrastat.CreateVendor(LibraryIntrastat.GetCountryRegionCode()));
        with PurchaseHeader do begin
            Validate("Posting Date", CalcDate('<+1Y-CM>', WorkDate()));
            Validate("Buy-from Country/Region Code", '');
            Modify(true);
        end;
        LibraryIntrastat.CreatePurchaseLine(PurchaseHeader, PurchaseLine, PurchaseLine.Type::Item, LibraryIntrastat.CreateItem());

        // [GIVEN] Item Charge Purchase Line
        LibraryPatterns.ASSIGNPurchChargeToPurchaseLine(PurchaseHeader, PurchaseLine, 1, LibraryRandom.RandDecInRange(100, 200, 2));

        // [GIVEN] Purchase Order is Received and Invoiced on 01.Jan
        DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [WHEN] Run Get Entries on Intrastat Report with "Show item charge entries" options set to TRUE
        // [THEN] No Intrastat Report Lines should be created for Item "X"
        //OpenAndVerifyIntrastatReportLine(PurchaseLine."No.", false);
        LibraryVariableStorage.Enqueue(true); // Show Item Charge entries
        CreateIntrastatReportAndSuggestLines(PurchaseHeader."Posting Date", IntrastatReportNo);
        VerifyIntrastatLineForItemExist(DocumentNo, IntrastatReportNo);
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler,NoLinesMsgHandler')]
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
        DocumentNo := LibraryIntrastat.CreateAndPostPurchaseOrder(PurchaseLine, InvoicePostingDate);

        // [GIVEN] Posted Item Charge in "F" period
        LibraryIntrastat.CreatePurchaseHeader(
          PurchaseHeader, PurchaseHeader."Document Type"::Invoice, CalcDate('<1M>', InvoicePostingDate),
          LibraryIntrastat.CreateVendor(LibraryIntrastat.GetCountryRegionCode()));
        LibraryInventory.CreateItemCharge(ItemCharge);
        LibraryIntrastat.CreatePurchaseLine(PurchaseHeader, PurchaseLine, PurchaseLine.Type::"Charge (Item)", ItemCharge."No.");
        LibraryIntrastat.CreateItemChargeAssignmentForPurchaseCreditMemo(PurchaseLine, DocumentNo);
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
        Initialize();

        // Set "Intrastat Contact Type" = "Contact"
        IntrastatContactNo := LibraryIntrastat.CreateIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Contact);
        LibraryIntrastat.SetIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Contact, IntrastatContactNo);
        VerifyIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Contact, IntrastatContactNo);

        // Set "Intrastat Contact Type" = "Vendor"
        IntrastatContactNo := LibraryIntrastat.CreateIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Vendor);
        LibraryIntrastat.SetIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Vendor, IntrastatContactNo);
        VerifyIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Vendor, IntrastatContactNo);

        // Trying to set "Intrastat Contact Type" = "Contact" with vendor
        Vendor.Get(LibraryPurchase.CreateIntrastatContact(''));
        asserterror LibraryIntrastat.SetIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Contact, Vendor."No.");
        Assert.ExpectedErrorCode('DB:PrimRecordNotFound');
        Assert.ExpectedError(Contact.TableCaption());

        // Trying to set "Intrastat Contact Type" = "Vendor" with contact
        Contact.Get(LibraryMarketing.CreateIntrastatContact(''));
        asserterror LibraryIntrastat.SetIntrastatContact(IntrastatReportSetup."Intrastat Contact Type"::Vendor, Contact."No.");
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
        Initialize();

        // Empty setup record
        IntrastatReportSetup.Delete();
        Assert.RecordIsEmpty(IntrastatReportSetup);
        LibraryMarketing.CreateCompanyContact(Contact[1]);
        Contact[1].Delete(true);

        // Existing setup with other contact
        LibraryIntrastat.IntrastatSetupEnableReportReceipts();
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
        Initialize();

        // Empty setup record
        IntrastatReportSetup.Delete();
        LibraryPurchase.CreateVendor(Vendor[1]);
        Vendor[1].Delete(true);

        // Existing setup with other contact
        LibraryIntrastat.IntrastatSetupEnableReportReceipts();
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

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure TestEmptyTariffNoIsBlocking()
    var
        SalesLine: Record "Sales Line";
        Item: Record Item;
        IntrastatReportLine: Record "Intrastat Report Line";
        IntrastatReportPage: TestPage "Intrastat Report";
        InvoiceDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report] [Error handling]
        // [SCENARIO 219210] Deliverable 219210:Reporting - Error in case of empty "Tariff No."
        // [GIVEN] Posted Sales Order for intrastat without "Tariff No."
        // [GIVEN] Intrastat Report
        Initialize();

        InvoiceDate := CalcDate('<5Y>');
        LibraryIntrastat.CreateAndPostSalesOrder(SalesLine, InvoiceDate);
        Item.Get(SalesLine."No.");
        Item.Validate("Tariff No.", '');
        Item.Modify(true);

        // [GIVEN] A Intrastat Report with empty "Tariff No."
        CreateIntrastatReportAndSuggestLines(InvoiceDate, IntrastatReportNo);
        Commit();

        // [WHEN] Running Checklist
        IntrastatReportPage.OpenEdit();
        IntrastatReportPage.Filter.SetFilter("No.", IntrastatReportNo);
        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] You got an error on Tariff no.
        IntrastatReportPage.ErrorMessagesPart.Filter.SetFilter("Field Name", IntrastatReportLine.FieldName("Tariff No."));
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals(IntrastatReportLine.FieldName("Tariff No."));
        IntrastatReportPage.Close();
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure TestEmptyCountryCodeIsBlocking()
    var
        SalesLine: Record "Sales Line";
        IntrastatReportLine: Record "Intrastat Report Line";
        IntrastatReportPage: TestPage "Intrastat Report";
        InvoiceDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report] [Error handling]
        // [SCENARIO 219210] Deliverable 219210:Reporting - Error in case of empty "Country/Region Code"
        // [GIVEN] Posted Sales Order for intrastat
        // [GIVEN] Intrastat Report
        Initialize();
        InvoiceDate := CalcDate('<5Y>');
        LibraryIntrastat.CreateAndPostSalesOrder(SalesLine, InvoiceDate);
        Commit();

        // [GIVEN] A Intrastat Report with empty "Country/Region Code" line
        CreateIntrastatReportAndSuggestLines(InvoiceDate, IntrastatReportNo);
        IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportNo);
        IntrastatReportLine.ModifyAll("Country/Region Code", '');

        // [WHEN] Running Checklist
        IntrastatReportPage.OpenEdit();
        IntrastatReportPage.Filter.SetFilter("No.", IntrastatReportNo);
        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] You got a error in error part
        IntrastatReportPage.ErrorMessagesPart.Filter.SetFilter("Field Name", IntrastatReportLine.FieldName("Country/Region Code"));
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals(IntrastatReportLine.FieldName("Country/Region Code"));
        IntrastatReportPage.Close();
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure TestEmptyTransactionTypeIsBlocking()
    var
        SalesLine: Record "Sales Line";
        IntrastatReportLine: Record "Intrastat Report Line";
        IntrastatReportPage: TestPage "Intrastat Report";
        InvoiceDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report] [Error handling]
        // [SCENARIO 219210] Deliverable 219210:Reporting - Error in case of empty "Transaction Type"
        // [GIVEN] Posted Sales Order for intrastat
        // [GIVEN] Intrastat Report
        Initialize();
        InvoiceDate := CalcDate('<5Y>');
        LibraryIntrastat.CreateAndPostSalesOrder(SalesLine, InvoiceDate);
        Commit();

        // [GIVEN] A Intrastat Report with empty "Transaction Type" line
        CreateIntrastatReportAndSuggestLines(InvoiceDate, IntrastatReportNo);
        IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportNo);
        IntrastatReportLine.ModifyAll("Transaction Type", '');

        // [WHEN] Running Checklist
        IntrastatReportPage.OpenEdit();
        IntrastatReportPage.Filter.SetFilter("No.", IntrastatReportNo);
        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] You got a error in error part
        IntrastatReportPage.ErrorMessagesPart.Filter.SetFilter("Field Name", IntrastatReportLine.FieldCaption("Transaction Type"));
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals(IntrastatReportLine.FieldCaption("Transaction Type"));
        IntrastatReportPage.Close();
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure TestEmptyQtyIsBlocking()
    var
        SalesLine: Record "Sales Line";
        IntrastatReportLine: Record "Intrastat Report Line";
        IntrastatReportPage: TestPage "Intrastat Report";
        InvoiceDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report] [Error handling]
        // [SCENARIO 219210] Deliverable 219210:Reporting - Error in case of empty "Quantity" and "Supplementary Units" = true
        // [GIVEN] Posted Sales Order for intrastat
        // [GIVEN] Intrastat Report
        Initialize();
        InvoiceDate := CalcDate('<5Y>');
        LibraryIntrastat.CreateAndPostSalesOrder(SalesLine, InvoiceDate);
        Commit();

        // [GIVEN] A Intrastat Report with empty Quantity and "Supplementary Units" = false
        CreateIntrastatReportAndSuggestLines(InvoiceDate, IntrastatReportNo);
        IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportNo);
        IntrastatReportLine.ModifyAll(Quantity, 0);
        IntrastatReportLine.ModifyAll("Supplementary Units", false);

        // [WHEN] Running checklist
        IntrastatReportPage.OpenEdit();
        IntrastatReportPage.Filter.SetFilter("No.", IntrastatReportNo);
        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] Check no error in error part
        IntrastatReportPage.ErrorMessagesPart.Filter.SetFilter("Field Name", IntrastatReportLine.FieldName(Quantity));
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals('');

        // [GIVEN] A Intrastat Report with empty Quantity and "Supplementary Units" = true
        IntrastatReportLine.ModifyAll("Supplementary Units", true);
        // [WHEN] Running Create File
        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] You got a error in error part
        IntrastatReportPage.ErrorMessagesPart.Filter.SetFilter("Field Name", IntrastatReportLine.FieldName(Quantity));
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals(IntrastatReportLine.FieldName(Quantity));
        IntrastatReportPage.Close();
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure TestEmptyTotalWeightIsBlocking()
    var
        SalesLine: Record "Sales Line";
        IntrastatReportLine: Record "Intrastat Report Line";
        IntrastatReportPage: TestPage "Intrastat Report";
        InvoiceDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report] [Error handling]
        // [SCENARIO 219210] Deliverable 219210:Reporting - Error in case of empty "Total Weight" and "Supplementary Units" = false
        // [GIVEN] Posted Sales Order for intrastat
        // [GIVEN] Intrastat Report
        Initialize();
        InvoiceDate := CalcDate('<5Y>');
        LibraryIntrastat.CreateAndPostSalesOrder(SalesLine, InvoiceDate);
        Commit();

        // [GIVEN] A Intrastat Report with empty "Total Weight" and "Supplementary Units" = true
        CreateIntrastatReportAndSuggestLines(InvoiceDate, IntrastatReportNo);
        IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportNo);
        IntrastatReportLine.ModifyAll("Total Weight", 0);
        IntrastatReportLine.ModifyAll("Supplementary Units", true);

        // [WHEN] Running checklist
        IntrastatReportPage.OpenEdit();
        IntrastatReportPage.Filter.SetFilter("No.", IntrastatReportNo);
        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] Check no error in error part
        IntrastatReportPage.ErrorMessagesPart.Filter.SetFilter("Field Name", IntrastatReportLine.FieldName("Total Weight"));
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals('');

        // [GIVEN] A Intrastat Report with empty "Total Weight" and "Supplementary Units" = false
        IntrastatReportLine.ModifyAll("Supplementary Units", false);
        // [WHEN] Running Create File
        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] You got a error in error part
        IntrastatReportPage.ErrorMessagesPart.Filter.SetFilter("Field Name", IntrastatReportLine.FieldName("Total Weight"));
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals(IntrastatReportLine.FieldName("Total Weight"));
        IntrastatReportPage.Close();
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure TestEmptyCountryOfOriginIsBlocking()
    var
        SalesLine: Record "Sales Line";
        IntrastatReportLine: Record "Intrastat Report Line";
        IntrastatReportPage: TestPage "Intrastat Report";
        InvoiceDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report] [Error handling]
        // [SCENARIO 219210] Deliverable 219210:Reporting - Error in case of empty "Country/Region of Origin Code" and Type = Shipment
        // [GIVEN] Posted Sales Order for intrastat
        // [GIVEN] Intrastat Report
        Initialize();
        InvoiceDate := CalcDate('<5Y>');
        LibraryIntrastat.CreateAndPostSalesOrder(SalesLine, InvoiceDate);
        Commit();

        // [GIVEN] A Intrastat Report with empty "Country/Region of Origin Code" and Type = Receipt
        CreateIntrastatReportAndSuggestLines(InvoiceDate, IntrastatReportNo);
        IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportNo);
        IntrastatReportLine.ModifyAll("Country/Region of Origin Code", '');
        IntrastatReportLine.ModifyAll(Type, IntrastatReportLine.Type::Receipt);

        // [WHEN] Running checklist
        IntrastatReportPage.OpenEdit();
        IntrastatReportPage.Filter.SetFilter("No.", IntrastatReportNo);
        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] Check no error in error part
        IntrastatReportPage.ErrorMessagesPart.Filter.SetFilter("Field Name", IntrastatReportLine.FieldName("Country/Region of Origin Code"));
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals('');

        // [GIVEN] A Intrastat Report with empty "Country/Region of Origin Code" and Type = Shipment
        IntrastatReportLine.ModifyAll(Type, IntrastatReportLine.Type::Shipment);
        // [WHEN] Running Create File
        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] You got a error in error part
        IntrastatReportPage.ErrorMessagesPart.Filter.SetFilter("Field Name", IntrastatReportLine.FieldName("Country/Region of Origin Code"));
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals(IntrastatReportLine.FieldName("Country/Region of Origin Code"));
        IntrastatReportPage.Close();
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure TestEmptyPartnerVATIDIsBlocking()
    var
        SalesLine: Record "Sales Line";
        IntrastatReportLine: Record "Intrastat Report Line";
        IntrastatReportPage: TestPage "Intrastat Report";
        InvoiceDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report] [Error handling]
        // [SCENARIO 219210] Deliverable 219210:Reporting - Error in case of empty "Partner VAT ID" and Type = Shipment
        // [GIVEN] Posted Sales Order for intrastat
        // [GIVEN] Intrastat Report
        Initialize();
        InvoiceDate := CalcDate('<5Y>');
        LibraryIntrastat.CreateAndPostSalesOrder(SalesLine, InvoiceDate);
        Commit();

        // [GIVEN] A Intrastat Report with empty "Partner VAT ID" and Type = Receipt
        CreateIntrastatReportAndSuggestLines(InvoiceDate, IntrastatReportNo);
        IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportNo);
        IntrastatReportLine.ModifyAll("Partner VAT ID", '');
        IntrastatReportLine.ModifyAll(Type, IntrastatReportLine.Type::Receipt);

        // [WHEN] Running checklist
        IntrastatReportPage.OpenEdit();
        IntrastatReportPage.Filter.SetFilter("No.", IntrastatReportNo);
        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] Check no error in error part
        IntrastatReportPage.ErrorMessagesPart.Filter.SetFilter("Field Name", IntrastatReportLine.FieldCaption("Partner VAT ID"));
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals('');

        // [GIVEN] A Intrastat Report with empty "Total Weight" and "Supplementary Units" = false
        IntrastatReportLine.ModifyAll(Type, IntrastatReportLine.Type::Shipment);
        // [WHEN] Running Create File
        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] You got a error in error part
        IntrastatReportPage.ErrorMessagesPart.Filter.SetFilter("Field Name", IntrastatReportLine.FieldCaption("Partner VAT ID"));
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals(IntrastatReportLine.FieldCaption("Partner VAT ID"));
        IntrastatReportPage.Close();
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure TestNonEmptyCountryOfOriginIsBlockingReceipts()
    var
        Country: Record "Country/Region";
        PurchaseLine: Record "Purchase Line";
        IntrastatReportLine: Record "Intrastat Report Line";
        IntrastatReportChecklist: Record "Intrastat Report Checklist";
        IntrastatReportPage: TestPage "Intrastat Report";
        InvoiceDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report] [Error handling]
        // [SCENARIO 219210] Deliverable 219210:Reporting - Error in case of non empty "Country Of Origin" in receipt line
        // [GIVEN] Posted Purchase Order for intrastat
        // [GIVEN] Intrastat Report
        Initialize();
        InvoiceDate := CalcDate('<5Y>');
        LibraryIntrastat.CreateAndPostPurchaseOrder(PurchaseLine, InvoiceDate);
        Commit();

        Country.SetFilter("Intrastat Code", '<>%1', '');
        Country.FindFirst();

        // [GIVEN] A Intrastat Report with non - empty "Country/Region of Origin Code" line
        CreateIntrastatReportAndSuggestLines(InvoiceDate, IntrastatReportNo);
        IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportNo);
        IntrastatReportLine.ModifyAll("Country/Region of Origin Code", Country.Code);

        // Adding rule for "must be blank" for all receipts
        IntrastatReportChecklist.Get(IntrastatReportLine.FieldNo("Country/Region of Origin Code"));
        IntrastatReportChecklist.Validate("Must Be Blank For Filter Expr.", 'Type: Receipt');
        IntrastatReportChecklist.Modify(true);

        // [WHEN] Running Checklist
        IntrastatReportPage.OpenEdit();
        IntrastatReportPage.Filter.SetFilter("No.", IntrastatReportNo);
        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] You got a error in error part
        IntrastatReportPage.ErrorMessagesPart.Filter.SetFilter("Field Name", IntrastatReportLine.FieldCaption("Country/Region of Origin Code"));
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals(IntrastatReportLine.FieldCaption("Country/Region of Origin Code"));
        IntrastatReportPage.Close();

        // Resetting rule for "must be blank" for all receipts
        IntrastatReportChecklist.Get(IntrastatReportLine.FieldNo("Country/Region of Origin Code"));
        IntrastatReportChecklist.Validate("Must Be Blank For Filter Expr.", '');
        IntrastatReportChecklist.Modify(true);
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure TestEmptyNonEmptyCountryOfOriginConflict()
    var
        Country: Record "Country/Region";
        SalesLine: Record "Sales Line";
        IntrastatReportLine: Record "Intrastat Report Line";
        IntrastatReportChecklist: Record "Intrastat Report Checklist";
        IntrastatReportPage: TestPage "Intrastat Report";
        InvoiceDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report] [Error handling]
        // [SCENARIO 219210] Deliverable 219210:Reporting - Error in case of rules conflict on "Country Of Origin"
        // [GIVEN] Posted Sales Order for intrastat
        // [GIVEN] Intrastat Report
        Initialize();
        InvoiceDate := CalcDate('<5Y>');
        LibraryIntrastat.CreateAndPostSalesOrder(SalesLine, InvoiceDate);
        Commit();

        Country.SetFilter("Intrastat Code", '<>%1', '');
        Country.FindFirst();

        // [GIVEN] A Intrastat Report with non - empty "Country/Region of Origin Code" line
        CreateIntrastatReportAndSuggestLines(InvoiceDate, IntrastatReportNo);
        IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportNo);
        IntrastatReportLine.ModifyAll("Country/Region of Origin Code", Country.Code);

        // Adding conflicting rule for "must be blank" for all receipts
        IntrastatReportChecklist.Get(IntrastatReportLine.FieldNo("Country/Region of Origin Code"));
        IntrastatReportChecklist.Validate("Must Be Blank For Filter Expr.", 'Type: Shipment');
        IntrastatReportChecklist.Modify(true);

        // [WHEN] Running Checklist
        IntrastatReportPage.OpenEdit();
        IntrastatReportPage.Filter.SetFilter("No.", IntrastatReportNo);
        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] You got a error in error part
        IntrastatReportPage.ErrorMessagesPart.Filter.SetFilter("Field Name", IntrastatReportLine.FieldCaption("Country/Region of Origin Code"));
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals(IntrastatReportLine.FieldCaption("Country/Region of Origin Code"));
        IntrastatReportPage.Close();

        // Resetting rule for "must be blank" for all receipts
        IntrastatReportChecklist.Get(IntrastatReportLine.FieldNo("Country/Region of Origin Code"));
        IntrastatReportChecklist.Validate("Must Be Blank For Filter Expr.", '');
        IntrastatReportChecklist.Modify(true);
    end;

    [MessageHandler]
    [Scope('OnPrem')]
    procedure CreateFileMessageHandler(Message: Text)
    begin
        Assert.AreEqual('One or more errors were found. You must resolve all the errors before you can proceed.', Message, '');
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure E2EErrorHandlingOfIntrastatReport()
    var
        SalesLine: Record "Sales Line";
        IntrastatReportLine: Record "Intrastat Report Line";
        ShipmentMethod: Record "Shipment Method";
        TransactionType: Record "Transaction Type";
        IntrastatReportPage: TestPage "Intrastat Report";
        InvoiceDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report] [Error handling]
        // [SCENARIO 219210] Deliverable 219210:Reporting - End to end error handling
        // [GIVEN] Posted Sales Order for intrastat
        // [GIVEN] Report Template and Batch 
        Initialize();
        InvoiceDate := CalcDate('<5Y>');
        LibraryIntrastat.CreateAndPostSalesOrder(SalesLine, InvoiceDate);
        CreateIntrastatReportAndSuggestLines(InvoiceDate, IntrastatReportNo);
        Commit();

        // [GIVEN] A Intrastat Report
        IntrastatReportPage.OpenEdit();
        IntrastatReportPage.Filter.SetFilter("No.", IntrastatReportNo);
        IntrastatReportPage."Currency Identifier".Value := 'EUR';

        // [WHEN] Running Checklist
        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] You got a error
        IntrastatReportPage.ErrorMessagesPart.Filter.SetFilter("Field Name", IntrastatReportLine.FieldName("Transaction Type"));
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals(IntrastatReportLine.FieldName("Transaction Type"));

        // [WHEN] Fixing the error
        TransactionType.Code := CopyStr(LibraryUtility.GenerateGUID(), 1, 2);
        TransactionType.Insert();
        IntrastatReportPage.IntrastatLines."Transaction Type".Value(TransactionType.Code);

        // [WHEN] Running Checklist
        IntrastatReportPage.ChecklistReport.Invoke();

        IntrastatReportPage.IntrastatLines."Total Weight".Value('1');
        // [WHEN] Fixing the error
        ShipmentMethod.FindFirst();
        IntrastatReportPage.IntrastatLines."Shpt. Method Code".Value(ShipmentMethod.Code);
        IntrastatReportPage.IntrastatLines."Partner VAT ID".Value('111111111');
        // [WHEN] Running Checklist
        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] You no more errors
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals('');

        // [WHEN] Running Create File
        // [THEN] You do not get any errors
        IntrastatReportPage.CreateFile.Invoke();

        IntrastatReportPage.Close();
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure E2EIntrastatReportFileCreation()
    var
        SalesLine: Record "Sales Line";
        ShipmentMethod: Record "Shipment Method";
        TransactionType: Record "Transaction Type";
        IntrastatReportPage: TestPage "Intrastat Report";
        InvoiceDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report] [Error handling]
        // [SCENARIO 219210] Deliverable 219210:Reporting - End to end file creation
        // [GIVEN] Posted Sales Order for intrastat
        // [GIVEN] Report Template and Batch 
        Initialize();
        InvoiceDate := CalcDate('<5Y>');
        LibraryIntrastat.CreateAndPostSalesOrder(SalesLine, InvoiceDate);
        CreateIntrastatReportAndSuggestLines(InvoiceDate, IntrastatReportNo);
        Commit();

        // [GIVEN] A Intrastat Report
        IntrastatReportPage.OpenEdit();
        IntrastatReportPage.Filter.SetFilter("No.", IntrastatReportNo);
        IntrastatReportPage."Currency Identifier".Value := 'EUR';

        TransactionType.Code := CopyStr(LibraryUtility.GenerateGUID(), 3, 2);
        TransactionType.Insert();
        IntrastatReportPage.IntrastatLines."Transaction Type".Value(TransactionType.Code);
        IntrastatReportPage.IntrastatLines.Quantity.Value('5');
        IntrastatReportPage.IntrastatLines."Total Weight".Value('10');
        IntrastatReportPage.IntrastatLines."Statistical Value".Value('25');

        ShipmentMethod.FindFirst();
        IntrastatReportPage.IntrastatLines."Shpt. Method Code".Value(ShipmentMethod.Code);
        IntrastatReportPage.IntrastatLines."Partner VAT ID".Value('111111111');
        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] You no more errors
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals('');

        // [WHEN] Running Create File
        IntrastatReportPage.CreateFile.Invoke();

        // [THEN] Check file content
        CheckFileContent(IntrastatReportPage);

        IntrastatReportPage.Close();
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure TestSellToCountry()
    var
        SellToCountryRegion: Record "Country/Region";
        ShipToCountryRegion: Record "Country/Region";
        BillToCountryRegion: Record "Country/Region";
        IntrastatReportSetup: Record "Intrastat Report Setup";
        IntrastatReportPage: TestPage "Intrastat Report";
        InvoiceDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report] [Error handling]
        // [SCENARIO 219210] Deliverable 219210: Test Shipment Based on "Sell-to Country"
        // [GIVEN] Posted Sales Order for intrastat
        // [GIVEN] Report Template and Batch 
        Initialize();
        IntrastatReportSetup.Get();
        IntrastatReportSetup."Shipments Based On" := IntrastatReportSetup."Shipments Based On"::"Sell-to Country";
        IntrastatReportSetup.Modify();

        InvoiceDate := CalcDate('<5Y>');

        LibraryIntrastat.CreateCountryRegion(SellToCountryRegion, true);
        LibraryIntrastat.CreateCountryRegion(ShipToCountryRegion, true);
        LibraryIntrastat.CreateCountryRegion(BillToCountryRegion, true);
        LibraryIntrastat.CreateAndPostSalesOrderWithDiferrentCountries(SellToCountryRegion.Code, ShipToCountryRegion.Code, BillToCountryRegion.Code, InvoiceDate);

        CreateIntrastatReportAndSuggestLines(InvoiceDate, IntrastatReportNo);
        Commit();

        // [WHEN] Running checklist
        IntrastatReportPage.OpenEdit();
        IntrastatReportPage.Filter.SetFilter("No.", IntrastatReportNo);

        // [THEN] Check no error in error part
        IntrastatReportPage.IntrastatLines."Country/Region Code".AssertEquals(SellToCountryRegion.Code);
        IntrastatReportPage.Close();
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure TestBillToCountry()
    var
        SellToCountryRegion: Record "Country/Region";
        ShipToCountryRegion: Record "Country/Region";
        BillToCountryRegion: Record "Country/Region";
        IntrastatReportSetup: Record "Intrastat Report Setup";
        IntrastatReportPage: TestPage "Intrastat Report";
        InvoiceDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report] [Error handling]
        // [SCENARIO 219210] Deliverable 219210: Test Shipment Based on "Bill-to Country"
        // [GIVEN] Posted Sales Order for intrastat
        // [GIVEN] Report Template and Batch 
        Initialize();
        IntrastatReportSetup.Get();
        IntrastatReportSetup."Shipments Based On" := IntrastatReportSetup."Shipments Based On"::"Bill-to Country";
        IntrastatReportSetup.Modify();

        InvoiceDate := CalcDate('<5Y>');

        LibraryIntrastat.CreateCountryRegion(SellToCountryRegion, true);
        LibraryIntrastat.CreateCountryRegion(ShipToCountryRegion, true);
        LibraryIntrastat.CreateCountryRegion(BillToCountryRegion, true);
        LibraryIntrastat.CreateAndPostSalesOrderWithDiferrentCountries(SellToCountryRegion.Code, ShipToCountryRegion.Code, BillToCountryRegion.Code, InvoiceDate);

        CreateIntrastatReportAndSuggestLines(InvoiceDate, IntrastatReportNo);
        Commit();

        // [WHEN] Running checklist
        IntrastatReportPage.OpenEdit();
        IntrastatReportPage.Filter.SetFilter("No.", IntrastatReportNo);

        // [THEN] Check no error in error part
        IntrastatReportPage.IntrastatLines."Country/Region Code".AssertEquals(BillToCountryRegion.Code);
        IntrastatReportPage.Close();
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure TestShipToCountry()
    var
        SellToCountryRegion: Record "Country/Region";
        ShipToCountryRegion: Record "Country/Region";
        BillToCountryRegion: Record "Country/Region";
        IntrastatReportSetup: Record "Intrastat Report Setup";
        IntrastatReportPage: TestPage "Intrastat Report";
        InvoiceDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report] [Error handling]
        // [SCENARIO 219210] Deliverable 219210: Test Shipment Based on "Ship-to Country"
        // [GIVEN] Posted Sales Order for intrastat
        // [GIVEN] Report Template and Batch 
        Initialize();
        IntrastatReportSetup.Get();
        IntrastatReportSetup."Shipments Based On" := IntrastatReportSetup."Shipments Based On"::"Ship-to Country";
        IntrastatReportSetup.Modify();

        InvoiceDate := CalcDate('<5Y>');

        LibraryIntrastat.CreateCountryRegion(SellToCountryRegion, true);
        LibraryIntrastat.CreateCountryRegion(ShipToCountryRegion, true);
        LibraryIntrastat.CreateCountryRegion(BillToCountryRegion, true);
        LibraryIntrastat.CreateAndPostSalesOrderWithDiferrentCountries(SellToCountryRegion.Code, ShipToCountryRegion.Code, BillToCountryRegion.Code, InvoiceDate);

        CreateIntrastatReportAndSuggestLines(InvoiceDate, IntrastatReportNo);
        Commit();

        // [WHEN] Running checklist
        IntrastatReportPage.OpenEdit();
        IntrastatReportPage.Filter.SetFilter("No.", IntrastatReportNo);

        // [THEN] Check no error in error part
        IntrastatReportPage.IntrastatLines."Country/Region Code".AssertEquals(ShipToCountryRegion.Code);
        IntrastatReportPage.Close();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [Scope('OnPrem')]
    procedure TestSupplementaryInfoFromTariffNo()
    var
        TariffNumber: Record "Tariff Number";
        Item: Record Item;
        UnitOfMeasure: Record "Unit of Measure";
        ItemOUM: Record "Item Unit of Measure";
    begin
        // [FEATURE] [Intrastat Report] [Error handling]
        // [SCENARIO 451276] Deliverable 451276: Test supplementary info validation between Tariff number and item 

        // Create Unit of Measure
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        // Create Tariff Number 
        TariffNumber.Get(LibraryUtility.CreateCodeRecord(DATABASE::"Tariff Number"));
        // Validate Supplementary Info fields
        TariffNumber.Validate("Supplementary Units", true);
        TariffNumber.Validate("Suppl. Unit of Measure", UnitOfMeasure.Code);
        TariffNumber.Validate("Suppl. Conversion Factor", 3);
        TariffNumber.Modify(true);

        // Create Item with Tariff number
        LibraryInventory.CreateItemWithTariffNo(Item, TariffNumber."No.");
        // Get created Item Unit Of Measure 
        ItemOUM.Get(Item."No.", UnitOfMeasure.Code);

        // Compare Values
        Assert.AreEqual(Item."Supplementary Unit of Measure", TariffNumber."Suppl. Unit of Measure", StrSubstNo(TariffItemInfoDifferentErr, Item.FieldCaption("Supplementary Unit of Measure"), Item.TableCaption, TariffNumber.TableCaption));
        Assert.AreEqual(ItemOUM."Qty. per Unit of Measure", 0.33333, StrSubstNo(TariffItemInfoDifferentErr, ItemOUM.FieldCaption("Qty. per Unit of Measure"), ItemOUM.TableCaption, TariffNumber.TableCaption));

        // Update Supplementary Info on Tariff number
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        TariffNumber.Validate("Suppl. Unit of Measure", UnitOfMeasure.Code);
        TariffNumber.Validate("Suppl. Conversion Factor", 0.5);
        TariffNumber.Modify(true);

        // Get Item and Item Unit Of Measure
        Item.Get(Item."No.");
        ItemOUM.Get(Item."No.", UnitOfMeasure.Code);

        // Compare Values
        Assert.AreEqual(Item."Supplementary Unit of Measure", TariffNumber."Suppl. Unit of Measure", StrSubstNo(TariffItemInfoDifferentErr, Item.FieldCaption("Supplementary Unit of Measure"), Item.TableCaption, TariffNumber.TableCaption));
        Assert.AreEqual(ItemOUM."Qty. per Unit of Measure", 2, StrSubstNo(TariffItemInfoDifferentErr, ItemOUM.FieldCaption("Qty. per Unit of Measure"), ItemOUM.TableCaption, TariffNumber.TableCaption));
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler,IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure ShptMethodCodeJobJournal()
    var
        IntrastatReportLine: Record "Intrastat Report Line";
        ShipmentMethod: Record "Shipment Method";
        Location: Record Location;
        IntrastatReportNo: Code[20];
        ItemNo: Code[20];
    begin
        // [FEATURE] [Job]
        // [SCENARIO] User creates and posts job journal and fills Intrastat Report
        Initialize();
        // [GIVEN] Shipment Method "SMC"
        ShipmentMethod.FindFirst();
        // [GIVEN] Location "X"
        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(Location);
        // [GIVEN] Job Journal Line (posted) with item, "X" and "SMC"
        ItemNo := LibraryIntrastat.CreateAndPostJobJournalLine(ShipmentMethod.Code, Location.Code);
        // [WHEN] Run Intrastat Report, then Get Entries 
        CreateIntrastatReportAndSuggestLines(WorkDate(), IntrastatReportNo);

        // [THEN] "Shpt. Method Code" in the Intrastat Report Line = "SMC"
        IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportNo);
        IntrastatReportLine.SetRange("Item No.", ItemNo);
        IntrastatReportLine.FindFirst();
        Assert.IsTrue(1 = 1, ShptMethodCodeErr);
        Assert.AreEqual(ShipmentMethod.Code, IntrastatReportLine."Shpt. Method Code", ShptMethodCodeErr);
        // [THEN] "Location Code" is "X" in the Intrastat Report Line = "SMC"
        // BUG 384736: "Location Code" copies to the Intrastat Report Line from the source documents
    end;

    [Test]
    [HandlerFunctions('MessageHandlerEmpty,IntrastatReportGetLinesPageHandler')]
    [Scope('OnPrem')]
    procedure IntrastatReportWithItemChargeInvoiceRevoked()
    var
        PostingDate: Date;
        DocumentNo: Code[20];
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Corrective Credit Memo] [Item Charge]
        // [SCENARIO 286107] Item Charge entry posted by Credit Memo in next period must not be reported in Intrastat Report
        Initialize();

        // [GIVEN] Sales Invoice with Item and Item Charge posted on 'X'
        PostingDate := CalcDate('<' + Format(LibraryRandom.RandInt(5)) + 'Y>', WorkDate());
        DocumentNo := LibraryIntrastat.CreateAndPostSalesInvoiceWithItemAndItemCharge(PostingDate);
        // [GIVEN] Sales Credit Memo with Item Charge posted on 'Y'='X'+<1M>
        PostingDate := CalcDate('<1M>', PostingDate);
        DocumentNo := LibraryIntrastat.CreateAndPostSalesCrMemoForItemCharge(DocumentNo, PostingDate);

        // [WHEN] Get Intrastat Entries 
        CreateIntrastatReportAndSuggestLines(PostingDate, IntrastatReportNo);

        // [THEN] Intrastat line for Item Charge from Sales Credit Memo does not exist        
        VerifyIntrastatReportLineExist(IntrastatReportNo, DocumentNo, false);
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler,NoLinesMsgHandler')]
    [Scope('OnPrem')]
    procedure IntrastatReportWithItemChargeInvoiced()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        PostingDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [SCENARIO 286107] Item Charge entry posted by Sales Invoice must not be reportedin Intrastat Report
        Initialize();

        // [GIVEN] Item Ledger Entry with Quantity < 0
        PostingDate := CalcDate('<' + Format(LibraryRandom.RandInt(5)) + 'Y>', WorkDate());
        LibraryIntrastat.CreateItemLedgerEntry(
          ItemLedgerEntry,
          PostingDate,
          LibraryInventory.CreateItemNo(),
          -LibraryRandom.RandInt(100),
          ItemLedgerEntry."Entry Type"::Sale);
        // [GIVEN] Value Entry with "Document Type" != "Sales Credit Memo" and "Item Charge No" posted in <1M>
        PostingDate := CalcDate('<1M>', PostingDate);

        LibraryIntrastat.CreateValueEntry(ValueEntry, ItemLedgerEntry, ValueEntry."Document Type"::"Sales Invoice", PostingDate);

        // [WHEN] Get Intrastat Entries on second posting date
        CreateIntrastatReportAndSuggestLines(PostingDate, IntrastatReportNo);

        // [THEN] Intrastat line for Item Charge from Sales Credit Memo does not exist        
        VerifyIntrastatReportLineExist(IntrastatReportNo, '', false);
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler,NoLinesMsgHandler')]
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
        LibraryIntrastat.CreateItemLedgerEntry(
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
        LibraryIntrastat.CreateCountryRegion(CountryRegion, true);
        ItemNo := LibraryIntrastat.CreateItem();
        LibraryIntrastat.CreateFromToLocations(Location, LocationEU, CountryRegion.Code);
        LibraryIntrastat.CreateAndPostPurchaseItemJournalLine(Location.Code, ItemNo);
        LibraryIntrastat.CreateAndPostSalesOrderWithCountryAndLocation(CountryRegion.Code, Location.Code, ItemNo);
        // [GIVEN] Posted transfer order with blank transit location.
        LibraryIntrastat.CreateAndPostTransferOrder(TransferLine, Location.Code, LocationEU.Code, ItemNo);

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
        LibraryIntrastat.UpdateShipmentOnInvoiceSalesSetup(false);

        // [GIVEN] Sell-to Customer with VAT Registration No = 'AT0123456'
        // [GIVEN] Bill-to Customer with VAT Registration No = 'DE1234567'
        // [GIVEN] Sales Invoice with different Sell-to and Bill-To customers
        SellToCustomer.Get(LibraryIntrastat.CreateCustomerWithVATRegNo(true));
        BillToCustomer.Get(LibraryIntrastat.CreateCustomerWithVATRegNo(true));
        LibraryIntrastat.CreateSalesDocument(
            SalesHeader, SalesLine, SellToCustomer."No.", WorkDate(), SalesLine."Document Type"::Invoice,
            SalesLine.Type::Item, LibraryIntrastat.CreateItem(), 1);
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
        LibraryIntrastat.UpdateShipmentOnInvoiceSalesSetup(true);

        // [GIVEN] Sell-to Customer with VAT Registration No = 'AT0123456'
        // [GIVEN] Bill-to Customer with VAT Registration No = 'DE1234567'
        // [GIVEN] Sales Invoice with different Sell-to and Bill-To customers
        SellToCustomer.Get(LibraryIntrastat.CreateCustomerWithVATRegNo(true));
        BillToCustomer.Get(LibraryIntrastat.CreateCustomerWithVATRegNo(true));
        LibraryIntrastat.CreateSalesDocument(
             SalesHeader, SalesLine, SellToCustomer."No.", WorkDate(), SalesLine."Document Type"::Invoice,
             SalesLine.Type::Item, LibraryIntrastat.CreateItem(), 1);
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
        LibraryIntrastat.UpdateRetShpmtOnCrMemoPurchSetup(false);

        // [GIVEN] Pay-to Vendor with VAT Registration No = 'AT0123456'
        Vendor.Get(LibraryIntrastat.CreateVendorWithVATRegNo(true));
        LibraryIntrastat.CreatePurchaseHeader(PurchaseHeader, PurchaseHeader."Document Type"::"Credit Memo", WorkDate(), Vendor."No.");
        LibraryIntrastat.CreatePurchaseLine(PurchaseHeader, PurchaseLine, PurchaseLine.Type::Item, LibraryIntrastat.CreateItem());
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
        LibraryIntrastat.UpdateRetShpmtOnCrMemoPurchSetup(true);

        // [GIVEN] Pay-to Vendor with VAT Registration No = 'AT0123456'
        Vendor.Get(LibraryIntrastat.CreateVendorWithVATRegNo(true));
        LibraryIntrastat.CreatePurchaseHeader(PurchaseHeader, PurchaseHeader."Document Type"::"Credit Memo", WorkDate(), Vendor."No.");
        LibraryIntrastat.CreatePurchaseLine(PurchaseHeader, PurchaseLine, PurchaseLine.Type::Item, LibraryIntrastat.CreateItem());
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
        VendorNo: Code[20];
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Purchase] [Receipt]
        // [SCENARIO 389253] Partner VAT ID is blank for Purchase Receipt
        Initialize();

        // [GIVEN] Posted purchase order with Pay-to Vendor with VAT Registration No = 'AT0123456'
        VendorNo := LibraryIntrastat.CreateVendorWithVATRegNo(true);
        LibraryIntrastat.CreatePurchaseHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, WorkDate(), VendorNo);
        LibraryIntrastat.CreatePurchaseLine(PurchaseHeader, PurchaseLine, PurchaseLine.Type::Item, LibraryIntrastat.CreateItem());
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [WHEN] Intrastat Report Line is created
        CreateIntrastatReportAndSuggestLines(WorkDate(), IntrastatReportNo);
        IntrastatReportHeader.Get(IntrastatReportNo);

        // [THEN] Partner VAT ID  = '' in Intrastat Report Line
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
        Initialize();
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
        Initialize();
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
        Initialize();
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
        DocumentNo := LibraryIntrastat.CreateAndPostFixedAssetPurchaseOrder(PurchaseLine, WorkDate());
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
        DocumentNo := LibraryIntrastat.CreateAndPostFixedAssetPurchaseOrder(PurchaseLine, WorkDate());
        // [GIVEN] Create and Post Disposal Sales Order
        DocumentNo := LibraryIntrastat.CreateAndPostSalesDocumentMultiLine(
            SalesLine, SalesHeader."Document Type"::Order, WorkDate(), SalesLine.Type::"Fixed Asset", PurchaseLine."No.", 1);

        // [WHEN] Get Intrastat Report Lines for Sales Order
        // [THEN] Verify Intrastat Report Line
        CreateAndVerifyIntrastatLine(DocumentNo, SalesLine."No.", SalesLine.Quantity, IntrastatReportLine.Type::Shipment);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('MessageHandlerEmpty,IntrastatReportGetLinesPageHandler')]
    procedure VerifyIntrastatShptInDirectTransfer()
    var
        ToCountryRegion: Record "Country/Region";
        FromLocation, ToLocation : Record Location;
        InventorySetup: Record "Inventory Setup";
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        IntrastatReportLine: Record "Intrastat Report Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        TransferOrder: TestPage "Transfer Order";
        ItemNo: Code[20];
    begin
        // [SCENARIO 465378] Verify shipment transaction in Intrastat Journal when transferring items from company country to EU country as Direct Transfer
        Initialize();

        // [GIVEN] Source Location and Country, set in Company Information, with Intrastat Code. Location: "L1". Country "C1"
        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(FromLocation);
        FromLocation."Country/Region Code" := LibraryIntrastat.GetCompanyInfoCountryRegionCode();
        FromLocation.Modify();

        // [GIVEN] Item on inventory for L1 
        ItemNo := LibraryIntrastat.CreateItem();
        LibraryIntrastat.CreateAndPostPurchaseItemJournalLine(FromLocation.Code, ItemNo);

        // [GIVEN] Destination Location and Country with Intrastat Code. Location: "L2". Country "C2"
        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(ToLocation);
        LibraryIntrastat.CreateCountryRegion(ToCountryRegion, true);
        ToLocation."Country/Region Code" := ToCountryRegion.Code;
        ToLocation.Modify();

        // [GIVEN] Inventory Setup with "Direct Transfer" as "Direct Transfer Posting"
        InventorySetup.Get();
        InventorySetup."Direct Transfer Posting" := InventorySetup."Direct Transfer Posting"::"Direct Transfer";
        InventorySetup.Modify();

        // [GIVEN] Create Transfer Order
        LibraryWarehouse.CreateTransferHeader(TransferHeader, FromLocation.Code, ToLocation.Code, '');
        TransferHeader.Validate("Direct Transfer", true);
        LibraryWarehouse.CreateTransferLine(TransferHeader, TransferLine, ItemNo, 1);

        // [GIVEN] Post Transfer Order
        TransferOrder.OpenEdit();
        TransferOrder.GoToRecord(TransferHeader);
        TransferOrder.Post.Invoke();

        // [WHEN] Get Intrastat Report Lines for direct transfer
        // [THEN] Verify Shipment Intrastat Report Line is created on source location and destination country
        ItemLedgerEntry.SetCurrentKey("Item No.", "Posting Date");
        ItemLedgerEntry.SetRange("Item No.", ItemNo);
        ItemLedgerEntry.SetRange("Posting Date", WorkDate());
        ItemLedgerEntry.SetRange("Document Type", ItemLedgerEntry."Document Type"::"Direct Transfer");
        ItemLedgerEntry.SetLoadFields("Document No.");
        ItemLedgerEntry.FindFirst();

        CreateAndVerifyIntrastatLine(ItemLedgerEntry."Document No.", ItemNo, 1, IntrastatReportLine.Type::Shipment, ToCountryRegion.Code, FromLocation.Code);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('MessageHandlerEmpty,IntrastatReportGetLinesPageHandler')]
    procedure VerifyIntrastatRcptInDirectTransfer()
    var
        FromCountryRegion: Record "Country/Region";
        FromLocation, ToLocation : Record Location;
        InventorySetup: Record "Inventory Setup";
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        IntrastatReportLine: Record "Intrastat Report Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        TransferOrder: TestPage "Transfer Order";
        ItemNo: Code[20];
    begin
        // [SCENARIO 465378] Verify receipt transaction in Intrastat Journal when transferring items from EU country to company country as Direct Transfer    

        // [GIVEN]
        // Source Location and Country with Intrastat Code. Location: "L1". Country "C1"
        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(FromLocation);
        LibraryIntrastat.CreateCountryRegion(FromCountryRegion, true);
        FromLocation."Country/Region Code" := FromCountryRegion.Code;
        FromLocation.Modify();

        // [GIVEN] Item on inventory for L1 
        ItemNo := LibraryIntrastat.CreateItem();
        LibraryIntrastat.CreateAndPostPurchaseItemJournalLine(FromLocation.Code, ItemNo);

        // Destination Country, set in Company Information, with Intrastat Code. Location: "L2". Country "C2"
        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(ToLocation);
        ToLocation."Country/Region Code" := LibraryIntrastat.GetCompanyInfoCountryRegionCode();
        ToLocation.Modify();

        // [GIVEN] Inventory Setup with "Direct Transfer" as "Direct Transfer Posting"
        InventorySetup.Get();
        InventorySetup."Direct Transfer Posting" := InventorySetup."Direct Transfer Posting"::"Direct Transfer";
        InventorySetup.Modify();

        // [GIVEN] Create Transfer Order
        LibraryWarehouse.CreateTransferHeader(TransferHeader, FromLocation.Code, ToLocation.Code, '');
        TransferHeader.Validate("Direct Transfer", true);
        LibraryWarehouse.CreateTransferLine(TransferHeader, TransferLine, ItemNo, 1);

        // [GIVEN] Post Transfer Order
        TransferOrder.OpenEdit();
        TransferOrder.GoToRecord(TransferHeader);
        TransferOrder.Post.Invoke();

        // [WHEN] Get Intrastat Report Lines for direct transfer
        // [THEN] Verify Receipt Intrastat Report Line is created on destination location and source country
        ItemLedgerEntry.SetCurrentKey("Item No.", "Posting Date");
        ItemLedgerEntry.SetRange("Item No.", ItemNo);
        ItemLedgerEntry.SetRange("Posting Date", WorkDate());
        ItemLedgerEntry.SetRange("Document Type", ItemLedgerEntry."Document Type"::"Direct Transfer");
        ItemLedgerEntry.SetLoadFields("Document No.");
        ItemLedgerEntry.FindFirst();

        CreateAndVerifyIntrastatLine(ItemLedgerEntry."Document No.", ItemNo, 1, IntrastatReportLine.Type::Receipt, FromCountryRegion.Code, ToLocation.Code);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('MessageHandlerEmpty,IntrastatReportGetLinesPageHandler')]
    procedure VerifyIntrastatShptInDirectTransferRcptAndShpt()
    var
        ToCountryRegion: Record "Country/Region";
        FromLocation, ToLocation : Record Location;
        InventorySetup: Record "Inventory Setup";
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        IntrastatReportLine: Record "Intrastat Report Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        TransferOrder: TestPage "Transfer Order";
        ItemNo, OrderNo : Code[20];
    begin
        // [SCENARIO 465378] Verify shipment transaction in Intrastat Journal when transferring items from company country to EU country as Direct Transfer Ship and Receive

        // [GIVEN] Source Location and Country, set in Company Information, with Intrastat Code. Location: "L1". Country "C1"
        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(FromLocation);
        FromLocation."Country/Region Code" := LibraryIntrastat.GetCompanyInfoCountryRegionCode();
        FromLocation.Modify();

        // [GIVEN] Item on inventory for L1 
        ItemNo := LibraryIntrastat.CreateItem();
        LibraryIntrastat.CreateAndPostPurchaseItemJournalLine(FromLocation.Code, ItemNo);

        // [GIVEN] Destination Location and Country with Intrastat Code. Location: "L2". Country "C2"
        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(ToLocation);
        LibraryIntrastat.CreateCountryRegion(ToCountryRegion, true);
        ToLocation."Country/Region Code" := ToCountryRegion.Code;
        ToLocation.Modify();

        // [GIVEN] Inventory Setup with "Receipt and Shipment" as "Direct Transfer Posting"
        InventorySetup.Get();
        InventorySetup."Direct Transfer Posting" := InventorySetup."Direct Transfer Posting"::"Receipt and Shipment";
        InventorySetup.Modify();

        // [GIVEN] Create Transfer Order
        LibraryWarehouse.CreateTransferHeader(TransferHeader, FromLocation.Code, ToLocation.Code, '');
        TransferHeader.Validate("Direct Transfer", true);
        LibraryWarehouse.CreateTransferLine(TransferHeader, TransferLine, ItemNo, 1);
        OrderNo := TransferHeader."No.";

        // [GIVEN] Post Transfer Order
        TransferOrder.OpenEdit();
        TransferOrder.GoToRecord(TransferHeader);
        TransferOrder.Post.Invoke();

        // [WHEN] Get Intrastat Report Lines for direct transfer with shipment and receipt
        // [THEN] Verify Shipment Intrastat Report Line is created on unknown location and destination country
        ItemLedgerEntry.SetCurrentKey("Item No.", "Posting Date");
        ItemLedgerEntry.SetRange("Item No.", ItemNo);
        ItemLedgerEntry.SetRange("Posting Date", WorkDate());
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Transfer);
        ItemLedgerEntry.SetRange("Order No.", OrderNo);
        ItemLedgerEntry.SetLoadFields("Document No.");
        ItemLedgerEntry.FindLast();

        CreateAndVerifyIntrastatLine(ItemLedgerEntry."Document No.", ItemNo, 1, IntrastatReportLine.Type::Shipment, ToCountryRegion.Code, '');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('MessageHandlerEmpty,IntrastatReportGetLinesPageHandler')]
    procedure VerifyIntrastatRcptInDirectTransferRcptAndShpt()
    var
        FromCountryRegion: Record "Country/Region";
        FromLocation, ToLocation : Record Location;
        InventorySetup: Record "Inventory Setup";
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        IntrastatReportLine: Record "Intrastat Report Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        TransferOrder: TestPage "Transfer Order";
        ItemNo, OrderNo : Code[20];
    begin
        // [SCENARIO 465378] Verify receipt transaction in Intrastat Journal when transferring items from EU country to company country as Direct Transfer Ship and Receive    

        // [GIVEN]
        // Source Location and Country with Intrastat Code. Location: "L1". Country "C1"
        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(FromLocation);
        LibraryIntrastat.CreateCountryRegion(FromCountryRegion, true);
        FromLocation."Country/Region Code" := FromCountryRegion.Code;
        FromLocation.Modify();

        // [GIVEN] Item on inventory for L1 
        ItemNo := LibraryIntrastat.CreateItem();
        LibraryIntrastat.CreateAndPostPurchaseItemJournalLine(FromLocation.Code, ItemNo);

        // Destination Country, set in Company Information, with Intrastat Code. Location: "L2". Country "C2"
        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(ToLocation);
        ToLocation."Country/Region Code" := LibraryIntrastat.GetCompanyInfoCountryRegionCode();
        ToLocation.Modify();

        // [GIVEN] Inventory Setup with "Receipt and Shipment" as "Direct Transfer Posting"
        InventorySetup.Get();
        InventorySetup."Direct Transfer Posting" := InventorySetup."Direct Transfer Posting"::"Receipt and Shipment";
        InventorySetup.Modify();

        // [GIVEN] Create Transfer Order
        LibraryWarehouse.CreateTransferHeader(TransferHeader, FromLocation.Code, ToLocation.Code, '');
        TransferHeader.Validate("Direct Transfer", true);
        LibraryWarehouse.CreateTransferLine(TransferHeader, TransferLine, ItemNo, 1);
        OrderNo := TransferHeader."No.";

        // [GIVEN] Post Transfer Order
        TransferOrder.OpenEdit();
        TransferOrder.GoToRecord(TransferHeader);
        TransferOrder.Post.Invoke();

        // [WHEN] Get Intrastat Report Lines for direct transfer with shipment and receipt
        // [THEN] Verify Receipt Intrastat Report Line is created on unknown location and source country
        ItemLedgerEntry.SetCurrentKey("Item No.", "Posting Date");
        ItemLedgerEntry.SetRange("Item No.", ItemNo);
        ItemLedgerEntry.SetRange("Posting Date", WorkDate());
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Transfer);
        ItemLedgerEntry.SetRange("Order No.", OrderNo);
        ItemLedgerEntry.SetLoadFields("Document No.");
        ItemLedgerEntry.FindFirst();

        CreateAndVerifyIntrastatLine(ItemLedgerEntry."Document No.", ItemNo, 1, IntrastatReportLine.Type::Receipt, FromCountryRegion.Code, '');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    procedure VerifyIntrastatShptInTransferRcptAndShpt()
    var
        ToCountryRegion: Record "Country/Region";
        InTransitLocation, FromLocation, ToLocation : Record Location;
        InventorySetup: Record "Inventory Setup";
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        IntrastatReportLine: Record "Intrastat Report Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemNo, OrderNo : Code[20];
    begin
        // [SCENARIO 465378] Verify shipment transaction in Intrastat Journal when transferring items from company country to EU country as Ship and Receive

        // [GIVEN] Source Location and Country, set in Company Information, with Intrastat Code. Location: "L1". Country "C1"
        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(FromLocation);
        FromLocation."Country/Region Code" := LibraryIntrastat.GetCompanyInfoCountryRegionCode();
        FromLocation.Modify();

        // [GIVEN] Item on inventory for L1 
        ItemNo := LibraryIntrastat.CreateItem();
        LibraryIntrastat.CreateAndPostPurchaseItemJournalLine(FromLocation.Code, ItemNo);

        // [GIVEN] Destination Location and Country with Intrastat Code. Location: "L2". Country "C2"
        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(ToLocation);
        LibraryIntrastat.CreateCountryRegion(ToCountryRegion, true);
        ToLocation."Country/Region Code" := ToCountryRegion.Code;
        ToLocation.Modify();

        // [GIVEN] In Transit Location
        LibraryWarehouse.CreateInTransitLocation(InTransitLocation);

        // [GIVEN] Inventory Setup with "Receipt and Shipment" as "Direct Transfer Posting"
        InventorySetup.Get();
        InventorySetup."Direct Transfer Posting" := InventorySetup."Direct Transfer Posting"::"Receipt and Shipment";
        InventorySetup.Modify();

        // [GIVEN] Create Transfer Order
        LibraryWarehouse.CreateTransferHeader(TransferHeader, FromLocation.Code, ToLocation.Code, InTransitLocation.Code);
        LibraryWarehouse.CreateTransferLine(TransferHeader, TransferLine, ItemNo, 1);
        OrderNo := TransferHeader."No.";

        // [GIVEN] Post Transfer Order
        LibraryWarehouse.PostTransferOrder(TransferHeader, true, true);

        // [WHEN] Get Intrastat Report Lines for transfer shipment and receipt
        // [THEN] Verify Shipment Intrastat Report Line is created on in-transit location and destination country
        ItemLedgerEntry.SetCurrentKey("Item No.", "Posting Date");
        ItemLedgerEntry.SetRange("Item No.", ItemNo);
        ItemLedgerEntry.SetRange("Posting Date", WorkDate());
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Transfer);
        ItemLedgerEntry.SetRange("Order No.", OrderNo);
        ItemLedgerEntry.SetLoadFields("Document No.");
        ItemLedgerEntry.FindLast();

        CreateAndVerifyIntrastatLine(ItemLedgerEntry."Document No.", ItemNo, 1, IntrastatReportLine.Type::Shipment, ToCountryRegion.Code, InTransitLocation.Code);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    procedure VerifyIntrastatRcptInTransferRcptAndShpt()
    var
        FromCountryRegion: Record "Country/Region";
        InTransitLocation, FromLocation, ToLocation : Record Location;
        InventorySetup: Record "Inventory Setup";
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        IntrastatReportLine: Record "Intrastat Report Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemNo, OrderNo : Code[20];
    begin
        // [SCENARIO 465378] Verify receipt transaction in Intrastat Journal when transferring items from EU country to company country as Ship and Receive 

        // [GIVEN]
        // Source Location and Country with Intrastat Code. Location: "L1". Country "C1"
        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(FromLocation);
        LibraryIntrastat.CreateCountryRegion(FromCountryRegion, true);
        FromLocation."Country/Region Code" := FromCountryRegion.Code;
        FromLocation.Modify();

        // [GIVEN] Item on inventory for L1 
        ItemNo := LibraryIntrastat.CreateItem();
        LibraryIntrastat.CreateAndPostPurchaseItemJournalLine(FromLocation.Code, ItemNo);

        // Destination Country, set in Company Information, with Intrastat Code. Location: "L2". Country "C2"
        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(ToLocation);
        ToLocation."Country/Region Code" := LibraryIntrastat.GetCompanyInfoCountryRegionCode();
        ToLocation.Modify();

        // [GIVEN] In Transit Location
        LibraryWarehouse.CreateInTransitLocation(InTransitLocation);

        // [GIVEN] Inventory Setup with "Receipt and Shipment" as "Direct Transfer Posting"
        InventorySetup.Get();
        InventorySetup."Direct Transfer Posting" := InventorySetup."Direct Transfer Posting"::"Receipt and Shipment";
        InventorySetup.Modify();

        // [GIVEN] Create Transfer Order
        LibraryWarehouse.CreateTransferHeader(TransferHeader, FromLocation.Code, ToLocation.Code, InTransitLocation.Code);
        LibraryWarehouse.CreateTransferLine(TransferHeader, TransferLine, ItemNo, 1);
        OrderNo := TransferHeader."No.";

        // [GIVEN] Post Transfer Order
        LibraryWarehouse.PostTransferOrder(TransferHeader, true, true);

        // [WHEN] Get Intrastat Report Lines for transfer shipment and receipt
        // [THEN] Verify Receipt Intrastat Report Line is created on in-transit location and source country
        ItemLedgerEntry.SetCurrentKey("Item No.", "Posting Date");
        ItemLedgerEntry.SetRange("Item No.", ItemNo);
        ItemLedgerEntry.SetRange("Posting Date", WorkDate());
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Transfer);
        ItemLedgerEntry.SetRange("Order No.", OrderNo);
        ItemLedgerEntry.SetLoadFields("Document No.");
        ItemLedgerEntry.FindFirst();

        CreateAndVerifyIntrastatLine(ItemLedgerEntry."Document No.", ItemNo, 1, IntrastatReportLine.Type::Receipt, FromCountryRegion.Code, InTransitLocation.Code);
    end;

    [Test]
    [HandlerFunctions('SalesListModalPageHandler,IntrastatReportGetLinesPageHandler,NoLinesMsgHandler')]
    [Scope('OnPrem')]
    procedure IntraCommunityEUSales()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PurchaseHeader: Record "Purchase Header";
        IntrastatReportLine: Record "Intrastat Report Line";
        IntrastatReportSetup: Record "Intrastat Report Setup";
        SalesShipmentNo: Code[20];
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 443883] Drop shipment Intra-Community sales entry created in the Intrastat Report by Get Entries function
        Initialize();

        // [GIVEN] Drop shipment sales order for customer with EU country "C1"
        LibraryIntrastat.CreateSalesOrdersWithDropShipment(SalesHeader, true);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.FindFirst();

        // [GIVEN] Drop shipment purchase order for local vendor
        LibraryIntrastat.CreatePurchOrdersWithDropShipment(PurchaseHeader, SalesHeader."Sell-to Customer No.", false);

        // [GIVEN] Post sales order
        SalesShipmentNo := LibrarySales.PostSalesDocument(SalesHeader, true, false);

        // [WHEN] do not include drop shipment
        IntrastatReportSetup.Get();
        IntrastatReportSetup."Include Drop Shipment" := false;
        IntrastatReportSetup.Modify();

        // [THEN] no lines created
        GetEntriesAndVerifyNoItemLine(SalesShipmentNo);

        // [WHEN] include drop shipment
        IntrastatReportSetup."Include Drop Shipment" := true;
        IntrastatReportSetup.Modify();

        // [THEN] check line created
        CreateAndVerifyIntrastatLine(SalesShipmentNo, SalesLine."No.", SalesLine.Quantity, IntrastatReportLine.Type::Shipment);

        IntrastatReportSetup."Include Drop Shipment" := false;
        IntrastatReportSetup.Modify();
    end;

    [Test]
    [HandlerFunctions('SalesListModalPageHandler,IntrastatReportGetLinesPageHandler,NoLinesMsgHandler')]
    [Scope('OnPrem')]
    procedure IntraCommunityEUPurchase()
    var
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        IntrastatReportLine: Record "Intrastat Report Line";
        IntrastatReportSetup: Record "Intrastat Report Setup";
        PurchReceiptNo: Code[20];
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 443883] Drop shipment Intra-Community purchase entry created in the Intrastat Report by Get Entries function
        Initialize();

        // [GIVEN] Drop shipment sales order for local customer 
        LibraryIntrastat.CreateSalesOrdersWithDropShipment(SalesHeader, false);

        // [GIVEN] Drop shipment purchase order for vendor with EU country "C2"
        LibraryIntrastat.CreatePurchOrdersWithDropShipment(PurchaseHeader, SalesHeader."Sell-to Customer No.", true);

        // [GIVEN] Post sales order
        LibrarySales.PostSalesDocument(SalesHeader, true, false);

        // [GIVEN] Post purchase order
        PurchaseHeader.Find();
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.FindFirst();

        PurchReceiptNo := PurchaseHeader."Last Receiving No.";

        // [WHEN] do not include drop shipment
        IntrastatReportSetup.Get();
        IntrastatReportSetup."Include Drop Shipment" := false;
        IntrastatReportSetup.Modify();

        // [THEN] no lines created
        GetEntriesAndVerifyNoItemLine(PurchReceiptNo);

        // [WHEN] include drop shipment
        IntrastatReportSetup."Include Drop Shipment" := true;
        IntrastatReportSetup.Modify();

        // [THEN] check line created
        CreateAndVerifyIntrastatLine(PurchReceiptNo, PurchaseLine."No.", PurchaseLine.Quantity, IntrastatReportLine.Type::Receipt);

        IntrastatReportSetup."Include Drop Shipment" := false;
        IntrastatReportSetup.Modify();
    end;

    [Test]
    [HandlerFunctions('SalesListModalPageHandler,IntrastatReportGetLinesPageHandler,NoLinesMsgHandler')]
    [Scope('OnPrem')]
    procedure IntraCommunityLocalSales()
    var
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        IntrastatReportSetup: Record "Intrastat Report Setup";
        SalesShipmentNo: Code[20];
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 443883] Drop shipment Intra-Community sales entry created in the Intrastat Report by Get Entries function
        Initialize();

        // [GIVEN] Drop shipment sales order for local customer
        LibraryIntrastat.CreateSalesOrdersWithDropShipment(SalesHeader, false);

        // [GIVEN] Drop shipment purchase order for local vendor
        LibraryIntrastat.CreatePurchOrdersWithDropShipment(PurchaseHeader, SalesHeader."Sell-to Customer No.", false);

        // [GIVEN] Post sales order
        SalesShipmentNo := LibrarySales.PostSalesDocument(SalesHeader, true, false);

        // [WHEN] do not include drop shipment
        IntrastatReportSetup.Get();
        IntrastatReportSetup."Include Drop Shipment" := false;
        IntrastatReportSetup.Modify();

        // [THEN] no lines created
        GetEntriesAndVerifyNoItemLine(SalesShipmentNo);

        // [WHEN] include drop shipment
        IntrastatReportSetup."Include Drop Shipment" := true;
        IntrastatReportSetup.Modify();

        // [THEN] no lines created
        GetEntriesAndVerifyNoItemLine(SalesShipmentNo);

        IntrastatReportSetup."Include Drop Shipment" := false;
        IntrastatReportSetup.Modify();
    end;

    [Test]
    [HandlerFunctions('SalesListModalPageHandler,IntrastatReportGetLinesPageHandler,NoLinesMsgHandler')]
    [Scope('OnPrem')]
    procedure IntraCommunityLocalPurchase()
    var
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        IntrastatReportSetup: Record "Intrastat Report Setup";
        PurchReceiptNo: Code[20];
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 443883] Drop shipment Intra-Community purchase entry created in the Intrastat Report by Get Entries function
        Initialize();

        // [GIVEN] Drop shipment sales order for local customer 
        LibraryIntrastat.CreateSalesOrdersWithDropShipment(SalesHeader, false);

        // [GIVEN] Drop shipment purchase order for local vendor 
        LibraryIntrastat.CreatePurchOrdersWithDropShipment(PurchaseHeader, SalesHeader."Sell-to Customer No.", false);

        // [GIVEN] Post sales order
        LibrarySales.PostSalesDocument(SalesHeader, true, false);

        // [GIVEN] Post purchase order
        PurchaseHeader.Find();
        PurchReceiptNo := PurchaseHeader."Last Receiving No.";

        // [WHEN] do not include drop shipment
        IntrastatReportSetup.Get();
        IntrastatReportSetup."Include Drop Shipment" := false;
        IntrastatReportSetup.Modify();

        // [THEN] no lines created
        GetEntriesAndVerifyNoItemLine(PurchReceiptNo);

        // [WHEN] include drop shipment
        IntrastatReportSetup."Include Drop Shipment" := true;
        IntrastatReportSetup.Modify();

        // [THEN] no lines created
        GetEntriesAndVerifyNoItemLine(PurchReceiptNo);

        IntrastatReportSetup."Include Drop Shipment" := false;
        IntrastatReportSetup.Modify();
    end;

    [Test]
    [HandlerFunctions('SalesListModalPageHandler,IntrastatReportGetLinesPageHandler,NoLinesMsgHandler')]
    [Scope('OnPrem')]
    procedure IntraCommunityForeingSales()
    var
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        IntrastatReportSetup: Record "Intrastat Report Setup";
        SalesShipmentNo: Code[20];
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 443883] Drop shipment Intra-Community sales entry created in the Intrastat Report by Get Entries function
        Initialize();

        // [GIVEN] Drop shipment sales order for customer with EU country "C1" and item "Item"
        LibraryIntrastat.CreateSalesOrdersWithDropShipment(SalesHeader, true);

        // [GIVEN] Drop shipment purchase order for EU vendor
        LibraryIntrastat.CreatePurchOrdersWithDropShipment(PurchaseHeader, SalesHeader."Sell-to Customer No.", true);

        // [GIVEN] Post sales order
        SalesShipmentNo := LibrarySales.PostSalesDocument(SalesHeader, true, false);

        // [WHEN] do not include drop shipment
        IntrastatReportSetup.Get();
        IntrastatReportSetup."Include Drop Shipment" := false;
        IntrastatReportSetup.Modify();

        // [THEN] no lines created
        GetEntriesAndVerifyNoItemLine(SalesShipmentNo);

        // [WHEN] include drop shipment
        IntrastatReportSetup."Include Drop Shipment" := true;
        IntrastatReportSetup.Modify();

        // [THEN] no lines created
        GetEntriesAndVerifyNoItemLine(SalesShipmentNo);

        IntrastatReportSetup."Include Drop Shipment" := false;
        IntrastatReportSetup.Modify();
    end;

    [Test]
    [HandlerFunctions('SalesListModalPageHandler,IntrastatReportGetLinesPageHandler,NoLinesMsgHandler')]
    [Scope('OnPrem')]
    procedure IntraCommunityForeingPurchase()
    var
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        IntrastatReportSetup: Record "Intrastat Report Setup";
        PurchReceiptNo: Code[20];
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 443883] Drop shipment Intra-Community purchase entry created in the Intrastat Report by Get Entries function
        Initialize();

        // [GIVEN] Drop shipment sales order for EU customer 
        LibraryIntrastat.CreateSalesOrdersWithDropShipment(SalesHeader, true);

        // [GIVEN] Drop shipment purchase order for vendor with EU country "C2"
        LibraryIntrastat.CreatePurchOrdersWithDropShipment(PurchaseHeader, SalesHeader."Sell-to Customer No.", true);

        // [GIVEN] Post sales order
        LibrarySales.PostSalesDocument(SalesHeader, true, false);

        // [GIVEN] Post purchase order
        PurchaseHeader.Find();
        PurchReceiptNo := PurchaseHeader."Last Receiving No.";

        // [WHEN] do not include drop shipment
        IntrastatReportSetup.Get();
        IntrastatReportSetup."Include Drop Shipment" := false;
        IntrastatReportSetup.Modify();

        // [THEN] no lines created
        GetEntriesAndVerifyNoItemLine(PurchReceiptNo);

        // [WHEN] include drop shipment
        IntrastatReportSetup."Include Drop Shipment" := true;
        IntrastatReportSetup.Modify();

        // [THEN] no lines created
        GetEntriesAndVerifyNoItemLine(PurchReceiptNo);

        IntrastatReportSetup."Include Drop Shipment" := false;
        IntrastatReportSetup.Modify();
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    procedure CheckCountryOfOriginFromItemCard()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        IntrastatReportHeader: Record "Intrastat Report Header";
        SerialNoInformation: Record "Serial No. Information";
        LotNoInformation: Record "Lot No. Information";
        PackageNoInformation: Record "Package No. Information";
        Item: Record Item;
        VendorNo: Code[20];
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Purchase] [Receipt]
        // [SCENARIO 466675] Country of origin is taken from item card
        Initialize();

        // [GIVEN] Posted purchase order with no item tracking
        VendorNo := LibraryIntrastat.CreateVendorWithVATRegNo(true);
        Item.Get(LibraryIntrastat.CreateTrackedItem(0, false, false, SerialNoInformation, LotNoInformation, PackageNoInformation));
        LibraryIntrastat.CreatePurchaseHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, WorkDate(), VendorNo);
        LibraryIntrastat.CreatePurchaseLine(PurchaseHeader, PurchaseLine, PurchaseLine.Type::Item, Item."No.");
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [WHEN] Intrastat Report Line is created
        CreateIntrastatReportAndSuggestLines(WorkDate(), IntrastatReportNo);
        IntrastatReportHeader.Get(IntrastatReportNo);

        // [THEN] Country of Origin  = country of origin in Intrastat Report Line is taken from item
        VerifyCountryOfOrigin(IntrastatReportHeader, PurchaseLine."No.", Item."Country/Region of Origin Code");
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    procedure CheckCountryOfOriginFromSerialInfoManual()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        IntrastatReportHeader: Record "Intrastat Report Header";
        SerialNoInformation: Record "Serial No. Information";
        LotNoInformation: Record "Lot No. Information";
        PackageNoInformation: Record "Package No. Information";
        ResEntry: Record "Reservation Entry";
        Item: Record Item;
        VendorNo: Code[20];
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Purchase] [Receipt]
        // [SCENARIO 466675] Country of origin is taken from serial info
        Initialize();

        // [GIVEN] Posted purchase order with serial no info
        VendorNo := LibraryIntrastat.CreateVendorWithVATRegNo(true);
        Item.Get(LibraryIntrastat.CreateTrackedItem(1, true, false, SerialNoInformation, LotNoInformation, PackageNoInformation));
        LibraryIntrastat.CreatePurchaseHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, WorkDate(), VendorNo);
        LibraryIntrastat.CreatePurchaseLine(PurchaseHeader, PurchaseLine, PurchaseLine.Type::Item, Item."No.");
        PurchaseLine.Validate(Quantity, 1);
        PurchaseLine.Modify(true);
        LibraryItemTracking.CreatePurchOrderItemTracking(ResEntry, PurchaseLine, SerialNoInformation."Serial No.", '', '', PurchaseLine.Quantity);
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [WHEN] Intrastat Report Line is created
        CreateIntrastatReportAndSuggestLines(WorkDate(), IntrastatReportNo);
        IntrastatReportHeader.Get(IntrastatReportNo);

        // [THEN] Country of Origin  = country of origin in Intrastat Report Line is taken from serial no info 
        VerifyCountryOfOrigin(IntrastatReportHeader, PurchaseLine."No.", SerialNoInformation."Country/Region Code");
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    procedure CheckCountryOfOriginFromLotInfoManual()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        IntrastatReportHeader: Record "Intrastat Report Header";
        SerialNoInformation: Record "Serial No. Information";
        LotNoInformation: Record "Lot No. Information";
        PackageNoInformation: Record "Package No. Information";
        ResEntry: Record "Reservation Entry";
        Item: Record Item;
        VendorNo: Code[20];
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Purchase] [Receipt]
        // [SCENARIO 466675] Country of origin is taken from lot info
        Initialize();

        // [GIVEN] Posted purchase order with Lot No Information
        VendorNo := LibraryIntrastat.CreateVendorWithVATRegNo(true);
        Item.Get(LibraryIntrastat.CreateTrackedItem(2, true, false, SerialNoInformation, LotNoInformation, PackageNoInformation));
        LibraryIntrastat.CreatePurchaseHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, WorkDate(), VendorNo);
        LibraryIntrastat.CreatePurchaseLine(PurchaseHeader, PurchaseLine, PurchaseLine.Type::Item, Item."No.");
        LibraryItemTracking.CreatePurchOrderItemTracking(ResEntry, PurchaseLine, '', LotNoInformation."Lot No.", '', PurchaseLine.Quantity);
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [WHEN] Intrastat Report Line is created
        CreateIntrastatReportAndSuggestLines(WorkDate(), IntrastatReportNo);
        IntrastatReportHeader.Get(IntrastatReportNo);

        // [THEN] Country of Origin  = country of origin in Intrastat Report Line is taken from Lot No Info
        VerifyCountryOfOrigin(IntrastatReportHeader, PurchaseLine."No.", LotNoInformation."Country/Region Code");
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    procedure CheckCountryOfOriginFromPackInfoManual()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        IntrastatReportHeader: Record "Intrastat Report Header";
        SerialNoInformation: Record "Serial No. Information";
        LotNoInformation: Record "Lot No. Information";
        PackageNoInformation: Record "Package No. Information";
        ResEntry: Record "Reservation Entry";
        Item: Record Item;
        VendorNo: Code[20];
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Purchase] [Receipt]
        // [SCENARIO 466675] Country of origin is taken from Package info
        Initialize();

        // [GIVEN] Posted purchase order with package no info
        VendorNo := LibraryIntrastat.CreateVendorWithVATRegNo(true);
        Item.Get(LibraryIntrastat.CreateTrackedItem(3, true, false, SerialNoInformation, LotNoInformation, PackageNoInformation));
        LibraryIntrastat.CreatePurchaseHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, WorkDate(), VendorNo);
        LibraryIntrastat.CreatePurchaseLine(PurchaseHeader, PurchaseLine, PurchaseLine.Type::Item, Item."No.");
        LibraryItemTracking.CreatePurchOrderItemTracking(ResEntry, PurchaseLine, '', '', PackageNoInformation."Package No.", PurchaseLine.Quantity);
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [WHEN] Intrastat Report Line is created
        CreateIntrastatReportAndSuggestLines(WorkDate(), IntrastatReportNo);
        IntrastatReportHeader.Get(IntrastatReportNo);

        // [THEN] Country of Origin  = country of origin in Intrastat Report Line is taken from package no info
        VerifyCountryOfOrigin(IntrastatReportHeader, PurchaseLine."No.", PackageNoInformation."Country/Region Code");
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    procedure CheckCountryOfOriginFromSerialInfoAuto()
    var
        CountryRegion: Record "Country/Region";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        IntrastatReportHeader: Record "Intrastat Report Header";
        SerialNoInformation: Record "Serial No. Information";
        LotNoInformation: Record "Lot No. Information";
        PackageNoInformation: Record "Package No. Information";
        ResEntry: Record "Reservation Entry";
        Item: Record Item;
        IntrastatReportSetup: Record "Intrastat Report Setup";
        VendorNo: Code[20];
        IntrastatReportNo: Code[20];
        SerialNo: Code[50];
    begin
        // [FEATURE] [Purchase] [Receipt]
        // [SCENARIO 466675] Country of origin is taken from purchase header into serial info, and intrastat line
        Initialize();

        IntrastatReportSetup.Get();
        IntrastatReportSetup.Validate("Def. Country Code for Item Tr.", IntrastatReportSetup."Def. Country Code for Item Tr."::"Purchase Header");
        IntrastatReportSetup.Modify(true);

        // [GIVEN] Posted purchase order with auto create serial no info, and add country from purchase header
        VendorNo := LibraryIntrastat.CreateVendorWithVATRegNo(true);
        Item.Get(LibraryIntrastat.CreateTrackedItem(1, false, true, SerialNoInformation, LotNoInformation, PackageNoInformation));
        LibraryIntrastat.CreatePurchaseHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, WorkDate(), VendorNo);
        LibraryIntrastat.CreateCountryRegion(CountryRegion, false);
        PurchaseHeader.Validate("Buy-from Country/Region Code", CountryRegion.Code);
        LibraryIntrastat.CreatePurchaseLine(PurchaseHeader, PurchaseLine, PurchaseLine.Type::Item, Item."No.");
        PurchaseLine.Validate(Quantity, 1);
        PurchaseLine.Modify(true);

        SerialNo := LibraryUtility.GenerateRandomCodeWithLength(ResEntry.FieldNo("Serial No."), Database::"Reservation Entry", 50);
        LibraryItemTracking.CreatePurchOrderItemTracking(ResEntry, PurchaseLine, SerialNo, '', '', PurchaseLine.Quantity);
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        SerialNoInformation.Get(PurchaseLine."No.", PurchaseLine."Variant Code", SerialNo);

        // [WHEN] Intrastat Report Line is created
        CreateIntrastatReportAndSuggestLines(WorkDate(), IntrastatReportNo);
        IntrastatReportHeader.Get(IntrastatReportNo);

        // [THEN] Country of Origin  = country of origin in Intrastat Report Line is taken from purchase header (and serial no info)
        VerifyCountryOfOrigin(IntrastatReportHeader, PurchaseLine."No.", SerialNoInformation."Country/Region Code");

        IntrastatReportSetup.Validate("Def. Country Code for Item Tr.", IntrastatReportSetup."Def. Country Code for Item Tr."::" ");
        IntrastatReportSetup.Modify(true);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler')]
    procedure CheckCountryOfOriginFromLotInfoAuto()
    var
        CountryRegion: Record "Country/Region";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        IntrastatReportHeader: Record "Intrastat Report Header";
        SerialNoInformation: Record "Serial No. Information";
        LotNoInformation: Record "Lot No. Information";
        PackageNoInformation: Record "Package No. Information";
        ResEntry: Record "Reservation Entry";
        IntrastatReportSetup: Record "Intrastat Report Setup";
        Item: Record Item;
        VendorNo: Code[20];
        IntrastatReportNo: Code[20];
        LotNo: Code[50];
    begin
        // [FEATURE] [Purchase] [Receipt]
        // [SCENARIO 466675] Country of origin is taken from purchase header into lot info, and intrastat line
        Initialize();
        IntrastatReportSetup.Get();
        IntrastatReportSetup.Validate("Def. Country Code for Item Tr.", IntrastatReportSetup."Def. Country Code for Item Tr."::"Purchase Header");
        IntrastatReportSetup.Modify(true);

        // [GIVEN] Posted purchase order with auto create lot no info, and add country from purchase header
        VendorNo := LibraryIntrastat.CreateVendorWithVATRegNo(true);
        Item.Get(LibraryIntrastat.CreateTrackedItem(2, false, true, SerialNoInformation, LotNoInformation, PackageNoInformation));
        LibraryIntrastat.CreatePurchaseHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, WorkDate(), VendorNo);
        LibraryIntrastat.CreateCountryRegion(CountryRegion, false);
        PurchaseHeader.Validate("Buy-from Country/Region Code", CountryRegion.Code);
        LibraryIntrastat.CreatePurchaseLine(PurchaseHeader, PurchaseLine, PurchaseLine.Type::Item, Item."No.");
        LotNo := LibraryUtility.GenerateRandomCodeWithLength(ResEntry.FieldNo("Lot No."), Database::"Reservation Entry", 50);
        LibraryItemTracking.CreatePurchOrderItemTracking(ResEntry, PurchaseLine, '', LotNo, '', PurchaseLine.Quantity);
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [WHEN] Intrastat Report Line is created
        CreateIntrastatReportAndSuggestLines(WorkDate(), IntrastatReportNo);
        IntrastatReportHeader.Get(IntrastatReportNo);

        LotNoInformation.Get(PurchaseLine."No.", PurchaseLine."Variant Code", LotNo);

        // [THEN] Country of Origin  = country of origin in Intrastat Report Line is taken from purchase header (and lot no info)
        VerifyCountryOfOrigin(IntrastatReportHeader, PurchaseLine."No.", LotNoInformation."Country/Region Code");

        IntrastatReportSetup.Validate("Def. Country Code for Item Tr.", IntrastatReportSetup."Def. Country Code for Item Tr."::" ");
        IntrastatReportSetup.Modify(true);
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
        LibraryIntrastat.UpdateIntrastatCodeInCountryRegion();
        LibraryERMCountryData.CreateVATData();
        LibraryERMCountryData.CreateGeneralPostingSetupData();
        LibraryERMCountryData.UpdateSalesReceivablesSetup();
        LibraryERMCountryData.UpdatePurchasesPayablesSetup();
        LibraryERMCountryData.UpdateGeneralPostingSetup();
        LibraryERM.SetBillToSellToVATCalc(GLSetupVATCalculation::"Bill-to/Pay-to No.");
        LibraryIntrastat.CreateIntrastatReportSetup();
        LibraryIntrastat.CreateIntrastatDataExchangeDefinition();
        CreateIntrastatReportChecklist();

        IsInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"Intrastat Report Test");
    end;

    procedure CreateAndVerifyIntrastatLine(DocumentNo: Code[20]; ItemNo: Code[20]; Quantity: Decimal; IntrastatReportLineType: Enum "Intrastat Report Line Type")
    var
        IntrastatReportNo: Code[20];
    begin
        // Exercise: Run Get Item Entries. Take Report Date as WORKDATE
        CreateIntrastatReportAndSuggestLines(WorkDate(), IntrastatReportNo);

        // Verify.
        VerifyIntrastatReportLine(DocumentNo, IntrastatReportNo, IntrastatReportLineType, LibraryIntrastat.GetCountryRegionCode(), ItemNo, Quantity);
    end;

    procedure CreateAndVerifyIntrastatLine(DocumentNo: Code[20]; ItemNo: Code[20]; Quantity: Decimal; IntrastatReportLineType: Enum "Intrastat Report Line Type"; CountryRegionCode: Code[10]; LocationCode: Code[10])
    var
        IntrastatReportNo: Code[20];
    begin
        // Exercise: Run Get Item Entries. Take Report Date as WORKDATE
        CreateIntrastatReportAndSuggestLines(WorkDate(), IntrastatReportNo);

        // Verify.
        VerifyIntrastatReportLine(DocumentNo, IntrastatReportNo, IntrastatReportLineType, CountryRegionCode, ItemNo, Quantity, LocationCode);
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

    local procedure VerifyIntrastatReportLine(DocumentNo: Code[20]; IntrastatReportNo: Code[20]; Type: Enum "Intrastat Report Line Type"; CountryRegionCode: Code[10];
                                                                                                           ItemNo: Code[20];
                                                                                                           Quantity: Decimal)
    var
        IntrastatReportLine: Record "Intrastat Report Line";
    begin
        LibraryIntrastat.GetIntrastatReportLine(DocumentNo, IntrastatReportNo, IntrastatReportLine);

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
            IntrastatReportLine.FieldCaption("Item No."), ItemNo, IntrastatReportLine.TableCaption()));
    end;

    local procedure VerifyIntrastatReportLine(DocumentNo: Code[20]; IntrastatReportNo: Code[20]; Type: Enum "Intrastat Report Line Type"; CountryRegionCode: Code[10]; ItemNo: Code[20]; Quantity: Decimal; LocationCode: Code[10])
    var
        IntrastatReportLine: Record "Intrastat Report Line";
    begin
        LibraryIntrastat.GetIntrastatReportLine(DocumentNo, IntrastatReportNo, IntrastatReportLine);

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
            IntrastatReportLine.FieldCaption("Item No."), ItemNo, IntrastatReportLine.TableCaption()));

        Assert.AreEqual(
            LocationCode, IntrastatReportLine."Location Code", StrSubstNo(ValidationErr,
            IntrastatReportLine.FieldCaption("Location Code"), LocationCode, IntrastatReportLine.TableCaption()));
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

    local procedure VerifyCountryOfOrigin(IntrastatReportHeader: Record "Intrastat Report Header"; ItemNo: Code[20]; CountryOfOrigin: Code[10])
    var
        IntrastatReportLine: Record "Intrastat Report Line";
    begin
        IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportHeader."No.");
        IntrastatReportLine.SetRange("Item No.", ItemNo);
        IntrastatReportLine.FindFirst();
        IntrastatReportLine.TestField("Country/Region of Origin Code", CountryOfOrigin);
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

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure SalesListModalPageHandler(var SalesList: TestPage "Sales List")
    begin
        SalesList.OK().Invoke();
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure UndoDocumentConfirmHandler(Message: Text[1024]; var Reply: Boolean)
    begin
        // Send Reply = TRUE for Confirmation Message.
        Reply := true;
    end;

    [MessageHandler]
    [Scope('OnPrem')]
    procedure NoLinesMsgHandler(Message: Text[1024])
    begin
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

    local procedure CreateIntrastatReportChecklist()
    var
        IntrastatReportChecklist: Record "Intrastat Report Checklist";
        IntrastatReportLine: Record "Intrastat Report Line";
    begin
        IntrastatReportChecklist.DeleteAll();

        LibraryIntrastat.CreateIntrastatReportChecklistRecord(IntrastatReportLine.FieldNo("Tariff No."), '');
        LibraryIntrastat.CreateIntrastatReportChecklistRecord(IntrastatReportLine.FieldNo("Country/Region Code"), '');
        LibraryIntrastat.CreateIntrastatReportChecklistRecord(IntrastatReportLine.FieldNo("Transaction Type"), '');
        LibraryIntrastat.CreateIntrastatReportChecklistRecord(IntrastatReportLine.FieldNo(Quantity), 'Supplementary Units: True');
        LibraryIntrastat.CreateIntrastatReportChecklistRecord(IntrastatReportLine.FieldNo("Total Weight"), 'Supplementary Units: False');
        LibraryIntrastat.CreateIntrastatReportChecklistRecord(IntrastatReportLine.FieldNo("Country/Region of Origin Code"), 'Type: Shipment');
        LibraryIntrastat.CreateIntrastatReportChecklistRecord(IntrastatReportLine.FieldNo("Partner VAT ID"), 'Type: Shipment');
    end;

    local procedure CheckFileContent(var IntrastatReportPage: TestPage "Intrastat Report")
    var
        DataExch: Record "Data Exch.";
        FileMgt: Codeunit "File Management";
        LibraryTextFileValidation: Codeunit "Library - Text File Validation";
        TempBlob: Codeunit "Temp Blob";
        FileName: Text;
        Line: Text;
        TabChar: Char;
        DecVar: Decimal;
    begin
        DataExch.FindLast();
        if DataExch."File Content".HasValue then begin
            DataExch.CalcFields("File Content");
            TempBlob.FromRecord(DataExch, DataExch.FieldNo("File Content"));

            FileName := FileMgt.ServerTempFileName('txt');
            FileMgt.BLOBExportToServerFile(TempBlob, FileName);

            TabChar := 9;
            Line := LibraryTextFileValidation.ReadLine(FileName, 1);

            IntrastatReportPage.IntrastatLines."Tariff No.".AssertEquals(LibraryTextFileValidation.ReadField(Line, 1, TabChar).Trim());
            IntrastatReportPage.IntrastatLines."Country/Region Code".AssertEquals(LibraryTextFileValidation.ReadField(Line, 2, TabChar).Trim());
            IntrastatReportPage.IntrastatLines."Transaction Type".AssertEquals(LibraryTextFileValidation.ReadField(Line, 3, TabChar).Trim());
            Evaluate(DecVar, LibraryTextFileValidation.ReadField(Line, 4, TabChar).Trim());
            IntrastatReportPage.IntrastatLines.Quantity.AssertEquals(Format(DecVar));
            Evaluate(DecVar, LibraryTextFileValidation.ReadField(Line, 5, TabChar).Trim());
            IntrastatReportPage.IntrastatLines."Total Weight".AssertEquals(Format(DecVar));
            Evaluate(DecVar, LibraryTextFileValidation.ReadField(Line, 6, TabChar).Trim());
            IntrastatReportPage.IntrastatLines."Statistical Value".AssertEquals(Format(DecVar));
            IntrastatReportPage.IntrastatLines."Partner VAT ID".AssertEquals(LibraryTextFileValidation.ReadField(Line, 8, TabChar).Trim());
            IntrastatReportPage.IntrastatLines."Country/Region of Origin Code".AssertEquals(LibraryTextFileValidation.ReadField(Line, 9, TabChar).Trim());
        end;
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
    begin
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure IntrastatReportSetupModalPageHandler(var IntrastatReportSetupPage: TestPage "Intrastat Report Setup")
    begin
    end;
}