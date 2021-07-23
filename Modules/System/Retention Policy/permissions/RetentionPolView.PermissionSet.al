// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// this is the minimum permission set needed to install an extension that adds a retention policy.
/// </summary>
PermissionSet 3905 "Retention Pol. View"
{
    Access = Public;
    Assignable = true;

    IncludedPermissionSets = "Retention Policy - View";
}
