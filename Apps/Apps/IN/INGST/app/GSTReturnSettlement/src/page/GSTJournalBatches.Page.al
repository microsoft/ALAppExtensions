// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ReturnSettlement;

page 18327 "GST Journal Batches"
{
    Caption = 'GST Journal Batches';
    DataCaptionExpression = DataCaption();
    PageType = List;
    SourceTable = "GST Journal Batch";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the GST adjustment journal batch.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the GST adjustment journal batch.';
                }
                field("Bal. Account Type"; Rec."Bal. Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of account where the balancing entry will be posted.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the location code for a journal.';
                }
                field("Bal. Account No."; Rec."Bal. Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the general ledger account number where the balancing entry will be posted.';
                }
                field("No. Series"; Rec."No. Series")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number series as document/posting number.';
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
                field("Source Code"; Rec."Source Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the source code that specifies where the entry was created.';
                }
                field("Template Type"; Rec."Template Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of template as GST Adjustment Journal for update on journal line.';
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
                ApplicationArea = Basic, Suite;
                ToolTip = 'Open a journal based on journal batch.';
                Image = OpenJournal;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Return';

                trigger OnAction()
                begin
                    GSTJnlManagement.TemplateSelectionFromGSTBatch(Rec)
                end;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetupNewBatch();
    end;

    trigger OnOpenPage()
    begin
        GSTJnlManagement.OpenGSTJnlBatch(Rec);
    end;

    var
        GSTJnlManagement: Codeunit "GST Journal Management";

    local procedure DataCaption(): Text[250]
    var
        GSTJournalTemplate: Record "GST Journal Template";
    begin
        if not CurrPage.LookUpMode then
            if GetFilter("Journal Template Name") <> '' then
                if GetRangeMin("Journal Template Name") = GetRangeMax("Journal Template Name") then
                    if GSTJournalTemplate.Get(GetRangeMin("Journal Template Name")) then
                        exit(GSTJournalTemplate.Name + ' ' + GSTJournalTemplate.Description);
    end;
}

