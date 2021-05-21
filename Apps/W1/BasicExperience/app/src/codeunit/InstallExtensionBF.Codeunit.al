codeunit 20603 "Install Extension BF"
{
    Access = Internal;

    Subtype = Install;
    trigger OnInstallAppPerCompany()
    var
        DummyExperienceTierSetup: Record "Experience Tier Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
        BasicMgmt: Codeunit "Basic Mgmt BF";
    begin
        BasicMgmt.TryDisableRoleCenter();
        ApplicationAreaMgmtFacade.SaveExperienceTierCurrentCompany(DummyExperienceTierSetup.FieldCaption(DummyExperienceTierSetup."BF Basic"));
    end;
}