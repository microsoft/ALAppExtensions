tableextension 31017 "Purchase Line Archive CZL" extends "Purchase Line Archive"
{
    fields
    {
        field(31064; "Physical Transfer CZL"; Boolean)
        {
            Caption = 'Physical Transfer';
            DataClassification = CustomerContent;
        }
    }
}