/// <summary>
/// Page Shpfy Order Attributes (ID 30114).
/// </summary>
page 30114 "Shpfy Order Attributes"
{

    Caption = 'Shopify Order Attributes';
    PageType = ListPart;
    SourceTable = "Shpfy Order Attribute";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Key"; Rec."Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'The key or name of the attribute.';
                }
                field(Value; Rec.Value)
                {
                    ApplicationArea = All;
                    ToolTip = 'The value of the attribute.';
                }
            }
        }
    }

}
