codeunit 27013 "Create CA Sales Document"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        SalesHeader: Record "Sales Header";
        ContosoSales: Codeunit "Contoso Sales";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        SalesHeader.Get(Enum::"Sales Document Type"::Invoice, SI102201Lbl);
        ContosoSales.InsertSalesLineWithGLAccount(SalesHeader, CreateGLAccount.ConsultantServices(), 1, 970);
    end;

    var
        SI102201Lbl: Label 'S-INV102201', MaxLength = 20;
}