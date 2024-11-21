codeunit 11233 "Create Ship-to Address SE"
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
                CreateShiptoAddress.Cheltenham():
                    ValidateShiptoAddress(Rec, GÖTEBORGCityLbl, PostCode41506Lbl);
                CreateShiptoAddress.London():
                    ValidateShiptoAddress(Rec, MALMÖCityLbl, PostCode21216Lbl);
            end;

        if Rec."Customer No." = CreateCustomer.DomesticTreyResearch() then
            case Rec.Code of
                CreateShiptoAddress.Fleet(),
                CreateShiptoAddress.TWYCross():
                    ValidateShiptoAddress(Rec, StockholmCityLbl, PostCode11432Lbl);
            end;
    end;

    local procedure ValidateShiptoAddress(var ShiptoAddress: Record "Ship-to Address"; City: Text[30]; PostCode: Code[20])
    begin
        ShiptoAddress.Validate(City, City);
        ShiptoAddress.Validate("Post Code", PostCode);
    end;

    var
        StockholmCityLbl: Label 'STOCKHOLM', MaxLength = 30, Locked = true;
        GÖTEBORGCityLbl: Label 'GÖTEBORG', MaxLength = 30, Locked = true;
        MALMÖCityLbl: Label 'MALMÖ', MaxLength = 30, Locked = true;
        PostCode41506Lbl: Label '415 06', MaxLength = 20;
        PostCode21216Lbl: Label '212 16', MaxLength = 20;
        PostCode11432Lbl: Label '114 32', MaxLength = 20;
}