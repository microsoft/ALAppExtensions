codeunit 11752 "Customer Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterDeleteEvent', '', false, false)]
    local procedure DeleteRegistrationLogCZLOnAfterDelete(var Rec: Record Customer)
    var
        RegistrationLogMgtCZL: Codeunit "Registration Log Mgt. CZL";
    begin
        RegistrationLogMgtCZL.DeleteCustomerLog(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterValidateEvent', 'Customer Posting Group', false, false)]
    local procedure CheckChangeCustomerPostingGroupOnAfterCustomerPostingGroupValidate(var Rec: Record Customer)
    begin
        Rec.CheckOpenCustomerLedgerEntriesCZL();
    end;
}