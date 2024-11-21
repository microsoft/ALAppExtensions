codeunit 10818 "Create ES Vendor Template"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Templ.", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVendorPostingGroup(var Rec: Record "Vendor Templ.")
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        CreateVendorTemplate: Codeunit "Create Vendor Template";
    begin
        case Rec.Code of
            CreateVendorTemplate.VendorCompany(),
            CreateVendorTemplate.VendorPerson():
                Rec.Validate("Country/Region Code", ContosoCoffeeDemoDataSetup."Country/Region Code");
        end;
    end;
}