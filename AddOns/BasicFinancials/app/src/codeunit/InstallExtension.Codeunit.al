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
        BasicFinancialsMgmt.TestSupportedLicenses();
        BasicFinancialsMgmt.TestSupportedUser();
        BasicFinancialsMgmt.TestSupportedCompanies();

        ApplicationAreaMgmtFacade.SaveExperienceTierCurrentCompany(DummyExperienceTierSetup.FieldCaption(DummyExperienceTierSetup."BF Basic Financials"));
        BasicFinancialsMgmt.TryDisableRoleCenter();
    end;


}