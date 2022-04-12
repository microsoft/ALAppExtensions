/// <summary>
/// Enum Shpfy Order Fulfillment Status (ID 30113).
/// </summary>
enum 30113 "Shpfy Order Fulfill. Status"
{
    Access = Internal;
    Caption = 'Shopify Order Fulfill. Status';
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(2; Fulfilled)
    {
        Caption = 'Fulfilled';
    }
    value(3; In_Progress)
    {
        Caption = 'In Progress';
    }
    value(4; Open)
    {
        Caption = 'Open';
    }
    value(5; Pending_Fulfillment)
    {
        Caption = 'Pending Fulfillment';
    }
    value(6; Restocked)
    {
        Caption = 'Restocked';
    }
    value(7; Unfilfilled)
    {
        Caption = 'Unfulfilled';
    }
    value(8; "Partially Fulfilled")
    {
        Caption = 'Partially Fulfilled';
    }
}