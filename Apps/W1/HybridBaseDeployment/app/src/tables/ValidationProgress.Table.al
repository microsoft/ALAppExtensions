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
        field(2; "Validation Suite Id"; Code[20])
        {
            Caption = 'Validation Suite Id';
            NotBlank = true;
            TableRelation = "Validation Suite";
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
        key(PK; "Company Name", "Validation Suite Id", "Source Table Id", "Validated Row System Id")
        {
            Clustered = true;
        }
    }
}