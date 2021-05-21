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
        MSCeridianUpgrade: Codeunit "MS Ceridian Payroll upgrade";
    begin
        if not UpgradeTag.HasUpgradeTag(MSCeridianUpgrade.GetCeridianSecretsToISUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(MSCeridianUpgrade.GetCeridianSecretsToISUpgradeTag());

        if not UpgradeTag.HasUpgradeTag(MSCeridianUpgrade.GetCeridianSecretsToISValidationTag()) then
            UpgradeTag.SetUpgradeTag(MSCeridianUpgrade.GetCeridianSecretsToISValidationTag());
    end;
}

