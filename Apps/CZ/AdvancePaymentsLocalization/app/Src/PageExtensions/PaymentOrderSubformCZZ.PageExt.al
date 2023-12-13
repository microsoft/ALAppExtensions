// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Bank.Documents;

pageextension 31181 "Payment Order Subform CZZ" extends "Payment Order Subform CZB"
{
    layout
    {
        addafter("Applies-to C/V/E Entry No.")
        {
            field("Purch. Advance Letter No. CZZ"; Rec."Purch. Advance Letter No. CZZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies no. of purchase advance letter.';
            }
        }
    }
}
