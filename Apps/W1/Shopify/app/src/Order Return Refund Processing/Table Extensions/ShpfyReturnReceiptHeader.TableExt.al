tableextension 30110 "Shpfy Return Receipt Header" extends "Return Receipt Header"
{
    fields
    {
        field(30103; "Shpfy Refund Id"; BigInteger)
        {
            Caption = 'Shpfy Refund Id';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = "Shpfy Refund Header"."Refund Id";
        }
    }
}