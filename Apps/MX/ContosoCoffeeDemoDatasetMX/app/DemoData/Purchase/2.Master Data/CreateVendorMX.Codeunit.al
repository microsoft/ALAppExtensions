codeunit 14135 "Create Vendor MX"
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
    begin
        case Rec."No." of
            CreateVendor.ExportFabrikam():
                ValidateRecordFields(Rec, LondonPostmasterLbl, NorthLakeAvenueLbl, MexicoCityLbl, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.DomesticPostingGroup(), PostCode01030Lbl);
            CreateVendor.DomesticFirstUp():
                ValidateRecordFields(Rec, ARDayPropertyManagementLbl, DayDrive100Lbl, MexicoCityLbl, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.DomesticPostingGroup(), PostCode6000Lbl);
            CreateVendor.EUGraphicDesign():
                ValidateRecordFields(Rec, CoolWoodTechnologiesLbl, HitechDrive33Lbl, LeonCityLbl, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.DomesticPostingGroup(), PostCode37500Lbl);
            CreateVendor.DomesticWorldImporter():
                ValidateRecordFields(Rec, LewisHomeFurnitureLbl, RadcroftRoad51Lbl, MonterreyCityLbl, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.DomesticPostingGroup(), PostCode64640Lbl);
            CreateVendor.DomesticNodPublisher():
                ValidateRecordFields(Rec, ServiceElectronicsLtdLbl, FieldGreen172Lbl, MazatlanCityLbl, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.DomesticPostingGroup(), PostCode82100Lbl);
        end;
    end;

    local procedure ValidateRecordFields(var Vendor: Record Vendor; Name: Text[100]; Address: Text[100]; City: Text[30]; VendorPostingGroup: Code[20]; GenBusPostingGroup: Code[20]; VATBusPostingGroup: Code[20]; PostCode: Code[20])
    begin
        Vendor.Validate(Name, Name);
        Vendor.Validate(Address, Address);
        Vendor.Validate("Address 2", '');
        Vendor.Validate(City, City);
        Vendor.Validate("Territory Code", '');
        Vendor.Validate("Vendor Posting Group", VendorPostingGroup);
        Vendor.Validate("Gen. Bus. Posting Group", GenBusPostingGroup);
        Vendor.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
        Vendor.Validate("Post Code", PostCode);
        Vendor.Validate(County, '');
    end;

    var
        LondonPostmasterLbl: Label 'London Postmaster', Maxlength = 100;
        ARDayPropertyManagementLbl: Label 'AR Day Property Management', Maxlength = 100;
        CoolWoodTechnologiesLbl: Label 'CoolWood Technologies', Maxlength = 100;
        LewisHomeFurnitureLbl: Label 'Lewis Home Furniture', Maxlength = 100;
        ServiceElectronicsLtdLbl: Label 'Service Electronics Ltd.', Maxlength = 100;
        NorthLakeAvenueLbl: Label '10 North Lake Avenue', MaxLength = 100;
        DayDrive100Lbl: Label '100 Day Drive', MaxLength = 100;
        HitechDrive33Lbl: Label '33 Hitech Drive', MaxLength = 100;
        RadcroftRoad51Lbl: Label '51 Radcroft Road', MaxLength = 100;
        FieldGreen172Lbl: Label '172 Field Green', MaxLength = 100;
        MexicoCityLbl: Label 'Mexico City', MaxLength = 30;
        LeonCityLbl: Label 'Leon', MaxLength = 30;
        MonterreyCityLbl: Label 'Monterrey', MaxLength = 30;
        MazatlanCityLbl: Label 'Mazatlan', MaxLength = 30;
        PostCode01030Lbl: Label '01030', MaxLength = 20;
        PostCode6000Lbl: Label '06000', MaxLength = 20;
        PostCode37500Lbl: Label '37500', MaxLength = 20;
        PostCode64640Lbl: Label '64640', MaxLength = 20;
        PostCode82100Lbl: Label '82100', MaxLength = 20;
}