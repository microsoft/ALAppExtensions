// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ExciseTax;

page 6286 "Sust. Excise Jnl. Batches"
{
    Caption = 'Excise Journal Batches';
    PageType = List;
    SourceTable = "Sust. Excise Journal Batch";
    ApplicationArea = Basic, Suite;
    AnalysisModeEnabled = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the name of the journal batch you are creating.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a brief description of the journal batch you are creating.';
                }
                field("No Series"; Rec."No Series")
                {
                    ToolTip = 'Specifies the No. Series to use for the journal batch.';
                }
                field(Type; Rec.Type)
                {
                    ToolTip = 'Specifies the type that is allowed to be used in the journal batch.';
                }
                field("Source Code"; Rec."Source Code")
                {
                    ToolTip = 'Specifies the source code for the journal batch.';
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ToolTip = 'Specifies the reason code for the journal batch.';
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action(EditJournal)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Edit Journal';
                Image = OpenJournal;
                ShortCutKey = 'Return';
                ToolTip = 'Open a journal based on the journal batch.';

                trigger OnAction()
                var
                    SustainabilityExciseJnlTemplate: Record "Sust. Excise Journal Template";
                    SustainabilityExciseJournalMgt: Codeunit "Sust. Excise Journal Mgt.";
                begin
                    SustainabilityExciseJnlTemplate.Get(Rec."Journal Template Name");
                    SustainabilityExciseJournalMgt.OpenJournalPageFromBatch(Rec, SustainabilityExciseJnlTemplate);
                end;
            }
        }
    }
}