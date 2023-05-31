enum 50103 "AFS File Last Write Time"
{
    Access = Public;
    Extensible = false;

    value(0; Now)
    {
        Caption = 'now', Locked = true;
    }
    value(1; Preserve)
    {
        Caption = 'preserve', Locked = true;
    }
}