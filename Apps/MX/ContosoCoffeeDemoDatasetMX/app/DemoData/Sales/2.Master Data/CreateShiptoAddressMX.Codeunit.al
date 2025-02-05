codeunit 14137 "Create Ship-to Address MX"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        Customer: Record Customer;
        ContosoCustomerVendor: Codeunit "Contoso Customer/Vendor";
        CreateCustomer: Codeunit "Create Customer";
        CreateCountryRegion: Codeunit "Create Country/Region";
    begin
        Customer.Get(CreateCustomer.DomesticAdatumCorporation());
        ContosoCustomerVendor.InsertShiptoAddress(Customer."No.", LewesRoad(), Customer.Name, LewesRoad2Lbl, AtlantaCityLbl, CreateCountryRegion.US(), PostCode31772Lbl);
        ContosoCustomerVendor.InsertShiptoAddress(Customer."No.", ParkRoad(), Customer.Name, ParkRoad10Lbl, AtlantaCityLbl, CreateCountryRegion.US(), PostCode31772Lbl);

        Customer.Get(CreateCustomer.DomesticTreyResearch());
        ContosoCustomerVendor.InsertShiptoAddress(Customer."No.", Chicago(), Customer.Name, EastActonRoad53AddressLbl, ChicagoCityLbl, CreateCountryRegion.US(), PostCode61236Lbl);
        ContosoCustomerVendor.InsertShiptoAddress(Customer."No.", Miami(), Customer.Name, CrossCourt55AddressLbl, MiamiCityLbl, CreateCountryRegion.US(), PostCode37125Lbl);
    end;

    procedure LewesRoad(): Code[10]
    begin
        exit(LewesRoadTok);
    end;

    procedure ParkRoad(): Code[10]
    begin
        exit(ParkRoadTok);
    end;

    procedure Chicago(): Code[10]
    begin
        exit(ChicagoTok);
    end;

    procedure Miami(): Code[10]
    begin
        exit(MiamiTok);
    end;

    var
        LewesRoadTok: Label 'LEWES ROAD', MaxLength = 10;
        ParkRoadTok: Label 'PARK ROAD', MaxLength = 10;
        ChicagoTok: Label 'CHICAGO', MaxLength = 10;
        MiamiTok: Label 'MIAMI', MaxLength = 10;
        LewesRoad2Lbl: Label '2 Lewes Road', MaxLength = 100;
        ParkRoad10Lbl: Label '10 Park Road', MaxLength = 100;
        EastActonRoad53AddressLbl: Label '53 East Acton Road', MaxLength = 100;
        CrossCourt55AddressLbl: Label '55 Cross Court', MaxLength = 100;
        AtlantaCityLbl: Label 'Atlanta', MaxLength = 30;
        ChicagoCityLbl: Label 'Chicago', MaxLength = 30;
        MiamiCityLbl: Label 'Miami', MaxLength = 30;
        PostCode31772Lbl: Label '31772', MaxLength = 20;
        PostCode61236Lbl: Label '61236', MaxLength = 20;
        PostCode37125Lbl: Label '37125', MaxLength = 20;
}