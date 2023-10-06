namespace Microsoft.Integration.Shopify;

page 30142 "Shpfy Shop Selection"
{
    PageType = List;
    SourceTable = "Shpfy Shop";
    Editable = false;
    Caption = 'Select a Shopify shop';

    layout
    {
        area(Content)
        {
            repeater(Control)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Shopify shop code.';
                    Editable = false;
                }
                field("Shopify URL"; Rec."Shopify URL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the URL of the Shopify shop.';
                    Editable = false;
                }
            }
        }
    }
}