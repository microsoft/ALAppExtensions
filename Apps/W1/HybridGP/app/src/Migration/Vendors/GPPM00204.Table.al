namespace Microsoft.DataMigration.GP;

table 40139 "GP PM00204"
{
    DataClassification = CustomerContent;
    fields
    {
        field(1; VENDORID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(2; TEN99TYPE; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(3; YEAR1; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(4; PERIODID; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(5; TEN99BOXNUMBER; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(6; TEN99AMNT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(7; TEN99FRNORUSDTL; Text[41])
        {
            DataClassification = CustomerContent;
        }
        field(8; TEN99STATECD; Text[3])
        {
            DataClassification = CustomerContent;
        }
        field(9; TEN99STATIDNUM; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(10; TEN99TAXEXMTCUSIPNUM; Text[13])
        {
            DataClassification = CustomerContent;
        }
        field(11; TEN99DIRSALECB; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(12; TEN99STATNMBR; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(13; TEN99FATCAFILEREQ; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(14; DEX_ROW_ID; Integer)
        {
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; VENDORID, TEN99TYPE, YEAR1, PERIODID, TEN99BOXNUMBER)
        {
            Clustered = true;
        }
    }
}