codeunit 13735 "Create Customer Template DK"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Customer Templ.", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertCustomerTemplate(var Rec: Record "Customer Templ.")
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        CreateCustomerTemplate: Codeunit "Create Customer Template";
    begin
        ContosoCoffeeDemoDataSetup.Get();
        case Rec.Code of
            CreateCustomerTemplate.CustomerCompany(),
            CreateCustomerTemplate.CustomerPerson():
                ValidateRecordFields(Rec, ContosoCoffeeDemoDataSetup."Country/Region Code");
        end;
    end;

    local procedure ValidateRecordFields(var CustomerTempl: Record "Customer Templ."; CountryRegionCode: Code[10])
    begin
        CustomerTempl.Validate("Country/Region Code", CountryRegionCode);
    end;
}