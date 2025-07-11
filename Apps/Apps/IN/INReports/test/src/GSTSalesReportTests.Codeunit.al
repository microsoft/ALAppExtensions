codeunit 18046 "GST Sales Report Tests"
{
    Subtype = Test;

    var
        LibrarySales: Codeunit "Library - Sales";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        GSTLibrary: Codeunit "GST Library";
        LibraryRandom: Codeunit "Library - Random";
        Storage: Dictionary of [Text, Code[20]];
        StorageBoolean: Dictionary of [Text, Boolean];
        ComponentPerArray: array[20] of Decimal;
        LocationStateCodeLbl: Label 'LocationStateCode';
        TCSAmtLbl: Label 'TCSAmt';
        LocationCodeLbl: Label 'LocationCode';
        LocPanLbl: Label 'LocPan';
        IGSTAmtLbl: Label 'IGSTAmt';
        LineAmountSalesInvLineLbl: Label 'LineAmount_SalesInvLine';
        CGSTAmtLbl: Label 'CGSTAmt';
        GSTGroupCodeLbl: Label 'GSTGroupCode';
        HSNSACCodeLbl: Label 'HSNSACCode';
        LineAmtSalesLineLbl: Label 'LineAmt_SalesLine';
        LineAmountSalesLineLbl: Label 'LineAmount_SalesLine';
        CGSTLbl: Label 'CGST';
        SGSTLbl: Label 'SGST';
        IGSTLbl: Label 'IGST';
        ExemptedLbl: Label 'Exempted';
        LineDiscountLbl: Label 'LineDiscount';
        FromStateCodeLbl: Label 'FromStateCode';
        CustomerNoLbl: Label 'CustomerNo';
        ToStateCodeLbl: Label 'ToStateCode';
        GLAccNameLbl: Label 'GLAccName';

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure TestSalesInvoiceReportForInterStateTrans()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Test Sales Invoice Report For InterState Transactions
        // [GIVEN] Created GST Setup For Registered Customer For InterState Transactions
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, false);
        InitializeShareStep(false, false);

        // [WHEN] Create and Post Sales Order with GST and Line Type as Goods and Interstate Transactions
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Order);

        // [THEN] GST Amount and TCS Amount Verified on Sales Invoice Report
        VerifyGSTAmountOnPostedInvoiceReport(PostedDocumentNo, false);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure TestSalesInvoiceReportForIntraStateTrans()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Test Sales Invoice Report For IntraState Transactions
        // [GIVEN] Created GST Setup For Registered Customer For IntraState Transactions
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, true);
        InitializeShareStep(false, false);

        // [WHEN] Create and Post Sales Order with GST and Line Type as Goods and Intrastate Transactions
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Order);

        // [THEN] GST Amount and TCS Amount Verified on Sales Invoice Report For IntraState Transactions
        VerifyGSTAmountOnPostedInvoiceReport(PostedDocumentNo, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure TestSalesOrderReportForInterStateTrans()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] Test Sales Order Report For InterState Transactions
        // [GIVEN] Created GST Setup For Registered Customer For InterState Transactions
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, false);
        InitializeShareStep(false, false);

        // [WHEN] Created Sales Order with GST and Line Type as Goods and Interstate Transactions
        DocumentNo := CreateSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Order);

        // [THEN] GST Amount Verified on Sales Order Report
        VerifyGSTAmountOnSalesOrderReport(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure TestReturnOrderReportForInterStateTrans()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] Test Sales Return Order Report For InterState Transactions
        // [GIVEN] Created GST Setup For Registered Customer For InterState Transactions
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, false);
        InitializeShareStep(false, false);

        // [WHEN] Created Sales Return Order with GST and Line Type as Goods and Interstate Transactions
        DocumentNo := CreateSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::"Return Order");

        // [THEN] GST Amount Verified on Sales Return Order Report
        VerifyGSTAmountOnSalesRetOrderReport(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure TestPrintVoucherReportWithIntraStateTrans()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomeType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Test Posted Voucher Report with IntraState Transactions
        // [GIVEN] Created GST Setup For Registered Customer For IntraState Transactions
        CreateGSTSetup(GSTCustomeType::Registered, GSTGroupType::Goods, true);
        InitializeShareStep(false, false);

        // [WHEN] Create and Post Sales Order with GST and Line Type as Goods and Intrastate Transactions
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Order);

        // [THEN] GL Account Name Verified on Posted Voucher Report for Posted Customer Ledger Entry
        VerifyCustomerNameOnPostedVoucherReport(PostedDocumentNo);
    end;

    local procedure VerifyCustomerNameOnPostedVoucherReport(PostedDocumentNo: Code[20])
    var
        SalesInvHeader: Record "Sales Invoice Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GLEntry: Record "G/L Entry";
        Customer: Record Customer;
    begin
        SalesInvHeader.SetRange("No.", PostedDocumentNo);
        if SalesInvHeader.FindFirst() then begin
            CustLedgerEntry.SetRange("Posting Date", SalesInvHeader."Posting Date");
            CustLedgerEntry.SetRange("Document No.", SalesInvHeader."No.");
            if CustLedgerEntry.FindFirst() then begin
                GLEntry.SetCurrentKey("Transaction No.");
                GLEntry.SetRange("Transaction No.", CustLedgerEntry."Transaction No.");
                if GLEntry.FindFirst() then begin
                    LibraryReportDataset.RunReportAndLoad(Report::"Posted Voucher", GLEntry, '');
                    GLEntry.Reset();
                    GLEntry.SetRange("Transaction No.", CustLedgerEntry."Transaction No.");
                    GLEntry.SetRange("Entry No.", CustLedgerEntry."Entry No.");
                    GLEntry.SetRange("Source Type", GLEntry."Source Type"::Customer);
                    if GLEntry.FindFirst() then
                        if Customer.Get(GLEntry."Source No.") then
                            LibraryReportDataset.AssertElementWithValueExists(GLAccNameLbl, Customer.Name);
                end;
            end;
        end;
    end;

    local procedure VerifyGSTAmountOnPostedInvoiceReport(PostedDocumentNo: Code[20]; IntraState: Boolean)
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        SalesInvoiceLine.SetRange("Document No.", PostedDocumentNo);
        SalesInvoiceLine.FindFirst();
        LibraryReportDataset.RunReportAndLoad(Report::"Sales - Invoice IN GST", SalesInvoiceLine, '');
        LibraryReportDataset.AssertElementWithValueExists(LineAmountSalesInvLineLbl, SalesInvoiceLine.Amount);
        LibraryReportDataset.AssertElementWithValueExists(TCSAmtLbl, GetTCSAmtInPostedInvoice(SalesInvoiceLine));
        if IntraState then
            LibraryReportDataset.AssertElementWithValueExists(CGSTAmtLbl, GetGSTAmounts(SalesInvoiceLine))
        else
            LibraryReportDataset.AssertElementWithValueExists(IGSTAmtLbl, GetGSTAmounts(SalesInvoiceLine));
    end;

    local procedure VerifyGSTAmountOnSalesOrderReport(DocumentNo: Code[20])
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document No.", DocumentNo);
        SalesLine.FindFirst();
        LibraryReportDataset.RunReportAndLoad(Report::"Order Confirmation GST", SalesLine, '');
        LibraryReportDataset.AssertElementWithValueExists(LineAmtSalesLineLbl, SalesLine.Amount);
    end;

    local procedure VerifyGSTAmountOnSalesRetOrderReport(DocumentNo: Code[20])
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document No.", DocumentNo);
        SalesLine.FindFirst();
        LibraryReportDataset.RunReportAndLoad(Report::"Return Order Confirmation GST", SalesLine, '');
        LibraryReportDataset.AssertElementWithValueExists(LineAmountSalesLineLbl, SalesLine.Amount);
    end;

    local procedure GetTCSAmtInPostedInvoice(SalesInvoiceLine: Record "Sales Invoice Line"): Decimal
    var
        TCSEntry: Record "TCS Entry";
        TCSAmt: Decimal;
    begin
        TCSEntry.Reset();
        TCSEntry.SetRange("Document No.", SalesInvoiceLine."Document No.");
        if TCSEntry.FindSet() then
            repeat
                TCSAmt += TCSEntry."Total TCS Including SHE CESS";
                TCSAmt := Round(TCSAmt, 1);
            until TCSEntry.Next() = 0;
        exit(TCSAmt);
    end;

    local procedure GetGSTAmounts(SalesInvoiceLine: Record "Sales Invoice Line"): Decimal
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        GSTAmount: Decimal;
    begin
        DetailedGSTLedgerEntry.SetRange("Document No.", SalesInvoiceLine."Document No.");
        DetailedGSTLedgerEntry.FindFirst();

        if SalesInvoiceLine."GST Jurisdiction Type" = SalesInvoiceLine."GST Jurisdiction Type"::Interstate then
            GSTAmount := Round((SalesInvoiceLine.Amount * ComponentPerArray[4]) / 100, GSTLibrary.GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"))
        else
            GSTAmount := Round(SalesInvoiceLine.Amount * ComponentPerArray[1] / 100, GSTLibrary.GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"));
        exit(GSTAmount);
    end;

    local procedure UpdateCustomerSetupWithGST(
        CustomerNo: Code[20];
        GSTCustomerType: Enum "GST Customer Type";
        StateCode: Code[10];
        PANNo: Code[20])
    var
        Customer: Record Customer;
        State: Record State;
    begin
        Customer.Get(CustomerNo);
        if GSTCustomerType <> GSTCustomerType::Export then begin
            State.Get(StateCode);
            Customer.Validate("State Code", StateCode);
            Customer.Validate("P.A.N. No.", PANNo);
            if not ((GSTCustomerType = GSTCustomerType::" ") or (GSTCustomerType = GSTCustomerType::Unregistered)) then
                Customer.Validate("GST Registration No.", GSTLibrary.GenerateGSTRegistrationNo(State."State Code (GST Reg. No.)", PANNo));
        end;

        Customer.Validate(Address, CopyStr(LibraryUtility.GenerateGUID(), 1, MaxStrLen(Customer.Address)));
        Customer.Validate("GST Customer Type", GSTCustomerType);
        if GSTCustomerType = GSTCustomerType::Export then
            Customer.Validate("Currency Code", GSTLibrary.CreateCurrencyCode());
        Customer.Modify(true);
    end;

    [PageHandler]
    procedure TaxRatePageHandler(var TaxRates: TestPage "Tax Rates")
    begin
        TaxRates.New();
        TaxRates.AttributeValue1.SetValue(Storage.Get(GSTGroupCodeLbl));
        TaxRates.AttributeValue2.SetValue(Storage.Get(HSNSACCodeLbl));
        TaxRates.AttributeValue3.SetValue(Storage.Get(FromStateCodeLbl));
        TaxRates.AttributeValue4.SetValue(Storage.Get(ToStateCodeLbl));
        TaxRates.AttributeValue5.SetValue(Today);
        TaxRates.AttributeValue6.SetValue(CalcDate('<10Y>', Today));
        TaxRates.AttributeValue7.SetValue(ComponentPerArray[1]);
        TaxRates.AttributeValue8.SetValue(ComponentPerArray[2]);
        TaxRates.AttributeValue9.SetValue(ComponentPerArray[4]);
        TaxRates.AttributeValue10.SetValue(ComponentPerArray[3]);
        TaxRates.AttributeValue11.SetValue('');
        TaxRates.AttributeValue12.SetValue('');
        TaxRates.OK().Invoke();
    end;

    local procedure CreateGSTSetup(
        GSTCustomerType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        IntraState: Boolean)
    var
        GSTGroup: Record "GST Group";
        HSNSAC: Record "HSN/SAC";
        TaxComponent: Record "Tax Component";
        CompanyInformation: Record "Company information";
        LocationStateCode: Code[10];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        LocPANNo: Code[20];
        HSNSACCode: Code[10];
        GSTGroupCode: Code[20];
        LocationGSTRegNo: Code[15];
        HsnSacType: Enum "GST Goods And Services Type";
        GSTComponentCode: Text[30];
    begin
        CompanyInformation.Get();
        if CompanyInformation."P.A.N. No." = '' then begin
            CompanyInformation."P.A.N. No." := GSTLibrary.CreatePANNos();
            CompanyInformation.Modify();
        end else
            LocPANNo := CompanyInformation."P.A.N. No.";

        LocPANNo := CompanyInformation."P.A.N. No.";
        Storage.Set(LocPanLbl, LocPANNo);

        LocationStateCode := GSTLibrary.CreateInitialSetup();
        Storage.Set(LocationStateCodeLbl, LocationStateCode);

        LocationGSTRegNo := GSTLibrary.CreateGSTRegistrationNos(LocationStateCode, LocPANNo);
        if CompanyInformation."GST Registration No." = '' then begin
            CompanyInformation."GST Registration No." := LocationGSTRegNo;
            CompanyInformation.Modify(true);
        end;

        LocationCode := GSTLibrary.CreateLocationSetup(LocationStateCode, LocationGSTRegNo, false);
        Storage.Set(LocationCodeLbl, LocationCode);

        GSTGroupCode := GSTLibrary.CreateGSTGroup(GSTGroup, GSTGroupType, GSTGroup."GST Place Of Supply"::" ", false);
        Storage.Set(GSTGroupCodeLbl, GSTGroupCode);

        HSNSACCode := GSTLibrary.CreateHSNSACCode(HSNSAC, GSTGroupCode, HsnSacType::HSN);
        Storage.Set(HSNSACCodeLbl, HSNSACCode);

        CustomerNo := GSTLibrary.CreateCustomerSetup();
        Storage.Set(CustomerNoLbl, CustomerNo);

        if IntraState then
            CreateSetupForIntraStateCustomer(GSTCustomerType, true)
        else
            CreateSetupForInterStateCustomer(GSTCustomerType, false);

        CreateGSTComponentAndPostingSetup(IntraState, LocationStateCode, TaxComponent, GSTComponentCode);
        CreateTaxRate();
    end;

    local procedure CreateSetupForIntraStateCustomer(GSTCustomerType: Enum "GST Customer Type"; IntraState: Boolean)
    var
        LocationStateCode: Code[10];
        CustomerNo: Code[20];
        LocPan: Code[20];
    begin
        CustomerNo := Storage.Get(CustomerNoLbl);
        LocationStateCode := (Storage.Get(LocationStateCodeLbl));
        LocPan := Storage.Get(LocPanLbl);
        UpdateCustomerSetupWithGST(CustomerNo, GSTCustomerType, LocationStateCode, LocPan);
        InitializeTaxRateParameters(IntraState, LocationStateCode, LocationStateCode);
    end;

    local procedure CreateSetupForInterStateCustomer(GSTCustomerType: Enum "GST Customer Type"; IntraState: Boolean)
    var
        LocationStateCode: Code[10];
        CustomerStateCode: Code[10];
        CustomerNo: Code[20];
        LocPan: Code[20];
    begin
        CustomerNo := Storage.Get(CustomerNoLbl);
        LocationStateCode := (Storage.Get(LocationStateCodeLbl));
        LocPan := Storage.Get(LocPanLbl);
        CustomerStateCode := GSTLibrary.CreateGSTStateCode();
        UpdateCustomerSetupWithGST(CustomerNo, GSTCustomerType, CustomerStateCode, LocPan);

        if GSTCustomerType in [GSTCustomerType::Export, GSTCustomerType::"SEZ Development", GSTCustomerType::"SEZ Unit"] then
            InitializeTaxRateParameters(IntraState, '', LocationStateCode)
        else
            InitializeTaxRateParameters(IntraState, CustomerStateCode, LocationStateCode);
    end;

    local procedure InitializeShareStep(Exempted: Boolean; LineDiscount: Boolean)
    begin
        StorageBoolean.Set(ExemptedLbl, Exempted);
        StorageBoolean.Set(LineDiscountLbl, LineDiscount);
    end;

    local procedure CreateGSTComponentAndPostingSetup(
        IntraState: Boolean;
        LocationStateCode: Code[10];
        TaxComponent: Record "Tax Component";
        GSTComponentCode: Text[30])
    begin
        if IntraState then begin
            GSTComponentCode := CGSTLbl;
            GSTLibrary.CreateGSTComponent(TaxComponent, GSTComponentCode);
            GSTLibrary.CreateGSTPostingSetup(TaxComponent, LocationStateCode);

            GSTComponentCode := SGSTLbl;
            GSTLibrary.CreateGSTComponent(TaxComponent, GSTComponentCode);
            GSTLibrary.CreateGSTPostingSetup(TaxComponent, LocationStateCode);
        end else begin
            GSTComponentCode := IGSTLbl;
            GSTLibrary.CreateGSTComponent(TaxComponent, GSTComponentCode);
            GSTLibrary.CreateGSTPostingSetup(TaxComponent, LocationStateCode);
        end;
    end;

    local procedure InitializeTaxRateParameters(IntraState: Boolean; FromState: Code[10]; ToState: Code[10])
    var
        GSTTaxPercent: Decimal;
    begin
        Storage.Set(FromStateCodeLbl, FromState);
        Storage.Set(ToStateCodeLbl, ToState);

        GSTTaxPercent := LibraryRandom.RandDecInRange(10, 18, 0);

        if IntraState then begin
            ComponentPerArray[1] := (GSTTaxPercent / 2);
            ComponentPerArray[2] := (GSTTaxPercent / 2);
            ComponentPerArray[3] := 0.00;
        end else
            ComponentPerArray[4] := GSTTaxPercent;
    end;

    local procedure CreateTaxRate()
    var
        GSTSetup: Record "GST Setup";
        TaxTypes: TestPage "Tax Types";
    begin
        if not GSTSetup.Get() then
            exit;

        TaxTypes.OpenEdit();
        TaxTypes.Filter.SetFilter(Code, GSTSetup."GST Tax Type");
        TaxTypes.TaxRates.Invoke();
    end;

    local procedure CreateAndPostSalesDocument(
        var SalesHeader: Record "Sales Header";
        var SalesLine: Record "Sales Line";
        LineType: Enum "Sales Line Type";
        DocumentType: Enum "Sales Document Type"): Code[20];
    var
        CustomerNo: Code[20];
        LocationCode: Code[10];
        PostedDocumentNo: Code[20];
    begin
        CustomerNo := Storage.Get(CustomerNoLbl);
        LocationCode := CopyStr(Storage.Get(LocationCodeLbl), 1, MaxStrLen(LocationCode));
        CreateSalesHeaderWithGST(SalesHeader, CustomerNo, DocumentType, LocationCode);
        CreateSalesLineWithGST(SalesHeader, SalesLine, LineType, LibraryRandom.RandDecInRange(2, 10, 0), StorageBoolean.Get(ExemptedLbl), StorageBoolean.Get(LineDiscountLbl));
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        exit(PostedDocumentNo);
    end;

    local procedure CreateSalesDocument(
        var SalesHeader: Record "Sales Header";
        var SalesLine: Record "Sales Line";
        LineType: Enum "Sales Line Type";
        DocumentType: Enum "Sales Document Type"): Code[20];
    var
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        CustomerNo := Storage.Get(CustomerNoLbl);
        LocationCode := CopyStr(Storage.Get(LocationCodeLbl), 1, MaxStrLen(LocationCode));
        CreateSalesHeaderWithGST(SalesHeader, CustomerNo, DocumentType, LocationCode);
        CreateSalesLineWithGST(SalesHeader, SalesLine, LineType, LibraryRandom.RandDecInRange(2, 10, 0), StorageBoolean.Get(ExemptedLbl), StorageBoolean.Get(LineDiscountLbl));
        exit(SalesHeader."No.");
    end;

    local procedure CreateSalesHeaderWithGST(
        var SalesHeader: Record "Sales Header";
        CustomerNo: Code[20];
        DocumentType: Enum "Sales Document Type";
        LocationCode: Code[10])
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, CustomerNo);
        SalesHeader.Validate("Posting Date", WorkDate());
        SalesHeader.Validate("Location Code", LocationCode);
        SalesHeader.Modify(true);
    end;

    local procedure CreateSalesLineWithGST(
        var SalesHeader: Record "Sales Header";
        var SalesLine: Record "Sales Line";
        LineType: Enum "Sales Line Type";
        Quantity: Decimal;
        Exempted: Boolean;
        LineDiscount: Boolean)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        LineTypeNo: Code[20];
    begin
        case LineType of
            LineType::Item:
                LineTypeNo := GSTLibrary.CreateItemWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), true, Exempted);
        end;

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, LineType, LineTypeno, Quantity);
        SalesLine.Validate("VAT Prod. Posting Group", VATPostingsetup."VAT Prod. Posting Group");

        if LineDiscount then begin
            SalesLine.Validate("Line Discount %", LibraryRandom.RandDecInRange(10, 20, 2));
            GSTLibrary.UpdateLineDiscAccInGeneralPostingSetup(SalesLine."Gen. Bus. Posting Group", SalesLine."Gen. Prod. Posting Group");
        end;
        SalesLine.Validate("Unit Price", LibraryRandom.RandInt(10000));
        SalesLine.Modify(true);
    end;
}