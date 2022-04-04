enumextension 31251 "Manual Setup Category CZB" extends "Manual Setup Category"
{
#if not CLEAN20
    value(31250; "Banking Documents CZZ")
    {
        Caption = 'Banking Documents';
        ObsoleteState = Pending;
        ObsoleteReason = 'Will be replaced by enum value with affix CZB.';
        ObsoleteTag = '20.0';
    }
#else
    value(31250; "Banking Documents CZB")
    {
        Caption = 'Banking Documents';
    }
#endif
}
