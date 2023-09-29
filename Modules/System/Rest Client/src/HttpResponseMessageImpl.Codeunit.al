// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.RestClient;

codeunit 2357 "Http Response Message Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    #region IsBlockedByEnvironment
    var
        IsBlockedByEnvironment: Boolean;

    procedure SetIsBlockedByEnvironment(Value: Boolean)
    begin
        IsBlockedByEnvironment := Value;
    end;

    procedure GetIsBlockedByEnvironment() ReturnValue: Boolean
    begin
        ReturnValue := IsBlockedByEnvironment;
    end;
    #endregion

    #region HttpStatusCode
    var
        HttpStatusCode: Integer;

    procedure SetHttpStatusCode(Value: Integer)
    begin
        HttpStatusCode := Value;
        IsSuccessStatusCode := Value in [200 .. 299];
    end;

    procedure GetHttpStatusCode() ReturnValue: Integer
    begin
        ReturnValue := HttpStatusCode
    end;
    #endregion

    #region IsSuccessStatusCode
    var
        IsSuccessStatusCode: Boolean;

    procedure GetIsSuccessStatusCode() Result: Boolean
    begin
        Result := HttpResponseMessage.IsSuccessStatusCode;
    end;

    procedure SetIsSuccessStatusCode(Value: Boolean)
    begin
        IsSuccessStatusCode := Value;
    end;
    #endregion

    #region ReasonPhrase
    var
        ReasonPhrase: Text;

    procedure SetReasonPhrase(Value: Text)
    begin
        ReasonPhrase := Value;
    end;

    procedure GetReasonPhrase() ReturnValue: Text
    begin
        ReturnValue := HttpResponseMessage.ReasonPhrase;
    end;
    #endregion

    #region HttpContent
    var
        HttpContent: Codeunit "Http Content";

    procedure SetContent(Content: Codeunit "Http Content")
    begin
        HttpContent := Content;
    end;

    procedure GetContent() ReturnValue: Codeunit "Http Content"
    begin
        ReturnValue := HttpContent;
    end;
    #endregion

    #region HttpResponseMessage
    var
        HttpResponseMessage: HttpResponseMessage;

    procedure SetResponseMessage(var ResponseMessage: HttpResponseMessage)
    begin
        HttpResponseMessage := ResponseMessage;
        SetIsBlockedByEnvironment(ResponseMessage.IsBlockedByEnvironment);
        SetHttpStatusCode(ResponseMessage.HttpStatusCode);
        SetReasonPhrase(ResponseMessage.ReasonPhrase);
        SetIsSuccessStatusCode(ResponseMessage.IsSuccessStatusCode);
        SetHeaders(ResponseMessage.Headers);
        SetContent(HttpContent.Create(ResponseMessage.Content));
    end;

    procedure GetResponseMessage() ReturnValue: HttpResponseMessage
    begin
        ReturnValue := HttpResponseMessage;
    end;
    #endregion

    #region HttpHeaders
    var
        HttpHeaders: HttpHeaders;

    procedure SetHeaders(Headers: HttpHeaders)
    begin
        HttpHeaders := Headers;
    end;

    procedure GetHeaders() ReturnValue: HttpHeaders
    begin
        ReturnValue := HttpHeaders;
    end;
    #endregion

    #region ErrorMessage
    var
        ErrorMessage: Text;

    procedure SetErrorMessage(Value: Text)
    begin
        ErrorMessage := Value;
    end;

    procedure GetErrorMessage() ReturnValue: Text
    begin
        if ErrorMessage <> '' then
            ReturnValue := ErrorMessage
        else
            ReturnValue := GetLastErrorText();
    end;
    #endregion
}