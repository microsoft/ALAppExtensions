codeunit 17134 "Create AU Ship-To Address"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Ship-to Address", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecords(var Rec: Record "Ship-to Address"; RunTrigger: Boolean)
    var
        CreateShiptoAddress: Codeunit "Create Ship-to Address";
        CreateCustomer: Codeunit "Create Customer";
    begin
        case Rec."Customer No." of
            CreateCustomer.DomesticAdatumCorporation():
                begin
                    if Rec.Code = CreateShiptoAddress.Cheltenham() then
                        ValidateRecordFields(Rec, CanberraLbl, '2600', NSWCountyLbl, '');
                    if Rec.Code = CreateShiptoAddress.London() then
                        ValidateRecordFields(Rec, BukkullaLbl, '2360', NSWCountyLbl, '');
                end;
            CreateCustomer.DomesticTreyResearch():
                begin
                    if Rec.Code = CreateShiptoAddress.Fleet() then
                        ValidateRecordFields(Rec, BowenBridgeLbl, '4006', QLDCountyLbl, '');
                    if Rec.Code = CreateShiptoAddress.TWYCross() then
                        ValidateRecordFields(Rec, EastMelbourneLbl, '3002', VICCountyLbl, '');
                end;
        end;
    end;

    local procedure ValidateRecordFields(var ShiptoAddress: Record "Ship-to Address"; City: Text[30]; PostCode: Code[20]; County: Text[30]; CountryRegionCode: Code[10])
    begin
        ShiptoAddress.Validate(City, City);
        ShiptoAddress.Validate("Post Code", PostCode);
        ShiptoAddress.Validate(County, County);
        ShiptoAddress."Country/Region Code" := CountryRegionCode;
    end;

    var
        CanberraLbl: Label 'CANBERRA', MaxLength = 30;
        BukkullaLbl: Label 'BUKKULLA', MaxLength = 30;
        BowenBridgeLbl: Label 'BOWEN BRIDGE', MaxLength = 30;
        EastMelbourneLbl: Label 'EAST MELBOURNE', MaxLength = 30;
        NSWCountyLbl: Label 'NSW', MaxLength = 30;
        QLDCountyLbl: Label 'QLD', MaxLength = 30;
        VICCountyLbl: Label 'VIC', MaxLength = 30;
}