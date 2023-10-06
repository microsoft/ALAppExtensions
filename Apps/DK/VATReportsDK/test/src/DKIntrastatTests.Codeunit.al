#if not CLEAN22
codeunit 148042 "DK Intrastat Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;
    ObsoleteReason = 'Intrastat was moved to a separate extension.';
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';

    trigger OnRun();
    begin
        // [FEATURE] [Intrastat]
    end;

    var
        Assert: Codeunit Assert;

    [Test]
    procedure VATReportsConfigurationCreatedWhenOpenIntrastatJournal()
    var
        VATReportsConfiguration: Record "VAT Reports Configuration";
        IntrastatJournalPage: TestPage "Intrastat Journal";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 431026] Intrastat VAT Reports configuration is created on Intrastat Journal page opening

        VATReportsConfiguration.SetRange("VAT Report Type", VATReportsConfiguration."VAT Report Type"::"Intrastat Report");
        Assert.RecordCount(VATReportsConfiguration, 0);

        IntrastatJournalPage.OpenView();
        IntrastatJournalPage.Close();

        VATReportsConfiguration.FindFirst();
        VATReportsConfiguration.TestField("Suggest Lines Codeunit ID", Codeunit::"Intrastat Suggest Lines");
        VATReportsConfiguration.TestField("Validate Codeunit ID", CODEUNIT::"Intrastat Validate Lines");
        VATReportsConfiguration.TestField("Content Codeunit ID", Codeunit::"Intrastat Export Lines");
    end;

    [Test]
    [HandlerFunctions('IntrastatMakeDiskTaxAuthRPH')]
    procedure IntrastatMakeDiskTaxAuthReportOpensWhenRunIntrastatExportLinesCodeunit()
    begin
        // [FEATURE] [UT]
        // [SCENARIO 431026] "Intrastat - Make Disk Tax Auth" report is opened when run "Intrastat Export Lines" codeunit

        Codeunit.Run(Codeunit::"Intrastat Export Lines");
    end;

    [RequestPageHandler]
    procedure IntrastatMakeDiskTaxAuthRPH(var IntrastatMakeDiskTaxAuth: TestRequestPage "Intrastat - Make Disk Tax Auth")
    begin
        IntrastatMakeDiskTaxAuth.Cancel().Invoke();
    end;
}
#endif