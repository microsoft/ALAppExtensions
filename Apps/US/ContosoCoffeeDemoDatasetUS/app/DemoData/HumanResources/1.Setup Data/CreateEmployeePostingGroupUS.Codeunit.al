codeunit 10522 "Create Employee PostingGroupUS"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Employee Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Employee Posting Group")
    var
        CreateUSGLAccounts: Codeunit "Create US GL Accounts";
    begin
        ValidateRecordFields(Rec, CreateUSGLAccounts.AccountsPayableDomestic(), CreateUSGLAccounts.InvoiceRounding(), CreateUSGLAccounts.InvoiceRounding(), CreateUSGLAccounts.InvoiceRounding(), CreateUSGLAccounts.InvoiceRounding());
    end;

    local procedure ValidateRecordFields(var EmployeePostingGroup: Record "Employee Posting Group"; PayableAccount: Code[20]; DebitCurrApplnRndgAcc: Code[20]; CreditCurrApplnRndgAcc: Code[20]; DebitRoundingAccount: Code[20]; CreditRoundingAccount: Code[20])
    begin
        EmployeePostingGroup.Validate("Payables Account", PayableAccount);
        EmployeePostingGroup.Validate("Debit Curr. Appln. Rndg. Acc.", DebitCurrApplnRndgAcc);
        EmployeePostingGroup.Validate("Credit Curr. Appln. Rndg. Acc.", CreditCurrApplnRndgAcc);
        EmployeePostingGroup.Validate("Debit Rounding Account", DebitRoundingAccount);
        EmployeePostingGroup.Validate("Credit Rounding Account", CreditRoundingAccount);
    end;
}