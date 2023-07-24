pageextension 4885 "EU3 Purch. Cr. Memo" extends "Purchase Credit Memo"
{
    layout
    {
        addafter("Foreign Trade")
        {
            field("EU 3 Party Trade"; Rec."EU 3 Party Trade")
            {
                ApplicationArea = VAT;
                ToolTip = 'Specifies whether or not totals for transactions involving EU 3-party trades are displayed in the VAT Statement.';
                Visible = EU3AppEnabled;
                Enabled = EU3AppEnabled;
            }
        }
    }

    trigger OnOpenPage()
    begin
        EU3AppEnabled := EU3PartyTradeFeatureMgt.IsEnabled();
    end;

    var
        EU3PartyTradeFeatureMgt: Codeunit "EU3 Party Trade Feature Mgt.";
        EU3AppEnabled: Boolean;
}