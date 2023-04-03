#if not CLEAN22
enumextension 11703 "Batch Posting Param. Type CZL" extends "Batch Posting Parameter Type"
{
    value(11700; "VAT Date CZL")
    {
        Caption = 'VAT Date';
        ObsoleteState = Pending;
        ObsoleteTag = '22.0';
        ObsoleteReason = 'Replaced by VAT Date.';
    }
    value(11701; "Replace VAT Date CZL")
    {
        Caption = 'Replace VAT Date';
        ObsoleteState = Pending;
        ObsoleteTag = '22.0';
        ObsoleteReason = 'Replaced by Replace VAT Date.';
    }
}
#endif