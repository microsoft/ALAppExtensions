codeunit 11382 "Create Vendor BE"
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
        CreateVATPostingGroupBE: Codeunit "Create VAT Posting Group BE";
    begin
        ContosoCoffeeDemoDataSetup.Get();
        case Rec."No." of
            CreateVendor.ExportFabrikam():
                begin
                    Rec.Validate("VAT Registration No.", ExportFabrikamVatRegLbl);
                    Rec.Validate("VAT Bus. Posting Group", CreateVATPostingGroupBE.IMPEXP());
                end;
            CreateVendor.DomesticFirstUp():
                ValidateRecordFields(Rec, GenkCityLbl, CreateVendorPostingGroup.Foreign(), ContosoCoffeeDemoDataSetup."Country/Region Code", '', '', PostCode3600Lbl);
            CreateVendor.EUGraphicDesign():
                Rec.Validate("VAT Registration No.", EUGraphicDesignVatRegLbl);
            CreateVendor.DomesticWorldImporter():
                ValidateRecordFields(Rec, DeurneCityLbl, CreateVendorPostingGroup.Foreign(), ContosoCoffeeDemoDataSetup."Country/Region Code", '', '', PostCode2100Lbl);
            CreateVendor.DomesticNodPublisher():
                ValidateRecordFields(Rec, BurchtCityLbl, CreateVendorPostingGroup.Foreign(), ContosoCoffeeDemoDataSetup."Country/Region Code", '', '', PostCode2070Lbl);
        end;
    end;

    local procedure ValidateRecordFields(var Vendor: Record Vendor; City: Text[30]; TerritoryCode: Code[20]; CountryRegionCode: Code[10]; VatRegNo: Text[20]; County: Text[30]; PostCode: Code[20])
    begin
        Vendor.Validate(City, City);
        Vendor.Validate("Territory Code", TerritoryCode);
        Vendor.Validate("Country/Region Code", CountryRegionCode);
        if CountryRegionCode = '' then
            Vendor."VAT Registration No." := VatRegNo
        else
            Vendor.Validate("VAT Registration No.", VatRegNo);
        Vendor.Validate(County, County);
        Vendor.Validate("Post Code", PostCode);
    end;

    var
        GenkCityLbl: Label 'GENK', MaxLength = 30, Locked = true;
        DeurneCityLbl: Label 'DEURNE', MaxLength = 30, Locked = true;
        BurchtCityLbl: Label 'BURCHT', MaxLength = 30, Locked = true;
        ExportFabrikamVatRegLbl: Label '503912693', MaxLength = 20;
        EUGraphicDesignVatRegLbl: Label '521478963', MaxLength = 20;
        PostCode3600Lbl: Label '3600', MaxLength = 20;
        PostCode2100Lbl: Label '2100', MaxLength = 20;
        PostCode2070Lbl: Label '2070', MaxLength = 20;
}