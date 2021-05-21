codeunit 18045 "GST Sales Return Report Tests"
{
    Subtype = Test;

    var
        GSTLibrary: Codeunit "GST Library";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        ComponentPerArray: array[20] of Decimal;
        Storage: Dictionary of [Text, Text[20]];
        StorageBoolean: Dictionary of [Text, Boolean];
        LocationCodeLbl: Label 'LocationCode';
        IGSTAmtLbl: Label 'IGSTAmt';
        LocPanLbl: Label 'LocPan';
        TCSAmtLbl: Label 'TCSAmt';
        LineAmtSalesCrMemoLineLbl: Label 'LineAmt_SalesCrMemoLine';
        CGSTAmtLbl: Label 'CGSTAmt';
        PostedDocumentNoLbl: Label 'PostedDocumentNo';
        LocationStateCodeLbl: Label 'LocationStateCode';
        ReverseDocumentNoLbl: Label 'ReverseDocumentNo';
        GSTGroupCodeLbl: Label 'GSTGroupCode';
        HSNSACCodeLbl: Label 'HSNSACCode';
        CGSTLbl: Label 'CGST';
        SGSTLbl: Label 'SGST';
        IGSTLbl: Label 'IGST';
        ExemptedLbl: Label 'Exempted';
        LineDiscountLbl: Label 'LineDiscount';
        FromStateCodeLbl: Label 'FromStateCode';
        CustomerNoLbl: Label 'CustomerNo';
        ToStateCodeLbl: Label 'ToStateCode';

    [Test]
    [HandlerFunctions('TaxRatePageHandler,CustomerLedgerEntries')]
    procedure TestPostedSalesCrMemoReportForInterStateTrans()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [SCENARIO] Test Sales Credit Memo Report for InterState Transactions
        // [GIVEN] Created GST Setup For Registered Customer For InterState Transactions
        InitializeShareStep(false, false);
        CreateGSTSetup(GSTCustomerType::Registered, GSTGroupType::Goods, false, false);

        // [WHEN] Created and Posted Sales Credit Memo For InterState Transactions
        CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        CreateAndPostSalesDocumentFromCopyDocument(
            SalesHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST Amount and TCS Amount Verified on Sales Credit Memo Report For InterState Transactions
        VerifyGSTAmountOnPostedInvoiceReport(Storage.Get(ReverseDocumentNoLbl), false);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,CustomerLedgerEntries')]
    procedure TestPostedSalesCrMemoReportForIntraStateTrans()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
    begin
        // [SCENARIO] Test Sales Credit Memo Report For IntraState Transactions
        // [GIVEN] Created GST Setup For Registered Customer For IntraState Transactions
        InitializeShareStep(false, false);
        CreateGSTSetup(GSTCustomerType::Registered, GSTGroupType::Goods, true, false);

        // [WHEN] Created and Posted Sales Credit Memo For IntraState Transactions
        CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine,
            LineType::Item,
            DocumentType::Invoice);

        CreateAndPostSalesDocumentFromCopyDocument(
            SalesHeader,
            DocumentType::"Credit Memo");

        // [THEN] GST Amount and TCS Amount Verified on Sales Credit Memo Report For IntraState Transactions
        VerifyGSTAmountOnPostedInvoiceReport(Storage.Get(ReverseDocumentNoLbl), true);
    end;

    local procedure VerifyGSTAmountOnPostedInvoiceReport(PostedDocumentNo: Code[20]; IntraState: Boolean)
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
    begin
        SalesCrMemoLine.SetRange("Document No.", PostedDocumentNo);
        SalesCrMemoLine.SetFilter("No.", '<>%1', '');
        SalesCrMemoLine.FindFirst();
        LibraryReportDataset.RunReportAndLoad(Report::"Sales - Credit Memo GST", SalesCrMemoLine, '');
        LibraryReportDataset.AssertElementWithValueExists(LineAmtSalesCrMemoLineLbl, SalesCrMemoLine.Amount);
        LibraryReportDataset.AssertElementWithValueExists(TCSAmtLbl, GetTCSAmt(SalesCrMemoLine));
        if IntraState then
            LibraryReportDataset.AssertElementWithValueExists(CGSTAmtLbl, GetGSTAmounts(SalesCrMemoLine))
        else
            LibraryReportDataset.AssertElementWithValueExists(IGSTAmtLbl, GetGSTAmounts(SalesCrMemoLine));
    end;

    local procedure GetTCSAmt(SalesCrMemoLine: Record "Sales Cr.Memo Line"): Decimal
    var
        TCSEntry: Record "TCS Entry";
        TCSAmt: Decimal;
    begin
        TCSEntry.Reset();
        TCSEntry.SetRange("Document No.", SalesCrMemoLine."Document No.");
        if TCSEntry.FindSet() then
            repeat
                TCSAmt += TCSEntry."Total TCS Including SHE CESS";
                TCSAmt := Round(TCSAmt, 1);
            until TCSEntry.Next() = 0;
        exit(TCSAmt);
    end;

    local procedure GetGSTAmounts(SalesCrMemoLine: Record "Sales Cr.Memo Line"): Decimal
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        GSTAmount: Decimal;
    begin
        DetailedGSTLedgerEntry.SetRange("Document No.", SalesCrMemoLine."Document No.");
        DetailedGSTLedgerEntry.FindFirst();

        if SalesCrMemoLine."GST Jurisdiction Type" = SalesCrMemoLine."GST Jurisdiction Type"::Interstate then
            GSTAmount := Round((SalesCrMemoLine.Amount * ComponentPerArray[4]) / 100, GSTLibrary.GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"))
        else
            GSTAmount := Round(SalesCrMemoLine.Amount * ComponentPerArray[1] / 100, GSTLibrary.GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"));
        exit(GSTAmount);
    end;

    [ModalPageHandler]
    procedure CustomerLedgerEntries(var CustomerLedgerEntries: TestPage "Customer Ledger Entries")
    begin
        CustomerLedgerEntries.OK().Invoke();
    end;

    [PageHandler]
    procedure TaxRatePageHandler(var TaxRates: TestPage "Tax Rates")
    begin
        TaxRates.New();
        TaxRates.AttributeValue1.SetValue(Storage.Get(GSTGroupCodeLbl));
        TaxRates.AttributeValue2.SetValue(Storage.Get(HSNSACCodeLbl));
        TaxRates.AttributeValue3.SetValue(Storage.Get(FromStateCodeLbl));
        TaxRates.AttributeValue4.SetValue(Storage.Get(ToStateCodeLbl));
        TaxRates.AttributeValue5.SetValue(WorkDate());
        TaxRates.AttributeValue6.SetValue(CalcDate('<10Y>', WorkDate()));
        TaxRates.AttributeValue7.SetValue(ComponentPerArray[1]); // SGST
        TaxRates.AttributeValue8.SetValue(ComponentPerArray[2]); // CGST
        TaxRates.AttributeValue9.SetValue(ComponentPerArray[4]); // IGST
        TaxRates.AttributeValue10.SetValue(ComponentPerArray[3]); // KFloodCess
        TaxRates.OK().Invoke();
    end;

    local procedure CreateAndPostSalesDocumentFromCopyDocument(
        var SalesHeader: Record "Sales Header";
        DocumentType: Enum "Sales Document Type")
    var
        CopyDocumentMgt: Codeunit "Copy Document Mgt.";
        ReverseDocumentNo: Code[20];
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, Storage.Get(CustomerNoLbl));
        SalesHeader.Validate("Posting Date", WorkDate());
        SalesHeader.Validate("Location Code", CopyStr(Storage.Get(LocationCodeLbl), 1, MaxStrLen(SalesHeader."Location Code")));
        SalesHeader.Modify(true);
        CopyDocumentMgt.SetProperties(true, false, false, false, true, false, false);
        CopyDocumentMgt.CopySalesDocForInvoiceCancelling(Storage.Get(PostedDocumentNoLbl), SalesHeader);
        UpdateReferenceInvoiceNoAndVerify(SalesHeader);
        ReverseDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        Storage.Set(ReverseDocumentNoLbl, ReverseDocumentNo);
    end;

    local procedure UpdateSalesLine(var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                SalesLine.Validate("Unit Price");
                SalesHeader.Modify(true);
            until SalesLine.Next() = 0;
    end;

    local procedure UpdateReferenceInvoiceNoAndVerify(var SalesHeader: Record "Sales Header")
    var
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        ReferenceInvoiceNoMgt: Codeunit "Reference Invoice No. Mgt.";
    begin
        UpdateSalesLine(SalesHeader);
        ReferenceInvoiceNo.Init();
        ReferenceInvoiceNo.Validate("Document No.", SalesHeader."No.");
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::"Credit Memo":
                ReferenceInvoiceNo.Validate("Document Type", ReferenceInvoiceNo."Document Type"::"Credit Memo");
            SalesHeader."Document Type"::"Return Order":
                ReferenceInvoiceNo.Validate("Document Type", ReferenceInvoiceNo."Document Type"::"Return Order");
        end;
        ReferenceInvoiceNo.Validate("Source Type", ReferenceInvoiceNo."Source Type"::Customer);
        ReferenceInvoiceNo.Validate("Source No.", SalesHeader."Sell-to Customer No.");
        ReferenceInvoiceNo.Validate("Reference Invoice Nos.", Storage.Get(PostedDocumentNoLbl));
        ReferenceInvoiceNo.Insert(true);
        ReferenceInvoiceNoMgt.UpdateReferenceInvoiceNoforCustomer(ReferenceInvoiceNo, ReferenceInvoiceNo."Document Type", ReferenceInvoiceNo."Document No.");
        ReferenceInvoiceNoMgt.VerifyReferenceNo(ReferenceInvoiceNo);
    end;

    local procedure CreateGSTSetup(
        GSTCustomerType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        IntraState: Boolean;
        ReverseCharge: Boolean)
    var
        GSTGroup: Record "GST Group";
        HSNSAC: Record "HSN/SAC";
        TaxComponent: Record "Tax Component";
        CompanyInformation: Record "Company information";
        LocationStateCode: Code[10];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        LocPANNo: Code[20];
        GSTGroupCode: Code[20];
        HSNSACCode: Code[10];
        LocationGSTRegNo: Code[15];
        HsnSacType: Enum "GST Goods And Services Type";
        GSTComponentCode: Text[30];
    begin
        FillCompanyInformation();
        CompanyInformation.Get();
        if CompanyInformation."P.A.N. No." = '' then begin
            CompanyInformation."P.A.N. No." := GSTLibrary.CreatePANNos();
            CompanyInformation.Modify();
        end else
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

        GSTGroupCode := GSTLibrary.CreateGSTGroup(GSTGroup, GSTGroupType, GSTGroup."GST Place Of Supply"::"Bill-to Address", ReverseCharge);
        Storage.Set(GSTGroupCodeLbl, GSTGroupCode);

        HSNSACCode := GSTLibrary.CreateHSNSACCode(HSNSAC, GSTGroupCode, HsnSacType::HSN);
        Storage.Set(HSNSACCodeLbl, HSNSACCode);

        CustomerNo := GSTLibrary.CreateCustomerSetup();
        Storage.Set(CustomerNoLbl, CustomerNo);

        if IntraState then
            CreateSetupForIntraStateCustomer(GSTCustomerType, true)
        else
            CreateSetupForInterStateCustomer(GSTCustomerType, false);

        CreateTaxRate();
        CreateGSTComponentAndPostingSetup(IntraState, LocationStateCode, TaxComponent, GSTComponentCode);
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

    local procedure CreateGSTComponentAndPostingSetup(
          IntraState: Boolean;
          LocationStateCode: Code[10];
          TaxComponent: Record "Tax Component";
          GSTComponentCode: Text[30])
    begin
        if not IntraState then begin
            GSTComponentCode := IGSTLbl;
            GSTLibrary.CreateGSTComponent(TaxComponent, GSTComponentCode);
            GSTLibrary.CreateGSTPostingSetup(TaxComponent, LocationStateCode);
        end else begin
            GSTComponentCode := CGSTLbl;
            GSTLibrary.CreateGSTComponent(TaxComponent, GSTComponentCode);
            GSTLibrary.CreateGSTPostingSetup(TaxComponent, LocationStateCode);

            GSTComponentCode := SGSTLbl;
            GSTLibrary.CreateGSTComponent(TaxComponent, GSTComponentCode);
            GSTLibrary.CreateGSTPostingSetup(TaxComponent, LocationStateCode);
        end;
    end;

    local procedure InitializeShareStep(
        Exempted: Boolean;
        LineDiscount: Boolean)
    begin
        StorageBoolean.Set(ExemptedLbl, Exempted);
        StorageBoolean.Set(LineDiscountLbl, LineDiscount);
    end;

    local procedure InitializeTaxRateParameters(
        IntraState: Boolean;
        FromState: Code[10];
        ToState: Code[10])
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
        if (GSTCustomerType <> GSTCustomerType::Export) then begin
            State.Get(StateCode);
            Customer.Validate("State Code", StateCode);
            Customer.Validate("P.A.N. No.", PANNo);
            if not ((GSTCustomerType = GSTCustomerType::" ") or (GSTCustomerType = GSTCustomerType::Unregistered)) then
                Customer.Validate("GST Registration No.", GSTLibrary.GenerateGSTRegistrationNo(State."State Code (GST Reg. No.)", PANNo));
        end;
        Customer.Validate("GST Customer Type", GSTCustomerType);
        Customer.Modify(true);
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
        Evaluate(LocationCode, CopyStr(Storage.Get(LocationCodeLbl), 1, 10));
        CreateSalesHeaderWithGST(SalesHeader, CustomerNo, DocumentType, LocationCode);
        CreateSalesLineWithGST(SalesHeader, SalesLine, LineType, LibraryRandom.RandDecInRange(2, 10, 0), StorageBoolean.Get(ExemptedLbl), StorageBoolean.Get(LineDiscountLbl));
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        Storage.Set(PostedDocumentNoLbl, PostedDocumentNo);
        exit(PostedDocumentNo);
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

    local procedure FillCompanyInformation()
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        if CompanyInformation."State Code" = '' then
            CompanyInformation.Validate("State Code", GSTLibrary.CreateGSTStateCode());
        if CompanyInformation."P.A.N. No." = '' then
            CompanyInformation.Validate("P.A.N. No.", GSTLibrary.CreatePANNos());
        CompanyInformation.Modify(true);
    end;
}