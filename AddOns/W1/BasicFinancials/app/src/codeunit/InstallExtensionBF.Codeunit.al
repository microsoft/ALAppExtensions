codeunit 20603 "Install Extension BF"
{
    /*
    To install the Basic Experience extension , the partner does the following:
    1.	Creates a new Business Central tenant.
    2.	Adds at least one user who has a Business Central Basic license assigned to them in the Azure Active Directory tenant.
    3.	Removes all companies manually, including Cronus.
    4.	Creates one production company that does not contain data or setups.
    5.	Imports a configuration package that includes Basic setup data.
    6.	Installs the Basic Experience extension.
    7.	Completes the Business Central Basic assisted setup guide. The assisted setup guide checks for the Business Central Basic license.
    8.	Sends sign in information to the customer in an email.
    */

    Access = Internal;

    Subtype = Install;
    trigger OnInstallAppPerCompany()
    var
        DummyExperienceTierSetup: Record "Experience Tier Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
        BasicMgmt: Codeunit "Basic Mgmt BF";
    begin
        BasicMgmt.TestSupportedLocales();
        BasicMgmt.TryDisableRoleCenter();
        ApplicationAreaMgmtFacade.SaveExperienceTierCurrentCompany(DummyExperienceTierSetup.FieldCaption(DummyExperienceTierSetup."BF Basic"));
    end;
}