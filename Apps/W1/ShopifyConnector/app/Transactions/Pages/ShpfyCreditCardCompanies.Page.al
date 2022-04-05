/// <summary>
/// Page Shpfy Credit Card Companies (ID 30130).
/// </summary>
page 30130 "Shpfy Credit Card Companies"
{
    Caption = 'Shopify Credit Card Companies';
    PageType = List;
    SourceTable = "Shpfy Credit Card Company";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the company that issued the customer''s credit card.';
                }
            }
        }
    }

}
