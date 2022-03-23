/// <summary>
/// PageExtension Shpfy Post. Sales Ships.Ext. (ID 30110) extends Record Posted Sales Shipments.
/// </summary>
pageextension 30110 "Shpfy Post. Sales Ships.Ext." extends "Posted Sales Shipments"
{
    layout
    {
        addafter("Package Tracking No.")
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