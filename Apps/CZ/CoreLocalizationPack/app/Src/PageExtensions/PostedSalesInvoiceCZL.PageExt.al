// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.History;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Setup;

pageextension 11733 "Posted Sales Invoice CZL" extends "Posted Sales Invoice"
{
    layout
    {
        addbefore("Location Code")
        {
            field("Reason Code CZL"; Rec."Reason Code")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the reason code on the entry.';
                Visible = true;
            }
        }
        addbefore("Customer Posting Group")
        {
            field("VAT Bus. Posting Group CZL"; Rec."VAT Bus. Posting Group")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies a VAT business posting group code.';
            }
        }
        addlast("Invoice Details")
        {
            field("VAT Registration No. CZL"; Rec."VAT Registration No.")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the VAT registration number. The field will be used when you do business with partners from EU countries/regions.';
            }
            field("Registration No. CZL"; Rec."Registration No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the registration number of customer.';
                Editable = false;
            }
            field("Tax Registration No. CZL"; Rec."Tax Registration No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the secondary VAT registration number for the customer.';
                Editable = false;
                Importance = Additional;
            }
        }
        addafter("Currency Code")
        {
            field(AdditionalCurrencyCodeCZL; GeneralLedgerSetup.GetAdditionalCurrencyCode())
            {
                ApplicationArea = Suite;
                Editable = false;
                Caption = 'Additional Currency Code';
                ToolTip = 'Specifies the exchange rate to be used if you post in an additional currency.';
                Visible = AddCurrencyVisible;

                trigger OnAssistEdit()
                begin
                    ChangeExchangeRate.SetParameter(GeneralLedgerSetup.GetAdditionalCurrencyCode(), Rec."Additional Currency Factor CZL", Rec."Posting Date");
                    ChangeExchangeRate.Editable(false);
                    ChangeExchangeRate.RunModal();
                end;
            }
            field("VAT Currency Code CZL"; Rec."VAT Currency Code CZL")
            {
                ApplicationArea = Suite;
                Editable = false;
                Importance = Promoted;
                ToolTip = 'Specifies the VAT currency code of the sales invoice.';

                trigger OnAssistEdit()
                begin
                    ChangeExchangeRate.SetParameter(Rec."VAT Currency Code CZL", Rec."VAT Currency Factor CZL", Rec."VAT Reporting Date");
                    ChangeExchangeRate.Editable(false);
                    ChangeExchangeRate.RunModal();
                end;
            }
        }
        addafter("Direct Debit Mandate ID")
        {
            field("Customer Posting Group CZL"; Rec."Customer Posting Group")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the customer''s market type to link business transakcions to.';
            }
        }
        addlast("Foreign Trade")
        {
            field("Transaction Type CZL"; Rec."Transaction Type")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the transaction type for the customer record. This information is used for Intrastat reporting.';
            }
            field("Language Code CZL"; Rec."Language Code")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the language to be used on printouts for this document.';
            }
            field("VAT Country/Region Code CZL"; Rec."VAT Country/Region Code")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the VAT country/region code of customer.';
            }
            field("EU 3-Party Intermed. Role CZL"; Rec."EU 3-Party Intermed. Role CZL")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies when the sales header will use European Union third-party intermediate trade rules. This option complies with VAT accounting standards for EU third-party trade.';
            }
        }
        addafter("Foreign Trade")
        {
            group(PaymentsCZL)
            {
                Caption = 'Payment Details';
                field("Variable Symbol CZL"; Rec."Variable Symbol CZL")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the detail information for payment.';
                    Importance = Promoted;
                }
                field("Constant Symbol CZL"; Rec."Constant Symbol CZL")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the additional symbol of bank payments.';
                    Importance = Additional;
                }
                field("Specific Symbol CZL"; Rec."Specific Symbol CZL")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the additional symbol of bank payments.';
                    Importance = Additional;
                }
                field("Bank Account Code CZL"; Rec."Bank Account Code CZL")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies a code to idenfity bank account of company.';
                }
                field("Bank Name CZL"; Rec."Bank Name CZL")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the name of the bank.';
                }
                field("Bank Account No. CZL"; Rec."Bank Account No. CZL")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the number used by the bank for the bank account.';
                    Importance = Promoted;
                }
                field("IBAN CZL"; Rec."IBAN CZL")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the bank account''s international bank account number.';
                    Importance = Promoted;
                }
                field("SWIFT Code CZL"; Rec."SWIFT Code CZL")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the international bank identifier code (SWIFT) of the bank where you have the account.';
                }
                field("Transit No. CZL"; Rec."Transit No. CZL")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies a bank identification number of your own choice.';
                    Importance = Additional;
                }
                field("Bank Branch No. CZL"; Rec."Bank Branch No. CZL")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the number of the bank branch.';
                    Importance = Additional;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        AddCurrencyVisible := GeneralLedgerSetup.IsAdditionalCurrencyEnabled();
    end;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        ChangeExchangeRate: Page "Change Exchange Rate";
        AddCurrencyVisible: Boolean;
}
