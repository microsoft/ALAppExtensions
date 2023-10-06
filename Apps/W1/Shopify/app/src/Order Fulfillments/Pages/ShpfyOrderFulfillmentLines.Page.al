namespace Microsoft.Integration.Shopify;

page 30154 "Shpfy Order Fulfillment Lines"
{
    ApplicationArea = All;
    Caption = 'Shopify Fulfillment Lines';
    PageType = ListPart;
    SourceTable = "Shpfy Fulfillment Line";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Shopify Fulfillment Id"; Rec."Fulfillment Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shopify Fulfillment Id field.';
                }
                field("Shopify Fulfillment Line Id"; Rec."Fulfillment Line Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shopify Fulfillment Line Id field.';
                }
                field("Shopify Order Id"; Rec."Order Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shopify Order Id field.';
                }
                field("Shopify Order Line Id"; Rec."Order Line Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shopify Order Line Id field.';
                }
                field("Quantity"; Rec."Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field.';
                }
                field("Is Gift Card"; Rec."Is Gift Card")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Is Gift Card field.';
                }
            }
        }
    }
}