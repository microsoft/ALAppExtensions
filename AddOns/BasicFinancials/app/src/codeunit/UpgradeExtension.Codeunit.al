codeunit 20604 "Upgrade Extension BF"
{
    Access = Internal;

    Subtype = Upgrade;
    trigger OnUpgradePerCompany()
    var
        DummyExperienceTierSetup: Record "Experience Tier Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
        BasicFinancialsMgmt: Codeunit "Basic Financials Mgmt BF";
    begin
        BasicFinancialsMgmt.TestSupportedLocales();
        //BasicFinancialsMgmt.TestSupportedLicenses(); // The requested functionality is not supported at the trigger OnUpgrade, in the current version of Microsoft Business Central.
        //BasicFinancialsMgmt.TestSupportedUser();  // The requested functionality is not supported at the trigger OnUpgrade, in the current version of Microsoft Business Central.
        ApplicationAreaMgmtFacade.SaveExperienceTierCurrentCompany(DummyExperienceTierSetup.FieldCaption(DummyExperienceTierSetup."BF Basic Financials"));
    end;
}