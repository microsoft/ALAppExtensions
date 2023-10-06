// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSReturnAndSettlement;

using Microsoft.Finance.TCS.TCSBase;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Foundation.NoSeries;
using Microsoft.Foundation.AuditCodes;

page 18870 "TCS Adjustment Journal"
{
    AutoSplitKey = true;
    Caption = 'TCS Adjustment Journal';
    DataCaptionFields = "Journal Batch Name";
    DelayedInsert = true;
    PageType = Worksheet;
    SaveValues = false;
    SourceTable = "TCS Journal Line";
    UsageCategory = Tasks;
    ApplicationArea = Basic, Suite;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("Current Jnl Batch Name"; CurrentJnlBatchName)
                {
                    Caption = 'Batch Name';
                    Lookup = true;
                    Visible = true;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the current journal batch';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        TCSAdjustment.LookupNameTCS(CurrentJnlBatchName, Rec);
                    end;

                    trigger OnValidate()
                    begin
                        TCSAdjustment.CheckNameTCS(CurrentJnlBatchName, Rec);
                        CurrentJnlBatchNameOnAfterVali();
                    end;
                }
                field("Transaction No"; TransactionNo)
                {
                    BlankZero = true;
                    Caption = 'Transaction No';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the transaction number that the TCS entry is linked to.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        TCSEntry: Record "TCS Entry";
                    begin
                        TCSEntry.Reset();
                        TCSEntry.SetRange("TCS Paid", false);
                        TCSEntry.SetFilter("TCS Amount", '<>%1', 0);
                        if not TCSEntry.IsEmpty() then
                            if Page.RunModal(Page::"TCS Entries", TCSEntry) = Action::LookupOK then
                                TransactionNo := TCSEntry."Entry No.";
                        InsertTCSAdjJnlOnTransactionNo();
                    end;

                    trigger OnValidate()
                    begin
                        InsertTCSAdjJnlOnTransactionNo();
                    end;
                }
            }
            repeater(Line)
            {
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting date for the entry.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of document that the entry on the adjustment journal line is.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies document number for the adjustment journal line.';
                }
                field("Assessee Code"; Rec."Assessee Code")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the assessee code of the entry on the adjustment journal line.';
                }
                field("TCS Base Amount"; Rec."TCS Base Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total base amount including (TCS) on the adjustment journal line.';
                }
                field("TCS %"; Rec."TCS %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the TCS % of the TCS entry the journal line is linked to.';
                }
                field("TCS % Applied"; Rec."TCS % Applied")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the TCS % to be applied on the adjustment journal line.';
                }
                field("Surcharge %"; Rec."Surcharge %")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the surcharge % of the TCS entry the journal line is linked to.';
                }
                field("Surcharge % Applied"; Rec."Surcharge % Applied")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the surcharge % to be applied on the adjustment journal line.';
                }
                field("eCESS %"; Rec."eCESS %")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the eCess % of the TCS entry the journal line is linked to.';
                }
                field("eCESS % Applied"; Rec."eCESS % Applied")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the eCess % to be applied on the adjustment journal line.';
                }
                field("SHE Cess % on TCS"; Rec."SHE Cess % on TCS")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the SHE Cess % of the TCS entry the journal line is linked to.';
                }
                field("SHE Cess % Applied"; Rec."SHE Cess % Applied")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the SHE Cess % to be applied on the adjustment journal line.';
                }
                field("TCS Base Amount Applied"; Rec."TCS Base Amount Applied")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the TCS base amount to be applied on the adjustment journal line.';
                }
                field("T.C.A.N. No."; Rec."T.C.A.N. No.")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the T.C.A.N. number on the adjustment journal line.';
                }
                field("Debit Amount"; Rec."Debit Amount")
                {
                    Caption = 'TCS Collected';
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the TCS collected to be adjusted on the adjustment journal line.';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    ToolTip = 'Specifies the external document number that the TCS entry is linked to.';
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of account that the entry on the adjustment journal line to be posted to.';

                    trigger OnValidate()
                    begin
                        TCSAdjustment.GetAccountsTCS(Rec, AccName, BalAccName);
                    end;
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the account number that the entry on the adjustment journal line to be posted to.';

                    trigger OnValidate()
                    begin
                        TCSAdjustment.GetAccountsTCS(Rec, AccName, BalAccName);
                        Rec.ShowShortcutDimCode(ShortcutDimCode);
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description on adjustment journal line to be adjusted.';
                }
                field(Amount; Rec.Amount)
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total of amount including adjustment on the adjustment journal to be posted to.';
                }
                field("Bal. Account Type"; Rec."Bal. Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the balancing account type that should be used in adjustment journal line.';
                }
                field("Bal. Account No."; Rec."Bal. Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of balancing account type to which the balancing entry for the journal line will be posted.';

                    trigger OnValidate()
                    begin
                        TCSAdjustment.GetAccountsTCS(Rec, AccName, BalAccName);
                        Rec.ShowShortcutDimCode(ShortcutDimCode);
                    end;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;

                action(Dimensions)
                {
                    Caption = 'Dimensions';
                    ApplicationArea = Basic, Suite;
                    Image = Dimensions;
                    ShortCutKey = 'Alt+D';
                    ToolTip = 'View or edit dimensions that you can be assigned to sales and purchase documents to distribute costs and analyze transaction history (Alt+D).';

                    trigger OnAction()
                    begin
                        Rec.ShowDimensions();
                        CurrPage.SAVERECORD();
                    end;
                }
            }
            group("A&ccount")
            {
                Caption = 'A&ccount';
                Image = ChartOfAccounts;

                action(Card)
                {
                    Caption = 'Card';
                    ApplicationArea = Basic, Suite;
                    Image = EditLines;
                    RunObject = Codeunit "Gen. Jnl.-Show Card";
                    ShortCutKey = 'Shift+F7';
                    ToolTip = 'View or change detailed information about the record on the document or journal line (Shift +F7).';
                }
                action("Ledger E&ntries")
                {
                    Caption = 'Ledger E&ntries';
                    Image = LedgerEntries;
                    ApplicationArea = Basic, Suite;
                    RunObject = Codeunit "Gen. Jnl.-Show Entries";
                    ShortCutKey = 'Ctrl+F7';
                    ToolTip = 'View the history of transactions that have been posted for the selected record (Ctrl + F7).';
                }
            }
        }
        area(processing)
        {
            group("P&osting")
            {
                Caption = 'P&osting';
                Image = Post;

                action("P&ost")
                {
                    Caption = 'P&ost';
                    ApplicationArea = Basic, Suite;
                    Image = Post;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';
                    ToolTip = 'Finalize the document or journal by posting the amounts and quantities to the related accounts in your company books (F9).';

                    trigger OnAction()
                    var
                        TCSTCSJnlManagement: Codeunit "Post-TCS Jnl. Line";
                    begin
                        TCSTCSJnlManagement.PostTCSJournal(Rec);
                        CurrentJnlBatchName := Rec.GetRangeMax("Journal Batch Name");
                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.ShowShortcutDimCode(ShortcutDimCode);
        AfterGetCurrentRecord();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.SetUpNewLine(xRec, false);
        Clear(ShortcutDimCode);
        Clear(AccName);
        AfterGetCurrentRecord();
    end;

    trigger OnOpenPage()
    var
        JnlSelected: Boolean;
    begin
        BalAccName := '';
        OpenedFromBatch := (Rec."Journal Batch Name" <> '') and (Rec."Journal Template Name" = '');
        if OpenedFromBatch then begin
            CurrentJnlBatchName := Rec."Journal Batch Name";
            TCSAdjustment.OpenTCSJnl(CurrentJnlBatchName, Rec);
            exit;
        end;
        TCSAdjustment.TCSTemplateSelection(Page::"TCS Adjustment Journal", Rec, JnlSelected);
        if not JnlSelected then
            Error('');
        TCSAdjustment.OpenTCSJnl(CurrentJnlBatchName, Rec);
    end;

    var
        TCSAdjustment: Codeunit "TCS Adjustment";
        TransactionNo: Integer;
        CurrentJnlBatchName: Code[10];
        ShortcutDimCode: array[8] of Code[20];
        BalAccName: Text[100];
        AccName: Text[100];
        OpenedFromBatch: Boolean;

    local procedure CurrentJnlBatchNameOnAfterVali()
    begin
        CurrPage.SAVERECORD();
        TCSAdjustment.SetNameTCS(CurrentJnlBatchName, Rec);
        CurrPage.Update(false);
    end;

    local procedure AfterGetCurrentRecord()
    begin
        xRec := Rec;
        TCSAdjustment.GetAccountsTCS(Rec, AccName, BalAccName);
    end;

    local procedure GetDocumentNo(): Code[20]
    var
        TCSJournalBatch: Record "TCS Journal Batch";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        TCSJournalBatch.Get(Rec."Journal Template Name", Rec."Journal Batch Name");
        if TCSJournalBatch."No. Series" <> '' then begin
            Clear(NoSeriesManagement);
            exit(NoSeriesManagement.TryGetNextNo(TCSJournalBatch."No. Series", Rec."Posting Date"));
        end;
    end;

    local procedure GetTCSJnlLineNo(): Integer
    var
        TCSJournalLine: Record "TCS Journal Line";
    begin
        TCSJournalLine.LockTable();
        TCSJournalLine.SetRange("Journal Template Name", Rec."Journal Template Name");
        TCSJournalLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
        if TCSJournalLine.FindLast() then
            exit(TCSJournalLine."Line No." + 10000)
        else
            exit(10000);
    end;

    local procedure InsertTCSAdjJnlOnTransactionNo()
    var
        TCSJournalLine: Record "TCS Journal Line";
        TCSEntry: Record "TCS Entry";
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.Get();
        SourceCodeSetup.TestField("TCS Adjustment Journal");
        TCSEntry.Get(TransactionNo);
        TCSJournalLine.Init();
        TCSJournalLine."Document No." := GetDocumentNo();
        TCSJournalLine."Journal Template Name" := Rec."Journal Template Name";
        TCSJournalLine."Journal Batch Name" := Rec."Journal Batch Name";
        TCSJournalLine."Line No." := GetTCSJnlLineNo();
        TCSJournalLine.Adjustment := true;
        TCSJournalLine."Posting Date" := WorkDate();
        TCSJournalLine."Account Type" := TCSJournalLine."Account Type"::Customer;
        TCSJournalLine.Validate("Account No.", TCSEntry."Customer No.");
        TCSJournalLine."Document Type" := TCSEntry."Document Type";
        TCSJournalLine.Description := TCSEntry.Description;
        TCSJournalLine."TCS Nature of Collection" := TCSEntry."TCS Nature of Collection";
        TCSJournalLine."Assessee Code" := TCSEntry."Assessee Code";
        TCSJournalLine."TCS Base Amount" := Abs(TCSEntry."TCS Base Amount");
        TCSJournalLine."Surcharge Base Amount" := Abs(TCSEntry."Surcharge Base Amount");
        TCSJournalLine."eCESS Base Amount" := Abs(TCSEntry."TCS Amount Including Surcharge");
        TCSJournalLine."SHE Cess Base Amount" := Abs(TCSEntry."TCS Amount Including Surcharge");
        if TCSEntry.Adjusted then begin
            TCSJournalLine."TCS %" := TCSEntry."Adjusted TCS %";
            TCSJournalLine."Surcharge %" := TCSEntry."Adjusted Surcharge %";
            TCSJournalLine."eCESS %" := TCSEntry."Adjusted eCESS %";
            TCSJournalLine."SHE Cess % on TCS" := TCSEntry."Adjusted SHE CESS %";
        end
        else begin
            TCSJournalLine."TCS %" := TCSEntry."TCS %";
            TCSJournalLine."Surcharge %" := TCSEntry."Surcharge %";
            TCSJournalLine."eCESS %" := TCSEntry."eCESS %";
            TCSJournalLine."SHE Cess % on TCS" := TCSEntry."SHE Cess %";
        end;
        TCSJournalLine."Debit Amount" := TCSEntry."Total TCS Including SHE CESS";
        TCSJournalLine."TCS Amount" := TCSEntry."TCS Amount";
        TCSJournalLine."Surcharge Amount" := TCSEntry."Surcharge Amount";
        TCSJournalLine."eCESS on TCS Amount" := TCSEntry."eCESS Amount";
        TCSJournalLine."SHE Cess on TCS Amount" := TCSEntry."SHE Cess Amount";
        TCSJournalLine."Bal. Account No." := TCSEntry."Account No.";
        TCSJournalLine."TCS Invoice No." := TCSEntry."Document No.";
        TCSJournalLine."TCS Transaction No." := TCSEntry."Entry No.";
        TCSJournalLine."T.C.A.N. No." := TCSEntry."T.C.A.N. No.";
        TCSJournalLine."Document Type" := TCSJournalLine."Document Type"::" ";
        TCSJournalLine."Source Code" := SourceCodeSetup."TCS Adjustment Journal";
        TCSJournalLine.Insert();
        CurrPage.Update(false);
    end;
}
