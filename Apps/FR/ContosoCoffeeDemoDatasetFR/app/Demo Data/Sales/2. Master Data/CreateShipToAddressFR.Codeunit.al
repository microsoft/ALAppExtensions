codeunit 10888 "Create Ship-to Address FR"
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
                    ValidateShiptoAddress(Rec, ParisCityLbl, PostCode75008Lbl);
                CreateShiptoAddress.London():
                    ValidateShiptoAddress(Rec, ParisCityLbl, PostCode75009Lbl);
            end;

        if Rec."Customer No." = CreateCustomer.DomesticTreyResearch() then
            case Rec.Code of
                CreateShiptoAddress.Fleet():
                    ValidateShiptoAddress(Rec, NantesCityLbl, PostCode44000Lbl);
                CreateShiptoAddress.TWYCross():
                    ValidateShiptoAddress(Rec, NancyCityLbl, PostCode54000Lbl);
            end;
    end;

    local procedure ValidateShiptoAddress(var ShiptoAddress: Record "Ship-to Address"; City: Text[30]; PostCode: Code[20])
    begin
        ShiptoAddress.Validate(City, City);
        ShiptoAddress.Validate("Post Code", PostCode);
    end;

    var
        ParisCityLbl: Label 'Paris', MaxLength = 30;
        NantesCityLbl: Label 'Nantes', MaxLength = 30;
        NancyCityLbl: Label 'Nancy', MaxLength = 30;
        PostCode75008Lbl: Label '75008', MaxLength = 20;
        PostCode75009Lbl: Label '75009', MaxLength = 20;
        PostCode44000Lbl: Label '44000', MaxLength = 20;
        PostCode54000Lbl: Label '54000', MaxLength = 20;
}