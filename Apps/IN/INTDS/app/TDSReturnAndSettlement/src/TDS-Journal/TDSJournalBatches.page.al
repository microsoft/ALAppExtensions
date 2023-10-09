// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSReturnAndSettlement;

page 18748 "TDS Journal Batches"
{
    Caption = 'TDS Journal Batches';
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "TDS Journal Batch";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the tax journal batch.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the tax journal batch.';
                }
                field("Bal. Account Type"; Rec."Bal. Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of account where the balancing entry will be posted.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of location that the entry is posted to.';
                }
                field("Bal. Account No."; Rec."Bal. Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the general ledger account number where the balancing entry will be posted.';
                }
                field("No. Series"; Rec."No. Series")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number series from which numbers are assigned to new entries or records.';
                }
                field("Posting No. Series"; Rec."Posting No. Series")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of number series that will be used to assign number to ledger entries that are posted from Journal using this template.';
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the reason code, a supplementary source code that enables you to trace the entry.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Edit Journal")
            {
                Caption = 'Edit Journal';
                Image = OpenJournal;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ShortCutKey = 'Return';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Opens a journal based on the journal batch.';

                trigger OnAction()
                begin
                    TDSJnlManagement.TemplateSelectionFromTaxBatch(Rec);
                end;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.SetupNewBatch();
    end;

    trigger OnOpenPage()
    begin
        TDSJnlManagement.OpenTaxJnlBatch(Rec);
    end;

    var
        TDSJnlManagement: Codeunit "TDS Jnl Management";
}
