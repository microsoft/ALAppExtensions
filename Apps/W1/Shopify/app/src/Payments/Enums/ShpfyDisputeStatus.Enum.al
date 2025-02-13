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
    value(3; "Charge Refunded")
    {
        Caption = 'Charge Refunded';
    }
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