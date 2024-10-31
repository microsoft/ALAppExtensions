namespace Microsoft.DataMigration.GP.HistoricalData;

table 40900 "Hist. G/L Account"
{
    DataClassification = AccountData;

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            Caption = 'Primary Key';
            AutoIncrement = true;
        }
        field(2; "No."; Code[130])
        {
            Caption = 'No.';
            NotBlank = true;
        }
        field(3; Name; Text[100])
        {
            Caption = 'Name';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
        key(Key2; "No.")
        {
            IncludedFields = "Name";
        }
    }
}