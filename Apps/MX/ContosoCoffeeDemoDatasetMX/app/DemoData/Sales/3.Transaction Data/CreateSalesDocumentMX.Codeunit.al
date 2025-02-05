codeunit 14138 "Create Sales Document MX"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        SalesHeader: Record "Sales Header";
        ContosoSales: Codeunit "Contoso Sales";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        SalesHeader.Get(Enum::"Sales Document Type"::Invoice, SINV102201Lbl);
        ContosoSales.InsertSalesLineWithGLAccount(SalesHeader, CreateGLAccount.ConsultantServices(), 1, 970);
    end;

    var
        SINV102201Lbl: Label '102201', MaxLength = 20;
}