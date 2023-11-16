// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

page 31155 "Cash Desk Role Center CZP"
{
    Caption = 'Cash Desk';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {
            group(Control1)
            {
                ShowCaption = false;
                part(CashDeskActivities; "Cash Desk Activities CZP")
                {
                    ApplicationArea = Basic, Suite;
                }
                systempart(MyNotes; MyNotes)
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }

    actions
    {
        area(reporting)
        {
            action("Cash Desk Account Book")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Cash Desk Account Book';
                Image = Print;
                RunObject = report "Cash Desk Account Book CZP";
                ToolTip = 'Open the report for cash desk account book - printed only posted documents.';
            }
            action("Cash Inventory")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Cash Desk Inventory';
                Image = Print;
                RunObject = report "Cash Desk Inventory CZP";
                ToolTip = 'Open the report for cash inventory.';
            }
            action("Cash Desk Book")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Cash Desk Book';
                Image = Print;
                RunObject = report "Cash Desk Book CZP";
                ToolTip = 'Open the report for cash desk book - printed posted and released unposted documents.';
            }
        }
        area(embedding)
        {
            action("Cash Desks")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Cash Desks';
                Image = List;
                RunObject = page "Cash Desk List CZP";
                ToolTip = 'Specifies cash desks';
            }
        }
    }
}
