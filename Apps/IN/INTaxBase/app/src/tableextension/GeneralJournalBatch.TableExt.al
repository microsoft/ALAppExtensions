tableextension 18552 "General Journal Batch" extends "Gen. Journal Batch"
{
    fields
    {
        field(18552; "Location Code"; Code[10])
        {
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = Location;
        }
    }
}