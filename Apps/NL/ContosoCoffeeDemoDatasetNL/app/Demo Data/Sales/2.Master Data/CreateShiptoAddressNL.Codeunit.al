codeunit 11512 "Create Ship-to Address NL"
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
                    ValidateShiptoAddress(Rec, AmsterdamCityLbl, PostCode7201HWLbl);
                CreateShiptoAddress.London():
                    ValidateShiptoAddress(Rec, ApeldoornCityLbl, PostCode3781ENLbl);
            end;

        if Rec."Customer No." = CreateCustomer.DomesticTreyResearch() then
            case Rec.Code of
                CreateShiptoAddress.Fleet():
                    ValidateShiptoAddress(Rec, ArnhemCityLbl, PostCode1012LXLbl);
                CreateShiptoAddress.TWYCross():
                    ValidateShiptoAddress(Rec, WaalwijkCityLbl, PostCode8071LMLbl);
            end;
    end;

    local procedure ValidateShiptoAddress(var ShiptoAddress: Record "Ship-to Address"; City: Text[30]; PostCode: Code[20])
    begin
        ShiptoAddress.Validate(City, City);
        ShiptoAddress.Validate("Post Code", PostCode);
    end;

    var
        AmsterdamCityLbl: Label 'Amsterdam', MaxLength = 30;
        ApeldoornCityLbl: Label 'Apeldoorn', MaxLength = 30;
        ArnhemCityLbl: Label 'Arnhem', MaxLength = 30;
        WaalwijkCityLbl: Label 'Waalwijk', MaxLength = 30;
        PostCode7201HWLbl: Label '7201 HW', MaxLength = 20;
        PostCode3781ENLbl: Label '3781 EN', MaxLength = 20;
        PostCode1012LXLbl: Label '1012 LX', MaxLength = 20;
        PostCode8071LMLbl: Label '8071 LM', MaxLength = 20;
}