// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.RoleCenters;

pageextension 31106 "Accountant Role Center CZZ" extends "Accountant Role Center"
{
    actions
    {
        addafter("Posted Purchase Credit Memos")
        {
            action(SalesAdvLettersCZZ)
            {
                Caption = 'Sales Advance Letters';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Show sales advance letters.';
                RunObject = Page "Sales Advance Letters CZZ";
                RunPageView = where(Status = filter(<> Closed));
            }
            action(PurchAdvLettersCZZ)
            {
                Caption = 'Purchase Advance Letters';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Show purchase advance letters.';
                RunObject = Page "Purch. Advance Letters CZZ";
                RunPageView = where(Status = filter(<> Closed));
            }
        }
    }
}
