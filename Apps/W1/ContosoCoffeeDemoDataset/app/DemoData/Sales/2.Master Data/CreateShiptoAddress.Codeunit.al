codeunit 5243 "Create Ship-to Address"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ContosoCustomerVendor: Codeunit "Contoso Customer/Vendor";
        CreateCustomer: Codeunit "Create Customer";
    begin
        ContosoCoffeeDemoDataSetup.Get();
        ContosoCustomerVendor.InsertShiptoAddress(CreateCustomer.DomesticAdatumCorporation(), Cheltenham(), AdatumCorporationLbl, CheltenhamAddressLbl, CheltenhamCityLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", 'GL50 1TY');
        ContosoCustomerVendor.InsertShiptoAddress(CreateCustomer.DomesticAdatumCorporation(), London(), AdatumCorporationLbl, LondonAddressLbl, LondonCityLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", 'W2 6BD');
        ContosoCustomerVendor.InsertShiptoAddress(CreateCustomer.DomesticTreyResearch(), Fleet(), TreyResearchLbl, FleetAddressLbl, FleetCityLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", 'GU52 8DY');
        ContosoCustomerVendor.InsertShiptoAddress(CreateCustomer.DomesticTreyResearch(), TWYCross(), TreyResearchLbl, TWYCrossAddressLbl, TWYCityLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", 'CV9 3QN');
    end;

    procedure Cheltenham(): Code[10]
    begin
        exit(CheltenhamTok);
    end;

    procedure London(): Code[10]
    begin
        exit(LondonTok);
    end;

    procedure Fleet(): Code[10]
    begin
        exit(FleetTok);
    end;

    procedure TWYCross(): Code[10]
    begin
        exit(TWYCrossTok);
    end;

    var
        CheltenhamTok: Label 'CHELTENHAM', MaxLength = 10;
        LondonTok: Label 'LONDON', MaxLength = 10;
        FleetTok: Label 'FLEET', MaxLength = 10;
        TWYCrossTok: Label 'TWYCROSS', MaxLength = 10;
        AdatumCorporationLbl: Label 'Adatum Corporation', MaxLength = 100;
        TreyResearchLbl: Label 'Trey Research', MaxLength = 100;
        CheltenhamAddressLbl: Label 'Montpellier House', MaxLength = 100;
        LondonAddressLbl: Label 'Kingdom Street, 2', MaxLength = 100;
        FleetAddressLbl: Label 'Beacon Hill Road', MaxLength = 100;
        TWYCrossAddressLbl: Label 'Manor Park', MaxLength = 100;
        CheltenhamCityLbl: Label 'Cheltenham', MaxLength = 30;
        LondonCityLbl: Label 'London', MaxLength = 30;
        FleetCityLbl: Label 'Fleet', MaxLength = 30;
        TWYCityLbl: Label 'Atherstone', MaxLength = 30;
}