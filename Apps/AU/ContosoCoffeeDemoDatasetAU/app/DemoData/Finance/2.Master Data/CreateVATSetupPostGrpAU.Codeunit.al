codeunit 17168 "Create VAT Setup Post.Grp. AU"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::"Sales Tax" then
            exit;

        UpdateVatReportSetup();
        CreateVatSetupPostingGrp();
        UpdateVatAssistedSetupBusGrp();
        CreateVATReportsConfiguration();
    end;

    local procedure CreateVatSetupPostingGrp()
    var
        ContosoVATStatement: Codeunit "Contoso VAT Statement";
        CreateAUVATPostingGroups: Codeunit "Create AU VAT Posting Groups";
        CreateAUGLAccounts: Codeunit "Create AU GL Accounts";
    begin
        ContosoVATStatement.SetOverwriteData(true);
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateAUVATPostingGroups.Gst10(), true, 10, CreateAUGLAccounts.GstPayable(), CreateAUGLAccounts.GstReceivable(), true, 1, GST10DescriptionLbl);
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateAUVATPostingGroups.NoVat(), true, 0, '', '', true, 1, NoVATDescriptionLbl);
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateAUVATPostingGroups.NonGst(), true, 0, CreateAUGLAccounts.GstPayable(), CreateAUGLAccounts.GstReceivable(), true, 1, NonGSTDescriptionLbl);
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateAUVATPostingGroups.Vat10(), true, 0, '', '', true, 1, Vat10DescriptionLbl);
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateAUVATPostingGroups.Vat15(), true, 0, '', '', true, 1, Vat15DescriptionLbl);
        ContosoVATStatement.SetOverwriteData(false);
    end;

    local procedure UpdateVatAssistedSetupBusGrp()
    var
        CreateVatPostingGroup: Codeunit "Create VAT Posting Groups";
        ContosoVATStatement: Codeunit "Contoso VAT Statement";
        CreatePostingGroups: Codeunit "Create Posting Groups";
    begin
        ContosoVATStatement.SetOverwriteData(true);
        ContosoVATStatement.InsertVATAssistedSetupBusGrp(CreateVatPostingGroup.Export(), ExportPostingGroupDescriptionLbl, true, true);
        ContosoVATStatement.InsertVATAssistedSetupBusGrp(CreatePostingGroups.MiscPostingGroup(), MiscPostingGroupDescriptionLbl, true, true);
        ContosoVATStatement.SetOverwriteData(false);
    end;

    local procedure UpdateVatReportSetup()
    var
        VATReportSetup: Record "VAT Report Setup";
        CreateAUNoSeries: Codeunit "Create AU No. Series";
    begin
        VATReportSetup.Get();
        VATReportSetup.Validate("BAS Report No. Series", CreateAUNoSeries.BASReports());
        VATReportSetup.Modify(true);
    end;

    local procedure CreateVATReportsConfiguration()
    var
        ContosoVATStatement: Codeunit "Contoso VAT Statement";
        CreateVATReportSetup: Codeunit "Create VAT Report Setup";
    begin
        ContosoVATStatement.InsertVATReportConfiguration(Enum::"VAT Report Configuration"::"BAS Report", CreateVATReportSetup.CurrentVersion(), Codeunit::"VAT Report Suggest Lines", Codeunit::"VAT Report Validate");
        UpdateVatReportConfiguration();
    end;

    local procedure UpdateVatReportConfiguration()
    var
        VATReportConfiguration: Record "VAT Reports Configuration";
        CreateVATReportSetup: Codeunit "Create VAT Report Setup";
        CreateAUVATStatement: Codeunit "Create AU VAT Statement";
    begin
        VATReportConfiguration.Get(VATReportConfiguration."VAT Report Type"::"BAS Report", CreateVATReportSetup.CurrentVersion());
        VATReportConfiguration.Validate("Submission Codeunit ID", Codeunit::"BAS Export");
        VATReportConfiguration.Validate("VAT Statement Template", CreateAUVATStatement.BASTemplateName());
        VATReportConfiguration.Validate("VAT Statement Name", StatementNameLbl);
        VATReportConfiguration.Modify(true);
    end;

    var
        GST10DescriptionLbl: Label 'Setup for MISC / GST10', MaxLength = 100;
        NoVATDescriptionLbl: Label 'Miscellaneous without VAT', MaxLength = 100;
        NonGSTDescriptionLbl: Label 'Setup for MISC / NON GST', MaxLength = 100;
        Vat10DescriptionLbl: Label 'Miscellaneous 10 VAT', MaxLength = 100;
        Vat15DescriptionLbl: Label 'Miscellaneous 15 VAT', MaxLength = 100;
        MiscPostingGroupDescriptionLbl: Label 'Customers and vendors in MISC', MaxLength = 100;
        ExportPostingGroupDescriptionLbl: Label 'Other customers and vendors (not MISC)', MaxLength = 100;
        StatementNameLbl: Label 'DEFAULT', MaxLength = 10;
}