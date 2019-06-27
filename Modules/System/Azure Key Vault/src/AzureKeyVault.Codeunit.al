// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
///
/// </summary>
codeunit 2200 "Azure Key Vault"
{
    Access = Public;
    SingleInstance = true;

    var
        AzureKeyVaultImpl: Codeunit "Azure Key Vault Impl.";

    /// <summary>
    /// Retrieves a secret from the key vault.
    /// </summary>
    /// <remarks>This is a try function.</remarks>
    /// <param name="SecretName">The name of the secret to retrieve.</param>
    /// <param name="Secret">Out parameter that holds the secret that was retrieved from the key vault.</param>
    [TryFunction]
    [Scope('OnPrem')]
    procedure GetAzureKeyVaultSecret(SecretName: Text; var Secret: Text)
    begin
        AzureKeyVaultImpl.GetAzureKeyVaultSecret(SecretName, Secret);
    end;

    /// <summary>
    /// Clears the key vault cache. Use this function to reinitialize the Azure key vault.
    /// </summary>
    /// <remarks>Use this function only for testing.</remarks>
    [Scope('OnPrem')]
    procedure ClearSecrets()
    begin
        AzureKeyVaultImpl.ClearSecrets();
    end;

    /// <summary>
    /// Sets the secret provider for the Azure key vault.
    /// </summary>
    /// <remarks>Use this function only for testing.</remarks>
    [Scope('OnPrem')]
    procedure SetAzureKeyVaultSecretProvider(NewAzureKeyVaultSecretProvider: DotNet IAzureKeyVaultSecretProvider)
    begin
        AzureKeyVaultImpl.SetAzureKeyVaultSecretProvider(NewAzureKeyVaultSecretProvider);
    end;
}

