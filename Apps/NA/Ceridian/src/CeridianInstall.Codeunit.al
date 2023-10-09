namespace Microsoft.Payroll.Ceridian;

using Microsoft.Foundation.Company;
using System.Environment;
using System.Privacy;
using System.Upgrade;

codeunit 1667 "Ceridian Install"
{
    Subtype = install;

    trigger OnInstallAppPerCompany()
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        if AppInfo.DataVersion().Major() = 0 then
            SetAllUpgradeTags();

        CompanyInitialize();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure CompanyInitialize()
    begin
        ApplyEvaluationClassificationsForPrivacy();
    end;

    local procedure ApplyEvaluationClassificationsForPrivacy()
    var
        MSCeridianPayrollSetup: Record "MS Ceridian Payroll Setup";
        Company: Record Company;
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

        DataClassificationMgt.SetTableFieldsToNormal(Database::"MS Ceridian Payroll Setup");
        DataClassificationMgt.SetFieldToPersonal(Database::"MS Ceridian Payroll Setup", MSCeridianPayrollSetup.FieldNo("User Name"));
        DataClassificationMgt.SetFieldToPersonal(Database::"MS Ceridian Payroll Setup", MSCeridianPayrollSetup.FieldNo("Service URL"));
    end;

    local procedure SetAllUpgradeTags()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        MSCeridianPayrollupgrade: Codeunit "MS Ceridian Payroll upgrade";
    begin
        if not UpgradeTag.HasUpgradeTag(MSCeridianPayrollupgrade.GetCeridianSecretsToISUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(MSCeridianPayrollupgrade.GetCeridianSecretsToISUpgradeTag());

        if not UpgradeTag.HasUpgradeTag(MSCeridianPayrollupgrade.GetCeridianSecretsToISValidationTag()) then
            UpgradeTag.SetUpgradeTag(MSCeridianPayrollupgrade.GetCeridianSecretsToISValidationTag());
    end;
}

