codeunit 11391 "Create Ship-to Address BE"
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
        CreateShipToAddress: Codeunit "Create Ship-to Address";
    begin
        ContosoCoffeeDemoDataSetup.Get();
        if (Rec."Customer No." = CreateCustomer.DomesticAdatumCorporation()) then
            case Rec.Code of
                CreateShipToAddress.Cheltenham(), CreateShipToAddress.London():
                    ValidateShiptoAddress(Rec, BurchtCityLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", '2070');
            end;

        if (Rec."Customer No." = CreateCustomer.DomesticTreyResearch()) then
            case Rec.Code of
                CreateShipToAddress.Fleet(), CreateShipToAddress.TWYCross():
                    ValidateShiptoAddress(Rec, BurchtCityLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", '2070');
            end;
    end;

    local procedure ValidateShiptoAddress(var ShiptoAddress: Record "Ship-to Address"; City: Text[30]; CountryRegionCode: Code[10]; PostCode: Code[20])
    begin
        ShiptoAddress.Validate(City, City);
        ShiptoAddress.Validate("Country/Region Code", CountryRegionCode);
        ShiptoAddress.Validate("Post Code", PostCode);
    end;

    var
        BurchtCityLbl: Label 'BURCHT', MaxLength = 30;
}