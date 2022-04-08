/// <summary>
/// Enum Shpfy Transaction Status (ID 30133).
/// </summary>
enum 30133 "Shpfy Transaction Status"
{
    Access = Internal;
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Pending)
    {
        Caption = 'Pending';
    }
    value(2; Failure)
    {
        Caption = 'Failure';
    }
    value(3; Success)
    {
        Caption = 'Success';
    }
    value(4; Error)
    {
        Caption = 'Error';
    }

}
