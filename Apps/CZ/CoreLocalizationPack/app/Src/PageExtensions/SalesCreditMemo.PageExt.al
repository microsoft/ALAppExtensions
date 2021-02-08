#pragma implicitwith disable
pageextension 11729 "Sales Credit Memo CZL" extends "Sales Credit Memo"
{
    layout
    {
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
        addafter("Incoming Document Entry No.")
        {
            field("Credit Memo Type CZL"; Rec."Credit Memo Type CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the type of credit memo (corrective tax document, internal correction, insolvency tax document).';
            }
        }
        addafter("VAT Registration No.")
        {
            field("Registration No. CZL"; Rec."Registration No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the registration number of customer.';
            }
            field("Tax Registration No. CZL"; Rec."Tax Registration No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the secondary VAT registration number for the customer.';
                Importance = Additional;
            }
        }
        addafter("Currency Code")
        {
            field("VAT Currency Code CZL"; Rec."VAT Currency Code CZL")
            {
                ApplicationArea = Suite;
                Importance = Promoted;
                ToolTip = 'Specifies the currency of VAT on the sales credit memo.';

                trigger OnAssistEdit()
                begin
                    Clear(ChangeExchangeRate);
                    if Rec."VAT Date CZL" <> 0D then
                        ChangeExchangeRate.SetParameter(Rec."VAT Currency Code CZL", Rec."VAT Currency Factor CZL", Rec."VAT Date CZL")
                    else
                        ChangeExchangeRate.SetParameter(Rec."VAT Currency Code CZL", Rec."VAT Currency Factor CZL", WorkDate());
                    if ChangeExchangeRate.RunModal() = ACTION::OK then begin
                        Rec.Validate("VAT Currency Factor CZL", ChangeExchangeRate.GetParameter());
                        CurrPage.Update();
                    end;
                    Clear(ChangeExchangeRate);
                end;

                trigger OnValidate()
                begin
                    CurrencyCodeOnAfterValidate();
                    CurrPage.SaveRecord();
                end;
            }
        }
        addafter("Posting Date")
        {
            field("EU 3-Party Intermed. Role CZL"; Rec."EU 3-Party Intermed. Role CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies when the sales header will use European Union third-party intermediate trade rules. This option complies with VAT accounting standards for EU third-party trade.';
            }
        }
    }
    var
        ChangeExchangeRate: Page "Change Exchange Rate";

    local procedure CurrencyCodeOnAfterValidate()
    begin
        CurrPage.SalesLines.PAGE.UpdateForm(true);
    end;
}
