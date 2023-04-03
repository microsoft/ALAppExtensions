/// <summary>
/// Enum Shpfy Order Fulfillment Status (ID 30113).
/// </summary>
enum 30113 "Shpfy Order Fulfill. Status"
{
    Caption = 'Shopify Order Fulfill. Status';
    Extensible = false;

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
#pragma warning disable AS0082
    value(7; Unfulfilled)
    {
        Caption = 'Unfulfilled';
    }
#pragma warning restore AS0082
    value(8; "Partially Fulfilled")
    {
        Caption = 'Partially Fulfilled';
    }
}