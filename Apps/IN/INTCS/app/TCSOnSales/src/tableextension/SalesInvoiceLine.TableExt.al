tableextension 18839 "Sales Invoice Line" extends "Sales Invoice Line"
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