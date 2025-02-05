codeunit 27066 "Create CA Vendor Posting Group"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CreateCAGLAccounts: Codeunit "Create CA GL Accounts";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoPostingGroup.InsertVendorPostingGroup(Employees(), CreateCAGLAccounts.AccountsPayableEmployees(), CreateGLAccount.OtherCostsofOperations(), CreateGLAccount.PmtDiscReceivedDecreases(), CreateGLAccount.InvoiceRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.PaymentDiscountsReceived(), CreateGLAccount.PmtTolReceivedDecreases(), CreateGLAccount.PaymentToleranceReceived(), EmployeesLbl, false);
    end;

    procedure Employees(): Code[20]
    begin
        exit(EmployeesTok);
    end;

    var
        EmployeesLbl: Label 'Employees', MaxLength = 100;
        EmployeesTok: Label 'EMPLOYEES', MaxLength = 20;
}