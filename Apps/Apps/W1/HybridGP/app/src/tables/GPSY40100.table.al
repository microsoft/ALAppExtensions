namespace Microsoft.DataMigration.GP;

table 40107 "GP SY40100"
{
    DataClassification = CustomerContent;
    Description = 'Period Setup';

    fields
    {
        field(1; CLOSED; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(2; SERIES; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(3; ODESCTN; Text[51])
        {
            DataClassification = CustomerContent;
        }
        field(4; FORIGIN; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(5; PERIODID; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(6; PERIODDT; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(7; PERNAME; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(8; PSERIES_1; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(9; PSERIES_2; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(10; PSERIES_3; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(11; PSERIES_4; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(12; PSERIES_5; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(13; PSERIES_6; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(14; YEAR1; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(15; PERDENDT; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(16; DEX_ROW_TS; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(17; DEX_ROW_ID; Integer)
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; FORIGIN, YEAR1, PERIODID, SERIES, ODESCTN)
        {
            Clustered = true;
        }
    }
}