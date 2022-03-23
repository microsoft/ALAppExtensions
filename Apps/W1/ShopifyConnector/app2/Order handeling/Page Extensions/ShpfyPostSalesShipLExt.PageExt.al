/// <summary>
/// PageExtension Shpfy Post.Sales Ship.L.Ext. (ID 30109) extends Record Posted Sales Shipment Lines.
/// </summary>
pageextension 30109 "Shpfy Post.Sales Ship.L.Ext." extends "Posted Sales Shipment Lines"
{
    layout
    {
        addafter("Document No.")
        {
            field(ShpfyOrderNo; Rec."Shpfy Order No.")
            {
                ApplicationArea = All;
                DrillDown = true;
                Visible = false;
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