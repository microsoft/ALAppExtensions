codeunit 18194 "GST Fin Charge Memo"
{
    Subtype = Test;

    var
        LibrarySales: Codeunit "Library - Sales";
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryGST: Codeunit "Library GST";
        Assert: Codeunit Assert;
        Storage: Dictionary of [Text, Code[20]];
        StorageBoolean: Dictionary of [Text, Boolean];
        ComponentPerArray: array[20] of Decimal;
        LocationStateCodeLbl: Label 'LocationStateCode';
        ExemptedLbl: Label 'Exempted';
        LineDiscountLbl: Label 'LineDiscount';
        LocationCodeLbl: Label 'LocationCode';
        GSTGroupCodeLbl: Label 'GSTGroupCode';
        HSNSACCodeLbl: Label 'HSNSACCode';
        LocPANNoLbl: Label 'LocPANNo';
        CGSTLbl: Label 'CGST';
        FinanceChargeTermsCodeLbl: Label 'FinanceChargeTermsCode';
        SGSTLbl: Label 'SGST';
        IGSTLbl: Label 'IGST';
        FromStateCodeLbl: Label 'FromStateCode';
        CustomerNoLbl: Label 'CustomerNo';
        ToStateCodeLbl: Label 'ToStateCode';
        PostedDocumentNoLbl: Label 'PostedDocumentNo';
        GSTPaymentDutyErr: Label 'You can only select GST without payment Of Duty in Export or Deemed Export Customer.';
        GSTLEVerifyErr: Label '%1 is incorrect in %2.', Comment = '%1 and %2 = Field Caption and Table Caption';
        InvoiceTypeErr: Label 'You can not select the Invoice Type %1 for GST Customer Type %2.', Comment = '%1 = Invoice Type ; %2 = GST Customer Type';

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromFinChrgeMemoWithRegCustInterstate()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        FinanceChargeMemoHeader: Record "Finance Charge Memo Header";
        FinanceChargeMemoLine: Record "Finance Charge Memo Line";
        Type: Option " ","G/L Account","Customer Ledger Entry";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [355999] Check if the system is calculating GST on Finance Charge Memo for a Register Customer and Interstate transaction.

        // [GIVEN] Create GST Setup and tax rates for Registered Customer where GST Group Type is Service and Jurisdiction Type is Interstate
        CreateGSTSetup(Enum::"GST Customer Type"::Registered, Enum::"GST Group Type"::Service, false);
        InitializeShareStep(false, false);

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Item for Interstate Transaction
        PostedDocumentNo := CreateAndPostSalesDocument(SalesHeader, SalesLine, Enum::"Sales Line Type"::Item, Enum::"Sales Document Type"::Invoice);

        // [THEN] Create and Finance Charge Memo for Interstate Transaction
        CreateAndIssueFinanceChargeMemo(FinanceChargeMemoHeader, FinanceChargeMemoLine, Type::"Customer Ledger Entry", false);
        LibraryERM.IssueFinanceChargeMemo(FinanceChargeMemoHeader);

        // [THEN] G/L Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromFinChrgeMemoWithRegCustIntrastate()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        FinanceChargeMemoHeader: Record "Finance Charge Memo Header";
        FinanceChargeMemoLine: Record "Finance Charge Memo Line";
        Type: Option " ","G/L Account","Customer Ledger Entry";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [394574] Check if the system is calculating GST on Finance Charge Memo for a Register Customer and Intrastate transaction.

        // [GIVEN] Create GST Setup and tax rates for Registered Customer where GST Group Type is Service and Jurisdiction Type is Intrastate
        CreateGSTSetup(Enum::"GST Customer Type"::Registered, Enum::"GST Group Type"::Service, true);
        InitializeShareStep(false, false);

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Item for Intrastate Transaction
        PostedDocumentNo := CreateAndPostSalesDocument(SalesHeader, SalesLine, Enum::"Sales Line Type"::Item, Enum::"Sales Document Type"::Invoice);

        // [THEN] Create and Finance Charge Memo for Intrastate Transaction
        CreateAndIssueFinanceChargeMemo(FinanceChargeMemoHeader, FinanceChargeMemoLine, Type::"Customer Ledger Entry", false);
        LibraryERM.IssueFinanceChargeMemo(FinanceChargeMemoHeader);

        // [THEN] G/L Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure VerifyGSTWithoutPaymentOfDutyErrorForRegCust()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        FinanceChargeMemoHeader: Record "Finance Charge Memo Header";
        FinanceChargeMemoLine: Record "Finance Charge Memo Line";
        Type: Option " ","G/L Account","Customer Ledger Entry";
    begin
        // [SCENARIO] Verify GST Without Payment of Duty Error For Registered Customer

        // [GIVEN] Create GST Setup and tax rates for Registered Customer where GST Group Type is Service and Jurisdiction Type is Intrastate
        CreateGSTSetup(Enum::"GST Customer Type"::Registered, Enum::"GST Group Type"::Service, true);
        InitializeShareStep(false, false);

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Item for Intrastate Transaction
        CreateAndPostSalesDocument(SalesHeader, SalesLine, Enum::"Sales Line Type"::Item, Enum::"Sales Document Type"::Invoice);

        // [THEN] Create and Finance Charge Memo for Intrastate Transaction
        CreateAndIssueFinanceChargeMemo(FinanceChargeMemoHeader, FinanceChargeMemoLine, Type::"Customer Ledger Entry", false);
        asserterror FinanceChargeMemoHeader.Validate("GST Without Payment of Duty", true);

        // [THEN] Assert Error Verified for Registered Customer
        Assert.ExpectedError(GSTPaymentDutyErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure VerifyInvoiceTypeErrorForRegCust()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        FinanceChargeMemoHeader: Record "Finance Charge Memo Header";
        FinanceChargeMemoLine: Record "Finance Charge Memo Line";
        Type: Option " ","G/L Account","Customer Ledger Entry";
    begin
        // [SCENARIO] Verify Invoice Type Error For Registered Customer

        // [GIVEN] Create GST Setup and tax rates for Registered Customer where GST Group Type is Service and Jurisdiction Type is Intrastate
        CreateGSTSetup(Enum::"GST Customer Type"::Registered, Enum::"GST Group Type"::Service, true);
        InitializeShareStep(false, false);

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Item for Intrastate Transaction
        CreateAndPostSalesDocument(SalesHeader, SalesLine, Enum::"Sales Line Type"::Item, Enum::"Sales Document Type"::Invoice);

        // [THEN] Create and Finance Charge Memo for Intrastate Transaction
        CreateAndIssueFinanceChargeMemo(FinanceChargeMemoHeader, FinanceChargeMemoLine, Type::"Customer Ledger Entry", false);
        asserterror FinanceChargeMemoHeader.Validate("Invoice Type", FinanceChargeMemoHeader."Invoice Type"::"Bill of Supply");

        // [THEN] Assert Error Verified for Registered Customer
        Assert.ExpectedError(StrSubstNo(InvoiceTypeErr, FinanceChargeMemoHeader."Invoice Type"::"Bill of Supply", FinanceChargeMemoHeader."GST Customer Type"));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromFinChrgeMemoWithExemptedCustIntrastate()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        FinanceChargeMemoHeader: Record "Finance Charge Memo Header";
        FinanceChargeMemoLine: Record "Finance Charge Memo Line";
        Type: Option " ","G/L Account","Customer Ledger Entry";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [395047] Check if the system is calculating GST on Finance Charge Memo for a Exempted Customer and Intrastate transaction.

        // [GIVEN] Create GST Setup and tax rates for Exempted Customer where GST Group Type is Service and Jurisdiction Type is Intrastate
        CreateGSTSetup(Enum::"GST Customer Type"::Exempted, Enum::"GST Group Type"::Service, true);
        InitializeShareStep(true, false);

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Item for Intrastate Transaction
        PostedDocumentNo := CreateAndPostSalesDocument(SalesHeader, SalesLine, Enum::"Sales Line Type"::Item, Enum::"Sales Document Type"::Invoice);

        // [THEN] Create and Finance Charge Memo for Intrastate Transaction
        CreateAndIssueFinanceChargeMemo(FinanceChargeMemoHeader, FinanceChargeMemoLine, Type::"Customer Ledger Entry", true);
        LibraryERM.IssueFinanceChargeMemo(FinanceChargeMemoHeader);

        // [THEN] G/L Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromFinChrgeMemoWithExemptedCustInterstate()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        FinanceChargeMemoHeader: Record "Finance Charge Memo Header";
        FinanceChargeMemoLine: Record "Finance Charge Memo Line";
        Type: Option " ","G/L Account","Customer Ledger Entry";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [395028] Check if the system is calculating GST on Finance Charge Memo for a Exempted Customer and Interstate transaction.

        // [GIVEN] Create GST Setup and tax rates for Exempted Customer where GST Group Type is Service and Jurisdiction Type is Interstate
        CreateGSTSetup(Enum::"GST Customer Type"::Exempted, Enum::"GST Group Type"::Service, false);
        InitializeShareStep(true, false);

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Item for Interstate Transaction
        PostedDocumentNo := CreateAndPostSalesDocument(SalesHeader, SalesLine, Enum::"Sales Line Type"::Item, Enum::"Sales Document Type"::Invoice);

        // [THEN] Create and Finance Charge Memo for Interstate Transaction
        CreateAndIssueFinanceChargeMemo(FinanceChargeMemoHeader, FinanceChargeMemoLine, Type::"Customer Ledger Entry", true);
        LibraryERM.IssueFinanceChargeMemo(FinanceChargeMemoHeader);

        // [THEN] G/L Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromFinChrgeMemoWithSEZDevelopmntCustInterstate()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        FinanceChargeMemoHeader: Record "Finance Charge Memo Header";
        FinanceChargeMemoLine: Record "Finance Charge Memo Line";
        Type: Option " ","G/L Account","Customer Ledger Entry";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [395070] Check if the system is calculating GST on Finance Charge Memo for a SEZ Development Customer and Interstate transaction.

        // [GIVEN] Create GST Setup and tax rates for SEZ Development Customer where GST Group Type is Service and Jurisdiction Type is Interstate
        CreateGSTSetup(Enum::"GST Customer Type"::"SEZ Development", Enum::"GST Group Type"::Service, false);
        InitializeShareStep(false, false);

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Item for Interstate Transaction
        PostedDocumentNo := CreateAndPostSalesDocument(SalesHeader, SalesLine, Enum::"Sales Line Type"::Item, Enum::"Sales Document Type"::Invoice);

        // [THEN] Create and Finance Charge Memo for Interstate Transaction
        CreateAndIssueFinanceChargeMemo(FinanceChargeMemoHeader, FinanceChargeMemoLine, Type::"Customer Ledger Entry", false);
        LibraryERM.IssueFinanceChargeMemo(FinanceChargeMemoHeader);

        // [THEN] G/L Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(PostedDocumentNo);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromFinChrgeMemoWithDeemedExportCustInterstate()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        FinanceChargeMemoHeader: Record "Finance Charge Memo Header";
        FinanceChargeMemoLine: Record "Finance Charge Memo Line";
        Type: Option " ","G/L Account","Customer Ledger Entry";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] [395080] Check if the system is calculating GST on Finance Charge Memo for a Deemred Customer and Interstate transaction..

        // [GIVEN] Create GST Setup and tax rates for Deemed Export Customer where GST Group Type is Service and Jurisdiction Type is Interstate
        CreateGSTSetup(Enum::"GST Customer Type"::"Deemed Export", Enum::"GST Group Type"::Service, false);
        InitializeShareStep(false, false);

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Item for Interstate Transaction
        PostedDocumentNo := CreateAndPostSalesDocument(SalesHeader, SalesLine, Enum::"Sales Line Type"::Item, Enum::"Sales Document Type"::Invoice);

        // [THEN] Create and Finance Charge Memo for Interstate Transaction
        CreateAndIssueFinanceChargeMemo(FinanceChargeMemoHeader, FinanceChargeMemoLine, Type::"Customer Ledger Entry", false);
        LibraryERM.IssueFinanceChargeMemo(FinanceChargeMemoHeader);

        // [THEN] G/L Entries and Detailed GST Ledger Entries Verified
        VerifyGSTEntries(PostedDocumentNo);
    end;

    local procedure CreateSalesHeaderWithGST(
        var SalesHeader: Record "Sales Header";
        CustomerNo: Code[20];
        DocumentType: Enum "Sales Document Type";
        LocationCode: Code[10])
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, CustomerNo);
        SalesHeader.Validate("Posting Date", CalcDate('<-1M>', WorkDate()));
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
                LineTypeNo := LibraryGST.CreateItemWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), true, Exempted);
            LineType::"G/L Account":
                LineTypeNo := LibraryGST.CreateGLAccWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), true, false);
        end;

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, LineType, LineTypeno, Quantity);
        SalesLine.Validate("VAT Prod. Posting Group", VATPostingsetup."VAT Prod. Posting Group");
        if LineDiscount then begin
            SalesLine.Validate("Line Discount %", LibraryRandom.RandDecInRange(10, 20, 2));
            LibraryGST.UpdateLineDiscAccInGeneralPostingSetup(SalesLine."Gen. Bus. Posting Group", SalesLine."Gen. Prod. Posting Group");
        end;

        if Exempted then
            SalesLine.Validate(Exempted, StorageBoolean.Get(ExemptedLbl));

        SalesLine.Validate("Unit Price", LibraryRandom.RandInt(10000));
        SalesLine.Modify(true);
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

    local procedure CreateAndIssueFinanceChargeMemo(
        var FinanceChargeMemoHeader: Record "Finance Charge Memo Header";
        var FinanceChargeMemoLine: Record "Finance Charge Memo Line";
        Type: Option " ","G/L Account","Customer Ledger Entry";
        Exempted: Boolean)
    var
        CalculateTax: Codeunit "Calculate Tax";
        CustomerNo: Code[20];
    begin
        CreateFinanceChargeTerms();
        CustomerNo := Storage.Get(CustomerNoLbl);
        LibraryERM.CreateFinanceChargeMemoHeader(FinanceChargeMemoHeader, CustomerNo);
        FinanceChargeMemoHeader.Validate("Fin. Charge Terms Code", Storage.Get(FinanceChargeTermsCodeLbl));
        FinanceChargeMemoHeader.Validate("Location Code", Storage.Get(LocationCodeLbl));
        FinanceChargeMemoHeader.Modify(true);
        LibraryERM.CreateFinanceChargeMemoLine(FinanceChargeMemoLine, FinanceChargeMemoHeader."No.", Type);
        FinanceChargeMemoLine.Validate("Document Type", FinanceChargeMemoLine."Document Type"::Invoice);
        FinanceChargeMemoLine.Validate("Document No.", Storage.Get(PostedDocumentNoLbl));
        FinanceChargeMemoLine.Validate("GST Group Code", Storage.Get(GSTGroupCodeLbl));
        FinanceChargeMemoLine.Validate("HSN/SAC Code", Storage.Get(HSNSACCodeLbl));
        CalculateTax.CallTaxEngineOnFinanceChargeMemoLine(FinanceChargeMemoLine, FinanceChargeMemoLine);

        if Exempted then
            FinanceChargeMemoLine.Validate(Exempted, StorageBoolean.Get(ExemptedLbl));

        FinanceChargeMemoLine.Modify();
    end;

    local procedure CreateFinanceChargeTerms()
    var
        FinanceChargeTerms: Record "Finance Charge Terms";
        DueDate: DateFormula;
    begin
        LibraryERM.CreateFinanceChargeTerms(FinanceChargeTerms);
        FinanceChargeTerms.Validate("Interest Period (Days)", 30);
        FinanceChargeTerms.Validate("Interest Rate", 1);
        Evaluate(DueDate, '30D');
        FinanceChargeTerms.Validate("Due Date Calculation", DueDate);
        FinanceChargeTerms.Modify(true);
        Storage.Set(FinanceChargeTermsCodeLbl, FinanceChargeTerms.Code);
    end;

    local procedure VerifyGSTEntries(PostedDocumentNo: Code[20])
    var
        FinanceChargeMemoLine: Record "Finance Charge Memo Line";
        ComponentList: List of [Code[30]];
    begin
        FinanceChargeMemoLine.SetRange("Document No.", PostedDocumentNo);
        if FinanceChargeMemoLine.FindSet() then
            repeat
                FillComponentList(FinanceChargeMemoLine."GST Jurisdiction Type", ComponentList, FinanceChargeMemoLine."GST Group Code");
                VerifyGSTEntriesForService(FinanceChargeMemoLine, PostedDocumentNo, ComponentList);
                VerifyDetailedGSTEntriesForService(FinanceChargeMemoLine, PostedDocumentNo, ComponentList);
            until FinanceChargeMemoLine.Next() = 0;
    end;

    local procedure FillComponentList(
        GSTJurisdictionType: Enum "GST Jurisdiction Type";
        var ComponentList: List of [Code[30]];
        GSTGroupCode: Code[20])
    var
        GSTGroup: Record "GST Group";
    begin
        GSTGroup.Get(GSTGroupCode);
        Clear(ComponentList);
        if GSTJurisdictionType = GSTJurisdictionType::Intrastate then begin
            ComponentList.Add(CGSTLbl);
            ComponentList.Add(SGSTLbl);
        end else
            ComponentList.Add(IGSTLbl);
    end;

    local procedure GetFinanceChargeMemoGSTAmount(
        FinanceChargeMemoLine: Record "Finance Charge Memo Line"): Decimal
    var
        FinanceChargeMemoHeader: Record "Finance Charge Memo Header";
    begin
        FinanceChargeMemoHeader.Get(FinanceChargeMemoLine."Document No.");

        if FinanceChargeMemoHeader."GST Customer Type" in [FinanceChargeMemoHeader."GST Customer Type"::Registered,
                  FinanceChargeMemoHeader."GST Customer Type"::Unregistered,
                  FinanceChargeMemoHeader."GST Customer Type"::Export,
                  FinanceChargeMemoHeader."GST Customer Type"::"Deemed Export",
                  FinanceChargeMemoHeader."GST Customer Type"::"SEZ Development",
                  FinanceChargeMemoHeader."GST Customer Type"::"SEZ Unit"] then
            if FinanceChargeMemoLine."GST Jurisdiction Type" = FinanceChargeMemoLine."GST Jurisdiction Type"::Interstate then
                exit((FinanceChargeMemoLine.Amount * ComponentPerArray[4]) / 100)
            else
                exit(FinanceChargeMemoLine.Amount * ComponentPerArray[1] / 100)
        else
            if FinanceChargeMemoHeader."GST Customer Type" = FinanceChargeMemoHeader."GST Customer Type"::Exempted then
                exit(0.00);
    end;

    local procedure VerifyGSTEntriesForService(
        var FinanceChargeMemoLine: Record "Finance Charge Memo Line";
        PostedDocumentNo: Code[20];
        var ComponentList: List of [Code[30]])
    var
        GSTLedgerEntry: Record "GST Ledger Entry";
        FinanceChargeMemoHeader: Record "Finance Charge Memo Header";
        SourceCodeSetup: Record "Source Code Setup";
        GLEntry: Record "G/L Entry";
        ComponentCode: Code[30];
    begin
        FinanceChargeMemoHeader.Get(PostedDocumentNo);

        SourceCodeSetup.Get();
        GLEntry.SetRange("Document No.", PostedDocumentNo);
        GLEntry.FindFirst();

        foreach ComponentCode in ComponentList do begin
            GSTLedgerEntry.Reset();
            GSTLedgerEntry.SetRange("GST Component Code", ComponentCode);
            GSTLedgerEntry.SetRange("Document No.", PostedDocumentNo);
            GSTLedgerEntry.FindFirst();
        end;

        Assert.AreEqual(FinanceChargeMemoHeader."Gen. Bus. Posting Group", GSTLedgerEntry."Gen. Bus. Posting Group",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldName("Gen. Bus. Posting Group"), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(FinanceChargeMemoLine."Gen. Prod. Posting Group", GSTLedgerEntry."Gen. Prod. Posting Group",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Gen. Prod. Posting Group"), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(FinanceChargeMemoHeader."Posting Date", GSTLedgerEntry."Posting Date",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Posting Date"), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(GSTLedgerEntry."Document Type"::Invoice, GSTLedgerEntry."Document Type",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Document Type"), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(GSTLedgerEntry."Transaction Type"::Sales, GSTLedgerEntry."Transaction Type",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Transaction Type"), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(GSTLedgerEntry."Source Type"::Customer, GSTLedgerEntry."Source Type",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Source Type"), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(GSTLedgerEntry."GST Component Code", GSTLedgerEntry."GST Component Code",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("GST Component Code"), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(FinanceChargeMemoHeader."Customer No.", GSTLedgerEntry."Source No.",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Source No."), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(UserId, GSTLedgerEntry."User ID",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("User ID"), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(SourceCodeSetup."Finance Charge Memo", GSTLedgerEntry."Source Code",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Source Code"), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(GLEntry."Transaction No.", GSTLedgerEntry."Transaction No.",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Transaction No."), GSTLedgerEntry.TableCaption));

        Assert.AreEqual(GSTLedgerEntry."Entry Type"::"Initial Entry", GSTLedgerEntry."Entry Type",
            StrSubstNo(GSTLEVerifyErr, GSTLedgerEntry.FieldCaption("Entry Type"), GSTLedgerEntry.TableCaption));
    end;

    local procedure VerifyDetailedGSTEntriesForService(
        var FinanceChargeMemoLine: Record "Finance Charge Memo Line";
        PostedDocumentNo: Code[20];
        var ComponentList: List of [Code[30]])
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        FinanceChargeMemoHeader: Record "Finance Charge Memo Header";
        SourceCodeSetup: Record "Source Code Setup";
        Customer: Record Customer;
        GLEntry: Record "G/L Entry";
        GSTAmount: Decimal;
        ComponentCode: Code[30];
    begin
        FinanceChargeMemoHeader.Get(PostedDocumentNo);

        Customer.Get(FinanceChargeMemoHeader."Customer No.");
        SourceCodeSetup.Get();

        GLEntry.SetRange("Document No.", PostedDocumentNo);
        GLEntry.FindFirst();

        foreach ComponentCode in ComponentList do begin
            DetailedGSTLedgerEntry.Reset();
            DetailedGSTLedgerEntry.SetRange("GST Component Code", ComponentCode);
            DetailedGSTLedgerEntry.SetRange("Document No.", PostedDocumentNo);
            DetailedGSTLedgerEntry.SetRange("Document Line No.", FinanceChargeMemoLine."Line No.");
            DetailedGSTLedgerEntry.FindFirst();
        end;

        GSTAmount := GetFinanceChargeMemoGSTAmount(FinanceChargeMemoLine);

        DetailedGSTLedgerEntryInfo.Get(DetailedGSTLedgerEntry."Entry No.");

        Assert.AreEqual(DetailedGSTLedgerEntry."Entry Type"::"Initial Entry", DetailedGSTLedgerEntry."Entry Type",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Entry Type"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(DetailedGSTLedgerEntry."Transaction Type"::Sales, DetailedGSTLedgerEntry."Transaction Type",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Transaction Type"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(DetailedGSTLedgerEntry."Document Type"::Invoice, DetailedGSTLedgerEntry."Document Type",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Document Type"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(FinanceChargeMemoHeader."Posting Date", DetailedGSTLedgerEntry."Posting Date",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Posting Date"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(FinanceChargeMemoLine.Type::"G/L Account", DetailedGSTLedgerEntry.Type,
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption(Type), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(DetailedGSTLedgerEntry."Source Type"::Customer, DetailedGSTLedgerEntry."Source Type",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Source Type"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(LibraryGST.GetGSTPayableAccountNo(FinanceChargeMemoHeader."Location State Code", DetailedGSTLedgerEntry."GST Component Code"), DetailedGSTLedgerEntry."G/L Account No.",
                StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("G/L Account No."), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(FinanceChargeMemoHeader."Customer No.", DetailedGSTLedgerEntry."Source No.",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Source No."), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(FinanceChargeMemoLine."HSN/SAC Code", DetailedGSTLedgerEntry."HSN/SAC Code",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("HSN/SAC Code"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(FinanceChargeMemoLine."GST Group Code", DetailedGSTLedgerEntry."GST Group Code",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Group Code"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(FinanceChargeMemoLine."GST Jurisdiction Type", DetailedGSTLedgerEntry."GST Jurisdiction Type",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Jurisdiction Type"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(ComponentCode, DetailedGSTLedgerEntry."GST Component Code",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Component Code"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreNearlyEqual(-FinanceChargeMemoLine.Amount, DetailedGSTLedgerEntry."GST Base Amount", LibraryGST.GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"),
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Base Amount"), DetailedGSTLedgerEntry.TableCaption));

        if FinanceChargeMemoHeader."GST Customer Type" in [FinanceChargeMemoHeader."GST Customer Type"::Registered,
           FinanceChargeMemoHeader."GST Customer Type"::Unregistered,
           FinanceChargeMemoHeader."GST Customer Type"::Export,
           FinanceChargeMemoHeader."GST Customer Type"::"Deemed Export",
           FinanceChargeMemoHeader."GST Customer Type"::"SEZ Development",
           FinanceChargeMemoHeader."GST Customer Type"::"SEZ Unit"] then
            if DetailedGSTLedgerEntry."GST Jurisdiction Type" = DetailedGSTLedgerEntry."GST Jurisdiction Type"::Interstate then
                Assert.AreEqual(ComponentPerArray[4], DetailedGSTLedgerEntry."GST %",
                    StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST %"), DetailedGSTLedgerEntry.TableCaption))
            else
                Assert.AreEqual(ComponentPerArray[1], DetailedGSTLedgerEntry."GST %",
                    StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST %"), DetailedGSTLedgerEntry.TableCaption))
        else
            Assert.AreEqual(0.00, DetailedGSTLedgerEntry."GST %",
                    StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST %"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreNearlyEqual(-GSTAmount, DetailedGSTLedgerEntry."GST Amount", LibraryGST.GetGSTRoundingPrecision(DetailedGSTLedgerEntry."GST Component Code"),
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Amount"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(-1.00, DetailedGSTLedgerEntry.Quantity,
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName(Quantity), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(UserId, DetailedGSTLedgerEntryInfo."User ID",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("User ID"), DetailedGSTLedgerEntryInfo.TableCaption));

        Assert.AreEqual(false, DetailedGSTLedgerEntryInfo.Positive,
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption(Positive), DetailedGSTLedgerEntryInfo.TableCaption));

        Assert.AreEqual(FinanceChargeMemoLine."Line No.", DetailedGSTLedgerEntry."Document Line No.",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Reverse Charge"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(FinanceChargeMemoHeader."Nature of Supply", DetailedGSTLedgerEntryInfo."Nature of Supply",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Nature of Supply"), DetailedGSTLedgerEntryInfo.TableCaption));

        Assert.AreEqual(FinanceChargeMemoHeader."Location State Code", DetailedGSTLedgerEntryInfo."Location State Code",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Location State Code"), DetailedGSTLedgerEntryInfo.TableCaption));

        Assert.AreEqual(Customer."State Code", DetailedGSTLedgerEntryInfo."Buyer/Seller State Code",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Buyer/Seller State Code"), DetailedGSTLedgerEntryInfo.TableCaption));

        Assert.AreEqual(FinanceChargeMemoHeader."Location GST Reg. No.", DetailedGSTLedgerEntry."Location  Reg. No.",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("Location  Reg. No."), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(FinanceChargeMemoHeader."Customer GST Reg. No.", DetailedGSTLedgerEntry."Buyer/Seller Reg. No.",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("Buyer/Seller Reg. No."), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(FinanceChargeMemoLine."GST Group Type", DetailedGSTLedgerEntry."GST Group Type",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("GST Group Type"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(DetailedGSTLedgerEntry."GST Credit", DetailedGSTLedgerEntry."GST Credit",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldName("GST Credit"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(GLEntry."Transaction No.", DetailedGSTLedgerEntry."Transaction No.",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Transaction No."), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(DetailedGSTLedgerEntryInfo."Original Doc. Type"::Invoice, DetailedGSTLedgerEntryInfo."Original Doc. Type",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Original Doc. Type"), DetailedGSTLedgerEntryInfo.TableCaption));

        Assert.AreEqual(PostedDocumentNo, DetailedGSTLedgerEntryInfo."Original Doc. No.",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Original Doc. No."), DetailedGSTLedgerEntryInfo.TableCaption));

        Assert.AreEqual(FinanceChargeMemoHeader."Location Code", DetailedGSTLedgerEntry."Location Code",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("Location Code"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(FinanceChargeMemoHeader."GST Customer Type", DetailedGSTLedgerEntry."GST Customer Type",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntry.FieldCaption("GST Vendor Type"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(FinanceChargeMemoHeader."Gen. Bus. Posting Group", DetailedGSTLedgerEntryInfo."Gen. Bus. Posting Group",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldName("Gen. Bus. Posting Group"), DetailedGSTLedgerEntryInfo.TableCaption));

        Assert.AreEqual(FinanceChargeMemoLine."Gen. Prod. Posting Group", DetailedGSTLedgerEntryInfo."Gen. Prod. Posting Group",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Gen. Prod. Posting Group"), DetailedGSTLedgerEntryInfo.TableCaption));

        Assert.AreEqual(FinanceChargeMemoHeader."Invoice Type", DetailedGSTLedgerEntryInfo."Sales Invoice Type",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Sales Invoice Type"), DetailedGSTLedgerEntry.TableCaption));

        Assert.AreEqual(DetailedGSTLedgerEntryInfo."Component Calc. Type"::General, DetailedGSTLedgerEntryInfo."Component Calc. Type",
            StrSubstNo(GSTLEVerifyErr, DetailedGSTLedgerEntryInfo.FieldCaption("Component Calc. Type"), DetailedGSTLedgerEntry.TableCaption));
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
            CompanyInformation."P.A.N. No." := LibraryGST.CreatePANNos();
            CompanyInformation.Modify();
        end else
            LocPANNo := CompanyInformation."P.A.N. No.";

        LocPANNo := CompanyInformation."P.A.N. No.";
        Storage.Set(LocPANNoLbl, LocPANNo);

        LibraryGST.CreateNoVatSetup();

        LocationStateCode := LibraryGST.CreateInitialSetup();
        Storage.Set(LocationStateCodeLbl, LocationStateCode);

        LocationGSTRegNo := LibraryGST.CreateGSTRegistrationNos(LocationStateCode, LocPANNo);
        if CompanyInformation."GST Registration No." = '' then begin
            CompanyInformation."GST Registration No." := LocationGSTRegNo;
            CompanyInformation.Modify(true);
        end;

        LocationCode := LibraryGST.CreateLocationSetup(LocationStateCode, LocationGSTRegNo, false);
        Storage.Set(LocationCodeLbl, LocationCode);

        GSTGroupCode := LibraryGST.CreateGSTGroup(GSTGroup, GSTGroupType, GSTGroup."GST Place Of Supply"::"Bill-to Address", false);
        Storage.Set(GSTGroupCodeLbl, GSTGroupCode);

        HSNSACCode := LibraryGST.CreateHSNSACCode(HSNSAC, GSTGroupCode, HsnSacType::HSN);
        Storage.Set(HSNSACCodeLbl, HSNSACCode);

        CustomerNo := LibraryGST.CreateCustomerSetup();
        Storage.Set(CustomerNoLbl, CustomerNo);

        if IntraState then
            CreateSetupForIntraStateCustomer(GSTCustomerType, IntraState)
        else
            CreateSetupForInterStateCustomer(GSTCustomerType, IntraState);

        CreateTaxRate();
        CreateGSTComponentAndPostingSetup(IntraState, LocationStateCode, TaxComponent, GSTComponentCode);
    end;

    local procedure InitializeShareStep(
        Exempted: Boolean;
        LineDiscount: Boolean)
    begin
        StorageBoolean.Set(ExemptedLbl, Exempted);
        StorageBoolean.Set(LineDiscountLbl, LineDiscount);
    end;

    local procedure CreateSetupForIntraStateCustomer(GSTCustomerType: Enum "GST Customer Type"; IntraState: Boolean)
    var
        LocationStateCode: Code[10];
        CustomerNo: Code[20];
        LocPANNo: Code[20];
    begin
        CustomerNo := Storage.Get(CustomerNoLbl);
        LocationStateCode := (Storage.Get(LocationStateCodeLbl));
        LocPANNo := Storage.Get(LocPANNoLbl);
        UpdateCustomerSetupWithGST(CustomerNo, GSTCustomerType, LocationStateCode, LocPANNo);
        InitializeTaxRateParameters(IntraState, LocationStateCode, LocationStateCode);
    end;

    local procedure CreateGSTComponentAndPostingSetup(
        IntraState: Boolean;
        LocationStateCode: Code[10];
        TaxComponent: Record "Tax Component";
        GSTComponentcode: Text[30])
    begin
        if IntraState then begin
            GSTComponentcode := CGSTLbl;
            LibraryGST.CreateGSTComponent(TaxComponent, GSTComponentcode);
            LibraryGST.CreateGSTPostingSetup(TaxComponent, LocationStateCode);

            GSTComponentcode := SGSTLbl;
            LibraryGST.CreateGSTComponent(TaxComponent, GSTComponentcode);
            LibraryGST.CreateGSTPostingSetup(TaxComponent, LocationStateCode);
        end else begin
            GSTComponentcode := IGSTLbl;
            LibraryGST.CreateGSTComponent(TaxComponent, GSTComponentcode);
            LibraryGST.CreateGSTPostingSetup(TaxComponent, LocationStateCode);
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
        if GSTCustomerType <> GSTCustomerType::Export then begin
            State.Get(StateCode);
            Customer.Validate("State Code", StateCode);
            Customer.Validate("P.A.N. No.", PANNo);
            if not ((GSTCustomerType = GSTCustomerType::" ") or (GSTCustomerType = GSTCustomerType::Unregistered)) then
                Customer.Validate("GST Registration No.", LibraryGST.GenerateGSTRegistrationNo(State."State Code (GST Reg. No.)", PANNo));
        end;

        Customer.Validate(Address, CopyStr(LibraryUtility.GenerateGUID(), 1, MaxStrLen(Customer.Address)));
        Customer.Validate("GST Customer Type", GSTCustomerType);
        if GSTCustomerType = GSTCustomerType::Export then
            Customer.Validate("Currency Code", LibraryGST.CreateCurrencyCode());
        Customer.Modify(true);
    end;

    local procedure CreateSetupForInterStateCustomer(GSTCustomerType: Enum "GST Customer Type"; IntraState: Boolean)
    var
        LocationStateCode: Code[10];
        CustomerStateCode: Code[10];
        CustomerNo: Code[20];
        LocPANNo: Code[20];
    begin
        CustomerNo := Storage.Get(CustomerNoLbl);
        LocationStateCode := (Storage.Get(LocationStateCodeLbl));
        LocPANNo := Storage.Get(LocPANNoLbl);
        CustomerStateCode := LibraryGST.CreateGSTStateCode();
        UpdateCustomerSetupWithGST(CustomerNo, GSTCustomerType, CustomerStateCode, LocPANNo);

        if GSTCustomerType in [GSTCustomerType::Export, GSTCustomerType::"SEZ Unit", GSTCustomerType::"SEZ Development", GSTCustomerType::"Deemed Export"] then
            InitializeTaxRateParameters(IntraState, '', LocationStateCode)
        else
            InitializeTaxRateParameters(IntraState, CustomerStateCode, LocationStateCode);
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
        TaxRates.AttributeValue7.SetValue(ComponentPerArray[1]);
        TaxRates.AttributeValue8.SetValue(ComponentPerArray[2]);
        TaxRates.AttributeValue9.SetValue(ComponentPerArray[4]);
        TaxRates.AttributeValue10.SetValue(ComponentPerArray[5]);
        TaxRates.OK().Invoke();
    end;
}