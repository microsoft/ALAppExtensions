namespace Microsoft.DataMigration.GP;

table 40113 "GP PM00200"
{
    Description = 'GP Vendor Master';
    DataClassification = CustomerContent;

    fields
    {
        field(1; VENDORID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(2; VENDNAME; Text[65])
        {
            DataClassification = CustomerContent;
        }
        field(3; VNDCHKNM; Text[65])
        {
            DataClassification = CustomerContent;
        }
        field(4; VENDSHNM; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(5; VADDCDPR; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(6; VADCDPAD; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(7; VADCDSFR; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(8; VADCDTRO; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(9; VNDCLSID; Text[11])
        {
            DataClassification = CustomerContent;
        }
        field(10; VNDCNTCT; Text[61])
        {
            DataClassification = CustomerContent;
        }
        field(11; ADDRESS1; Text[61])
        {
            DataClassification = CustomerContent;
        }
        field(12; ADDRESS2; Text[61])
        {
            DataClassification = CustomerContent;
        }
        field(13; ADDRESS3; Text[61])
        {
            DataClassification = CustomerContent;
        }
        field(14; CITY; Text[35])
        {
            DataClassification = CustomerContent;
        }
        field(15; STATE; Text[29])
        {
            DataClassification = CustomerContent;
        }
        field(16; ZIPCODE; Text[11])
        {
            DataClassification = CustomerContent;
        }
        field(17; COUNTRY; Text[61])
        {
            DataClassification = CustomerContent;
        }
        field(18; PHNUMBR1; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(19; PHNUMBR2; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(20; PHONE3; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(21; FAXNUMBR; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(22; UPSZONE; Text[3])
        {
            DataClassification = CustomerContent;
        }
        field(23; SHIPMTHD; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(24; TAXSCHID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(25; ACNMVNDR; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(26; TXIDNMBR; Text[11])
        {
            DataClassification = CustomerContent;
        }
        field(27; VENDSTTS; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(28; CURNCYID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(29; TXRGNNUM; Text[25])
        {
            DataClassification = CustomerContent;
        }
        field(30; PARVENID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(31; TRDDISCT; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(32; TEN99TYPE; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(33; TEN99BOXNUMBER; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(34; MINORDER; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(35; PYMTRMID; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(36; MINPYTYP; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(37; MINPYPCT; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(38; MINPYDLR; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(39; MXIAFVND; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(40; MAXINDLR; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(41; COMMENT1; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(42; COMMENT2; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(43; USERDEF1; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(44; USERDEF2; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(45; CRLMTDLR; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(46; PYMNTPRI; Text[3])
        {
            DataClassification = CustomerContent;
        }
        field(47; KPCALHST; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(48; KGLDSTHS; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(49; KPERHIST; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(50; KPTRXHST; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(51; HOLD; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(52; PTCSHACF; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(53; CREDTLMT; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(54; WRITEOFF; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(55; MXWOFAMT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(56; SBPPSDED; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(57; PPSTAXRT; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(58; DXVARNUM; Text[25])
        {
            DataClassification = CustomerContent;
        }
        field(59; CRTCOMDT; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(60; CRTEXPDT; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(61; RTOBUTKN; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(62; XPDTOBLG; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(63; PRSPAYEE; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(64; PMAPINDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(65; PMCSHIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(66; PMDAVIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(67; PMDTKIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(68; PMFINIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(69; PMMSCHIX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(70; PMFRTIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(71; PMTAXIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(72; PMWRTIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(73; PMPRCHIX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(74; PMRTNGIX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(75; PMTDSCIX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(76; ACPURIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(77; PURPVIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(78; NOTEINDX; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(79; CHEKBKID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(80; MODIFDT; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(81; CREATDDT; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(82; RATETPID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(83; Revalue_Vendor; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(84; Post_Results_To; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(85; FREEONBOARD; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(86; GOVCRPID; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(87; GOVINDID; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(88; DISGRPER; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(89; DUEGRPER; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(90; DOCFMTID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(91; TaxInvRecvd; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(92; USERLANG; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(93; WithholdingType; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(94; WithholdingFormType; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(95; WithholdingEntityType; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(96; TaxFileNumMode; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(97; BRTHDATE; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(98; LaborPmtType; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(99; CCode; Text[7])
        {
            DataClassification = CustomerContent;
        }
        field(100; DECLID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(101; CBVAT; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(102; Workflow_Approval_Status; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(103; Workflow_Priority; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(104; Workflow_Status; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(105; VADCD1099; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(106; ONEPAYPERVENDINV; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(107; DEX_ROW_TS; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(108; DEX_ROW_ID; Integer)
        {
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; VENDORID)
        {
            Clustered = true;
        }
    }
}

