codeunit 12226 "Create Ship-to Address IT"
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
                    ValidateShiptoAddress(Rec, MilanoCityLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", PostCode20100Lbl);
                London():
                    ValidateShiptoAddress(Rec, PalermoCityLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", PostCode90100Lbl);
            end;

        if Rec."Customer No." = CreateCustomer.DomesticTreyResearch() then
            case Rec.Code of
                Fleet():
                    ValidateShiptoAddress(Rec, LivornoCityLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", PostCode57100Lbl);
                TWYCross():
                    ValidateShiptoAddress(Rec, ArenzanoCityLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", PostCode16011Lbl);
            end;
    end;

    local procedure ValidateShiptoAddress(var ShiptoAddress: Record "Ship-to Address"; City: Text[30]; CountryRegionCode: Code[10]; PostCode: Code[20])
    begin

        ShiptoAddress.Validate("Country/Region Code", CountryRegionCode);
        ShiptoAddress.Validate(City, City);
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
        MilanoCityLbl: Label 'Milano', MaxLength = 30;
        PalermoCityLbl: Label 'Palermo', MaxLength = 30;
        ArenzanoCityLbl: Label 'Arenzano', MaxLength = 30;
        LivornoCityLbl: Label 'Livorno', MaxLength = 30;
        PostCode20100Lbl: Label '20100', MaxLength = 20;
        PostCode90100Lbl: Label '90100', MaxLength = 20;
        PostCode57100Lbl: Label '57100', MaxLength = 20;
        PostCode16011Lbl: Label '16011', MaxLength = 20;
}