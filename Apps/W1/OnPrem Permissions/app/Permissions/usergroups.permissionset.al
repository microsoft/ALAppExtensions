#if not CLEAN22
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 7244 "USERGROUPS"
{
    Access = Public;
    Assignable = true;
    Caption = 'User Groups Setup';
    ObsoleteState = Pending;
    ObsoleteReason = 'The user group functionality is deprecated.';
    ObsoleteTag = '22.0';

    IncludedPermissionSets = "User Groups - Admin";
}
#endif