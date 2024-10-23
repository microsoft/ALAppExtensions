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
                    ToolTip = 'Specifies the responsibility center''s Water Capacity Dimension.';
                }
                field("Water Capacity Quantity"; Rec."Water Capacity Quantity(Month)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the responsibility center''s Water Capacity Quantity.';
                }
                field("Water Capacity Unit"; Rec."Water Capacity Unit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the responsibility center''s Water Capacity Unit.';
                }
            }
        }
    }
}