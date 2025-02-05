codeunit 11383 "Create Vendor Template BE"
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
                Rec.Validate("Suggest Payments", true);
        end;
    end;
}