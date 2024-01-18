// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Finance.RoleCenters;

pageextension 31151 "Finance Manager RC CZP" extends "Finance Manager Role Center"
{
    actions
    {
        addlast(Sections)
        {
            group(CashDeskCZP)
            {
                Caption = 'Cash Desk';
                action(CashDesksListCZP)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cash Desks';
                    RunObject = page "Cash Desk List CZP";
                    RunPageMode = View;
                    ToolTip = 'Open the list of cash desks.';
                }
                action(CashDocumentsCZP)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cash Documents';
                    RunObject = page "Cash Document List CZP";
                    ToolTip = 'Open the list of cash documents.';
                }
                action(PostedCashDocumentsCZP)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Cash Documents';
                    RunObject = page "Posted Cash Document List CZP";
                    ToolTip = 'Open the list of posted cash documents.';
                }
                group(CashDeskReportsCZP)
                {
                    Caption = 'Reports';
                    action(CashDeskBookCZP)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Cash Desk Book';
                        RunObject = report "Cash Desk Book CZP";
                        ToolTip = 'View, print, or send a report that shows cash desk book.';
                    }
                    action(CashDeskAccountBookCZP)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Cash Desk Account Book';
                        RunObject = report "Cash Desk Account Book CZP";
                        ToolTip = 'View, print, or send a report that shows cash desk account book.';
                    }
                    action(CashDeskInventoryCZP)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Cash Desk Inventory';
                        RunObject = report "Cash Desk Inventory CZP";
                        ToolTip = 'View, print, or send a report that shows cash inventory.';
                    }
                }
                group(CashDeskSetupCZP)
                {
                    Caption = 'Setup';
                    action(CashDesksSetupCZP)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Cash Desks';
                        RunObject = page "Cash Desk List CZP";
                        RunPageMode = Edit;
                        ToolTip = 'Manage the list of cash desks.';
                    }
                    action(CashDeskEventsSetupCZP)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Cash Desk Events Setup';
                        RunObject = page "Cash Desk Events Setup CZP";
                        RunPageMode = Edit;
                        ToolTip = 'Manage cash desks events.';
                    }
                    action(CurrencyNominalValuesCZP)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Currency Nominal Values';
                        RunObject = page "Currency Nominal Values CZP";
                        RunPageMode = Edit;
                        ToolTip = 'Manage currency nominal values.';
                    }
                }
            }
        }
    }
}
