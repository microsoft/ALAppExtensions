tableextension 31014 "Transfer Receipt Header CZL" extends "Transfer Receipt Header"
{
    fields
    {
        field(31069; "Intrastat Exclude CZL"; Boolean)
        {
            Caption = 'Intrastat Exclude';
            DataClassification = CustomerContent;
        }
    }
}