pageextension 11770 "Posted Service Shipment CZL" extends "Posted Service Shipment"
{
    layout
    {
        addafter("EU 3-Party Trade")
        {
            field("EU 3-Party Intermed. Role CZL"; Rec."EU 3-Party Intermed. Role CZL")
            {
                ApplicationArea = Service;
                Editable = false;
                ToolTip = 'Specifies when the service header will use European Union third-party intermediate trade rules. This option complies with VAT accounting standards for EU third-party trade.';
            }
        }
    }
}