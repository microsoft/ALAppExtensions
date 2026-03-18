// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Foundation.Navigate;

page 10848 "Payment Slip Subform FR"
{
    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Payment Line FR";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of account that the payment line will be posted to.';

                    trigger OnValidate()
                    begin
                        BankInfoEditable := IsBankInfoEditable();
                    end;
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    Style = Strong;
                    StyleExpr = AccountNoEmphasize;
                    ToolTip = 'Specifies the number of the account that the entry on the journal line will be posted to.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a document number for the payment line.';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a document number that refers to the customer''s or vendor''s numbering system.';
                    Visible = false;
                }
                field("Drawee Reference"; Rec."Drawee Reference")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the file reference which will be used in the electronic payment (ETEBAC) file.';
                }
                field("Posting Group"; Rec."Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting group associated with the account.';
                    Visible = false;
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the due date on the entry.';
                }
                field("Debit Amount"; Rec."Debit Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total amount (including VAT) of the payment line, if it is a debit amount.';
                    Visible = DebitAmountVisible;
                }
                field("Credit Amount"; Rec."Credit Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total amount (including VAT) of the payment line, if it is a credit amount.';
                    Visible = CreditAmountVisible;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total amount (including VAT) of the payment line.';
                    Visible = AmountVisible;
                    AutoFormatType = 1;
                }
                field(IBAN; Rec.IBAN)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = BankInfoEditable;
                    ToolTip = 'Specifies the international bank account number (IBAN) for the payment slip.';
                }
                field("SWIFT Code"; Rec."SWIFT Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = BankInfoEditable;
                    ToolTip = 'Specifies the international bank identification code for the payment slip.';
                }
                field("Bank Account Code"; Rec."Bank Account Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code of the customer or vendor bank account that you want to perform the payment to, or collection from.';
                    Visible = BankAccountCodeVisible;
                }
                field("Acceptation Code"; Rec."Acceptation Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies an acceptation code for the payment line.';
                    Visible = AcceptationCodeVisible;
                }
                field("Payment Address Code"; Rec."Payment Address Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a code for the payment address of the customer or vendor.';
                }
                field("Bank Branch No."; Rec."Bank Branch No.")
                {
                    ApplicationArea = All;
                    Editable = BankInfoEditable;
                    ToolTip = 'Specifies the branch number of the bank account.';
                    Visible = RIBVisible;
                }
                field("Agency Code"; Rec."Agency Code")
                {
                    ApplicationArea = All;
                    Editable = BankInfoEditable;
                    ToolTip = 'Specifies the agency code of the bank account.';
                    Visible = RIBVisible;
                }
                field("Bank Account No."; Rec."Bank Account No.")
                {
                    ApplicationArea = All;
                    Editable = BankInfoEditable;
                    ToolTip = 'Specifies the number of the customer or vendor bank account that you want to perform the payment to, or collection from.';
                    Visible = RIBVisible;
                }
                field("Bank Account Name"; Rec."Bank Account Name")
                {
                    ApplicationArea = All;
                    Editable = BankInfoEditable;
                    ToolTip = 'Specifies the name of the bank account as entered in the Bank Account Code field.';
                    Visible = RIBVisible;
                }
                field("Bank City"; Rec."Bank City")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = BankInfoEditable;
                    ToolTip = 'Specifies the city of the bank account.';
                    Visible = false;
                }
                field("RIB Key"; Rec."RIB Key")
                {
                    ApplicationArea = All;
                    Editable = BankInfoEditable;
                    ToolTip = 'Specifies the two-digit RIB key associated with the Bank Account No. RIB key value in range from 01 to 09 is represented in the single-digit form, without leading zero digit.';
                    Visible = RIBVisible;
                }
                field("RIB Checked"; Rec."RIB Checked")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies that the key entered in the RIB Key field is correct.';
                    Visible = RIBVisible;
                }
                field("Has Payment Export Error"; Rec."Has Payment Export Error")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that an error occurred when you used the Export Payments to File function in the Payment Slip window.';
                }
                field("Direct Debit Mandate ID"; Rec."Direct Debit Mandate ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the direct debit mandate of the customer who made this payment.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("Set Document ID")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Set Document ID';
                    Image = Documents;
                    ToolTip = 'Fill in the document number of the entry in the payment slip.';

                    trigger OnAction()
                    begin
                        SetDocumentID();
                    end;
                }
            }
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action(Application)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = '&Application';
                    ShortCutKey = 'Shift+F11';
                    Image = ApplicationWorksheet;
                    ToolTip = 'Apply the customer or vendor payment on the selected payment slip line.';

                    trigger OnAction()
                    begin
                        ApplyPayment();
                    end;
                }
                action(Dimensions)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';
                    ToolTip = 'View or change the dimension settings for this payment slip. If you change the dimension, you can update all lines on the payment slip.';

                    trigger OnAction()
                    begin
                        Rec.ShowDimensions();
                    end;
                }
                action(Modify)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Modify';
                    Image = EditFilter;
                    ToolTip = 'View and edit information in the document associated with the line on the payment slip.';

                    trigger OnAction()
                    begin
                        OnModify();
                    end;
                }
                action(Insert)
                {
                    ApplicationArea = Basic, Suite;
                    Image = Insert;
                    Caption = 'Insert';
                    ToolTip = 'Insert the payment line.';

                    trigger OnAction()
                    begin
                        OnInsert();
                    end;
                }
                action(Remove)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Remove';
                    Image = Cancel;
                    ToolTip = 'Remove the payment line.';

                    trigger OnAction()
                    begin
                        OnDelete();
                    end;
                }
                group("A&ccount")
                {
                    Caption = 'A&ccount';
                    Image = ChartOfAccounts;
                    action(Card)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Card';
                        Image = EditLines;
                        ShortCutKey = 'Shift+F7';
                        ToolTip = 'Open the card for the entity on the selected line to view more details.';

                        trigger OnAction()
                        begin
                            ShowAccount();
                        end;
                    }
                    action("Ledger E&ntries")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Ledger E&ntries';
                        ShortCutKey = 'Ctrl+F7';
                        Image = LedgerEntries;
                        ToolTip = 'View details about ledger entries for the vendor account.';

                        trigger OnAction()
                        begin
                            ShowEntries();
                        end;
                    }
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ActivateControls();
        BankInfoEditable := IsBankInfoEditable();
        AccountNoEmphasize := Rec."Copied To No." <> '';
    end;

    trigger OnInit()
    begin
        BankAccountCodeVisible := true;
        CreditAmountVisible := true;
        DebitAmountVisible := true;
        AmountVisible := true;
        AcceptationCodeVisible := true;
        RIBVisible := true;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.SetUpNewLine(xRec, BelowxRec);
    end;

    var
        Header: Record "Payment Header FR";
        Status: Record "Payment Status FR";
        Navigate: Page Navigate;
        Text000Lbl: Label 'Assign No. ?';
        Text001Lbl: Label 'There is no line to modify.';
        Text002Lbl: Label 'A posted line cannot be modified.';
        Text003Lbl: Label 'You cannot assign numbers to a posted header.';
        AccountNoEmphasize: Boolean;
        AcceptationCodeVisible: Boolean;
        AmountVisible: Boolean;
        BankAccountCodeVisible: Boolean;
        BankInfoEditable: Boolean;
        CreditAmountVisible: Boolean;
        DebitAmountVisible: Boolean;
        RIBVisible: Boolean;

    local procedure ApplyPayment()
    begin
        CODEUNIT.Run(CODEUNIT::"Payment-Apply FR", Rec);
    end;

    local procedure DisableFields()
    begin
        if Header.Get(Rec."No.") then
            CurrPage.Editable((Header."Status No." = 0) and (Rec."Copied To No." = ''));
    end;

    local procedure OnModify()
    var
        PaymentLine: Record "Payment Line FR";
        PaymentModification: Page "Payment Line Modification FR";
    begin
        if Rec."Line No." = 0 then
            Message(Text001Lbl)
        else
            if not Rec.Posted then begin
                PaymentLine.Copy(Rec);
                PaymentLine.SetRange("No.", Rec."No.");
                PaymentLine.SetRange("Line No.", Rec."Line No.");
                PaymentModification.SetTableView(PaymentLine);
                PaymentModification.RunModal();
            end else
                Message(Text002Lbl);
    end;

    local procedure OnInsert()
    var
        PaymentManagement: Codeunit "Payment Management FR";
    begin
        PaymentManagement.LinesInsert(Rec."No.");
    end;

    local procedure OnDelete()
    var
        StatementLine: Record "Payment Line FR";
        PostingStatement: Codeunit "Payment Management FR";
    begin
        StatementLine.Copy(Rec);
        CurrPage.SetSelectionFilter(StatementLine);
        PostingStatement.DeleteLigBorCopy(StatementLine);
    end;

    local procedure SetDocumentID()
    var
        StatementLine: Record "Payment Line FR";
        No: Code[20];
    begin
        if Rec."Status No." <> 0 then begin
            Message(Text003Lbl);
            exit;
        end;
        if Confirm(Text000Lbl) then begin
            CurrPage.SetSelectionFilter(StatementLine);
            StatementLine.MarkedOnly(true);
            if not StatementLine.Find('-') then
                StatementLine.MarkedOnly(false);
            if StatementLine.Find('-') then begin
                No := StatementLine."Document No.";
                while StatementLine.Next() <> 0 do begin
                    No := IncStr(No);
                    StatementLine."Document No." := No;
                    StatementLine.Modify();
                end;
            end;
        end;
    end;

    local procedure ShowAccount()
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        GenJnlLine."Account Type" := Rec."Account Type";
        GenJnlLine."Account No." := Rec."Account No.";
        CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Show Card", GenJnlLine);
    end;

    local procedure ShowEntries()
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        GenJnlLine."Account Type" := Rec."Account Type";
        GenJnlLine."Account No." := Rec."Account No.";
        CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Show Entries", GenJnlLine);
    end;


    procedure MarkLines(ToMark: Boolean)
    var
        LineCopy: Record "Payment Line FR";
        NumLines: Integer;
    begin
        if ToMark then begin
            CurrPage.SetSelectionFilter(LineCopy);
            NumLines := LineCopy.Count();
            if NumLines > 0 then begin
                LineCopy.Find('-');
                repeat
                    LineCopy.Marked := true;
                    LineCopy.Modify();
                until LineCopy.Next() = 0;
            end else
                LineCopy.Reset();
            LineCopy.SetRange("No.", Rec."No.");
            LineCopy.ModifyAll(Marked, true);
        end else begin
            LineCopy.SetRange("No.", Rec."No.");
            LineCopy.ModifyAll(Marked, false);
        end;
        Commit();
    end;

    local procedure ActivateControls()
    begin
        if Header.Get(Rec."No.") then begin
            Status.Get(Header."Payment Class", Header."Status No.");
            RIBVisible := Status.RIB;
            AcceptationCodeVisible := Status."Acceptation Code";
            AmountVisible := Status.Amount;
            DebitAmountVisible := Status.Debit;
            CreditAmountVisible := Status.Credit;
            BankAccountCodeVisible := Status."Bank Account";
            DisableFields();
        end;
    end;


    procedure NavigateLine(PostingDate: Date)
    begin
        Navigate.SetDoc(PostingDate, Rec."Document No.");
        Navigate.Run();
    end;

    local procedure IsBankInfoEditable(): Boolean
    begin
        exit(not (Rec."Account Type" in [Rec."Account Type"::Customer, Rec."Account Type"::Vendor]));
    end;
}

