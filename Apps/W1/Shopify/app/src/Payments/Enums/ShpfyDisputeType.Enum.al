namespace Microsoft.Integration.Shopify;

enum 30151 "Shpfy Dispute Type"
{
    /// <summary>
    /// Enum Shpfy Dispute Type (ID 30151).
    /// </summary>
    /// 
    Caption = 'Shopify Dispute Type';

    value(0; Unknown)
    {
        Caption = ' ';
    }
    value(1; Inquiry)
    {
        Caption = 'Inquiry';
    }
    value(2; Chargeback)
    {
        Caption = 'Chargeback';
    }
}