namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Foundation.Company;
using System.Environment;
using System.Privacy;

codeunit 13611 "Elec. VAT Decl. Install"
{
    Access = Internal;
    Subtype = Install;

    var
        VersionLbl: Label 'DK Ele.VAT', Locked = true;

    trigger OnInstallAppPerCompany()
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        if (AppInfo.DataVersion() <> Version.Create('0.0.0.0')) then
            exit;

        SetupElecVATDecl();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure CompanyInitialize()
    begin
        SetupElecVATDecl();
    end;

    local procedure SetupElecVATDecl()
    begin
        ApplyEvaluationClassificationsForPrivacy();
        InsertVATReportsConfiguration();
        UpdateVATReportSetup();
        InsertEmptySetup();
    end;

    local procedure ApplyEvaluationClassificationsForPrivacy()
    var
        Company: Record Company;
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

        DataClassificationMgt.SetTableFieldsToNormal(Database::"Elec. VAT Decl. Setup");
    end;

    local procedure InsertVATReportsConfiguration()
    var
        VATReportsConfiguration: Record "VAT Reports Configuration";
    begin
        VATReportsConfiguration.Init();
        VATReportsConfiguration.Validate("VAT Report Type", VATReportsConfiguration."VAT Report Type"::"VAT Return");
        VATReportsConfiguration.Validate("VAT Report Version", GetVATReportVersion());
        VATReportsConfiguration.Validate("Suggest Lines Codeunit ID", Codeunit::"VAT Report Suggest Lines");
        VATReportsConfiguration.Validate("Validate Codeunit ID", Codeunit::"Elec. VAT Decl. Validate");
        VATReportsConfiguration.Validate("Content Codeunit ID", Codeunit::"Elec. VAT Decl. Create");
        VATReportsConfiguration.Validate("Submission Codeunit ID", Codeunit::"Elec. VAT Decl. Submit");
        VATReportsConfiguration.Validate("Response Handler Codeunit ID", Codeunit::"Elec. VAT Decl. Check Status");
        if VATReportsConfiguration.Insert(true) then;
    end;

    local procedure UpdateVATReportSetup()
    var
        VATReportSetup: Record "VAT Report Setup";
    begin
        if not VATReportSetup.Get() then
            VATReportSetup.Insert();

        VATReportSetup."Report Version" := GetVATReportVersion();
        VATReportSetup.Validate("Manual Receive Period CU ID", Codeunit::"Elec. VAT Decl. Get Periods");
        if VATReportSetup.Modify() then;
    end;

    local procedure GetVATReportVersion(): Code[10]
    begin
        exit(CopyStr(VersionLbl, 1, 10));
    end;

    local procedure InsertEmptySetup()
    var
        ElecVATDeclSetup: Record "Elec. VAT Decl. Setup";
    begin
        if not ElecVATDeclSetup.Get() then
            ElecVATDeclSetup.Insert(true);

        ElecVATDeclSetup."Use Azure Key Vault" := true;
        if ElecVATDeclSetup.Modify(true) then;
    end;
}