namespace Microsoft.DataMigration.GP;

table 40099 "GP Checkbook MSTR"
{
    DataClassification = CustomerContent;
    Extensible = false;

    fields
    {
        field(1; CHEKBKID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(2; DSCRIPTN; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(3; BANKID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(4; CURNCYID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(5; ACTINDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(6; BNKACTNM; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(7; NXTCHNUM; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(8; Next_Deposit_Number; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(9; INACTIVE; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(10; DYDEPCLR; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(11; XCDMCHPW; Text[11])
        {
            DataClassification = CustomerContent;
        }
        field(12; MXCHDLR; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(13; DUPCHNUM; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(14; OVCHNUM1; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(15; LOCATNID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(16; NOTEINDX; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(17; CMUSRDF1; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(18; CMUSRDF2; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(19; Last_Reconciled_Date; Date)
        {
            DataClassification = CustomerContent;
        }
        field(20; Last_Reconciled_Balance; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(21; CURRBLNC; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(22; CREATDDT; Date)
        {
            DataClassification = CustomerContent;
        }
        field(23; MODIFDT; Date)
        {
            DataClassification = CustomerContent;
        }
        field(24; Recond; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(25; Reconcile_In_Progress; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(26; Deposit_In_Progress; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(27; CHBKPSWD; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(28; CURNCYPD; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(29; CRNCYRCD; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(30; ADPVADLR; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(31; ADPVAPWD; Text[11])
        {
            DataClassification = CustomerContent;
        }
        field(32; DYCHTCLR; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(33; CMPANYID; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(34; CHKBKTYP; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(35; DDACTNUM; Text[17])
        {
            DataClassification = CustomerContent;
        }
        field(36; DDINDNAM; Text[23])
        {
            DataClassification = CustomerContent;
        }
        field(37; DDTRANS; Text[3])
        {
            DataClassification = CustomerContent;
        }
        field(38; PaymentRateTypeID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(39; DepositRateTypeID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(40; CashInTransAcctIdx; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(41; DEX_ROW_ID; Integer)
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; CHEKBKID)
        {
            Clustered = true;
        }
    }
}