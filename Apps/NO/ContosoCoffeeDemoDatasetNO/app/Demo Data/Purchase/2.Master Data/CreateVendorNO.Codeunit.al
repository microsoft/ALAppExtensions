codeunit 10711 "Create Vendor NO"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVendor(var Rec: Record Vendor)
    var
        CreateVendor: Codeunit "Create Vendor";
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreatePostingGroupsNO: Codeunit "Create Posting Groups NO";
        CreateVatPostingGroupsNO: Codeunit "Create Vat Posting Groups NO";
    begin
        case Rec."No." of
            CreateVendor.ExportFabrikam():
                ValidateRecordFields(Rec, AtlantaCityLbl, PostCodeUSGA31772Lbl, ExportFabrikamVatRegNoLbl, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroupsNO.VendDom(), CreateVatPostingGroupsNO.VENDHIGH());
            CreateVendor.DomesticFirstUp():
                ValidateRecordFields(Rec, OsloCityLbl, PostCode1Lbl, DomesticFirstUpVatRegNoLbl, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroupsNO.VendDom(), CreateVatPostingGroupsNO.VENDHIGH());
            CreateVendor.EUGraphicDesign():
                ValidateRecordFields(Rec, EningenCityLbl, PostCodeDE72800Lbl, EUGraphicDesignVatRegNoLbl, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroupsNO.VendDom(), CreateVatPostingGroupsNO.VENDHIGH());
            CreateVendor.DomesticWorldImporter():
                ValidateRecordFields(Rec, BodoCityLbl, PostCode8001Lbl, DomesticWorldImporterVatRegNoLbl, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroupsNO.VendDom(), CreateVatPostingGroupsNO.VENDHIGH());
            CreateVendor.DomesticNodPublisher():
                ValidateRecordFields(Rec, OsloCityLbl, PostCode1001Lbl, DomesticNodPublisherVatRegNoLbl, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroupsNO.VendDom(), CreateVatPostingGroupsNO.VENDHIGH());
        end;
    end;

    local procedure ValidateRecordFields(var Vendor: Record Vendor; City: Text[30]; PostCode: Code[20]; VatRegNo: Text[20]; VendorPostingGroup: Code[20]; GenBusPostingGroup: Code[20]; VATBusPostingGroup: Code[20])
    begin
        Vendor.Validate(City, City);
        Vendor.Validate("Post Code", PostCode);
        Vendor.Validate("VAT Registration No.", VatRegNo);
        Vendor.Validate("Vendor Posting Group", VendorPostingGroup);
        Vendor.Validate("Gen. Bus. Posting Group", GenBusPostingGroup);
        Vendor.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
    end;

    var
        AtlantaCityLbl: Label 'Atlanta', MaxLength = 30, Locked = true;
        OsloCityLbl: Label 'OSLO', MaxLength = 30, Locked = true;
        EningenCityLbl: Label 'Eningen', MaxLength = 30, Locked = true;
        BodoCityLbl: Label 'BODØ', MaxLength = 30, Locked = true;
        PostCode1Lbl: Label '0001', MaxLength = 20;
        PostCode8001Lbl: Label '8001', MaxLength = 20;
        PostCode1001Lbl: Label '1001', MaxLength = 20;
        PostCodeUSGA31772Lbl: Label 'US-GA 31772', MaxLength = 20;
        PostCodeDE72800Lbl: Label 'DE-72800', MaxLength = 20;
        ExportFabrikamVatRegNoLbl: Label '503912693', MaxLength = 20;
        DomesticFirstUpVatRegNoLbl: Label 'NO 274 863 274', MaxLength = 20;
        EUGraphicDesignVatRegNoLbl: Label '521478963', MaxLength = 20;
        DomesticWorldImporterVatRegNoLbl: Label 'NO 197 548 769', MaxLength = 20;
        DomesticNodPublisherVatRegNoLbl: Label 'NO 295 267 495', MaxLength = 20;
}