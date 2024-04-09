// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Environment.Configuration;

using System.Environment;
using System.Reflection;
#if not CLEAN22
using System.Security.AccessControl;
#endif

codeunit 20601 "Basic Mgmt BF"
{
    Access = Internal;

    var
        AllProfileFilterTxt: Label 'MANUFACTURING|PROJECTS|SERVICES|WAREHOUSE|SHIPPING AND RECEIVING - WMS|SHIPPING AND RECEIVING|WAREHOUSE WORKER - WMS|PRODUCTION PLANNER|PROJECT MANAGER|DISPATCHER|SALES AND RELATIONSHIP MANAGER', Locked = true;

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
#if not CLEAN22
        UserGroup: Record "User Group";
#endif
    begin
        if AllProfile."Default Role Center" then
            exit(true);

#if not CLEAN22
        UserGroup.SetRange("Default Profile ID", AllProfile."Profile ID");
        UserGroup.SetRange("Default Profile App ID", AllProfile."App ID");
        if not UserGroup.IsEmpty() then
            exit(true);
#endif

        UserPersonalization.SetRange("Profile ID", AllProfile."Profile ID");
        UserPersonalization.SetRange("App ID", AllProfile."App ID");
        if not UserPersonalization.IsEmpty() then
            exit(true);

        exit(false);
    end;
}
