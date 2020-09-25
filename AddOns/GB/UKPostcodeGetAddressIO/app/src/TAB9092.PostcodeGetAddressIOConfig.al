// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

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

    [Scope('OnPrem')]
    procedure GetAPIKey(APIKeyGUID: Guid): Text
    var
        APIPassword: Text;
    begin
        IF ISNULLGUID(APIKeyGUID) OR NOT IsolatedStorage.Get(APIKeyGUID, Datascope::Company, APIPassword) THEN
            EXIT('');

        EXIT(APIPassword);
    end;

    [Scope('OnPrem')]
    procedure SaveAPIKey(var APIKeyGUID: Guid; APIKeyValue: Text[250])
    var
    begin
        IF NOT ISNULLGUID(APIKeyGUID) AND (APIKeyValue = '') THEN BEGIN
            If IsolatedStorage.Contains(APIKeyGUID, Datascope::Company) then
                IsolatedStorage.Delete(APIKeyGUID, Datascope::Company);
            CLEAR(APIKey);
        end else begin
            IF ISNULLGUID(APIKey) OR NOT IsolatedStorage.Contains(APIKeyGUID, Datascope::Company) THEN BEGIN
                APIKeyGuid := FORMAT(CreateGuid());
                APIKey := APIKeyGuid;
            end;
            IF NOT EncryptionEnabled() THEN
                IsolatedStorage.Set(APIKeyGUID, APIKeyValue, Datascope::Company)
            else
                IsolatedStorage.SetEncrypted(APIKeyGUID, APIKeyValue, Datascope::Company);
        end;
        Modify();
    end;
}

