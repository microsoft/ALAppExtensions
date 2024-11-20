codeunit 10821 "Create ES Cust Template"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Customer Templ.", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertCustomerTempl(var Rec: Record "Customer Templ.")
    var
        CreateCustomerTemplate: Codeunit "Create Customer Template";
        CreateCountryRegion: Codeunit "Create Country/Region";
    begin
        case Rec.Code of
            CreateCustomerTemplate.CustomerCompany(),
            CreateCustomerTemplate.CustomerPerson():
                Rec.Validate("Country/Region Code", CreateCountryRegion.ES());
        end;
    end;
}