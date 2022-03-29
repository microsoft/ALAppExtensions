#if not CLEAN20
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 7228 "G/L-XBRL"
{
    Access = Public;
    Assignable = true;
    Caption = 'Read XBRL Taxonomies';

    IncludedPermissionSets = "General Ledger XBRL - Read";
    ObsoleteTag = '20.0';
    ObsoleteState = Pending;
    ObsoleteReason = 'XBRL feature will be discontinued';
}
#endif