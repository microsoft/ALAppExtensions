// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using System.Automation;

pageextension 31285 "Approval User Setup CZP" extends "Approval User Setup"
{
    layout
    {
        addafter("Unlimited Request Approval")
        {
            field("Cash Desk Amt. Appr. Limit"; Rec."Cash Desk Amt. Appr. Limit CZP")
            {
                ApplicationArea = Suite;
                ToolTip = 'Specifies approval limit for approving cash desk document';
            }
            field("Unlimited Cash Desk Appr. CZP"; Rec."Unlimited Cash Desk Appr. CZP")
            {
                ApplicationArea = Suite;
                ToolTip = 'Specifies that the user on this line is allowed to approve cash desk documents with no maximum amount.';
            }
        }
    }
}
