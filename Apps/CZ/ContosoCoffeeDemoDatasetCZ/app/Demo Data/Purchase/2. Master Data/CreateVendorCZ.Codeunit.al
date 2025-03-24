codeunit 31298 "Create Vendor CZ"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVendor(var Rec: Record Vendor)
    var
        CreateCurrency: Codeunit "Create Currency";
        CreateVendor: Codeunit "Create Vendor";
        CreateLanguage: Codeunit "Create Language";
    begin
        case Rec."No." of
            CreateVendor.ExportFabrikam():
                ValidateVendor(Rec, CreateLanguage.ENU(), CreateCurrency.USD(), 'US-GA 31772', '');
            CreateVendor.DomesticFirstUp():
                ValidateVendor(Rec, CreateLanguage.CSY(), '', '669 02', 'CZ197548769');
            CreateVendor.EUGraphicDesign():
                ValidateVendor(Rec, CreateLanguage.DEU(), CreateCurrency.EUR(), 'DE-72800', '');
            CreateVendor.DomesticWorldImporter():
                ValidateVendor(Rec, CreateLanguage.CSY(), '', '687 71', 'CZ222459523');
            CreateVendor.DomesticNodPublisher():
                ValidateVendor(Rec, CreateLanguage.CSY(), '', '697 01', 'CZ295267495');
        end;
    end;

    local procedure ValidateVendor(var Vendor: Record Vendor; LanguageCode: Code[10]; CurrencyCode: Code[20]; PostCode: Code[20]; VatRegistrationNo: Text[20])
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        Vendor."Format Region" := '';
        Vendor.Validate("Language Code", LanguageCode);
        Vendor.Validate("Currency Code", CurrencyCode);
        Vendor.Validate("Post Code", PostCode);
        Vendor.Validate("VAT Registration No.", VatRegistrationNo);
        Vendor."Disable Unreliab. Check CZL" := Vendor."Country/Region Code" = ContosoCoffeeDemoDataSetup."Country/Region Code";
    end;
}
