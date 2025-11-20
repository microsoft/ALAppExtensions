namespace Microsoft.DataMigration;

table 40045 "Company Validation Progress"
{
    Caption = 'Company Validation Progress';
    DataClassification = CustomerContent;
    DataPerCompany = false;

    fields
    {
        field(1; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
        }
        field(2; "Validator Code"; Code[20])
        {
            Caption = 'Validator Code';
        }
        field(3; "Validation Step"; Code[20])
        {
            Caption = 'Validation Step';
        }
    }
    keys
    {
        key(PK; "Company Name", "Validator Code", "Validation Step")
        {
            Clustered = true;
        }
    }
}