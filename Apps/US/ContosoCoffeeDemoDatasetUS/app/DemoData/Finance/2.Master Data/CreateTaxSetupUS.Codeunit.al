codeunit 11461 "Create Tax Setup US"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoTaxUS: Codeunit "Contoso Tax US";
        CreateUSGLAccounts: Codeunit "Create US GL Accounts";
        CreateTaxGroupUS: Codeunit "Create Tax Group US";
    begin
        ContosoTaxUS.InsertTaxSetup(true, CreateTaxGroupUS.NonTaxable(), CreateUSGLAccounts.TaxesLiable(), CreateUSGLAccounts.TaxesLiable(), CreateUSGLAccounts.TaxesLiable());
    end;
}