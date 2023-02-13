// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 5681 "WebDAV Basic Auth. Impl." implements "WebDAV Authorization"
{
    Access = Internal;

    var
        [NonDebuggable]
        AuthorizationString: Text;

    [NonDebuggable]
    procedure Authorize(var HttpRequestMessage: HttpRequestMessage);
    var
        Headers: HttpHeaders;
    begin
        HttpRequestMessage.GetHeaders(Headers);
        Headers.Remove('Authorization');
        Headers.Add('Authorization', AuthorizationString);

        Headers.Remove('Translate');
        Headers.Add('Translate', 'F');
    end;


    [NonDebuggable]
    procedure SetUserNameAndPassword(Username: Text; Password: Text)
    var
        Base64Convert: Codeunit "Base64 Convert";
    begin
        AuthorizationString := 'Basic ' + Base64Convert.ToBase64(Username + ':' + Password);
    end;
}