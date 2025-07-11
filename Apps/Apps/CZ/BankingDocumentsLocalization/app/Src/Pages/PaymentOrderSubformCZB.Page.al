// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.Currency;

page 31263 "Payment Order Subform CZB"
{
    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Payment Order Line CZB";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Type; Rec.Type)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of partner (customer, vendor, bank account, employee).';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of partner (customer, vendor, bank account, employee).';
                }
                field("Cust./Vendor Bank Account Code"; Rec."Cust./Vendor Bank Account Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the customer or vendor bank account code.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the payment order line.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of partner (customer, vendor, bank account).';
                    Visible = false;
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = IBANMissing;
                    ToolTip = 'Specifies the number used by the bank for the bank account.';

                    trigger OnValidate()
                    begin
                        SetShowMandatoryConditions();
                    end;
                }
                field("Variable Symbol"; Rec."Variable Symbol")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = not IsForeignPaymentOrder;
                    ToolTip = 'Specifies the detail information for payment.';
                }
                field("Constant Symbol"; Rec."Constant Symbol")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the additional symbol of bank payments.';
                }
                field("Specific Symbol"; Rec."Specific Symbol")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the additional symbol of bank payments.';
                }
                field("Skip Payment"; Rec."Skip Payment")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the amount must be skipped.';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    ToolTip = 'Specifies payment order amount.';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Original Amount"; Rec."Original Amount")
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    ToolTip = 'Specifies the amount of the original entry.';
                    Visible = false;
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    ShowMandatory = true;
                    ToolTip = 'Specifies payment order amount in local currency.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field(RelatedAmountToApply; Rec.CalcRelatedAmountToApply())
                {
                    Caption = 'Related Amount to Apply (LCY)';
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the total Amount (LCY) related suggestions to apply.';
                    BlankZero = true;
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownRelatedAmountToApply();
                    end;
                }
                field("Amount (Paym. Order Currency)"; Rec."Amount (Paym. Order Currency)")
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    ShowMandatory = true;
                    ToolTip = 'Specifies payment order amount in payment order currency.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Payment Order Currency Code"; Rec."Payment Order Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the payment order currency code.';

                    trigger OnAssistEdit()
                    var
                        PaymentOrderHeaderCZB: Record "Payment Order Header CZB";
                        ChangeExchangeRate: Page "Change Exchange Rate";
                    begin
                        PaymentOrderHeaderCZB.Get(Rec."Payment Order No.");
                        ChangeExchangeRate.SetParameter(Rec."Payment Order Currency Code",
                          Rec."Payment Order Currency Factor", PaymentOrderHeaderCZB."Document Date");
                        if ChangeExchangeRate.RunModal() = Action::OK then begin
                            Rec.Validate("Payment Order Currency Factor", ChangeExchangeRate.GetParameter());
                            CurrPage.Update();
                        end;
                    end;
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date when the payment is due.';
                    Visible = false;
                }
                field("Original Due Date"; Rec."Original Due Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date when the payment was due.';
                    Visible = false;
                }
                field("Pmt. Discount Date"; Rec."Pmt. Discount Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies payment discount date.';
                    Visible = false;
                }
                field("Pmt. Discount Possible"; Rec."Pmt. Discount Possible")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the discount is possible.';
                    Visible = false;
                }
                field("Remaining Pmt. Disc. Possible"; Rec."Remaining Pmt. Disc. Possible")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies possible remaining payment discount.';
                    Visible = false;
                }
                field("Transit No."; Rec."Transit No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a bank identification number of your own choice.';
                }
                field(IBAN; Rec.IBAN)
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = AccountNoMissing;
                    ToolTip = 'Specifies the bank account''s international bank account number.';

                    trigger OnValidate()
                    begin
                        SetShowMandatoryConditions();
                    end;
                }
                field("SWIFT Code"; Rec."SWIFT Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the international bank identifier code (SWIFT) of the bank where you have the account.';
                }
                field("Applies-to Doc. Type"; Rec."Applies-to Doc. Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the payment will be applied to an already-posted document. The field is used only if the account type is a customer or vendor account.';
                    Visible = false;
                }
                field("Applies-to Doc. No."; Rec."Applies-to Doc. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the payment will be applied to an already-posted document.';
                    Visible = false;
                }
                field("Applies-to C/V/E Entry No."; Rec."Applies-to C/V/E Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the payment will be applied to an already-posted document.';
                }
                field("Amt. on Issued Payment Orders"; IssPaymentOrderLineCZB.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    Caption = 'Amt. on Issued Payment Orders';
                    Editable = false;
                    ToolTip = 'Specifies the amount on issued payment orders.';
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        DrillDownAmountOnIssPaymentOrder(false);
                    end;
                }
                field("Amt. on Iss. Pay. Orders (LCY)"; IssPaymentOrderLineCZB."Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    Caption = 'Amt. on Issued Payment Orders (LCY)';
                    Editable = false;
                    ToolTip = 'Specifies the amount on issued payment orders. The amount is in the local currency.';
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        DrillDownAmountOnIssPaymentOrder(true);
                    end;
                }
                field("Amount Must Be Checked"; Rec."Amount Must Be Checked")
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    ToolTip = 'Specifies if the amount must be checked.';
                }
                field("VAT Unreliable Payer"; Rec."VAT Unreliable Payer")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the vendor is unreliable payer.';
                }
                field("Public Bank Account"; Rec."Public Bank Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the bank account is public.';
                }
                field("Third Party Bank Account"; Rec."Third Party Bank Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the account is third party bank account.';
                }
                field("Payment Method Code"; Rec."Payment Method Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies how the customer must advance pay.';
                    Visible = false;
                }
            }
            group(Total)
            {
                ShowCaption = false;
                Visible = false;

                field(TotalPaymentOrderHeaderPaymentOrderCurrency; TotalPaymentOrderHeaderCZB."Amount (Pay.Order Curr.)")
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = TotalPaymentOrderHeaderCZB."Payment Order Currency Code";
                    AutoFormatType = 1;
                    CaptionClass = BankingDocumentTotalsCZB.GetTotalCaption(TotalPaymentOrderHeaderCZB."Payment Order Currency Code");
                    Caption = 'Total Amount';
                    Editable = false;
                    Style = Strong;
                    StyleExpr = true;
                    ToolTip = 'Specifies total amount of payment order';
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        BankingDocumentTotalsCZB.CalculatePaymentOrderTotals(TotalPaymentOrderHeaderCZB, Rec);
        SetShowMandatoryConditions();
    end;

    trigger OnAfterGetRecord()
    begin
        CalcAmountsOnIssPaymentOrder();
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        CurrPage.Update();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        PaymentOrderHeaderCZB: Record "Payment Order Header CZB";
        BankAccount: Record "Bank Account";
    begin
        if PaymentOrderHeaderCZB.Get(Rec."Payment Order No.") then begin
            BankAccount.Get(PaymentOrderHeaderCZB."Bank Account No.");
            Rec."Constant Symbol" := BankAccount."Default Constant Symbol CZB";
            Rec."Specific Symbol" := BankAccount."Default Specific Symbol CZB";
            Rec."Currency Code" := PaymentOrderHeaderCZB."Currency Code";
            Rec."Payment Order Currency Code" := PaymentOrderHeaderCZB."Payment Order Currency Code";
            Rec."Payment Order Currency Factor" := PaymentOrderHeaderCZB."Payment Order Currency Factor";
        end else
            if BankAccount.Get(BankAccountNo) then begin
                Rec."Constant Symbol" := BankAccount."Default Constant Symbol CZB";
                Rec."Specific Symbol" := BankAccount."Default Specific Symbol CZB";
                Rec."Currency Code" := BankAccount."Currency Code";
                Rec."Payment Order Currency Code" := BankAccount."Currency Code";
            end;
    end;

    trigger OnOpenPage()
    begin
        OnActivateForm();
    end;

    var
        TotalPaymentOrderHeaderCZB: Record "Payment Order Header CZB";
        GlobalPaymentOrderHeaderCZB: Record "Payment Order Header CZB";
        IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB";
        BankingDocumentTotalsCZB: Codeunit "Banking Document Totals CZB";
        BankAccountNo: Code[20];
        IBANMissing: Boolean;
        AccountNoMissing: Boolean;
        IsForeignPaymentOrder: Boolean;

    procedure SetParameters(NewBankAccountNo: Code[20])
    begin
        BankAccountNo := NewBankAccountNo;
    end;

    procedure SetPaymentOrderHeader(PaymentOrderHeaderCZB: Record "Payment Order Header CZB")
    begin
        GlobalPaymentOrderHeaderCZB := PaymentOrderHeaderCZB;
    end;

    local procedure OnActivateForm()
    var
        PaymentOrderHeaderCZB: Record "Payment Order Header CZB";
    begin
        if Rec."Line No." = 0 then
            if PaymentOrderHeaderCZB.Get(Rec."Payment Order No.") then begin
                Rec.Validate("Payment Order Currency Code", PaymentOrderHeaderCZB."Payment Order Currency Code");
                Rec."Payment Order Currency Factor" := PaymentOrderHeaderCZB."Payment Order Currency Factor";
                CurrPage.Update();
            end;
    end;

    local procedure SetShowMandatoryConditions()
    begin
        IBANMissing := Rec.IBAN = '';
        AccountNoMissing := Rec."Account No." = '';
        IsForeignPaymentOrder := GlobalPaymentOrderHeaderCZB."Foreign Payment Order";
    end;

    local procedure CalcAmountsOnIssPaymentOrder()
    begin
        Clear(IssPaymentOrderLineCZB);
        if Rec."Applies-to C/V/E Entry No." = 0 then
            exit;

        SetFilterToIssPaymentOrderLine(IssPaymentOrderLineCZB);
        IssPaymentOrderLineCZB.CalcSums(Amount, "Amount (LCY)");
    end;

    local procedure DrillDownAmountOnIssPaymentOrder(IsLCY: Boolean)
    var
        IssPaymentOrderLineCZB2: Record "Iss. Payment Order Line CZB";
        IsHandled: Boolean;
    begin
        OnBeforeDrillDownAmountOnIssPaymentOrder(Rec, IsLCY, IsHandled);
        if IsHandled then
            exit;

        if Rec."Applies-to C/V/E Entry No." = 0 then
            Rec.FieldError("Applies-to C/V/E Entry No.");

        SetFilterToIssPaymentOrderLine(IssPaymentOrderLineCZB2);
        Page.RunModal(0, IssPaymentOrderLineCZB2);
    end;

    local procedure SetFilterToIssPaymentOrderLine(var IssPaymentOrderLineCZB2: Record "Iss. Payment Order Line CZB")
    begin
        IssPaymentOrderLineCZB2.SetCurrentKey(Type, "Applies-to C/V/E Entry No.", Status);
        IssPaymentOrderLineCZB2.SetRange(Type, Rec.Type);
        IssPaymentOrderLineCZB2.SetRange("Applies-to C/V/E Entry No.", Rec."Applies-to C/V/E Entry No.");
        IssPaymentOrderLineCZB2.SetRange(Status, IssPaymentOrderLineCZB2.Status::" ");
        OnAfterSetFilterToIssPaymentOrderLine(Rec, IssPaymentOrderLineCZB2);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDrillDownAmountOnIssPaymentOrder(PaymentOrderLineCZB: Record "Payment Order Line CZB"; IsLCY: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetFilterToIssPaymentOrderLine(PaymentOrderLineCZB: Record "Payment Order Line CZB"; var IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB")
    begin
    end;
}
