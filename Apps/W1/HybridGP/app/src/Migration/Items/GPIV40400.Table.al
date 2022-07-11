table 40117 "GP IV40400"
{
    Description = 'Item Class Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; ITMCLSCD; Text[11])
        {
            DataClassification = CustomerContent;
        }
        field(2; ITMCLSDC; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(3; DEFLTCLS; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(4; NOTEINDX; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(5; ITEMTYPE; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(6; ITMTRKOP; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(7; LOTTYPE; Text[11])
        {
            DataClassification = CustomerContent;
        }
        field(8; KPERHIST; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(9; KPTRXHST; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(10; KPCALHST; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(11; KPDSTHST; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(12; ALWBKORD; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(13; ITMGEDSC; Text[11])
        {
            DataClassification = CustomerContent;
        }
        field(14; TAXOPTNS; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(15; ITMTSHID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(16; Purchase_Tax_Options; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(17; Purchase_Item_Tax_Schedu; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(18; UOMSCHDL; Text[11])
        {
            DataClassification = CustomerContent;
        }
        field(19; VCTNMTHD; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(20; USCATVLS_1; Text[11])
        {
            DataClassification = CustomerContent;
        }
        field(21; USCATVLS_2; Text[11])
        {
            DataClassification = CustomerContent;
        }
        field(22; USCATVLS_3; Text[11])
        {
            DataClassification = CustomerContent;
        }
        field(23; USCATVLS_4; Text[11])
        {
            DataClassification = CustomerContent;
        }
        field(24; USCATVLS_5; Text[11])
        {
            DataClassification = CustomerContent;
        }
        field(25; USCATVLS_6; Text[11])
        {
            DataClassification = CustomerContent;
        }
        field(26; DECPLQTY; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(27; IVIVINDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(28; IVIVOFIX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(29; IVCOGSIX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(30; IVSLSIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(31; IVSLDSIX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(32; IVSLRNIX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(33; IVINUSIX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(34; IVINSVIX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(35; IVDMGIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(36; IVVARIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(37; DPSHPIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(38; PURPVIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(39; UPPVIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(40; IVRETIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(41; ASMVRIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(42; PRCLEVEL; Text[11])
        {
            DataClassification = CustomerContent;
        }
        field(43; PriceGroup; Text[11])
        {
            DataClassification = CustomerContent;
        }
        field(44; PRICMTHD; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(45; TCC; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(46; Revalue_Inventory; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(47; Tolerance_Percentage; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(48; CNTRYORGN; Text[7])
        {
            DataClassification = CustomerContent;
        }
        field(49; STTSTCLVLPRCNTG; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(50; INCLUDEINDP; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(51; LOTEXPWARN; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(52; LOTEXPWARNDAYS; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(53; UseQtyOverageTolerance; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(54; UseQtyShortageTolerance; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(55; QtyOverTolerancePercent; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(56; QtyShortTolerancePercent; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(57; IVSCRVIX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(58; DEX_ROW_ID; Integer)
        {
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; ITMCLSCD)
        {
            Clustered = true;
        }
    }
}