// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Ledger;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Foundation.Navigate;

page 31286 "Applied G/L Entries CZA"
{
    Caption = 'Applied General Ledger Entries';
    DataCaptionExpression = Caption();
    Editable = false;
    PageType = List;
    SourceTable = "G/L Entry";

    layout
    {
        area(content)
        {
            repeater(Lines)
            {
                ShowCaption = false;
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date when the posting of the apply general ledger entries was posted.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the original document type which will be applied.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry''s Document No.';
                }
                field("G/L Account No."; Rec."G/L Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the account that the entry has been posted to.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the entry.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Amount of the entry.';
                }
                field("Applied Amount CZA"; Rec."Applied Amount CZA")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the sum of the amounts in the Amount to Apply field.';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry number that is assigned to the entry.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Navigate)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Find Entries';
                Image = Navigate;
                Ellipsis = true;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ShortCutKey = 'Ctrl+Alt+Q';
                ToolTip = 'Find all entries and documents that exist for the document number and posting date on the selected entry or document.';

                trigger OnAction()
                begin
                    PageNavigate.SetDoc(Rec."Posting Date", Rec."Document No.");
                    PageNavigate.Run();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if Rec."Entry No." <> 0 then begin
            GLEntry := Rec;
            FindApplnEntriesDtldtLedgEntry();
            GLAccount.Get(Rec."G/L Account No.");
        end;
        Rec.MarkedOnly(true);
    end;

    var
        GLEntry: Record "G/L Entry";
        GLAccount: Record "G/L Account";
        PageNavigate: Page Navigate;

    procedure FindApplnEntriesDtldtLedgEntry()
    var
        SelectedOneDetailedGLEntryCZA: Record "Detailed G/L Entry CZA";
        SelectedTwoDetailedGLEntryCZA: Record "Detailed G/L Entry CZA";
    begin
        SelectedOneDetailedGLEntryCZA.SetCurrentKey("G/L Entry No.", "Posting Date");
        SelectedOneDetailedGLEntryCZA.SetRange("G/L Entry No.", GLEntry."Entry No.");
        SelectedOneDetailedGLEntryCZA.SetRange(Unapplied, false);
        if SelectedOneDetailedGLEntryCZA.FindSet() then
            repeat
                if SelectedOneDetailedGLEntryCZA."G/L Entry No." = SelectedOneDetailedGLEntryCZA."Applied G/L Entry No." then begin
                    SelectedTwoDetailedGLEntryCZA.SetRange("Applied G/L Entry No.", SelectedOneDetailedGLEntryCZA."Applied G/L Entry No.");
                    SelectedTwoDetailedGLEntryCZA.SetRange(Unapplied, false);
                    if SelectedTwoDetailedGLEntryCZA.FindSet() then
                        repeat
                            if SelectedTwoDetailedGLEntryCZA."G/L Entry No." <>
                               SelectedTwoDetailedGLEntryCZA."Applied G/L Entry No."
                            then
                                if Rec.Get(SelectedTwoDetailedGLEntryCZA."G/L Entry No.") then
                                    Rec.Mark(true);
                        until SelectedTwoDetailedGLEntryCZA.Next() = 0;
                end else
                    if Rec.Get(SelectedOneDetailedGLEntryCZA."Applied G/L Entry No.") then
                        Rec.Mark(true);
            until SelectedOneDetailedGLEntryCZA.Next() = 0;
    end;

    procedure Caption(): Text
    var
        CaptionTok: Label '%1 %2', Locked = true;
    begin
        exit(StrSubstNo(
            CaptionTok,
            GLAccount."No.",
            GLAccount.Name));
    end;
}

