// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Security.Encryption;
using System.Telemetry;
using System.Text;
using System.Utilities;

codeunit 10046 "OAuth Client IRIS"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "User Params IRIS" = M;

    var
        KeyVaultClient: Codeunit "Key Vault Client IRIS";
        Helper: Codeunit "Helper IRIS";
        Base64Convert: Codeunit "Base64 Convert";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        JWTSignAlgorithmTxt: Label 'RS256', Locked = true;
        GetTokensEventTxt: Label 'GetTokens', Locked = true;
        SubmitTransmEventTxt: Label 'SubmitTransmission', Locked = true;
        RequestTransmStatusOrAckEventTxt: Label 'RequestTransmissionStatusOrAck', Locked = true;
        GrantTypeTxt: Label 'urn:ietf:params:oauth:grant-type:jwt-bearer', Locked = true;
        ClientAssertionTypeTxt: Label 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer', Locked = true;
        UrlEncodedContentTypeTxt: Label 'application/x-www-form-urlencoded', Locked = true;
        MultipartContentTypeTxt: Label 'multipart/form-data; boundary=%1', Comment = '%1 - string that separates multipart sections in request body', Locked = true;
        JWTAccessTokenRequestBodyTxt: Label 'grant_type=%1&assertion=%2&client_assertion_type=%3&client_assertion=%4', Locked = true;
        RefreshAccessTokenReqBodyTxt: Label 'grant_type=refresh_token&refresh_token=%1&client_assertion_type=%2&client_assertion=%3', Locked = true;
        BearerTxt: Label 'Bearer %1', Comment = '%1 - access token', Locked = true;
        ApplicationXmlTxt: Label 'application/xml', Locked = true;
        HttpRequestSendErr: Label 'Error sending HTTP request.';
        HttpResponseErr: Label 'The IRIS service returned the error response.';
        HttpResponseDetailsErr: Label '\\Status: %1 %2 \Response: %3', Comment = '%1 - HTTP status code, %2 - reason phrase, %3 - response text';
        GetAccessTokenErr: Label 'Could not get access token from response.';
        AccessTokenExpiredErr: Label 'Access token is expired.', Locked = true;
        UserIDMustBeSetErr: Label 'IRIS User ID must be specified. %1', Comment = '%1 - additional instructions';
        GetClientIDErr: Label 'Could not get IRIS Client ID from Azure Key Vault. Try operation again later. If the issue persists, open a Business Central support request.';
        EmptyRequestErr: Label 'The xml request for getting transmission status is empty.';
        EmptyResponseErr: Label 'IRIS API server returned empty response.';
        EmptyTransmissionErr: Label 'Transmission content is empty.', Locked = true;
        EmptyTransmContentUserErr: Label 'The transmission content is empty. Make sure that the transmission contains IRS 1099 form documents to report.';
        UserIDGetInstructionsMsg: Label 'Use the action Setup IRIS User ID on the IRS Forms Setup page to see instructions for getting your IRIS User ID.';
        CustomDimKeyValueTxt: Label '%1: %2\', Locked = true;

    [NonDebuggable]
    procedure GetToken(TokenKey: Guid) TokenValue: SecretText
    begin
        if IsolatedStorage.Get(TokenKey, DataScope::User, TokenValue) then;
    end;

    [NonDebuggable]
    procedure SetToken(var TokenKey: Guid; TokenValue: SecretText)
    begin
        if TokenValue.IsEmpty() then begin
            if IsolatedStorage.Delete(TokenKey, DataScope::User) then;
            Clear(TokenKey);
            exit;
        end;

        if IsNullGuid(TokenKey) then
            TokenKey := CreateGuid();

        if IsolatedStorage.Set(TokenKey, TokenValue, DataScope::User) then;
    end;

    procedure TokenExists(TokenKey: Guid): Boolean
    begin
        exit(not IsNullGuid(TokenKey) and IsolatedStorage.Contains(TokenKey, DataScope::User));
    end;

    local procedure GetEpochTime(InputDateTime: DateTime): Integer
    var
        UnixEpoch: DateTime;
        Duration: Duration;
    begin
        UnixEpoch := CreateDateTime(DMY2Date(1, 1, 1970), 0T);
        Duration := InputDateTime - UnixEpoch;
        exit(Duration div 1000);    // convert milliseconds to seconds
    end;

    local procedure CreateJWTHeader(KeyID: Text; SignAlgorithm: Text) Base64Header: Text
    var
        JWTHeader: JsonObject;
        JWTHeaderText: Text;
    begin
        JWTHeader.Add('kid', KeyID);
        JWTHeader.Add('alg', SignAlgorithm);
        JWTHeader.WriteTo(JWTHeaderText);
        Base64Header := Base64Convert.ToBase64Url(JWTHeaderText);
    end;

    local procedure CreateJWTPayload(Issuer: Text; Subject: Text; Audience: Text; IssuedAtTime: DateTime; ExpirationTime: DateTime; JWTID: Text) Base64Payload: Text
    var
        JWTPayload: JsonObject;
        JWTPayloadText: Text;
    begin
        JWTPayload.Add('iss', Issuer);
        JWTPayload.Add('sub', Subject);
        JWTPayload.Add('aud', Audience);
        JWTPayload.Add('iat', GetEpochTime(IssuedAtTime));
        JWTPayload.Add('exp', GetEpochTime(ExpirationTime));
        JWTPayload.Add('jti', JWTID);
        JWTPayload.WriteTo(JWTPayloadText);
        Base64Payload := Base64Convert.ToBase64Url(JWTPayloadText);
    end;

    [NonDebuggable]
    local procedure CreateSignature(Base64Header: Text; Base64Payload: Text) Signature: Text
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        SignatureKey: Codeunit "Signature Key";
        TempBlob: Codeunit "Temp Blob";
        StringToSign: Text;
        Certificate: SecretText;
        DummyPassword: SecretText;
        BlobOutStream: OutStream;
        BlobInStream: InStream;
    begin
        StringToSign := StrSubstNo('%1.%2', Base64Header, Base64Payload);
        Certificate := KeyVaultClient.GetCertificate();
        TempBlob.CreateOutStream(BlobOutStream, TextEncoding::UTF8);
        SignatureKey.FromBase64String(Certificate.Unwrap(), DummyPassword, true);
        CryptographyManagement.SignData(StringToSign, SignatureKey.ToXmlString(), Enum::"Hash Algorithm"::SHA256, Enum::"RSA Signature Padding"::Pkcs1, BlobOutStream);
        TempBlob.CreateInStream(BlobInStream);
        Signature := Base64Convert.ToBase64Url(BlobInStream);
    end;

    [NonDebuggable]
    local procedure CreateJWT(Subject: Text): Text
    var
        Base64Header: Text;
        Base64Payload: Text;
        Signature: Text;
        KeyID: Text;
        Issuer: Text;
        Audience: Text;
        IssuedAtTime: DateTime;
        ExpirationTime: DateTime;
        JWTID: Text;
    begin
        KeyID := KeyVaultClient.GetJSONWebKeyID();
        Base64Header := CreateJWTHeader(KeyID, JWTSignAlgorithmTxt);

        Issuer := KeyVaultClient.GetAPIClientIDFromKV();
        Audience := KeyVaultClient.GetAuthURL();
        IssuedAtTime := CurrentDateTime();
        ExpirationTime := IssuedAtTime + 15 * 60 * 1000; // 15 minutes
        JWTID := StrSubstNo('%1 %2', Helper.CreateUUID(), Format(CurrentDateTime(), 0, 9));
        Base64Payload := CreateJWTPayload(Issuer, Subject, Audience, IssuedAtTime, ExpirationTime, JWTID);

        Signature := CreateSignature(Base64Header, Base64Payload);
        exit(StrSubstNo('%1.%2.%3', Base64Header, Base64Payload, Signature));
    end;

    [NonDebuggable]
    procedure RequestTokens(var AccessToken: SecretText; var RefreshToken: SecretText; var AccessTokenExpiresIn: Integer)
    var
        UserParamsIRIS: Record "User Params IRIS";
        HttpResponseMessage: HttpResponseMessage;
        ClientID: Text;
        UserID: SecretText;
        ClientJWT: Text;
        UserJWT: Text;
        RequestBody: Text;
        ResponseText: SecretText;
    begin
        FeatureTelemetry.LogUsage('0000P81', Helper.GetIRISFeatureName(), GetTokensEventTxt);

        UserParamsIRIS.GetRecord();
        UserID := GetToken(UserParamsIRIS."IRIS User ID Key");
        if UserID.IsEmpty() then begin
            FeatureTelemetry.LogError('0000PAG', Helper.GetIRISFeatureName(), '', UserIDMustBeSetErr, GetLastErrorCallStack());
            Error(UserIDMustBeSetErr, UserIDGetInstructionsMsg);
        end;
        UserJWT := CreateJWT(UserID.Unwrap());

        ClientID := KeyVaultClient.GetAPIClientIDFromKV();
        if ClientID = '' then
            Error(GetClientIDErr);
        ClientJWT := CreateJWT(ClientID);

        RequestBody := StrSubstNo(JWTAccessTokenRequestBodyTxt, GrantTypeTxt, UserJWT, ClientAssertionTypeTxt, ClientJWT);

        if not SendPOSTHttpRequestUrlEncoded(RequestBody, KeyVaultClient.GetAuthURL(), HttpResponseMessage) then
            ShowRequestSendError(HttpResponseMessage.IsBlockedByEnvironment());
        HttpResponseMessage.Content().ReadAs(ResponseText);

        if not HttpResponseMessage.IsSuccessStatusCode() then
            ShowResponseError(HttpResponseMessage.HttpStatusCode(), HttpResponseMessage.ReasonPhrase(), ResponseText.Unwrap());

        if not GetTokensFromResponse(ResponseText, AccessToken, RefreshToken, AccessTokenExpiresIn) then
            ShowGetAccessTokenError(AccessToken.IsEmpty(), RefreshToken.IsEmpty(), AccessTokenExpiresIn = 0);
    end;

    [NonDebuggable]
    local procedure GetTokensFromResponse(ResponseJson: SecretText; var AccessToken: SecretText; var RefreshToken: SecretText; var ExpireInSec: Integer): Boolean
    var
        JToken: JsonToken;
        NewAccessToken: Text;
        NewRefreshToken: Text;
    begin
        NewAccessToken := '';
        NewRefreshToken := '';

        AccessToken := NewAccessToken;
        RefreshToken := NewRefreshToken;

        ExpireInSec := 0;

        if JToken.ReadFrom(ResponseJson.Unwrap()) then
            foreach JToken in JToken.AsObject().Values() do
                case JToken.Path() of
                    'access_token':
                        NewAccessToken := JToken.AsValue().AsText();
                    'refresh_token':
                        NewRefreshToken := JToken.AsValue().AsText();
                    'expires_in':
                        ExpireInSec := JToken.AsValue().AsInteger();
                end;
        if (NewAccessToken = '') or (NewRefreshToken = '') then
            exit(false);

        AccessToken := NewAccessToken;
        RefreshToken := NewRefreshToken;
        exit(true);
    end;

    [NonDebuggable]
    local procedure SaveTokens(AccessToken: SecretText; RefreshToken: SecretText; AccessTokenExpiresIn: Integer)
    var
        UserParamsIRIS: Record "User Params IRIS";
    begin
        UserParamsIRIS.GetRecord();
        if AccessTokenExpiresIn = 0 then
            AccessTokenExpiresIn := 15 * 60 * 1000;     // 15 minutes

        if not AccessToken.IsEmpty() then begin
            SetToken(UserParamsIRIS."Access Token Key", AccessToken);
            UserParamsIRIS."Access Token Expires At" := CurrentDateTime() + AccessTokenExpiresIn * 1000;
        end;

        if not RefreshToken.IsEmpty() then begin
            SetToken(UserParamsIRIS."Refresh Token Key", RefreshToken);
            UserParamsIRIS."Refresh Token Expires At" := CurrentDateTime() + 60 * 60 * 1000;       // 1 hour
        end;

        UserParamsIRIS.Modify();
    end;

    procedure ClearTokens()
    var
        UserParamsIRIS: Record "User Params IRIS";
        EmptyTokenValue: Text;
    begin
        UserParamsIRIS.GetRecord();
        EmptyTokenValue := '';
        SetToken(UserParamsIRIS."Access Token Key", EmptyTokenValue);
        SetToken(UserParamsIRIS."Refresh Token Key", EmptyTokenValue);
        UserParamsIRIS."Access Token Expires At" := 0DT;
        UserParamsIRIS."Refresh Token Expires At" := 0DT;
        UserParamsIRIS.Modify();
    end;

    local procedure GetAccessToken() AccessToken: SecretText
    var
        UserParamsIRIS: Record "User Params IRIS";
        NewRefreshToken: SecretText;
        CurrRefreshToken: SecretText;
        AccessTokenExpiresIn: Integer;
        AccessTokenOffsetTime: Duration;
        AccessTokenExpiresAt: DateTime;
    begin
        UserParamsIRIS.GetRecord();

        // in practice access token expires approximately on 9th minute, i.e. 5-6 minutes before the expected expiration time
        AccessTokenOffsetTime := 7 * 60 * 1000;
        AccessTokenExpiresAt := UserParamsIRIS."Access Token Expires At";
        if AccessTokenExpiresAt <> 0DT then
            AccessTokenExpiresAt -= AccessTokenOffsetTime;

        // return existing access token if not expired
        if CurrentDateTime() < AccessTokenExpiresAt then
            if IsAccessTokenValid() then
                exit(GetToken(UserParamsIRIS."Access Token Key"));

        // try refresh access token
        if CurrentDateTime() < UserParamsIRIS."Refresh Token Expires At" then begin
            CurrRefreshToken := GetToken(UserParamsIRIS."Refresh Token Key");
            if not CurrRefreshToken.IsEmpty() then begin
                RefreshAccessToken(CurrRefreshToken, AccessToken, NewRefreshToken, AccessTokenExpiresIn);
                if not AccessToken.IsEmpty() then begin
                    SaveTokens(AccessToken, NewRefreshToken, AccessTokenExpiresIn);
                    exit(AccessToken);
                end;
            end;
        end;

        // get new tokens if couldn't refresh access token
        RequestTokens(AccessToken, NewRefreshToken, AccessTokenExpiresIn);
        SaveTokens(AccessToken, NewRefreshToken, AccessTokenExpiresIn);
    end;

    local procedure IsAccessTokenValid(): Boolean
    var
        UserParamsIRIS: Record "User Params IRIS";
        IRSFormsFacade: Codeunit "IRS Forms Facade";
        GetStatusRequestContentBlob: Codeunit "Temp Blob";
        HttpResponseMessage: HttpResponseMessage;
        ReceiptID: Text;
        RequestXml: Text;
        HttpStatusCode: Integer;
    begin
        ReceiptID := '0';        // use non-existing ReceiptID to create dummy status request to validate access token
        IRSFormsFacade.CreateGetStatusRequestXmlContent(Enum::"Search Param Type IRIS"::RID, ReceiptID, GetStatusRequestContentBlob);

        // use current access token to send dummy status request
        UserParamsIRIS.GetRecord();
        RequestXml := Helper.WriteTempBlobToText(GetStatusRequestContentBlob);
        if SendPOSTHttpRequestXml(RequestXml, KeyVaultClient.GetStatusEndpointURL(), GetToken(UserParamsIRIS."Access Token Key"), HttpResponseMessage) then;
        HttpStatusCode := HttpResponseMessage.HttpStatusCode();

        // check if 401 Unauthorized was returned
        if HttpStatusCode = 401 then begin
            FeatureTelemetry.LogError('0000PSH', Helper.GetIRISFeatureName(), GetTokensEventTxt, AccessTokenExpiredErr, GetLastErrorCallStack());
            exit(false);
        end;

        exit(true);
    end;

    [NonDebuggable]
    local procedure RefreshAccessToken(RefreshToken: SecretText; var NewAccessToken: SecretText; var NewRefreshToken: SecretText; var NewAccessTokenExpiresIn: Integer)
    var
        HttpResponseMessage: HttpResponseMessage;
        JObject: JsonObject;
        RequestBody: Text;
        ResponseText: Text;
        ResponseSecretText: SecretText;
        ClientID: Text;
        ClientJWT: Text;
    begin
        ClientID := KeyVaultClient.GetAPIClientIDFromKV();
        if ClientID = '' then
            Error(GetClientIDErr);
        ClientJWT := CreateJWT(ClientID);
        RequestBody := StrSubstNo(RefreshAccessTokenReqBodyTxt, RefreshToken.Unwrap(), ClientAssertionTypeTxt, ClientJWT);

        if not SendPOSTHttpRequestUrlEncoded(RequestBody, KeyVaultClient.GetAuthURL(), HttpResponseMessage) then
            ShowRequestSendError(HttpResponseMessage.IsBlockedByEnvironment());
        if not HttpResponseMessage.IsSuccessStatusCode() then
            exit;       // no need to show error here as both access and refresh tokens will be requested again

        HttpResponseMessage.Content().ReadAs(ResponseText);
        JObject.ReadFrom(ResponseText);
        ResponseSecretText := ResponseText;
        GetTokensFromResponse(ResponseSecretText, NewAccessToken, NewRefreshToken, NewAccessTokenExpiresIn);
    end;

    procedure SubmitTransmission(TransmissionContentBlob: Codeunit "Temp Blob"; ResponseContentBlob: Codeunit "Temp Blob"; var HttpStatusCode: Integer)
    var
        HttpResponseMessage: HttpResponseMessage;
        MultipartContent: Text;
        Boundary: Text;
        Payload: Text;
        ResponseText: Text;
    begin
        Boundary := Format(Helper.CreateUUID());
        Payload := Helper.WriteTempBlobToText(TransmissionContentBlob);
        if Payload = '' then begin
            FeatureTelemetry.LogError('0000PSI', Helper.GetIRISFeatureName(), SubmitTransmEventTxt, EmptyTransmissionErr, GetLastErrorCallStack());
            Message(EmptyTransmContentUserErr);
            exit;
        end;
        MultipartContent := PrepareMultipartContent(Payload, Boundary);

        if not SendPOSTHttpRequestMultipart(MultipartContent, KeyVaultClient.GetSubmitEndpointURL(), Boundary, HttpResponseMessage) then begin
            ShowRequestSendError(HttpResponseMessage.IsBlockedByEnvironment());
            exit;
        end;

        HttpStatusCode := HttpResponseMessage.HttpStatusCode();
        HttpResponseMessage.Content().ReadAs(ResponseText);

        if not HttpResponseMessage.IsSuccessStatusCode() then
            ShowResponseError(HttpResponseMessage.HttpStatusCode(), HttpResponseMessage.ReasonPhrase(), ResponseText);

        if ResponseText = '' then begin
            FeatureTelemetry.LogError('0000PAH', Helper.GetIRISFeatureName(), SubmitTransmEventTxt, EmptyResponseErr, GetLastErrorCallStack());
            Message(EmptyResponseErr);
        end;
        Helper.WriteTextToTempBlob(ResponseContentBlob, ResponseText);

        FeatureTelemetry.LogUsage('0000PAJ', Helper.GetIRISFeatureName(), SubmitTransmEventTxt);
    end;

    procedure RequestTransmStatusOrAcknowledgement(StatusRequestBlob: Codeunit "Temp Blob"; var ResponseBlob: Codeunit "Temp Blob"; var HttpStatusCode: Integer)
    var
        HttpResponseMessage: HttpResponseMessage;
        RequestXml: Text;
        ResponseText: Text;
    begin
        RequestXml := Helper.WriteTempBlobToText(StatusRequestBlob);
        if RequestXml = '' then begin
            FeatureTelemetry.LogError('0000PSJ', Helper.GetIRISFeatureName(), RequestTransmStatusOrAckEventTxt, EmptyRequestErr, GetLastErrorCallStack());
            Message(EmptyRequestErr);
            exit;
        end;

        if not SendPOSTHttpRequestXml(RequestXml, KeyVaultClient.GetStatusEndpointURL(), GetAccessToken(), HttpResponseMessage) then begin
            ShowRequestSendError(HttpResponseMessage.IsBlockedByEnvironment());
            exit;
        end;

        HttpStatusCode := HttpResponseMessage.HttpStatusCode();
        HttpResponseMessage.Content().ReadAs(ResponseText);

        if not HttpResponseMessage.IsSuccessStatusCode() then
            ShowResponseError(HttpResponseMessage.HttpStatusCode(), HttpResponseMessage.ReasonPhrase(), ResponseText);

        if ResponseText = '' then begin
            FeatureTelemetry.LogError('0000PAI', Helper.GetIRISFeatureName(), RequestTransmStatusOrAckEventTxt, EmptyResponseErr, GetLastErrorCallStack());
            Message(EmptyResponseErr);
        end;
        Helper.WriteTextToTempBlob(ResponseBlob, ResponseText);

        FeatureTelemetry.LogUsage('0000PAK', Helper.GetIRISFeatureName(), RequestTransmStatusOrAckEventTxt);
    end;

    local procedure PrepareMultipartContent(Payload: Text; Boundary: Text): Text
    var
        MultiPartContent: TextBuilder;
    begin
        MultiPartContent.AppendLine('--' + Boundary);

        // payload
        MultiPartContent.AppendLine('Content-Disposition: form-data; name="file"; filename="transmission.xml"');
        MultiPartContent.AppendLine('Content-Type: text/xml');
        MultiPartContent.AppendLine('');
        MultiPartContent.AppendLine(Payload);

        // close boundary
        MultiPartContent.AppendLine('--' + Boundary + '--');
        exit(MultiPartContent.ToText());
    end;

    [NonDebuggable]
    local procedure SendPOSTHttpRequestUrlEncoded(RequestBody: SecretText; RequestUri: Text; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpContent: HttpContent;
        ContentHeaders: HttpHeaders;
    begin
        HttpRequestMessage.Method('POST');
        HttpRequestMessage.SetRequestUri(RequestUri);
        HttpContent.WriteFrom(RequestBody);

        HttpContent.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', UrlEncodedContentTypeTxt);
        HttpRequestMessage.Content(HttpContent);

        exit(HttpClient.Send(HttpRequestMessage, HttpResponseMessage));
    end;

    [NonDebuggable]
    local procedure SendPOSTHttpRequestMultipart(RequestBody: Text; RequestUri: Text; Boundary: Text; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
    begin
        HttpRequestMessage.Method('POST');
        HttpRequestMessage.SetRequestUri(RequestUri);
        HttpContent.WriteFrom(RequestBody);

        HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Authorization', SecretStrSubstNo(BearerTxt, GetAccessToken()));
        HttpHeaders.Add('Accept', ApplicationXmlTxt);

        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.Remove('Content-Type');
        HttpHeaders.Add('Content-Type', StrSubstNo(MultipartContentTypeTxt, Boundary));
        HttpRequestMessage.Content(HttpContent);

        exit(HttpClient.Send(HttpRequestMessage, HttpResponseMessage));
    end;

    [NonDebuggable]
    local procedure SendPOSTHttpRequestXml(RequestBody: Text; RequestUri: Text; AccessToken: SecretText; var HttpResponseMessage: HttpResponseMessage): Boolean
    var
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
    begin
        HttpRequestMessage.Method('POST');
        HttpRequestMessage.SetRequestUri(RequestUri);
        HttpContent.WriteFrom(RequestBody);

        HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Add('Authorization', StrSubstNo(BearerTxt, AccessToken.Unwrap()));
        HttpHeaders.Add('Accept', ApplicationXmlTxt);

        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.Remove('Content-Type');
        HttpHeaders.Add('Content-Type', ApplicationXmlTxt);
        HttpRequestMessage.Content(HttpContent);

        exit(HttpClient.Send(HttpRequestMessage, HttpResponseMessage));
    end;

    local procedure ShowRequestSendError(IsBlockedByEnvironment: Boolean)
    var
        CustomDimensions: Dictionary of [Text, Text];
        ErrorMessage: Text;
    begin
        CustomDimensions.Add('IsBlockedByEnvironment', Format(IsBlockedByEnvironment));
        FeatureTelemetry.LogError('0000P7X', Helper.GetIRISFeatureName(), '', HttpRequestSendErr, GetLastErrorCallStack(), CustomDimensions);
        ErrorMessage := AddErrorDetails(HttpRequestSendErr, CustomDimensions);
        Message(ErrorMessage);
    end;

    local procedure ShowResponseError(HttpStatusCode: Integer; ReasonPhrase: Text; ResponseText: Text)
    var
        CustomDimensions: Dictionary of [Text, Text];
        ErrorMessage: Text;
    begin
        CustomDimensions.Add('HttpStatusCode', Format(HttpStatusCode));
        CustomDimensions.Add('ReasonPhrase', ReasonPhrase);
        FeatureTelemetry.LogError('0000P7Y', Helper.GetIRISFeatureName(), '', HttpResponseErr, GetLastErrorCallStack(), CustomDimensions);
        ErrorMessage := HttpResponseErr + StrSubstNo(HttpResponseDetailsErr, HttpStatusCode, ReasonPhrase, ResponseText);
        Message(ErrorMessage);
    end;

    local procedure ShowGetAccessTokenError(AccessTokenIsEmpty: Boolean; RefreshTokenIsEmpty: Boolean; AccessTokenExpiresInZero: Boolean)
    var
        CustomDimensions: Dictionary of [Text, Text];
    begin
        CustomDimensions.Add('AccessTokenEmpty', Format(AccessTokenIsEmpty));
        CustomDimensions.Add('RefreshTokenEmpty', Format(RefreshTokenIsEmpty));
        CustomDimensions.Add('ExpiresInZero', Format(AccessTokenExpiresInZero));
        FeatureTelemetry.LogError('0000P7Z', Helper.GetIRISFeatureName(), '', HttpResponseErr, GetLastErrorCallStack(), CustomDimensions);
        if AccessTokenIsEmpty then
            Error(GetAccessTokenErr);
    end;

    local procedure AddErrorDetails(BaseErrorText: Text; CustomDimensions: Dictionary of [Text, Text]) FullErrorText: Text
    var
        CustomDimKey: Text;
    begin
        FullErrorText := BaseErrorText + '\';
        foreach CustomDimKey in CustomDimensions.Keys() do
            FullErrorText += StrSubstNo(CustomDimKeyValueTxt, CustomDimKey, CustomDimensions.Get(CustomDimKey));
    end;
}