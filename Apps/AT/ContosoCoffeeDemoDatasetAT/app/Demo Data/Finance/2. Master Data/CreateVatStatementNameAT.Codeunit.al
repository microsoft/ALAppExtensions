codeunit 11189 "Create VAT Statement Name AT"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateVATStatement: Codeunit "Create VAT Statement";
        ContosoVATStatement: Codeunit "Contoso VAT Statement";
    begin
        ContosoVATStatement.InsertVATStatementName(CreateVATStatement.VATTemplateName(), StatementUstvaLbl, VATStatementGermanyDescLbl);
    end;

    var
        StatementUstvaLbl: Label 'USTVA', MaxLength = 10;
        VATStatementGermanyDescLbl: Label 'VAT Statement Germany', MaxLength = 100;
}