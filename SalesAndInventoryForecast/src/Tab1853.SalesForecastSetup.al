// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 1853 "MS - Sales Forecast Setup"
{
    Permissions = TableData "Service Password" = rimd;
    ReplicateData = false;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
        }
        field(2; "Period Type"; Option)
        {
            InitValue = Month;
            OptionMembers = Day,Week,Month,Quarter,Year;
        }
        field(3; "Show Setup Notification"; Boolean)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Notification is now using the My notifications table';
            Editable = false;
            InitValue = true;
        }
        field(4; "Stockout Warning Horizon"; Integer)
        {
            InitValue = 3;
        }
        field(5; Horizon; Integer)
        {
            InitValue = 12;
        }
        field(6; "API URI"; Text[250])
        {
        }
        field(7; "API Key ID"; Guid)
        {

            trigger OnValidate()
            begin
                if not IsNullGuid("API Key ID") then
                    EnableEncryption();
            end;
        }
        field(8; "Timeout (seconds)"; Integer)
        {
            InitValue = 60;
        }
        field(9; "Variance %"; Decimal)
        {
            InitValue = 35;
            MaxValue = 100;
            MinValue = 1;
        }
        field(10; "Expiration Period (Days)"; Integer)
        {
            InitValue = 7;
        }
        field(11; "Historical Periods"; Integer)
        {
            InitValue = 24;
            MinValue = 5;
        }
        field(12; "Last Run Completed"; DateTime)
        {
            Editable = false;
        }
        field(13; Limit; Decimal)
        {
            Editable = false;
        }
        field(14; "Processing Time"; Decimal)
        {
            Editable = false;
        }
        field(15; "API Cache Minutes"; Integer)
        {
            Description = 'Default period in minutes for caching the API URI and API Key.';
            InitValue = 5;
        }
        field(16; "API Cache Expiry"; DateTime)
        {
            Description = 'Expiration datetime for the API URI and API Key.';
        }
        field(17; "Service Pass API Uri ID"; Guid)
        {
            Description = 'The Key for retrieving the API URI from the Service Password table.';
            TableRelation = "Service Password".Key;
        }
        field(18; "Service Pass API Key ID"; Guid)
        {
            Description = 'The Key for retrieving the API Key from the Service Password table.';
            TableRelation = "Service Password".Key;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    var
        SalesForecastScheduler: Codeunit "Sales Forecast Scheduler";
        SpecifyApiKeyErr: Label 'You must specify an API key and an API URI in the Sales and Inventory Forecast Setup page.';
        ExceedingLenghtErr: Label 'It is not possible to have the Uri %1 in a field with a length of %2.';

    procedure GetSingleInstance(AzureKeyVaultManagement: Codeunit "Azure Key Vault Management")
    begin
        if not Get() then begin
            Init();
            Insert();
        end;
        RefreshURIAndKey(AzureKeyVaultManagement);
    end;

    local procedure RefreshURIAndKey(AzureKeyVaultManagement: Codeunit "Azure Key Vault Management")
    var
        ServicePassword: Record "Service Password";
        PermissionManager: Codeunit "Permission Manager";
        APIKey: Text[200];
        APIURI: Text[250];
        LimitType: Option;
    begin
        if not PermissionManager.SoftwareAsAService() then
            exit;

        if SalesForecastScheduler.JobQueueEntryCreationInProcess() then
            exit;

        if APICacheExpired() or URIOrKeyEmpty() then begin
            if not AzureKeyVaultManagement.GetMLForecastCredentials(APIURI, APIKey, LimitType, Limit) then
                // The Azure ML KeyVault interrogation returned an error. Falling back to the previous credentials, if any.
                exit;
            if (APIKey = '') or (APIURI = '') or (Limit <= 0) then
                // No credentials received (KeyVault unavailable), or credentials invalid. Falling back to the previous credentials, if any.
                exit;

            if ServicePassword.WritePermission() then begin
                SetKeyVaultAPIKey(APIKey);
                SetKeyVaultAPIUri(CheckUriLength(APIURI + '/execute?api-version=2.0&details=true'));
            end;

            Validate("API Cache Expiry", CreateDateTime(WorkDate(), Time()) + HMSDuration(0, "API Cache Minutes", 0));
            Validate(Limit);
            Modify(true);
        end;
    end;

    local procedure CheckUriLength(Txt: Text): Text[250];
    begin
        if STRLEN(Txt) > 250 then
            ERROR(ExceedingLenghtErr, Txt, 250);
        exit(CopyStr(Txt, 1, 250));
    end;

    procedure CheckURIAndKey()
    begin
        if URIOrKeyEmpty() then
            Error(SpecifyApiKeyErr);
    end;

    local procedure EnableEncryption()
    var
        EncryptionManagement: Codeunit "Encryption Management";
    begin
        if not EncryptionManagement.IsEncryptionEnabled() then
            EncryptionManagement.EnableEncryption();
    end;

    local procedure APICacheExpired(): Boolean
    begin
        if "API Cache Expiry" = 0DT then
            exit(false);
        exit(("API Cache Expiry" - CreateDateTime(WorkDate(), Time())) < 0);
    end;

    procedure URIOrKeyEmpty(): Boolean
    begin
        exit((GetAPIUri() = '') or (GetAPIKey() = ''));
    end;

    local procedure HMSDuration(H: Integer; M: Integer; S: Integer): Duration
    begin
        exit((((H * 60) + M) * 60 + S) * 1000);
    end;

    procedure GetUserDefinedAPIKey(): Text[250]
    begin
        // If the user has defined the API Key in the page UI, then retrieve it from
        // the encrypted Service Password table
        if IsNullGuid("API Key ID") then
            exit('');

        exit(TryReadAPICredential("API Key ID"));
    end;

    procedure SetUserDefinedAPIKey(UserDefinedAPIKey: Text[250])
    begin
        // Store the user-defined API Key in Service Password and remember its GUID in "API Key ID"
        if UserDefinedAPIKey = '' then begin
            DeleteAPICredential("API Key ID");
            exit;
        end;
        "API Key ID" := InsertAPICredential(UserDefinedAPIKey);
    end;

    procedure GetAPIKey(): Text[250]
    var
        UserDefinedAPIKey: Text[250];
    begin
        // The API Key and URI entered by the user take precedence
        UserDefinedAPIKey := GetUserDefinedAPIKey();
        if UserDefinedAPIKey <> '' then
            exit(UserDefinedAPIKey);

        // Try to retrieve the API URI cached and encrypted in the Service Password table
        exit(TryReadAPICredential("Service Pass API Key ID"));
    end;

    procedure GetAPIUri(): Text[250]
    begin
        // The API Key and URI entered by the user take precedence
        if "API URI" <> '' then
            exit("API URI");

        // Try to retrieve the API URI cached and encrypted in the Service Password table
        exit(TryReadAPICredential("Service Pass API Uri ID"));
    end;

    local procedure SetKeyVaultAPIUri(NewValue: Text[250])
    var
        ServicePassword: Record "Service Password";
    begin
        // First time storing it, create a new key
        if IsNullGuid("Service Pass API Uri ID") then begin
            "Service Pass API Uri ID" := InsertAPICredential(NewValue);
            Modify();
            exit;
        end;

        // Invalid key, creating a new one
        if not ServicePassword.Get("Service Pass API Uri ID") then begin
            "Service Pass API Uri ID" := InsertAPICredential(NewValue);
            Modify();
            exit;
        end;

        // Update the value on the existing (valid) key
        ServicePassword.SavePassword(NewValue);
        ServicePassword.Modify();
    end;

    local procedure SetKeyVaultAPIKey(NewValue: Text[250])
    var
        ServicePassword: Record "Service Password";
    begin
        // First time storing it, create a new key
        if IsNullGuid("Service Pass API Key ID") then begin
            "Service Pass API Key ID" := InsertAPICredential(NewValue);
            Modify();
            exit;
        end;

        // Invalid key, creating a new one
        if not ServicePassword.Get("Service Pass API Key ID") then begin
            "Service Pass API Key ID" := InsertAPICredential(NewValue);
            Modify();
            exit;
        end;

        // Update the value on the existing (valid) key
        ServicePassword.SavePassword(NewValue);
        ServicePassword.Modify();
    end;

    local procedure TryReadAPICredential(CredentialGUID: Guid): Text[250]
    var
        ServicePassword: Record "Service Password";
    begin
        if IsNullGuid(CredentialGUID) then
            exit('');

        if not ServicePassword.Get(CredentialGUID) then
            exit('');

        exit(CopyStr(ServicePassword.GetPassword(), 1, 250));
    end;

    local procedure InsertAPICredential(NewValue: Text[250]): Guid
    var
        ServicePassword: Record "Service Password";
    begin
        ServicePassword.Init();
        ServicePassword.SavePassword(NewValue);
        ServicePassword.Insert(true);
        exit(ServicePassword.Key)
    end;

    local procedure DeleteAPICredential(KeyId: Guid)
    var
        ServicePassword: Record "Service Password";
    begin
        // Clear the local key id
        Clear("API Key ID");
        Modify();

        // Delete the stored API Key from Service Password table
        if ServicePassword.Get(KeyId) then
            ServicePassword.Delete();
    end;
}

