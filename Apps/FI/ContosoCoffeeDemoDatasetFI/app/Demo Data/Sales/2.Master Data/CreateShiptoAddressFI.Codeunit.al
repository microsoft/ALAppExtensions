codeunit 13417 "Create Ship-to Address FI"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

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
                    ValidateShiptoAddress(Rec, HelsinkiCityLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", PostCode1201Lbl);
                London():
                    ValidateShiptoAddress(Rec, HelsinkiCityLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", PostCode90100Lbl);
            end;

        if Rec."Customer No." = CreateCustomer.DomesticTreyResearch() then
            case Rec.Code of
                Fleet():
                    ValidateShiptoAddress(Rec, HelsinkiCityLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", PostCode80100Lbl);
                TWYCross():
                    ValidateShiptoAddress(Rec, HelsinkiCityLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", PostCode57810Lbl);
            end;
    end;

    local procedure ValidateShiptoAddress(var ShiptoAddress: Record "Ship-to Address"; City: Text[30]; CountryRegionCode: Code[10]; PostCode: Code[20])
    begin
        ShiptoAddress.Validate(City, City);
        ShiptoAddress.Validate("Country/Region Code", CountryRegionCode);
        ShiptoAddress.Validate("Post Code", PostCode);
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
        HelsinkiCityLbl: Label 'Helsinki', MaxLength = 30;
        PostCode1201Lbl: Label '01201', MaxLength = 20;
        PostCode90100Lbl: Label '90100', MaxLength = 20;
        PostCode80100Lbl: Label '80100', MaxLength = 20;
        PostCode57810Lbl: Label '57810', MaxLength = 20;
}