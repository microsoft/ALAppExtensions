// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.CashFlow.Setup;

pageextension 31195 "Cash Flow Setup CZZ" extends "Cash Flow Setup"
{
    layout
    {
        addafter("FA Disposal CF Account No.")
        {
            field("S. Adv. Letter CF Account No. CZZ"; Rec."S. Adv. Letter CF Acc. No. CZZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the number of the cash flow account for sales advance letters';
            }
            field("P. Adv. Letter CF Account No. CZZ"; Rec."P. Adv. Letter CF Acc. No. CZZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the number of the cash flow account for purchase advance letters ';
            }
        }
    }
}
