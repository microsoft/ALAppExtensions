namespace Microsoft.Integration.Shopify;

/// <summary>
/// Table Shpfy Registered Store (ID 30136).
/// </summary>
table 30138 "Shpfy Registered Store New"
{
    Access = Internal;
    Caption = 'Shopify Registered Store';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; Store; Text[250])
        {
            Caption = 'Store';
            DataClassification = SystemMetadata;
        }
        field(2; "Requested Scope"; Text[1024])
        {
            Caption = 'Requested Scope';
            DataClassification = SystemMetadata;
        }
        field(3; "Actual Scope"; Text[1024])
        {
            Caption = 'Actual Scope';
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; Store)
        {
            Clustered = true;
        }
    }

    [Scope('OnPrem')]
    internal procedure SetAccessToken(AccessToken: SecretText)
    begin
        IsolatedStorage.Set('AccessToken(' + Rec.SystemId + ')', AccessToken, DataScope::Module);
    end;

    [Scope('OnPrem')]
    internal procedure GetAccessToken() Result: SecretText
    begin
        if not IsolatedStorage.Get('AccessToken(' + Rec.SystemId + ')', DataScope::Module, Result) then;
    end;
}
