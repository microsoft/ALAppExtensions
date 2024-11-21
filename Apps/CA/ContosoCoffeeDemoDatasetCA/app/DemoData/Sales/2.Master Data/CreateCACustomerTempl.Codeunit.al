codeunit 27071 "Create CA Customer Templ."
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Customer Templ.", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Customer Templ.")
    var
        CreateCustomerTemplate: Codeunit "Create Customer Template";
    begin
        if Rec.Code = CreateCustomerTemplate.CustomerPerson() then
            Rec.Validate("Prices Including VAT", false)
    end;
}