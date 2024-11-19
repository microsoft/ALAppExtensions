codeunit 12237 "Contoso VAT Statement IT"
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

    procedure InsertVatStatementLineWithAnnualVATCommField(StatementTemplateName: Code[10]; StatementName: Code[10]; StatementLineNo: Integer; StatementRowNo: Code[10]; StatementLineType: Enum "VAT Statement Line Type"; GenPostingType: Option; VatBusPostingGrp: Code[20]; VAtProdPostingGrp: Code[20]; RowTotaling: Text[50]; AmountType: Enum "VAT Statement Line Amount Type"; CalulationWith: Option; StatementPrint: Boolean; PrintWith: Option; StatementDesc: Text[100]; AnnualVATCommField: Option)
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
        VatStatementLine.Validate("Annual VAT Comm. Field", AnnualVATCommField);

        if Exists then
            VatStatementLine.Modify(true)
        else
            VatStatementLine.Insert(true);
    end;

    procedure InsertVatStatementLine(StatementTemplateName: Code[10]; StatementName: Code[10]; StatementLineNo: Integer; StatementRowNo: Code[10]; StatementLineType: Enum "VAT Statement Line Type"; GenPostingType: Option; VatBusPostingGrp: Code[20]; VAtProdPostingGrp: Code[20]; RowTotaling: Text[50]; AmountType: Enum "VAT Statement Line Amount Type"; CalulationWith: Option; StatementPrint: Boolean; PrintWith: Option; StatementDesc: Text[100])
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

        if Exists then
            VatStatementLine.Modify(true)
        else
            VatStatementLine.Insert(true);
    end;

    procedure InsertVATAssistedSetupBusGrp(VatAssistedCode: Code[20]; VatAssistedDesc: Text[100]; VatAssistedDefault: Boolean; VatAssistedSelected: Boolean)
    var
        VatAssistedSetupBusGrp: Record "VAT Assisted Setup Bus. Grp.";
        Exists: Boolean;
    begin
        if VatAssistedSetupBusGrp.Get(VatAssistedCode, VatAssistedDefault) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        VatAssistedSetupBusGrp.Validate(Code, VatAssistedCode);
        VatAssistedSetupBusGrp.Validate(Default, VatAssistedDefault);
        VatAssistedSetupBusGrp.Validate(Description, VatAssistedDesc);
        VatAssistedSetupBusGrp.Validate(Selected, VatAssistedSelected);

        if Exists then
            VatAssistedSetupBusGrp.Modify(true)
        else
            VatAssistedSetupBusGrp.Insert(true);
    end;

    procedure InsertVATReportConfiguration(ReportConfig: Enum "VAT Report Configuration"; Version: Code[10]; SuggestCodeunit: Integer; ValidateCodeunit: Integer)
    var
        VATReportConfiguration: Record "VAT Reports Configuration";
        Exists: Boolean;
    begin
        if VATReportConfiguration.Get(ReportConfig, Version) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        VATReportConfiguration.Validate("VAT Report Type", ReportConfig);
        VATReportConfiguration.Validate("VAT Report Version", Version);
        VATReportConfiguration.Validate("Suggest Lines Codeunit ID", SuggestCodeunit);
        VATReportConfiguration.Validate("Validate Codeunit ID", ValidateCodeunit);

        if Exists then
            VATReportConfiguration.Modify(true)
        else
            VATReportConfiguration.Insert(true);
    end;
}