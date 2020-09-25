// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135214 "In Memory Secret Provider Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Secrets]
    end;

    var
        Assert: Codeunit "Library Assert";

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure HappyPath()
    var
        InMemorySecretProvider: Codeunit "In Memory Secret Provider";
        Secret: Text;
        Result: Boolean;
    begin
        // [SCENARIO] Populate the secret provider with some values and read them back

        // [GIVEN] A populated secret provider
        InMemorySecretProvider.AddSecret('secret1', 'value1');
        InMemorySecretProvider.AddSecret('secret2', 'value2');

        // [WHEN] The a secret is retrieved
        Result := InMemorySecretProvider.GetSecret('secret1', Secret);

        // [THEN] The value is retrieved
        Assert.AreEqual('value1', Secret, 'The returned secret does not match.');
        Assert.IsTrue(Result, 'GetSecret should return true if it could read the secret');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OverwriteAnExistingSecret()
    var
        InMemorySecretProvider: Codeunit "In Memory Secret Provider";
        Secret: Text;
        Result: Boolean;
    begin
        // [SCENARIO] Populate the secret provider with the same value twice -> show overwrite the value

        // [GIVEN] A populated secret provider
        InMemorySecretProvider.AddSecret('secret1', 'value1');

        // [WHEN] Overwriting a secret and reading it back
        InMemorySecretProvider.AddSecret('secret1', 'value2');
        Result := InMemorySecretProvider.GetSecret('secret1', Secret);

        // [THEN] The new value is retrieved
        Assert.AreEqual('value2', Secret, 'The returned secret does not match.');
        Assert.IsTrue(Result, 'GetSecret should return true if it could read the secret');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ReadNonExistingSecret()
    var
        InMemorySecretProvider: Codeunit "In Memory Secret Provider";
        Secret: Text;
        Result: Boolean;
    begin
        // [SCENARIO] Try to read a secret that doesn't exist

        // [GIVEN] A secret provider
        // [WHEN] Reading a non-existing secret
        Result := InMemorySecretProvider.GetSecret('secret1', Secret);

        // [THEN] The value should be empty, and the result should be false
        Assert.AreEqual('', Secret, 'The returned secret should be empty.');
        Assert.IsFalse(Result, 'GetSecret should return false if it couldn''t read the secret');
    end;
}