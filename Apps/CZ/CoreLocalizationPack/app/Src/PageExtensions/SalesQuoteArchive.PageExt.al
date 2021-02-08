pageextension 11771 "Sales Quote Archive CZL" extends "Sales Quote Archive"
{
    layout
    {
        addafter("Area")
        {
            field("EU 3-Party Intermed. Role CZL"; Rec."EU 3-Party Intermed. Role CZL")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies when the sales header will use European Union third-party intermediate trade rules. This option complies with VAT accounting standards for EU third-party trade.';
            }
        }
    }
}
