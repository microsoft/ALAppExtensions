tableextension 18547 "Purchase Header Ext" extends "Purchase Header"
{
    fields
    {
        field(18543; "State"; Code[10])
        {
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = State;
        }
    }
}