codeunit 12218 "Create Vendor IT"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVendor(var Rec: Record Vendor)
    var
        CreateVendor: Codeunit "Create Vendor";
        CreateTerritory: Codeunit "Create Territory";
    begin
        case Rec."No." of
            CreateVendor.ExportFabrikam():
                Rec.Validate("VAT Registration No.", ExportFabrikamVatRegNoLbl);
            CreateVendor.DomesticFirstUp():
                ValidateRecordFields(Rec, NapoliCityLbl, DomesticFirstUpVatRegNoLbl, PostCode80100Lbl, CreateTerritory.Foreign());
            CreateVendor.EUGraphicDesign():
                Rec.Validate("VAT Registration No.", EUGraphicDesignVatRegNoLbl);
            CreateVendor.DomesticWorldImporter():
                ValidateRecordFields(Rec, ReggioEmiliaCityLbl, DomesticWorldImporterVatRegNoLbl, PostCode42100Lbl, CreateTerritory.Foreign());
            CreateVendor.DomesticNodPublisher():
                ValidateRecordFields(Rec, ArenzanoCityLbl, DomesticNodPublisherVatRegNoLbl, PostCode16011Lbl, CreateTerritory.Foreign());
        end;
    end;

    local procedure ValidateRecordFields(var Vendor: Record Vendor; City: Text[30]; VatRegNo: Text[20]; PostCode: Code[20]; TerritoryCode: Code[10])
    begin
        Vendor.Validate(City, City);
        Vendor.Validate("VAT Registration No.", VatRegNo);
        Vendor.Validate("Post Code", PostCode);
        Vendor.Validate("Territory Code", TerritoryCode);
    end;

    var
        NapoliCityLbl: Label 'Napoli', MaxLength = 30, Locked = true;
        ReggioEmiliaCityLbl: Label 'Reggio Emilia', MaxLength = 30, Locked = true;
        ArenzanoCityLbl: Label 'Arenzano', MaxLength = 30, Locked = true;
        ExportFabrikamVatRegNoLbl: Label '503912693', MaxLength = 20;
        DomesticFirstUpVatRegNoLbl: Label '274863274', MaxLength = 20;
        EUGraphicDesignVatRegNoLbl: Label '521478963', MaxLength = 20;
        DomesticWorldImporterVatRegNoLbl: Label '197548769', MaxLength = 20;
        DomesticNodPublisherVatRegNoLbl: Label '295267495', MaxLength = 20;
        PostCode80100Lbl: Label '80100', MaxLength = 20;
        PostCode42100Lbl: Label '42100', MaxLength = 20;
        PostCode16011Lbl: Label '16011', MaxLength = 20;
}