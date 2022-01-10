enumextension 31003 "EET Applied Document Type CZZ" extends "EET Applied Document Type CZL"
{
#if not CLEAN20
    value(31000; Advance)
    {
        Caption = 'Advance';
        ObsoleteState = Pending;
        ObsoleteReason = 'Will be replaced by enum value with affix CZZ.';
        ObsoleteTag = '20.0';
    }
#else
    value(31000; "Advance CZZ")
    {
        Caption = 'Advance';
    }
#endif
}