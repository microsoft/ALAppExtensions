tableextension 31269 "Std. Item Journal Line CZA" extends "Standard Item Journal Line"
{
    fields
    {
        field(31050; "New Location Code CZA"; Code[10])
        {
            Caption = 'New Location Code';
            TableRelation = Location;

            trigger OnValidate()
            begin
                TestField("Entry Type", "Entry Type"::Transfer);
            end;
        }
    }
}
