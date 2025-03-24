codeunit 31299 "Create Item Charge CZ"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Item Charge", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertFAPostingGroup(var Rec: Record "Item Charge")
    var
        CreateVatPostingGroupsCZ: Codeunit "Create Vat Posting Groups CZ";
    begin
        Rec.Validate("VAT Prod. Posting Group", CreateVatPostingGroupsCZ.VAT21S());
    end;
}