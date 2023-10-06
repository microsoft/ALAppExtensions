namespace Microsoft.DataMigration.GP;

table 40112 "GP PM00100"
{
    Description = 'GP Vendor Class Master';
    DataClassification = CustomerContent;

    fields
    {
        field(1; VNDCLSID; Text[11])
        {
            DataClassification = CustomerContent;
        }
        field(2; VNDCLDSC; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(3; DEFLTCLS; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(4; MXIAFVND; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(5; MXINVAMT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(6; WRITEOFF; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(7; CREDTLMT; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(8; TEN99TYPE; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(9; PTCSHACF; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(10; MXWOFAMT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(11; MINORDER; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(12; CRLMTDLR; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(13; PYMNTPRI; Text[3])
        {
            DataClassification = CustomerContent;
        }
        field(14; SHIPMTHD; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(15; PYMTRMID; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(16; MINPYTYP; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(17; MINPYDLR; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(18; MINPYPCT; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(19; CURNCYID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(20; TAXSCHID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(21; KPCALHST; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(22; KGLDSTHS; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(23; KPERHIST; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(24; KPTRXHST; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(25; TRDDISCT; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(26; USERDEF1; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(27; USERDEF2; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(28; PMAPINDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(29; PMCSHIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(30; PMDAVIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(31; PMDTKIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(32; PMFINIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(33; PMMSCHIX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(34; PMFRTIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(35; PMTAXIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(36; PMWRTIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(37; PMPRCHIX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(38; PMRTNGIX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(39; PMTDSCIX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(40; ACPURIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(41; PURPVIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(42; CHEKBKID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(43; MODIFDT; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(44; CREATDDT; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(45; RATETPID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(46; Revalue_Vendor; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(47; Post_Results_To; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(48; FREEONBOARD; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(49; DISGRPER; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(50; DUEGRPER; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(51; TaxInvRecvd; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(52; CBVAT; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(53; ONEPAYPERVENDINV; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(54; DEX_ROW_ID; Integer)
        {
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; VNDCLSID)
        {
            Clustered = true;
        }
    }
}

