codeunit 11546 "Contoso VAT Statement NL"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "VAT Statement Line" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertVatStatementLine(StatementTemplateName: Code[10]; StatementName: Code[10]; StatementLineNo: Integer; StatementRowNo: Code[10]; StatementLineType: Enum "VAT Statement Line Type"; GenPostingType: Enum "General Posting Type"; VatBusPostingGrp: Code[20]; VAtProdPostingGrp: Code[20]; RowTotaling: Text[50]; AmountType: Enum "VAT Statement Line Amount Type"; CalulationWith: Option; StatementPrint: Boolean; PrintWith: Option; StatementDesc: Text[100]; AccountTotaling: Text[30]; BoxNo: Text[30]; ElecTaxDeclCategoryCode: Code[20])
    var
        VatStatementLine: Record "VAT Statement Line";
        Exists: Boolean;
    begin
        if VatStatementLine.Get(StatementTemplateName, StatementName, StatementLineNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        VatStatementLine.Validate("Statement Template Name", StatementTemplateName);
        VatStatementLine.Validate("Statement Name", StatementName);
        VatStatementLine.Validate("Line No.", StatementLineNo);
        VatStatementLine.Validate("Row No.", StatementRowNo);
        VatStatementLine.Validate(Description, StatementDesc);
        VatStatementLine.Validate(Type, StatementLineType);
        VatStatementLine.Validate("Gen. Posting Type", GenPostingType);
        VatStatementLine.Validate("VAT Bus. Posting Group", VatBusPostingGrp);
        VatStatementLine.Validate("VAT Prod. Posting Group", VAtProdPostingGrp);
        VatStatementLine.Validate("Row Totaling", RowTotaling);
        VatStatementLine.Validate("Amount Type", AmountType);
        VatStatementLine.Validate("Calculate with", CalulationWith);
        VatStatementLine.Validate(Print, StatementPrint);
        VatStatementLine.Validate("Print with", PrintWith);
        VatStatementLine.Validate("Account Totaling", AccountTotaling);
        VatStatementLine.Validate("Box No.", BoxNo);
        VatStatementLine.Validate("Elec. Tax Decl. Category Code", ElecTaxDeclCategoryCode);

        if Exists then
            VatStatementLine.Modify(true)
        else
            VatStatementLine.Insert(true);
    end;
}