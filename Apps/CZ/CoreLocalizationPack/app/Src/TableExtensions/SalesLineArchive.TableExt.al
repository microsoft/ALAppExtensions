tableextension 31016 "Sales Line Archive CZL" extends "Sales Line Archive"
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