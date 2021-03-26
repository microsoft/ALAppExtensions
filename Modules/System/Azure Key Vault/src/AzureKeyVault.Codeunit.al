// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to handle the retrieval of azure key vault secrets, along with setting the provider and clear the secrets cache used.
/// </summary>
codeunit 2200 "Azure Key Vault"
{
    Access = Public;
    SingleInstance = true;

    var
        [NonDebuggable]
        AzureKeyVaultImpl: Codeunit "Azure Key Vault Impl.";

    /// <summary>
    /// Retrieves a secret from the key vault.
    /// </summary>
    /// <remarks>This is a try function.</remarks>
    /// <param name="SecretName">The name of the secret to retrieve.</param>
    /// <param name="Secret">Out parameter that holds the secret that was retrieved from the key vault.</param>
    /// <remarks>As a best practice, you should only store secrets in a key vault. For example, avoid storing information that can be available elsewhere, such as configuration details or URLs.</remarks>
    [TryFunction]
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetAzureKeyVaultSecret(SecretName: Text; var Secret: Text)
    begin
        AzureKeyVaultImpl.GetAzureKeyVaultSecret(SecretName, Secret);
    end;

    /// <summary>
    /// Retrieves a certificate from the key vault.
    /// </summary>
    /// <remarks>This is a try function.</remarks>
    /// <param name="CertificateName">The name of the secret to retrieve.</param>
    /// <param name="Certificate">Out parameter that holds the certificate as a base 64 encoded string that was retrieved from the key vault.</param>
    /// <remarks>As a best practice, you should only store secrets in a key vault. For example, avoid storing information that can be available elsewhere, such as configuration details or URLs.</remarks>
    [TryFunction]
    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetAzureKeyVaultCertificate(CertificateName: Text; var Certificate: Text)
    begin
        AzureKeyVaultImpl.GetAzureKeyVaultCertificate(CertificateName, Certificate);
    end;
}

