tableextension 2405 "XS Sync Setup Extension" extends "Sync Setup"
{
    fields
    {
        field(5; "XS Xero Last Sync Time"; DateTime)
        {
            Caption = 'Xero Last Sync Time';
            DataClassification = SystemMetadata;
        }
        field(6; "XS Xero Start Sync Time"; DateTime)
        {
            Caption = 'Xero Start Sync Time';
            DataClassification = SystemMetadata;
        }
        field(9; "XS Xero Access Key"; Text[250])
        {
            Caption = 'Xero Access Key';
            DataClassification = SystemMetadata;
            ObsoleteState = Removed;
            ObsoleteReason = 'The suggested way to store the secrets is Isolated Storage, therefore XS Xero Access Key will be removed.';
            ObsoleteTag = '18.0';

        }
        field(10; "XS Xero Access Secret"; Text[250])
        {
            Caption = 'Xero Access Secret';
            DataClassification = SystemMetadata;
            ObsoleteState = Removed;
            ObsoleteReason = 'The suggested way to store the secrets is Isolated Storage, therefore XS Xero Access Secret will be removed.';
            ObsoleteTag = '18.0';
        }
        field(11; "XS Enabled"; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = SystemMetadata;
        }
        field(12; "XS Access Key Expiration"; DateTime)
        {
            Caption = 'Access Key Expiration';
            DataClassification = SystemMetadata;
        }
        field(13; "XS In Test Mode"; Boolean)
        {
            Caption = 'In Test Mode';
            DataClassification = SystemMetadata;
        }
        field(14; "XS Default Tax Type"; Text[50])
        {
            DataClassification = SystemMetadata;
        }

        field(15; "XS Default AccountCode"; Code[10])
        {
            DataClassification = SystemMetadata;
        }
    }

    var
        StopSynchronizationQst: Label 'Stop sharing?';

    procedure SetSharingEnabled(Enable: Boolean)
    begin
        "XS Enabled" := Enable;
        Modify(true);
    end;

    [Scope('OnPrem')]
    procedure CleanSharingSettings()
    begin
        Validate("XS Enabled", false);
        IF IsolatedStorage.Contains('XS Xero Access Key', DataScope::Company) then
            IsolatedStorage.Delete('XS Xero Access Key', DataScope::Company);

        IF IsolatedStorage.Contains('XS Xero Access Secret', DataScope::Company) then
            IsolatedStorage.Delete('XS Xero Access Secret', DataScope::Company);

        Modify(true);
    end;

    procedure SynchronizationIsSetUp(): Boolean;
    begin
        if not Get() then
            exit(false);

        exit("XS Enabled");
    end;

    procedure AccessTokenKeyIsExpired() ReturnValue: Boolean
    begin
        ReturnValue := "XS Access Key Expiration" < CurrentDateTime();
    end;

    local procedure RenewAccessToken(var XeroSyncSetup: Record "Sync Setup") // TODO: Temporary - Remove when this is a Xero partner app
    var
        RenewTokenFailedErr: Label 'Could not renew access to Xero. Please run the Xero setup page to restore access';
    begin
        //Automatic token renewal only possible with partner app
        //So for now we start the wizard again, which is only possible in a user session
        if not GuiAllowed() then
            LogInternalError(RenewTokenFailedErr, DataClassification::SystemMetadata, Verbosity::Error);

        Page.RunModal(Page::"XS Xero Synchronization Wizard", XeroSyncSetup);
    end;

    procedure InitAPIParameters(var Parameters: Record "XS REST Web Service Parameters")
    var
        XSOAuthManagement: Codeunit "XS OAuth Management";
        ConsumerKeyTxt: Text;
        ConsumerSecretTxt: Text;
        XSXeroAccessKey: Text;
        XSXeroAccessSecret: Text;
    begin
        if not SynchronizationIsSetUp() then
            exit;

        XSOAuthManagement.GetConsumerKeyAndSecret(ConsumerKeyTxt, ConsumerSecretTxt);

        if AccessTokenKeyIsExpired() then begin
            Commit(); // This is to be able to Call page (wizard) in RunModal (see RenewAccessToken)
            RenewAccessToken(Rec);
            GetSingleInstance();
        end;

        with Parameters do begin
            AuthenticationType := AuthenticationType::OAuth;
            ConsumerKey := CopyStr(ConsumerKeyTxt, 1, 250);
            ConsumerSecret := CopyStr(ConsumerSecretTxt, 1, 250);

            IF IsolatedStorage.Contains('XS Xero Access Key', DataScope::Company) then
                IsolatedStorage.Get('XS Xero Access Key', DataScope::Company, XSXeroAccessKey);

            IF IsolatedStorage.Contains('XS Xero Access Secret', DataScope::Company) then
                IsolatedStorage.Get('XS Xero Access Secret', DataScope::Company, XSXeroAccessSecret);

            AccessKey := COPYSTR(XSXeroAccessKey, 1, 250);
            AccessSecret := COPYSTR(XSXeroAccessSecret, 1, 250);
            Accept := 'application/json';
        end;
    end;

    procedure FindDefaultAccountCodeAndTaxType()
    var
        Parameters: Record "XS REST Web Service Parameters";
        XSCommunicateWithXero: Codeunit "XS Communicate With Xero";
        JsonArrayOut: JsonArray;
        Token: JsonToken;
        Object: JsonObject;
        ValueToken: JsonToken;
        AccountType: Text;
        AccountStatus: Text;
        AccountCode: Text;
        AccountTaxType: Text;
    begin
        if ("XS Default AccountCode" <> '') and ("XS Default Tax Type" <> '') then
            exit;

        if not XSCommunicateWithXero.QueryXeroAccounts(Parameters, JsonArrayOut) then
            exit;

        foreach Token in JsonArrayOut Do begin
            Object := Token.AsObject();
            Object.Get('Type', ValueToken);
            AccountType := DelChr(Format(ValueToken), '<>', '"');

            Object.Get('Status', ValueToken);
            AccountStatus := DelChr(Format(ValueToken), '<>', '"');

            Object.Get('Code', ValueToken);
            AccountCode := DelChr(Format(ValueToken), '<>', '"');

            Object.Get('TaxType', ValueToken);
            AccountTaxType := DelChr(Format(ValueToken), '<>', '"');
            if (AccountType = 'REVENUE') and
               (AccountStatus = 'ACTIVE')
            then begin
                "XS Default AccountCode" := CopyStr(AccountCode, 1, 10);
                "XS Default Tax Type" := CopyStr(AccountTaxType, 1, 50);
                Modify(true);
                exit;
            end;
        end;
    end;

    procedure StopSynchronization();
    var
        JobQueueFunctionLibrary: Codeunit "XS Job Queue Management";
    begin
        if not Confirm(StopSynchronizationQst, false) then
            exit;

        GetSingleInstance();
        JobQueueFunctionLibrary.RemoveScheduledJobTask();
        CleanSharingSettings();
        OnAfterXeroSyncStopped();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterXeroSyncStopped()
    begin
    end;
}
