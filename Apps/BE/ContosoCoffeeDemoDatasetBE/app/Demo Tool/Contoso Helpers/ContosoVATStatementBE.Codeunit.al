codeunit 11421 "Contoso VAT Statement BE"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "VAT Statement Line" = rim,
        tabledata "VAT Statement Name" = rim,
        tabledata "VAT Statement Template" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertVATStatementLine(StatementTemplateName: Code[10]; StatementName: Code[10]; StatementLineNo: Integer; RowNo: Code[10]; Description: Text[100]; Type: Enum "VAT Statement Line Type"; AccountTotaling: Text[30]; DocumentType: Option; GenPostingType: Enum "General Posting Type"; VATBusPostingGroup: Code[20]; VATProdPostingGroup: Code[20]; RowTotaling: Text[50]; AmountType: Enum "VAT Statement Line Amount Type"; CalculateWith: Option; Print: Boolean; PrintWith: Option; NewPage: Boolean)
    var
        VATStatementLine: Record "VAT Statement Line";
        Exists: Boolean;
    begin
        if VatStatementLine.Get(StatementTemplateName, StatementName, StatementLineNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        VATStatementLine.Validate("Statement Template Name", StatementTemplateName);
        VATStatementLine.Validate("Statement Name", StatementName);
        VATStatementLine.Validate("Line No.", StatementLineNo);
        VATStatementLine.Validate("Row No.", RowNo);
        VATStatementLine.Validate(Description, Description);
        VATStatementLine.Validate(Type, Type);
        VATStatementLine.Validate("Account Totaling", AccountTotaling);
        VATStatementLine.Validate("Document Type", DocumentType);
        VATStatementLine.Validate("Gen. Posting Type", GenPostingType);
        VATStatementLine.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
        VATStatementLine.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
        VATStatementLine.Validate("Row Totaling", RowTotaling);
        VATStatementLine.Validate("Amount Type", AmountType);
        VATStatementLine.Validate("Calculate with", CalculateWith);
        VATStatementLine.Validate(Print, Print);
        VATStatementLine.Validate("Print with", PrintWith);
        VATStatementLine.Validate("New Page", NewPage);
        VATStatementLine.Validate("Print on Official VAT Form", Print);

        if Exists then
            VatStatementLine.Modify(true)
        else
            VatStatementLine.Insert(true);
    end;

    procedure InsertVATStatementTemplate(TemplateName: Code[10]; VatStatementDescription: Text[80]; VatStatementPageID: Integer; VatStatementReportID: Integer)
    var
        VATStatementTemplate: Record "VAT Statement Template";
        Exists: Boolean;
    begin
        if VATStatementTemplate.Get(TemplateName) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        VATStatementTemplate.Validate(Name, TemplateName);
        VATStatementTemplate.Validate(Description, VatStatementDescription);
        VATStatementTemplate.Validate("Page ID", VatStatementPageID);
        VATStatementTemplate.Validate("VAT Statement Report ID", VatStatementReportID);

        if Exists then
            VATStatementTemplate.Modify(true)
        else
            VATStatementTemplate.Insert(true);
    end;

    procedure InsertVATStatementName(StatementTemplateName: Code[10]; StatementName: Code[10]; StatementDesc: Text[100])
    var
        VatStatementName: Record "VAT Statement Name";
        Exists: Boolean;
    begin
        if VatStatementName.Get(StatementTemplateName, StatementName) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        VatStatementName.Validate("Statement Template Name", StatementTemplateName);
        VatStatementName.Validate(Name, StatementName);
        VatStatementName.Validate(Description, StatementDesc);

        if Exists then
            VatStatementName.Modify(true)
        else
            VatStatementName.Insert(true);
    end;
}