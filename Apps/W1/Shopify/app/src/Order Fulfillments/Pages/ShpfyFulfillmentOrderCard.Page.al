page 30140 "Shpfy Fulfillment Order Card"
{
    ApplicationArea = All;
    Caption = 'Fulfillment Order Card';
    PageType = Card;
    SourceTable = "Shpfy FulFillment Order Header";

    layout
    {
        area(content)
        {
            group(General)
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
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field.';
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
            part(Lines; "Shpfy Fulfillment Order Lines")
            {
                ApplicationArea = All;
                Caption = 'Lines';
                SubPageLink = "Shopify Fulfillment Order Id" = field("Shopify Fulfillment Order Id");
            }
        }
    }
}