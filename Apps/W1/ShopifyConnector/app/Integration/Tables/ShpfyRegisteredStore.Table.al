/// <summary>
/// Table Shpfy Registered Store (ID 30136).
/// </summary>
table 30136 "Shpfy Registered Store"
{
    Access = Internal;
    Caption = 'Shopify Registered Store';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; Store; Text[50])
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

    [NonDebuggable]
    internal procedure SetAccessToken(AccessToken: Text)
    begin
        IsolatedStorage.Set('AccessToken(' + Rec.SystemId + ')', AccessToken, DataScope::Company);
    end;

    [NonDebuggable]
    internal procedure GetAccessToken() Result: Text
    begin
        if not IsolatedStorage.Get('AccessToken(' + Rec.SystemId + ')', DataScope::Company, Result) then
            exit('');
    end;
}
