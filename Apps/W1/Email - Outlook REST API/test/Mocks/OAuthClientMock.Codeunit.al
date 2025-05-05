// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139753 "OAuth Client Mock" implements "Email - OAuth Client v2"
{
    SingleInstance = true;


    internal procedure GetAccessToken(var AccessToken: SecretText)
    begin
        TryGetAccessToken(AccessToken);
    end;

    internal procedure TryGetAccessToken(var AccessToken: SecretText): Boolean
    var
        Token: Text;
    begin
        Token := 'test token';
        AccessToken := Token;
        exit(true);
    end;
}