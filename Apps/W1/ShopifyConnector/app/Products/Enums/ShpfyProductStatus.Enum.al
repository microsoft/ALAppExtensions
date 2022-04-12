/// <summary>
/// Enum Shpfy Product Status (ID 30130).
/// </summary>
enum 30130 "Shpfy Product Status"
{
    Access = Internal;
    Caption = 'Shopify Product Status';

    value(0; Active)
    {
        Caption = 'Active';
    }
    value(1; Archived)
    {
        Caption = 'Archived';
    }
    value(2; Draft)
    {
        Caption = 'Draft';
    }

}
