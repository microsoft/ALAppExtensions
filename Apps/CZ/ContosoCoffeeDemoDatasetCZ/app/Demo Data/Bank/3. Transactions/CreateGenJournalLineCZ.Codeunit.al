codeunit 31285 "Create Gen. Journal Line CZ"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertGenJournalLine(var Rec: Record "Gen. Journal Line")
    var
        CreateBankAccount: Codeunit "Create Bank Account";
        CreateBankAccountCZ: Codeunit "Create Bank Account CZ";
    begin
        if (Rec."Account Type" = Rec."Account Type"::"Bank Account") and
           (Rec."Account No." = CreateBankAccount.Checking())
        then
            Rec.Validate("Account No.", CreateBankAccountCZ.WWBEUR());
        if (Rec."Bal. Account Type" = Rec."Bal. Account Type"::"Bank Account") and
           (Rec."Bal. Account No." = CreateBankAccount.Checking())
        then
            Rec.Validate("Bal. Account No.", CreateBankAccountCZ.WWBEUR());
        if (Rec."Account Type" = Rec."Account Type"::"Bank Account") and
           (Rec."Account No." = CreateBankAccount.Savings())
        then
            Rec.Validate("Account No.", CreateBankAccountCZ.NBL());
        if (Rec."Bal. Account Type" = Rec."Bal. Account Type"::"Bank Account") and
           (Rec."Bal. Account No." = CreateBankAccount.Savings())
        then
            Rec.Validate("Bal. Account No.", CreateBankAccountCZ.NBL());
    end;
}