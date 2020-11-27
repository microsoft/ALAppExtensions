pageextension 11753 "Posted Serv. Credit Memo CZL" extends "Posted Service Credit Memo"
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
        }
        addafter("VAT Registration No.")
        {
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
            field("VAT Currency Code CZL"; Rec."VAT Currency Code CZL")
            {
                ApplicationArea = Suite;
                Editable = false;
                Importance = Promoted;
                ToolTip = 'Specifies the VAT currency code of the Service credit memo.';

                trigger OnAssistEdit()
                var
                    UpdateCurrencyFactor: Codeunit "Update Currency Factor";
                begin
                    ChangeExchangeRate.SetParameter(Rec."VAT Currency Code CZL", Rec."VAT Currency Factor CZL", Rec."VAT Date CZL");
                    ChangeExchangeRate.Editable(false);
                    ChangeExchangeRate.RunModal();
                    Clear(ChangeExchangeRate);
                end;
            }
        }
        addafter("Area")
        {
            field("EU 3-Party Intermed. Role CZL"; Rec."EU 3-Party Intermed. Role CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies when the service header will use European Union third-party intermediate trade rules. This option complies with VAT accounting standards for EU third-party trade.';
            }
        }
        addlast(General)
        {
            field("Credit Memo Type CZL"; Rec."Credit Memo Type CZL")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the type of credit memo (corrective tax document, internal correction, insolvency tax document).';
            }
        }
    }
    var
        ChangeExchangeRate: Page "Change Exchange Rate";
}
