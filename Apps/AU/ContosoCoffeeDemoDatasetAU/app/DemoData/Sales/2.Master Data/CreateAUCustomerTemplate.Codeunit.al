codeunit 17133 "Create AU Customer Template"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Customer Templ.", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecords(var Rec: Record "Customer Templ."; RunTrigger: Boolean)
    var
        CreateCustomerTemplate: Codeunit "Create Customer Template";
        CreateCountryRegion: Codeunit "Create Country/Region";
    begin
        case Rec.Code of
            CreateCustomerTemplate.CustomerCompany():
                ValidateRecordFields(Rec, CreateCountryRegion.AU());
            CreateCustomerTemplate.CustomerPerson():
                ValidateRecordFields(Rec, CreateCountryRegion.AU());
        end;
    end;

    procedure ValidateRecordFields(var CustomerTempl: Record "Customer Templ."; CountryRegionCode: Code[10])
    begin
        CustomerTempl.Validate("Country/Region Code", CountryRegionCode);
    end;
}