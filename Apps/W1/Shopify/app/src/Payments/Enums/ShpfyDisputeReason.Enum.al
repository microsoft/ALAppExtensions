namespace Microsoft.Integration.Shopify;

enum 30153 "Shpfy Dispute Reason"
{
    Caption = 'Shopify Dispute Reason';
    Extensible = false;

    value(0; Unknown)
    {
        Caption = 'Unknown';
    }
    value(1; "Bank Not Process")
    {
        Caption = 'Bank Not Process';
    }
    value(2; "Credit Not Processed")
    {
        Caption = 'Credit Not Processed';
    }
    value(3; "Customer Initiated")
    {
        Caption = 'Customer Initiated';
    }
    value(4; "Debit Not Authorized")
    {
        Caption = 'Debit Not Authorized';
    }
    value(5; Duplicate)
    {
        Caption = 'Duplicate';
    }
    value(6; Fraudulent)
    {
        Caption = 'Fraudulent';
    }
    value(7; General)
    {
        Caption = 'General';
    }
    value(8; "Incorrect Account Details")
    {
        Caption = 'Incorrect Account Details';
    }
    value(9; "Insufficient Funds")
    {
        Caption = 'Insufficient Funds';
    }
    value(10; "Product Not Received")
    {
        Caption = 'Product Not Received';
    }
    value(11; "Product Unacceptable")
    {
        Caption = 'Product Unacceptable';
    }
    value(12; "Subscription Canceled")
    {
        Caption = 'Subscription Canceled';
    }
    value(13; Unrecognized)
    {
        Caption = 'Unrecognized';
    }
}