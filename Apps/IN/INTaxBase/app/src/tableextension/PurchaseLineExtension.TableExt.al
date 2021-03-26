tableextension 18548 "PurchaseLineExtension" extends "Purchase Line"
{
    fields
    {
        field(18543; "Work Tax Nature Of Deduction"; Code[10])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18544; "State Code"; Code[10])
        {
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = State;
        }
    }
}