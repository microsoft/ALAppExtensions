// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Finance.RoleCenters;

pageextension 31160 "Business Manager RC CZP" extends "Business Manager Role Center"
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
            }
        }
    }
}
