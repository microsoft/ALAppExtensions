/// <summary>
/// Page Shpfy Shipment Methods Mapping (ID 30129).
/// </summary>
page 30129 "Shpfy Shipment Methods Mapping"
{
    Caption = 'Shopify Shipment Methods';
    PageType = List;
    SourceTable = "Shpfy Shipment Method Mapping";
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
                field("Code"; Rec."Shipment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shipping method in D365BC.';
                }
            }
        }
    }

}
