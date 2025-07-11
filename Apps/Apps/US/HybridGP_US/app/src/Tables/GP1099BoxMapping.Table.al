namespace Microsoft.DataMigration.GP;

table 41101 "GP 1099 Box Mapping"
{
    DataPerCompany = false;
    Caption = 'GP 1099 Box Mapping';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Tax Year"; Integer)
        {
            Caption = 'Tax Year';
            NotBlank = true;
            TableRelation = "Supported Tax Year"."Tax Year";
        }
        field(2; "GP 1099 Type"; Integer)
        {
            Caption = 'GP 1099 Type';
            NotBlank = true;
        }
        field(3; "GP 1099 Box No."; Integer)
        {
            Caption = 'GP 1099 Box No.';
            NotBlank = true;
        }
        field(4; "BC IRS 1099 Code"; Code[10])
        {
            Caption = 'BC IRS 1099 Code';
            NotBlank = true;
        }
    }
    keys
    {
        key(PK; "Tax Year", "GP 1099 Type", "GP 1099 Box No.")
        {
            Clustered = true;
        }
    }
}