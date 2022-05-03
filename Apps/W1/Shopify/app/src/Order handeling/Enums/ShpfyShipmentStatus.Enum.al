/// <summary>
/// Enum Shpfy Shipment Status (ID 30119).
/// </summary>
enum 30119 "Shpfy Shipment Status"
{
    Access = Internal;
    Caption = 'Shopify Shipment Status';
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "Label Printed")
    {
        Caption = 'Label Printed';
    }
    value(2; "Label Purchased")
    {
        Caption = 'Label Purchased';
    }
    value(3; "Ready for Pickup")
    {
        Caption = 'Ready for Pickup';
    }
    value(4; Confirmed)
    {
        Caption = 'Confirmed';
    }
    value(5; "In Transit")
    {
        Caption = 'In Transit';
    }
    value(6; "Out for Delivery")
    {
        Caption = 'Out for Delivery';
    }
    value(7; Delivered)
    {
        Caption = 'Delivered';
    }
    value(8; Failure)
    {
        Caption = 'Failure';
    }
    value(9; "Attempted Delivery")
    {
        Caption = 'Attempted Delivery';
    }
}
