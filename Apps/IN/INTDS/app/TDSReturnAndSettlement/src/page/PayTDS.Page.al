// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSReturnAndSettlement;

using Microsoft.Finance.TDS.TDSBase;
using Microsoft.Finance.GeneralLedger.Journal;

page 18746 "Pay TDS"
{
    Caption = 'Pay TDS';
    Editable = false;
    PageType = List;
    SourceTable = "TDS Entry";
    UsageCategory = Lists;
    ApplicationArea = Basic, Suite;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of account that TDS entry is linked to.';
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the vendor account that TDS entry is linked to.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting date of the TDS entry.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document type that the TDS entry belongs to.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies document number of the TDS entry.';
                }
                field("TDS Base Amount"; Rec."TDS Base Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'TDS Base Amount';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the entry, as assigned from the specified number series when the entry was created.';
                }
                field("Assessee Code"; Rec."Assessee Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the assessee code of the customer account that the TDS entry is linked to.';
                }
                field("TDS Paid"; Rec."TDS Paid")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the amount on the TDS entry is fully paid.';
                }
                field("Challan Date"; Rec."Challan Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the challan date for the TDS entry once TDS amount is paid to government.';
                }
                field("Challan No."; Rec."Challan No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the challan number for the TDS entry once TDS amount is paid to government.';
                }
                field("Bank Name"; Rec."Bank Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the bank account of the applied entry.';
                }
                field("TDS %"; Rec."TDS %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies TDS % on the TDS entry.';
                }
                field(Adjusted; Rec.Adjusted)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the TDS entry is adjusted.';
                }
                field("Adjusted TDS %"; Rec."Adjusted TDS %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies adjusted TDS % for the TDS Entry.';
                }
                field("Pay TDS Document No."; Rec."Pay TDS Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number of the TDS entry to be paid to government.';
                }
                field("Surcharge %"; Rec."Surcharge %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the surcharge % on the TDS entry.';
                }
                field("Surcharge Amount"; Rec."Surcharge Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the surcharge amount that the TDS entry is linked to.';
                }
                field("Concessional Code"; Rec."Concessional Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the applied concessional code that the TDS entry is linked to.';
                }
                field("Concessional Form No."; Rec."Concessional Form No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the applied concessional form on TDS entry.';
                }
                field("Invoice Amount"; Rec."Invoice Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the invoice amount that the TDS entry is linked to.';
                }
                field(Applied; Rec.Applied)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the TDS entry is applied.';
                }
                field("TDS Amount"; Rec."TDS Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the TDS Amount that the TDS entry is linked to.';
                }
                field("eCESS %"; Rec."eCESS %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the eCess % on TDS entry.';
                }
                field("eCESS Amount"; Rec."eCESS Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the eCess amount on TDS entry.';
                }
                field("SHE Cess %"; Rec."SHE Cess %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the SHE Cess % on TDS entry.';
                }
                field("SHE Cess Amount"; Rec."SHE Cess Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the SHE Cess amount on TDS entry.';
                }
                field("T.A.N. No."; Rec."T.A.N. No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'T.A.N. No.';
                    ToolTip = 'Specifies the T.A.N. number that the TDS entry is linked to.';
                }
                field(Reversed; Rec.Reversed)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the TDS entry has been reversed.';
                }
                field("Reversed by Entry No."; Rec."Reversed by Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry number by which the TDS entry has been reversed.';
                }
                field("Reversed Entry No."; Rec."Reversed Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry number for which the TDS entry has been reversed.';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the user who posted the TDS entry.';
                }
                field("Source Code"; Rec."Source Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the source code. Source code can be PURCHASES, SALES, GENJNL, BANKPYMT etc.';
                }
                field("Transaction No."; Rec."Transaction No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the transaction number of the posted entry.';
                }
                field("Party P.A.N. No."; Rec."Party P.A.N. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the P.A.N. number of the deductee.';
                }
                field("TDS Payment Date"; Rec."TDS Payment Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the P.A.N. number of the deductee.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("&Pay")
            {
                Caption = '&Pay';
                ToolTip = 'Click Pay to transfer the total of the selected entries to the amount field of payment journal.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ApplicationArea = Basic, Suite;
                Image = Payment;

                trigger OnAction()
                var
                    TDSEntry: Record "TDS Entry";
                    DocNo: Code[20];
                    TotalTDSAmount: Decimal;
                    TotalInvAmount: Decimal;
                    TotalCreditAmount: Decimal;
                begin
                    TotalTDSAmount := 0;
                    DocNo := GetGenJnlLineDocNo();

                    TDSEntry.SetRange("Pay TDS Document No.", DocNo);
                    TDSEntry.SetRange("TDS Paid", false);
                    if TDSEntry.FindSet() then
                        repeat
                            TDSEntry."Pay TDS Document No." := ' ';
                            TDSEntry.Modify();
                        until TDSEntry.Next() = 0;

                    TDSEntry.Copy(Rec);
                    if TDSEntry.FindSet() then
                        repeat
                            if not (TDSEntry."Document Type" = TDSEntry."Document Type"::"Credit Memo") then
                                TotalInvAmount := TotalInvAmount + TDSEntry."Bal. TDS Including SHE CESS"
                            else
                                TotalCreditAmount := TotalCreditAmount + TDSEntry."Bal. TDS Including SHE CESS";
                            TDSEntry."Pay TDS Document No." := DocNo;
                            TDSEntry.Modify();
                        until TDSEntry.Next() = 0;
                    TotalTDSAmount := TotalInvAmount - TotalCreditAmount;

                    UpdateGenJnlLineAmount(TotalTDSAmount);

                    CurrPage.Close();
                end;
            }
        }
    }

    var
        GenJournalLine: Record "Gen. Journal Line";
        BatchName: Code[10];
        TemplateName: Code[10];
        LineNo: Integer;

    procedure SetProperties(NewBatchName: Code[10]; NewTemplateName: Code[10]; NewLineNo: Integer)
    begin
        BatchName := NewBatchName;
        TemplateName := NewTemplateName;
        LineNo := NewLineNo;
    end;

    local procedure GetGenJnlLineDocNo(): Code[20]
    begin
        GenJournalLine.Reset();
        GenJournalLine.SetRange("Journal Template Name", TemplateName);
        GenJournalLine.SetRange("Journal Batch Name", BatchName);
        GenJournalLine.SetRange("Line No.", LineNo);
        if GenJournalLine.FindLast() then
            exit(GenJournalLine."Document No.");
    end;

    local procedure UpdateGenJnlLineAmount(Amount: Decimal)
    begin
        GenJournalLine.Reset();
        GenJournalLine.SetRange("Journal Template Name", TemplateName);
        GenJournalLine.SetRange("Journal Batch Name", BatchName);
        GenJournalLine.SetRange("Line No.", LineNo);
        if GenJournalLine.FindLast() then begin
            GenJournalLine.Amount := Amount;
            GenJournalLine.Validate("Debit Amount", Amount);
            GenJournalLine.Modify();
        end;
    end;
}
