/// <summary>
/// Page Shpfy Shipment Methods (ID 30129).
/// </summary>
page 30129 "Shpfy Shipment Methods"
{
    Caption = 'Shopify Shipment Methods';
    PageType = List;
    SourceTable = "Shpfy Shipment Method";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the delivery method in Shopify.';
                }
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shipping method in D365BC.';
                }
            }
        }
    }

}
