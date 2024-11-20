codeunit 17162 "Create AU VAT Statement"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        ContosoVatStatement.InsertVATStatementTemplate(BASTemplateName(), BASStatementDescLbl, Page::"VAT Statement", Report::"VAT Statement");

        ContosoVatStatement.InsertVATStatementName(BASTemplateName(), StatementNameLbl, StatementNameDescLbl);
    end;

    procedure BASTemplateName(): Code[10]
    begin
        exit(BASTemplateNameTok);
    end;

    var
        ContosoVatStatement: Codeunit "Contoso VAT Statement";
        BASTemplateNameTok: Label 'BAS', Locked = true;
        StatementNameLbl: Label 'DEFAULT', MaxLength = 10;
        StatementNameDescLbl: Label 'Default Statement', MaxLength = 100;
        BASStatementDescLbl: Label 'Business Activity Statement', MaxLength = 80;
}