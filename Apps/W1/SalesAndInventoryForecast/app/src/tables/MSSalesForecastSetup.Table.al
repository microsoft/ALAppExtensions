namespace Microsoft.Inventory.InventoryForecast;

using System.AI;
using System.Environment;
using System.Security.Encryption;
using System.Security.User;
using System.Privacy;
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 1853 "MS - Sales Forecast Setup"
{
    ReplicateData = false;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Period Type"; Option)
        {
            InitValue = Month;
            OptionMembers = Day,Week,Month,Quarter,Year;
            DataClassification = CustomerContent;
        }
        field(4; "Stockout Warning Horizon"; Integer)
        {
            DataClassification = CustomerContent;
            InitValue = 3;
        }
        field(5; Horizon; Integer)
        {
            DataClassification = CustomerContent;
            InitValue = 12;
        }
        field(6; "API URI"; Text[250])
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                AzureMLConnector: Codeunit "Azure ML Connector";
            begin
                AzureMLConnector.ValidateApiUrl("API URI");
            end;
        }
        field(7; "API Key ID"; Guid)
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if not IsNullGuid("API Key ID") then
                    EnableEncryption();
            end;
        }
        field(8; "Timeout (seconds)"; Integer)
        {
            InitValue = 60;
            DataClassification = CustomerContent;
        }
        field(9; "Variance %"; Decimal)
        {
            InitValue = 35;
            MaxValue = 100;
            MinValue = 1;
            DataClassification = CustomerContent;
        }
        field(10; "Expiration Period (Days)"; Integer)
        {
            InitValue = 7;
            DataClassification = CustomerContent;
        }
        field(11; "Historical Periods"; Integer)
        {
            InitValue = 24;
            MinValue = 5;
            DataClassification = CustomerContent;
        }
        field(12; "Last Run Completed"; DateTime)
        {
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(13; Limit; Decimal)
        {
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14; "Processing Time"; Decimal)
        {
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(19; "Timeseries Model"; Option)
        {
            OptionMembers = ARIMA,ETS,STL,"ETS+ARIMA","ETS+STL",ALL,TBATS;
            DataClassification = CustomerContent;
        }
        field(20; Enabled; Boolean)
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    var
        SpecifyApiKeyErr: Label 'You must specify an API key and an API URI in the Sales and Inventory Forecast Setup page.';
        NotAdminErr: Label 'You must be an administrator to enable/disable sales forecasting. Ensure that you are assigned the ''SUPER'' user permission set.';

    procedure GetSingleInstance()
    begin
        if not Get() then begin
            Init();
            Insert();
            Commit();
        end;
    end;

    procedure CheckURIAndKey()
    begin
        if URIOrKeyEmpty() then
            Error(SpecifyApiKeyErr);
    end;

    local procedure EnableEncryption()
    var
        CryptographyManagement: Codeunit "Cryptography Management";
    begin
        if not CryptographyManagement.IsEncryptionEnabled() then
            CryptographyManagement.EnableEncryption(false);
    end;

    procedure URIOrKeyEmpty(): Boolean
    var
        EnvironmentInfo: Codeunit "Environment Information";
    begin
        if EnvironmentInfo.IsSaaS() then
            exit(false);
        exit((GetAPIUri() = '') or GetAPIKeyAsSecret().IsEmpty());
    end;

#if not CLEAN24
    [NonDebuggable]
    [Scope('OnPrem')]
    [Obsolete('Use GetUserDefinedAPIKeyAsSecret() instead.', '24.0')]
    procedure GetUserDefinedAPIKey(): Text[250]
    begin
        // If the user has defined the API Key in the page UI, then retrieve it from
        // the encrypted Isolated Storage table
        if IsNullGuid("API Key ID") then
            exit('');

        exit(CopyStr(TryReadAPICredentialAsSecret("API Key ID").Unwrap(), 1, 250));
    end;
#endif
    [Scope('OnPrem')]
    procedure GetUserDefinedAPIKeyAsSecret(): SecretText
    var
        EmptyText: Text[250];
    begin
        // If the user has defined the API Key in the page UI, then retrieve it from
        // the encrypted Isolated Storage table
        EmptyText := '';
        if IsNullGuid("API Key ID") then
            exit(EmptyText);

        exit(TryReadAPICredentialAsSecret("API Key ID"));
    end;

    [Scope('OnPrem')]
    procedure SetUserDefinedAPIKey(UserDefinedAPIKey: SecretText)
    begin
        // Store the user-defined API Key in the Isolated Storage and save its GUID in the "API Key ID"
        if UserDefinedAPIKey.IsEmpty() then begin
            DeleteAPICredential("API Key ID");
            exit;
        end;
        "API Key ID" := InsertAPICredential(UserDefinedAPIKey);
    end;

#if not CLEAN24
    [NonDebuggable]
    [Obsolete('Use GetAPIKeyAsSecret() instead.', '24.0')]
    procedure GetAPIKey(): Text[250]
    var
        UserDefinedAPIKey: Text[250];
    begin
        // The API Key and URI entered by the user take precedence
        UserDefinedAPIKey := CopyStr(GetUserDefinedAPIKeyAsSecret().Unwrap(), 1, 250);
        if UserDefinedAPIKey <> '' then
            exit(UserDefinedAPIKey);
        exit('');
    end;
#endif
    procedure GetAPIKeyAsSecret(): SecretText
    var
        UserDefinedAPIKey: SecretText;
    begin
        // The API Key and URI entered by the user take precedence
        UserDefinedAPIKey := GetUserDefinedAPIKeyAsSecret();
        if not UserDefinedAPIKey.IsEmpty() then
            exit(UserDefinedAPIKey);
        exit(UserDefinedAPIKey);
    end;

    procedure GetAPIUri(): Text[250]
    begin
        // The API Key and URI entered by the user take precedence
        if "API URI" <> '' then
            exit("API URI");
        exit('');
    end;

    local procedure TryReadAPICredentialAsSecret(CredentialGUID: Guid): SecretText
    var
        CredentialValue: Text;
        CredentialValueAsSecret: SecretText;
    begin
        CredentialValue := '';
        CredentialValueAsSecret := CredentialValue;
        if IsNullGuid(CredentialGUID) then
            exit(CredentialValueAsSecret);

        if not IsolatedStorage.Contains(CredentialGUID, Datascope::Company) then
            exit(CredentialValueAsSecret);

        IsolatedStorage.Get(CredentialGUID, Datascope::Company, CredentialValueAsSecret);
        exit(CredentialValueAsSecret);
    end;

    local procedure InsertAPICredential(NewValue: SecretText): Guid
    var
        NewKey: Text;
    begin
        NewKey := FORMAT(CreateGuid());

        if not EncryptionEnabled() then
            IsolatedStorage.Set(NewKey, NewValue, Datascope::Company)
        else
            IsolatedStorage.SetEncrypted(NewKey, NewValue, Datascope::Company);
        exit(NewKey)
    end;

    local procedure DeleteAPICredential(KeyId: Guid)
    begin
        // Clear the local key id
        Clear("API Key ID");
        Modify();

        // Delete the stored API Key from Isolated Storage table
        if not IsolatedStorage.Contains(KeyId, Datascope::Company) then
            exit;

        IsolatedStorage.Delete(KeyId, Datascope::Company);
    end;

    internal procedure CheckEnabled()
    var
        CustomerConsentMgt: Codeunit "Customer Consent Mgt.";
        UserPermissions: Codeunit "User Permissions";
    begin
        if not Rec.Enabled then begin
            if not UserPermissions.IsSuper(UserSecurityId()) then
                Error(NotAdminErr);
            if CustomerConsentMgt.ConsentToMicrosoftServiceWithAI() then begin
                Rec.Enabled := true;
                Rec.Modify(true);
            end else
                Error('');
        end;
    end;
}
