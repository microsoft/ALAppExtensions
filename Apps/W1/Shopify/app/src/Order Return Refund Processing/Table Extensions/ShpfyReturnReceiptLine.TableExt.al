tableextension 30111 "Shpfy Return Receipt Line" extends "Return Receipt Line"
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

        field(30104; "Shpfy Refund Line Id"; BigInteger)
        {
            Caption = 'Shopify Refund Line Id';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}