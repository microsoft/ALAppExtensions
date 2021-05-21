codeunit 20601 "Basic Mgmt BF"
{
    Access = Internal;

    var
        NotSupportedUserErr: Label 'The user who deploys the Basic Experience extension must have the Super User permission set.';
        AllProfileFilterTxt: Label 'MANUFACTURING|PROJECTS|SERVICES|WAREHOUSE|SHIPPING AND RECEIVING - WMS|SHIPPING AND RECEIVING|WAREHOUSE WORKER - WMS|PRODUCTION PLANNER|PROJECT MANAGER|DISPATCHER|SALES AND RELATIONSHIP MANAGER', Locked = true;
        UserSecurityIdTxt: Label '{00000000-0000-0000-0000-000000000001}', Locked = true, Comment = 'System user';
        NotSupportedSystemUserErr: Label 'The Basic Experience extension must be installed by a user who exists in the User table. The current user is the Microsoft System User.';
        UnknowUserErr: Label 'The current user is not found in the User table.The Basic Experience extension must be installed by a user who exists in the User table.';

    internal procedure IsSupportedLicense(): Boolean // Microsoft requirements: The Basic Assisted Setup checks for the Basic license on the AAD tenant, at least one user has been assigned to this license.
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        // Checks for the Basic license on the AAD tenant is not possibly in Sandbox Environment
        if EnvironmentInformation.IsSandbox() then
            exit(false);

        exit(true);
    end;

    internal procedure IsSupportedCompanies(): Boolean // Microsoft requirements: The Basic Assisted Setup checks for whether the tenant contains more than one company.
    var
        Company: Record Company;
    begin
        Clear(Company);
        if Company.count() = 1 then
            exit(true);
        exit(false);
    end;

    internal procedure TestSupportedUser() // Microsoft requirements: The extension checks whether the Super User permission set is assigned to the user who is installing the extension.
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

    internal procedure TryDisableRoleCenter() // Microsoft requirement: The extensions aligns the user experience with the license limitations by disabling certain Role Centers that are not assigned to groups or users.
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