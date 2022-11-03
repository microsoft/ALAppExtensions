codeunit 139900 "Library - Service Declaration"
{

    var
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryRandom: Codeunit "Library - Random";


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

    procedure CreateSalesDocApplicableForServDecl(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
        CreateServDeclSalesHeader(SalesHeader);
        CreateServDeclSalesLine(SalesLine, SalesHeader);
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

    procedure CreatePurchDocWithServTransTypeCode(var PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line")
    begin
        CreatePurchDocApplicableForServDecl(PurchHeader, PurchLine);
        PurchLine.Validate("Service Transaction Type Code", CreateServTransTypeCode());
        PurchLine.Modify(true);
    end;

    procedure CreatePurchDocApplicableForServDecl(var PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line")
    begin
        CreateServDeclPurchHeader(PurchHeader);
        CreateServDeclPurchLine(PurchLine, PurchHeader);
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
