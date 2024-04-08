// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#if not CLEAN24
#pragma warning disable AL0432
codeunit 139753 "OAuth Client Mock" implements "Email - OAuth Client", "Email - OAuth Client v2"
#pragma warning restore AL0432
#else
codeunit 139753 "OAuth Client Mock" implements "Email - OAuth Client v2"
#endif
{
    SingleInstance = true;
#if not CLEAN24
    ObsoleteReason = 'Email - OAuth Client interface is obsolete and being removed.';
    ObsoleteState = Pending;
    ObsoleteTag = '24.0';
#endif

#if not CLEAN24
    [Obsolete('Replaced by GetAccessToken with SecretText data type for AccessToken parameter.', '24.0')]
    internal procedure GetAccessToken(var AccessToken: Text)
    begin
        TryGetAccessToken(AccessToken);
    end;

    [Obsolete('Replaced by TryGetAccessToken with SecretText data type for AccessToken parameter.', '24.0')]
    internal procedure TryGetAccessToken(var AccessToken: Text): Boolean
    begin
        AccessToken := 'test token';
        exit(true);
    end;
#endif

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