// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This permission set is required to turn a feature on or off. It can be assigned to users to give full access to the Feature Management functionality.
/// </summary>
PermissionSet 2615 "Feature Mgt. - Admin"
{
    Access = Public;
    Assignable = true;
    Caption = 'Feature Management - Admin';

    IncludedPermissionSets = "Feature Key - Admin";
}
