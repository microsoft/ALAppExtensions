codeunit 11753 "Vendor Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnAfterDeleteEvent', '', false, false)]
    local procedure DeleteRegistrationLogCZLOnAfterDelete(var Rec: Record Vendor)
    var
        UnreliablePayerEntryCZL: Record "Unreliable Payer Entry CZL";
        RegistrationLogMgtCZL: Codeunit "Registration Log Mgt. CZL";
    begin
        UnreliablePayerEntryCZL.SetRange("Vendor No.", Rec."No.");
        UnreliablePayerEntryCZL.DeleteAll(true);
        RegistrationLogMgtCZL.DeleteVendorLog(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnAfterValidateEvent', 'Vendor Posting Group', false, false)]
    local procedure CheckChangeVendorPostingGroupOnAfterVendorPostingGroupValidate(var Rec: Record Vendor)
    begin
        Rec.CheckVendorLedgerOpenEntriesCZL();
    end;
}