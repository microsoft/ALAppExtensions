/// <summary>
/// PageExtension Shpfy Posted Sales Invoices (ID 30107) extends Record Posted Sales Invoices.
/// </summary>
pageextension 30107 "Shpfy Posted Sales Invoices" extends "Posted Sales Invoices"
{
    layout
    {
        addafter("Order No.")
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