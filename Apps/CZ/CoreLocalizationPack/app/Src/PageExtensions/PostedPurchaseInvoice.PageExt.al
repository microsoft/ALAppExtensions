pageextension 11744 "Posted Purchase Invoice CZL" extends "Posted Purchase Invoice"
{
    layout
    {
        addafter("Posting Date")
        {
            field("VAT Date CZL"; Rec."VAT Date CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies date by which the accounting transaction will enter VAT statement.';
                Editable = false;
            }
            field("Original Doc. VAT Date CZL"; Rec."Original Doc. VAT Date CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the VAT date of the original document.';
                Editable = false;
            }
        }
        addafter("VAT Registration No.")
        {
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
            field("VAT Currency Code CZL"; Rec."VAT Currency Code CZL")
            {
                ApplicationArea = Suite;
                Editable = false;
                Importance = Promoted;
                ToolTip = 'Specifies the VAT currency code of the purchase invoice.';

                trigger OnAssistEdit()
                begin
                    ChangeExchangeRate.SetParameter(Rec."VAT Currency Code CZL", Rec."VAT Currency Factor CZL", Rec."VAT Date CZL");
                    ChangeExchangeRate.Editable(false);
                    ChangeExchangeRate.RunModal();
                    Clear(ChangeExchangeRate);
                end;
            }
            field("EU 3-Party Trade CZL"; Rec."EU 3-Party Trade CZL")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies whether the document is part of a three-party trade.';
            }
        }
        addafter("Area")
        {
            field("EU 3-Party Intermed. Role CZL"; Rec."EU 3-Party Intermed. Role CZL")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies when the purchase header will use European Union third-party intermediate trade rules. This option complies with VAT accounting standards for EU third-party trade.';
            }
            field("Intrastat Exclude CZL"; Rec."Intrastat Exclude CZL")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies that entry will be excluded from intrastat.';
            }
        }
        addafter("Invoice Details")
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
                field("Vendor Posting Group CZL"; Rec."Vendor Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the vendor''s market type to link business transactions made for the vendor with the appropriate account in the general ledger.';
                }
            }
        }
    }

    actions
    {
        addlast(processing)
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

    trigger OnAfterGetCurrRecord()
    begin
        VATLCYCorrectionCZLVisible := Rec.IsVATLCYCorrectionAllowedCZL();
    end;

    var
        ChangeExchangeRate: Page "Change Exchange Rate";
        VATLCYCorrectionCZLVisible: Boolean;

    procedure SetRecPopUpVATLCYCorrectionCZL(NewPopUpVATLCYCorrection: Boolean)
    begin
        Rec.SetPopUpVATLCYCorrectionCZL(NewPopUpVATLCYCorrection);
    end;
}
