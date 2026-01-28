// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using Microsoft.Purchases.History;

pageextension 6792 "WHT Purch. Cr. Memo Statistics" extends "Purch. Credit Memo Statistics"
{
    layout
    {
        addafter(Vendor)
        {
            group(Withholding)
            {
                Caption = 'Withholding';
                field("Rem. Wthldg. Tax Pre. Amt(LCY)"; Rec."Rem. Wthldg. Tax Pre. Amt(LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the remaining Withholding Tax Amount, which is to be realized (deducted) for this credit memo.';
                }
                field("Paid Wthldg. Tax Pre. Amt(LCY)"; Rec."Paid Wthldg. Tax Pre. Amt(LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the paid (realized) Withholding Tax amount for this credit memo.';
                }
                field("Tot. Wthldg. Tax Pre. Amt(LCY)"; Rec."Tot. Wthldg. Tax Pre. Amt(LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total Withholding Tax amount for the credit memo.';
                }
            }
        }
    }
}