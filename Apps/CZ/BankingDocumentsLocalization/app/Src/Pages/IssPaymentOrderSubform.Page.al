// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Finance.Currency;

page 31267 "Iss. Payment Order Subform CZB"
{
    AutoSplitKey = true;
    Caption = 'Lines';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    SourceTable = "Iss. Payment Order Line CZB";

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
                    ToolTip = 'Specifies the bank account code of the customer or vendor.';
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
                    ToolTip = 'Specifies the number used by the bank for the bank account.';
                }
                field("Variable Symbol"; Rec."Variable Symbol")
                {
                    ApplicationArea = Basic, Suite;
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
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies Amount on Issued Payment Order Line.';
                    Visible = false;
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount in the local currency for payment.';
                }
                field("Amount(Payment Order Currency)"; Rec."Amount(Payment Order Currency)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies issued payment order currency code. The issued payment order currency code can be different from bank account currency.';
                }
                field("Payment Order Currency Code"; Rec."Payment Order Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the payment order currency code.';
                    Visible = false;

                    trigger OnAssistEdit()
                    var
                        IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB";
                        ChangeExchangeRate: Page "Change Exchange Rate";
                    begin
                        IssPaymentOrderHeaderCZB.Get(Rec."Payment Order No.");
                        ChangeExchangeRate.SetParameter(Rec."Payment Order Currency Code", Rec."Payment Order Currency Factor",
                          IssPaymentOrderHeaderCZB."Document Date");
                        ChangeExchangeRate.Editable(false);
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
                field("Transit No."; Rec."Transit No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a bank identification number of your own choice.';
                }
                field(IBAN; Rec.IBAN)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the bank account''s international bank account number.';
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
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the status of credits lines';
                    Visible = false;
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
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("&Line")
            {
                Caption = '&Line';
                action(Cancel)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cancel';
                    Image = CancelLine;
                    ToolTip = 'This function deletes selected payment order lines.';

                    trigger OnAction()
                    var
                        IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB";
                    begin
                        CurrPage.SetSelectionFilter(IssPaymentOrderLineCZB);
                        Rec.CancelLines(IssPaymentOrderLineCZB);
                        CurrPage.Update();
                    end;
                }
            }
        }
    }

    procedure FilterCanceledLines(CanceledLinesFilter: Option " ","Not Canceled",Canceled)
    begin
        case CanceledLinesFilter of
            CanceledLinesFilter::" ":
                Rec.SetRange(Status);
            CanceledLinesFilter::"Not Canceled":
                Rec.SetRange(Status, Rec.Status::" ");
            CanceledLinesFilter::Canceled:
                Rec.SetRange(Status, Rec.Status::Canceled);
        end;
    end;
}
