codeunit 10883 "Create Vendor FR"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVendor(var Rec: Record Vendor)
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        CreateVendor: Codeunit "Create Vendor";
        CreateVendorPostingGroup: codeunit "Create Vendor Posting Group";
    begin
        ContosoCoffeeDemoDataSetup.Get();
        case Rec."No." of
            CreateVendor.ExportFabrikam():
                Rec.Validate("VAT Registration No.", ExportFabrikamVatRegLbl);
            CreateVendor.DomesticFirstUp():
                ValidateRecordFields(Rec, NantesCityLbl, CreateVendorPostingGroup.Foreign(), ContosoCoffeeDemoDataSetup."Country/Region Code", 'FR27486327456', '', PostCode44000Lbl);
            CreateVendor.EUGraphicDesign():
                Rec.Validate("VAT Registration No.", EUGraphicDesignVatRegLbl);
            CreateVendor.DomesticWorldImporter():
                ValidateRecordFields(Rec, NantesCityLbl, CreateVendorPostingGroup.Foreign(), ContosoCoffeeDemoDataSetup."Country/Region Code", 'FR19754876901', '', PostCode44000Lbl);
            CreateVendor.DomesticNodPublisher():
                ValidateRecordFields(Rec, BordeauxCityLbl, CreateVendorPostingGroup.Foreign(), ContosoCoffeeDemoDataSetup."Country/Region Code", 'FR29526749567', '', PostCode33000Lbl);
        end;
    end;

    local procedure ValidateRecordFields(var Vendor: Record Vendor; City: Text[30]; TerritoryCode: Code[20]; CountryRegionCode: Code[10]; VatRegNo: Text[20]; County: Text[30]; PostCode: Code[20])
    begin
        Vendor.Validate("Post Code", PostCode);
        Vendor.Validate(City, City);
        Vendor.Validate("Territory Code", TerritoryCode);
        Vendor.Validate("Country/Region Code", CountryRegionCode);
        if CountryRegionCode = '' then
            Vendor."VAT Registration No." := VatRegNo
        else
            Vendor.Validate("VAT Registration No.", VatRegNo);
        Vendor.Validate(County, County);
    end;

    var
        NantesCityLbl: Label 'Nantes', MaxLength = 30, Locked = true;
        BordeauxCityLbl: Label 'Bordeaux', MaxLength = 30, Locked = true;
        ExportFabrikamVatRegLbl: Label '503912693', MaxLength = 20;
        EUGraphicDesignVatRegLbl: Label '521478963', MaxLength = 20;
        PostCode44000Lbl: Label '44000', MaxLength = 20;
        PostCode33000Lbl: Label '33000', MaxLength = 20;
}