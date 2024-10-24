// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

page 42005 "SL APDoc"
{
    ApplicationArea = All;
    Caption = 'Vendor Documents';
    PageType = List;
    SourceTable = "SL APDoc";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("RecordID"; Rec.RecordID) { ToolTip = 'Record ID'; }
                field(DocType; Rec.DocType) { ToolTip = 'Document Type'; }
                field(VendId; Rec.VendId) { ToolTip = 'Vendor ID'; }
                field(RefNbr; Rec.RefNbr) { ToolTip = 'Reference Number'; }
                field(DocDate; Rec.DocDate) { ToolTip = 'Document Date'; }
                field(DueDate; Rec.DueDate) { ToolTip = 'Due Date'; }
                field(DocBal; Rec.DocBal) { ToolTip = 'Document Balance'; }
                field(Terms; Rec.Terms) { ToolTip = 'Terms'; }
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
                    ToolTip = 'SL Posting Accounts';
                }
            }
        }
    }
}