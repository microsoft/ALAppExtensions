pageextension 11737 "Purchase Quote CZL" extends "Purchase Quote"
{
    layout
    {
        addlast("Invoice Details")
        {
            field("Last Unreliab. Check Date CZL"; Rec."Last Unreliab. Check Date CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the date of the last check of unreliability.';
            }
            field("VAT Unreliable Payer CZL"; Rec."VAT Unreliable Payer CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if the vendor is unreliabe payer.';
            }
        }
        addlast(Payments)
        {
            field(IsPublicBankAccountCZL; Rec.IsPublicBankAccountCZL())
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Public Bank Account';
                Editable = false;
                ToolTip = 'Specifies if the vendor''s bank account is public.';
            }
            field("Third Party Bank Account CZL"; Rec."Third Party Bank Account CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if the account is third party bank account.';
            }
        }
        addafter("VAT Registration No.")
        {
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
        addafter("Area")
        {
            field("EU 3-Party Trade CZL"; Rec."EU 3-Party Trade CZL")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies whether the document is part of a three-party trade.';
            }
            field("EU 3-Party Intermed. Role CZL"; Rec."EU 3-Party Intermed. Role CZL")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies when the purchase header will use European Union third-party intermediate trade rules. This option complies with VAT accounting standards for EU third-party trade.';
            }
        }
    }
}
