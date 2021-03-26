tableextension 18546 "LocationExt" extends Location
{
    fields
    {
        field(18543; "State Code"; Code[10])
        {
            TableRelation = "State";
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18544; "T.A.N. No."; Code[10])
        {
            TableRelation = "TAN Nos.";
            DataClassification = EndUserIdentifiableInformation;
        }
    }
}