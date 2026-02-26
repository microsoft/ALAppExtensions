namespace Microsoft.DataMigration.GP;

table 40143 "GP PM30300"
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
        field(6; VCHRNMBR; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(7; DOCTYPE; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(8; APFRDCNM; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(9; ApplyFromGLPostDate; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(10; FROMCURR; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(11; APFRMAPLYAMT; Decimal)
        {
            AutoFormatType = 0;
            DataClassification = CustomerContent;
        }
        field(12; APFRMDISCTAKEN; Decimal)
        {
            AutoFormatType = 0;
            DataClassification = CustomerContent;
        }
        field(13; APFRMDISCAVAIL; Decimal)
        {
            AutoFormatType = 0;
            DataClassification = CustomerContent;
        }
        field(14; APFRMWROFAMT; Decimal)
        {
            AutoFormatType = 0;
            DataClassification = CustomerContent;
        }
        field(15; ActualApplyToAmount; Decimal)
        {
            AutoFormatType = 0;
            DataClassification = CustomerContent;
        }
        field(16; ActualDiscTakenAmount; Decimal)
        {
            AutoFormatType = 0;
            DataClassification = CustomerContent;
        }
        field(17; ActualDiscAvailTaken; Decimal)
        {
            AutoFormatType = 0;
            DataClassification = CustomerContent;
        }
        field(18; ActualWriteOffAmount; Decimal)
        {
            AutoFormatType = 0;
            DataClassification = CustomerContent;
        }
        field(19; APFRMEXRATE; Decimal)
        {
            AutoFormatType = 0;
            DataClassification = CustomerContent;
        }
        field(20; APFRMDENRATE; Decimal)
        {
            AutoFormatType = 0;
            DataClassification = CustomerContent;
        }
        field(21; APFRMRTCLCMETH; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(22; APFRMMCTRXSTT; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(23; APTVCHNM; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(24; APTODCTY; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(25; APTODCNM; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(26; APTODCDT; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(27; ApplyToGLPostDate; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(28; CURNCYID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(29; CURRNIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(30; APPLDAMT; Decimal)
        {
            AutoFormatType = 0;
            DataClassification = CustomerContent;
        }
        field(31; DISTKNAM; Decimal)
        {
            AutoFormatType = 0;
            DataClassification = CustomerContent;
        }
        field(32; DISAVTKN; Decimal)
        {
            AutoFormatType = 0;
            DataClassification = CustomerContent;
        }
        field(33; WROFAMNT; Decimal)
        {
            AutoFormatType = 0;
            DataClassification = CustomerContent;
        }
        field(34; ORAPPAMT; Decimal)
        {
            AutoFormatType = 0;
            DataClassification = CustomerContent;
        }
        field(35; ORDISTKN; Decimal)
        {
            AutoFormatType = 0;
            DataClassification = CustomerContent;
        }
        field(36; ORDATKN; Decimal)
        {
            AutoFormatType = 0;
            DataClassification = CustomerContent;
        }
        field(37; ORWROFAM; Decimal)
        {
            AutoFormatType = 0;
            DataClassification = CustomerContent;
        }
        field(38; APTOEXRATE; Decimal)
        {
            AutoFormatType = 0;
            DataClassification = CustomerContent;
        }
        field(39; APTODENRATE; Decimal)
        {
            AutoFormatType = 0;
            DataClassification = CustomerContent;
        }
        field(40; APTORTCLCMETH; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(41; APTOMCTRXSTT; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(42; PPSAMDED; Decimal)
        {
            AutoFormatType = 0;
            DataClassification = CustomerContent;
        }
        field(43; GSTDSAMT; Decimal)
        {
            AutoFormatType = 0;
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
            AutoFormatType = 0;
            DataClassification = CustomerContent;
        }
        field(47; RLGANLOS; Decimal)
        {
            AutoFormatType = 0;
            DataClassification = CustomerContent;
        }
        field(48; APYFRMRNDAMT; Decimal)
        {
            AutoFormatType = 0;
            DataClassification = CustomerContent;
        }
        field(49; APYTORNDAMT; Decimal)
        {
            AutoFormatType = 0;
            DataClassification = CustomerContent;
        }
        field(50; APYTORNDDISC; Decimal)
        {
            AutoFormatType = 0;
            DataClassification = CustomerContent;
        }
        field(51; OAPYFRMRNDAMT; Decimal)
        {
            AutoFormatType = 0;
            DataClassification = CustomerContent;
        }
        field(52; OAPYTORNDAMT; Decimal)
        {
            AutoFormatType = 0;
            DataClassification = CustomerContent;
        }
        field(53; OAPYTORNDDISC; Decimal)
        {
            AutoFormatType = 0;
            DataClassification = CustomerContent;
        }
        field(54; Settled_Gain_CreditCurrT; Decimal)
        {
            AutoFormatType = 0;
            DataClassification = CustomerContent;
        }
        field(55; Settled_Loss_CreditCurrT; Decimal)
        {
            AutoFormatType = 0;
            DataClassification = CustomerContent;
        }
        field(56; Settled_Gain_DebitCurrTr; Decimal)
        {
            AutoFormatType = 0;
            DataClassification = CustomerContent;
        }
        field(57; Settled_Loss_DebitCurrTr; Decimal)
        {
            AutoFormatType = 0;
            DataClassification = CustomerContent;
        }
        field(58; Settled_Gain_DebitDiscAv; Decimal)
        {
            AutoFormatType = 0;
            DataClassification = CustomerContent;
        }
        field(59; Settled_Loss_DebitDiscAv; Decimal)
        {
            AutoFormatType = 0;
            DataClassification = CustomerContent;
        }
        field(60; Revaluation_Status; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(61; Credit1099Amount; Decimal)
        {
            AutoFormatType = 0;
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