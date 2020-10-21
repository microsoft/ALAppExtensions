// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139753 "OAuth Client Mock" implements "Email - OAuth Client"
{
    SingleInstance = true;

    internal procedure GetAccessToken(var AccessToken: Text)
    begin
        TryGetAccessToken(AccessToken);
    end;

    internal procedure TryGetAccessToken(var AccessToken: Text): Boolean
    begin
        AccessToken := 'test token';
        exit(true);
    end;
}