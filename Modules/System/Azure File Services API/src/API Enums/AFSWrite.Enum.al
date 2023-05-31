enum 50102 "AFS Write"
{
    Access = Public;
    Extensible = false;

    value(0; Update)
    {
        Caption = 'update', Locked = true;
    }
    value(1; Clear)
    {
        Caption = 'clear', Locked = true;
    }
}