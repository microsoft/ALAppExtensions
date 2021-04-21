codeunit 18192 "GST TCS Transactions"
{
    Subtype = Test;

    var
        GSTTCSLibrary: Codeunit "GST TCS Library";
        LibrarySales: Codeunit "Library - Sales";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryGST: Codeunit "Library GST";
        LibraryRandom: Codeunit "Library - Random";
        LibraryStorage: Dictionary of [Text, Text];
        StorageBoolean: Dictionary of [Text, Boolean];
        TaxType: Code[20];
        ComponentPerArray: array[20] of Decimal;
        LocationCodeLbl: Label 'LocationCode';
        LocationStateCodeLbl: Label 'LocationStateCode';
        WithoutPaymentofDutyLbl: Label 'WithoutPaymentofDuty';
        PANNoLbl: Label 'PANNo';
        POSLbl: Label 'POS';
        NoOfLineLbl: Label 'NoOfLine';
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
        SurchargeThresholdAmountLbl: Label 'SurchargeThresholdAmount';
        TCSThresholdAmountLbl: Label 'TCSThresholdAmount';
        SHECessPercentageLbl: Label 'SHECessPercentage';
        eCessPercentageLbl: Label 'eCessPercentage';
        SurchargePercentageLbl: Label 'SurchargePercentage';
        NonPANTCSPercentageLbl: Label 'NonPANTCSPercentage';
        TCSPercentageLbl: Label 'TCSPercentage';
        EffectiveDateLbl: Label 'EffectiveDate';
        TCSNOCTypeLbl: Label 'TCSNOCType';
        TCSConcessionalCodeLbl: Label 'TCSConcessionalCode';
        TCSAssesseeCodeLbl: Label 'TCSAssesseeCode';

    // [SCENARIO] [354593]- Check if the system is calculating TCS and GST on Intra-State Sale of Goods through Sale Quotes.
    [Test]
    [HandlerFunctions('GSTTCSTaxRatesPage')]
    procedure GSTTCSIntraStateSalesOfGoodsThroughSalesQuotes()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomerType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        LocationCode: Code[10];
        CustomerNo: Code[20];
        TCSNOC: Code[10];
        TCSConcessionalCode: Code[10];
    begin
        // [GIVEN] Created GST and TCS Setup
        CreateGSTSetup(GSTCustomerType::Registered, GSTGroupType::Goods, true);
        InitializeSharedStep(false, false);
        CustomerNo := CopyStr(LibraryStorage.Get(CustomerNoLbl), 1, MaxStrLen(CustomerNo));
        Customer.Get(CustomerNo);
        LocationCode := CopyStr(LibraryStorage.Get(LocationCodeLbl), 1, MaxStrLen(LocationCode));
        GSTTCSLibrary.CreateGSTTCSSetup(Customer, TCSNOC, TCSConcessionalCode, LocationCode);
        GSTTCSLibrary.UpdateCustomerNOC(Customer, true, true);
        CreateTaxRateSetup(TCSNOC, Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Quote with GST and Line Type as Item for Intrastate Transactions
        LibraryStorage.Set(NoOfLineLbl, '1');
        CreateSalesDocument(SalesHeader, SalesLine, LineType::Item, DocumentType::Quote);

        // [THEN] Quote to Make Order Conversion
        LibrarySales.QuoteMakeOrder(SalesHeader);
    end;

    // [SCENARIO] [354633]- Check if the system is calculating TCS and GST on Inter-State Sale of Services to Unregistered Customer through Sale Orders.
    [Test]
    [HandlerFunctions('GSTTCSTaxRatesPage')]
    procedure GSTTCSInterStateSalesOfServicesThroughSalesOrdersForUnregisteredCust()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomerType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
        LocationCode: Code[10];
        CustomerNo: Code[20];
        TCSNOC: Code[10];
        TCSConcessionalCode: Code[10];
    begin
        // [GIVEN] Created GST and TCS Setup
        CreateGSTSetup(GSTCustomerType::Unregistered, GSTGroupType::Service, false);
        InitializeSharedStep(false, false);
        CustomerNo := CopyStr(LibraryStorage.Get(CustomerNoLbl), 1, MaxStrLen(CustomerNo));
        Customer.Get(CustomerNo);
        LocationCode := CopyStr(LibraryStorage.Get(LocationCodeLbl), 1, MaxStrLen(LocationCode));
        GSTTCSLibrary.CreateGSTTCSSetup(Customer, TCSNOC, TCSConcessionalCode, LocationCode);
        GSTTCSLibrary.UpdateCustomerNOC(Customer, true, true);
        CreateTaxRateSetup(TCSNOC, Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Order with GST and Line Type as G/L Account for Intrastate Transactions
        LibraryStorage.Set(NoOfLineLbl, '1');
        PostedDocumentNo := CreateAndPostSalesDocument(SalesHeader, SalesLine, LineType::"G/L Account", DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(SalesHeader."Document Type"::Order, PostedDocumentNo, 5);
    end;

    // [SCENARIO] [354600]- Check if the system is calculating TCS and GST on Intra-State Sale of Services through Sale Orders.
    [Test]
    [HandlerFunctions('GSTTCSTaxRatesPage')]
    procedure GSTTCSIntraStateSalesOfServicesThroughSalesOrders()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomerType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
        LocationCode: Code[10];
        CustomerNo: Code[20];
        TCSNOC: Code[10];
        TCSConcessionalCode: Code[10];
    begin
        // [GIVEN] Created GST and TCS Setup
        CreateGSTSetup(GSTCustomerType::Registered, GSTGroupType::Service, true);
        InitializeSharedStep(false, false);
        CustomerNo := CopyStr(LibraryStorage.Get(CustomerNoLbl), 1, MaxStrLen(CustomerNo));
        Customer.Get(CustomerNo);
        LocationCode := CopyStr(LibraryStorage.Get(LocationCodeLbl), 1, MaxStrLen(LocationCode));
        GSTTCSLibrary.CreateGSTTCSSetup(Customer, TCSNOC, TCSConcessionalCode, LocationCode);
        GSTTCSLibrary.UpdateCustomerNOC(Customer, true, true);
        CreateTaxRateSetup(TCSNOC, Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Order with GST and Line Type as G/L Account for Intrastate Transactions
        LibraryStorage.Set(NoOfLineLbl, '1');
        PostedDocumentNo := CreateAndPostSalesDocument(SalesHeader, SalesLine, LineType::"G/L Account", DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(SalesHeader."Document Type"::Order, PostedDocumentNo, 5);
    end;

    // [SCENARIO] [354601]- Check if the system is calculating TCS and GST on Intra-State Sale of Services through Sale Invoices.
    [Test]
    [HandlerFunctions('GSTTCSTaxRatesPage')]
    procedure GSTTCSIntraStateSalesOfServicesThroughSalesInvoices()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomerType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
        LocationCode: Code[10];
        CustomerNo: Code[20];
        TCSNOC: Code[10];
        TCSConcessionalCode: Code[10];
    begin
        // [GIVEN] Created GST and TCS Setup
        CreateGSTSetup(GSTCustomerType::Registered, GSTGroupType::Service, true);
        InitializeSharedStep(false, false);
        CustomerNo := CopyStr(LibraryStorage.Get(CustomerNoLbl), 1, MaxStrLen(CustomerNo));
        Customer.Get(CustomerNo);
        LocationCode := CopyStr(LibraryStorage.Get(LocationCodeLbl), 1, MaxStrLen(LocationCode));
        GSTTCSLibrary.CreateGSTTCSSetup(Customer, TCSNOC, TCSConcessionalCode, LocationCode);
        GSTTCSLibrary.UpdateCustomerNOC(Customer, true, true);
        CreateTaxRateSetup(TCSNOC, Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Order with GST and Line Type as G/L Account for Intrastate Transactions
        LibraryStorage.Set(NoOfLineLbl, '1');
        PostedDocumentNo := CreateAndPostSalesDocument(SalesHeader, SalesLine, LineType::"G/L Account", DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(SalesHeader."Document Type"::Order, PostedDocumentNo, 5);
    end;

    // [SCENARIO] [354599]- Check if the system is calculating TCS and GST on Intra-State Sale of Services through Sale Quotes.
    [Test]
    [HandlerFunctions('GSTTCSTaxRatesPage')]
    procedure GSTTCSIntraStateSalesOfServicesThroughSalesQuotes()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomerType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        LocationCode: Code[10];
        CustomerNo: Code[20];
        TCSNOC: Code[10];
        TCSConcessionalCode: Code[10];
    begin
        // [GIVEN] Created GST and TCS Setup
        CreateGSTSetup(GSTCustomerType::Registered, GSTGroupType::Service, true);
        InitializeSharedStep(false, false);
        CustomerNo := CopyStr(LibraryStorage.Get(CustomerNoLbl), 1, MaxStrLen(CustomerNo));
        Customer.Get(CustomerNo);
        LocationCode := CopyStr(LibraryStorage.Get(LocationCodeLbl), 1, MaxStrLen(LocationCode));
        GSTTCSLibrary.CreateGSTTCSSetup(Customer, TCSNOC, TCSConcessionalCode, LocationCode);
        GSTTCSLibrary.UpdateCustomerNOC(Customer, true, true);
        CreateTaxRateSetup(TCSNOC, Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Quote with GST and Line Type as G/L Account for Intrastate Transactions
        LibraryStorage.Set(NoOfLineLbl, '1');
        CreateSalesDocument(SalesHeader, SalesLine, LineType::"G/L Account", DocumentType::Quote);

        // [THEN] Quote to Make Order Conversion
        LibrarySales.QuoteMakeOrder(SalesHeader);
    end;

    // [SCENARIO] [354602]- Check if the system is calculating TCS and GST on Inter-State Sale of Goods through Sale Quotes.
    [Test]
    [HandlerFunctions('GSTTCSTaxRatesPage')]
    procedure GSTTCSInterStateSalesOfGoodsThroughSalesQuotes()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomerType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        LocationCode: Code[10];
        CustomerNo: Code[20];
        TCSNOC: Code[10];
        TCSConcessionalCode: Code[10];
    begin
        // [GIVEN] Created GST and TCS Setup
        CreateGSTSetup(GSTCustomerType::Registered, GSTGroupType::Goods, false);
        InitializeSharedStep(false, false);
        CustomerNo := CopyStr(LibraryStorage.Get(CustomerNoLbl), 1, MaxStrLen(CustomerNo));
        Customer.Get(CustomerNo);
        LocationCode := CopyStr(LibraryStorage.Get(LocationCodeLbl), 1, MaxStrLen(LocationCode));
        GSTTCSLibrary.CreateGSTTCSSetup(Customer, TCSNOC, TCSConcessionalCode, LocationCode);
        GSTTCSLibrary.UpdateCustomerNOC(Customer, true, true);
        CreateTaxRateSetup(TCSNOC, Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Quote with GST and Line Type as Item for Interstate Transactions
        LibraryStorage.Set(NoOfLineLbl, '1');
        CreateSalesDocument(SalesHeader, SalesLine, LineType::Item, DocumentType::Quote);

        // [THEN] Quote to Make Order Conversion
        LibrarySales.QuoteMakeOrder(SalesHeader);
    end;

    // [SCENARIO] [354604]- Check if the system is calculating TCS and GST on Inter-State Sale of Goods through Sale Orders.
    [Test]
    [HandlerFunctions('GSTTCSTaxRatesPage')]
    procedure GSTTCSInterStateSalesOfGoodsThroughSalesOrders()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomerType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
        LocationCode: Code[10];
        CustomerNo: Code[20];
        TCSNOC: Code[10];
        TCSConcessionalCode: Code[10];
    begin
        // [GIVEN] Created GST and TCS Setup
        CreateGSTSetup(GSTCustomerType::Registered, GSTGroupType::Goods, false);
        InitializeSharedStep(false, false);
        CustomerNo := CopyStr(LibraryStorage.Get(CustomerNoLbl), 1, MaxStrLen(CustomerNo));
        Customer.Get(CustomerNo);
        LocationCode := CopyStr(LibraryStorage.Get(LocationCodeLbl), 1, MaxStrLen(LocationCode));
        GSTTCSLibrary.CreateGSTTCSSetup(Customer, TCSNOC, TCSConcessionalCode, LocationCode);
        GSTTCSLibrary.UpdateCustomerNOC(Customer, true, true);
        CreateTaxRateSetup(TCSNOC, Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Order with GST and Line Type as Goods and Interstate Juridisction
        LibraryStorage.Set(NoOfLineLbl, '1');
        PostedDocumentNo := CreateAndPostSalesDocument(SalesHeader, SalesLine, LineType::Item, DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(SalesHeader."Document Type"::Order, PostedDocumentNo, 4);
    end;

    // [SCENARIO] [354605]- Check if the system is calculating TCS and GST on Inter-State Sale of Goods through Sale Invoices.
    [Test]
    [HandlerFunctions('GSTTCSTaxRatesPage')]
    procedure GSTTCSInterStateSalesOfGoodsThroughSalesInvoices()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomerType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
        LocationCode: Code[10];
        CustomerNo: Code[20];
        TCSNOC: Code[10];
        TCSConcessionalCode: Code[10];
    begin
        // [GIVEN] Created GST and TCS Setup
        CreateGSTSetup(GSTCustomerType::Registered, GSTGroupType::Goods, false);
        InitializeSharedStep(false, false);
        CustomerNo := CopyStr(LibraryStorage.Get(CustomerNoLbl), 1, MaxStrLen(CustomerNo));
        Customer.Get(CustomerNo);
        LocationCode := CopyStr(LibraryStorage.Get(LocationCodeLbl), 1, MaxStrLen(LocationCode));
        GSTTCSLibrary.CreateGSTTCSSetup(Customer, TCSNOC, TCSConcessionalCode, LocationCode);
        GSTTCSLibrary.UpdateCustomerNOC(Customer, true, true);
        CreateTaxRateSetup(TCSNOC, Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Order with GST and Line Type as Goods and Interstate Juridisction
        LibraryStorage.Set(NoOfLineLbl, '1');
        PostedDocumentNo := CreateAndPostSalesDocument(SalesHeader, SalesLine, LineType::Item, DocumentType::Invoice);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(SalesHeader."Document Type"::Order, PostedDocumentNo, 4);
    end;

    // [SCENARIO] [354608]- Check if the system is calculating TCS and GST on Inter-State Sale of Services through Sale Orders
    [Test]
    [HandlerFunctions('GSTTCSTaxRatesPage')]
    procedure GSTTCSInterStateSalesOfServicesThroughSalesOrders()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomerType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        PostedDocumentNo: Code[20];
        LocationCode: Code[10];
        CustomerNo: Code[20];
        TCSNOC: Code[10];
        TCSConcessionalCode: Code[10];
    begin
        // [GIVEN] Created GST and TCS Setup
        CreateGSTSetup(GSTCustomerType::Registered, GSTGroupType::Service, false);
        InitializeSharedStep(false, false);
        CustomerNo := CopyStr(LibraryStorage.Get(CustomerNoLbl), 1, MaxStrLen(CustomerNo));
        Customer.Get(CustomerNo);
        LocationCode := CopyStr(LibraryStorage.Get(LocationCodeLbl), 1, MaxStrLen(LocationCode));
        GSTTCSLibrary.CreateGSTTCSSetup(Customer, TCSNOC, TCSConcessionalCode, LocationCode);
        GSTTCSLibrary.UpdateCustomerNOC(Customer, true, true);
        CreateTaxRateSetup(TCSNOC, Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Order with GST and Line Type as Services and Interstate Juridisction
        LibraryStorage.Set(NoOfLineLbl, '1');
        PostedDocumentNo := CreateAndPostSalesDocument(SalesHeader, SalesLine, LineType::"G/L Account", DocumentType::Order);

        // [THEN] GST ledger entries are created and Verified
        LibraryGST.VerifyGLEntries(SalesHeader."Document Type"::Order, PostedDocumentNo, 4);
    end;

    // [SCENARIO] [354607]- Check if the system is calculating TCS and GST on Inter-State Sale of Services through Sale Quotes.
    [Test]
    [HandlerFunctions('GSTTCSTaxRatesPage')]
    procedure GSTTCSInterStateSalesOfServicesThroughSalesQuotes()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GSTCustomerType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        DocumentType: Enum "Sales Document Type";
        LineType: Enum "Sales Line Type";
        LocationCode: Code[10];
        CustomerNo: Code[20];
        TCSNOC: Code[10];
        TCSConcessionalCode: Code[10];
    begin
        // [GIVEN] Created GST and TCS Setup
        CreateGSTSetup(GSTCustomerType::Registered, GSTGroupType::Service, false);
        InitializeSharedStep(false, false);
        CustomerNo := CopyStr(LibraryStorage.Get(CustomerNoLbl), 1, MaxStrLen(CustomerNo));
        Customer.Get(CustomerNo);
        LocationCode := CopyStr(LibraryStorage.Get(LocationCodeLbl), 1, MaxStrLen(LocationCode));
        GSTTCSLibrary.CreateGSTTCSSetup(Customer, TCSNOC, TCSConcessionalCode, LocationCode);
        GSTTCSLibrary.UpdateCustomerNOC(Customer, true, true);
        CreateTaxRateSetup(TCSNOC, Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post Sales Quote with GST and Line Type as G/L Account for Interstate Transactions
        LibraryStorage.Set(NoOfLineLbl, '1');
        CreateSalesDocument(SalesHeader, SalesLine, LineType::"G/L Account", DocumentType::Quote);

        // [THEN] Quote to Make Order Conversion
        LibrarySales.QuoteMakeOrder(SalesHeader);
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
        Customer.Modify(true);
    end;

    local procedure CreateSalesDocument(
        var SalesHeader: Record "Sales Header";
        var SalesLine: Record "Sales Line";
        LineType: Enum "Sales Line Type";
        DocumentType: Enum "Sales Document Type"): Code[20]
    var
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        CustomerNo := CopyStr(LibraryStorage.Get(CustomerNoLbl), 1, MaxStrLen(CustomerNo));
        LocationCode := CopyStr(LibraryStorage.Get(LocationCodeLbl), 1, MaxStrLen(LocationCode));
        CreateSalesHeaderWithGST(SalesHeader, CustomerNo, DocumentType, LocationCode);
        CreateSalesLineWithGST(SalesHeader, SalesLine, LineType, LibraryRandom.RandDecInRange(2, 10, 0), StorageBoolean.Get(ExemptedLbl), StorageBoolean.Get(LineDiscountLbl));
        exit(SalesHeader."No.");
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
        CustomerNo := CopyStr(LibraryStorage.Get(CustomerNoLbl), 1, MaxStrLen(CustomerNo));
        LocationCode := CopyStr(LibraryStorage.Get(LocationCodeLbl), 1, MaxStrLen(LocationCode));
        CreateSalesHeaderWithGST(SalesHeader, CustomerNo, DocumentType, LocationCode);
        CreateSalesLineWithGST(SalesHeader, SalesLine, LineType, LibraryRandom.RandDecInRange(2, 10, 0), StorageBoolean.Get(ExemptedLbl), StorageBoolean.Get(LineDiscountLbl));
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        exit(PostedDocumentNo);
    end;

    local procedure CreateSalesHeaderWithGST(
        var SalesHeader: Record "Sales Header";
        CustomerNo: Code[20];
        DocumentType: Enum "Sales Document Type";
        LocationCode: Code[10])
    var
        WithoutPaymentofDuty: Boolean;
        POS: Boolean;
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, CustomerNo);
        SalesHeader.Validate("Posting Date", WorkDate());
        SalesHeader.Validate("Location Code", LocationCode);

        if StorageBoolean.ContainsKey(WithoutPaymentofDutyLbl) then begin
            WithoutPaymentofDuty := StorageBoolean.Get(WithoutPaymentofDutyLbl);
            if WithoutPaymentofDuty then
                SalesHeader.Validate("GST Without Payment of Duty", true);
        end;
        if StorageBoolean.ContainsKey(POSLbl) then begin
            POS := StorageBoolean.Get(POSLbl);
            if POS then begin
                SalesHeader.Validate("GST Invoice", true);
                SalesHeader.Validate("POS Out Of India", true);
            end;
        end;
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
        TCSNOCType: Code[10];
        LineNo: Integer;
        NoOfLine: Integer;
    begin
        Evaluate(NoOfLine, LibraryStorage.Get(NoOfLineLbl));
        for LineNo := 1 to NoOfLine do begin
            case LineType of
                LineType::Item:
                    LineTypeNo := LibraryGST.CreateItemWithGSTDetails(VATPostingSetup, (LibraryStorage.Get(GSTGroupCodeLbl)), (LibraryStorage.Get(HSNSACCodeLbl)), true, Exempted);
                LineType::"G/L Account":
                    LineTypeNo := LibraryGST.CreateGLAccWithGSTDetails(VATPostingSetup, (LibraryStorage.Get(GSTGroupCodeLbl)), (LibraryStorage.Get(HSNSACCodeLbl)), true, Exempted);
                LineType::"Fixed Asset":
                    LineTypeNo := LibraryGST.CreateFixedAssetWithGSTDetails(VATPostingSetup, (LibraryStorage.Get(GSTGroupCodeLbl)), (LibraryStorage.Get(HSNSACCodeLbl)), true, Exempted);
            end;

            LibrarySales.CreateSalesLine(SalesLine, SalesHeader, LineType, LineTypeno, Quantity);
            SalesLine.Validate("VAT Prod. Posting Group", VATPostingsetup."VAT Prod. Posting Group");
            if LineDiscount then begin
                SalesLine.Validate("Line Discount %", LibraryRandom.RandDecInRange(10, 20, 2));
                LibraryGST.UpdateLineDiscAccInGeneralPostingSetup(SalesLine."Gen. Bus. Posting Group", SalesLine."Gen. Prod. Posting Group");
            end;
            TCSNOCType := CopyStr(LibraryStorage.Get(TCSNOCTypeLbl), 1, MaxStrLen(TCSNOCType));
            GSTTCSLibrary.UpdateSalesLineWithTCSNOC(SalesLine, TCSNOCType);
            SalesLine.Validate("Unit Price", LibraryRandom.RandInt(10000));
            SalesLine.Modify(true);
        end;
    end;

    local procedure CreateGSTSetup(
        GSTCustomerType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        IntraState: Boolean)
    var
        GSTGroup: Record "GST Group";
        HSNSAC: Record "HSN/SAC";
        TaxComponent: Record "Tax Component";
        GSTSetup: Record "GST Setup";
        CompanyInformation: Record "Company information";
        LocationStateCode: Code[10];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        CustomerStateCode: Code[10];
        LocPANNo: Code[20];
        HSNSACCode: Code[10];
        GSTGroupCode: Code[20];
        LocationGSTRegNo: Code[15];
        HsnSacType: Enum "GST Goods And Services Type";
        GSTComponentCode: Text[30];
    begin
        FillCompanyInformation();
        CompanyInformation.Get();
        LocPANNo := CopyStr(LibraryStorage.Get(PANNoLbl), 1, MaxStrLen(LocPANNo));
        LocationStateCode := LibraryGST.CreateInitialSetup();
        if CompanyInformation."State Code" = '' then begin
            CompanyInformation."State Code" := LocationStateCode;
            CompanyInformation.Modify(true);
        end;
        LibraryStorage.Set(LocationStateCodeLbl, LocationStateCode);

        LocationGSTRegNo := LibraryGST.CreateGSTRegistrationNos(LocationStateCode, LocPANNo);
        if CompanyInformation."GST Registration No." = '' then begin
            CompanyInformation."GST Registration No." := LocationGSTRegNo;
            CompanyInformation.Modify(true);
        end;

        LocationCode := LibraryGST.CreateLocationSetup(LocationStateCode, LocationGSTRegNo, false);
        LibraryStorage.Set(LocationCodeLbl, LocationCode);

        GSTGroupCode := LibraryGST.CreateGSTGroup(GSTGroup, GSTGroupType, GSTGroup."GST Place Of Supply"::" ", false);
        LibraryStorage.Set(GSTGroupCodeLbl, GSTGroupCode);

        HSNSACCode := LibraryGST.CreateHSNSACCode(HSNSAC, GSTGroupCode, HsnSacType::HSN);
        LibraryStorage.Set(HSNSACCodeLbl, HSNSACCode);

        if IntraState then begin
            CustomerNo := LibraryGST.CreateCustomerSetup();
            UpdateCustomerSetupWithGST(CustomerNo, GSTCustomerType, LocationStateCode, LocPANNo);
            CreateGSTSetupTaxRateParameters(IntraState, LocationStateCode, LocationStateCode);
            CreateGSTComponentAndPostingSetup(IntraState, LocationStateCode, TaxComponent, GSTComponentCode);
        end else begin
            CustomerStateCode := LibraryGST.CreateGSTStateCode();
            CustomerNo := LibraryGST.CreateCustomerSetup();
            UpdateCustomerSetupWithGST(CustomerNo, GSTCustomerType, CustomerStateCode, LocPANNo);
            if GSTCustomerType in [GSTCustomerType::Export, GSTCustomerType::"SEZ Unit", GSTCustomerType::"SEZ Development"] then
                CreateGSTSetupTaxRateParameters(IntraState, '', LocationStateCode)
            else begin
                CreateGSTSetupTaxRateParameters(IntraState, CustomerStateCode, LocationStateCode);
                CreateGSTComponentAndPostingSetup(IntraState, LocationStateCode, TaxComponent, GSTComponentCode);
            end;
        end;
        LibraryStorage.Set(CustomerNoLbl, CustomerNo);

        if not GSTSetup.Get() then
            exit;

        TaxType := GSTSetup."GST Tax Type";
        CreateGSTRate();
    end;

    local procedure InitializeSharedStep(
        Exempted: Boolean;
        LineDiscount: Boolean)
    begin
        StorageBoolean.Set(ExemptedLbl, Exempted);
        StorageBoolean.Set(LineDiscountLbl, LineDiscount);
    end;

    local procedure CreateGSTSetupTaxRateParameters(
        IntraState: Boolean;
        FromState: Code[10];
        ToState: Code[10])
    var
        GSTTaxPercent: Decimal;
    begin
        LibraryStorage.Set(FromStateCodeLbl, FromState);
        LibraryStorage.Set(ToStateCodeLbl, ToState);

        GSTTaxPercent := LibraryRandom.RandDecInRange(10, 18, 0);
        if IntraState then begin
            ComponentPerArray[1] := (GSTTaxPercent / 2);
            ComponentPerArray[2] := (GSTTaxPercent / 2);
            ComponentPerArray[3] := 0.00;
        end else
            ComponentPerArray[4] := GSTTaxPercent;
    end;

    local procedure CreateGSTComponentAndPostingSetup(
        IntraState: Boolean;
        LocationStateCode: Code[10];
        TaxComponent: Record "Tax Component";
        GSTComponentCode: Text[30])
    begin
        if IntraState then begin
            GSTComponentCode := CGSTLbl;
            LibraryGST.CreateGSTComponent(TaxComponent, GSTComponentCode);
            LibraryGST.CreateGSTPostingSetup(TaxComponent, LocationStateCode);

            GSTComponentCode := SGSTLbl;
            LibraryGST.CreateGSTComponent(TaxComponent, GSTComponentCode);
            LibraryGST.CreateGSTPostingSetup(TaxComponent, LocationStateCode);
        end else begin
            GSTComponentCode := IGSTLbl;
            LibraryGST.CreateGSTComponent(TaxComponent, GSTComponentCode);
            LibraryGST.CreateGSTPostingSetup(TaxComponent, LocationStateCode);
        end;
    end;

    local procedure CreateTCSRate()
    var
        TaxTypes: TestPage "Tax Types";
    begin
        TaxTypes.OpenEdit();
        TaxTypes.Filter.SetFilter(Code, TaxType);
        TaxTypes.TaxRates.Invoke();
    end;

    local procedure CreateGSTRate()
    var
        TaxTypes: TestPage "Tax Types";
    begin
        TaxTypes.OpenEdit();
        TaxTypes.Filter.SetFilter(Code, TaxType);
        TaxTypes.TaxRates.Invoke();
    end;

    local procedure CreateTaxRateSetup(
        TCSNOC: Code[10];
        AssesseeCode: Code[10];
        ConcessionalCode: Code[10];
        EffectiveDate: Date)
    begin
        LibraryStorage.Set(TCSNOCTypeLbl, TCSNOC);
        LibraryStorage.Set(TCSAssesseeCodeLbl, AssesseeCode);
        LibraryStorage.Set(TCSConcessionalCodeLbl, ConcessionalCode);
        LibraryStorage.Set(EffectiveDateLbl, Format(EffectiveDate, 0, 9));
        GenerateTaxComponentsPercentage();
        TaxType := GSTTCSLibrary.GetTCSTaxTypeCode();

        CreateTCSRate();
    end;

    local procedure GenerateTaxComponentsPercentage()
    begin
        LibraryStorage.Set(TCSPercentageLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
        LibraryStorage.Set(NonPANTCSPercentageLbl, Format(LibraryRandom.RandIntInRange(6, 10)));
        LibraryStorage.Set(SurchargePercentageLbl, Format(LibraryRandom.RandIntInRange(6, 10)));
        LibraryStorage.Set(eCessPercentageLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
        LibraryStorage.Set(SHECessPercentageLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
        LibraryStorage.Set(TCSThresholdAmountLbl, Format(LibraryRandom.RandIntInRange(4000, 6000)));
        LibraryStorage.Set(SurchargeThresholdAmountLbl, Format(LibraryRandom.RandIntInRange(4000, 6000)));
    end;

    local procedure FillCompanyInformation()
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        if CompanyInformation."State Code" = '' then
            CompanyInformation.Validate("State Code", LibraryGST.CreateGSTStateCode());
        CompanyInformation."P.A.N. No." := LibraryGST.CreatePANNos();
        LibraryStorage.Set(PANNoLbl, CompanyInformation."P.A.N. No.");
        CompanyInformation.Modify(true);
    end;

    [PageHandler]
    procedure GSTTCSTaxRatesPage(var TaxRates: TestPage "Tax Rates")
    var
        GSTSetup: Record "GST Setup";
        TCSPercentage: Decimal;
        NonPANTCSPercentage: Decimal;
        SurchargePercentage: Decimal;
        eCessPercentage: Decimal;
        SHECessPercentage: Decimal;
        EffectiveDate: Date;
        TCSThresholdAmount: Decimal;
        SurchargeThresholdAmount: Decimal;
    begin
        if not GSTSetup.Get() then
            exit;

        if TaxType = GSTSetup."GST Tax Type" then begin
            TaxRates.New();
            TaxRates.AttributeValue1.SetValue(LibraryStorage.Get(GSTGroupCodeLbl));
            TaxRates.AttributeValue2.SetValue(LibraryStorage.Get(HSNSACCodeLbl));
            TaxRates.AttributeValue3.SetValue(LibraryStorage.Get(FromStateCodeLbl));
            TaxRates.AttributeValue4.SetValue(LibraryStorage.Get(ToStateCodeLbl));
            TaxRates.AttributeValue5.SetValue(WorkDate());
            TaxRates.AttributeValue6.SetValue(CalcDate('<10Y>', WorkDate()));
            TaxRates.AttributeValue7.SetValue(ComponentPerArray[1]); // SGST
            TaxRates.AttributeValue8.SetValue(ComponentPerArray[2]); // CGST
            TaxRates.AttributeValue9.SetValue(ComponentPerArray[4]); // IGST
            TaxRates.AttributeValue10.SetValue(ComponentPerArray[3]); // KFloodCess
            TaxRates.OK().Invoke();
            Clear(TaxRates);
        end;
        if TaxType = GSTTCSLibrary.GetTCSTaxTypeCode() then begin
            Evaluate(EffectiveDate, LibraryStorage.Get(EffectiveDateLbl), 9);
            Evaluate(TCSPercentage, LibraryStorage.Get(TCSPercentageLbl));
            Evaluate(NonPANTCSPercentage, LibraryStorage.Get(NonPANTCSPercentageLbl));
            Evaluate(SurchargePercentage, LibraryStorage.Get(SurchargePercentageLbl));
            Evaluate(eCessPercentage, LibraryStorage.Get(eCessPercentageLbl));
            Evaluate(SHECessPercentage, LibraryStorage.Get(SHECessPercentageLbl));
            Evaluate(TCSThresholdAmount, LibraryStorage.Get(TCSThresholdAmountLbl));
            Evaluate(SurchargeThresholdAmount, LibraryStorage.Get(SurchargeThresholdAmountLbl));

            TaxRates.New();
            TaxRates.AttributeValue1.SetValue(LibraryStorage.Get(TCSNOCTypeLbl));
            TaxRates.AttributeValue2.SetValue(LibraryStorage.Get(TCSAssesseeCodeLbl));
            TaxRates.AttributeValue3.SetValue(LibraryStorage.Get(TCSConcessionalCodeLbl));
            TaxRates.AttributeValue4.SetValue(EffectiveDate);
            TaxRates.AttributeValue5.SetValue(TCSPercentage);
            TaxRates.AttributeValue6.SetValue(SurchargePercentage);
            TaxRates.AttributeValue7.SetValue(NonPANTCSPercentage);
            TaxRates.AttributeValue8.SetValue(eCessPercentage);
            TaxRates.AttributeValue9.SetValue(SHECessPercentage);
            TaxRates.AttributeValue10.SetValue(TCSThresholdAmount);
            TaxRates.AttributeValue11.SetValue(SurchargeThresholdAmount);
            TaxRates.OK().Invoke();
        end;
    end;
}