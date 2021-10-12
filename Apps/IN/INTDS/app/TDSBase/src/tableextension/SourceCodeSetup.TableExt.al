tableextension 18685 "Source Code Setup" extends "Source Code Setup"
{
    fields
    {
        field(18685; "TDS Adjustment Journal"; code[10])
        {
            Caption = 'TDS Adjustment Journal';
            DataClassification = CustomerContent;
            TableRelation = "Source Code";
        }
        field(18686; "TDS Above Threshold Opening"; code[10])
        {
            Caption = 'TDS Over & Above Threshold Opening';
            DataClassification = CustomerContent;
            TableRelation = "Source Code";
        }
    }
}