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
permissionset 2626 "Statistical Accounts - Objects"
{
    Assignable = false;
    Access = Public;
    Caption = 'Statistical Accounts - Objects';

    Permissions =
        codeunit "Stat. Acc. Fin Reporting Mgt" = X,
        codeunit "Stat. Acc. Jnl Check Line" = X,
        codeunit "Stat. Acc. Jnl. Line Post" = X,
        codeunit "Stat. Acc. Post. Batch" = X,
        codeunit "Stat. Acc. Telemetry" = X,
        table "Statistical Acc. Journal Batch" = X,
        table "Statistical Acc. Journal Line" = X,
        table "Statistical Account" = X,
        table "Statistical Ledger Entry" = X,
        page "Statistical Account Card" = X,
        page "Statistical Acc. Journal Batch" = X,
        page "Statistical Account List" = X,
        page "Statistical Accounts Journal" = X,
        page "Statistical Ledger Entry List" = X;
}