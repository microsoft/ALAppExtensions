namespace Microsoft.Sustainability.Setup;

using Microsoft.Foundation.UOM;
using Microsoft.Inventory.Location;

tableextension 6226 "Responsibility Center - TabExt" extends "Responsibility Center"
{
    fields
    {
        field(6210; "Water Capacity Dimension"; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Water Capacity Dimension';
        }
        field(6211; "Water Capacity Quantity(Month)"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Water Capacity Quantity(Month)';
            DecimalPlaces = 2 : 2;
        }
        field(6212; "Water Capacity Unit"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Water Capacity Unit';
            TableRelation = "Unit of Measure";
        }
    }
}