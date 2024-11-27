codeunit 10720 "Create Ship-to Address NO"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Ship-to Address", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertShiptoAddress(var Rec: Record "Ship-to Address")
    var
        CreateCustomer: Codeunit "Create Customer";
        CreateShiptoAddress: Codeunit "Create Ship-to Address";
    begin
        if (Rec."Customer No." = CreateCustomer.DomesticAdatumCorporation()) then
            case Rec.Code of
                CreateShiptoAddress.Cheltenham():
                    ValidateShiptoAddress(Rec, OsloCityLbl, PostCode0102Lbl);
                CreateShiptoAddress.London():
                    ValidateShiptoAddress(Rec, OsloCityLbl, PostCode0001Lbl);
            end;

        if Rec."Customer No." = CreateCustomer.DomesticTreyResearch() then
            case Rec.Code of
                CreateShiptoAddress.Fleet():
                    ValidateShiptoAddress(Rec, VoldaCityLbl, PostCode6100Lbl);
                CreateShiptoAddress.TWYCross():
                    ValidateShiptoAddress(Rec, OsloCityLbl, PostCode1001Lbl);
            end;
    end;

    local procedure ValidateShiptoAddress(var ShiptoAddress: Record "Ship-to Address"; City: Text[30]; PostCode: Code[20])
    begin
        ShiptoAddress.Validate(City, City);
        ShiptoAddress.Validate("Post Code", PostCode);
    end;

    var
        OsloCityLbl: Label 'OSLO', MaxLength = 30, Locked = true;
        VoldaCityLbl: Label 'VOLDA', MaxLength = 30, Locked = true;
        PostCode0102Lbl: Label '0102', MaxLength = 20;
        PostCode0001Lbl: Label '0001', MaxLength = 20;
        PostCode6100Lbl: Label '6100', MaxLength = 20;
        PostCode1001Lbl: Label '1001', MaxLength = 20;
}