#if not CLEAN18
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// this permission set is required to create retention policies
/// </summary>
permissionset 3903 "RETENTION POL. SETUP"
{
    Access = Public;
    Assignable = true;
    Caption = '(Obsolete) Reten. Pol. Setup';

    ObsoleteState = Pending;
    ObsoleteReason = 'Replaced with PermissionSet Retention Pol. Admin';
    ObsoleteTag = '18.0';

    IncludedPermissionSets = "Retention Policy - Admin";
}
#endif
