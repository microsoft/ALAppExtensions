﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

using Microsoft.Finance.Currency;
#if not CLEAN24
using Microsoft.Finance.EU3PartyTrade;
#endif

pageextension 11741 "Purchase Return Order CZL" extends "Purchase Return Order"
{
    layout
    {
        addlast(General)
        {
            field("Posting Description CZL"; Rec."Posting Description")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies a description of the document. The posting description also appers on vendor and G/L entries.';
            }
            field("Your Reference CZL"; Rec."Your Reference")
            {
                ApplicationArea = Basic, Suite;
                Importance = Additional;
                ToolTip = 'Specifies the customer''s reference. The contents will be printed on sales documents.';
            }
        }
        addafter("Posting Date")
        {
            field("Original Doc. VAT Date CZL"; Rec."Original Doc. VAT Date CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the VAT date of the original document.';
            }
        }
        addafter("Document Date")
        {
            field("Correction CZL"; Rec.Correction)
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if you need to post a corrective entry to an account.';
            }
        }
        addlast("Invoice Details")
        {
            field("VAT Registration No. CZL"; Rec."VAT Registration No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the VAT registration number. The field will be used when you do business with partners from EU countries/regions.';
            }
            field("Registration No. CZL"; Rec."Registration No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the registration number of vendor.';
            }
            field("Tax Registration No. CZL"; Rec."Tax Registration No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the secondary VAT registration number for the vendor.';
                Importance = Additional;
            }
        }
        addafter("Currency Code")
        {
            field("VAT Currency Code CZL"; Rec."VAT Currency Code CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'VAT Currency Code';
                Editable = false;
                ToolTip = 'Specifies VAT currency code of purchase return order';

                trigger OnAssistEdit()
                begin
                    if Rec."VAT Reporting Date" <> 0D then
                        ChangeExchangeRate.SetParameter(Rec."VAT Currency Code CZL", Rec."VAT Currency Factor CZL", Rec."VAT Reporting Date")
                    else
                        ChangeExchangeRate.SetParameter(Rec."VAT Currency Code CZL", Rec."VAT Currency Factor CZL", WorkDate());

                    if ChangeExchangeRate.RunModal() = Action::OK then begin
                        Rec.Validate("VAT Currency Factor CZL", ChangeExchangeRate.GetParameter());
                        CurrPage.Update();
                    end;
                end;

                trigger OnValidate()
                begin
                    CurrencyCodeOnAfterValidate();
                end;
            }
        }
        addlast("Shipping and Payment")
        {
            field("Shipment Method Code CZL"; Rec."Shipment Method Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the code that represents the shipment method for this purchase.';
            }
        }
        addlast("Foreign Trade")
        {
            field("Language Code CZL"; Rec."Language Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the language to be used on printouts for this document.';
            }
            field("VAT Country/Region Code CZL"; Rec."VAT Country/Region Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the VAT country/region code of customer.';
            }
#if not CLEAN24
            field("EU 3-Party Trade CZL"; Rec."EU 3-Party Trade CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'EU 3-Party Trade (Obsolete)';
                ToolTip = 'Specifies whether the document is part of a three-party trade.';
                Visible = not EU3PartyTradeFeatureEnabled;
                Enabled = not EU3PartyTradeFeatureEnabled;
                ObsoleteState = Pending;
                ObsoleteTag = '24.0';
                ObsoleteReason = 'Replaced by "EU 3 Party Trade" field in "EU 3-Party Trade Purchase" app.';
            }
#endif
            field("EU 3-Party Intermed. Role CZL"; Rec."EU 3-Party Intermed. Role CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies when the purchase header will use European Union third-party intermediate trade rules. This option complies with VAT accounting standards for EU third-party trade.';
            }
            field(IsIntrastatTransactionCZL; Rec.IsIntrastatTransactionCZL())
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Intrastat Transaction';
                Editable = false;
                ToolTip = 'Specifies if the entry is an Intrastat transaction.';
            }
        }
        movebefore("EU 3-Party Intermed. Role CZL"; "EU 3rd Party Trade")
        addafter("Foreign Trade")
        {
            group(PaymentsCZL)
            {
                Caption = 'Payment Details';
                field("Variable Symbol CZL"; Rec."Variable Symbol CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the detail information for payment.';
                    Importance = Promoted;
                }
                field("Constant Symbol CZL"; Rec."Constant Symbol CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the additional symbol of bank payments.';
                    Importance = Additional;
                }
                field("Specific Symbol CZL"; Rec."Specific Symbol CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the additional symbol of bank payments.';
                    Importance = Additional;
                }
                field("Bank Account Code CZL"; Rec."Bank Account Code CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a code to idenfity bank account of company.';
                }
                field("Bank Name CZL"; Rec."Bank Name CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the bank.';
                }
                field("Bank Account No. CZL"; Rec."Bank Account No. CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number used by the bank for the bank account.';
                    Importance = Promoted;
                }
                field("IBAN CZL"; Rec."IBAN CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the bank account''s international bank account number.';
                    Importance = Promoted;
                }
                field("SWIFT Code CZL"; Rec."SWIFT Code CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the international bank identifier code (SWIFT) of the bank where you have the account.';
                }
                field("Transit No. CZL"; Rec."Transit No. CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a bank identification number of your own choice.';
                    Importance = Additional;
                }
                field("Bank Branch No. CZL"; Rec."Bank Branch No. CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the bank branch.';
                    Importance = Additional;
                }
            }
        }
    }
#if not CLEAN24

    trigger OnOpenPage()
    begin
        EU3PartyTradeFeatureEnabled := EU3PartyTradeFeatMgt.IsEnabled();
    end;
#endif    

    var
#if not CLEAN24
#pragma warning disable AL0432
        EU3PartyTradeFeatMgt: Codeunit "EU3 Party Trade Feat Mgt. CZL";
#pragma warning restore AL0432
#endif
        ChangeExchangeRate: Page "Change Exchange Rate";
#if not CLEAN24
        EU3PartyTradeFeatureEnabled: Boolean;
#endif

    local procedure CurrencyCodeOnAfterValidate()
    begin
        CurrPage.PurchLines.Page.UpdateForm(true);
    end;
}
