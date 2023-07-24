pageextension 4891 "EU3 VAT Setup" extends "VAT Setup"
{
    layout
    {
        addafter("Enable Non-Deductible VAT")
        {
            field("Enable EU 3 Party Trade"; Rec."Enable EU 3-Party Purchase")
            {
                ApplicationArea = VAT;
                ToolTip = 'Specifies whether EU 3 Trade Party Purchase functionality is enabled.';
                Visible = EU3AppEnabled;
                Enabled = EU3AppEnabled;
            }
        }
    }

    trigger OnOpenPage()
    begin
        EU3AppEnabled := EU3PartyTradeFeatureMgt.IsFeatureKeyEnabled();
    end;

    var
        EU3PartyTradeFeatureMgt: Codeunit "EU3 Party Trade Feature Mgt.";
        EU3AppEnabled: Boolean;
}