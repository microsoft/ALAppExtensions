/// <summary>
/// Enum Shpfy Financial Status (ID 30117).
/// </summary>
enum 30117 "Shpfy Financial Status"
{
    Caption = 'Shopify Financial Status';
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Pending)
    {
        Caption = 'Pending';
    }
#pragma warning disable AS0082
    value(2; Authorized)
    {
        Caption = 'Authorized';
    }
#pragma warning restore AS0082
    value(3; "Partially Paid")
    {
        Caption = 'Partially Paid';
    }
    value(4; Paid)
    {
        Caption = 'Paid';
    }
    value(5; "Partially Refunded")
    {
        Caption = 'Partially Refunded';
    }
    value(6; Refunded)
    {
        Caption = 'Refunded';
    }
    value(7; Voided)
    {
        Caption = 'Voided';
    }
    value(99; Unknown)
    {
        Caption = 'Unknown';
    }
}
