// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135210 "Azure Key Vault Test Library"
{
    SingleInstance = true;

    var
        AzureKeyVaultImpl: Codeunit "Azure Key Vault Impl.";


    /// <summary>
    /// Sets the secret provider for the Azure key vault.
    /// </summary>
    /// <param name="NewAzureKeyVaultSecretProvider">A new Azure Key Vault secret provider.</param>
    /// <remarks>Use this function only for testing.</remarks>
    procedure SetAzureKeyVaultSecretProvider(NewAzureKeyVaultSecretProvider: DotNet IAzureKeyVaultSecretProvider)
    begin
        AzureKeyVaultImpl.SetAzureKeyVaultSecretProvider(NewAzureKeyVaultSecretProvider);
    end;

    /// <summary>
    /// Clears the key vault cache. Use this function to reinitialize the Azure key vault.
    /// </summary>
    /// <remarks>Use this function only for testing.</remarks>
    procedure ClearSecrets()
    begin
        AzureKeyVaultImpl.ClearSecrets();
    end;
}