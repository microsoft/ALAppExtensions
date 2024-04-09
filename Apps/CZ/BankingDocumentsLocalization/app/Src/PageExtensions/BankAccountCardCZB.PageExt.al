// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank.BankAccount;

pageextension 31287 "Bank Account Card CZB" extends "Bank Account Card"
{
    layout
    {
        modify("Disable Automatic Pmt Matching")
        {
            Importance = Standard;
        }
        modify("Match Tolerance Type")
        {
            Importance = Standard;
        }
        modify("Match Tolerance Value")
        {
            Importance = Standard;
        }
        addafter(Transfer)
        {
            group("Numbering CZB")
            {
                Caption = 'Numbering';
                field("Payment Order Nos. CZB"; Rec."Payment Order Nos. CZB")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code for the number series that will be used to assign numbers to payment orders.';
                }
                field("Isssued Payment Order Nos. CZB"; Rec."Issued Payment Order Nos. CZB")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code for the number series that will be used to assign numbers to issued payment order.';
                }
                field("Bank Statement Nos. CZB"; Rec."Bank Statement Nos. CZB")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code for the number series that will be used to assign numbers to bank statement.';
                }
                field("Issued Bank Statement Nos. CZB"; Rec."Issued Bank Statement Nos. CZB")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code for the number series that will be used to assign numbers to issued bank statement.';
                }
            }
        }
        addafter("Payment Export Format")
        {
            field("Foreign Payment Ex. Format CZB"; Rec."Foreign Payment Ex. Format CZB")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the format of the bank file that will be exported when you choose the export foreign payment order.';
            }
        }
        movelast("Numbering CZB"; "Credit Transfer Msg. Nos.", "Direct Debit Msg. Nos.")
        addbefore("Numbering CZB")
        {
            group(PaymentReconciliationJournalCZB)
            {
                Caption = 'Payment Journal';
                field("Variable S. to Description CZB"; Rec."Variable S. to Description CZB")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies copying variable symbol of the payment to the description field in payment journal.';
                }
                field("Variable S. to Variable S. CZB"; Rec."Variable S. to Variable S. CZB")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies copying variable symbol of the payment to the variable symbol field in payment journal.';
                }
                field("Variable S. to Ext.Doc.No. CZB"; Rec."Variable S. to Ext.Doc.No. CZB")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies copying variable symbol of the payment to the external document number field in payment journal.';
                }
                field("Dimension from Apply Entry CZB"; Rec."Dimension from Apply Entry CZB")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the transfer the dimension from apply entry.';
                }
                field("Post Per Line CZB"; Rec."Post Per Line CZB")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the bank account will be used as balance account number on each line.';
                }
                field("Search Rule Code CZB"; Rec."Search Rule Code CZB")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the rule code for matching lines from bank statements.';

                    trigger OnValidate()
                    begin
                        MandatoryFieldCZB := Rec."Search Rule Code CZB" <> '';
                    end;
                }
                field("Non Assoc. Payment Account CZB"; Rec."Non Assoc. Payment Account CZB")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the account for non associated payment.';
                    ShowMandatory = MandatoryFieldCZB;
                }
            }
            group(PaymentOrdersCZB)
            {
                Caption = 'Payment Orders';
                field("Pmt.Jnl. Templ. Name Order CZB"; Rec."Pmt.Jnl. Templ. Name Order CZB")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of payment journal template.';
                    ShowMandatory = MandatoryFieldCZB;
                }
                field("Pmt. Jnl. Batch Name Order CZB"; Rec."Pmt. Jnl. Batch Name Order CZB")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of payment journal batch.';
                    ShowMandatory = MandatoryFieldCZB;
                }
                field("Domestic Payment Order ID CZB"; Rec."Domestic Payment Order ID CZB")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the report setup for domestic payment order.';
                }
                field("Foreign Payment Order ID CZB"; Rec."Foreign Payment Order ID CZB")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the report setup for foreign payment order.';
                }
                field("Base Calendar Code CZB"; Rec."Base Calendar Code CZB")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a customizable calendar for shipment planning that holds the customer''s working days and holidays.';
                    Importance = Additional;
                }
                field("Default Constant Symbol CZB"; Rec."Default Constant Symbol CZB")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the default constant symbol for payment.';
                    Importance = Additional;
                }
                field("Default Specific Symbol CZB"; Rec."Default Specific Symbol CZB")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the default specific symbol for payment.';
                    Importance = Additional;
                }
                field("Payment Order Line Descr. CZB"; Rec."Payment Order Line Descr. CZB")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description which will be transfered into payment order line. Placeholders: %1 = document type, %2 = document no., %3 = partner no., %4 = partner name, %5 = external document no.';
                }
                field("Payment Partial Suggestion CZB"; Rec."Payment Partial Suggestion CZB")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the partial suggestion of payment have to be suggest.';
                }
                field("Foreign Payment Orders CZB"; Rec."Foreign Payment Orders CZB")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the foreign or domestic payment order.';
                }
                field("Check CZ Format on Issue CZB"; Rec."Check CZ Format on Issue CZB")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies check the bank account format on payment order issue for domestic payment order';
                }
            }
            group(BankStatementsCZB)
            {
                Caption = 'Bank Statements';
                field("Payment Jnl. Template Name CZB"; Rec."Payment Jnl. Template Name CZB")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of payment journal template.';
                    ShowMandatory = MandatoryFieldCZB;
                }
                field("Payment Jnl. Batch Name CZB"; Rec."Payment Jnl. Batch Name CZB")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of payment journal batch.';
                    ShowMandatory = MandatoryFieldCZB;
                }
                field("Check Ext. No. Curr. Year CZB"; Rec."Check Ext. No. Curr. Year CZB")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies check the external number of document by current year by payment order apply';
                }
            }
        }
    }

    var
        MandatoryFieldCZB: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        MandatoryFieldCZB := Rec."Search Rule Code CZB" <> '';
    end;
}
