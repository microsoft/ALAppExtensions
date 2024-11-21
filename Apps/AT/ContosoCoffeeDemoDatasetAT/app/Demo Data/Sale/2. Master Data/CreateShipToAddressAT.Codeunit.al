codeunit 11178 "Create Ship-to Address AT"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    //TODO: PostCode Later to be replaced from Labels

    [EventSubscriber(ObjectType::Table, Database::"Ship-to Address", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertShiptoAddress(var Rec: Record "Ship-to Address")
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        CreateCustomer: Codeunit "Create Customer";
    begin
        ContosoCoffeeDemoDataSetup.Get();
        if (Rec."Customer No." = CreateCustomer.DomesticAdatumCorporation()) then
            case Rec.Code of
                Cheltenham():
                    ValidateShiptoAddress(Rec, WienCityLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", PostCodeWienLbl);
                London():
                    ValidateShiptoAddress(Rec, SalzburgCityLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", SalzburgPostCodeLbl);
            end;

        if Rec."Customer No." = CreateCustomer.DomesticTreyResearch() then
            case Rec.Code of
                Fleet(), TWYCross():
                    ValidateShiptoAddress(Rec, WienCityLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", WienPostCodeLbl);
            end;
    end;

    local procedure ValidateShiptoAddress(var ShiptoAddress: Record "Ship-to Address"; City: Text[30]; CountryRegionCode: Code[10]; PostCode: Code[20])
    begin
        ShiptoAddress.Validate("Post Code", PostCode);
        ShiptoAddress.Validate(City, City);
        ShiptoAddress.Validate("Country/Region Code", CountryRegionCode);
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
        WienCityLbl: Label 'Wien', MaxLength = 30;
        SalzburgCityLbl: Label 'Salzburg', MaxLength = 30;
        SalzburgPostCodeLbl: Label '5020', MaxLength = 20;
        PostCodeWienLbl: Label '1230', MaxLength = 20;
        WienPostCodeLbl: Label '1010', MaxLength = 20;
}