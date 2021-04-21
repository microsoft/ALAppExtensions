// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to retrieve app secrets from the key vault that is specified in the app's manifest file.
/// </summary>
codeunit 3800 "App Key Vault Secret Provider" implements "Secret Provider"
{
    Access = Public;

    var
        [NonDebuggable]
        AppKeyVaultSecretPrImpl: Codeunit "App Key Vault Secret Pr. Impl.";

    /// <summary>
    /// Identifies the calling app and initializes the codeunit with the app's key vaults.
    /// </summary>
    [TryFunction]
    [NonDebuggable]
    procedure TryInitializeFromCurrentApp()
    begin
        AppKeyVaultSecretPrImpl.InitializeFromCurrentApp();
    end;

    /// <summary>
    /// Retrieves a secret value from one of the app's key vaults.
    /// </summary>
    /// <param name="SecretName">The name of the secret to retrieve.</param>
    /// <param name="SecretValue">The value of the secret, or the empty string if the value could not be retrieved.</param>
    /// <returns>True if the secret value could be retrieved; false otherwise.</returns>
    [NonDebuggable]
    procedure GetSecret(SecretName: Text; var SecretValue: Text): Boolean
    begin
        exit(AppKeyVaultSecretPrImpl.GetSecret(SecretName, SecretValue));
    end;
}
