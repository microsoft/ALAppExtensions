namespace Microsoft.Payroll.Ceridian;

table 1665 "MS Ceridian Payroll Setup"
{
    Caption = 'Ceridian Payroll Setup';
    ReplicateData = false;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
        }
        field(2; "User Name"; Text[50])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; "Password Key"; Guid)
        {
        }
        field(5; "Service URL"; Text[250])
        {
            ExtendedDatatype = URL;
        }
        field(13; Enabled; Boolean)
        {
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    [NonDebuggable]
    [Scope('OnPrem')]
    procedure SavePassword(var PasswordKey: Guid; PasswordText: Text);
    begin
        if ISNULLGUID(PasswordKey) or not IsolatedStorage.Contains(PasswordKey, Datascope::Company) then
            PasswordKey := FORMAT(CreateGuid());

        if not EncryptionEnabled() then
            IsolatedStorage.Set(PasswordKey, PasswordText, Datascope::Company)
        else
            IsolatedStorage.SetEncrypted(PasswordKey, PasswordText, Datascope::Company);
    end;

    procedure GetAppID(): Guid;
    begin
        exit('{30828ce4-53e3-407f-ba80-13ce8d79d110}');
    end;
}

