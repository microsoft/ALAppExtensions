namespace Microsoft.Integration.Shopify;

/// <summary>
/// Table Shpfy Registered Store (ID 30136).
/// </summary>
table 30136 "Shpfy Registered Store"
{
#if not CLEAN21
    ObsoleteState = Pending;
    ObsoleteTag = '21.0';
#else
    ObsoleteState = removed;
    ObsoleteTag = '24.0';
#endif
    ObsoleteReason = 'Use table 30138 "Shpfy Registered Store New" instead';

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
    [Scope('OnPrem')]
    internal procedure SetAccessToken(AccessToken: Text)
    begin
        IsolatedStorage.Set('AccessToken(' + Rec.SystemId + ')', AccessToken, DataScope::Module);
    end;

    [NonDebuggable]
    [Scope('OnPrem')]
    internal procedure GetAccessToken() Result: Text
    begin
        if not IsolatedStorage.Get('AccessToken(' + Rec.SystemId + ')', DataScope::Module, Result) then
            exit('');
    end;
}
