tableextension 18842 "Sales Cr. Memo Line" extends "Sales Cr.Memo Line"
{
    fields
    {
        field(18838; "TCS Nature of Collection"; Code[10])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18839; "Assessee Code"; Code[10])
        {
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
    }
}