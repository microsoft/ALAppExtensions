// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 2271 "SMTP-SETUP"
{
    Access = Public;
    Assignable = true;
    Caption = 'SMTP Mail Setup';
    ObsoleteTag = '20.0';
    ObsoleteState =  Pending;
    ObsoleteReason = '"SMTP Mail - Admin" has been removed.';
#if not CLEAN20
    IncludedPermissionSets = "SMTP Mail - Admin";
#endif
}
