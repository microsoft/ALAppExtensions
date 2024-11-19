codeunit 14617 "Create Ship-to Address IS"
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
        CreateShiptoAddress: Codeunit "Create Ship-to Address";
    begin
        ContosoCoffeeDemoDataSetup.Get();
        if (Rec."Customer No." = CreateCustomer.DomesticAdatumCorporation()) then
            case Rec.Code of
                CreateShiptoAddress.Cheltenham(),
                CreateShiptoAddress.London():
                    ValidateShiptoAddress(Rec, CityLbl, PostCodeLbl);
            end;

        if Rec."Customer No." = CreateCustomer.DomesticTreyResearch() then
            case Rec.Code of
                CreateShiptoAddress.Fleet(),
                CreateShiptoAddress.TWYCross():
                    ValidateShiptoAddress(Rec, CityLbl, PostCodeLbl);
            end;
    end;

    local procedure ValidateShiptoAddress(var ShiptoAddress: Record "Ship-to Address"; City: Text[30]; PostCode: Code[20])
    begin
        ShiptoAddress.Validate(City, City);
        ShiptoAddress.Validate("Post Code", PostCode);
    end;

    var
        CityLbl: Label 'Reykjavik', MaxLength = 30, Locked = true;
        PostCodeLbl: Label '131', MaxLength = 20;
}