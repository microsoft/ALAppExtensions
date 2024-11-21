codeunit 13419 "Create Vendor FI"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVendor(var Rec: Record Vendor)
    var
        CreateVendor: Codeunit "Create Vendor";
        CreatePaymentTerms: Codeunit "Create Payment Terms";
    begin
        case Rec."No." of
            CreateVendor.ExportFabrikam():
                Rec.Validate("VAT Registration No.", ExportFabrikamVatRegNoLbl);
            CreateVendor.DomesticFirstUp():
                ValidateRecordFields(Rec, HelsinkiCityLbl, DomesticFirstUpVatRegNoLbl, PostCode45160Lbl, CreatePaymentTerms.PaymentTermsDAYS30());
            CreateVendor.EUGraphicDesign():
                Rec.Validate("VAT Registration No.", EUGraphicDesignVatRegNoLbl);
            CreateVendor.DomesticWorldImporter():
                ValidateRecordFields(Rec, HelsinkiCityLbl, DomesticWorldImporterVatRegNoLbl, PostCode60320Lbl, CreatePaymentTerms.PaymentTermsCM());
            CreateVendor.DomesticNodPublisher():
                ValidateRecordFields(Rec, HelsinkiCityLbl, DomesticNodPublisherVatRegNoLbl, PostCode57810Lbl, CreatePaymentTerms.PaymentTermsCM());
        end;
    end;

    local procedure ValidateRecordFields(var Vendor: Record Vendor; City: Text[30]; VatRegNo: Text[20]; PostCode: Code[20]; PaymentTermsCode: Code[10])
    begin
        Vendor.Validate(City, City);
        Vendor.Validate("VAT Registration No.", VatRegNo);
        Vendor.Validate("Post Code", PostCode);
        Vendor.Validate("Payment Terms Code", PaymentTermsCode);
    end;

    var
        HelsinkiCityLbl: Label 'Helsinki', MaxLength = 30, Locked = true;
        ExportFabrikamVatRegNoLbl: Label '503912693', MaxLength = 20;
        DomesticFirstUpVatRegNoLbl: Label '274863274', MaxLength = 20;
        EUGraphicDesignVatRegNoLbl: Label '521478963', MaxLength = 20;
        DomesticWorldImporterVatRegNoLbl: Label '197548769', MaxLength = 20;
        DomesticNodPublisherVatRegNoLbl: Label '295267495', MaxLength = 20;
        PostCode45160Lbl: Label '45160', MaxLength = 20;
        PostCode60320Lbl: Label '60320', MaxLength = 20;
        PostCode57810Lbl: Label '57810', MaxLength = 20;
}