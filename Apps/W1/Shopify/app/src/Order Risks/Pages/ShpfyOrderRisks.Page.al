/// <summary>
/// Page Shpfy Order Risks (ID 30123).
/// </summary>
page 30123 "Shpfy Order Risks"
{
    Caption = 'Shopify Order Risks';
    PageType = List;
    SourceTable = "Shpfy Order Risk";
    UsageCategory = None;
    SourceTableView = where(Display = const(true));
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Level; Rec.Level)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the level of the Shopify Order Risk.';
                }
                field("Message"; Rec.Message)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the message that''s displayed to the merchant to indicate the results of the fraud check.';
                }
            }
        }
    }

}
