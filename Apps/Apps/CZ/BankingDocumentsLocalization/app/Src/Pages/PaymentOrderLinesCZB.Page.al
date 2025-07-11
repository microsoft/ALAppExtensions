// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Utilities;

page 31264 "Payment Order Lines CZB"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Payment Order Lines';
    Editable = false;
    PageType = List;
    SourceTable = "Payment Order Line CZB";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number used by the bank for the bank account.';
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
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies payment order amount.';
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies payment order amount in local currency.';
                }
                field("Amount (Paym. Order Currency)"; Rec."Amount (Paym. Order Currency)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies payment order amount in payment order currency.';
                }
                field("Payment Order Currency Code"; Rec."Payment Order Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the payment order currency code.';
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
                field("Transit No."; Rec."Transit No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a bank identification number of your own choice.';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of partner (customer, vendor, bank account, employee).';
                    Visible = false;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of partner (customer, vendor, bank account, employee).';
                    Visible = false;
                }
                field("Cust./Vendor Bank Account Code"; Rec."Cust./Vendor Bank Account Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the bank account code of the customer or vendor.';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        Rec.CalcFields("Third Party Bank Account");
                        if Rec.Type <> Rec.Type::Vendor then
                            Clear(Rec."Third Party Bank Account");
                    end;
                }
                field("Payment Order No."; Rec."Payment Order No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the Payment Order.';
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
                action("Show Document")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Show Document';
                    Image = View;
                    ShortCutKey = 'Shift+F7';
                    ToolTip = 'Open the document that the selected line exists on.';

                    trigger OnAction()
                    var
                        PaymentOrderHeaderCZB: Record "Payment Order Header CZB";
                        PageManagement: Codeunit "Page Management";
                    begin
                        PaymentOrderHeaderCZB.Get(Rec."Payment Order No.");
                        PageManagement.PageRun(PaymentOrderHeaderCZB);
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref("Show Document_Promoted"; "Show Document")
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if Rec.Type <> Rec.Type::Vendor then
            Clear(Rec."Third Party Bank Account");
    end;
}
