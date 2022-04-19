/// <summary>
/// PageExtension Shpfy Sales Order Subform (ID 30117) extends Record Sales Order Subform.
/// </summary>
pageextension 30117 "Shpfy Sales Order Subform" extends "Sales Order Subform"
{
    layout
    {
        addafter("Item Reference No.")
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