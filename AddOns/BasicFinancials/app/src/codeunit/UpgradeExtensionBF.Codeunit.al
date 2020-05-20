codeunit 20604 "Upgrade Extension BF"
{
    Access = Internal;

    Subtype = Upgrade;
    trigger OnUpgradePerCompany()
    var
        DummyExperienceTierSetup: Record "Experience Tier Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
        BasicMgmt: Codeunit "Basic Mgmt BF";
    begin
        BasicMgmt.TestSupportedLocales();
        //BasicMgmt.TestSupportedLicenses(); // The requested functionality is not supported at the trigger OnUpgrade, in the current version of Microsoft Business Central.
        //BasicMgmt.TestSupportedUser();  // The requested functionality is not supported at the trigger OnUpgrade, in the current version of Microsoft Business Central.
        ApplicationAreaMgmtFacade.SaveExperienceTierCurrentCompany(DummyExperienceTierSetup.FieldCaption(DummyExperienceTierSetup."BF Basic"));
    end;
}