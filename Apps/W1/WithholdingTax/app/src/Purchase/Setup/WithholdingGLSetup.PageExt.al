// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using Microsoft.Finance.GeneralLedger.Setup;

pageextension 6788 "Withholding GL Setup" extends "General Ledger Setup"
{
    layout
    {
        addafter("Bank Account Nos.")
        {
            field("Enable Withholding Tax"; Rec."Enable Withholding Tax")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if your company must use withholding tax.';
            }
            field("Min. Wthldg. Tax Calc Inv. Amt"; Rec."Min. Wthldg. Tax Calc Inv. Amt")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies Min. Withholding Tax Calc Inv. Amt';
            }
        }
    }
}