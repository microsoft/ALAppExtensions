tableextension 18810 "Source Code Setup" extends "Source Code Setup"
{
    fields
    {
        field(18807; "TCS Adjustment Journal"; code[10])
        {
            Caption = 'TCS Adjustment Journal';
            DataClassification = CustomerContent;
            TableRelation = "Source Code";
        }
    }
}
