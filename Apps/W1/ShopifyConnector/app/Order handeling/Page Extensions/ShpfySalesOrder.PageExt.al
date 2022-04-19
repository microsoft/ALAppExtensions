/// <summary>
/// PageExtension Shpfy Sales Order (ID 30115) extends Record Sales Order.
/// </summary>
pageextension 30115 "Shpfy Sales Order" extends "Sales Order"
{
    layout
    {
        addafter("Your Reference")
        {
            field(ShpfyOrderNo; Rec."Shpfy Order No.")
            {
                ApplicationArea = All;
                DrillDown = true;
                ToolTip = 'Specifies the order number from Shopify';
                Importance = Additional;
                Visible = false;

                trigger OnDrillDown()
                var
                    ShopifyOrderMgt: Codeunit "Shpfy Order Mgt.";
                    VariantRec: Variant;
                begin
                    VariantRec := Rec;
                    ShopifyOrderMgt.ShowShopifyOrder(VariantRec);
                end;
            }
            field("ShpfyShopify Risk Level"; Rec."Shpfy Risk Level")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the risk level from the Shopify order.';
                Visible = false;
            }
        }
    }
}