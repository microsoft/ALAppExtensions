codeunit 14620 "Create Vendor IS"
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
                ValidateRecordFields(Rec, ReykjavikCityLbl, DomesticFirstUpVatRegNoLbl, PostCode108Lbl);
            CreateVendor.EUGraphicDesign():
                Rec.Validate("VAT Registration No.", EUGraphicDesignVatRegNoLbl);
            CreateVendor.DomesticWorldImporter():
                ValidateRecordFields(Rec, ReykjavikCityLbl, DomesticWorldImporterVatRegNoLbl, PostCode120Lbl);
            CreateVendor.DomesticNodPublisher():
                ValidateRecordFields(Rec, ReykjavikCityLbl, DomesticNodPublisherVatRegNoLbl, PostCode131Lbl);
        end;
    end;

    local procedure ValidateRecordFields(var Vendor: Record Vendor; City: Text[30]; VatRegNo: Text[20]; PostCode: Code[20])
    begin
        Vendor.Validate(City, City);
        Vendor.Validate("Post Code", PostCode);
        Vendor.Validate("VAT Registration No.", VatRegNo);
    end;

    var
        ReykjavikCityLbl: Label 'Reykjavik', MaxLength = 30, Locked = true;
        PostCode108Lbl: Label '108', MaxLength = 20;
        PostCode120Lbl: Label '120', MaxLength = 20;
        PostCode131Lbl: Label '131', MaxLength = 20;
        ExportFabrikamVatRegNoLbl: Label '503912693', MaxLength = 20;
        DomesticFirstUpVatRegNoLbl: Label '274863274B01', MaxLength = 20;
        EUGraphicDesignVatRegNoLbl: Label '521478963', MaxLength = 20;
        DomesticWorldImporterVatRegNoLbl: Label '197548769B01', MaxLength = 20;
        DomesticNodPublisherVatRegNoLbl: Label '295267495B01', MaxLength = 20;
}