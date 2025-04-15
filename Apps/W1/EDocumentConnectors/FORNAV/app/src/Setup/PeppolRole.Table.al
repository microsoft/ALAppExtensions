table 6246262 "Fornav Peppol Role"
{
    DataClassification = SystemMetadata;
    Caption = 'ForNAV Peppol Roles';
    Access = Internal;

    fields
    {
        field(1; "Role"; Code[20])
        {
            Caption = 'Role';
        }
    }

    keys
    {
        key(Key1; Role)
        {
            Clustered = true;
        }
    }
}