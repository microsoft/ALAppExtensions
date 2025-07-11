namespace Microsoft.DataMigration.GP;

table 40144 "GP RM20201"
{
    DataClassification = CustomerContent;
    Extensible = false;

    fields
    {
        field(1; CUSTNMBR; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(2; CPRCSTNM; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(3; TRXSORCE; Text[13])
        {
            DataClassification = CustomerContent;
        }
        field(4; DATE1; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(5; TIME1; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(6; GLPOSTDT; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(7; POSTED; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(8; TAXDTLID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(9; APTODCNM; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(10; APTODCTY; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(11; APTODCDT; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(12; ApplyToGLPostDate; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(13; CURNCYID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(14; CURRNIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(15; APPTOAMT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(16; DISTKNAM; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(17; DISAVTKN; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(18; WROFAMNT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(19; ORAPTOAM; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(20; ORDISTKN; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(21; ORDATKN; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(22; ORWROFAM; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(23; APTOEXRATE; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(24; APTODENRATE; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(25; APTORTCLCMETH; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(26; APTOMCTRXSTT; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(27; APFRDCNM; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(28; APFRDCTY; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(29; APFRDCDT; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(30; ApplyFromGLPostDate; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(31; FROMCURR; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(32; APFRMAPLYAMT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(33; APFRMDISCTAKEN; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(34; APFRMDISCAVAIL; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(35; APFRMWROFAMT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(36; ActualApplyToAmount; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(37; ActualDiscTakenAmount; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(38; ActualDiscAvailTaken; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(39; ActualWriteOffAmount; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(40; APFRMEXRATE; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(41; APFRMDENRATE; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(42; APFRMRTCLCMETH; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(43; APFRMMCTRXSTT; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(44; APYFRMRNDAMT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(45; APYTORNDAMT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(46; APYTORNDDISC; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(47; OAPYFRMRNDAMT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(48; OAPYTORNDAMT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(49; OAPYTORNDDISC; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50; GSTDSAMT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(51; PPSAMDED; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(52; RLGANLOS; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(53; Settled_Gain_CreditCurrT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(54; Settled_Loss_CreditCurrT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(55; Settled_Gain_DebitCurrTr; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(56; Settled_Loss_DebitCurrTr; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(57; Settled_Gain_DebitDiscAv; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(58; Settled_Loss_DebitDiscAv; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(59; Revaluation_Status; Integer)
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
        key(Key1; APFRDCTY, APFRDCNM, APTODCTY, APTODCNM)
        {
            Clustered = true;
        }
    }
}