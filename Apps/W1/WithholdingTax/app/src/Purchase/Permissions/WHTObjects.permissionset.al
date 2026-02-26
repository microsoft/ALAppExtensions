// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.WithholdingTax;

using Microsoft.Finance.WithholdingTax;

permissionset 6786 "WHT - Objects"
{
    Caption = 'Withholding Tax - Objects';
    Access = Internal;
    Assignable = false;

    Permissions =
        table "Wthldg. Tax Bus. Post. Group" = X,
        table "Wthldg. Tax Prod. Post. Group" = X,
        table "Withholding Tax Posting Setup" = X,
        table "Withholding Tax Revenue Types" = X,
        table "Withholding Tax Entry" = X,
        table "Withholding Tax Cert. Buffer" = X,
        table "Temp Withholding Tax Entry" = X,
        table "Withholding Tax Posting Buffer" = X,
        page "Wthldg. Tax Bus. Post. Group" = X,
        page "Wthldg. Tax Prod. Post. Group" = X,
        page "Withholding Tax Posting Setup" = X,
        page "Withholding Tax Revenue Types" = X,
        page "Withholding Tax Entries" = X,
        codeunit "Wthldg Tax Purch. Subscribers" = X,
        codeunit "Withholding Tax Mgmt." = X,
        codeunit "Withholding Tax Jnl Subscriber" = X,
        codeunit "Wthldg Tax Navigate Handler" = X,
        codeunit "Withholding Tax Event Handler" = X,
        report "WHT Calc. and Post Settlement" = X,
        report "WHT Annual Information Return" = X,
        report "WHT Certificate Creditable tax" = X,
        report "WHT Monthly Remittance Return" = X,
        report "Withholding Tax Certificate" = X;
}