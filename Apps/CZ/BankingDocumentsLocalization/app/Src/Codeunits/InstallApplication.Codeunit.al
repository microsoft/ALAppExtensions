#pragma warning disable AL0432
codeunit 31330 "Install Application CZB"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        if not InitializeDone() then
            CopyData();

        CompanyInitialize();
    end;

    local procedure InitializeDone(): boolean
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        exit(AppInfo.DataVersion() <> Version.Create('0.0.0.0'));
    end;

    local procedure CopyData()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure CompanyInitialize()
    var
        DataClassEvalHandlerCZB: Codeunit "Data Class. Eval. Handler CZB";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        DataClassEvalHandlerCZB.ApplyEvaluationClassificationsForPrivacy();
        UpgradeTag.SetAllUpgradeTags();
    end;
}
