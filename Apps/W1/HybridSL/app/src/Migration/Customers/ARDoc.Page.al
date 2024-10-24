// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

page 42004 "SL ARDoc"
{
    ApplicationArea = All;
    Caption = 'SL Customer Open Documents';
    PageType = List;
    SourceTable = "SL ARDoc";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(CpnyID; Rec.CpnyID) { ToolTip = 'Company ID'; }
                field(CustId; Rec.CustId) { ToolTip = 'Customer Number'; }
                field(RefNbr; Rec.RefNbr) { ToolTip = 'Reference Number'; }
                field(DocDate; Rec.DocDate) { ToolTip = 'Document Date'; }
                field(DueDate; Rec.DueDate) { ToolTip = 'Due Date'; }
                field(DocBal; Rec.DocBal) { ToolTip = 'Customer Transaction Amount'; }
                field(DocType; Rec.DocType) { ToolTip = 'Document Type'; }
                field(SlsperId; Rec.SlsperId) { ToolTip = 'Salesperson Id'; }
                field(Terms; Rec.Terms) { ToolTip = 'Payment Terms Id'; }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            group(SupportingPages)
            {
                Caption = 'Supporting Pages';

                action(AccountSetup)
                {
                    Caption = 'Posting Accounts';
                    Image = EntriesList;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    RunObject = page "SL Posting Accounts";
                    RunPageMode = Edit;
                    ToolTip = 'Posting Account Setup';
                }
            }
        }
    }
}