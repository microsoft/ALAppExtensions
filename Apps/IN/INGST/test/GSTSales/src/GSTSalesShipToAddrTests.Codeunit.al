codeunit 18191 "GST Sales Ship To Addr Tests"
{
    Subtype = Test;

    var
        LibrarySales: Codeunit "Library - Sales";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryGST: Codeunit "Library GST";
        LibraryRandom: Codeunit "Library - Random";
        Storage: Dictionary of [Text, Code[20]];
        StorageBoolean: Dictionary of [Text, Boolean];
        ComponentPerArray: array[20] of Decimal;
        LocationStateCodeLbl: Label 'LocationStateCode';
        LocationCodeLbl: Label 'LocationCode';
        GSTGroupCodeLbl: Label 'GSTGroupCode';
        LocPANNoLbl: Label 'LocPANNo';
        HSNSACCodeLbl: Label 'HSNSACCode';
        CGSTLbl: Label 'CGST';
        SGSTLbl: Label 'SGST';
        IGSTLbl: Label 'IGST';
        ShipToGSTRegNoLbl: Label 'ShipToGSTRegNoCode';
        ShipToGSTStateCodeLbl: Label 'ShipToGSTStateCode';
        ExemptedLbl: Label 'Exempted';
        LineDiscountLbl: Label 'LineDiscount';
        FromStateCodeLbl: Label 'FromStateCode';
        CustomerNoLbl: Label 'CustomerNo';
        ToStateCodeLbl: Label 'ToStateCode';
        PostedDocumentNoLbl: Label 'PostedDocumentNo';

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustSalesInvInterstateWithShipToAddrItem()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Check if the system is calculating Inter State Sales of Goods from Registered Customer through Sales Order/Invoice.

        // [GIVEN] Create GST Setup and tax rates for Registered Customer where GST Group Type is Goods for InterState Transactions
        CreateGSTSetup(Enum::"GST Customer Type"::Registered, Enum::"GST Group Type"::Goods, true, true);
        InitializeShareStep(false, false);

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Item for Interstate Transaction With Ship To Address
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine, Enum::"Sales Line Type"::Item,
            Enum::"Sales Document Type"::Invoice);

        // [THEN] Verify G/L Entry
        LibraryGST.VerifyGLEntries(SalesHeader."Document Type"::Invoice, PostedDocumentNo, 2);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustSalesInvIntrastateWithShipToAddrItem()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Check if the system is calculating Intra State Sales of Goods from Registered Customer through Sales Order/Invoice.

        // [GIVEN] Create GST Setup and tax rates for Registered Customer where GST Group Type is Goods for IntraState Transactions
        CreateGSTSetup(Enum::"GST Customer Type"::Registered, Enum::"GST Group Type"::Goods, false, true);
        InitializeShareStep(false, false);

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Item for Intrastate Transaction With Ship To Address
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine, Enum::"Sales Line Type"::Item,
            Enum::"Sales Document Type"::Invoice);

        // [THEN] Verify G/L Entry
        LibraryGST.VerifyGLEntries(SalesHeader."Document Type"::Invoice, PostedDocumentNo, 4);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustSalesInvInterstateWithShipToAddrGL()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Check if the system is calculating Inter State Sales of Services from Registered Customer through Sales Order/Invoice.

        // [GIVEN] Create GST Setup and tax rates for Registered Customer where GST Group Type is Services for InterState Transactions
        CreateGSTSetup(Enum::"GST Customer Type"::Registered, Enum::"GST Group Type"::Goods, true, true);
        InitializeShareStep(false, false);

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as G/L Account for Interstate Transaction With Ship To Address
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine, Enum::"Sales Line Type"::"G/L Account",
            Enum::"Sales Document Type"::Invoice);

        // [THEN] Verify G/L Entry
        LibraryGST.VerifyGLEntries(SalesHeader."Document Type"::Invoice, PostedDocumentNo, 3);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustSalesInvIntrastateWithShipToAddrGL()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Check if the system is calculating Intra State Sales of Services from Registered Customer through Sales Order/Invoice.

        // [GIVEN] Create GST Setup and tax rates for Registered Customer where GST Group Type is Services for IntraState Transactions
        CreateGSTSetup(Enum::"GST Customer Type"::Registered, Enum::"GST Group Type"::Service, false, true);
        InitializeShareStep(false, false);

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as G/L Account for Intrastate Transaction With Ship To Address
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine, Enum::"Sales Line Type"::"G/L Account",
            Enum::"Sales Document Type"::Invoice);

        // [THEN] Verify G/L Entry
        LibraryGST.VerifyGLEntries(SalesHeader."Document Type"::Invoice, PostedDocumentNo, 2);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustSalesInvInterstateWithShipToAddrFA()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Check if the system is calculating Inter State Sales of Fixed Asset from Registered Customer through Sales Order/Invoice.

        // [GIVEN] Create GST Setup and tax rates for Registered Customer where GST Group Type is Goods for InterState Transactions
        CreateGSTSetup(Enum::"GST Customer Type"::Registered, Enum::"GST Group Type"::Goods, true, true);
        InitializeShareStep(false, false);

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Fixed Asset for Interstate Transaction With Ship To Address
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine, Enum::"Sales Line Type"::"Fixed Asset",
            Enum::"Sales Document Type"::Invoice);

        // [THEN] Verify G/L Entry
        LibraryGST.VerifyGLEntries(SalesHeader."Document Type"::Invoice, PostedDocumentNo, 4);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustSalesInvIntrastateWithShipToAddrFA()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Check if the system is calculating Intra State Sales of Fixed Asset from Registered Customer through Sales Order/Invoice.

        // [GIVEN] Create GST Setup and tax rates for Registered Customer where GST Group Type is Goods for IntraState Transactions
        CreateGSTSetup(Enum::"GST Customer Type"::Registered, Enum::"GST Group Type"::Goods, false, true);
        InitializeShareStep(false, false);

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Fixed Asset for Intrastate Transaction With Ship To Address
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine, Enum::"Sales Line Type"::"Fixed Asset",
            Enum::"Sales Document Type"::Invoice);

        // [THEN] Verify G/L Entry
        LibraryGST.VerifyGLEntries(SalesHeader."Document Type"::Invoice, PostedDocumentNo, 6);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustSalesInvInterstateWithShipToAddrRes()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Check if the system is calculating Inter State Sales of Resource from Registered Customer through Sales Order/Invoice.

        // [GIVEN] Create GST Setup and tax rates for Registered Customer where GST Group Type is Goods for InterState Transactions
        CreateGSTSetup(Enum::"GST Customer Type"::Registered, Enum::"GST Group Type"::Goods, true, true);
        InitializeShareStep(false, false);

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Resource for Interstate Transaction With Ship To Address
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine, Enum::"Sales Line Type"::Resource,
            Enum::"Sales Document Type"::Invoice);

        // [THEN] Verify G/L Entry
        LibraryGST.VerifyGLEntries(SalesHeader."Document Type"::Invoice, PostedDocumentNo, 2);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromRegCustSalesInvIntrastateWithShipToAddrRes()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PostedDocumentNo: Code[20];
    begin
        // [SCENARIO] Check if the system is calculating Intra State Sales of Resource from Registered Customer through Sales Order/Invoice.

        // [GIVEN] Create GST Setup and tax rates for Registered Customer where GST Group Type is Goods for IntraState Transactions
        CreateGSTSetup(Enum::"GST Customer Type"::Registered, Enum::"GST Group Type"::Goods, false, true);
        InitializeShareStep(false, false);

        // [WHEN] Create and Post Sales Invoice with GST and Line Type as Resource for Intrastate Transaction With Ship To Address
        PostedDocumentNo := CreateAndPostSalesDocument(
            SalesHeader,
            SalesLine, Enum::"Sales Line Type"::Resource,
            Enum::"Sales Document Type"::Invoice);

        // [THEN] Verify G/L Entry
        LibraryGST.VerifyGLEntries(SalesHeader."Document Type"::Invoice, PostedDocumentNo, 4);
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
        SalesHeader.Validate("Ship-to Code", CreateShipToAddress());
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
                LineTypeNo := LibraryGST.CreateGLAccWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), true, Exempted);
            LineType::"Fixed Asset":
                LineTypeNo := LibraryGST.CreateFixedAssetWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), true, Exempted);
            LineType::Resource:
                LineTypeNo := LibraryGST.CreateResourceWithGSTDetails(VATPostingSetup, (Storage.Get(GSTGroupCodeLbl)), (Storage.Get(HSNSACCodeLbl)), true);
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
        SalesLine.Validate("GST Place Of Supply", SalesLine."GST Place Of Supply"::"Ship-to Address");
        SalesLine.Modify(true);
    end;

    local procedure CreateShipToAddress(): Code[10]
    var
        ShipToAddress: Record "Ship-to Address";
    begin
        LibrarySales.CreateShipToAddress(ShipToAddress, Storage.Get(CustomerNoLbl));
        ShipToAddress.Validate(State, Storage.Get(ShipToGSTStateCodeLbl));
        ShipToAddress.Validate(Address, LibraryRandom.RandText(10));
        ShipToAddress.Validate("GST Registration No.", Storage.Get(ShipToGSTRegNoLbl));
        ShipToAddress.Modify(true);
        exit(ShipToAddress.Code);
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

    local procedure CreateGSTSetup(
        GSTCustomerType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        IntraState: Boolean;
        ShipToAddr: Boolean)
    var
        GSTGroup: Record "GST Group";
        HSNSAC: Record "HSN/SAC";
        TaxComponent: Record "Tax Component";
        CompanyInformation: Record "Company information";
        LocationStateCode: Code[10];
        ShipToAddrStateCode: Code[10];
        ShipToGSTRegNo: Code[15];
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

        ShipToAddrStateCode := LibraryGST.CreateInitialSetup();
        Storage.Set(ShipToGSTStateCodeLbl, ShipToAddrStateCode);

        LocationGSTRegNo := LibraryGST.CreateGSTRegistrationNos(LocationStateCode, LocPANNo);

        ShipToGSTRegNo := LibraryGST.CreateGSTRegistrationNos(ShipToAddrStateCode, LocPANNo);
        Storage.Set(ShipToGSTRegNoLbl, ShipToGSTRegNo);

        if CompanyInformation."GST Registration No." = '' then begin
            CompanyInformation."GST Registration No." := LocationGSTRegNo;
            CompanyInformation.Modify(true);
        end;

        LocationCode := LibraryGST.CreateLocationSetup(LocationStateCode, LocationGSTRegNo, false);
        Storage.Set(LocationCodeLbl, LocationCode);

        GSTGroupCode := LibraryGST.CreateGSTGroup(GSTGroup, GSTGroupType, GSTGroup."GST Place Of Supply"::"Ship-to Address", false);
        Storage.Set(GSTGroupCodeLbl, GSTGroupCode);

        HSNSACCode := LibraryGST.CreateHSNSACCode(HSNSAC, GSTGroupCode, HsnSacType::HSN);
        Storage.Set(HSNSACCodeLbl, HSNSACCode);

        CustomerNo := LibraryGST.CreateCustomerSetup();
        Storage.Set(CustomerNoLbl, CustomerNo);

        if IntraState and ShipToAddr then
            CreateSetupForInterStateCustomer(GSTCustomerType, IntraState)
        else
            CreateSetupForIntraStateCustomer(GSTCustomerType, IntraState);

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

    local procedure CreateSetupForIntraStateCustomer(
        GSTCustomerType: Enum "GST Customer Type";
        IntraState: Boolean)
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
            GSTComponentcode := IGSTLbl;
            LibraryGST.CreateGSTComponent(TaxComponent, GSTComponentcode);
            LibraryGST.CreateGSTPostingSetup(TaxComponent, LocationStateCode);
        end else begin
            GSTComponentcode := CGSTLbl;
            LibraryGST.CreateGSTComponent(TaxComponent, GSTComponentcode);
            LibraryGST.CreateGSTPostingSetup(TaxComponent, LocationStateCode);

            GSTComponentcode := SGSTLbl;
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

        if IntraState then
            ComponentPerArray[4] := GSTTaxPercent
        else begin
            ComponentPerArray[1] := (GSTTaxPercent / 2);
            ComponentPerArray[2] := (GSTTaxPercent / 2);
        end;
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

    local procedure CreateSetupForInterStateCustomer(
        GSTCustomerType: Enum "GST Customer Type";
        IntraState: Boolean)
    var
        LocationStateCode: Code[10];
        CustomerStateCode: Code[10];
        ShipToAddrStateCode: Code[10];
        CustomerNo: Code[20];
        LocPANNo: Code[20];
    begin
        CustomerNo := Storage.Get(CustomerNoLbl);
        LocationStateCode := (Storage.Get(LocationStateCodeLbl));
        ShipToAddrStateCode := (Storage.Get(ShipToGSTStateCodeLbl));

        LocPANNo := Storage.Get(LocPANNoLbl);
        CustomerStateCode := LibraryGST.CreateGSTStateCode();
        UpdateCustomerSetupWithGST(CustomerNo, GSTCustomerType, CustomerStateCode, LocPANNo);

        if GSTCustomerType in [GSTCustomerType::Export, GSTCustomerType::"SEZ Unit", GSTCustomerType::"SEZ Development", GSTCustomerType::"Deemed Export"] then
            InitializeTaxRateParameters(IntraState, '', LocationStateCode)
        else
            InitializeTaxRateParameters(IntraState, ShipToAddrStateCode, LocationStateCode);
    end;

    [PageHandler]
    procedure TaxRatePageHandler(var TaxRates: TestPage "Tax Rates")
    begin
        TaxRates.New();
        TaxRates.AttributeValue1.SetValue(Storage.Get(GSTGroupCodeLbl));
        TaxRates.AttributeValue2.SetValue(Storage.Get(HSNSACCodeLbl));
        TaxRates.AttributeValue3.SetValue(Storage.Get(FromStateCodeLbl));
        TaxRates.AttributeValue4.SetValue(Storage.Get(ToStateCodeLbl));
        TaxRates.AttributeValue5.SetValue(CalcDate('<-1Y>', WorkDate()));
        TaxRates.AttributeValue6.SetValue(CalcDate('<10Y>', WorkDate()));
        TaxRates.AttributeValue7.SetValue(ComponentPerArray[1]);
        TaxRates.AttributeValue8.SetValue(ComponentPerArray[2]);
        TaxRates.AttributeValue9.SetValue(ComponentPerArray[4]);
        TaxRates.AttributeValue10.SetValue(ComponentPerArray[5]);
        TaxRates.OK().Invoke();
    end;
}