/// <summary>
/// PageExtension Shpfy Sales Invoice (ID 30113) extends Record Sales Invoice.
/// </summary>
pageextension 30113 "Shpfy Sales Invoice" extends "Sales Invoice"
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
        }
    }
}