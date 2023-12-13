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
        field(3; "Show Setup Notification"; Boolean)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Notification is now using the My notifications table';
            ObsoleteTag = '18.0';
            Editable = false;
            InitValue = true;
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
        field(15; "API Cache Minutes"; Integer)
        {
            Description = 'Default period in minutes for caching the API URI and API Key.';
            InitValue = 5;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not Used After Refactoring';
            DataClassification = CustomerContent;
            ObsoleteTag = '18.0';
        }
        field(16; "API Cache Expiry"; DateTime)
        {
            Description = 'Expiration datetime for the API URI and API Key.';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not Used After Refactoring';
            DataClassification = CustomerContent;
            ObsoleteTag = '18.0';
        }
        field(17; "Service Pass API Uri ID"; Guid)
        {
            Description = 'The Key for retrieving the API URI from the Service Password table.';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not Used After Refactoring';
            DataClassification = CustomerContent;
            ObsoleteTag = '18.0';
        }
        field(18; "Service Pass API Key ID"; Guid)
        {
            Description = 'The Key for retrieving the API Key from the Service Password table.';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not Used After Refactoring';
            DataClassification = CustomerContent;
            ObsoleteTag = '18.0';
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
            CryptographyManagement.EnableEncryption(FALSE);
    end;

    [NonDebuggable]
    procedure URIOrKeyEmpty(): Boolean
    var
        EnvironmentInfo: Codeunit "Environment Information";
    begin
        if EnvironmentInfo.IsSaaS() then
            exit(false);
        exit((GetAPIUri() = '') or (GetAPIKey() = ''));
    end;

    [NonDebuggable]
    [Scope('OnPrem')]
    procedure GetUserDefinedAPIKey(): Text[250]
    begin
        // If the user has defined the API Key in the page UI, then retrieve it from
        // the encrypted Isolated Storage table
        if IsNullGuid("API Key ID") then
            exit('');

        exit(TryReadAPICredential("API Key ID"));
    end;

    [NonDebuggable]
    [Scope('OnPrem')]
    procedure SetUserDefinedAPIKey(UserDefinedAPIKey: Text[250])
    begin
        // Store the user-defined API Key in the Isolated Storage and save its GUID in the "API Key ID"
        if UserDefinedAPIKey = '' then begin
            DeleteAPICredential("API Key ID");
            exit;
        end;
        "API Key ID" := InsertAPICredential(UserDefinedAPIKey);
    end;

    [NonDebuggable]
    procedure GetAPIKey(): Text[250]
    var
        UserDefinedAPIKey: Text[250];
    begin
        // The API Key and URI entered by the user take precedence
        UserDefinedAPIKey := GetUserDefinedAPIKey();
        if UserDefinedAPIKey <> '' then
            exit(UserDefinedAPIKey);
        exit('');
    end;

    procedure GetAPIUri(): Text[250]
    begin
        // The API Key and URI entered by the user take precedence
        if "API URI" <> '' then
            exit("API URI");
        exit('');
    end;

    [NonDebuggable]
    local procedure TryReadAPICredential(CredentialGUID: Guid): Text[250]
    var
        CredentialValue: Text;
    begin
        if IsNullGuid(CredentialGUID) then
            exit('');

        if not IsolatedStorage.Contains(CredentialGUID, Datascope::Company) then
            exit('');

        IsolatedStorage.Get(CredentialGUID, Datascope::Company, CredentialValue);
        exit(CopyStr(CredentialValue, 1, 250));
    end;

    [NonDebuggable]
    local procedure InsertAPICredential(NewValue: Text[250]): Guid
    var
        NewKey: Text;
    begin
        NewKey := FORMAT(CreateGuid());

        IF NOT EncryptionEnabled() THEN
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
        if not IsolatedStorage.Contains(KeyId, Datascope::Company) THEN
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

