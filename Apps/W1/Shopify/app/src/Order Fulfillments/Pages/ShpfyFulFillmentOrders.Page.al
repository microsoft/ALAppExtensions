page 30141 "Shpfy Fulfillment Orders"
{
    ApplicationArea = All;
    Caption = 'Fulfillment Orders';
    PageType = List;
    SourceTable = "Shpfy FulFillment Order Header";
    CardPageId = "Shpfy Fulfillment Order Card";

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
                field("Shopify Order Id"; Rec."Shopify Order Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shopify Order Id field.';
                }
                field("Shop Code"; Rec."Shop Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shop Code field.';
                }
                field("Shop Id"; Rec."Shop Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shop Id field.';
                }
            }
        }
    }
}