codeunit 11615 "Create CH Ship-to Address"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Ship-to Address", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertShiptoAddress(var Rec: Record "Ship-to Address")
    var
        CreateShiptoAddress: Codeunit "Create Ship-to Address";
        CreateCustomer: Codeunit "Create Customer";
    begin
        if (Rec."Customer No." = CreateCustomer.DomesticAdatumCorporation()) and (Rec.Code = CreateShiptoAddress.Cheltenham()) then
            ValidateRecordFields(Rec, '', '3000');

        if (Rec."Customer No." = CreateCustomer.DomesticAdatumCorporation()) and (Rec.Code = CreateShiptoAddress.London()) then
            ValidateRecordFields(Rec, '', '6343');

        if (Rec."Customer No." = CreateCustomer.DomesticTreyResearch()) and (Rec.Code = CreateShiptoAddress.Fleet()) then
            ValidateRecordFields(Rec, '', '6440');

        if (Rec."Customer No." = CreateCustomer.DomesticTreyResearch()) and (Rec.Code = CreateShiptoAddress.TWYCross()) then
            ValidateRecordFields(Rec, '', '6440');
    end;

    local procedure ValidateRecordFields(var ShiptoAddress: Record "Ship-to Address"; CountryRegionCode: Code[10]; PostCode: Code[20])
    begin
        ShiptoAddress.Validate("Post Code", PostCode);
        ShiptoAddress.Validate("Country/Region Code", CountryRegionCode);
    end;
}