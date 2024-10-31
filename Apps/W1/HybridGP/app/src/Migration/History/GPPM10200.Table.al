namespace Microsoft.DataMigration.GP;

table 40142 "GP PM10200"
{
    DataClassification = CustomerContent;
    Extensible = false;

    fields
    {
        field(1; VENDORID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(2; DOCDATE; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(3; DATE1; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(4; GLPOSTDT; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(5; TIME1; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(6; APTVCHNM; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(7; APTODCTY; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(8; APTODCNM; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(9; APTODCDT; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(10; ApplyToGLPostDate; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(11; CURNCYID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(12; CURRNIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(13; APPLDAMT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(14; DISTKNAM; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(15; DISAVTKN; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(16; WROFAMNT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(17; ORAPPAMT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(18; ORDISTKN; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(19; ORDATKN; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(20; ORWROFAM; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(21; APTOEXRATE; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(22; APTODENRATE; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(23; APTORTCLCMETH; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(24; APTOMCTRXSTT; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(25; VCHRNMBR; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(26; DOCTYPE; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(27; APFRDCNM; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(28; ApplyFromGLPostDate; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(29; FROMCURR; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(30; APFRMAPLYAMT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(31; APFRMDISCTAKEN; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(32; APFRMDISCAVAIL; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(33; APFRMWROFAMT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(34; ActualApplyToAmount; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(35; ActualDiscTakenAmount; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(36; ActualDiscAvailTaken; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(37; ActualWriteOffAmount; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(38; APFRMEXRATE; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(39; APFRMDENRATE; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(40; APFRMRTCLCMETH; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(41; APFRMMCTRXSTT; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(42; PPSAMDED; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(43; GSTDSAMT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(44; TAXDTLID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(45; POSTED; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(46; TEN99AMNT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(47; RLGANLOS; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(48; APYFRMRNDAMT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(49; APYTORNDAMT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(50; APYTORNDDISC; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(51; OAPYFRMRNDAMT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(52; OAPYTORNDAMT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(53; OAPYTORNDDISC; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(54; Settled_Gain_CreditCurrT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(55; Settled_Loss_CreditCurrT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(56; Settled_Gain_DebitCurrTr; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(57; Settled_Loss_DebitCurrTr; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(58; Settled_Gain_DebitDiscAv; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(59; Settled_Loss_DebitDiscAv; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(60; Revaluation_Status; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(61; Credit1099Amount; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(62; DEFTEN99TYPE; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(63; DEFTEN99BOXNUMBER; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(64; DEX_ROW_ID; Integer)
        {
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; APTVCHNM, APTODCTY, VCHRNMBR, DOCTYPE)
        {
            Clustered = true;
        }
        key(Key2; VENDORID, DOCTYPE, VCHRNMBR, POSTED)
        {
        }
    }
}