// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using Microsoft.Finance.GeneralLedger.Account;

pageextension 6786 "Withholding GL Account Card" extends "G/L Account Card"
{
    layout
    {
        addbefore("Default Deferral Template Code")
        {
            field("Wthldg. Tax Bus. Post. Group"; Rec."Wthldg. Tax Bus. Post. Group")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the withholding tax business posting group for the G/L account.';
            }
            field("Wthldg. Tax Prod. Post. Group"; Rec."Wthldg. Tax Prod. Post. Group")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the withholding tax product posting group for the G/L account.';
            }
        }
    }
}