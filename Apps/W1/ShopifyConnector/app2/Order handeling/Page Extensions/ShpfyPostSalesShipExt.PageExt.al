/// <summary>
/// PageExtension Shpfy Post. Sales Ship. Ext. (ID 30108) extends Record Posted Sales Shipment.
/// </summary>
pageextension 30108 "Shpfy Post. Sales Ship. Ext." extends "Posted Sales Shipment"
{
    layout
    {
        addafter("External Document No.")
        {
            field(ShpfyOrderNo; Rec."Shpfy Order No.")
            {
                ApplicationArea = All;
                DrillDown = true;
                ToolTip = 'Specifies the order number from Shopify';

                trigger OnDrillDown()
                var
                    ShopifyOrderMgt: Codeunit "Shpfy Order Mgt.";
                    VariantRec: Variant;
                begin
                    VariantRec := Rec;
                    ShopifyOrderMgt.ShowShopifyOrder(VariantRec);
                end;
            }
        }
    }
}