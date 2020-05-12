codeunit 20601 "Basic Financials Mgmt BF"
{
    Access = Internal;

    var
        AzureADLicensing: codeunit "Azure AD Licensing";
        NotSupportedLicenseErr: Label 'The Basic Financials Extension can only be deployed, when at least one user has been assigned to a Basic Financials license.';
        NotSupportedLocalesErr: Label 'The Basic Financials Extension can only be deployed for the following countries: Denmark, Iceland.';
        NotSupportedUserErr: Label 'The Basic Financials Extension can only be deployed with Super User Permissions.';
        NotSupportedCompanyErr: Label 'The Basic Financials Extension, can only be deployed, when exactly one Company is present in the Environment.';
        AllProfileFilterTxt: Label 'MANUFACTURING|PROJECTS|SERVICES|WAREHOUSE|SHIPPING AND RECEIVING - WMS|SHIPPING AND RECEIVING|WAREHOUSE WORKER - WMS|PRODUCTION PLANNER|PROJECT MANAGER|DISPATCHER|SALES AND RELATIONSHIP MANAGER', Locked = true;
        BFSKUIdTxt: Label '{66CAD104-64F9-476E-9682-3C3518B9B6ED}', Locked = true, Comment = 'Dynamics 365 Business Central Basic Financials';
        BFC5SPLASKUIdTxt: Label '{4dCE07FD-7B07-4FB5-8FB7-D49653F7BF30}', Locked = true, Comment = 'Dynamics 365 Business Central Basic Financials from C5 SPLA (Qualified Offer)';
        UserSecurityIdTxt: Label '{00000000-0000-0000-0000-000000000001}', Locked = true, Comment = 'System user';
        NotSupportedSystemUserErr: Label 'The current user is the Microsoft System User. The Basic Financials Extension can only be deployed with a user that exist in the user table.';
        UnknowUserErr: Label 'The current user is unknown. The Basic Financials Extension can only be deployed with a user that exist in the user table.';

    internal procedure IsSupportedLicense(): Boolean // A microsoft requirements: The Basic Financials Assisted Setup checks for the Basic Financials license on the AAD tenant, at least one user has been assigned to this license.
    var
    begin
        AzureADLicensing.ResetSubscribedSKU();
        while AzureADLicensing.NextSubscribedSKU() do
            case UpperCase(AzureADLicensing.SubscribedSKUId()) of
                BFSKUIdTxt:
                    exit(true);
                BFC5SPLASKUIdTxt:
                    exit(true);
            end;
        exit(false);
    end;

    internal procedure TestSupportedLicenses() // A microsoft requirements: The extension checks for the Basic Financials license on the AAD tenant, at least one user has been assigned to this license. 
    var
    begin
        AzureADLicensing.ResetSubscribedSKU();
        while AzureADLicensing.NextSubscribedSKU() do
            case UpperCase(AzureADLicensing.SubscribedSKUId()) of
                BFSKUIdTxt:
                    exit;
                BFC5SPLASKUIdTxt:
                    exit;
            end;
        Error(NotSupportedLicenseErr);
    end;

    internal procedure TestSupportedLocales() // A microsoft requirements: The extension checks for the country availability, the extension is only available to the Countries: Denmark, Iceland';
    var
        TempApplicationAreaSetup: Record "Application Area Setup";
        AppAreaMgmt: Codeunit "App Area Mgmt BF";

    begin
        Clear(TempApplicationAreaSetup);
        AppAreaMgmt.GetEssentialExperienceAppAreas(TempApplicationAreaSetup);
        if TempApplicationAreaSetup."Basic DK" or TempApplicationAreaSetup."Basic IS" then
            exit;

        Error(NotSupportedLocalesErr);
    end;

    internal procedure TestSupportedUser() // A microsoft requirements: The extension checks for User Permissions, the user which install the extension has been assigned to Super. 
    var
        User: Record User;
        UserPermissions: Codeunit "User Permissions";
    begin
        if UserSecurityId() = UserSecurityIdTxt then
            Error(NotSupportedSystemUserErr);

        if User.Get(UserSecurityId()) then
            Error(UnknowUserErr);

        if UserPermissions.IsSuper(UserSecurityId()) then
            exit;

        Error(NotSupportedUserErr);
    end;

    internal procedure TestSupportedCompanies() // A microsoft requirements: The extension checks for only 1 company is installed on the tenant, additional companies has to be added afterward. 
    var
        Company: Record Company;
    begin
        Clear(Company);
        if Company.count() = 1 then
            exit;
        Error(NotSupportedCompanyErr);
    end;

    internal procedure TryDisableRoleCenter() // A microsoft requirements:The Extensions aligns the User Experience to the license limitations, by disable certain Role Center, which is not assigned to Groups Or Users.
    var
        AllProfile: Record "All Profile";
    begin
        Clear(AllProfile);
        AllProfile.SetRange(Enabled, true);
        AllProfile.SetFilter("Profile ID", AllProfileFilterTxt);

        if AllProfile.FindSet(true, false) then
            repeat
                if not IsAssignedToGroupsOrUsers(AllProfile) then begin // Disable Role Center, which is not assigned to Groups Or Users. It is not possible to disable Role Center which is in use.
                    AllProfile.Enabled := false;
                    AllProfile.Promoted := false;
                    AllProfile.Modify();
                end;
            until AllProfile.Next() = 0;
    end;

    internal procedure IsAssignedToGroupsOrUsers(AllProfile: Record "All Profile"): Boolean
    var
        UserPersonalization: Record "User Personalization";
        UserGroup: Record "User Group";
    begin
        if AllProfile."Default Role Center" then
            exit(true);

        UserGroup.SetRange("Default Profile ID", AllProfile."Profile ID");
        UserGroup.SetRange("Default Profile App ID", AllProfile."App ID");
        if not UserGroup.IsEmpty() then
            exit(true);

        UserPersonalization.SetRange("Profile ID", AllProfile."Profile ID");
        UserPersonalization.SetRange("App ID", AllProfile."App ID");
        if not UserPersonalization.IsEmpty() then
            exit(true);

        exit(false);
    end;
}