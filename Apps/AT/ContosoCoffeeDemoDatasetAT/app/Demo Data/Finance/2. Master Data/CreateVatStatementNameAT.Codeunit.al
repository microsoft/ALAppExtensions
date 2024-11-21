codeunit 11189 "Create VAT Statement NameAT"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateVATStatement: Codeunit "Create VAT Statement";
        ContosoVatStatmentES: Codeunit "Contoso Vat Statment ES";
    begin
        ContosoVatStatmentES.InsertVATStatementName(CreateVATStatement.VATTemplateName(), StatementUstvaLbl, VATStatementGermanyDescLbl);
    end;

    var
        StatementUstvaLbl: Label 'USTVA', MaxLength = 10;
        VATStatementGermanyDescLbl: Label 'VAT Statement Germany', MaxLength = 100;
}