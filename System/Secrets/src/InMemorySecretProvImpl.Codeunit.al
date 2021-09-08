// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// An in-memory secret provider that can be populated with secrets from any source.
/// </summary>
codeunit 3803 "In Memory Secret Prov Impl."
{
    Access = Internal;

    var
        [NonDebuggable]
        dict: Dictionary of [Text, Text];

    [NonDebuggable]
    procedure AddSecret(SecretName: Text; SecretValue: Text)
    begin
        if dict.ContainsKey(SecretName) then
            dict.Remove(SecretName);

        dict.Add(SecretName, SecretValue);
    end;

    [NonDebuggable]
    procedure GetSecret(SecretName: Text; var SecretValue: Text): Boolean
    begin
        if dict.ContainsKey(SecretName) then begin
            dict.Get(SecretName, SecretValue);
            exit(true);
        end;

        exit(false);
    end;
}
