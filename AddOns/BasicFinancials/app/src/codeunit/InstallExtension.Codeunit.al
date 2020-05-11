codeunit 20603 "Install Extension BF"
{
    /*
    Installation process 

    1)	The partner creates a new Business Central Tenant
    2)	The partner adds at least one user with a Basic Financials License to ADD tenant
    3)	The partner manually removes all companies  (incl Cronus)
    4)	The partner creates one new production company
    5)	The partner import a configuration packages with Basic Financials setup data  
    6)	The partner installs the Basic Financials extension
        a.	The extension checks for for the country availability
        b.	The extension checks for the Basic Financials license (Not implemented due to unsupported functionality)
        c.	The extension checks for User Permissions (Not implemented due to unsupported functionality)
        d.	The extension checks for only 1 company is installed on the tenant
    7)  The partner completed the Basic Financials Assisted Setup
        a.	The Assisted Setup checks for the Basic Financials license (is implemented as a workaround due to unsupported functionality at OnInstallAppPerCompany trigger)
    8)	The partner sends an email to the customer including log-in details
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