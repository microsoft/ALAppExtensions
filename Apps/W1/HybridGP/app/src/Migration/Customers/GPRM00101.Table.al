namespace Microsoft.DataMigration.GP;

table 40114 "GP RM00101"
{
    Description = 'RM Customer Master';
    DataClassification = CustomerContent;

    fields
    {
        field(1; CUSTNMBR; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(2; CUSTNAME; Text[65])
        {
            DataClassification = CustomerContent;
        }
        field(3; CUSTCLAS; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(4; CPRCSTNM; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(5; CNTCPRSN; Text[61])
        {
            DataClassification = CustomerContent;
        }
        field(6; STMTNAME; Text[65])
        {
            DataClassification = CustomerContent;
        }
        field(7; SHRTNAME; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(8; ADRSCODE; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(9; UPSZONE; Text[3])
        {
            DataClassification = CustomerContent;
        }
        field(10; SHIPMTHD; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(11; TAXSCHID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(12; ADDRESS1; Text[61])
        {
            DataClassification = CustomerContent;
        }
        field(13; ADDRESS2; Text[61])
        {
            DataClassification = CustomerContent;
        }
        field(14; ADDRESS3; Text[61])
        {
            DataClassification = CustomerContent;
        }
        field(15; COUNTRY; Text[61])
        {
            DataClassification = CustomerContent;
        }
        field(16; CITY; Text[35])
        {
            DataClassification = CustomerContent;
        }
        field(17; STATE; Text[29])
        {
            DataClassification = CustomerContent;
        }
        field(18; ZIP; Text[11])
        {
            DataClassification = CustomerContent;
        }
        field(19; PHONE1; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(20; PHONE2; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(21; PHONE3; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(22; FAX; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(23; PRBTADCD; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(24; PRSTADCD; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(25; STADDRCD; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(26; SLPRSNID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(27; CHEKBKID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(28; PYMTRMID; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(29; CRLMTTYP; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(30; CRLMTAMT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(31; CRLMTPER; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(32; CRLMTPAM; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(33; CURNCYID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(34; RATETPID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(35; CUSTDISC; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(36; PRCLEVEL; Text[11])
        {
            DataClassification = CustomerContent;
        }
        field(37; MINPYTYP; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(38; MINPYDLR; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(39; MINPYPCT; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(40; FNCHATYP; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(41; FNCHPCNT; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(42; FINCHDLR; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(43; MXWOFTYP; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(44; MXWROFAM; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(45; COMMENT1; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(46; COMMENT2; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(47; USERDEF1; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(48; USERDEF2; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(49; TAXEXMT1; Text[25])
        {
            DataClassification = CustomerContent;
        }
        field(50; TAXEXMT2; Text[25])
        {
            DataClassification = CustomerContent;
        }
        field(51; TXRGNNUM; Text[25])
        {
            DataClassification = CustomerContent;
        }
        field(52; BALNCTYP; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(53; STMTCYCL; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(54; BANKNAME; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(55; BNKBRNCH; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(56; SALSTERR; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(57; DEFCACTY; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(58; RMCSHACC; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(59; RMARACC; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(60; RMSLSACC; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(61; RMIVACC; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(62; RMCOSACC; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(63; RMTAKACC; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(64; RMAVACC; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(65; RMFCGACC; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(66; RMWRACC; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(67; RMSORACC; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(68; FRSTINDT; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(69; INACTIVE; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(70; HOLD; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(71; CRCARDID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(72; CRCRDNUM; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(73; CCRDXPDT; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(74; KPDSTHST; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(75; KPCALHST; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(76; KPERHIST; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(77; KPTRXHST; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(78; NOTEINDX; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(79; CREATDDT; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(80; MODIFDT; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(81; Revalue_Customer; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(82; Post_Results_To; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(83; FINCHID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(84; GOVCRPID; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(85; GOVINDID; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(86; DISGRPER; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(87; DUEGRPER; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(88; DOCFMTID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(89; Send_Email_Statements; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(90; USERLANG; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(91; GPSFOINTEGRATIONID; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(92; INTEGRATIONSOURCE; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(93; INTEGRATIONID; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(94; ORDERFULFILLDEFAULT; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(95; CUSTPRIORITY; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(96; CCode; Text[7])
        {
            DataClassification = CustomerContent;
        }
        field(97; DECLID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(98; RMOvrpymtWrtoffAcctIdx; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(99; SHIPCOMPLETE; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(100; CBVAT; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(101; INCLUDEINDP; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(102; DEX_ROW_TS; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(103; DEX_ROW_ID; Integer)
        {
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; CUSTNMBR)
        {
            Clustered = true;
        }
    }
}

