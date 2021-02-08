pageextension 11776 "Purch. Return Order Arch. CZL" extends "Purchase Return Order Archive"
{
    layout
    {
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
