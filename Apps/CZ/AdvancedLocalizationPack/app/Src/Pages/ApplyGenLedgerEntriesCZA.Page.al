// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Ledger;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Foundation.Navigate;

page 31287 "Apply Gen. Ledger Entries CZA"
{
    Caption = 'Apply General Ledger Entries';
    DataCaptionFields = "G/L Account No.";
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = Worksheet;
    SourceTable = "G/L Entry";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(ApplyingGLEntryPostingDate; TempApplyingGLEntry."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posting Date';
                    Editable = false;
                    ToolTip = 'Specifies the entry''s Posting Date.';
                }
                field(ApplyingGLEntryDocumentType; TempApplyingGLEntry."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Document Type';
                    Editable = false;
                    ToolTip = 'Specifies the original document type which will be applied.';
                }
                field(ApplyingGLEntryDocumentNo; TempApplyingGLEntry."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Document No.';
                    Editable = false;
                    ToolTip = 'Specifies the entry''s Document No.';
                }
                field(ApplyingGLEntryGLAccountNo; TempApplyingGLEntry."G/L Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'G/L Account No.';
                    Editable = false;
                    ToolTip = 'Specifies the number of the account that the entry has been posted to.';
                }
                field(ApplyingGLEntryDescription; TempApplyingGLEntry.Description)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Description';
                    Editable = false;
                    ToolTip = 'Specifies the description of the entry.';
                }
                field(ApplyingGLEntryAmount; TempApplyingGLEntry.Amount)
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
                    RunPageLink = "G/L Entry No." = field("Entry No.");
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
                    Visible = not GenJnlLineApply;
                    Image = Line;
                    ShortCutKey = 'Shift+F11';
                    ToolTip = 'Sets applying entry';

                    trigger OnAction()
                    begin
                        if GenJnlLineApply then
                            exit;

                        if TempApplyingGLEntry."Entry No." <> 0 then
                            RemoveApplyingGLEntry();
                        SetApplyingGLEntry(Rec."Entry No.");
                    end;
                }
                action("Remove Applying Entry")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Remove Applying Entry';
                    Visible = not GenJnlLineApply;
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
                    Visible = not GenJnlLineApply;
                    Ellipsis = true;
                    Image = PostApplication;
                    ShortCutKey = 'F9';
                    ToolTip = 'This batch job posts G/L entries application.';

                    trigger OnAction()
                    var
                        CompareOneGLEntry: Record "G/L Entry";
                        CompareTwoGLEntry: Record "G/L Entry";
                    begin
                        if not GenJnlLineApply then begin
                            if TempApplyingGLEntry."Entry No." <> 0 then begin
                                CompareTwoGLEntry.Get(TempApplyingGLEntry."Entry No.");
                                CompareTwoGLEntry.CalcFields("Applied Amount CZA");
                                WriteToDatabase();
                                WriteToDatabase(TempApplyingGLEntry."Entry No.");

                                GLEntryPostApplicationCZA.PostApplyGLEntry(TempApplyingGLEntry);
                                RefreshFromDatabase();
                                CurrPage.Update(false);
                                CompareOneGLEntry.Get(TempApplyingGLEntry."Entry No.");
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
                            Rec.SetRange("Applies-to ID CZA", AppliesToID)
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
                actionref("Set Applies-to ID_Promoted"; "Set Applies-to ID")
                {
                }
                actionref("Post Application_Promoted"; "Post Application")
                {
                }
                actionref("Show Only Selected Entries to Be Applied_Promoted"; "Show Only Selected Entries to Be Applied")
                {
                }
            }
            group(Category_Category5)
            {
                Caption = 'Entry';

                actionref(Navigate_Promoted; Navigate)
                {
                }
                actionref(Dimensions_Promoted; Dimensions)
                {
                }
                actionref("Applied E&ntries_Promoted"; "Applied E&ntries")
                {
                }
                actionref("Detailed &Ledger Entries_Promoted"; "Detailed &Ledger Entries")
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Remaining := Rec.Amount - Rec."Applied Amount CZA";
    end;

    trigger OnClosePage()
    begin
        ShowAppliedEntries := false;
        WriteToDatabase();
    end;

    trigger OnOpenPage()
    var
        GLAccount: Record "G/L Account";
    begin
        if Rec.GetFilter("G/L Account No.") <> '' then
            GLAccount.Get(Rec.GetFilter("G/L Account No."));

        if GenJnlLineApply then
            CalcApplyingAmount()
        else
            FindApplyingGLEntry();
    end;

    var
        PageNavigate: Page Navigate;
        ShowAppliedEntries: Boolean;
        AppliesToID: Code[50];
        Remaining: Decimal;
        ApplyingEntryNo: Integer;
        GenJnlLineApply: Boolean;
        AppEntryNeedErr: Label 'You must select an applying entry before posting the application.';
        AppFromWindowErr: Label 'You must post the application from the window where you entered the applying entry.';
        ApplyingAmount: Decimal;

    protected var
        GLEntry: Record "G/L Entry";
        TempApplyingGLEntry: Record "G/L Entry" temporary;
        TempModifiedGLEntry: Record "G/L Entry" temporary;
        GLEntryPostApplicationCZA: Codeunit "G/L Entry Post Application CZA";
        ApplyingRemainingAmount: Decimal;
        AvailableAmount: Decimal;

    procedure SetApplyingEntry(NewApplyingEntryNo: Integer)
    begin
        ApplyingEntryNo := NewApplyingEntryNo;
    end;

    procedure SetGenJournalLine(NewGenJournalLine: Record "Gen. Journal Line")
    begin
        GenJnlLineApply := true;
        AppliesToID := NewGenJournalLine."Applies-to ID";

        if NewGenJournalLine."Bal. Account Type" = NewGenJournalLine."Bal. Account Type"::"G/L Account" then
            ApplyingAmount := -NewGenJournalLine.Amount;
        if NewGenJournalLine."Account Type" = NewGenJournalLine."Account Type"::"G/L Account" then
            ApplyingAmount := NewGenJournalLine.Amount;

        TempApplyingGLEntry."Entry No." := 1;
        TempApplyingGLEntry."Posting Date" := NewGenJournalLine."Posting Date";
        TempApplyingGLEntry."Document Type" := NewGenJournalLine."Document Type";
        TempApplyingGLEntry."Document No." := NewGenJournalLine."Document No.";
        TempApplyingGLEntry."G/L Account No." := NewGenJournalLine."Account No.";
        TempApplyingGLEntry.Description := NewGenJournalLine.Description;
        TempApplyingGLEntry.Amount := NewGenJournalLine.Amount;
        ApplyingRemainingAmount := NewGenJournalLine.Amount;
        CalcApplyingAmount();
    end;

    procedure InsertEntry(var NewGLEntry: Record "G/L Entry")
    begin
        NewGLEntry.FindSet();
        Rec.Copy(NewGLEntry);
        repeat
            Rec := NewGLEntry;
            if not Rec."Closed CZA" then // there is a performance reason why it is not in the filter
                Rec.Insert();
        until NewGLEntry.Next() = 0;
    end;

    local procedure FindApplyingGLEntry()
    begin
        AppliesToID := Rec.GetDefaultAppliesToID();

        if ApplyingEntryNo <> 0 then begin
            SetApplyingGLEntry(ApplyingEntryNo);
            ApplyingEntryNo := 0;
        end else begin
            GLEntry.SetCurrentKey("G/L Account No.", "Posting Date");
            GLEntry.SetRange("G/L Account No.", Rec."G/L Account No.");
            GLEntry.SetRange("Applies-to ID CZA", AppliesToID);
            GLEntry.SetRange("Closed CZA", false);
            GLEntry.SetRange("Applying Entry CZA", true);
            if GLEntry.FindFirst() then
                SetApplyingGLEntry(GLEntry."Entry No.");
        end;
        CalcApplyingAmount();
    end;

    local procedure SetApplyingGLEntry(EntryNo: Integer)
    begin
        Rec.Get(EntryNo);
        GLEntryPostApplicationCZA.SetApplyingGLEntry(Rec, true, AppliesToID);
        if Rec.Amount > 0 then
            Rec.SetFilter(Amount, '<0')
        else
            Rec.SetFilter(Amount, '>0');
        OnSetApplyingGLEntryByEntryNoOnAfterSetFilters(Rec, GLEntryPostApplicationCZA);
        Rec."Applying Entry CZA" := true;
        Rec.Modify();

        TempApplyingGLEntry := Rec;
        Rec.SetCurrentKey("Entry No.");
        Rec.SetFilter("Entry No.", '<> %1', Rec."Entry No.");
        AvailableAmount := Rec.Amount - Rec."Applied Amount CZA";
        ApplyingRemainingAmount := Rec.Amount - Rec."Applied Amount CZA";
        CalcApplyingAmount();
        Rec.SetCurrentKey("G/L Account No.");

        if TempModifiedGLEntry.Get(TempApplyingGLEntry."Entry No.") then
            TempModifiedGLEntry.Delete();
    end;

    local procedure RemoveApplyingGLEntry()
    begin
        if Rec.Get(TempApplyingGLEntry."Entry No.") then begin
            GLEntryPostApplicationCZA.SetApplyingGLEntry(Rec, false, '');
            Rec.SetRange(Amount);
            Rec."Applying Entry CZA" := false;
            Rec.Modify();

            Clear(TempApplyingGLEntry);
            Rec.SetCurrentKey("Entry No.");
            Rec.SetRange("Entry No.");
            AvailableAmount := 0;
            ApplyingRemainingAmount := 0;
            CalcApplyingAmount();
        end;
    end;

    local procedure SetAppliesToID()
    var
        TempGLEntry: Record "G/L Entry" temporary;
    begin
        TempGLEntry.Copy(Rec, true);
        CurrPage.SetSelectionFilter(TempGLEntry);
        if TempGLEntry.FindSet() then
            repeat
                Rec := TempGLEntry;
                SetApplyingGLEntry(Rec, false, AppliesToID);
            until TempGLEntry.Next() = 0;
        CalcApplyingAmount();
    end;

    local procedure SetApplyingGLEntry(var ApplyingGLEntry: Record "G/L Entry"; IsApplyingEntry: Boolean; AppliesToID: Code[50])
    var
        IsHandled: Boolean;
    begin
        OnBeforeSetApplyingGLEntry(ApplyingGLEntry, IsApplyingEntry, AppliesToID, GLEntryPostApplicationCZA, IsHandled);
        if IsHandled then
            exit;
        GLEntryPostApplicationCZA.SetApplyingGLEntry(ApplyingGLEntry, false, AppliesToID);
        SaveSourceRecord();
    end;

    local procedure CalcApplyingAmount()
    var
        TempGLEntry: Record "G/L Entry" temporary;
    begin
        ApplyingAmount := 0;
        TempGLEntry.Copy(Rec, true);
        TempGLEntry.SetRange("Applies-to ID CZA", AppliesToID);
        TempGLEntry.CalcSums("Amount to Apply CZA");
        ApplyingAmount := TempGLEntry."Amount to Apply CZA";
        CurrPage.Update(false);
    end;

    local procedure AppliestoIDOnAfterValidate()
    begin
        if (Rec."Applies-to ID CZA" = AppliesToID) and (Rec."Amount to Apply CZA" = 0) then
            SetAppliesToID();

        if Rec."Applies-to ID CZA" = '' then begin
            Rec."Applies-to ID CZA" := '';
            Rec."Amount to Apply CZA" := 0;
            ModifySourceRecord();
        end;
    end;

    local procedure AmounttoApplyOnAfterValidate()
    begin
        if Rec."Amount to Apply CZA" <> 0 then
            Rec."Applies-to ID CZA" := AppliesToID
        else
            Rec."Applies-to ID CZA" := '';
        ModifySourceRecord();
        CalcApplyingAmount();
    end;

    local procedure ModifySourceRecord()
    begin
        Rec.Modify();
        SaveSourceRecord();
    end;

    local procedure SaveSourceRecord()
    begin
        if not TempModifiedGLEntry.Get(Rec."Entry No.") then begin
            TempModifiedGLEntry := Rec;
            TempModifiedGLEntry.Insert();
        end;
    end;

    local procedure WriteToDatabase()
    begin
        TempModifiedGLEntry.Reset();
        if TempModifiedGLEntry.FindSet() then
            repeat
                WriteToDatabase(TempModifiedGLEntry."Entry No.");
            until TempModifiedGLEntry.Next() = 0;
    end;

    local procedure WriteToDatabase(EntryNo: Integer)
    begin
        Rec.Get(EntryNo);
        Codeunit.Run(Codeunit::"G/L Entry-Edit", Rec);
    end;

    local procedure RefreshFromDatabase()
    var
        TempGLEntry: Record "G/L Entry" temporary;
    begin
        TempModifiedGLEntry.SetRange("Applies-to ID CZA", TempApplyingGLEntry."Applies-to ID CZA");
        TempModifiedGLEntry.DeleteAll();

        TempGLEntry.Copy(Rec, true);
        TempGLEntry.SetRange("Applies-to ID CZA", TempApplyingGLEntry."Applies-to ID CZA");
        if TempGLEntry.FindSet() then
            repeat
                GLEntry.Get(TempGLEntry."Entry No.");
                Rec := GLEntry;
                if GLEntry."Closed CZA" then
                    Rec.Delete()
                else
                    Rec.Modify();
            until TempGLEntry.Next() = 0;
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
