codeunit 11103 "Create DE Vendor"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    //Todo - Hard Coded Post Code to be replace with Post Code Codeuint.

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVendor(var Rec: Record Vendor)
    var
        CreateCountryRegion: Codeunit "Create Country/Region";
        CreateVendor: Codeunit "Create Vendor";
    begin
        case Rec."No." of
            CreateVendor.ExportFabrikam():
                ValidateVendor(Rec, '', 'GA 31772', '503912693');
            CreateVendor.DomesticFirstUp():
                ValidateVendor(Rec, '', '01310', '895741963');
            CreateVendor.EUGraphicDesign():
                ValidateVendor(Rec, CreateCountryRegion.GB(), 'B31 2AL', '796385274');
            CreateVendor.DomesticWorldImporter():
                ValidateVendor(Rec, '', '60320', '197548769');
            CreateVendor.DomesticNodPublisher():
                ValidateVendor(Rec, '', '01238', '295267495');
        end;
    end;

    local procedure ValidateVendor(var Vendor: Record Vendor; CountryRegionCode: Code[10]; PostCode: Code[20]; VatRegistraionNo: Text[20])
    begin
        Vendor.Validate("VAT Registration No.", VatRegistraionNo);
        Vendor.Validate("Post Code", PostCode);
        if CountryRegionCode <> '' then
            Vendor."Country/Region Code" := CountryRegionCode;
    end;
}
