/// <summary>
/// Page Shpfy Order Subform (ID 30122).
/// </summary>
page 30122 "Shpfy Order Subform"
{
    Caption = 'Shopify Order Lines';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "Shpfy Order Line";

    layout
    {
        area(content)
        {
            repeater(Group9)
            {
                field(ShopifyProductId; Rec."Shopify Product Id")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies a unique identifier for the product.';
                }
                field(ShopifyVariantId; Rec."Shopify Variant Id")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies a unique identifier for the variant.';
                }
                field(ItemNo; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the item number.';
                }
                field(UnitOfMeasureCode; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies how each unit of the item is measured.';
                }
                field(VariantCode; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the variant of the item on the line.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the description of the product to be sold.';
                }
                field(VariantDescription; Rec."Variant Description")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the description of the variant to be sold.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies how many units are being sold.';
                }
                field(UnitPrice; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the prices for one unit on the line.';
                }
                field(DiscountAmount; Rec."Discount Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the discount amount that is granted for the item on the line.';
                }
                field(FullfillableQuantity; Rec."Fulfillable Quantity")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the quantity available to fulfill.';
                }
            }
        }
    }
}

