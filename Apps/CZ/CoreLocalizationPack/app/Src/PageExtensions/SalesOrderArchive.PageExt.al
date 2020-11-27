pageextension 11772 "Sales Order Archive CZL" extends "Sales Order Archive"
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
