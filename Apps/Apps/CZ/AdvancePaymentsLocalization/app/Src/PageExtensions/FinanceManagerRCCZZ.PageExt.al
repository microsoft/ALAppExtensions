// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.RoleCenters;

using Microsoft.Finance.AdvancePayments;

pageextension 31231 "Finance Manager RC CZZ" extends "Finance Manager Role Center"
{
    actions
    {
        addlast(Group40)
        {
            action("Purch. Advance Letters CZZ")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Purchase Advance Letters';
                Image = Report;
                RunObject = report "Purch. Advance Letters CZZ";
                Tooltip = 'Run the Purch. Advance Letters report.';
            }
            action("Purch. Advance Letters VAT CZZ")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Purchase Advance Letters VAT';
                Image = Report;
                RunObject = report "Purch. Advance Letters VAT CZZ";
                Tooltip = 'Run the Purch. Advance Letters VAT report.';
            }
            action("Purch. Adv. Letters Recap. CZZ")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Purch. Advance Letters Recapitulation';
                Image = Report;
                RunObject = report "Purch. Adv. Letters Recap. CZZ";
                Tooltip = 'Run the Purch. Adv. Letters Recap. report.';
            }
        }
        addlast(Group34)
        {
            action("Sales Advance Letters CZZ")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Sales Advance Letters';
                Image = Report;
                RunObject = report "Sales Advance Letters CZZ";
                Tooltip = 'Run the Sales Advance Letters report.';
            }
            action("Sales Advance Letters VAT CZZ")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Sales Advance Letters VAT';
                Image = Report;
                RunObject = report "Sales Advance Letters VAT CZZ";
                Tooltip = 'Run the Sales Advance Letters VAT report.';
            }
            action("Sales Adv. Letters Recap. CZZ")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Sales Advance Letters Recapitulation';
                Image = Report;
                RunObject = report "Sales Adv. Letters Recap. CZZ";
                Tooltip = 'Run the Sales Adv. Letters Recap. report.';
            }
        }
    }
}
