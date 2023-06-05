/// <summary>
/// Describes possible values of the additional AFS properties.
/// </summary>
enum 8953 "AFS Properties"
{
    Access = Public;
    Extensible = false;

    /// <summary>
    /// Indicates the the Timestamps should be included in the response.
    /// </summary>
    value(0; Timestamps)
    {
        Caption = 'Timestamps', Locked = true;
    }
    /// <summary>
    /// Indicates the the ETag should be included in the response.
    /// </summary>
    value(1; ETag)
    {
        Caption = 'ETag', Locked = true;
    }
    /// <summary>
    /// Indicates the the Attributes should be included in the response.
    /// </summary>
    value(2; Attributes)
    {
        Caption = 'Attributes', Locked = true;
    }
    /// <summary>
    /// Indicates the the PermissionKey should be included in the response.
    /// </summary>
    value(3; PermissionKey)
    {
        Caption = 'PermissionKey', Locked = true;
    }
}