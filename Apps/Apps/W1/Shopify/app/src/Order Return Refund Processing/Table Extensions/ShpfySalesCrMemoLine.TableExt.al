namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.History;

tableextension 30109 "Shpfy Sales Cr.Memo Line" extends "Sales Cr.Memo Line"
{
    fields
    {
        field(30103; "Shpfy Refund Id"; BigInteger)
        {
            Caption = 'Shopify Refund Id';
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