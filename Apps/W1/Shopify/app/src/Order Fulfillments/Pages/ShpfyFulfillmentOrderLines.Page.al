page 30139 "Shpfy Fulfillment Order Lines"
{
    ApplicationArea = All;
    Caption = 'Fulfillment Order Lines';
    PageType = ListPart;
    SourceTable = "Shpfy FulFillment Order Line";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Shopify Fulfillment Order Id"; Rec."Shopify Fulfillment Order Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shopify Fulfillment Order Id field.';
                }
                field("Shopify Fulfillm. Ord. Line Id"; Rec."Shopify Fulfillm. Ord. Line Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shopify Fulfillm. Ord. Line Id field.';
                }
                field("Shopify Location Id"; Rec."Shopify Location Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shopify Location Id field.';
                }
                field("Shopify Order Id"; Rec."Shopify Order Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shopify Order Id field.';
                }
                field("Shopify Product Id"; Rec."Shopify Product Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shopify Product Id field.';
                }
                field("Shopify Variant Id"; Rec."Shopify Variant Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shopify Variant Id field.';
                }
                field("Quantity to Fulfill"; Rec."Quantity to Fulfill")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Qty. to Fulfill field.';
                }
                field("Remaining Quantity"; Rec."Remaining Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Remaining Quantity field.';
                }
                field("Total Quantity"; Rec."Total Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Total Quantity field.';
                }
            }
        }
    }
}