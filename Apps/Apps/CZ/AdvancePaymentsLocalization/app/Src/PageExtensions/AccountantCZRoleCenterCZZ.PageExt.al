// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.RoleCenters;

pageextension 31206 "Accountant CZ Role Center CZZ" extends "Accountant CZ Role Center CZL"
{
    actions
    {
        addafter("Purchase Credit Memos")
        {
            action("View Purchase Advance Letters CZZ")
            {
                Caption = 'Purchase Advance Letters';
                ApplicationArea = Basic, Suite;
                ToolTip = 'View or edit purchase advance letters.';
                RunObject = Page "Purch. Advance Letters CZZ";
                RunPageView = where(Status = filter(<> Closed));
            }
        }
        addafter("Sales Credit Memos")
        {
            action("View Sales Advance Letters CZZ")
            {
                Caption = 'Sales Advance Letters';
                ApplicationArea = Basic, Suite;
                ToolTip = 'View or edit sales advance letters.';
                RunObject = Page "Sales Advance Letters CZZ";
                RunPageView = where(Status = filter(<> Closed));
            }
        }
        addafter("Purchase Credit Memo")
        {
            action("Create Purchase Advance Letter CZZ")
            {
                Caption = 'Purchase Advance Letter';
                ApplicationArea = Basic, Suite;
                RunObject = Page "Purch. Advance Letter CZZ";
                RunPageMode = Create;
                ToolTip = 'Create a new purchase advance letter.';
            }
        }
        addafter("Sales Credit Memo")
        {
            action("Create Sales Advance Letter CZZ")
            {
                Caption = 'Sales Advance Letter';
                ApplicationArea = Basic, Suite;
                RunObject = Page "Sales Advance Letter CZZ";
                RunPageMode = Create;
                ToolTip = 'Create a new sales advance letter.';
            }
        }
        addlast("Payable Reports")
        {
            action("Purchase Advance Letters CZZ")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Purchase Advance Letters';
                Ellipsis = true;
                Image = Report;
                RunObject = Report "Purch. Advance Letters CZZ";
                ToolTip = 'View, print, or send the purchase advance letters report.';
            }
            action("Purchase Advance Letters VAT CZZ")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Purchase Advance Letters VAT';
                Ellipsis = true;
                Image = Report;
                RunObject = Report "Purch. Advance Letters VAT CZZ";
                ToolTip = 'View, print, or send the purchase advance letters VAT report.';
            }
            action("Purchase Advance Letters Recapitulation CZZ")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Purchase Advance Letters Recapitulation';
                Ellipsis = true;
                Image = Report;
                RunObject = Report "Purch. Adv. Letters Recap. CZZ";
                ToolTip = 'View, print, or send the purchase advance letters recapitulation report.';
            }
        }
        addlast("Receivable Reports")
        {
            action("Sales Advance Letters CZZ")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Sales Advance Letters';
                Ellipsis = true;
                Image = Report;
                RunObject = Report "Sales Advance Letters CZZ";
                ToolTip = 'View, print, or send the sales advance letters report.';
            }
            action("Sales Advance Letters VAT CZZ")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Sales Advance Letters VAT';
                Ellipsis = true;
                Image = Report;
                RunObject = Report "Sales Advance Letters VAT CZZ";
                ToolTip = 'View, print, or send the sales advance letters VAT report.';
            }
            action("Sales Advance Letters Recapitulation CZZ")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Sales Advance Letters Recapitulation';
                Ellipsis = true;
                Image = Report;
                RunObject = Report "Sales Adv. Letters Recap. CZZ";
                ToolTip = 'View, print, or send the sales advance letters recapitulation report.';
            }
        }
    }
}
