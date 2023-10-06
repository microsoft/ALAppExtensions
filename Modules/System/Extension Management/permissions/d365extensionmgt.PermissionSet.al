#if not CLEAN18
// BUG: 481264 - permissionset 2503 "D365 EXTENSION MGT" cannot get removed (CLEAN18) without tests failing

// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Apps;

permissionset 2503 "D365 EXTENSION MGT"
{
    Access = Public;
    Assignable = true;
    Caption = '(Obsolete) D365 Extension Mgt.';

    ObsoleteState = Pending;
    ObsoleteReason = 'This permission set is replaced by permission set Exten. Mgt. - Admin';
    ObsoleteTag = '18.0';

    IncludedPermissionSets = "Exten. Mgt. - Admin";
}
#endif
