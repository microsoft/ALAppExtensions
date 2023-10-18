// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSReturnAndSettlement;

page 18871 "TCS Journal Batches"
{
    Caption = 'TCS Journal Batches';
    DataCaptionExpression = DataCaption();
    PageType = List;
    SourceTable = "TCS Journal Batch";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the journal you are creating.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a brief description of the journal batch you are creating.';
                }
                field("Bal. Account Type"; Rec."Bal. Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of account that a balancing entry is posted to, such as Bank for a Cash account.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the location code for which the journal lines will be posted.';
                }
                field("Bal. Account No."; Rec."Bal. Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the general ledger, customer, vendor, or bank account that the balancing entry is posted to, such as a Cash account.';
                }
                field("No. Series"; Rec."No. Series")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number series from which entry or record numbers are assigned to new entries or records.';
                }
                field("Posting No. Series"; Rec."Posting No. Series")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code for the number series that will be used to assign document numbers to ledger entries that are posted from this journal batch.';
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
                PromotedOnly = true;
                PromotedIsBig = true;
                ShortCutKey = 'Return';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Opens a journal based on the journal batch.';

                trigger OnAction()
                begin
                    TCSAdjustment.TemplateSelectionFromTCSBatch(Rec);
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
        TCSAdjustment.OpenTCSJnlBatch(Rec);
    end;

    var
        TCSAdjustment: Codeunit "TCS Adjustment";

    local procedure DataCaption(): Text[250]
    var
        TCSJournalTemplate: Record "TCS Journal Template";
    begin
        if not CurrPage.LookupMode() then
            if (Rec.GetFilter("Journal Template Name") <> '') and (Rec.GetRangeMin("Journal Template Name") = Rec.GetRangeMax("Journal Template Name")) then
                if TCSJournalTemplate.Get(Rec.GetRangeMin("Journal Template Name")) then
                    exit(TCSJournalTemplate.Name + ' ' + TCSJournalTemplate.Description);
    end;
}
