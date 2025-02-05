codeunit 11497 "Create GB Vendor"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecords(var Rec: Record Vendor; RunTrigger: Boolean)
    var
        CreateVendor: Codeunit "Create Vendor";
    begin
        case Rec."No." of
            CreateVendor.ExportFabrikam():
                ValidateRecordFields(Rec, '', true);
            CreateVendor.DomesticFirstUp():
                ValidateRecordFields(Rec, DomesticFirstUpVATLbl, true);
            CreateVendor.EUGraphicDesign():
                ValidateRecordFields(Rec, EUGraphicDesignVATLbl, true);
            CreateVendor.DomesticWorldImporter():
                ValidateRecordFields(Rec, DomesticWorldImporterVATLbl, true);
            CreateVendor.DomesticNodPublisher():
                ValidateRecordFields(Rec, DomesticNodPublisherVATLbl, false);
        end;
    end;

    local procedure ValidateRecordFields(var Vendor: Record Vendor; VATRegistrationNo: Code[20]; TaxLiable: Boolean)
    begin
        Vendor.Validate("VAT Registration No.", VATRegistrationNo);
        Vendor.Validate("Tax Liable", TaxLiable);
    end;

    var
        DomesticFirstUpVATLbl: Label 'GB444444444', MaxLength = 20;
        EUGraphicDesignVATLbl: Label 'DE777777777', MaxLength = 20;
        DomesticWorldImporterVATLbl: Label 'GB555555555', MaxLength = 20;
        DomesticNodPublisherVATLbl: Label 'GB666666666', MaxLength = 20;
}