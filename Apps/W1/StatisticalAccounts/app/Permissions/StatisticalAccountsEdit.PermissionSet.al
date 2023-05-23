// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// this permission set is used to easily add all the extension objects into the apps license
/// do not include this permission set in any other permission set
/// and do not change the Access and Assignable properties
/// </summary>
permissionset 2625 "Statistical Accounts - Edit"
{
    Assignable = false;
    Access = Public;
    Caption = 'Statistical Accounts - View';

    IncludedPermissionSets = "Statistical Accounts - Read";

    Permissions =
        tabledata "Statistical Acc. Journal Batch" = IMD,
        tabledata "Statistical Acc. Journal Line" = IMD,
        tabledata "Statistical Account" = IMD,
        tabledata "Statistical Ledger Entry" = IMD;
}
