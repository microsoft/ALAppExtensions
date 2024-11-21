codeunit 17139 "Create NZ Ship-To Address"
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
                        ValidateRecordFields(Rec, AucklandLbl, '1015', '');
                    if Rec.Code = CreateShiptoAddress.London() then
                        ValidateRecordFields(Rec, FentonParkLbl, '3201', '');
                end;
            CreateCustomer.DomesticTreyResearch():
                begin
                    if Rec.Code = CreateShiptoAddress.Fleet() then
                        ValidateRecordFields(Rec, ManaiaLbl, '4851', '');
                    if Rec.Code = CreateShiptoAddress.TWYCross() then
                        ValidateRecordFields(Rec, AnnesBrookLbl, '7001', '');
                end;
        end;
    end;

    local procedure ValidateRecordFields(var ShiptoAddress: Record "Ship-to Address"; City: Text[30]; PostCode: Code[20]; CountryRegionCode: Code[10])
    begin
        ShiptoAddress.Validate(City, City);
        ShiptoAddress.Validate("Post Code", PostCode);
        ShiptoAddress."Country/Region Code" := CountryRegionCode;
    end;

    var
        AucklandLbl: Label 'Auckland', MaxLength = 30;
        FentonParkLbl: Label 'Fenton Park', MaxLength = 30;
        ManaiaLbl: Label 'Manaia', MaxLength = 30;
        AnnesBrookLbl: Label 'Annes Brook', MaxLength = 30;
}