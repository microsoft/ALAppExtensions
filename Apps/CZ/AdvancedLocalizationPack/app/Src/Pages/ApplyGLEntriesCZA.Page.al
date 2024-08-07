// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Ledger;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Foundation.Navigate;

page 31284 "Apply G/L Entries CZA"
{
    Caption = 'Apply General Ledger Entries';
    DataCaptionFields = "G/L Account No.";
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Worksheet;
    Permissions = tabledata "G/L Entry" = m;
    SourceTable = "G/L Entry";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(TempApplyingGLEntryPostingDateField; TempGLEntry."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posting Date';
                    Editable = false;
                    ToolTip = 'Specifies the entry''s Posting Date.';
                }
                field(TempApplyingGLEntryDocumentTypeField; TempGLEntry."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Document Type';
                    Editable = false;
                    ToolTip = 'Specifies the original document type which will be applied.';
                }
                field(TempApplyingGLEntryDocumentNoField; TempGLEntry."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Document No.';
                    Editable = false;
                    ToolTip = 'Specifies the entry''s Document No.';
                }
                field(TempApplyingGLEntryGLAccountNoField; TempGLEntry."G/L Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'G/L Account No.';
                    Editable = false;
                    ToolTip = 'Specifies the number of the account that the entry has been posted to.';
                }
                field(TempApplyingGLEntryDescriptionField; TempGLEntry.Description)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Description';
                    Editable = false;
                    ToolTip = 'Specifies the description of the entry.';
                }
                field(TempApplyingGLEntryAmountField; TempGLEntry.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Amount';
                    Editable = false;
                    ToolTip = 'Specifies the amount to apply.';
                }
                field(ApplyingRemainingAmountField; ApplyingRemainingAmount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Remaining Amount';
                    Editable = false;
                    ToolTip = 'Specifies the remaining amount of general ledger entries';
                }
            }
            repeater(Lines)
            {
                ShowCaption = false;
                field("Applies-to ID"; Rec."Applies-to ID CZA")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ID to apply to the general ledger entry.';

                    trigger OnValidate()
                    begin
                        AppliestoIDOnAfterValidate();
                    end;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the date when the posting of the apply general ledger entries will be recorded.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the original document type which will be applied.';
                    Visible = false;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the entry''s Document No.';
                }
                field("G/L Account No."; Rec."G/L Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the number of the account that the entry has been posted to.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the description of the entry to be applied.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the amount of the entry.';
                }
                field("Amount to Apply"; Rec."Amount to Apply CZA")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount to apply.';

                    trigger OnValidate()
                    begin
                        AmounttoApplyOnAfterValidate();
                    end;
                }
                field("Applying Entry"; Rec."Applying Entry CZA")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies that the general ledger entry is an applying entry.';
                    Visible = false;
                }
                field("Applied Amount"; Rec."Applied Amount CZA")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the applied amount for the general ledger entry.';
                }
                field(RemainingAmountField; Remaining)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Remaining Amount';
                    ToolTip = 'Specifies the remaining amount of general ledger entries';
                    Visible = false;
                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the code for the Gen. Bus. Posting Group that applies to the entry.';
                    Visible = false;
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the code for the Gen. Prod. Posting Group that applies to the entry.';
                    Visible = false;
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies a VAT business posting group code.';
                    Visible = false;
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies a VAT product posting group code for the VAT Statement.';
                    Visible = false;
                }
            }
            group(Amounts)
            {
                ShowCaption = false;
                fixed(AmountFields)
                {
                    ShowCaption = false;
                    group(AmmountToApply)
                    {
                        Caption = 'Amount to Apply';
                        field(ApplyingAmountField; ApplyingAmount)
                        {
                            ApplicationArea = Basic, Suite;
                            AutoFormatType = 1;
                            Caption = 'Amount to Apply';
                            Editable = false;
                            ShowCaption = false;
                            ToolTip = 'Specifies the apply amount for the general ledger entry.';
                        }
                    }
                    group(AvailableAmount)
                    {
                        Caption = 'Available Amount';
                        field(AvailableAmountField; AvailableAmount)
                        {
                            ApplicationArea = Basic, Suite;
                            AutoFormatType = 1;
                            Caption = 'Available Amount';
                            Editable = false;
                            ToolTip = 'Specifies the amount of the journal entry that you have selected as the applying entry.';
                        }
                    }
                    group(Balance)
                    {
                        Caption = 'Balance';
                        field(AvailableAmountPlusApplyingAmountField; AvailableAmount + ApplyingAmount)
                        {
                            ApplicationArea = Basic, Suite;
                            AutoFormatType = 1;
                            Caption = 'Balance';
                            Editable = false;
                            ToolTip = 'Specifies the description of the entry to be applied.';
                        }
                    }
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Entry)
            {
                Caption = 'Entry';
                action("Applied E&ntries")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Applied E&ntries';
                    Image = Approve;
                    RunObject = Page "Applied G/L Entries CZA";
                    RunPageOnRec = true;
                    ToolTip = 'Specifies the apllied entries.';
                }
                action(Dimensions)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';
                    ToolTip = 'View the dimension sets that are set up for the entry.';

                    trigger OnAction()
                    begin
                        Rec.ShowDimensions();
                    end;
                }
                action("Detailed &Ledger Entries")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Detailed &Ledger Entries';
                    Image = View;
                    RunObject = Page "Detailed G/L Entries CZA";
                    RunPageLink = "G/L Entry No." = Field("Entry No.");
                    RunPageView = sorting("G/L Entry No.", "Posting Date");
                    ShortCutKey = 'Ctrl+F7';
                    ToolTip = 'Specifies the detailed ledger entries of the entry.';
                }
            }
            group(Application)
            {
                Caption = 'Application';
                action("Set Applying Entry")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Set Applying Entry';
                    Image = Line;
                    ShortCutKey = 'Shift+F11';
                    ToolTip = 'Sets applying entry';

                    trigger OnAction()
                    var
                        TEntryNo: Integer;
                    begin
                        if GenJnlLineApply then
                            exit;

                        TEntryNo := Rec."Entry No.";
                        if TempGLEntry."Entry No." <> 0 then
                            RemoveApplyingGLEntry();
                        SetApplyingGLEntry(TEntryNo);
                    end;
                }
                action("Remove Applying Entry")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Remove Applying Entry';
                    Image = CancelLine;
                    ShortCutKey = 'Ctrl+F11';
                    ToolTip = 'Removes applying entry';

                    trigger OnAction()
                    begin
                        if GenJnlLineApply then
                            exit;

                        RemoveApplyingGLEntry();
                    end;
                }
                action("Set Applies-to ID")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Set Applies-to ID';
                    Image = SelectLineToApply;
                    ShortCutKey = 'F7';
                    ToolTip = 'Sets applies to id';

                    trigger OnAction()
                    begin
                        SetAppliesToID();
                    end;
                }
                action("Post Application")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Post Application';
                    Ellipsis = true;
                    Image = PostApplication;
                    ShortCutKey = 'F9';
                    ToolTip = 'This batch job posts G/L entries application.';

                    trigger OnAction()
                    var
                        CompareOneGLEntry: Record "G/L Entry";
                        CompareTwoGLEntry: Record "G/L Entry";
                    begin
                        if CalcType <> CalcType::GenJnlLine then begin
                            if TempGLEntry."Entry No." <> 0 then begin
                                CompareTwoGLEntry.Get(TempGLEntry."Entry No.");
                                CompareTwoGLEntry.CalcFields("Applied Amount CZA");
                                Commit();
                                GLEntryPostApplicationCZA.PostApplyGLEntry(TempGLEntry);
                                CurrPage.Update(false);
                                CompareOneGLEntry.Get(TempGLEntry."Entry No.");
                                CompareOneGLEntry.CalcFields("Applied Amount CZA");
                                if CompareTwoGLEntry."Applied Amount CZA" <> CompareOneGLEntry."Applied Amount CZA" then
                                    RemoveApplyingGLEntry();
                            end else
                                Error(AppEntryNeedErr);
                        end else
                            Error(AppFromWindowErr);
                    end;
                }
                action("Show Only Selected Entries to Be Applied")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Show Only Selected Entries to Be Applied';
                    Image = ShowSelected;
                    ToolTip = 'View the selected ledger entries that will be applied to the specified record. ';

                    trigger OnAction()
                    begin
                        ShowAppliedEntries := not ShowAppliedEntries;
                        if ShowAppliedEntries then
                            Rec.SetRange("Applies-to ID CZA", GLApplID)
                        else
                            Rec.SetRange("Applies-to ID CZA");
                    end;
                }
            }
        }
        area(processing)
        {
            action(Navigate)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Find Entries';
                Image = Navigate;
                Ellipsis = true;
                ShortCutKey = 'Ctrl+Alt+Q';
                ToolTip = 'Find all entries and documents that exist for the document number and posting date on the selected entry or document.';

                trigger OnAction()
                begin
                    PageNavigate.SetDoc(Rec."Posting Date", Rec."Document No.");
                    PageNavigate.Run();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(Navigate_Promoted; Navigate)
                {
                }
                actionref("Set Applies-to ID_Promoted"; "Set Applies-to ID")
                {
                }
                actionref("Post Application_Promoted"; "Post Application")
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Applied Amount CZA");
        Remaining := Rec.Amount - Rec."Applied Amount CZA";
    end;

    trigger OnClosePage()
    var
        ApplyGLEntry: Record "G/L Entry";
    begin
        ShowAppliedEntries := false;
        if not PostingDone then begin
            ApplyGLEntry := TempGLEntry;
            if ApplyGLEntry.FindFirst() then
                GLEntryPostApplicationCZA.SetApplyingGLEntry(ApplyGLEntry, false, '');
        end;
    end;

    trigger OnOpenPage()
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.Get(Rec.GetFilter("G/L Account No."));
        PostingDone := false;

        if CalcType = CalcType::GenJnlLine then begin
            case ApplnType of
                ApplnType::"Applies-to Doc. No.":
                    GLApplID := GenJournalLine."Applies-to Doc. No.";
                ApplnType::"Applies-to ID":
                    GLApplID := GenJournalLine."Applies-to ID";
            end;
            CalcApplnAmount();
        end else
            FindApplyingGLEntry();
    end;

    var
        GenJournalLine: Record "Gen. Journal Line";
        PageNavigate: Page Navigate;
        ShowAppliedEntries: Boolean;
        GLApplID: Code[50];
        Remaining: Decimal;
        ApplEntryNo: Integer;
        PostingDone: Boolean;
        GenJnlLineApply: Boolean;
        ApplnType: Option " ","Applies-to Doc. No.","Applies-to ID";
        CalcType: Option Direct,GenJnlLine;
        AppEntryNeedErr: Label 'You must select an applying entry before posting the application.';
        AppFromWindowErr: Label 'You must post the application from the window where you entered the applying entry.';

    protected var
        TempGLEntry: Record "G/L Entry" temporary;
        GLEntry: Record "G/L Entry";
        GLEntryPostApplicationCZA: Codeunit "G/L Entry Post Application CZA";
        ApplyingRemainingAmount: Decimal;
        ApplyingAmount: Decimal;
        AvailableAmount: Decimal;

    local procedure FindApplyingGLEntry()
    begin
        GLApplID := CopyStr(UserId(), 1, MaxStrLen(GLApplID));
        if GLApplID = '' then
            GLApplID := '***';

        if ApplEntryNo <> 0 then begin
            SetApplyingGLEntry(ApplEntryNo);
            ApplEntryNo := 0;
        end else begin
            GLEntry.SetCurrentKey("G/L Account No.", "Posting Date");
            GLEntry.SetRange("G/L Account No.", Rec."G/L Account No.");
            GLEntry.SetRange("Applies-to ID CZA", GLApplID);
            GLEntry.SetRange("Closed CZA", false);
            GLEntry.SetRange("Applying Entry CZA", true);
            if GLEntry.FindFirst() then
                SetApplyingGLEntry(GLEntry."Entry No.");
        end;
        CalcApplnAmount();
    end;

    local procedure SetApplyingGLEntry(EntryNo: Integer)
    begin
        Rec.Get(EntryNo);
        GLEntryPostApplicationCZA.SetApplyingGLEntry(Rec, true, GLApplID);
        if Rec.Amount > 0 then
            Rec.SetFilter(Amount, '<0')
        else
            Rec.SetFilter(Amount, '>0');
        OnSetApplyingGLEntryByEntryNoOnAfterSetFilters(Rec, GLEntryPostApplicationCZA);
        Rec."Applying Entry CZA" := true;
        Rec.Modify();

        TempGLEntry := Rec;
        Rec.SetCurrentKey("Entry No.");
        Rec.SetFilter("Entry No.", '<> %1', Rec."Entry No.");
        AvailableAmount := Rec.Amount - Rec."Applied Amount CZA";
        ApplyingRemainingAmount := Rec.Amount - Rec."Applied Amount CZA";
        CalcApplnAmount();
        Rec.SetCurrentKey("G/L Account No.");
    end;

    local procedure RemoveApplyingGLEntry()
    begin
        if Rec.Get(TempGLEntry."Entry No.") then begin
            GLEntryPostApplicationCZA.SetApplyingGLEntry(Rec, false, '');
            Rec.SetRange(Amount);
            Rec."Applying Entry CZA" := false;
            Rec.Modify();

            Clear(TempGLEntry);
            Rec.SetCurrentKey("Entry No.");
            Rec.SetRange("Entry No.");
            AvailableAmount := 0;
            ApplyingRemainingAmount := 0;
            CalcApplnAmount();
        end;
    end;

    local procedure SetAppliesToID()
    begin
        GLEntry.Reset();
        GLEntry.Copy(Rec);
        CurrPage.SetSelectionFilter(GLEntry);
        if GLEntry.FindSet(true) then
            repeat
                SetApplyingGLEntry(GLEntry, false, GLApplID);
            until GLEntry.Next() = 0;
        Rec := GLEntry;
        CalcApplnAmount();
        CurrPage.Update(false);
    end;

    local procedure SetApplyingGLEntry(var GLEntry2: Record "G/L Entry"; IsApplyingEntry: Boolean; AppliesToID: Code[50])
    var
        IsHandled: Boolean;
    begin
        OnBeforeSetApplyingGLEntry(GLEntry2, IsApplyingEntry, AppliesToID, GLEntryPostApplicationCZA, IsHandled);
        if IsHandled then
            exit;
        GLEntryPostApplicationCZA.SetApplyingGLEntry(GLEntry2, false, GLApplID);
    end;

    procedure CalcApplnAmount()
    begin
        ApplyingAmount := 0;
        GLEntry.Reset();
        GLEntry.Copy(Rec);
        GLEntry.SetRange("Applies-to ID CZA", GLApplID);
        GLEntry.CalcSums("Amount to Apply CZA");
        ApplyingAmount := GLEntry."Amount to Apply CZA";
    end;

    procedure CheckAppliesToID(var GLEntry2: Record "G/L Entry")
    begin
        if GLEntry2."Applies-to ID CZA" <> '' then begin
            GLApplID := CopyStr(UserId, 1, MaxStrLen(GLApplID));
            if GLApplID = '' then
                GLApplID := '***';
            GLEntry2.TestField("Applies-to ID CZA", GLApplID);
        end;
    end;

    local procedure AppliestoIDOnAfterValidate()
    begin
        if (Rec."Applies-to ID CZA" = GLApplID) and (Rec."Amount to Apply CZA" = 0) then
            SetAppliesToID();

        if Rec."Applies-to ID CZA" = '' then begin
            Rec."Applies-to ID CZA" := '';
            Rec."Amount to Apply CZA" := 0;
            Rec.Modify();
        end;
    end;

    local procedure AmounttoApplyOnAfterValidate()
    begin
        if Rec."Amount to Apply CZA" <> 0 then
            Rec."Applies-to ID CZA" := GLApplID
        else
            Rec."Applies-to ID CZA" := '';
        Rec.Modify();
        CalcApplnAmount();
    end;

    procedure SetAplEntry(ApplEntryNo1: Integer)
    begin
        ApplEntryNo := ApplEntryNo1;
    end;

    procedure SetGenJnlLine(NewGenJournalLine: Record "Gen. Journal Line"; ApplnTypeSelect: Integer)
    begin
        GenJournalLine := NewGenJournalLine;
        GenJnlLineApply := true;

        if GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::"G/L Account" then
            ApplyingAmount := -GenJournalLine.Amount;
        if GenJournalLine."Account Type" = GenJournalLine."Account Type"::"G/L Account" then
            ApplyingAmount := GenJournalLine.Amount;

        CalcType := CalcType::GenJnlLine;

        case ApplnTypeSelect of
            GenJournalLine.FieldNo("Applies-to Doc. No."):
                ApplnType := ApplnType::"Applies-to Doc. No.";
            GenJournalLine.FieldNo("Applies-to ID"):
                ApplnType := ApplnType::"Applies-to ID";
        end;

        TempGLEntry."Entry No." := 1;
        TempGLEntry."Posting Date" := GenJournalLine."Posting Date";
        TempGLEntry."Document Type" := GenJournalLine."Document Type";
        TempGLEntry."Document No." := GenJournalLine."Document No.";
        TempGLEntry."G/L Account No." := GenJournalLine."Account No.";
        TempGLEntry.Description := GenJournalLine.Description;
        TempGLEntry.Amount := GenJournalLine.Amount;
        ApplyingRemainingAmount := GenJournalLine.Amount;
        CalcApplnAmount();
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSetApplyingGLEntry(var GLEntry: Record "G/L Entry"; IsApplyingEntry: Boolean; AppliesToID: Code[50]; var GLEntryPostApplicationCZA: Codeunit "G/L Entry Post Application CZA"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnSetApplyingGLEntryByEntryNoOnAfterSetFilters(var GLEntry: Record "G/L Entry"; var GLEntryPostApplicationCZA: Codeunit Microsoft.Finance.GeneralLedger.Posting."G/L Entry Post Application CZA")
    begin
    end;
}
