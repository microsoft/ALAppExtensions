codeunit 20603 "Install Extension BF"
{
    Access = Internal;

    Subtype = Install;
    trigger OnInstallAppPerCompany()
    var
        DummyExperienceTierSetup: Record "Experience Tier Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
        BasicFinancialsMgmt: Codeunit "Basic Financials Mgmt BF";
    begin
        BasicFinancialsMgmt.TestSupportedLocales();
        //BasicFinancialsMgmt.TestSupportedLicenses(); // The requested functionality is not supported at the trigger OnInstallApp, in the current version of Microsoft Business Central.
        //BasicFinancialsMgmt.TestSupportedUser(); // The requested functionality is not supported at the trigger OnInstallApp, in the current version of Microsoft Business Central.
        BasicFinancialsMgmt.TestSupportedCompanies();
        BasicFinancialsMgmt.TryDisableRoleCenter();
        ApplicationAreaMgmtFacade.SaveExperienceTierCurrentCompany(DummyExperienceTierSetup.FieldCaption(DummyExperienceTierSetup."BF Basic Financials"));
    end;
}