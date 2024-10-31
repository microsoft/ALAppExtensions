namespace Microsoft.DataMigration.GP;

table 40115 "GP RM00201"
{
    Description = 'RM Class Master';
    DataClassification = CustomerContent;

    fields
    {
        field(1; CLASSID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(2; CLASDSCR; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(3; CRLMTTYP; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(4; CRLMTAMT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(5; CRLMTPER; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(6; CRLMTPAM; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(7; DEFLTCLS; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(8; BALNCTYP; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(9; CHEKBKID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(10; BANKNAME; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(11; TAXSCHID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(12; SHIPMTHD; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(13; PYMTRMID; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(14; CUSTDISC; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(15; CSTPRLVL; Text[11])
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
        field(19; MXWOFTYP; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(20; MXWROFAM; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(21; FINCHARG; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(22; FNCHATYP; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(23; FINCHDLR; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(24; FNCHPCNT; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(25; PRCLEVEL; Text[11])
        {
            DataClassification = CustomerContent;
        }
        field(26; CURNCYID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(27; RATETPID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(28; DEFCACTY; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(29; RMCSHACC; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(30; RMARACC; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(31; RMCOSACC; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(32; RMIVACC; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(33; RMSLSACC; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(34; RMAVACC; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(35; RMTAKACC; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(36; RMFCGACC; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(37; RMWRACC; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(38; RMSORACC; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(39; SALSTERR; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(40; SLPRSNID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(41; STMTCYCL; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(42; SNDSTMNT; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(43; INACTIVE; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(44; KPCALHST; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(45; KPDSTHST; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(46; KPERHIST; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(47; KPTRXHST; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(48; NOTEINDX; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(49; MODIFDT; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(50; CREATDDT; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(51; Revalue_Customer; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(52; Post_Results_To; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(53; DISGRPER; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(54; DUEGRPER; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(55; ORDERFULFILLDEFAULT; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(56; CUSTPRIORITY; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(57; RMOvrpymtWrtoffAcctIdx; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(58; CBVAT; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(59; INCLUDEINDP; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(60; DEX_ROW_ID; Integer)
        {
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; CLASSID)
        {
            Clustered = true;
        }
    }
}

