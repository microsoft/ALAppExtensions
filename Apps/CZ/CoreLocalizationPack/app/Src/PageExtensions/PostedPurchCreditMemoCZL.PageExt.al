// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.History;

using Microsoft.Finance.Currency;
#if not CLEAN24
using Microsoft.Finance.EU3PartyTrade;
#endif
using Microsoft.Finance.GeneralLedger.Setup;

pageextension 11746 "Posted Purch. Credit Memo CZL" extends "Posted Purchase Credit Memo"
{
    layout
    {
        addlast(General)
        {
            field("Posting Description CZL"; Rec."Posting Description")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies a description of the document. The posting description also appers on vendor and G/L entries.';
                Visible = false;
            }
        }
        addafter("Posting Date")
        {
            field("Original Doc. VAT Date CZL"; Rec."Original Doc. VAT Date CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the VAT date of the original document.';
                Editable = false;
            }
        }
        addbefore("Vendor Posting Group")
        {
            field("VAT Bus. Posting Group CZL"; Rec."VAT Bus. Posting Group")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies a VAT business posting group code.';
            }
        }
        addafter("Document Date")
        {
            field("Correction CZL"; Rec.Correction)
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies if you need to post a corrective entry to an account.';
            }
        }
        addlast("Shipping and Payment")
        {
            field("Shipment Method Code CZL"; Rec."Shipment Method Code")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the code that represents the shipment method for this purchase.';
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
                ToolTip = 'Specifies the registration number of vendor.';
                Editable = false;
            }
            field("Tax Registration No. CZL"; Rec."Tax Registration No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the secondary VAT registration number for the vendor.';
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
                ToolTip = 'Specifies the VAT currency code of the purchase credit memo.';

                trigger OnAssistEdit()
                var
                    ChangeExchangeRate: Page "Change Exchange Rate";
                begin
                    ChangeExchangeRate.SetParameter(Rec."VAT Currency Code CZL", Rec."VAT Currency Factor CZL", Rec."VAT Reporting Date");
                    ChangeExchangeRate.Editable(false);
                    ChangeExchangeRate.RunModal();
                end;
            }
        }
        addafter("Invoice Details")
        {
            group("Foreign Trade CZL")
            {
                Caption = 'Foreign Trade';
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
                    ToolTip = 'Specifies the VAT country/region code of vendor';
                }
                field("Transaction Type CZL"; Rec."Transaction Type")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the transaction type for the customer record. This information is used for Intrastat reporting.';
                }
                field("Transaction Specification CZL"; Rec."Transaction Specification")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies a code for the purchase document''s transaction specification, for the purpose of reporting to INTRASTAT.';
                }
                field("Transport Method CZL"; Rec."Transport Method")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the transport method, for the purpose of reporting to INTRASTAT.';
                }
                field("Entry Point CZL"; Rec."Entry Point")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the code of the port of entry where the items pass into your country/region.';
                }
                field("Area CZL"; Rec.Area)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the area code used in the invoice';
                }
#if not CLEAN24
                field("EU 3-Party Trade CZL"; Rec."EU 3-Party Trade CZL")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'EU 3-Party Trade (Obsolete)';
                    Editable = false;
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
                    Editable = false;
                    ToolTip = 'Specifies when the purchase header will use European Union third-party intermediate trade rules. This option complies with VAT accounting standards for EU third-party trade.';
                }
            }
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
                field("Vendor Posting Group CZL"; Rec."Vendor Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the vendor''s market type to link business transactions made for the vendor with the appropriate account in the general ledger.';
                }
            }
        }
        movebefore("EU 3-Party Intermed. Role CZL"; "EU 3 Party Trade")
    }

    actions
    {
        addlast(Processing)
        {
            action(VATLCYCorrectionCZL)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'VAT LCY Correction';
                Image = AdjustEntries;
                ToolTip = 'Allows you to adjust the VAT amount in LCY for purchase documents charged in a foreign currency.';
                Visible = VATLCYCorrectionCZLVisible;

                trigger OnAction()
                begin
                    Rec.MakeVATLCYCorrectionCZL();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
#if not CLEAN24
        EU3PartyTradeFeatureEnabled := EU3PartyTradeFeatMgt.IsEnabled();
#endif
        AddCurrencyVisible := GeneralLedgerSetup.IsAdditionalCurrencyEnabled();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        VATLCYCorrectionCZLVisible := Rec.IsVATLCYCorrectionAllowedCZL();
    end;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
#if not CLEAN24
#pragma warning disable AL0432
        EU3PartyTradeFeatMgt: Codeunit "EU3 Party Trade Feat Mgt. CZL";
#pragma warning restore AL0432
#endif
        ChangeExchangeRate: Page "Change Exchange Rate";
#if not CLEAN24
#pragma warning disable AL0432
        EU3PartyTradeFeatureEnabled: Boolean;
#pragma warning restore AL0432
#endif
        VATLCYCorrectionCZLVisible: Boolean;
        AddCurrencyVisible: Boolean;

    procedure SetRecPopUpVATLCYCorrectionCZL(NewPopUpVATLCYCorrection: Boolean)
    begin
        Rec.SetPopUpVATLCYCorrectionCZL(NewPopUpVATLCYCorrection);
    end;
}
