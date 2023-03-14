codeunit 139900 "Library - Service Declaration"
{

    var
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        LibraryService: Codeunit "Library - Service";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryRandom: Codeunit "Library - Random";
        LibraryResource: Codeunit "Library - Resource";


    procedure GetInitializedServDeclSetup(var ServDeclSetup: Record "Service Declaration Setup")
    var
        ServDeclMgt: Codeunit "Service Declaration Mgt.";
    begin
        ServDeclMgt.InsertSetup(ServDeclSetup);
    end;

    procedure InitServDeclSetup()
    var
        ServDeclSetup: Record "Service Declaration Setup";
    begin
        GetInitializedServDeclSetup(ServDeclSetup);
    end;

    procedure CreateServTransTypeCode(): Code[20]
    var
        ServiceTransactionType: Record "Service Transaction Type";
    begin
        ServiceTransactionType.Validate(Code,
            LibraryUtility.GenerateRandomCode20(ServiceTransactionType.FieldNo(Code), Database::"Service Transaction Type"));
        ServiceTransactionType.Insert(true);
        exit(ServiceTransactionType.Code)
    end;

    procedure EnableFeature()
    begin
        ChangeFeatureStatus(true);
    end;

    procedure DisableFeature()
    begin
        ChangeFeatureStatus(false);
    end;

    procedure SetReportItemCharges(ReportItemCharges: Boolean)
    var
        ServDeclSetup: Record "Service Declaration Setup";
    begin
        ServDeclSetup.Get();
        ServDeclSetup.Validate("Report Item Charges", ReportItemCharges);
        ServDeclSetup.Modify(true)
    end;

    procedure CreateSalesDocWithServTransTypeCode(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
        CreateSalesDocApplicableForServDecl(SalesHeader, SalesLine);
        SalesLine.Validate("Service Transaction Type Code", CreateServTransTypeCode());
        SalesLine.Modify(true);
    end;

    procedure CreateResSalesDocWithServTransTypeCode(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
        CreateResSalesDocApplicableForServDecl(SalesHeader, SalesLine);
        SalesLine.Validate("Service Transaction Type Code", CreateServTransTypeCode());
        SalesLine.Modify(true);
    end;

    procedure CreateItemChargeSalesDocWithServTransTypeCode(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
        CreateItemChargeSalesDocApplicableForServDecl(SalesHeader, SalesLine);
        SalesLine.validate("Service Transaction Type Code", CreateServTransTypeCode());
        SalesLine.Modify(true);
    end;

    procedure CreateSalesDocApplicableForServDecl(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
        CreateServDeclSalesHeader(SalesHeader);
        CreateServDeclSalesLine(SalesLine, SalesHeader);
    end;

    procedure CreateResSalesDocApplicableForServDecl(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
        CreateServDeclSalesHeader(SalesHeader);
        CreateResServDeclSalesLine(SalesLine, SalesHeader);
    end;

    procedure CreateItemChargeSalesDocApplicableForServDecl(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
        CreateServDeclSalesHeader(SalesHeader);
        CreateItemChargeServDeclSalesLine(SalesLine, SalesHeader);
    end;

    procedure CreateServDeclSalesHeader(var SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
        ValueEntry: Record "Value Entry";
    begin
        LibrarySales.CreateCustomerWithVATRegNo(Customer);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");
        ValueEntry.FindLast();
        SalesHeader.Validate("Posting Date", CalcDate('<1Y>', ValueEntry."Posting Date"));
        SalesHeader.Modify(true);
    end;

    procedure CreateServDeclSalesLine(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header")
    var
        Item: Record Item;
    begin
        LibraryInventory.CreateServiceTypeItem(Item);
        LibrarySales.CreateSalesLineWithUnitPrice(
            SalesLine, SalesHeader, Item."No.", LibraryRandom.RandDec(100, 2), LibraryRandom.RandInt(100));
    end;

    procedure CreateResServDeclSalesLine(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header")
    begin
        LibrarySales.CreateSalesLine(
            SalesLine, SalesHeader, SalesLine.Type::Resource, LibraryResource.CreateResourceNo(), LibraryRandom.RandInt(100));
        SalesLine.Validate("Unit Price", LibraryRandom.RandDec(100, 2));
        SalesLine.Modify(true);
    end;

    procedure CreateItemChargeServDeclSalesLine(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header")
    begin
        LibrarySales.CreateSalesLine(
            SalesLine, SalesHeader, SalesLine.Type::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(100));
        LibrarySales.CreateSalesLine(
          SalesLine, SalesHeader,
          SalesLine.Type::"Charge (Item)", LibraryInventory.CreateItemChargeNo(), SalesLine.Quantity);
        SalesLine.Validate("Unit Price", LibraryRandom.RandDec(10, 2));
        SalesLine.Modify(true);
    end;

    procedure CreateServDocWithServTransTypeCode(var ServiceHeader: Record "Service Header"; var ServiceLine: Record "Service Line")
    begin
        CreateServDocApplicableForServDecl(ServiceHeader, ServiceLine);
        ServiceLine.Validate("Service Transaction Type Code", CreateServTransTypeCode());
        ServiceLine.Modify(true);
    end;

    procedure CreateServDocApplicableForServDecl(var ServiceHeader: Record "Service Header"; var ServiceLine: Record "Service Line")
    begin
        CreateServDeclServHeader(ServiceHeader);
        CreateServDeclServLine(ServiceLine, ServiceHeader);
    end;

    procedure CreateServDeclServHeader(var ServiceHeader: Record "Service Header")
    var
        Customer: Record Customer;
        ValueEntry: Record "Value Entry";
    begin
        LibrarySales.CreateCustomerWithVATRegNo(Customer);
        LibraryService.CreateServiceHeader(ServiceHeader, ServiceHeader."Document Type"::Invoice, Customer."No.");
        ValueEntry.FindLast();
        ServiceHeader.Validate("Posting Date", CalcDate('<1Y>', ValueEntry."Posting Date"));
        ServiceHeader.Modify(true);
    end;

    procedure CreateServDeclServLine(var ServiceLine: Record "Service Line"; ServiceHeader: Record "Service Header")
    var
        Item: Record Item;
    begin
        LibraryInventory.CreateServiceTypeItem(Item);
        LibraryService.CreateServiceLineWithQuantity(
          ServiceLine, ServiceHeader, ServiceLine.Type::Item, Item."No.", LibraryRandom.RandIntInRange(5, 10));
        ServiceLine.Validate("Unit Price", LibraryRandom.RandIntInRange(3, 5));
        ServiceLine.Modify(true);
    end;

    procedure CreatePurchDocWithServTransTypeCode(var PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line")
    begin
        CreatePurchDocApplicableForServDecl(PurchHeader, PurchLine);
        PurchLine.Validate("Service Transaction Type Code", CreateServTransTypeCode());
        PurchLine.Modify(true);
    end;

    procedure CreateResPurchDocWithServTransTypeCode(var PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line")
    begin
        CreateResPurchDocApplicableForServDecl(PurchHeader, PurchLine);
        PurchLine.Validate("Service Transaction Type Code", CreateServTransTypeCode());
        PurchLine.Modify(true);
    end;

    procedure CreateItemChargePurchDocWithServTransTypeCode(var PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line")
    begin
        CreateItemChargePurchDocApplicableForServDecl(PurchHeader, PurchLine);
        PurchLine.Validate("Service Transaction Type Code", CreateServTransTypeCode());
        PurchLine.Modify(true);
    end;

    procedure CreatePurchDocApplicableForServDecl(var PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line")
    begin
        CreateServDeclPurchHeader(PurchHeader);
        CreateServDeclPurchLine(PurchLine, PurchHeader);
    end;

    procedure CreateResPurchDocApplicableForServDecl(var PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line")
    begin
        CreateServDeclPurchHeader(PurchHeader);
        CreateResServDeclPurchLine(PurchLine, PurchHeader);
    end;

    procedure CreateItemChargePurchDocApplicableForServDecl(var PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line")
    begin
        CreateServDeclPurchHeader(PurchHeader);
        CreateItemChargeServDeclPurchLine(PurchLine, PurchHeader);
    end;

    procedure CreateServDeclPurchHeader(var PurchHeader: Record "Purchase Header")
    var
        Vendor: Record Vendor;
        ValueEntry: Record "Value Entry";
    begin
        LibraryPurchase.CreateVendorWithVATRegNo(Vendor);
        LibraryPurchase.CreatePurchHeader(PurchHeader, PurchHeader."Document Type"::Invoice, Vendor."No.");
        ValueEntry.FindLast();
        PurchHeader.Validate("Posting Date", CalcDate('<1Y>', ValueEntry."Posting Date"));
        PurchHeader.Modify(true);
    end;

    procedure CreateServDeclPurchLine(var PurchLine: Record "Purchase Line"; PurchHeader: Record "Purchase Header")
    var
        Item: Record Item;
    begin
        LibraryInventory.CreateServiceTypeItem(Item);
        LibraryPurchase.CreatePurchaseLineWithUnitCost(
            PurchLine, PurchHeader, Item."No.", LibraryRandom.RandDec(100, 2), LibraryRandom.RandInt(100));
    end;

    procedure CreateResServDeclPurchLine(var PurchLine: Record "Purchase Line"; PurchHeader: Record "Purchase Header")
    begin
        LibraryPurchase.CreatePurchaseLine(
            PurchLine, PurchHeader, PurchLine.Type::Resource, LibraryResource.CreateResourceNo(), LibraryRandom.RandInt(100));
        PurchLine.validate("Direct Unit Cost", LibraryRandom.RandDec(100, 2));
        PurchLine.Modify(true);
    end;

    procedure CreateItemChargeServDeclPurchLine(var PurchLine: Record "Purchase Line"; PurchHeader: Record "Purchase Header")
    begin
        LibraryPurchase.CreatePurchaseLine(
            PurchLine, PurchHeader, PurchLine.Type::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(100));
        LibraryPurchase.CreatePurchaseLine(
          PurchLine, PurchHeader,
          PurchLine.Type::"Charge (Item)", LibraryInventory.CreateItemChargeNo(), PurchLine.Quantity);
        PurchLine.Validate("Direct Unit Cost", LibraryRandom.RandDec(10, 2));
        PurchLine.Modify(true);
    end;

    local procedure ChangeFeatureStatus(Enabled: Boolean)
    var
        FeatureDataUpdateStatus: Record "Feature Data Update Status";
    begin
        FeatureDataUpdateStatus.Get(GetServiceDeclarationFeatureKeyId(), CompanyName());
        if Enabled then
            FeatureDataUpdateStatus.Validate("Feature Status", FeatureDataUpdateStatus."Feature Status"::Enabled)
        else
            FeatureDataUpdateStatus.Validate("Feature Status", FeatureDataUpdateStatus."Feature Status"::Disabled);
        FeatureDataUpdateStatus.Modify(true);
    end;

    local procedure GetServiceDeclarationFeatureKeyId(): Text[50]
    begin
        exit('ServiceDeclaration');
    end;
}
