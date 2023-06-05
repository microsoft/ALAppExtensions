/// <summary>
/// Describes possible values for the Write header.
/// </summary>
enum 8951 "AFS Write"
{
    Access = Public;
    Extensible = false;

    /// <summary>
    /// Indicates that the data should be updated.
    /// </summary>
    value(0; Update)
    {
        Caption = 'update', Locked = true;
    }
    /// <summary>
    /// Indicates that the data should be cleared.
    /// </summary>
    value(1; Clear)
    {
        Caption = 'clear', Locked = true;
    }
}