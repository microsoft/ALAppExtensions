codeunit 11471 "Create Ship-to Address US"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    //TODO: PostCode Later to be replaced

    //ToDo Need to check later as Primary Key fields are changing

    trigger OnRun()
    var
    //        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
    // ContosoCustomerVendor: Codeunit "Contoso Customer/Vendor";
    // CreateCustomer: Codeunit "Create Customer";
    begin
        //      ContosoCoffeeDemoDataSetup.Get();
        // ContosoCustomerVendor.InsertShiptoAddress(CreateCustomer.DomesticAdatumCorporation(), LewesRoad(), AdatumCorporationLbl, LewesRoadAddressLbl, AtlantaCityLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", '31772', GaLbl);
        // ContosoCustomerVendor.InsertShiptoAddress(CreateCustomer.DomesticAdatumCorporation(), ParkRoad(), AdatumCorporationLbl, ParkRoadAddressLbl, AtlantaCityLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", '31772', GaLbl);
        // ContosoCustomerVendor.InsertShiptoAddress(CreateCustomer.DomesticTreyResearch(), Chicago(), TreyResearchLbl, ChicagoAddressLbl, ChicagoCityLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", '61236', IlLbl);
        // ContosoCustomerVendor.InsertShiptoAddress(CreateCustomer.DomesticTreyResearch(), Miami(), TreyResearchLbl, MiamiAddressLbl, MiamiCityLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", '37125', FlLbl);
        //ToDo Need to check later as Primary Key fields are changing
    end;

    // procedure LewesRoad(): Code[10]
    // begin
    //     exit(LewesRoadTok);
    // end;

    // procedure ParkRoad(): Code[10]
    // begin
    //     exit(ParkRoadTok);
    // end;

    // procedure Chicago(): Code[10]
    // begin
    //     exit(ChicagoTok);
    // end;

    // procedure Miami(): Code[10]
    // begin
    //     exit(MiamiTok);
    // end;

    // var
    //     LewesRoadTok: Label 'LEWES ROAD', MaxLength = 10;
    //     ParkRoadTok: Label 'PARK ROAD', MaxLength = 10;
    //     ChicagoTok: Label 'CHICAGO', MaxLength = 10;
    //     MiamiTok: Label 'MIAMI', MaxLength = 10;
    //     AdatumCorporationLbl: Label 'Adatum Corporation', MaxLength = 100;
    //     TreyResearchLbl: Label 'Trey Research', MaxLength = 100;
    //     LewesRoadAddressLbl: Label '2 Lewes Road', MaxLength = 100;
    //     ParkRoadAddressLbl: Label '10 Park Road', MaxLength = 100;
    //     ChicagoAddressLbl: Label '53 East Acton Road', MaxLength = 100;
    //     MiamiAddressLbl: Label '55 Cross Court', MaxLength = 100;
    //     AtlantaCityLbl: Label 'Atlanta', MaxLength = 30;
    //     ChicagoCityLbl: Label 'Chicago', MaxLength = 30;
    //     MiamiCityLbl: Label 'Miami', MaxLength = 30;
    //     GaLbl: Label 'GA', MaxLength = 30;
    //     IlLbl: Label 'IL', MaxLength = 30;
    //     FlLbl: Label 'FL', MaxLength = 30;
}