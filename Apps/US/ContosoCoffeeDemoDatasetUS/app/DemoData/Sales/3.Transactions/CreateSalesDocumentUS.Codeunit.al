codeunit 11469 "Create Sales Document US"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        SalesHeader: Record "Sales Header";
        ContosoSales: Codeunit "Contoso Sales";
        CreateUSGLAccount: Codeunit "Create US GL Accounts";
    begin
        SalesHeader.Get(Enum::"Sales Document Type"::Invoice, SINV102201Lbl);
        ContosoSales.InsertSalesLineWithGLAccount(SalesHeader, CreateUSGLAccount.SalesofServiceWork(), 1, 970);
    end;

    var
        SINV102201Lbl: Label 'S-INV102201', MaxLength = 20;
}