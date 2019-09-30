// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135205 "Azure Key Vault Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Azure] [Key Vault]
    end;

    var
        Assert: Codeunit "Library Assert";
        SecretNotFoundErr: Label '%1 is not an application secret.', Comment = '%1 = Secret Name.';
        SecretNotInitializedTxt: Label 'Initialization of allowed secret names failed';
        AllowedApplicationSecretsSecretNameTxt: Label 'AllowedApplicationSecrets', Locked = true;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure GetAzureKeyVaultSecretTest()
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        AzureKeyVaultTestLibrary: Codeunit "Azure Key Vault Test Library";
        MockAzureKeyvaultSecretProvider: DotNet MockAzureKeyVaultSecretProvider;
        Secret: Text;
    begin
        // [SCENARIO] When the key vault is called, the correct value is retrieved

        // [GIVEN] A configured Azure Key Vault
        MockAzureKeyvaultSecretProvider := MockAzureKeyvaultSecretProvider.MockAzureKeyVaultSecretProvider();
        MockAzureKeyvaultSecretProvider.AddSecretMapping(AllowedApplicationSecretsSecretNameTxt, 'some-secret,');
        MockAzureKeyvaultSecretProvider.AddSecretMapping('some-secret', 'SecretFromKeyVault');
        AzureKeyVaultTestLibrary.SetAzureKeyVaultSecretProvider(MockAzureKeyvaultSecretProvider);

        // [WHEN] The key vault is called
        AzureKeyVault.GetAzureKeyVaultSecret('some-secret', Secret);

        // [THEN] The value is retrieved
        Assert.AreEqual('SecretFromKeyVault', Secret, 'The returned secret does not match.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure GetAzureKeyVaultSecretChangeProviderTest()
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        AzureKeyVaultTestLibrary: Codeunit "Azure Key Vault Test Library";
        FirstMockAzureKeyvaultSecretProvider: DotNet MockAzureKeyVaultSecretProvider;
        SecondMockAzureKeyvaultSecretProvider: DotNet MockAzureKeyVaultSecretProvider;
        Secret: Text;
    begin
        // [SCENARIO] When the key vault secret provider is changed, the cache is cleared and the new value is retrieved

        // [GIVEN] A configured Azure Key Vault
        FirstMockAzureKeyvaultSecretProvider := FirstMockAzureKeyvaultSecretProvider.MockAzureKeyVaultSecretProvider();
        FirstMockAzureKeyvaultSecretProvider.AddSecretMapping(AllowedApplicationSecretsSecretNameTxt, 'some-secret');
        FirstMockAzureKeyvaultSecretProvider.AddSecretMapping('some-secret', 'AnotherSecretFromTheKeyVault');
        AzureKeyVaultTestLibrary.SetAzureKeyVaultSecretProvider(FirstMockAzureKeyvaultSecretProvider);

        // [WHEN] The key vault is called
        AzureKeyVault.GetAzureKeyVaultSecret('some-secret', Secret);

        // [THEN] The value is retrieved
        Assert.AreEqual('AnotherSecretFromTheKeyVault', Secret, 'The returned secret does not match.');

        // [WHEN] The Key Vault Secret Provider is changed
        SecondMockAzureKeyvaultSecretProvider := SecondMockAzureKeyvaultSecretProvider.MockAzureKeyVaultSecretProvider();
        SecondMockAzureKeyvaultSecretProvider.AddSecretMapping(AllowedApplicationSecretsSecretNameTxt, 'some-secret');
        SecondMockAzureKeyvaultSecretProvider.AddSecretMapping('some-secret', 'SecretFromKeyVault');
        AzureKeyVaultTestLibrary.SetAzureKeyVaultSecretProvider(SecondMockAzureKeyvaultSecretProvider);
        AzureKeyVault.GetAzureKeyVaultSecret('some-secret', Secret);

        // [THEN] The cache is cleared and the value is retrieved
        Assert.AreEqual('SecretFromKeyVault', Secret, 'The returned secret was incorrect.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetAzureKeyVaultSecretMissingSecretTest()
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        AzureKeyVaultTestLibrary: Codeunit "Azure Key Vault Test Library";
        MockAzureKeyvaultSecretProvider: DotNet MockAzureKeyVaultSecretProvider;
        Secret: Text;
    begin
        // [SCENARIO] When an unknown key is provided, then retrieval of the secret fails

        // [GIVEN] A configured Azure Key Vault
        MockAzureKeyvaultSecretProvider := MockAzureKeyvaultSecretProvider.MockAzureKeyVaultSecretProvider();
        MockAzureKeyvaultSecretProvider.AddSecretMapping(AllowedApplicationSecretsSecretNameTxt, 'somesecret');
        MockAzureKeyvaultSecretProvider.AddSecretMapping('somesecret', 'AnotherSecretFromTheKeyVault');
        AzureKeyVaultTestLibrary.SetAzureKeyVaultSecretProvider(MockAzureKeyvaultSecretProvider);

        // [WHEN] The key vault is called with an unknown key
        asserterror AzureKeyVault.GetAzureKeyVaultSecret('somekeythatdoesnotexist', Secret);

        // [THEN] An error is thrown
        Assert.ExpectedError(StrSubstNo(SecretNotFoundErr, 'somekeythatdoesnotexist'));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ClearSecretsTest()
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        AzureKeyVaultTestLibrary: Codeunit "Azure Key Vault Test Library";
        MockAzureKeyvaultSecretProvider: DotNet MockAzureKeyVaultSecretProvider;
        Secret: Text;
    begin
        // [SCENARIO] When the secrets are cleared from the key vault, they can no longer be retrieved.

        // [GIVEN] A configured Azure Key Vault
        MockAzureKeyvaultSecretProvider := MockAzureKeyvaultSecretProvider.MockAzureKeyVaultSecretProvider();
        MockAzureKeyvaultSecretProvider.AddSecretMapping(AllowedApplicationSecretsSecretNameTxt, 'somesecret');
        MockAzureKeyvaultSecretProvider.AddSecretMapping('somesecret', 'SecretFromKeyVault');
        AzureKeyVaultTestLibrary.SetAzureKeyVaultSecretProvider(MockAzureKeyvaultSecretProvider);

        // [WHEN] The key vault is called with a key
        AzureKeyVault.GetAzureKeyVaultSecret('somesecret', Secret);

        // [THEN] The right secret is retreived
        Assert.AreEqual('SecretFromKeyVault', Secret, 'The returned secret does not match.');

        // [WHEN] The key vault secrets are cleared and the same secret is retrieved
        AzureKeyVaultTestLibrary.ClearSecrets();

        // [THEN] The secret is no longer accessible and an error is thrown
        asserterror AzureKeyVault.GetAzureKeyVaultSecret('somesecret', Secret);
        Assert.ExpectedError(SecretNotInitializedTxt);
    end;
}