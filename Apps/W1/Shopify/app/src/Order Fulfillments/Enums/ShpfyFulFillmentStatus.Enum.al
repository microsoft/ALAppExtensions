/// <summary>
/// Enum Shpfy FulFillment Status (ID 30112).
/// </summary>
enum 30112 "Shpfy Fulfillment Status"
{
    Access = Internal;
    Caption = 'Shopify FulFillment Status';
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Pending)
    {
        Caption = 'Pending';
    }
    value(2; Open)
    {
        Caption = 'Open';
    }
    value(3; Success)
    {
        Caption = 'Success';
    }
    value(4; Cancelled)
    {
        Caption = 'Cancelled';
    }
    value(5; Error)
    {
        Caption = 'Error';
    }
    value(6; Failure)
    {
        Caption = 'Failure';
    }

}
