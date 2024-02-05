// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance;

using Microsoft.Finance.GeneralLedger.IRS;
using Microsoft.Finance.VAT.Reporting;

permissionset 14600 "IS Core - Objects"
{
    Assignable = true;

    Permissions = table "IS IRS Groups" = X,
        table "IS IRS Numbers" = X,
        table "IS IRS Types" = X,
        report "IS IRS Details" = X,
        report "IS IRS notification" = X,
        report "IS Trial Balance - IRS Number" = X,
        report "IS VAT Balancing Report" = X,
        report "IS VAT Reconciliation A" = X,
        codeunit "IS Core Install" = X,
        codeunit "IS Core" = X,
        codeunit "Enable IS Core App" = X,
        codeunit "IS Docs Retention Period" = X,
        codeunit "IS Core Upgrade" = X,
        page "IS IRS Groups" = X,
        page "IS IRS Numbers" = X,
#if not CLEAN24
        page "IS Core App Setup Wizard" = X,
#endif
        page "IS IRS Types" = X;
}