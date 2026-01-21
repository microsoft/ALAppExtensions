namespace Microsoft.DataMigration;

table 40045 "Validation Progress"
{
    Caption = 'Validation Progress';
    DataClassification = CustomerContent;
    DataPerCompany = false;

    fields
    {
        field(1; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
            NotBlank = true;
        }
        field(2; "Validator Code"; Code[20])
        {
            Caption = 'Validator Code';
            NotBlank = true;
            TableRelation = "Migration Validator Registry";
        }
        field(3; "Source Table Id"; Integer)
        {
            Caption = 'Source Table Id';
            NotBlank = true;
        }
        field(4; "Validated Row System Id"; Guid)
        {
            Caption = 'Validated Row System Id';
            NotBlank = true;
        }
    }
    keys
    {
        key(PK; "Company Name", "Validator Code", "Source Table Id", "Validated Row System Id")
        {
            Clustered = true;
        }
    }
}