codeunit 148132 "Elec. VAT Submission Demodata"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryElecVATSubmission: Codeunit "Library - Elec. VAT Submission";
        Assert: Codeunit Assert;

    trigger OnRun()
    begin
        // [FEATURE] [Electronic VAT Submission]
    end;

    [Test]
    procedure VATReportConfigurationForElecVATSubmissionExists()
    var
        VATReportsConfiguration: Record "VAT Reports Configuration";
    begin
        // [SCENARIO 409651] VAT reports configuration for the Electronic VAT submission is added on extension installation
        Assert.IsTrue(LibraryElecVATSubmission.GetVATReportConfigurationForSubmission(VATReportsConfiguration), '');
        VATReportsConfiguration.TestField("Suggest Lines Codeunit ID", Codeunit::"VAT Report Suggest Lines");
        VATReportsConfiguration.TestField("Content Codeunit ID", Codeunit::"Elec. VAT Create Content");
        VATReportsConfiguration.TestField("Validate Codeunit ID", Codeunit::"Elec. VAT Validate Return");
        VATReportsConfiguration.TestField("Response Handler Codeunit ID", Codeunit::"Elec. VAT Get Response");
    end;

    [Test]
    procedure VATReportSetupDemodata()
    var
        VATReportSetup: Record "VAT Report Setup";
    begin
        VATReportSetup.Get();
        VATReportSetup.TestField("Report VAT Base");
        // Work item 433237: A "Report VAT Note" option is enabled by default for the Electronic VAT Return extension
        VATReportSetup.TestField("Report VAT Note");
    end;

    [Test]
    procedure InstallExtensionWithNoVATReportSetup()
    var
        VATReportSetup: Record "VAT Report Setup";
        ElecVATSetup: Record "Elec. VAT Setup";
        ElectronicVATInstallation: Codeunit "Electronic VAT Installation";
    begin
        // [SCENARIO 422655] Stan can install extension when no "VAT Report Setup" record exists
        VATReportSetup.DeleteAll();
        ElecVATSetup.DeleteAll();
        ElectronicVATInstallation.RunExtensionSetup();
        ElecVATSetup.Get();
        ElecVATSetup.TestField("Authentication URL");
        ElecVATSetup.TestField("Login URL");
    end;
}