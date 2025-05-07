namespace Microsoft.Integration.Shopify;

enum 30154 "Shpfy Dispute Status"
{

    Caption = 'Shopify Dispute Status';
    Extensible = false;

    value(0; Unknown)
    {
        Caption = ' ';
    }
    value(1; "Needs Response")
    {
        Caption = 'Needs Response';
    }
    value(2; "Under Review")
    {
        Caption = 'Under Review';
    }
#if not CLEAN26
    value(3; "Charge Refunded")
    {
        Caption = 'Charge Refunded';
        ObsoleteReason = 'Charge Refunded is no longer supported by Shopify.';
        ObsoleteState = Pending;
        ObsoleteTag = '26.0';
    }
#endif
    value(4; "Accepted")
    {
        Caption = 'Accepted';
    }
    value(5; "Won")
    {
        Caption = 'Won';
    }
    value(6; "Lost")
    {
        Caption = 'Lost';
    }
}