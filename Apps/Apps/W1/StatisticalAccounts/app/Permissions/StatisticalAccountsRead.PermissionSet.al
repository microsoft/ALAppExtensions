namespace Microsoft.Finance.Analysis.StatisticalAccount;

// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// this permission set is used to easily add all the extension objects into the apps license
/// do not include this permission set in any other permission set
/// and do not change the Access and Assignable properties
/// </summary>
permissionset 2627 "Statistical Accounts - Read"
{
    Assignable = false;
    Access = Public;
    Caption = 'Statistical Accounts - Read';
    IncludedPermissionSets = "Statistical Accounts - Objects";

    Permissions =
        tabledata "Statistical Acc. Journal Batch" = R,
        tabledata "Statistical Acc. Journal Line" = R,
        tabledata "Statistical Account" = R,
        tabledata "Statistical Ledger Entry" = R;
}