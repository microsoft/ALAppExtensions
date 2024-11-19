codeunit 10833 "Create ES VAT Statement Name"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateVATStatement: Codeunit "Create VAT Statement";
        ContosoVatStatment: Codeunit "Contoso VAT Statement";
    begin
        ContosoVatStatment.InsertVATStatementName(CreateVATStatement.VATTemplateName(), Statement320Lbl, TelematicStatement320DescLbl);
        ContosoVatStatment.InsertVATStatementName(CreateVATStatement.VATTemplateName(), Statement392Lbl, TelematicStatement392DescLbl);
        UpdateTemplateType(CreateVATStatement.VATTemplateName(), StatementNameLbl, 0);
        UpdateTemplateType(CreateVATStatement.VATTemplateName(), Statement320Lbl, 1);
        UpdateTemplateType(CreateVATStatement.VATTemplateName(), Statement392Lbl, 1);
    end;

    local procedure UpdateTemplateType(StatementTemplateName: Code[10]; StatementName: Code[10]; TemplateType: option)
    var
        VatStatementName: Record "VAT Statement Name";
    begin
        if not VatStatementName.Get(StatementTemplateName, StatementName) then
            exit;

        VatStatementName.Validate("Template Type", TemplateType);
        VatStatementName.Modify(true);
    end;

    var
        StatementNameLbl: Label 'DEFAULT', MaxLength = 10;
        Statement320Lbl: Label 'STMT. 320', MaxLength = 10;
        Statement392Lbl: Label 'STMT. 392', MaxLength = 10;
        TelematicStatement320DescLbl: Label '320 Telematic Statement', MaxLength = 100;
        TelematicStatement392DescLbl: Label '392 XML Telematic Statement', MaxLength = 100;
}