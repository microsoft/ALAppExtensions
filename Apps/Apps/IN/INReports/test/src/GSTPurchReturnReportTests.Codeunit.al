codeunit 18047 "GST Purch Return Report Tests"
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
        ReverseDocumentNoLbl: Label 'ReverseDocumentNo';
        LocPanLbl: Label 'LocPan';
        IGSTAmtLbl: Label 'IGSTAmt';
        LineAmtPurchCrMemoLineLbl: Label 'LineAmt_PurchCrMemoLine';
        CGSTAmtLbl: Label 'CGSTAmt';
        LocationStateCodeLbl: Label 'LocationStateCode';
        LocationCodeLbl: Label 'LocationCode';
        GSTGroupCodeLbl: Label 'GSTGroupCode';
        HSNSACCodeLbl: Label 'HSNSACCode';
        VendorNoLbl: Label 'VendorNo';
        CGSTLbl: Label 'CGST';
        SGSTLbl: Label 'SGST';
        IGSTLbl: Label 'IGST';
        InputCreditAvailmentLbl: Label 'InputCreditAvailment';
        PostedDocumentNoLbl: Label 'PostedDocumentNo';
        LineDiscountLbl: Label 'LineDiscount';
        FromStateCodeLbl: Label 'FromStateCode';
        ToStateCodeLbl: Label 'ToStateCode';
        AssociatedVendorLbl: Label 'AssociatedVendor';

    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure TestPurchaseCreditMemoReportForInterStateTrans()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] Test Purchase Credit Memo Report For InterState Transactions
        // [GIVEN] Created GST Setup with Registered Vendor For InterState Transactions
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, false, false);
        InitializeSharedStep(true, false);

        // [WHEN] Created and Posted Purchase Credit Memo with GST and Line Type as Item for Interstate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Order);

        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GGST Amount Verified on Purch Cr Memo Report For InterState Transactions
        VerifyGSTAmountOnPostedInvoiceReport(Storage.Get(ReverseDocumentNoLbl), false);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,VendorLedgerEntries')]
    procedure TestPurchaseCreditMemoReportForIntraStateTrans()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LineType: Enum "Purchase Line Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Document Type Enum";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        // [SCENARIO] Test Purchase Credit Memo Report For IntraState Transactions
        // [GIVEN] Created GST Setup with Registered Vendor For IntraState Transactions
        CreateGSTSetup(GSTVendorType::Registered, GSTGroupType::Goods, true, false);
        InitializeSharedStep(true, false);

        // [WHEN] Created and Posted Purchase Credit Memo with GST and Line Type as Item for Intrastate Transactions.
        CreateAndPostPurchaseDocument(
            PurchaseHeader,
            PurchaseLine,
            LineType::Item,
            DocumentType::Order);

        CreateAndPostPurchaseReturnFromCopyDocument(
            PurchaseHeader,
            DocumentType::"Credit Memo");

        // [THEN] GGST Amount Verified on Purch Cr Memo Report For IntraState Transactions
        VerifyGSTAmountOnPostedInvoiceReport(Storage.Get(ReverseDocumentNoLbl), true);
    end;

    local procedure VerifyGSTAmountOnPostedInvoiceReport(PostedDocumentNo: Code[20]; IntraState: Boolean)
    var
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
    begin
        PurchCrMemoLine.SetRange("Document No.", PostedDocumentNo);
        PurchCrMemoLine.SetFilter("No.", '<>%1', '');
        PurchCrMemoLine.FindFirst();
        LibraryReportDataset.RunReportAndLoad(Report::"Purchase - Credit Memo GST", PurchCrMemoLine, '');
        LibraryReportDataset.AssertElementWithValueExists(LineAmtPurchCrMemoLineLbl, PurchCrMemoLine.Amount);
        if IntraState then
            LibraryReportDataset.AssertElementWithValueExists(CGSTAmtLbl, GetGSTAmounts(PurchCrMemoLine))
        else
            LibraryReportDataset.AssertElementWithValueExists(IGSTAmtLbl, GetGSTAmounts(PurchCrMemoLine));
    end;

    local procedure GetGSTAmounts(PurchCrMemoLine: Record "Purch. Cr. Memo Line"): Decimal
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        GSTAmount: Decimal;
    begin
        DetailedGSTLedgerEntry.SetRange("Document No.", PurchCrMemoLine."Document No.");
        DetailedGSTLedgerEntry.FindFirst();

        if PurchCrMemoLine."GST Jurisdiction Type" = PurchCrMemoLine."GST Jurisdiction Type"::Interstate then
            GSTAmount := Round((PurchCrMemoLine.Amount * ComponentPerArray[4]) / 100, GSTLibrary.GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"))
        else
            GSTAmount := Round(PurchCrMemoLine.Amount * ComponentPerArray[1] / 100, GSTLibrary.GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"));
        exit(GSTAmount);
    end;

    [ModalPageHandler]
    procedure VendorLedgerEntries(var VendorLedgerEntries: TestPage "Vendor Ledger Entries")
    begin
        VendorLedgerEntries.OK().Invoke();
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
        TaxRates.OK().Invoke();
    end;

    [PageHandler]
    procedure VendorInvoiceDiscountPageHandler(var VendInvoiceDiscounts: TestPage "Vend. Invoice Discounts")
    begin
        VendInvoiceDiscounts."Discount %".SetValue(LibraryRandom.RandIntInRange(1, 4));
        VendInvoiceDiscounts.OK().Invoke();
    end;

    local procedure CreateGSTSetup(
        GSTVendorType: Enum "GST Vendor Type";
        GSTGroupType: Enum "GST Group Type";
        IntraState: Boolean;
        ReverseCharge: Boolean)
    var
        GSTGroup: Record "GST Group";
        HSNSAC: Record "HSN/SAC";
        TaxComponent: Record "Tax Component";
        CompanyInformation: Record "Company information";
        LocationStateCode: Code[10];
        VendorNo: Code[20];
        GSTGroupCode: Code[20];
        LocationCode: Code[10];
        HSNSACCode: Code[10];
        LocPan: Code[20];
        LocationGSTRegNo: Code[15];
        HsnSacType: Enum "GST Goods And Services Type";
        GSTcomponentcode: Text[30];
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

        GSTGroupCode := GSTLibrary.CreateGSTGroup(GSTGroup, GSTGroupType, GSTGroup."GST Place Of Supply"::"Bill-to Address", ReverseCharge);
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
        CreateGSTComponentAndPostingSetup(IntraState, LocationStateCode, TaxComponent, GSTcomponentcode);
    end;

    local procedure CreateSetupForIntraStateVendor(GSTVendorType: Enum "GST Vendor Type"; IntraState: Boolean)
    var
        LocationStateCode: Code[10];
        VendorNo: Code[20];
        LocPan: Code[20];
    begin
        VendorNo := Storage.Get(VendorNoLbl);
        LocationStateCode := (Storage.Get(LocationStateCodeLbl));
        LocPan := Storage.Get(LocPanLbl);
        UpdateVendorSetupWithGST(VendorNo, GSTVendorType, false, LocationStateCode, LocPan);
        InitializeTaxRateParameters(IntraState, LocationStateCode, LocationStateCode);
    end;

    local procedure CreateSetupForInterStateVendor(GSTVendorType: Enum "GST Vendor Type"; IntraState: Boolean)
    var
        LocationStateCode: Code[10];
        VendorStateCode: Code[10];
        VendorNo: Code[20];
        LocPan: Code[20];
    begin
        VendorNo := Storage.Get(VendorNoLbl);
        LocationStateCode := (Storage.Get(LocationStateCodeLbl));
        LocPan := Storage.Get(LocPanLbl);
        VendorStateCode := GSTLibrary.CreateGSTStateCode();
        UpdateVendorSetupWithGST(VendorNo, GSTVendorType, false, VendorStateCode, LocPan);

        if GSTVendorType in [GSTVendorType::Import, GSTVendorType::SEZ] then
            InitializeTaxRateParameters(IntraState, LocationStateCode, '')
        else
            InitializeTaxRateParameters(IntraState, VendorStateCode, LocationStateCode);
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

    local procedure CreateAndPostPurchaseReturnFromCopyDocument(
        var PurchaseHeader: Record "Purchase Header";
        DocumentType: Enum "Purchase Document Type")
    var
        CopyDocumentMgt: Codeunit "Copy Document Mgt.";
        ReverseDocumentNo: Code[20];
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, DocumentType, Storage.Get(VendorNoLbl));
        PurchaseHeader.Validate("Posting Date", WorkDate());
        PurchaseHeader.Validate("Location Code", CopyStr(Storage.Get(LocationCodeLbl), 1, MaxStrLen(PurchaseHeader."Location Code")));
        PurchaseHeader.Modify(true);
        CopyDocumentMgt.SetProperties(true, false, false, false, true, false, false);
        CopyDocumentMgt.CopyPurchaseDocForInvoiceCancelling(Storage.Get(PostedDocumentNoLbl), PurchaseHeader);
        UpdateReferenceInvoiceNoAndVerify(PurchaseHeader);
        ReverseDocumentNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        Storage.Set(ReverseDocumentNoLbl, ReverseDocumentNo);
    end;

    local procedure InitializeSharedStep(InputCreditAvailment: Boolean; LineDiscount: Boolean)
    begin
        StorageBoolean.Set(InputCreditAvailmentLbl, InputCreditAvailment);
        StorageBoolean.Set(LineDiscountLbl, LineDiscount);
    end;

    local procedure UpdateVendorSetupWithGST(
        VendorNo: Code[20];
        GSTVendorType: Enum "GST Vendor Type";
        AssociateEnterprise: Boolean;
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
        if Vendor."GST Vendor Type" = vendor."GST Vendor Type"::Import then begin
            Vendor.Validate("Currency Code", GSTLibrary.CreateCurrencyCode());
            if StorageBoolean.ContainsKey(AssociatedVendorLbl) then
                vendor.Validate("Associated Enterprises", AssociateEnterprise);
        end;
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
        GSTcomponentcode: Text[30])
    begin
        if IntraState then begin
            GSTcomponentcode := CGSTLbl;
            GSTLibrary.CreateGSTComponent(TaxComponent, GSTcomponentcode);
            GSTLibrary.CreateGSTPostingSetup(TaxComponent, LocationStateCode);

            GSTcomponentcode := SGSTLbl;
            GSTLibrary.CreateGSTComponent(TaxComponent, GSTcomponentcode);
            GSTLibrary.CreateGSTPostingSetup(TaxComponent, LocationStateCode);
        end else begin
            GSTcomponentcode := IGSTLbl;
            GSTLibrary.CreateGSTComponent(TaxComponent, GSTcomponentcode);
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
        Overseas: Boolean;
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, DocumentType, VendorNo);
        PurchaseHeader.Validate("Posting Date", WorkDate());
        PurchaseHeader.Validate("Location Code", LocationCode);
        if Overseas then
            PurchaseHeader.Validate("POS Out Of India", true);
        if PurchaseInvoiceType in [PurchaseInvoiceType::"Debit Note", PurchaseInvoiceType::Supplementary] then
            PurchaseHeader.Validate("Vendor Invoice No.", LibraryUtility.GenerateRandomCode(PurchaseHeader.FieldNo("Vendor Invoice No."), Database::"Purchase Header"));

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
                LineTypeNo := GSTLibrary.CreateItemWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), true, false);
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

        if (PurchaseHeader."GST Vendor Type" in [PurchaseHeader."GST Vendor Type"::Import, PurchaseHeader."GST Vendor Type"::SEZ]) and
                    (not (PurchaseLine.Type in [PurchaseLine.Type::" ", PurchaseLine.Type::"Charge (Item)"])) then begin
            PurchaseLine.Validate("GST Assessable Value", LibraryRandom.RandInt(1000));
            if PurchaseLine.Type in [PurchaseLine.Type::Item, PurchaseLine.Type::"G/L Account"] then
                PurchaseLine.Validate("Custom Duty Amount", LibraryRandom.RandInt(1000));
        end;
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandInt(1000));
        PurchaseLine.Modify(true);
    end;

    local procedure UpdateReferenceInvoiceNoAndVerify(var PurchaseHeader: Record "Purchase Header")
    var
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        ReferenceInvoiceNoMgt: Codeunit "Reference Invoice No. Mgt.";
    begin
        ReferenceInvoiceNo.Init();
        ReferenceInvoiceNo.Validate("Document No.", PurchaseHeader."No.");
        case PurchaseHeader."Document Type" of
            PurchaseHeader."Document Type"::"Credit Memo":
                ReferenceInvoiceNo.Validate("Document Type", ReferenceInvoiceNo."Document Type"::"Credit Memo");
            PurchaseHeader."Document Type"::"Return Order":
                ReferenceInvoiceNo.Validate("Document Type", ReferenceInvoiceNo."Document Type"::"Return Order");
        end;
        ReferenceInvoiceNo.Validate("Source Type", ReferenceInvoiceNo."Source Type"::Vendor);
        ReferenceInvoiceNo.Validate("Source No.", PurchaseHeader."Buy-from Vendor No.");
        ReferenceInvoiceNo.Validate("Reference Invoice Nos.", Storage.Get(PostedDocumentNoLbl));
        ReferenceInvoiceNo.Insert(true);
        ReferenceInvoiceNoMgt.UpdateReferenceInvoiceNoforVendor(ReferenceInvoiceNo, ReferenceInvoiceNo."Document Type", ReferenceInvoiceNo."Document No.");
        ReferenceInvoiceNoMgt.VerifyReferenceNo(ReferenceInvoiceNo);
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