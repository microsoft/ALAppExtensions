namespace Microsoft.Integration.Shopify;

enum 30152 "Shpfy Dispute Reason"
{
    /// <summary>
    /// Enum Shpfy Dispute Reason (ID 30152).
    /// </summary>
    /// 
    Caption = 'Shopify Dispute Reason';
    Extensible = true;


    value(0; Unknown)
    {
        Caption = 'Unknown';
    }
    value(1; bank_not_process)
    {
        Caption = 'Bank Not Process';
    }
    value(2; credit_not_processed)
    {
        Caption = 'Credit Not Processed';
    }
    value(3; customer_initiated)
    {
        Caption = 'Customer Initiated';
    }
    value(4; debit_not_authorized)
    {
        Caption = 'Debit Not Authorized';
    }
    value(5; duplicate)
    {
        Caption = 'Duplicate';
    }
    value(6; fraudulent)
    {
        Caption = 'Fraudulent';
    }
    value(7; general)
    {
        Caption = 'General';
    }
    value(8; incorrect_account_details)
    {
        Caption = 'Incorrect Account Details';
    }
    value(9; insufficient_funds)
    {
        Caption = 'Insufficient Funds';
    }
    value(10; product_not_received)
    {
        Caption = 'Product Not Received';
    }
    value(11; product_unacceptable)
    {
        Caption = 'Product Unacceptable';
    }
    value(12; subscription_canceled)
    {
        Caption = 'Subscription Canceled';
    }
    value(13; unrecognized)
    {
        Caption = 'Unrecognized';
    }
}