enum 11780 "Default VAT Date CZL"
{
    Extensible = true;
#if not CLEAN22
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';
    ObsoleteReason = 'Replaced by VAT Reporting Date and changed access to internal.';
#else
    Access = Internal;
#endif

    value(0; "Posting Date")
    {
        Caption = 'Posting Date';
    }
    value(1; "Document Date")
    {
        Caption = 'Document Date';
    }
    value(2; Blank)
    {
        Caption = 'Blank';
    }
}
