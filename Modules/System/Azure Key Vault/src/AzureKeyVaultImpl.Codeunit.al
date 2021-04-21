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
        [NonDebuggable]
        NavAzureKeyVaultClient: DotNet AzureKeyVaultClientHelper;
        [NonDebuggable]
        AzureKeyVaultSecretProvider: DotNet IAzureKeyVaultSecretProvider;
        SecretNotFoundErr: Label '%1 is not an application secret.', Comment = '%1 = Secret Name.';
        [NonDebuggable]
        CachedSecretsDictionary: Dictionary of [Text, Text];
        [NonDebuggable]
        CachedCertificatesDictionary: Dictionary of [Text, Text];
        AllowedApplicationSecretsSecretNameTxt: Label 'AllowedApplicationSecrets', Locked = true;
        [NonDebuggable]
        AllowedSecretNamesList: List of [Text];
        IsKeyVaultClientInitialized: Boolean;
        NoSecretsErr: Label 'The key vault did not have any secrets that are allowed to be fetched.';
        AllowedApplicationSecretsSecretNotFetchedMsg: Label 'The list of allowed secret names could not be fetched.', Locked = true;
        AzureKeyVaultTxt: Label 'Azure Key Vault', Locked = true;
        InitializeAllowedSecretNamesErr: Label 'Initialization of allowed secret names failed.';

    [NonDebuggable]
    procedure GetAzureKeyVaultSecret(SecretName: Text; var Secret: Text)
    begin
        // Gets the secret as a Text from the key vault, given a SecretName.

        if not InitializeAllowedSecretNames() then
            Error(InitializeAllowedSecretNamesErr);

        if not IsSecretNameAllowed(SecretName) then
            Error(SecretNotFoundErr, SecretName);

        Secret := GetSecretFromClient(SecretName);
    end;

    [NonDebuggable]
    procedure GetAzureKeyVaultCertificate(CertificateName: Text; var Certificate: Text)
    begin
        // Gets the certificate as a base 64 encoded string from the key vault, given a CertificateName.

        Certificate := GetCertificateFromClient(CertificateName);
    end;

    [NonDebuggable]
    procedure SetAzureKeyVaultSecretProvider(NewAzureKeyVaultSecretProvider: DotNet IAzureKeyVaultSecretProvider)
    begin
        // Sets the secret provider to simulate the vault. Used for testing.

        ClearSecrets();
        AzureKeyVaultSecretProvider := NewAzureKeyVaultSecretProvider;
    end;

    [NonDebuggable]
    procedure ClearSecrets()
    begin
        Clear(NavAzureKeyVaultClient);
        Clear(AzureKeyVaultSecretProvider);
        Clear(CachedSecretsDictionary);
        Clear(CachedCertificatesDictionary);
        Clear(AllowedSecretNamesList);
        IsKeyVaultClientInitialized := false;
    end;

    [TryFunction]
    [NonDebuggable]
    local procedure TryGetSecretFromClient(SecretName: Text; var Secret: Text)
    begin
        Secret := GetSecretFromClient(SecretName);
    end;

    [NonDebuggable]
    local procedure GetSecretFromClient(SecretName: Text) Secret: Text
    begin
        if CachedSecretsDictionary.ContainsKey(SecretName) then begin
            Secret := CachedSecretsDictionary.Get(SecretName);
            exit;
        end;

        if not IsKeyVaultClientInitialized then begin
            NavAzureKeyVaultClient := NavAzureKeyVaultClient.AzureKeyVaultClientHelper();
            NavAzureKeyVaultClient.SetAzureKeyVaultProvider(AzureKeyVaultSecretProvider);
            IsKeyVaultClientInitialized := true;
        end;
        Secret := NavAzureKeyVaultClient.GetAzureKeyVaultSecret(SecretName);

        CachedSecretsDictionary.Add(SecretName, Secret);
    end;

    [NonDebuggable]
    local procedure GetCertificateFromClient(CertificateName: Text) Certificate: Text
    begin
        if CachedCertificatesDictionary.ContainsKey(CertificateName) then begin
            Certificate := CachedCertificatesDictionary.Get(CertificateName);
            exit;
        end;

        if not IsKeyVaultClientInitialized then begin
            NavAzureKeyVaultClient := NavAzureKeyVaultClient.AzureKeyVaultClientHelper();
            NavAzureKeyVaultClient.SetAzureKeyVaultProvider(AzureKeyVaultSecretProvider);
            IsKeyVaultClientInitialized := true;
        end;
        Certificate := NavAzureKeyVaultClient.GetAzureKeyVaultCertificate(CertificateName);

        CachedCertificatesDictionary.Add(CertificateName, Certificate);
    end;

    [NonDebuggable]
    local procedure IsSecretNameAllowed(SecretName: Text): Boolean
    var
        UppercaseSecretName: Text;
    begin
        UppercaseSecretName := UpperCase(SecretName);
        exit(AllowedSecretNamesList.Contains(UppercaseSecretName));
    end;

    [NonDebuggable]
    local procedure InitializeAllowedSecretNames(): Boolean
    var
        AllowedSecretNames: Text;
    begin
        if AllowedSecretNamesList.Count() > 0 then
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

        AllowedSecretNamesList := AllowedSecretNames.Split(',');
        exit(true);
    end;
}

