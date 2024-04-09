// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Finance.RoleCenters;

pageextension 31204 "Accountant CZ Role Center CZP" extends "Accountant CZ Role Center CZL"
{
    actions
    {
        addlast("Cash Management")
        {
            action("Cash Desks CZP")
            {
                Caption = 'Cash Desks';
                ApplicationArea = Basic, Suite;
                ToolTip = 'View and edit cash desks.';
                RunObject = Page "Cash Desk List CZP";
            }
            action("Cash Documents CZP")
            {
                Caption = 'Cash Documents';
                ApplicationArea = Basic, Suite;
                ToolTip = 'View and edit cash documents.';
                RunObject = Page "Cash Document List CZP";
            }
            action("Cash Desk Events CZP")
            {
                Caption = 'Cash Desk Events';
                ApplicationArea = Basic, Suite;
                ToolTip = 'View and edit cash desk events.';
                RunObject = Page "Cash Desk Events CZP";
            }
        }
        addlast("Posted Documents")
        {
            action("Posted Cash Documents CZP")
            {
                Caption = 'Posted Cash Documents';
                ApplicationArea = Basic, Suite;
                ToolTip = 'View posted cash documents.';
                RunObject = Page "Posted Cash Document List CZP";
            }
        }
        addlast("Cash Management Reports")
        {
            action("Cash Desk Book CZP")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Cash Desk Book';
                Ellipsis = true;
                Image = Report;
                RunObject = Report "Cash Desk Book CZP";
                ToolTip = 'View, print, or send the cash desk book report.';
            }
            action("Cash Desk Account Book CZP")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Cash Desk Account Book';
                Ellipsis = true;
                Image = Report;
                RunObject = Report "Cash Desk Account Book CZP";
                ToolTip = 'View, print, or send the cash desk account book report.';
            }
            action("Cash Desk Inventory CZP")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Cash Desk Inventory';
                Ellipsis = true;
                Image = Report;
                RunObject = Report "Cash Desk Inventory CZP";
                ToolTip = 'View, print, or send the cash desk inventory report.';
            }
        }
    }
}
