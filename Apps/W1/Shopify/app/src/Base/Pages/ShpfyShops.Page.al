/// <summary>
/// Page Shpfy Shops (ID 30102).
/// </summary>
page 30102 "Shpfy Shops"
{
    ApplicationArea = All;
    Caption = 'Shopify Shops';
    CardPageId = "Shpfy Shop Card";
    PageType = List;
    SourceTable = "Shpfy Shop";
    UsageCategory = Administration;
    Editable = false;
    DeleteAllowed = true;
    InsertAllowed = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a code to identify this Shopify Shop.';
                }
                field(ShopifyURL; Rec."Shopify URL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the URL of the Shopify Shop.';
                }
                field(LanguageCode; Rec."Language Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the language of the Shopify Shop.';
                }
            }
        }
    }
}