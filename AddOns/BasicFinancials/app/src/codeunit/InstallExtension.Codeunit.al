codeunit 20603 "Install Extension BF"
{
    /*
    To install the extension, the partner does the following:
    1.	Creates a new Business Central tenant.
    2.	Adds at least one user who has a Basic FInancials license assigned to them in the Azure Active Directory tenant.
    3.	Removes all companies manually, including Cronus.
    4.	Creates one production company that does not contain data or setups.
    5.	Imports a configuration package that includes Basic Financials setup data.
    6.	Installs the Basic Financials extension. During installation the extension verifies the country availability that there is only one company.
    7.	Completes the Basic Financials assisted setup guide. The assisted setup guide checks for the Basic Financials license.
    8.	Sends sign in information to the customer in an email.
    */

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