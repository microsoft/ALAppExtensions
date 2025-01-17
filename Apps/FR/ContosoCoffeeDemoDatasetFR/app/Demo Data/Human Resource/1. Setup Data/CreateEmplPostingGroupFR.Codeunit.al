codeunit 10899 "Create Empl. Posting Group FR"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateEmployeePostingGroup: Codeunit "Create Employee Posting Group";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        UpdateEmployeePostingGroup(CreateEmployeePostingGroup.EmployeeExpenses(), CreateGLAccount.EmployeesPayable(), CreateGLAccount.PmtTolReceivedDecreases(), CreateGLAccount.PmtTolReceivedDecreases(), CreateGLAccount.PmtTolReceivedDecreases(), CreateGLAccount.PmtTolReceivedDecreases());
    end;

    local procedure UpdateEmployeePostingGroup(EmployeePostingGroupCode: Code[20]; PayableAccount: Code[20]; DebitCurrApplnRndgAcc: Code[20]; CreditCurrApplnRndgAcc: Code[20]; DebitRoundingAccount: Code[20]; CreditRoundingAccount: Code[20])
    var
        EmployeePostingGroup: Record "Employee Posting Group";
    begin
        EmployeePostingGroup.Get(EmployeePostingGroupCode);
        EmployeePostingGroup.Validate("Payables Account", PayableAccount);
        EmployeePostingGroup.Validate("Debit Curr. Appln. Rndg. Acc.", DebitCurrApplnRndgAcc);
        EmployeePostingGroup.Validate("Credit Curr. Appln. Rndg. Acc.", CreditCurrApplnRndgAcc);
        EmployeePostingGroup.Validate("Debit Rounding Account", DebitRoundingAccount);
        EmployeePostingGroup.Validate("Credit Rounding Account", CreditRoundingAccount);
        EmployeePostingGroup.Modify(true);
    end;
}