pageextension 11743 "Posted Return Shipment CZL" extends "Posted Return Shipment"
{
    layout
    {
        addafter("Currency Code")
        {
            field("EU 3-Party Trade CZL"; Rec."EU 3-Party Trade CZL")
            {
                ApplicationArea = PurchReturnOrder;
                Editable = false;
                ToolTip = 'Specifies whether the document is part of a three-party trade.';
            }
        }
    }
}