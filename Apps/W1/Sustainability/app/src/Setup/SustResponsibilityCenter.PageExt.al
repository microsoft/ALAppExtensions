namespace Microsoft.Sustainability.Setup;
using Microsoft.Inventory.Location;

pageextension 6226 "Sust. Responsibility Center" extends "Responsibility Center Card"
{
    layout
    {
        addafter(Communication)
        {

            group(Sustainability)
            {
                Caption = 'Sustainability';
                field("Water Capacity Dimension"; Rec."Water Capacity Dimension")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the capacity dimension. For example, Area or Volume.';
                }
                field("Water Capacity Quantity"; Rec."Water Capacity Quantity(Month)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total water capacity quantity of the responsibility center.';
                }
                field("Water Capacity Unit"; Rec."Water Capacity Unit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unit of measure that describes capacity quantity.';
                }
            }
        }
    }
}