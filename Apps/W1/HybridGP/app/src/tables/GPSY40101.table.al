namespace Microsoft.DataMigration.GP;

table 40108 "GP SY40101"
{
    DataClassification = CustomerContent;
    Description = 'Period Header';

    fields
    {
        field(1; YEAR1; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(2; FSTFSCDY; DateTime)
        {
            DataClassification = CustomerContent;
            Description = 'First Fiscal Day';
        }
        field(3; LSTFSCDY; DateTime)
        {
            DataClassification = CustomerContent;
            Description = 'Last Fiscal Day';
        }
        field(4; NUMOFPER; Integer)
        {
            DataClassification = CustomerContent;
            Description = 'Number of Periods';
        }
        field(5; HISTORYR; Boolean)
        {
            DataClassification = CustomerContent;
            Description = 'Historical Year';
        }
        field(6; DEX_ROW_TS; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(7; DEX_ROW_ID; Integer)
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; YEAR1)
        {
            Clustered = true;
        }
    }
}