codeunit 11227 "Create Vendor SE"
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
                ValidateRecordFields(Rec, StockholmLbl, '503912693', PostCode11432Lbl, CreateCountryRegion.US());
            CreateVendor.DomesticFirstUp():
                ValidateRecordFields(Rec, StockholmLbl, 'SE274863274501', PostCode11432Lbl, CreateCountryRegion.SE());
            CreateVendor.EUGraphicDesign():
                Rec."VAT Registration No." := EUGraphicDesignVatRegNoLbl;
            CreateVendor.DomesticWorldImporter():
                ValidateRecordFields(Rec, StockholmLbl, 'SE197548769001', PostCode11432Lbl, CreateCountryRegion.SE());
            CreateVendor.DomesticNodPublisher():
                ValidateRecordFields(Rec, StockholmLbl, 'SE295267495601', PostCode11432Lbl, CreateCountryRegion.SE());
        end;
    end;

    local procedure ValidateRecordFields(var Vendor: Record Vendor; City: Text[30]; VatRegNo: Text[20]; PostCode: Code[20]; CountryRegionCode: Code[10])
    begin
        Vendor.Validate(City, City);
        Vendor.Validate("Post Code", PostCode);
        Vendor."VAT Registration No." := VatRegNo;
        Vendor."Country/Region Code" := CountryRegionCode;
    end;

    var
        StockholmLbl: Label 'STOCKHOLM', MaxLength = 30, Locked = true;
        EUGraphicDesignVatRegNoLbl: Label '521478963', MaxLength = 20;
        PostCode11432Lbl: Label '114 32', MaxLength = 20;
}