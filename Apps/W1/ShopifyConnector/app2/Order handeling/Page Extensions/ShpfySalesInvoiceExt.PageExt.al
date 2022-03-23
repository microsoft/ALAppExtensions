/// <summary>
/// PageExtension Shpfy Sales Invoice Ext. (ID 30113) extends Record Sales Invoice.
/// </summary>
pageextension 30113 "Shpfy Sales Invoice Ext." extends "Sales Invoice"
{
    layout
    {
        addafter(General)
        {
            group(Shpfy)
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
}