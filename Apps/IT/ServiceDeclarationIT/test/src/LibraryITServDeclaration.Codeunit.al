codeunit 144109 "Library - IT Serv. Declaration"
{
    Subtype = Test;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    // [FEATURE] [Service Declaration] [Library]
    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryInventory: Codeunit "Library - Inventory";
        LibrarySales: Codeunit "Library - Sales";
        LibraryRandom: Codeunit "Library - Random";
        LibraryWarehouse: Codeunit "Library - Warehouse";

    procedure CreateServDeclSetup()
    var
        ServDeclSetup: Record "Service Declaration Setup";
        NoSeriesCode: Code[20];
    begin
        if ServDeclSetup.Get() then
            exit;

        NoSeriesCode := LibraryERM.CreateNoSeriesCode();
        ServDeclSetup.Init();
        ServDeclSetup.Validate("Declaration No. Series", NoSeriesCode);
        ServDeclSetup.Insert();
    end;

    procedure CreateServDecl(ReportDate: Date; var ServDeclNo: Code[20])
    var
        ServDeclHeader: Record "Service Declaration Header";
        VATReportsConfiguration: Record "VAT Reports Configuration";
    begin
        ServDeclHeader.Init();
        ServDeclHeader.Validate("No.", GetServDeclNo());

        VATReportsConfiguration.SetRange("VAT Report Type", VATReportsConfiguration."VAT Report Type"::"Service Declaration");
        VATReportsConfiguration.FindFirst();
        ServDeclHeader.Validate("Config. Code", VATReportsConfiguration."VAT Report Version");
        ServDeclHeader.Insert();

        ServDeclHeader.Validate("Statistics Period", GetStatisticalPeriod(ReportDate));
        ServDeclHeader.Modify();

        ServDeclNo := ServDeclHeader."No.";
    end;

    procedure CreateSalesDocument(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; CustomerNo: Code[20]; PostingDate: Date; DocumentType: Enum "Sales Document Type"; Type: Enum "Sales Line Type"; No: Code[20];
                                                                                                                                                                              NoOfLines: Integer)
    var
        ServiceTariffNumber: Record "Service Tariff Number";
        i: Integer;
    begin
        // Create Sales Order with Random Quantity and Unit Price.
        CreateSalesHeader(SalesHeader, CustomerNo, PostingDate, DocumentType);
        for i := 1 to NoOfLines do begin
            LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Type, No, LibraryRandom.RandDec(10, 2));
            ServiceTariffNumber.Init();
            ServiceTariffNumber."No." := '162534';
            if not ServiceTariffNumber.Insert() then;
            SalesLine.Validate("Service Tariff No.", ServiceTariffNumber."No.");
            SalesLine.Validate("Unit Price", LibraryRandom.RandDec(100, 2));
            SalesLine.Modify(true);
        end;
    end;

    procedure CreateSalesHeader(var SalesHeader: Record "Sales Header"; CustomerNo: Code[20]; PostingDate: Date; DocumentType: Enum "Sales Document Type")
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, CustomerNo);
        SalesHeader.Validate("Posting Date", PostingDate);
        SalesHeader.Validate("Transport Method", LibraryUtility.CreateCodeRecord(Database::"Transport Method"));
        SalesHeader.Modify(true);
    end;

    procedure CreateCountryRegion(var CountryRegion: Record "Country/Region"; IsEUCountry: Boolean)
    begin
        CountryRegion.Code := LibraryUtility.GenerateRandomCodeWithLength(CountryRegion.FieldNo(Code), Database::"Country/Region", 2);
        CountryRegion.Validate("Intrastat Code", CopyStr(LibraryUtility.GenerateRandomAlphabeticText(3, 0), 1, 2));
        if IsEUCountry then
            CountryRegion.Validate("EU Country/Region Code", CopyStr(LibraryUtility.GenerateRandomAlphabeticText(3, 0), 1, 2));
        CountryRegion.Insert(true);
    end;

    procedure CreateCustomer(): Code[20]
    var
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Country/Region Code", GetCountryRegionCode());
        VATPostingSetup.SetRange("VAT Calculation Type", VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        VATPostingSetup.SetRange("EU Service", true);
        VATPostingSetup.FindFirst();
        Customer.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        Customer.Modify(true);
        exit(Customer."No.");
    end;

    procedure CreateAndPostPurchaseOrder(var PurchaseLine: Record "Purchase Line"; PostingDate: Date): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        exit(
            CreateAndPostPurchaseDocumentMultiLine(
                PurchaseLine, PurchaseHeader."Document Type"::Order, PostingDate, PurchaseLine.Type::Item, CreateItem(), 1));
    end;

    procedure CreateAndPostPurchaseDocumentMultiLine(var PurchaseLine: Record "Purchase Line"; DocumentType: Enum "Purchase Document Type"; PostingDate: Date;
                                                                                                                       LineType: Enum "Purchase Line Type";
                                                                                                                       ItemNo: Code[20];
                                                                                                                       NoOfLines: Integer): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
        i: Integer;
    begin
        CreatePurchaseHeader(PurchaseHeader, DocumentType, PostingDate, CreateVendor(GetCountryRegionCode()));
        for i := 1 to NoOfLines do
            CreatePurchaseLine(PurchaseHeader, PurchaseLine, LineType, ItemNo);
        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
    end;

    procedure CreateAndPostPurchaseOrderWithInvoice(var PurchaseLine: Record "Purchase Line"; PostingDate: Date): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        exit(
          CreateAndPostPurchaseDocumentMultiLineWithInvoice(
            PurchaseLine, PurchaseHeader."Document Type"::Order, PostingDate, PurchaseLine.Type::Item, CreateItem(), 1));
    end;

    procedure CreateAndPostPurchaseDocumentMultiLineWithInvoice(var PurchaseLine: Record "Purchase Line";
        DocumentType: Enum "Purchase Document Type";
        PostingDate: Date;
        LineType: Enum "Purchase Line Type";
        ItemNo: Code[20];
        NoOfLines: Integer): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
        i: Integer;
    begin
        CreatePurchaseHeader(PurchaseHeader, DocumentType, PostingDate, CreateVendor(GetCountryRegionCode()));
        for i := 1 to NoOfLines do
            CreatePurchaseLine(PurchaseHeader, PurchaseLine, LineType, ItemNo);
        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
    end;

    procedure CreateItem(): Code[20]
    var
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        LibraryInventory.CreateItem(Item);
        VATPostingSetup.SetRange("VAT Calculation Type", VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        VATPostingSetup.SetRange("EU Service", true);
        VATPostingSetup.FindFirst();
        Item.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        Item.Modify(true);
        exit(Item."No.");
    end;

    procedure CreatePurchaseHeader(var PurchaseHeader: Record "Purchase Header"; DocumentType: Enum "Purchase Document Type"; PostingDate: Date;
                                                                                                         VendorNo: Code[20])
    var
        Location: Record Location;
    begin
        // Create Purchase Order With Random Quantity and Direct Unit Cost.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, DocumentType, VendorNo);

        PurchaseHeader.Validate("Posting Date", PostingDate);
        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(Location);
        PurchaseHeader.Validate("Location Code", Location.Code);
        PurchaseHeader.Validate("Transport Method", LibraryUtility.CreateCodeRecord(Database::"Transport Method"));
        PurchaseHeader.Modify(true);
    end;

    procedure CreatePurchaseLine(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; Type: Enum "Purchase Line Type"; No: Code[20])
    var
        ServiceTariffNumber: Record "Service Tariff Number";
    begin
        // Take Random Values for Purchase Line.
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, Type, No, LibraryRandom.RandDec(10, 2));
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDec(100, 2));
        ServiceTariffNumber.Init();
        ServiceTariffNumber."No." := '162534';
        if not ServiceTariffNumber.Insert() then;
        PurchaseLine.Validate("Service Tariff No.", ServiceTariffNumber."No.");
        PurchaseLine.Modify(true);
    end;

    procedure CreateAndPostSalesOrder(var SalesLine: Record "Sales Line"; PostingDate: Date): Code[20]
    var
        SalesHeader: Record "Sales Header";
    begin
        exit(
          CreateAndPostSalesDocumentMultiLine(
            SalesLine, SalesHeader."Document Type"::Order, PostingDate, SalesLine.Type::Item, CreateItem(), 1));
    end;

    procedure CreateAndPostSalesDocumentMultiLine(var SalesLine: Record "Sales Line"; DocumentType: Enum "Sales Document Type"; PostingDate: Date;
                                                                                                             LineType: Enum "Sales Line Type";
                                                                                                             ItemNo: Code[20];
                                                                                                             NoOfSalesLines: Integer): Code[20]
    var
        SalesHeader: Record "Sales Header";
    begin
        CreateSalesDocument(SalesHeader, SalesLine, CreateCustomer(), PostingDate, DocumentType, LineType, ItemNo, NoOfSalesLines);
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    procedure CreateAndPostSalesOrderWithInvoice(var SalesLine: Record "Sales Line"; PostingDate: Date): Code[20]
    var
        SalesHeader: Record "Sales Header";
    begin
        exit(
          CreateAndPostSalesDocumentMultiLineWithInvoice(
            SalesLine, SalesHeader."Document Type"::Order, PostingDate, SalesLine.Type::Item, CreateItem(), 1));
    end;

    procedure CreateAndPostSalesDocumentMultiLineWithInvoice(var SalesLine: Record "Sales Line"; DocumentType: Enum "Sales Document Type"; PostingDate: Date;
                                                                                                         LineType: Enum "Sales Line Type";
                                                                                                         ItemNo: Code[20];
                                                                                                         NoOfSalesLines: Integer): Code[20]
    var
        SalesHeader: Record "Sales Header";
    begin
        CreateSalesDocument(SalesHeader, SalesLine, CreateCustomer(), PostingDate, DocumentType, LineType, ItemNo, NoOfSalesLines);
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    procedure CreateVendor(CountryRegionCode: Code[10]): Code[20]
    var
        Vendor: Record Vendor;
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        LibraryPurchase.CreateVendor(Vendor);
        Vendor.Validate("Country/Region Code", CountryRegionCode);
        VATPostingSetup.SetRange("VAT Calculation Type", VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        VATPostingSetup.SetRange("EU Service", true);
        VATPostingSetup.FindFirst();
        Vendor.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        Vendor.Modify(true);
        exit(Vendor."No.");
    end;

    procedure DeleteServDecl(ServDecltNo: Code[20])
    var
        ServDeclHeader: Record "Service Declaration Header";
        ServDeclLine: Record "Service Declaration Line";
    begin
        ServDeclHeader.SetRange("No.", ServDecltNo);
        ServDeclHeader.FindFirst();
        ServDeclHeader.Status := ServDeclHeader.Status::Open;
        ServDeclHeader.Modify();

        ServDeclLine.SetRange("Service Declaration No.", ServDecltNo);
        ServDeclLine.DeleteAll(true);
        ServDeclHeader.DeleteAll(true);
    end;

    procedure GetCountryRegionCode(): Code[10]
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

    procedure GetServDeclNo() NoSeriesCode: Code[20]
    var
        ServDeclSetup: Record "Service Declaration Setup";
        NoSeries: Record "No. Series";
        NoSeriesCodeunit: Codeunit "No. Series";
    begin
        ServDeclSetup.Get();
        NoSeries.SetFilter(NoSeries.Code, ServDeclSetup."Declaration No. Series");
        NoSeries.FindFirst();
        NoSeriesCode := NoSeriesCodeunit.GetNextNo(NoSeries.Code);
    end;

    procedure GetStatisticalPeriod(ReportDate: Date): Code[20]
    var
        Month: Code[2];
        Year: Code[4];
    begin
        Month := format(Date2DMY(ReportDate, 2));
        if StrLen(Month) < 2 then
            Month := '0' + Month;
        Year := CopyStr(format(Date2DMY(ReportDate, 3)), 3, 2);
        exit(Year + Month);
    end;

    procedure GetServDeclLine(DocumentNo: Code[20]; ServDeclNo: Code[20]; var ServDeclLine: Record "Service Declaration Line")
    begin
        ServDeclLine.SetRange("Service Declaration No.", ServDeclNo);
        ServDeclLine.SetRange("Document No.", DocumentNo);
        ServDeclLine.FindFirst();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service Declaration Mgt.", 'OnAfterCheckFeatureEnabled', '', true, true)]
    local procedure OnAfterCheckFeatureEnabled(var IsEnabled: Boolean)
    begin
        IsEnabled := true;
    end;
}