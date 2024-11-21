codeunit 11171 "Create Vendor AT"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVendor(var Rec: Record Vendor)
    var
        CreateVendor: Codeunit "Create Vendor";
        CreateCountryRegion: Codeunit "Create Country/Region";
    begin
        case Rec."No." of
            CreateVendor.ExportFabrikam():
                ValidateVendorRecordFields(Rec, ExportFabrikamVatRegLbl, PostCodeGA31772Lbl, 'GA');
            CreateVendor.DomesticFirstUp():
                ValidateRecordFields(Rec, InnsbruckCityLbl, '', '', DomesticFirstUpVatRegLbl, '', PostCode6020Lbl);
            CreateVendor.EUGraphicDesign():
                ValidateRecordFields(Rec, EningenCityLbl, '', CreateCountryRegion.DE(), EUGraphicDesignVatRegLbl, '', PostCode72800Lbl);
            CreateVendor.DomesticWorldImporter():
                ValidateRecordFields(Rec, EisenstadtCityLbl, '', '', DomesticWorldImporterVatRegLbl, '', PostCode7000Lbl);
            CreateVendor.DomesticNodPublisher():
                ValidateRecordFields(Rec, WienCityLbl, '', '', DomesticNodPublisherVatRegLbl, '', PostCode1010Lbl);
        end;
    end;

    local procedure ValidateRecordFields(var Vendor: Record Vendor; City: Text[30]; TerritoryCode: Code[10]; CountryRegionCode: Code[10]; VatRegNo: Text[20]; County: Text[30]; PostCode: Code[20])
    begin
        Vendor.Validate("Post Code", PostCode);
        Vendor.Validate("Territory Code", TerritoryCode);
        Vendor.Validate(City, City);
        Vendor.Validate(County, County);
        Vendor."Country/Region Code" := CountryRegionCode;
        if CountryRegionCode = '' then
            Vendor."VAT Registration No." := VatRegNo
        else
            Vendor.Validate("VAT Registration No.", VatRegNo);

    end;

    local procedure ValidateVendorRecordFields(var Vendor: Record Vendor; VatRegNo: Text[20]; PostCode: Code[20]; County: Text[30])
    begin
        Vendor.Validate("VAT Registration No.", VatRegNo);
        Vendor.Validate("Post Code", PostCode);
        Vendor.Validate(County, County);
    end;

    var
        InnsbruckCityLbl: Label 'Innsbruck', MaxLength = 30, Locked = true;
        EisenstadtCityLbl: Label 'Eisenstadt', MaxLength = 30, Locked = true;
        EningenCityLbl: Label 'Eningen', MaxLength = 30, Locked = true;
        WienCityLbl: Label 'Wien', MaxLength = 30, Locked = true;
        ExportFabrikamVatRegLbl: Label '503912693', MaxLength = 20;
        DomesticFirstUpVatRegLbl: Label 'XATU27486327', MaxLength = 20;
        EUGraphicDesignVatRegLbl: Label '521478963', MaxLength = 20;
        DomesticWorldImporterVatRegLbl: Label 'XATU19754876', MaxLength = 20;
        DomesticNodPublisherVatRegLbl: Label 'XATU29526749', MaxLength = 20;
        PostCodeGA31772Lbl: Label 'GA 31772', MaxLength = 20;
        PostCode6020Lbl: Label '6020', MaxLength = 20;
        PostCode72800Lbl: Label '72800', MaxLength = 20;
        PostCode7000Lbl: Label '7000', MaxLength = 20;
        PostCode1010Lbl: Label '1010', MaxLength = 20;
}