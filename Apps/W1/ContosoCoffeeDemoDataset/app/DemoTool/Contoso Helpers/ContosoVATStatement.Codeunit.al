codeunit 5628 "Contoso VAT Statement"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "VAT Statement Name" = rim,
        tabledata "VAT Statement Template" = rim,
        tabledata "VAT Statement Line" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
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

    procedure InsertVatSetupPostingGrp(VATProdPostingGroup: Code[20]; DefaultSetup: Boolean; VatPercent: Decimal; SalesVatAccount: Code[20]; PurchaseVatAccount: Code[20]; SelectedSetup: Boolean; ApplicationType: Option; VATProdPostingGrpDesc: Text[100])
    var
        VatSetupPostingGroup: Record "VAT Setup Posting Groups";
        Exists: Boolean;
    begin
        if VatSetupPostingGroup.Get(VATProdPostingGroup, DefaultSetup) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        VatSetupPostingGroup.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
        VatSetupPostingGroup.Validate(Default, DefaultSetup);
        VatSetupPostingGroup.Validate("VAT %", VatPercent);
        VatSetupPostingGroup.Validate("Sales VAT Account", SalesVatAccount);
        VatSetupPostingGroup.Validate("Purchase VAT Account", PurchaseVatAccount);
        VatSetupPostingGroup.Validate(Selected, SelectedSetup);
        VatSetupPostingGroup.Validate("Application Type", ApplicationType);
        VatSetupPostingGroup.Validate("VAT Prod. Posting Grp Desc.", VATProdPostingGrpDesc);

        if Exists then
            VatSetupPostingGroup.Modify(true)
        else
            VatSetupPostingGroup.Insert(true);
    end;

    procedure InsertVatStatementLine(StatementTemplateName: Code[10]; StatementName: Code[10]; StatementLineNo: Integer; StatementRowNo: Code[10]; StatementLineType: Enum "VAT Statement Line Type"; GenPostingType: Enum "General Posting Type"; VatBusPostingGrp: Code[20]; VAtProdPostingGrp: Code[20]; RowTotaling: Text[50]; AmountType: Enum "VAT Statement Line Amount Type"; CalulationWith: Option; StatementPrint: Boolean; PrintWith: Option; StatementDesc: Text[100])
    begin
        InsertVatStatementLine(StatementTemplateName, StatementName, StatementLineNo, StatementRowNo, StatementLineType, GenPostingType, VatBusPostingGrp, VAtProdPostingGrp, RowTotaling, AmountType, CalulationWith, StatementPrint, PrintWith, StatementDesc, '');
    end;

    procedure InsertVatStatementLine(StatementTemplateName: Code[10]; StatementName: Code[10]; StatementLineNo: Integer; StatementRowNo: Code[10]; StatementLineType: Enum "VAT Statement Line Type"; GenPostingType: Enum "General Posting Type"; VatBusPostingGrp: Code[20]; VAtProdPostingGrp: Code[20]; RowTotaling: Text[50]; AmountType: Enum "VAT Statement Line Amount Type"; CalulationWith: Option; StatementPrint: Boolean; PrintWith: Option; StatementDesc: Text[100]; AccountTotaling: Text[30])
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
        VatStatementLine.Validate("Account Totaling", AccountTotaling);
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