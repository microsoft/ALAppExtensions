codeunit 13420 "Create Vendor Template FI"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Templ.", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVendorTemplate(var Rec: Record "Vendor Templ.")
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        CreateVendorTemplate: Codeunit "Create Vendor Template";
    begin
        ContosoCoffeeDemoDataSetup.Get();
        case Rec.Code of
            CreateVendorTemplate.VendorCompany(),
            CreateVendorTemplate.VendorPerson():
                ValidateRecordFields(Rec, ContosoCoffeeDemoDataSetup."Country/Region Code");
        end;
    end;

    local procedure ValidateRecordFields(var VendorTempl: Record "Vendor Templ."; CountryRegionCode: Code[10])
    begin
        VendorTempl.Validate("Country/Region Code", CountryRegionCode);
    end;
}