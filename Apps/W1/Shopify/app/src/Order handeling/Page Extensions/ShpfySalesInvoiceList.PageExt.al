/// <summary>
/// PageExtension Shpfy Sales Invoice List (ID 30112) extends Record Sales Invoice List.
/// </summary>
pageextension 30112 "Shpfy Sales Invoice List" extends "Sales Invoice List"
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
        }
    }
}