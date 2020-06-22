codeunit 1955 "Late Payment Install"
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
        Company: Record Company;
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

        DataClassificationMgt.SetTableFieldsToNormal(Database::"LP Machine Learning Setup");

        DataClassificationMgt.SetTableFieldsToNormal(Database::"LP ML Input Data");
    end;

    local procedure SetAllUpgradeTags()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        LatePaymentUpgrade: Codeunit "Late Payment Upgrade";
    begin
        if not UpgradeTag.HasUpgradeTag(LatePaymentUpgrade.GetLatePaymentPredictionSecretsToISUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(LatePaymentUpgrade.GetLatePaymentPredictionSecretsToISUpgradeTag());

        if not UpgradeTag.HasUpgradeTag(LatePaymentUpgrade.GetLatePaymentPredictionSecretsToISValidationTag()) then
            UpgradeTag.SetUpgradeTag(LatePaymentUpgrade.GetLatePaymentPredictionSecretsToISValidationTag());
    end;

}