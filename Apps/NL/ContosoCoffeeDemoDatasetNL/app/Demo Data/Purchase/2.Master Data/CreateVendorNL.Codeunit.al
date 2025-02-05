codeunit 11520 "Create Vendor NL"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVendor(var Rec: Record Vendor)
    var
        CreateVendor: Codeunit "Create Vendor";
    begin
        case Rec."No." of
            CreateVendor.ExportFabrikam():
                Rec.Validate("VAT Registration No.", ExportFabrikamVatRegNoLbl);
            CreateVendor.DomesticFirstUp():
                ValidateRecordFields(Rec, ZaandamCityLbl, DomesticFirstUpVatRegNoLbl, PostCode3872LLLbl);
            CreateVendor.EUGraphicDesign():
                Rec.Validate("VAT Registration No.", EUGraphicDesignVatRegNoLbl);
            CreateVendor.DomesticWorldImporter():
                ValidateRecordFields(Rec, ApeldoornCityLbl, DomesticWorldImporterVatRegNoLbl, PostCode5141GPLbl);
            CreateVendor.DomesticNodPublisher():
                ValidateRecordFields(Rec, WaalwijkCityLbl, DomesticNodPublisherVatRegNoLbl, PostCode8071LMLbl);
        end;
    end;

    local procedure ValidateRecordFields(var Vendor: Record Vendor; City: Text[30]; VatRegNo: Text[20]; PostCode: Code[20])
    begin
        Vendor.Validate(City, City);
        Vendor.Validate("Post Code", PostCode);
        Vendor.Validate("VAT Registration No.", VatRegNo);
    end;

    var
        ZaandamCityLbl: Label 'Zaandam', MaxLength = 30;
        ApeldoornCityLbl: Label 'Apeldoorn', MaxLength = 30;
        WaalwijkCityLbl: Label 'Waalwijk', MaxLength = 30;
        PostCode3872LLLbl: Label '3872 LL', MaxLength = 20;
        PostCode5141GPLbl: Label '5141 GP', MaxLength = 20;
        PostCode8071LMLbl: Label '8071 LM', MaxLength = 20;
        ExportFabrikamVatRegNoLbl: Label '503912693', MaxLength = 20;
        DomesticFirstUpVatRegNoLbl: Label '274863274B01', MaxLength = 20;
        EUGraphicDesignVatRegNoLbl: Label '521478963', MaxLength = 20;
        DomesticWorldImporterVatRegNoLbl: Label '197548769B01', MaxLength = 20;
        DomesticNodPublisherVatRegNoLbl: Label '295267495B01', MaxLength = 20;
}