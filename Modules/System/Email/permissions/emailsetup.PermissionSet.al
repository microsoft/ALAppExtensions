#if not CLEAN18
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 8904 "EMAIL SETUP"
{
    Access = Public;
    Assignable = true;
    Caption = '(Obsolete) Email Setup';

    ObsoleteState = Pending;
    ObsoleteReason = 'This permission set is replaced with permission set Email - Admin';
    ObsoleteTag = '18.0';

    IncludedPermissionSets = "Email - Admin";
}
#endif
