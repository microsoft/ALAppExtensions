// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135143 "Mock HttpResponseMessage" implements IHttpResponseMessage
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        _blockedByEnvironment: Boolean;
        _httpContentHeaders: HttpHeaders;
        _statusCode: Integer;
        _reasonPhrase: Text;
        _responseBody: Text;

    procedure InitializeError(NewStatusCode: Integer; NewReasonPhrase: Text)
    begin
        _statusCode := NewStatusCode;
        _reasonPhrase := NewReasonPhrase;
    end;

    procedure InitializeSuccess(StatusCode: Integer; ResponseBodyText: Text)
    var
    begin
        _statusCode := StatusCode;
        _responseBody := ResponseBodyText;
    end;

    procedure InitializeBlockedByEnvironment()
    begin
        _blockedByEnvironment := true;
    end;

    procedure IsBlockedByEnvironment(): Boolean;
    begin
        exit(_blockedByEnvironment);
    end;

    procedure IsSuccessStatusCode(): Boolean;
    begin
        exit((_statusCode >= 200) and (_statusCode < 300));
    end;

    procedure HttpStatusCode(): Integer;
    begin
        exit(_statusCode);
    end;

    procedure ReasonPhrase(): Text;
    begin
        exit(_reasonPhrase);
    end;

    procedure Content(): HttpContent;
    var
        HttpContent: HttpContent;
        ContentHttpHeaders: HttpHeaders;
    begin
        HttpContent.GetHeaders(ContentHttpHeaders);
        ContentHttpHeaders := _httpContentHeaders;
        HttpContent.WriteFrom(_responseBody);
        exit(HttpContent);
    end;

    procedure Headers(): HttpHeaders;
    begin
        exit(_httpContentHeaders);
    end;
}