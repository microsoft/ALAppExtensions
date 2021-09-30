codeunit 13603 "Install DK Core"
{
    Access = Internal;

    Subtype = Install;
    trigger OnInstallAppPerCompany()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
        BasicExtTxt: Label 'Basic Ext', Locked = true;
    begin
        ApplicationAreaMgmtFacade.SaveExperienceTierCurrentCompany(BasicExtTxt);
    end;
}