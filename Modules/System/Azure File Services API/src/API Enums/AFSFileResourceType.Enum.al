/// <summary>
/// Indicator of what type the resource is.
/// </summary>
enum 50105 "AFS File Resource Type"
{
    Access = Public;
    Extensible = false;

    /// <summary>
    ///  Indicates entry is of file type.
    /// </summary>
    value(0; File)
    {
        Caption = 'File', Locked = true;
    }
    /// <summary>
    ///  Indicates entry is of directory type.
    /// </summary>
    value(1; Directory)
    {
        Caption = 'Directory', Locked = true;
    }
}