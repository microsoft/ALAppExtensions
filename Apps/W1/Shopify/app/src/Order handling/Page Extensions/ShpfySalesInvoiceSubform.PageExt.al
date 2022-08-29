/// <summary>
/// PageExtension Shpfy Sales Invoice Subform (ID 30114) extends Record Sales Invoice Subform.
/// </summary>
pageextension 30114 "Shpfy Sales Invoice Subform" extends "Sales Invoice Subform"
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