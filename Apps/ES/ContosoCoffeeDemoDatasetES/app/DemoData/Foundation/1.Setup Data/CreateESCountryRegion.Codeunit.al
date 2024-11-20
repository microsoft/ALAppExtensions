codeunit 10784 "Create ES Country Region"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Country/Region", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecords(var Rec: Record "Country/Region")
    begin
        Rec.Validate("VAT Registration No. digits", 15);
    end;
}