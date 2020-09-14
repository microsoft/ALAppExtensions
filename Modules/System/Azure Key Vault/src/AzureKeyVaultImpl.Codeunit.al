// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
///
/// </summary>
codeunit 2202 "Azure Key Vault Impl."
{
    Access = Internal;
    SingleInstance = true;


    var
        NavAzureKeyVaultClient: DotNet AzureKeyVaultClientHelper;
        AzureKeyVaultSecretProvider: DotNet IAzureKeyVaultSecretProvider;
        SecretNotFoundErr: Label '%1 is not an application secret.', Comment = '%1 = Secret Name.';
        CachedSecretsDictionary: DotNet GenericDictionary2;
        AllowedApplicationSecretsSecretNameTxt: Label 'AllowedApplicationSecrets', Locked = true;
        AllowedSecretNamesArray: DotNet Array;
        IsKeyVaultClientInitialized: Boolean;
        NoSecretsErr: Label 'The key vault did not have any secrets that are allowed to be fetched.';
        AllowedApplicationSecretsSecretNotFetchedMsg: Label 'The list of allowed secret names could not be fetched.', Locked = true;
        AzureKeyVaultTxt: Label 'Azure Key Vault', Locked = true;
        InitializeAllowedSecretNamesErr: Label 'Initialization of allowed secret names failed.';

    procedure GetAzureKeyVaultSecret(SecretName: Text; var Secret: Text)
    begin
        // Gets the secret as a Text from the key vault, given a SecretName.

        if not InitializeAllowedSecretNames() then
            Error(InitializeAllowedSecretNamesErr);

        if not IsSecretNameAllowed(SecretName) then
            Error(SecretNotFoundErr, SecretName);

        Secret := GetSecretFromClient(SecretName);
    end;

    procedure SetAzureKeyVaultSecretProvider(NewAzureKeyVaultSecretProvider: DotNet IAzureKeyVaultSecretProvider)
    begin
        // Sets the secret provider to simulate the vault. Used for testing.

        ClearSecrets();
        AzureKeyVaultSecretProvider := NewAzureKeyVaultSecretProvider;
    end;

    procedure ClearSecrets()
    begin
        Clear(NavAzureKeyVaultClient);
        Clear(AzureKeyVaultSecretProvider);

        InitBuffer();

        CachedSecretsDictionary.Clear();
        IsKeyVaultClientInitialized := false;
        Clear(AllowedSecretNamesArray);
    end;

    [TryFunction]
    local procedure TryGetSecretFromClient(SecretName: Text; var Secret: Text)
    begin
        Secret := GetSecretFromClient(SecretName);
    end;

    local procedure GetSecretFromClient(SecretName: Text) Secret: Text
    begin
        if KeyValuePairInBuffer(SecretName, Secret) then
            exit;

        if not IsKeyVaultClientInitialized then begin
            NavAzureKeyVaultClient := NavAzureKeyVaultClient.AzureKeyVaultClientHelper();
            NavAzureKeyVaultClient.SetAzureKeyVaultProvider(AzureKeyVaultSecretProvider);
            IsKeyVaultClientInitialized := true;
        end;
        Secret := NavAzureKeyVaultClient.GetAzureKeyVaultSecret(SecretName);

        StoreKeyValuePairInBuffer(SecretName, Secret);
    end;

    local procedure KeyValuePairInBuffer("Key": Text; var Value: Text): Boolean
    var
        ValueFound: Boolean;
        ValueToReturn: Text;
    begin
        InitBuffer();

        ValueFound := CachedSecretsDictionary.TryGetValue(Key, ValueToReturn);
        Value := ValueToReturn;
        exit(ValueFound);
    end;

    local procedure StoreKeyValuePairInBuffer("Key": Text; Value: Text)
    begin
        InitBuffer();

        CachedSecretsDictionary.Add(Key, Value);
    end;

    local procedure InitBuffer()
    begin
        if IsNull(CachedSecretsDictionary) then
            CachedSecretsDictionary := CachedSecretsDictionary.Dictionary();
    end;

    local procedure IsSecretNameAllowed(SecretName: Text): Boolean
    var
        Name: Text;
        UppercaseSecretName: Text;
    begin
        UppercaseSecretName := UpperCase(SecretName);
        foreach Name in AllowedSecretNamesArray do
            if Name = UppercaseSecretName then
                exit(true);
    end;

    local procedure InitializeAllowedSecretNames(): Boolean
    var
        AllowedSecretNames: DotNet String;
        Delimiters: DotNet String;
    begin
        if not IsNull(AllowedSecretNamesArray) then
            exit(true);

        if not TryGetSecretFromClient(AllowedApplicationSecretsSecretNameTxt, AllowedSecretNames) then begin
            Session.LogMessage('0000970', AllowedApplicationSecretsSecretNotFetchedMsg, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', AzureKeyVaultTxt);
            exit(false);
        end;

        AllowedSecretNames := UpperCase(AllowedSecretNames);
        if StrLen(AllowedSecretNames) = 0 then begin
            Session.LogMessage('00008E8', NoSecretsErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', AzureKeyVaultTxt);
            exit(false);
        end;

        Delimiters := ',';
        AllowedSecretNamesArray := AllowedSecretNames.Split(Delimiters.ToCharArray());
        exit(true);
    end;
}

