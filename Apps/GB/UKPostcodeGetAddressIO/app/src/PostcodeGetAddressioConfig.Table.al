// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Address;

using System.Telemetry;

table 9092 "Postcode GetAddress.io Config"
{
    ReplicateData = false;

    fields
    {
        field(1; EndpointURL; Text[250]) { }
        field(2; APIKey; Guid) { }
        field(3; "Primary Key"; Code[10]) { }
    }

    keys
    {
        key(Key1; "Primary Key") { }
    }

    [NonDebuggable]
    [Scope('OnPrem')]
    procedure GetAPIKey(APIKeyGUID: Guid): Text
    var
        APIPassword: Text;
    begin
        if IsNullGuid(APIKeyGUID) or not IsolatedStorage.Get(APIKeyGUID, Datascope::Company, APIPassword) then
            exit('');

        exit(APIPassword);
    end;

    [NonDebuggable]
    [Scope('OnPrem')]
    procedure SaveAPIKey(var APIKeyGUID: Guid; APIKeyValue: Text[250])
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        if not IsNullGuid(APIKeyGUID) AND (APIKeyValue = '') then begin
            If IsolatedStorage.Contains(APIKeyGUID, Datascope::Company) then
                IsolatedStorage.Delete(APIKeyGUID, Datascope::Company);
            Clear(APIKey);
        end else begin
            if IsNullGuid(APIKey) or not IsolatedStorage.Contains(APIKeyGUID, Datascope::Company) then begin
                APIKeyGuid := Format(CreateGuid());
                APIKey := APIKeyGuid;
            end;
            if not EncryptionEnabled() then
                IsolatedStorage.Set(APIKeyGUID, APIKeyValue, Datascope::Company)
            else
                IsolatedStorage.SetEncrypted(APIKeyGUID, APIKeyValue, Datascope::Company);

            FeatureTelemetry.LogUptake('0000FW7', 'GetAddress.io UK Postcodes', Enum::"Feature Uptake Status"::"Set up");
        end;
        Modify();
    end;
}

