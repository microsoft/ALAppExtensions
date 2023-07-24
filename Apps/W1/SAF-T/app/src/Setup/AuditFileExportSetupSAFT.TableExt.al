tableextension 5283 "Audit File Export Setup SAF-T" extends "Audit File Export Setup"
{
    fields
    {
        field(5280; "SAF-T Modification"; Enum "SAF-T Modification") { }
        field(5281; "Dimension No."; Integer) { }
        field(5282; "Not Applicable VAT Code"; Code[9]) { }
        field(5283; "Default Payment Method Code"; Code[10])
        {
            TableRelation = "Payment Method";
        }
    }
}