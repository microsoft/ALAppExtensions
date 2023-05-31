enum 50106 "AFS File Attribute"
{
    Extensible = false;

    value(0; "Read Only")
    {
        Caption = 'ReadOnly', Locked = true;
    }
    value(1; Hidden)
    {
        Caption = 'Hidden', Locked = true;
    }
    value(2; System)
    {
        Caption = 'System', Locked = true;
    }
    value(3; "None")
    {
        Caption = 'None', Locked = true;
    }
    value(4; Archive)
    {
        Caption = 'Archive', Locked = true;
    }
    value(5; "Temporary")
    {
        Caption = 'Temporary', Locked = true;
    }
    value(6; Offline)
    {
        Caption = 'Offline', Locked = true;
    }
    value(7; "Not Content Indexed")
    {
        Caption = 'NotContentIndexed', Locked = true;
    }
    value(8; "No Scrub Data")
    {
        Caption = 'NoScrubData', Locked = true;
    }
}