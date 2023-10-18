// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSOnReceipt;

using Microsoft.Finance.TCS.TCSBase;
using Microsoft.Finance.GeneralLedger.Journal;

page 18906 "Pay TCS"
{
    Caption = 'Pay TCS';
    Editable = false;
    PageType = List;
    SourceTable = "TCS Entry";
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
                    ToolTip = 'Specifies the type of account that TCS entry is linked to.';
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the customer account that TCS entry is linked to.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting date of the TCS entry.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document type that the TCS entry belongs to.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies document number of the TCS entry.';
                }
                field("TCS Base Amount"; Rec."TCS Base Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the base amount on which TCS is being calculated.';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the entry, as assigned from the specified number series when the entry was created.';
                }
                field("TCS Nature of Collection"; Rec."TCS Nature of Collection")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Nature of Collection on which TCS is applied.';
                }
                field("Assessee Code"; Rec."Assessee Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the assessee code of the customer account that the TCS entry is linked to.';
                }
                field("TCS Paid"; Rec."TCS Paid")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    ToolTip = 'Specifies whether the amount on the TCS entry is fully paid.';
                }
                field("Challan Date"; Rec."Challan Date")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    ToolTip = 'Specifies the challan date for the TCS entry once TCS amount is paid to government.';
                }
                field("Challan No."; Rec."Challan No.")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    ToolTip = 'Specifies the challan number for the TCS entry once TCS amount is paid to government.';
                }
                field("Bank Name"; Rec."Bank Name")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    ToolTip = 'Specifies the bank account of the applied entry.';
                }
                field("TCS %"; Rec."TCS %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies TCS % on the TCS entry.';
                }
                field("Pay TCS Document No."; Rec."Pay TCS Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number of the TCS entry to be paid to government.';
                }
                field("Surcharge %"; Rec."Surcharge %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the surcharge % on the TCS entry.';
                }
                field("Surcharge Amount"; Rec."Surcharge Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the surcharge amount that the TCS entry is linked to.';
                }
                field("Concessional Code"; Rec."Concessional Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the applied concessional code that the TCS entry is linked to.';
                }
                field("Invoice Amount"; Rec."Invoice Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the invoice amount that the TCS entry is linked to.';
                }
                field("TCS Amount"; Rec."TCS Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the TCS Amount that the TCS entry is linked to.';
                }
                field("eCESS %"; Rec."eCESS %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the eCess % on TCS entry.';
                }
                field("eCESS Amount"; Rec."eCESS Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the eCess amount on TCS entry.';
                }
                field("SHE Cess %"; Rec."SHE Cess %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the SHE Cess % on TCS entry.';
                }
                field("SHE Cess Amount"; Rec."SHE Cess Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the SHE Cess amount on TCS entry.';
                }
                field("T.C.A.N. No."; Rec."T.C.A.N. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the T.C.A.N. number that the TCS entry is linked to.';
                }
                field("Customer P.A.N. No."; Rec."Customer P.A.N. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the PAN number of the Customer that the TCS entry is linked to.';
                }
                field("TCS Payment Date"; Rec."TCS Payment Date")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                    ToolTip = 'Specifies the date on which TCS is paid to the government.';
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
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ApplicationArea = Basic, Suite;
                Image = Payment;
                ToolTip = 'Click Pay to transfer the total of the selected entries to the amount field of payment journal.';

                trigger OnAction()
                var
                    TCSEntry: Record "TCS Entry";
                begin
                    ClearTCSAmount();
                    TCSEntry.SetRange("Pay TCS Document No.", GetGenJnlDocNo());
                    TCSEntry.SetRange("TCS Paid", false);
                    if TCSEntry.FindSet() then
                        TCSEntry.ModifyAll("Pay TCS Document No.", '');

                    TCSEntry.Copy(Rec);
                    if TCSEntry.FindSet() then
                        repeat
                            if not (TCSEntry."Document Type" = TCSEntry."Document Type"::"Credit Memo") then
                                TotalInvAmount := TotalInvAmount + TCSEntry."Bal. TCS Including SHE CESS"
                            else
                                TotalCreditAmount := TotalCreditAmount + TCSEntry."Bal. TCS Including SHE CESS";
                            TCSEntry."Pay TCS Document No." := GetGenJnlDocNo();
                            TCSEntry.Modify();
                        until TCSEntry.Next() = 0;
                    TotalTCSAmount := TotalInvAmount - TotalCreditAmount;
                    UpdateGenJnlAmounts();
                    CurrPage.Close();
                end;
            }
        }
    }

    var
        BatchName: Code[10];
        TemplateName: Code[10];
        LineNo: Integer;
        TotalTCSAmount: Decimal;
        TotalInvAmount: Decimal;
        TotalCreditAmount: Decimal;

    procedure SetProperties(NewBatchName: Code[10]; NewTemplateName: Code[10]; NewLineNo: Integer)
    begin
        BatchName := NewBatchName;
        TemplateName := NewTemplateName;
        LineNo := NewLineNo;
    end;

    local procedure GetGenJnlDocNo(): Code[20]
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        SetFiltersOnGenJnlLine(GenJournalLine);
        if GenJournalLine.FindLast() then
            exit(GenJournalLine."Document No.");
    end;

    local procedure UpdateGenJnlAmounts()
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        SetFiltersOnGenJnlLine(GenJournalLine);
        if GenJournalLine.FindLast() then begin
            GenJournalLine.Amount := TotalTCSAmount;
            GenJournalLine.Validate("Debit Amount", TotalTCSAmount);
            GenJournalLine.Modify();
        end;
    end;

    local procedure SetFiltersOnGenJnlLine(var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine.SetRange("Journal Template Name", TemplateName);
        GenJournalLine.SetRange("Journal Batch Name", BatchName);
        GenJournalLine.SetRange("Line No.", LineNo);
    end;

    local procedure ClearTCSAmount()
    begin
        TotalTCSAmount := 0;
    end;
}
