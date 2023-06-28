#pragma implicitwith disable
page 2629 "Stat. Acc. Reverse Entries"
{
    Caption = 'Reverse Entries';
    DataCaptionExpression = Rec.Caption();
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Reversal Entry";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Transaction No."; Rec."Transaction No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the number of the transaction that was reversed.';
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the account number that the reversal was posted to.';
                }
                field("Account Name"; Rec."Account Name")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies erroneous postings that you want to undo by using the Reverse function.';
                    Visible = false;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = false;
                    Editable = false;
                    ToolTip = 'Specifies the number of the entry, as assigned from the specified number series when the entry was created.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ClosingDates = true;
                    Editable = false;
                    ToolTip = 'Specifies the posting date for the entry.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = DescriptionEditable;
                    ToolTip = 'Specifies a description of the record.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the document number of the transaction that created the entry.';
                }
                field("Journal Batch Name"; Rec."Journal Batch Name")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the name of the journal batch, a personalized journal layout, that the entries were posted from.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the amount on the entry to be reversed.';
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("Ent&ry")
            {
                Caption = 'Ent&ry';
                Image = Entry;
                action(StatisticalAccountLedgerEntries)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Statistical Account Ledger';
                    Image = GLRegisters;
                    ToolTip = 'View the postings you have made in the statistical account ledger.';

                    trigger OnAction()
                    var
                        StatisticalLedgerEntryList: Page "Statistical Ledger Entry List";
                    begin
                        StatisticalLedgerEntryList.Run();
                    end;
                }
            }
        }
        area(processing)
        {
            group("Re&versing")
            {
                Caption = 'Re&versing';
                Image = Restore;
                action(Reverse)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Reverse';
                    Image = Undo;
                    ShortCutKey = 'F9';
                    ToolTip = 'Reverse selected entries.';

                    trigger OnAction()
                    var
                        StatAccReverseEntry: Codeunit "Stat. Acc. Reverse Entry";
                    begin
                        StatAccReverseEntry.PostReversal(Rec);
                        Message(ReversalSuccesfullMsg);
                        CurrPage.Close();
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process', Comment = 'Generated from the PromotedActionCategories property index 1.';

                actionref(Reverse_Promoted; Reverse)
                {
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        DescriptionEditable := Rec."Entry Type" <> Rec."Entry Type"::VAT;
    end;

    trigger OnInit()
    begin
        DescriptionEditable := true;
    end;

    trigger OnOpenPage()
    begin
        InitializeFilter();
    end;

    var
        ReversalEntry: Record "Reversal Entry";
        [InDataSet]
        DescriptionEditable: Boolean;
        ReverseTransactionEntriesLbl: Label 'Reverse Transaction Entries';
        ReverseRegisterEntriesLbl: Label 'Reverse Register Entries';
        ReversalSuccesfullMsg: Label 'The entries were successfully reversed.';

    internal procedure SetReversalEntries(var TempReversalEntry: Record "Reversal Entry" temporary)
    begin
        if not TempReversalEntry.FindSet() then
            exit;
        repeat
            Clear(Rec);
            Rec.Copy(TempReversalEntry);
            Rec.Insert();
        until TempReversalEntry.Next() = 0;
    end;

    local procedure InitializeFilter()
    begin
        Rec.FindFirst();
        Rec."Entry Type" := Rec."Entry Type"::"Statistical Account";
        ReversalEntry := Rec;
        if Rec."Reversal Type" = Rec."Reversal Type"::Transaction then begin
            CurrPage.Caption := ReverseTransactionEntriesLbl;
            ReversalEntry.SetReverseFilter(Rec."Transaction No.", Rec."Reversal Type");
        end else begin
            CurrPage.Caption := ReverseRegisterEntriesLbl;
            ReversalEntry.SetReverseFilter(Rec."G/L Register No.", Rec."Reversal Type");
        end;
    end;
}

#pragma implicitwith restore

