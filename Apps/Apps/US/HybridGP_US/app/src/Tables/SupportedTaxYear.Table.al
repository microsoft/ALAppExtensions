namespace Microsoft.DataMigration.GP;

table 41100 "Supported Tax Year"
{
    DataPerCompany = false;
    Caption = 'Supported Tax Year';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Tax Year"; Integer)
        {
            Caption = 'Tax Year';
            NotBlank = true;
        }
    }
    keys
    {
        key(PK; "Tax Year")
        {
            Clustered = true;
        }
    }
}