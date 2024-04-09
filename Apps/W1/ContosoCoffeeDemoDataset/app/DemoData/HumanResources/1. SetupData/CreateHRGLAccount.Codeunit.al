codeunit 5161 "Create HR GL Account"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        GLAccountIndent: Codeunit "G/L Account-Indent";
    begin
        AddGLAccountsForLocalization();
        ContosoGLAccount.InsertGLAccount(EmployeesPayable(), EmployeesPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Enum::"G/L Account Type"::Posting);
        GLAccountIndent.Indent();
    end;

    local procedure AddGLAccountsForLocalization()
    begin
        ContosoGLAccount.AddAccountForLocalization(EmployeesPayableName(), '5850');
        OnAfterAddGLAccountsForLocalization();
    end;

    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        EmployeesPayableLbl: Label 'Employees Payable', MaxLength = 100;

    procedure EmployeesPayable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(EmployeesPayableName()));
    end;

    procedure EmployeesPayableName(): Text[100]
    begin
        exit(EmployeesPayableLbl);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAddGLAccountsForLocalization()
    begin
    end;
}