tableextension 18845 "Sales Cr.Memo Header" extends "Sales Cr.Memo Header"
{
    fields
    {
        field(18839; "Exclude GST in TCS Base"; Boolean)
        {
            Caption = 'Exclude GST in TCS Base';
            DataClassification = EndUserIdentifiableInformation;
            editable = false;
        }
    }
}