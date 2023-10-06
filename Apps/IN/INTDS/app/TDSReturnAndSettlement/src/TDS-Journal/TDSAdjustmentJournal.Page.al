// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSReturnAndSettlement;

using Microsoft.Finance.TDS.TDSBase;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Foundation.NoSeries;
using Microsoft.Foundation.AuditCodes;

page 18747 "TDS Adjustment Journal"
{
    AutoSplitKey = true;
    Caption = 'TDS Adjustment Journal';
    DataCaptionFields = "Journal Batch Name";
    DelayedInsert = true;
    PageType = Worksheet;
    SaveValues = false;
    SourceTable = "TDS Journal Line";
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
                    ToolTip = 'Specifies the name of the tax journal batch.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        TDSJnlManagement.LookupNameTax(CurrentJnlBatchName, Rec);
                    end;

                    trigger OnValidate()
                    begin
                        TDSJnlManagement.CheckNameTax(CurrentJnlBatchName, Rec);
                        CurrentJnlBatchNameOnAfterVali();
                    end;
                }
                field("Transaction No"; TransactionNo)
                {
                    Caption = 'Transaction No';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the transaction number of the posted entry.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        TDSEntry: Record "TDS Entry";
                        TDSEntriesList: Page "TDS Entries";
                    begin
                        TDSEntry.Reset();
                        TDSEntry.SetRange("TDS Paid", false);
                        TDSEntry.SetFilter("TDS Base Amount", '<>%1', 0);
                        if not TDSEntry.IsEmpty() then
                            TDSEntriesList.SetTableView(TDSEntry);
                        TDSEntriesList.LookupMode(true);
                        if TDSEntriesList.RunModal() = Action::LookupOK then begin
                            TDSEntriesList.GetRecord(TDSEntry);
                            TransactionNo := TDSEntry."Entry No.";
                            InsertTDSJnlLine(TransactionNo);
                        end;
                    end;

                    trigger OnValidate()
                    begin
                        InsertTDSJnlLine(TransactionNo);
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
                field("Document Date"; Rec."Document Date")
                {
                    Visible = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the creation date of the the entry';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of document of the entry on the adjustment journal line.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies document number for the adjustment journal.';
                }
                field("Assessee Code"; Rec."Assessee Code")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the assessee code for the entry on the journal line.';
                }
                field("TDS Section Code"; Rec."TDS Section Code")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the TDS section code for the entry on the journal line.';
                }
                field("TDS Base Amount"; Rec."TDS Base Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total base amount including (TDS) on the adjustment journal line.';
                }
                field("TDS Base Amount Applied"; Rec."TDS Base Amount Applied")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the TDS base amount to be applied on the adjustment journal line.';
                }
                field("TDS %"; Rec."TDS %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the TDS % of the TDS entry the journal line is linked to.';
                }
                field("TDS % Applied"; Rec."TDS % Applied")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the TDS % to be applied on the adjustment journal line.';
                }
                field("Surcharge %"; Rec."Surcharge %")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the surcharge % of the TDS entry the journal line is linked to.';
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
                    ToolTip = 'Specifies the eCess % of the TDS entry the journal line is linked to.';
                }
                field("eCESS % Applied"; Rec."eCESS % Applied")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the eCess % to be applied on the adjustment journal line.';
                }
                field("SHE Cess %"; Rec."SHE Cess %")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the SHE Cess % of the TDS entry the journal line is linked to.';
                }
                field("SHE Cess % Applied"; Rec."SHE Cess % Applied")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the SHE Cess % to be applied on the adjustment journal line.';
                }
                field("Bal. TDS Including SHECESS"; Rec."Bal. TDS Including SHE CESS")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the balance TDS including SHE Cess on the adjustment journal line.';
                }
                field("Debit Amount"; Rec."Debit Amount")
                {
                    Caption = 'TDS Deducted';
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the TDS deducted to be adjusted on the journal line.';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    ToolTip = 'Displays the external document number entered in the purchase/sales document/journal bank charges Line.';
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of account that the entry on the adjustment journal line to be posted to.';

                    trigger OnValidate()
                    begin
                        TDSJnlManagement.GetAccountsTax(Rec, AccName, BalAccName);
                    end;
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the account number that the entry on the adjustment journal line to be posted to.';

                    trigger OnValidate()
                    begin
                        TDSJnlManagement.GetAccountsTax(Rec, AccName, BalAccName);
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
                    ToolTip = 'Specifies the total of amount including adjustment amount on the adjustment journal.';
                }
                field("Bal. Account Type"; Rec."Bal. Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the balancing account type that should be used in adjustment journal line.';
                }
                field("Bal. Account No."; Rec."Bal. Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of balancing account type to which the balancing entry on the journal line will be posted.';

                    trigger OnValidate()
                    begin
                        TDSJnlManagement.GetAccountsTax(Rec, AccName, BalAccName);
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
                    ToolTip = 'View or edit dimensions that you can assign to sales and purchase documents to distribute costs and analyze transaction history. (Alt+D)';
                    ApplicationArea = Basic, Suite;
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';

                    trigger OnAction()
                    begin
                        Rec.ShowDimensions();
                        CurrPage.SaveRecord();
                    end;
                }
            }
            group("A&ccount")
            {
                Caption = 'A&ccount';
                Image = ChartOfAccounts;
                ToolTip = 'View or change detailed information about the record on the document or journal line. (Shift +F7)';

                action(Card)
                {
                    Caption = 'Card';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'View or change detailed information about the record on the document or journal line. (Shift +F7)';
                    Image = EditLines;
                    RunObject = Codeunit "Gen. Jnl.-Show Card";
                    ShortCutKey = 'Shift+F7';
                }
                action("Ledger E&ntries")
                {
                    Caption = 'Ledger E&ntries';
                    ToolTip = 'View the history of transactions that have been posted for the selected record. (Ctrl + F7)';
                    ApplicationArea = Basic, Suite;
                    Image = LedgerEntries;
                    RunObject = Codeunit "Gen. Jnl.-Show Entries";
                    ShortCutKey = 'Ctrl+F7';
                }
            }
        }
        area(processing)
        {
            group("P&osting")
            {
                Caption = 'P&osting';
                Image = Post;
                ToolTip = 'Click Pay to transfer the total of the selected entries to the amount field of payment journal.';

                action("P&ost")
                {
                    Caption = 'P&ost';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Finalize the document or journal by posting the amounts and quantities to the related accounts in your company books. (F9)';
                    Image = Post;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = F9;

                    trigger OnAction()
                    var
                        TDSAdjPost: Codeunit "TDS Adjustment Post";
                    begin
                        TDSAdjPost.PostTaxJournal(Rec);
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
            TDSJnlManagement.OpenTaxJnl(CurrentJnlBatchName, Rec);
            exit
        end;
        TDSJnlManagement.TaxTemplateSelection(Page::"TDS Adjustment Journal", Rec, JnlSelected);
        if not JnlSelected then
            Error('');
        TDSJnlManagement.OpenTaxJnl(CurrentJnlBatchName, Rec);
    end;

    var
        TDSJnlManagement: Codeunit "TDS Jnl Management";
        TransactionNo: Integer;
        CurrentJnlBatchName: Code[10];
        ShortcutDimCode: array[8] of Code[20];
        BalAccName: Text[100];
        AccName: Text[100];
        OpenedFromBatch: Boolean;

    local procedure CurrentJnlBatchNameOnAfterVali()
    begin
        CurrPage.SAVERECORD();
        TDSJnlManagement.SetNameTax(CurrentJnlBatchName, Rec);
        CurrPage.Update(false);
    end;

    local procedure AfterGetCurrentRecord()
    begin
        xRec := Rec;
        TDSJnlManagement.GetAccountsTax(Rec, AccName, BalAccName);
    end;

    local procedure InsertTDSJnlLine(TransactionNo: Integer)
    var
        GetTDSEntry: Record "TDS Entry";
        TDSJournalLine: Record "TDS Journal Line";
        TDSJournalBatch: Record "TDS Journal Batch";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        DocumentNo: Code[20];
        LineNo: Integer;
    begin
        TDSJournalBatch.Get(Rec."Journal Template Name", Rec."Journal Batch Name");
        if TDSJournalBatch."No. Series" <> '' then begin
            Clear(NoSeriesManagement);
            DocumentNo := NoSeriesManagement.TryGetNextNo(TDSJournalBatch."No. Series", Rec."Posting Date");
        end;
        TDSJournalLine.LockTable();
        TDSJournalLine.SetRange("Journal Template Name", Rec."Journal Template Name");
        TDSJournalLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
        if TDSJournalLine.FindLast() then
            LineNo := TDSJournalLine."Line No." + 10000
        else
            LineNo := 10000;

        GetTDSEntry.Get(TransactionNo);
        if GetTDSEntry."TDS Base Amount" <> 0 then
            InsertTDSJnlLineWithTDSAmt(TDSJournalLine, GetTDSEntry, DocumentNo, LineNo);
    end;

    local procedure InsertTDSJnlLineWithTDSAmt(
        TDSJournalLine: Record "TDS Journal Line";
        TDSEntry: Record "TDS Entry";
        DocumentNo: Code[20];
        LineNo: Integer)
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.Get();
        SourceCodeSetup.TestField("TDS Adjustment Journal");
        TDSJournalLine.Init();
        TDSJournalLine."Document No." := DocumentNo;
        TDSJournalLine."Journal Template Name" := Rec."Journal Template Name";
        TDSJournalLine."Journal Batch Name" := Rec."Journal Batch Name";
        TDSJournalLine."Line No." := LineNo;
        TDSJournalLine.Adjustment := true;
        TDSJournalLine."Posting Date" := WorkDate();
        TDSJournalLine."Account Type" := TDSJournalLine."Account Type"::Vendor;
        TDSJournalLine."Account No." := TDSEntry."Vendor No.";
        TDSJournalLine."TDS Section Code" := TDSEntry.Section;
        TDSJournalLine."Document Type" := TDSEntry."Document Type";
        TDSJournalLine."Concessional Code" := TDSEntry."Concessional Code";
        TDSJournalLine."Per Contract" := TDSEntry."Per Contract";
        TDSJournalLine."Assessee Code" := TDSEntry."Assessee Code";
        TDSJournalLine."TDS Base Amount" := Abs(TDSEntry."TDS Base Amount");
        TDSJournalLine."Surcharge Base Amount" := Abs(TDSEntry."Surcharge Base Amount");
        TDSJournalLine."eCESS Base Amount" := Abs(TDSEntry."TDS Amount Including Surcharge");
        TDSJournalLine."SHE Cess Base Amount" := Abs(TDSEntry."TDS Amount Including Surcharge");
        if TDSEntry.Adjusted then begin
            TDSJournalLine."TDS %" := TDSEntry."Adjusted TDS %";
            TDSJournalLine."Surcharge %" := TDSEntry."Adjusted Surcharge %";
            TDSJournalLine."eCESS %" := TDSEntry."Adjusted eCESS %";
            TDSJournalLine."SHE Cess %" := TDSEntry."Adjusted SHE CESS %"
        end else begin
            TDSJournalLine."TDS %" := TDSEntry."TDS %";
            TDSJournalLine."Surcharge %" := TDSEntry."Surcharge %";
            TDSJournalLine."eCESS %" := TDSEntry."eCESS %";
            TDSJournalLine."SHE Cess %" := TDSEntry."SHE Cess %";
        end;
        TDSJournalLine."Debit Amount" := TDSEntry."Total TDS Including SHE CESS";
        TDSJournalLine."TDS Amount" := TDSEntry."TDS Amount";
        TDSJournalLine."Surcharge Amount" := TDSEntry."Surcharge Amount";
        TDSJournalLine."eCESS on TDS Amount" := TDSEntry."eCESS Amount";
        TDSJournalLine."SHE Cess on TDS Amount" := TDSEntry."SHE Cess Amount";
        TDSJournalLine."Bal. Account No." := TDSEntry."Account No.";
        TDSJournalLine."TDS Invoice No." := TDSEntry."Document No.";
        TDSJournalLine."TDS Transaction No." := TDSEntry."Entry No.";
        TDSJournalLine."T.A.N. No." := TDSEntry."T.A.N. No.";
        TDSJournalLine."Document Type" := TDSJournalLine."Document Type"::" ";
        TDSJournalLine."Bal. TDS Including SHE CESS" := TDSEntry."Bal. TDS Including SHE CESS";
        TDSJournalLine."Source Code" := SourceCodeSetup."TDS Adjustment Journal";
        TDSJournalLine.Insert();
        CurrPage.Update(false);
    end;
}
