// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.Currency;

page 31255 "Bank Statement Subform CZB"
{
    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Bank Statement Line CZB";

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
                    ToolTip = 'Specifies the type of partner (customer, vendor, bank account).';
                    Visible = false;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of partner (customer, vendor, bank account).';
                    Visible = false;
                }
                field("Cust./Vendor Bank Account Code"; Rec."Cust./Vendor Bank Account Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the bank account code of the customer or vendor.';
                    Visible = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the payment''s description.';
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
                    BlankZero = true;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the amount for payment.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    ToolTip = 'Specifies the amount in the local currency for payment.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Bank Statement Currency Code"; Rec."Bank Statement Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the bank statement currency code which is setup in the bank card.';
                    Visible = false;

                    trigger OnAssistEdit()
                    var
                        BankStatementHeaderCZB: Record "Bank Statement Header CZB";
                        ChangeExchangeRate: Page "Change Exchange Rate";
                    begin
                        BankStatementHeaderCZB.Get(Rec."Bank Statement No.");
                        ChangeExchangeRate.SetParameter(Rec."Bank Statement Currency Code", Rec."Bank Statement Currency Factor",
                          BankStatementHeaderCZB."Document Date");
                        if ChangeExchangeRate.RunModal() = Action::OK then begin
                            Rec.Validate("Bank Statement Currency Factor", ChangeExchangeRate.GetParameter());
                            CurrPage.Update();
                        end;
                    end;
                }
                field("Amount (Bank Stat. Currency)"; Rec."Amount (Bank Stat. Currency)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount in bank statement currencythat the bank statement line contains.';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
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
            }
        }
    }

    trigger OnDeleteRecord(): Boolean
    begin
        CurrPage.Update();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        BankStatementHeaderCZB: Record "Bank Statement Header CZB";
        BankAccount: Record "Bank Account";
    begin
        if BankStatementHeaderCZB.Get(Rec."Bank Statement No.") then begin
            BankAccount.Get(BankStatementHeaderCZB."Bank Account No.");
            Rec."Constant Symbol" := BankAccount."Default Constant Symbol CZB";
            Rec."Specific Symbol" := BankAccount."Default Specific Symbol CZB";
            Rec."Currency Code" := BankStatementHeaderCZB."Currency Code";
            Rec."Bank Statement Currency Code" := BankStatementHeaderCZB."Bank Statement Currency Code";
            Rec."Bank Statement Currency Factor" := BankStatementHeaderCZB."Bank Statement Currency Factor";
        end else
            if BankAccount.Get(BankAccountNo) then begin
                Rec."Constant Symbol" := BankAccount."Default Constant Symbol CZB";
                Rec."Specific Symbol" := BankAccount."Default Specific Symbol CZB";
                Rec."Currency Code" := BankAccount."Currency Code";
            end;
    end;

    trigger OnOpenPage()
    begin
        OnActivateForm();
    end;

    var
        BankAccountNo: Code[20];

    procedure SetParameters(NewBankAccountNo: Code[20])
    begin
        BankAccountNo := NewBankAccountNo;
    end;

    local procedure OnActivateForm()
    var
        BankStatementHeader: Record "Bank Statement Header CZB";
    begin
        if Rec."Line No." = 0 then
            if BankStatementHeader.Get(Rec."Bank Statement No.") then begin
                Rec.Validate("Bank Statement Currency Code", BankStatementHeader."Bank Statement Currency Code");
                Rec."Bank Statement Currency Factor" := BankStatementHeader."Bank Statement Currency Factor";
                CurrPage.Update();
            end;
    end;
}
