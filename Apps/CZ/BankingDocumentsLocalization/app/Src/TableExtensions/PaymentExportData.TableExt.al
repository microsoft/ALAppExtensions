tableextension 31287 "Payment Export Data CZB" extends "Payment Export Data"
{
    fields
    {
        field(11710; "Specific Symbol CZB"; Code[10])
        {
            Caption = 'Specific Symbol';
            CharAllowed = '09';
            DataClassification = CustomerContent;
        }
        field(11711; "Variable Symbol CZB"; Code[10])
        {
            Caption = 'Variable Symbol';
            CharAllowed = '09';
            DataClassification = CustomerContent;
        }
        field(11712; "Constant Symbol CZB"; Code[10])
        {
            Caption = 'Constant Symbol';
            CharAllowed = '09';
            TableRelation = "Constant Symbol CZL";
            DataClassification = CustomerContent;
        }
    }
}
