pageextension 11740 "Purchase Credit Memo CZL" extends "Purchase Credit Memo"
{
    layout
    {
#if not CLEAN20
        modify("Vendor Posting Group")
        {
            Editable = IsPostingGroupEditableCZL;
        }
#endif
        movelast(General; "Posting Description")
        addlast(General)
        {
            field("Your Reference CZL"; Rec."Your Reference")
            {
                ApplicationArea = Basic, Suite;
                Importance = Additional;
                ToolTip = 'Specifies the customer''s reference. The contents will be printed on sales documents.';
            }
        }
        addafter("Posting Date")
        {
            field("VAT Date CZL"; Rec."VAT Date CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies date by which the accounting transaction will enter VAT statement.';
            }
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
        addlast("Shipping and Payment")
        {
            field("Shipment Method Code CZL"; Rec."Shipment Method Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the code that represents the shipment method for this purchase.';
            }
            field("Physical Transfer CZL"; Rec."Physical Transfer CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if there is physical transfer of the item.';
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
                ToolTip = 'Specifies VAT currency code of purchase credit memo';

                trigger OnAssistEdit()
                var
                    ChangeExchangeRate: Page "Change Exchange Rate";
                begin
                    if Rec."VAT Date CZL" <> 0D then
                        ChangeExchangeRate.SetParameter(Rec."VAT Currency Code CZL", Rec."VAT Currency Factor CZL", Rec."VAT Date CZL")
                    else
                        ChangeExchangeRate.SetParameter(Rec."VAT Currency Code CZL", Rec."VAT Currency Factor CZL", WorkDate());

                    if ChangeExchangeRate.RunModal() = Action::OK then begin
                        Rec.Validate("VAT Currency Factor CZL", ChangeExchangeRate.GetParameter());
                        CurrPage.Update();
                    end;
                end;
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
            field("EU 3-Party Trade CZL"; Rec."EU 3-Party Trade CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether the document is part of a three-party trade.';
            }
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
            field("Intrastat Exclude CZL"; Rec."Intrastat Exclude CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies that entry will be excluded from intrastat.';
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
#if not CLEAN20

    trigger OnOpenPage()
    begin
        PurchasesPayablesSetupCZL.GetRecordOnce();
#pragma warning disable AL0432
        IsPostingGroupEditableCZL := PurchasesPayablesSetupCZL."Allow Alter Posting Groups CZL";
#pragma warning restore AL0432
    end;

    var
        PurchasesPayablesSetupCZL: Record "Purchases & Payables Setup";
        IsPostingGroupEditableCZL: Boolean;
#endif
}
