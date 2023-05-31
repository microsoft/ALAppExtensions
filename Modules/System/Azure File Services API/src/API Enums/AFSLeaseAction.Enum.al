enum 50109 "AFS Lease Action"
{
    Access = Internal;
    Extensible = false;

    /// <summary>
    /// Requests a new lease.
    /// </summary>
    value(0; Acquire)
    {
        Caption = 'acquire', Locked = true;
    }

    /// <summary>
    /// Renews the lease.
    /// </summary>
    value(1; Renew)
    {
        Caption = 'renew', Locked = true;
    }

    /// <summary>
    /// Changes the lease ID of an active lease.
    /// </summary>
    value(2; Change)
    {
        Caption = 'change', Locked = true;
    }

    /// <summary>
    /// Releases the lease
    /// </summary>
    value(3; Release)
    {
        Caption = 'release', Locked = true;
    }

    /// <summary>
    /// Breaks the lease, if the file has an active lease
    /// </summary>
    value(4; Break)
    {
        Caption = 'break', Locked = true;
    }
}