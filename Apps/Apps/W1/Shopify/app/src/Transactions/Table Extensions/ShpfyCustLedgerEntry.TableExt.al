namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Receivables;

tableextension 30201 "Shpfy Cust. Ledger Entry" extends "Cust. Ledger Entry"
{
    fields
    {
        field(30100; "Shpfy Transaction Id"; BigInteger)
        {
            Caption = 'Shopify Transaction Id';
            DataClassification = SystemMetadata;
            Editable = false;
        }
    }
}