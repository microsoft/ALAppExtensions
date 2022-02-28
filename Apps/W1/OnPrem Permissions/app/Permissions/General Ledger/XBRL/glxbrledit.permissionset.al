#if not CLEAN20
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 2253 "G/L-XBRL, EDIT"
{
    Access = Public;
    Assignable = true;
    Caption = 'Create, edit XBRL Taxonomies';

    IncludedPermissionSets = "General Ledger XBRL - Edit";
    ObsoleteTag = '20.0';
    ObsoleteState = Pending;
    ObsoleteReason = 'XBRL feature will be discontinued';
}
#endif