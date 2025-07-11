codeunit 18044 "GST Purchase Report Tests"
{
    Subtype = Test;

    var
        GSTLibrary: Codeunit "GST Library";
        LibraryRandom: Codeunit "Library - Random";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        Storage: Dictionary of [Text, Code[20]];
        StorageBoolean: Dictionary of [Text, Boolean];
        ComponentPerArray: array[20] of Decimal;
        LineAmtPurchInvLineLbl: Label 'LineAmt_PurchInvLine';
        TDSAmtLbl: Label 'TDSAmt';
        VendorNoLbl: Label 'VendorNo';
        LineAmtPurchLineLbl: Label 'LineAmt_PurchLine';
        PurchLineLineAmountLbl: Label 'PurchLineLineAmount';
        LocPanLbl: Label 'LocPan';
        CGSTAmtLbl: Label 'CGSTAmt';
        PostedDocumentNoLbl: Label 'PostedDocumentNo';
        InputCreditAvailmentLbl: Label 'InputCreditAvailment';
        IGSTAmtLbl: Label 'IGSTAmt';
        LocationCodeLbl: Label 'LocationCode';
        LineDiscountLbl: Label 'LineDiscount';
        LocationStateCodeLbl: Label 'LocationStateCode';
        GSTGroupCodeLbl: Label 'GSTGroupCode';
        HSNSACCodeLbl: Label 'HSNSACCode';
        FromStateCodeLbl: Label 'FromStateCode';
        ToStateCodeLbl: Label 'ToStateCode';
        CGSTLbl: Label 'CGST';
        SGSTLbl: Label 'SGST';
        IGSTLbl: Label 'IGST';
        GLAccNameLbl: Label 'GLAccName';

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure TestPurchaseInvReportForInterstateTrans()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Test Purchase Invoice Report for Interstate Transactions
        // [GIVEN] Created GST Setup for Registered Vendor For InterState Transactions
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeSharedStep(true, false);

        // [WHEN] Created and Posted Purchase Order with GST and Line Type as Item for Interstate Transactions
        PostedDocumentNo := CreateAndPostPurchaseDocument(
           PurchaseHeader,
           PurchaseLine,
           LineType::Item,
           DocumentType::Order);

        // [THEN] GST Amount and TDS Amount Verified on Purchase Invoice GST Report for InterState Transactions
        VerifyGSTAmountOnPostedInvoiceReport(PostedDocumentNo, false);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure TestPurchaseInvReportForIntraStateTrans()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Test Purchase Invoice Report for Intrastate Transactions
        // [GIVEN] Created GST Setup for Registered Vendor For IntraState Transactions
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeSharedStep(true, false);

        // [WHEN] Created and Posted Purchase Order with GST and Line Type as Item for Intrastate Transactions
        PostedDocumentNo := CreateAndPostPurchaseDocument(
           PurchaseHeader,
           PurchaseLine,
           LineType::Item,
           DocumentType::Order);

        // [THEN] GST Amount Verified on Purchase Invoice GST Report For IntraState Transactions
        VerifyGSTAmountOnPostedInvoiceReport(PostedDocumentNo, true);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure TestPurchaseOrderReport()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] Test Purchase Order Report for Interstate Transactions
        // [GIVEN] Created GST Setup for Registered Vendor
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeSharedStep(true, false);

        // [WHEN] Created Purchase Order with GST and Line Type as Item for Interstate Transactions
        DocumentNo := CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Order);

        // [THEN] Line Amount Verified on Purchase Order Report
        VerifyGSTAmountOnPurchaseOrderReport(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure TestPurchaseReturnOrderReport()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] Test Purchase Return Order Report for Interstate Transactions
        // [GIVEN] Created GST Setup for Registered Vendor
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeSharedStep(true, false);

        // [WHEN] Created Purchase Order with GST and Line Type as Item for Interstate Transactions
        DocumentNo := CreatePurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::"Return Order");

        // [THEN] Line Amount Verified on Purchase Return Order Report
        VerifyGSTAmountOnPurchaseRetOrderReport(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure TestPrintVoucherReportWithIntraStateTrans()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Test Posted Voucher Report with Intrastate Transactions
        // [GIVEN] Created GST Setup for Registered Vendor For IntraState Transactions
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeSharedStep(true, false);

        // [WHEN] Created and Posted Purchase Order with GST and Line Type as Item with Intrastate Transactions
        PostedDocumentNo := CreateAndPostPurchaseDocument(
           PurchaseHeader,
           PurchaseLine,
           LineType::Item,
           DocumentType::Order);

        // [THEN] GL Account Name Verified on Posted Voucher Report for Posted Vendor Ledger Entry
        VerifyVendorNameOnPostedVoucherReport(PostedDocumentNo);
    end;

    local procedure VerifyVendorNameOnPostedVoucherReport(PostedDocumentNo: Code[20])
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        GLEntry: Record "G/L Entry";
        Vendor: Record Vendor;
    begin
        PurchInvHeader.SetRange("No.", PostedDocumentNo);
        if PurchInvHeader.FindFirst() then begin
            VendorLedgerEntry.SetRange("Posting Date", PurchInvHeader."Posting Date");
            VendorLedgerEntry.SetRange("Document No.", PurchInvHeader."No.");
            if VendorLedgerEntry.FindFirst() then begin
                GLEntry.SetCurrentKey("Transaction No.");
                GLEntry.SetRange("Transaction No.", VendorLedgerEntry."Transaction No.");
                if GLEntry.FindFirst() then begin
                    LibraryReportDataset.RunReportAndLoad(Report::"Posted Voucher", GLEntry, '');
                    GLEntry.Reset();
                    GLEntry.SetRange("Transaction No.", VendorLedgerEntry."Transaction No.");
                    GLEntry.SetRange("Entry No.", VendorLedgerEntry."Entry No.");
                    GLEntry.SetRange("Source Type", GLEntry."Source Type"::Vendor);
                    if GLEntry.FindFirst() then
                        if Vendor.Get(GLEntry."Source No.") then
                            LibraryReportDataset.AssertElementWithValueExists(GLAccNameLbl, Vendor.Name);
                end;
            end;
        end;
    end;

    local procedure VerifyGSTAmountOnPostedInvoiceReport(PostedDocumentNo: Code[20]; IntraState: Boolean)
    var
        PurchInvLine: Record "Purch. Inv. Line";
    begin
        PurchInvLine.SetRange("Document No.", PostedDocumentNo);
        PurchInvLine.FindFirst();
        LibraryReportDataset.RunReportAndLoad(Report::"Purchase - Invoice GST", PurchInvLine, '');
        LibraryReportDataset.AssertElementWithValueExists(LineAmtPurchInvLineLbl, PurchInvLine.Amount);
        LibraryReportDataset.AssertElementWithValueExists(TDSAmtLbl, GetTDSAmt(PurchInvLine));
        if IntraState then
            LibraryReportDataset.AssertElementWithValueExists(CGSTAmtLbl, GetGSTAmounts(PurchInvLine))
        else
            LibraryReportDataset.AssertElementWithValueExists(IGSTAmtLbl, GetGSTAmounts(PurchInvLine));
    end;

    local procedure VerifyGSTAmountOnPurchaseOrderReport(DocumentNo: Code[20])
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SetRange("Document No.", DocumentNo);
        PurchaseLine.FindFirst();
        LibraryReportDataset.RunReportAndLoad(Report::"Purchase Order GST", PurchaseLine, '');
        LibraryReportDataset.AssertElementWithValueExists(PurchLineLineAmountLbl, PurchaseLine.Amount);
    end;

    local procedure VerifyGSTAmountOnPurchaseRetOrderReport(DocumentNo: Code[20])
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SetRange("Document No.", DocumentNo);
        PurchaseLine.FindFirst();
        LibraryReportDataset.RunReportAndLoad(Report::"Return Order GST", PurchaseLine, '');
        LibraryReportDataset.AssertElementWithValueExists(LineAmtPurchLineLbl, PurchaseLine.Amount);
    end;

    local procedure GetGSTAmounts(PurchInvLine: Record "Purch. Inv. Line"): Decimal
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        GSTAmount: Decimal;
    begin
        DetailedGSTLedgerEntry.SetRange("Document No.", PurchInvLine."Document No.");
        DetailedGSTLedgerEntry.FindFirst();

        if PurchInvLine."GST Jurisdiction Type" = PurchInvLine."GST Jurisdiction Type"::Interstate then
            GSTAmount := Round((PurchInvLine.Amount * ComponentPerArray[4]) / 100, GSTLibrary.GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"))
        else
            GSTAmount := Round(PurchInvLine.Amount * ComponentPerArray[1] / 100, GSTLibrary.GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"));
        exit(GSTAmount);
    end;

    local procedure GetTDSAmt(PurchInvLine: Record "Purch. Inv. Line"): Decimal
    var
        TDSEntry: Record "TDS Entry";
        TDSAmt: Decimal;
    begin
        Clear(TDSAmt);
        TDSEntry.Reset();
        TDSEntry.SetRange("Document No.", PurchInvLine."Document No.");
        if TDSEntry.FindSet() then
            repeat
                TDSAmt += TDSEntry."Total TDS Including SHE CESS";
            until TDSEntry.Next() = 0;
        TDSAmt := Round(TDSAmt, 1);
        exit(TDSAmt);
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
        TaxRates.AttributeValue7.SetValue(componentPerArray[1]);
        TaxRates.AttributeValue8.SetValue(componentPerArray[2]);
        TaxRates.AttributeValue9.SetValue(componentPerArray[4]);
        TaxRates.AttributeValue10.SetValue(componentPerArray[3]);
        TaxRates.AttributeValue11.SetValue('');
        TaxRates.AttributeValue12.SetValue('');
        TaxRates.OK().Invoke();
    end;

    local procedure CreateGSTSetup(
        GSTVendorType: Enum "GST Vendor Type";
        GSTGroupType: Enum "GST Group Type";
        IntraState: Boolean;
        ReverseCharge: Boolean)
    var
        GSTGroup: Record "GST Group";
        HSNSAC: Record "HSN/SAC";
        CompanyInformation: Record "Company information";
        TaxComponent: Record "Tax Component";
        LocationStateCode: Code[10];
        VendorNo: Code[20];
        GSTGroupCode: Code[20];
        LocationCode: Code[10];
        HSNSACCode: Code[10];
        LocPan: Code[20];
        LocationGSTRegNo: Code[15];
        HsnSacType: Enum "GST Goods And Services Type";
        GSTComponentcode: Text[30];
    begin
        CompanyInformation.Get();

        if CompanyInformation."P.A.N. No." = '' then begin
            CompanyInformation."P.A.N. No." := GSTLibrary.CreatePANNos();
            CompanyInformation.Modify();
        end else
            LocPan := CompanyInformation."P.A.N. No.";
        LocPan := CompanyInformation."P.A.N. No.";
        Storage.Set(LocPanLbl, LocPan);

        LocationStateCode := GSTLibrary.CreateInitialSetup();
        Storage.Set(LocationStateCodeLbl, LocationStateCode);

        LocationGSTRegNo := GSTLibrary.CreateGSTRegistrationNos(LocationStateCode, LocPan);
        if CompanyInformation."GST Registration No." = '' then begin
            CompanyInformation."GST Registration No." := LocationGSTRegNo;
            CompanyInformation.Modify(true);
        end;

        LocationCode := GSTLibrary.CreateLocationSetup(LocationStateCode, LocationGSTRegNo, false);
        Storage.Set(LocationCodeLbl, LocationCode);

        GSTGroupCode := GSTLibrary.CreateGSTGroup(GSTGroup, GSTGroupType, GSTGroup."GST Place Of Supply"::" ", ReverseCharge);
        Storage.Set(GSTGroupCodeLbl, GSTGroupCode);

        HSNSACCode := GSTLibrary.CreateHSNSACCode(HSNSAC, GSTGroupCode, HsnSacType::HSN);
        Storage.Set(HSNSACCodeLbl, HSNSACCode);

        VendorNo := GSTLibrary.CreateVendorSetup();
        Storage.Set(VendorNoLbl, VendorNo);

        if IntraState then
            CreateSetupForIntraStateVendor(GSTVendorType, IntraState)
        else
            CreateSetupForInterStateVendor(GSTVendorType, IntraState);

        CreateTaxRate();
        CreateGSTComponentAndPostingSetup(IntraState, LocationStateCode, TaxComponent, GSTComponentcode);
    end;

    local procedure CreateSetupForIntraStateVendor(GSTVendorType: Enum "GST Vendor Type"; IntraState: Boolean)
    var
        LocationStateCode: Code[10];
        VendorNo: Code[20];
        LocPan: Code[20];
    begin
        VendorNo := (Storage.Get(VendorNoLbl));
        LocationStateCode := (Storage.Get(LocationStateCodeLbl));
        LocPan := (Storage.Get(LocPanLbl));

        UpdateVendorSetupWithGST(VendorNo, GSTVendorType, LocationStateCode, LocPan);
        InitializeTaxRateParameters(IntraState, LocationStateCode, LocationStateCode);
    end;

    local procedure CreateSetupForInterStateVendor(GSTVendorType: Enum "GST Vendor Type"; IntraState: Boolean)
    var
        LocationStateCode: Code[10];
        VendorStateCode: Code[10];
        VendorNo: Code[20];
        LocPan: Code[20];
    begin
        VendorNo := (Storage.Get(VendorNoLbl));
        LocationStateCode := (Storage.Get(LocationStateCodeLbl));
        LocPan := (Storage.Get(LocPanLbl));
        VendorStateCode := GSTLibrary.CreateGSTStateCode();

        UpdateVendorSetupWithGST(VendorNo, GSTVendorType, VendorStateCode, LocPan);

        if GSTVendorType in [GSTVendorType::Import, GSTVendorType::SEZ] then
            InitializeTaxRateParameters(IntraState, '', LocationStateCode)
        else
            InitializeTaxRateParameters(IntraState, VendorStateCode, LocationStateCode);
    end;

    local procedure CreatePurchaseDocument(
        var PurchaseHeader: Record "Purchase Header";
        var PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        DocumentType: Enum "Purchase Document Type"): Code[20]
    var
        LocationCode: Code[10];
        VendorNo: Code[20];
        PurchaseInvoiceType: Enum "GST Invoice Type";
    begin
        VendorNo := Storage.Get(VendorNoLbl);
        Evaluate(LocationCode, CopyStr(Storage.Get(LocationCodeLbl), 1, MaxStrLen(LocationCode)));
        CreatePurchaseHeaderWithGST(PurchaseHeader, VendorNo, DocumentType, LocationCode, PurchaseInvoiceType::" ");
        CreatePurchaseLineWithGST(PurchaseHeader, PurchaseLine, LineType, LibraryRandom.RandDecInRange(2, 10, 0), StorageBoolean.Get(InputCreditAvailmentLbl), StorageBoolean.Get(LineDiscountLbl));
        exit(PurchaseHeader."No.")
    end;

    local procedure CreateAndPostPurchaseDocument(
        var PurchaseHeader: Record "Purchase Header";
        var PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        DocumentType: Enum "Purchase Document Type"): Code[20];
    var
        VendorNo: Code[20];
        LocationCode: Code[10];
        DocumentNo: Code[20];
        PurchaseInvoiceType: Enum "GST Invoice Type";
    begin
        VendorNo := Storage.Get(VendorNoLbl);
        Evaluate(LocationCode, CopyStr(Storage.Get(LocationCodeLbl), 1, MaxStrLen(LocationCode)));
        CreatePurchaseHeaderWithGST(PurchaseHeader, VendorNo, DocumentType, LocationCode, PurchaseInvoiceType::" ");
        CreatePurchaseLineWithGST(PurchaseHeader, PurchaseLine, LineType, LibraryRandom.RandDecInRange(2, 10, 0), StorageBoolean.Get(InputCreditAvailmentLbl), StorageBoolean.Get(LineDiscountLbl));
        if not (PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Quote) then begin
            DocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
            Storage.Set(PostedDocumentNoLbl, DocumentNo);
            exit(DocumentNo);
        end;
    end;

    local procedure InitializeSharedStep(InputCreditAvailment: Boolean; LineDiscount: Boolean)
    begin
        StorageBoolean.Set(InputCreditAvailmentLbl, InputCreditAvailment);
        StorageBoolean.Set(LineDiscountLbl, LineDiscount);
    end;

    local procedure UpdateVendorSetupWithGST(
        VendorNo: Code[20];
        GSTVendorType: Enum "GST Vendor Type";
        StateCode: Code[10];
        Pan: Code[20])
    var
        Vendor: Record Vendor;
        State: Record State;
    begin
        Vendor.Get(VendorNo);
        if (GSTVendorType <> GSTVendorType::Import) then begin
            State.Get(StateCode);
            Vendor.Validate("State Code", StateCode);
            Vendor.Validate("P.A.N. No.", Pan);
            if not ((GSTVendorType = GSTVendorType::" ") or (GSTVendorType = GSTVendorType::Unregistered)) then
                Vendor.Validate("GST Registration No.", GSTLibrary.GenerateGSTRegistrationNo(State."State Code (GST Reg. No.)", Pan));
        end;
        Vendor.Validate("GST Vendor Type", GSTVendorType);
        if Vendor."GST Vendor Type" = Vendor."GST Vendor Type"::Import then
            Vendor.Validate("Currency Code", GSTLibrary.CreateCurrencyCode());
        Vendor.Modify(true);
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
            ComponentPerArray[3] := 0;
        end else
            ComponentPerArray[4] := GSTTaxPercent;
    end;

    local procedure CreateGSTComponentAndPostingSetup(
        IntraState: Boolean;
        LocationStateCode: Code[10];
        TaxComponent: Record "Tax Component";
        GSTComponentcode: Text[30])
    begin
        if IntraState then begin
            GSTComponentcode := CGSTLbl;
            GSTLibrary.CreateGSTComponent(TaxComponent, GSTComponentcode);
            GSTLibrary.CreateGSTPostingSetup(TaxComponent, LocationStateCode);

            GSTComponentcode := SGSTLbl;
            GSTLibrary.CreateGSTComponent(TaxComponent, GSTComponentcode);
            GSTLibrary.CreateGSTPostingSetup(TaxComponent, LocationStateCode);
        end else begin
            GSTComponentcode := IGSTLbl;
            GSTLibrary.CreateGSTComponent(TaxComponent, GSTComponentcode);
            GSTLibrary.CreateGSTPostingSetup(TaxComponent, LocationStateCode);
        end;
    end;

    local procedure CreatePurchaseHeaderWithGST(
        var PurchaseHeader: Record "Purchase Header";
        VendorNo: Code[20];
        DocumentType: Enum "Purchase Document Type";
        LocationCode: Code[10];
        PurchaseInvoiceType: Enum "GST Invoice Type")
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, DocumentType, VendorNo);
        PurchaseHeader.Validate("Posting Date", WorkDate());
        PurchaseHeader.Validate("Location Code", LocationCode);
        if PurchaseInvoiceType in [PurchaseInvoiceType::"Debit Note", PurchaseInvoiceType::Supplementary] then
            PurchaseHeader.Validate("Vendor Invoice No.", LibraryUtility.GenerateRandomCode(PurchaseHeader.FieldNo("Vendor Invoice No."), Database::"Purchase Header"))
        else
            PurchaseHeader.Validate("Vendor Cr. Memo No.", LibraryUtility.GenerateRandomCode(PurchaseHeader.FieldNo("Vendor Cr. Memo No."), Database::"Purchase Header"));
        if PurchaseHeader."GST Vendor Type" = PurchaseHeader."GST Vendor Type"::SEZ then begin
            PurchaseHeader."Bill of Entry No." := LibraryUtility.GenerateRandomCode(PurchaseHeader.FieldNo("Bill of Entry No."), Database::"Purchase Header");
            PurchaseHeader."Bill of Entry Date" := WorkDate();
            PurchaseHeader."Bill of Entry Value" := LibraryRandom.RandInt(1000);
        end;
        PurchaseHeader.Modify(true);
    end;

    local procedure CreatePurchaseLineWithGST(
        var PurchaseHeader: Record "Purchase Header";
        var PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        Quantity: Decimal;
        InputCreditAvailment: Boolean;
        LineDiscount: Boolean)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        LineTypeNo: Code[20];
    begin
        InputCreditAvailment := StorageBoolean.Get(InputCreditAvailmentLbl);
        case LineType of
            LineType::Item:
                LineTypeNo := GSTLibrary.CreateItemWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), InputCreditAvailment, false);
        end;
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, LineType, LineTypeno, Quantity);
        PurchaseLine.Validate("VAT Prod. Posting Group", VATPostingsetup."VAT Prod. Posting Group");
        if InputCreditAvailment then
            PurchaseLine."GST Credit" := PurchaseLine."GST Credit"::Availment
        else
            PurchaseLine."GST Credit" := PurchaseLine."GST Credit"::"Non-Availment";

        if LineDiscount then begin
            PurchaseLine.Validate("Line Discount %", LibraryRandom.RandDecInRange(10, 20, 2));
            GSTLibrary.UpdateLineDiscAccInGeneralPostingSetup(PurchaseLine."Gen. Bus. Posting Group", PurchaseLine."Gen. Prod. Posting Group");
        end;

        if ((PurchaseHeader."GST Vendor Type" in [PurchaseHeader."GST Vendor Type"::Import, PurchaseHeader."GST Vendor Type"::SEZ])) and (PurchaseLine.Type = PurchaseLine.Type::"Fixed Asset") then
            PurchaseLine.Validate("GST Assessable Value", LibraryRandom.RandInt(1000))
        else
            if (PurchaseHeader."GST Vendor Type" in [PurchaseHeader."GST Vendor Type"::Import, PurchaseHeader."GST Vendor Type"::SEZ]) then begin
                PurchaseLine.Validate("GST Assessable Value", LibraryRandom.RandInt(1000));
                PurchaseLine.Validate("Custom Duty Amount", LibraryRandom.RandInt(1000));
            end;
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandInt(1000));
        PurchaseLine.Modify(true);
    end;

    local procedure CreateTaxRate()
    var
        GSTSetup: Record "GST Setup";
        TaxTypes: TestPage "Tax Types";
    begin
        GSTSetup.Get();
        TaxTypes.OpenEdit();
        TaxTypes.Filter.SetFilter(Code, GSTSetup."GST Tax Type");
        TaxTypes.TaxRates.Invoke();
    end;
}