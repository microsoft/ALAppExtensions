enum 31000 "VAT Ctrl. Report Format CZL" implements "VAT Control Report Export CZL"
{
    Extensible = true;

    value(0; "02_01_03")
    {
        Caption = 'KH 02.01.03', Locked = true;
        Implementation = "VAT Control Report Export CZL" = "VAT Control Report DPHKH1 CZL";
    }
    value(1; "03_01_03")
    {
        Caption = 'KH 03.01.03', Locked = true;
        Implementation = "VAT Control Report Export CZL" = "VAT Control Report DPHKH1 CZL";
    }
}
