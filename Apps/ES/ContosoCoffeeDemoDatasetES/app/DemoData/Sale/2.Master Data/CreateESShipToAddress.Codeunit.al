codeunit 10822 "Create ES Ship-to Address"
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

        if (Rec."Customer No." = CreateCustomer.DomesticAdatumCorporation()) then begin
            if Rec.Code = CreateShiptoAddress.Cheltenham() then
                ValidateShiptoAddress(Rec, MadridCityLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", PostCode28023Lbl, MadridCountyLbl);
            if Rec.Code = CreateShiptoAddress.London() then
                ValidateShiptoAddress(Rec, VillalbaCityLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", PostCode28240Lbl, MadridCountyLbl);
        end;

        if Rec."Customer No." = CreateCustomer.DomesticTreyResearch() then begin
            if Rec.Code = CreateShiptoAddress.Fleet() then
                ValidateShiptoAddress(Rec, ZaragozaCityLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", PostCode50001Lbl, ZaragozaCountyLbl);
            if Rec.Code = CreateShiptoAddress.TWYCross() then
                ValidateShiptoAddress(Rec, AlicanteCityLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", PostCode03003Lbl, AlicanteCountyLbl);
        end;
    end;

    local procedure ValidateShiptoAddress(var ShiptoAddress: Record "Ship-to Address"; City: Text[30]; CountryRegionCode: Code[10]; PostCode: Code[20]; ShipCounty: Text[30])
    begin
        ShiptoAddress.Validate(City, City);
        ShiptoAddress.Validate("Country/Region Code", CountryRegionCode);
        ShiptoAddress.Validate("Post Code", PostCode);
        ShiptoAddress.Validate(County, ShipCounty);
    end;

    var
        VillalbaCityLbl: Label 'Villalba', MaxLength = 30;
        MadridCityLbl: Label 'Madrid', MaxLength = 30;
        MadridCountyLbl: Label 'MADRID', MaxLength = 30;
        ZaragozaCityLbl: Label 'Zaragoza', MaxLength = 30;
        ZaragozaCountyLbl: Label 'ZARAGOZA', MaxLength = 30;
        AlicanteCityLbl: Label 'Alicante', MaxLength = 30;
        AlicanteCountyLbl: Label 'ALICANTE/ALACANT', MaxLength = 30;
        PostCode28023Lbl: Label '28023', MaxLength = 20;
        PostCode28240Lbl: Label '28240', MaxLength = 20;
        PostCode50001Lbl: Label '50001', MaxLength = 20;
        PostCode03003Lbl: Label '03003', MaxLength = 20;
}