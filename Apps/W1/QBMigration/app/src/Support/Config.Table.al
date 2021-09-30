table 1917 "MigrationQB Config"
{
    ReplicateData = false;

    fields
    {
        field(1; Dummy; Code[10])
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Zip File"; Text[250])
        {
            DataClassification = SystemMetadata;
        }
        field(3; "Unziped Folder"; Text[250])
        {
            DataClassification = SystemMetadata;
        }
        field(4; "Total Items"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(5; "Total Accounts"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(6; "Total Customers"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(7; "Total Vendors"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(8; Online; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        field(9; "Realm Id"; Text[250])
        {
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'The suggested way to store the secrets is Isolated Storage, therefore Realm Id will be removed.';
            ObsoleteTag = '15.4';
        }
        field(10; "Token Key"; Text[250])
        {
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'The suggested way to store the secrets is Isolated Storage, therefore Token Key will be removed.';
            ObsoleteTag = '15.4';
        }
        field(11; "Token Secret"; Text[250])
        {
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'The suggested way to store the secrets is Isolated Storage, therefore Token Secret will be removed.';
            ObsoleteTag = '15.4';
        }
    }

    keys
    {
        key(PK; Dummy)
        {
            Clustered = true;
        }
    }

    procedure GetSingleInstance();
    begin
        Reset();
        if not Get() then begin
            Init();
            Insert();
        end;
    end;

    [NonDebuggable]
    procedure InitializeOnlineConfig(AccessToken: Text; RealmId: Text)
    begin
        if not Get() then begin
            Init();
            Insert();
        end;

        Validate(Online, true);
        Modify();

        IsolatedStorage.Set('Migration QB Realm Id', RealmId, DataScope::Company);
        IsolatedStorage.Set('Migration QB Access Token', AccessToken, DataScope::Company);
    end;

    [Obsolete('Do not use. Replaced with InitializeOnlineConfig() for OAuth 2.0 implementation.', '15.4')]
    procedure InitializeOnlineSetup(TokenKey: Text; TokenSecret: Text; RealmId: Text)
    var
        CryptographyManagement: Codeunit "Cryptography Management";
    begin
        if not Get() then begin
            Init();
            Insert();
        end;

        Validate(Online, true);
        Modify();

        if CryptographyManagement.IsEncryptionEnabled() then begin
            IsolatedStorage.SetEncrypted('Migration QB Realm Id', RealmId, DataScope::Company);
            IsolatedStorage.SetEncrypted('Migration QB Token Key', TokenKey, DataScope::Company);
            IsolatedStorage.SetEncrypted('Migration QB Token Secret', TokenSecret, DataScope::Company);
        end else begin
            IsolatedStorage.Set('Migration QB Realm Id', RealmId, DataScope::Company);
            IsolatedStorage.Set('Migration QB Token Key', TokenKey, DataScope::Company);
            IsolatedStorage.Set('Migration QB Token Secret', TokenSecret, DataScope::Company);
        end;
    end;

    procedure IsOnlineData(): Boolean
    begin
        Get();
        exit(Online);
    end;

    procedure UpdateTotalItems(TotalItems: Integer)
    begin
        if not Get() then
            exit;

        Validate("Total Items", TotalItems);
        Modify();
    end;

    procedure UpdateTotalAccounts(TotalAccounts: Integer)
    begin
        if not Get() then
            exit;

        Validate("Total Accounts", TotalAccounts);
        Modify();
    end;

    procedure UpdateTotalCustomers(TotalCustomers: Integer)
    begin
        if not Get() then
            exit;

        Validate("Total Customers", TotalCustomers);
        Modify();
    end;

    procedure UpdateTotalVendors(TotalVendors: Integer)
    begin
        if not Get() then
            exit;

        Validate("Total Vendors", TotalVendors);
        Modify();
    end;
}
