// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135213 "App Key Vault Secret Pro. Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";

    trigger OnRun()
    begin
        // [FEATURE] [Secrets]
    end;

    [Test]
    procedure InitializingWithoutSpecifyingKeyVaultGivesError()
    var
        AppKeyVaultSecretProvider: Codeunit "App Key Vault Secret Provider";
    begin
        // [SCENARIO] An app (in this case the system test app) without a key vault specified. Trying to initialize secrets should give error.

        if AppKeyVaultSecretProvider.TryInitializeFromCurrentApp() then
            Assert.Fail('Expected initialization of App Key Vault Secret Provider to fail because this app has no key vaults specified, but it did not fail.')
        else
            Assert.ExpectedError('Couldn''t initialize the App Key Vault Secret Provider');
    end;

    [Test]
    procedure GetSecretbeforeInitializedGivesError()
    var
        AppKeyVaultSecretProvider: Codeunit "App Key Vault Secret Provider";
        SecretValue: Text;
    begin
        // [SCENARIO] Calling GetSecret before calling TryInitializeFromCurrentApp should give error.

        asserterror AppKeyVaultSecretProvider.GetSecret('foo', SecretValue);
        Assert.ExpectedError('Cannot get secrets because the App Key Vault Secret Provider has not been initialized.');
    end;
}