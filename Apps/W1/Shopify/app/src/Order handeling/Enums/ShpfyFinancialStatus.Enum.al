/// <summary>
/// Enum Shpfy Financial Status (ID 30117).
/// </summary>
enum 30117 "Shpfy Financial Status"
{
    Access = Internal;
    Caption = 'Shopify Financial Status';
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Pending)
    {
        Caption = 'Pending';
    }
    value(2; authorized)
    {
        Caption = 'Authorized';
    }
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
