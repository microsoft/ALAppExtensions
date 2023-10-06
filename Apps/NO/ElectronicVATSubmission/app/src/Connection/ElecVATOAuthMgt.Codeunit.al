// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Foundation.Company;
using Microsoft.Utilities;
using System.Reflection;
using System.Security.Authentication;
using System.Utilities;

codeunit 10680 "Elec. VAT OAuth Mgt."
{
    trigger OnRun()
    begin
    end;

    var
        ElecVATSetup: Record "Elec. VAT Setup";
        OAuth20Mgt: Codeunit "OAuth 2.0 Mgt.";
        ElecVATCodeLbl: Label 'ELECVAT-1';
        ServiceConnectionSetupLbl: Label 'Elec. VAT Return Submission Setup';
        OAuthSetupDescriptionLbl: Label 'Electronic VAT Submission', Locked = true;
        ScopeTxt: Label 'openid skatteetaten:mvameldingvalidering skatteetaten:mvameldinginnsending', Locked = true;
        AuthorizationURLPathTxt: Label '/authorize', Locked = true;
        AccessTokenURLPathTxt: Label '/token', Locked = true;
        RefreshTokenURLPathTxt: Label '/token', Locked = true;
        AuthorizationResponseTypeTxt: Label 'code', Locked = true;
        CurrUrlWithStateTxt: Label '%1&state=%2', Comment = '%1 = base url, %2 = guid', Locked = true;
        OAuthNotConfiguredErr: Label 'OAuth setup is not enabled for Electronic VAT submissiob feature.';
        OpenSetupMsg: Label 'Open service connections to setup.';
        OpenSetupQst: Label 'Do you want to open the setup?';
        CombinedStatementMsg: Label '%1\%2', Comment = '%1 = first statement; %2 = second statement';
        NoHttpStatusErr: Label 'No http status from the https response', Locked = true;
        NoJsonResponseErr: Label 'Could not parse http response as json object', Locked = true;
        NoContentMessageErr: Label 'No content.message in the json response', Locked = true;
        EmptyJsonErrMsgErr: Label 'Missing error description in json response', Locked = true;
        NoContentStatusCodeErr: Label 'No Content.statusCode in json response', Locked = true;
        EmptyStatusReasonErr: Label 'Empty status reason in json response', Locked = true;
        CannotParseResponseErr: Label 'Cannot parse the http error response', Locked = true;
        HttpErrorTextWithDetailsTxt: Label 'HTTP error %1 (%2). %3', Comment = '%1 = StatusCode, %2 = StatusReason, %3 = HttpError';
        NOVATReturnSubmissionTok: Label 'NOVATReturnSubmissionTelemetryCategoryTok', Locked = true;
        CheckCompanyVATNoAfterSuccessAuthorizationQst: Label 'Authorization successful.\Do you want to open the Company Information page to verify the VAT registration number?';

    procedure OpenOAuthSetupPage()
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
    begin
        InitOAuthSetup(OAuth20Setup);
        Commit();
        Page.RunModal(Page::"OAuth 2.0 Setup", OAuth20Setup);
    end;

    procedure InitOAuthSetup(var OAuth20Setup: Record "OAuth 2.0 Setup")
    var
        NewCode: Code[20];
    begin
        ElecVATSetup.GetRecordOnce();
        ElecVATSetup.TestField("OAuth Feature GUID");
        ElecVATSetup.TestField("Redirect URL");
        with OAuth20Setup do begin
            if not OAuth20Setup.FindFirstOAuth20SetupByFeatureAndCurrUser(ElecVATSetup."OAuth Feature GUID") then begin
                SetRange("User ID");
                if FindLast() then
                    NewCode := IncStr(Code)
                else
                    NewCode := ElecVATCodeLbl;
                Code := NewCode;
                Status := Status::Disabled;
                while not Insert() do
                    Code := IncStr(Code);
            end;
            "Service URL" := ElecVATSetup."Authentication URL";
            Description := CopyStr(OAuthSetupDescriptionLbl, 1, MaxStrLen(Description));
            "Redirect URL" := ElecVATSetup."Redirect URL";
            "Client ID" := ElecVATSetup."Client ID";
            "Client Secret" := ElecVATSetup."Client Secret";
            Scope := ScopeTxt;
            "Authorization URL Path" := AuthorizationURLPathTxt;
            "Access Token URL Path" := AccessTokenURLPathTxt;
            "Refresh Token URL Path" := RefreshTokenURLPathTxt;
            "Authorization Response Type" := AuthorizationResponseTypeTxt;
            "Token DataScope" := "Token DataScope"::UserAndCompany;
            "Daily Limit" := 1000;
            "Feature GUID" := ElecVATSetup."OAuth Feature GUID";
            "User ID" := CopyStr(UserId(), 1, MaxStrLen("User ID"));
            Modify();
        end;
    end;

    procedure CheckOAuthConfigured(OpenSetup: Boolean)
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        ConfirmManagement: Codeunit "Confirm Management";
        ErrorText: Text;
    begin
        if IsOAuthConfigured() then
            exit;

        if not OpenSetup then begin
            ErrorText := StrSubstNo(CombinedStatementMsg, OAuthNotConfiguredErr, OpenSetupMsg);
            Error(ErrorText);
        end;

        if ConfirmManagement.GetResponseOrDefault(StrSubstNo(CombinedStatementMsg, OAuthNotConfiguredErr, OpenSetupQst), false) then begin
            GetOAuthSetup(OAuth20Setup);
            Commit();
            Page.RunModal(Page::"OAuth 2.0 Setup", OAuth20Setup);
            if IsOAuthConfigured() then
                exit;
        end;

        Error('');
    end;

    procedure GetOAuthSetup(var OAuth20Setup: Record "OAuth 2.0 Setup"): Boolean
    begin
        if not ElecVATSetup.GetRecordOnce() then
            exit(false);
        ElecVATSetup.TestField("OAuth Feature GUID");
        if not OAuth20Setup.FindFirstOAuth20SetupByFeatureAndCurrUser(ElecVATSetup."OAuth Feature GUID") then
            InitOAuthSetup(OAuth20Setup);
        exit(true);
    end;

    procedure UpdateElecVATOAuthSetupRecordsWithClientIDAndSecret(ClientID: Guid; ClientSecret: Guid)
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
    begin
        ElecVATSetup.GetRecordOnce();
        ElecVATSetup.TestField("OAuth Feature GUID");
        if not OAuth20Setup.FindSetOAuth20SetupByFeature(ElecVATSetup."OAuth Feature GUID") then
            exit;
        repeat
            OAuth20Setup."Client ID" := ClientID;
            OAuth20Setup."Client Secret" := ClientSecret;
            OAuth20Setup.Modify();
        until OAuth20Setup.Next() = 0;
    end;

    procedure UpdateElecVATOAuthSetupRecordsWithAuthenticationURL(AuthenticationURL: Text[250])
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
    begin
        ElecVATSetup.GetRecordOnce();
        if IsNullGuid(ElecVATSetup."OAuth Feature GUID") then
            exit;
        if not OAuth20Setup.FindSetOAuth20SetupByFeature(ElecVATSetup."OAuth Feature GUID") then
            exit;
        repeat
            OAuth20Setup."Service URL" := AuthenticationURL;
            OAuth20Setup.Modify();
        until OAuth20Setup.Next() = 0;
    end;

    procedure UpdateElecVATOAuthSetupRecordsWithRedirectURL(RedirectURL: Text[250])
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
    begin
        ElecVATSetup.GetRecordOnce();
        if IsNullGuid(ElecVATSetup."OAuth Feature GUID") then
            exit;
        if not OAuth20Setup.FindSetOAuth20SetupByFeature(ElecVATSetup."OAuth Feature GUID") then
            exit;
        repeat
            OAuth20Setup."Redirect URL" := RedirectURL;
            OAuth20Setup.Modify();
        until OAuth20Setup.Next() = 0;
    end;

    local procedure IsOAuthConfigured(): Boolean
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
    begin
        GetOAuthSetup(OAuth20Setup);
        exit(OAuth20Setup.Status = OAuth20Setup.Status::Enabled);
    end;

    procedure IsElectronicVATOAuthSetup(OAuth20Setup: Record "OAuth 2.0 Setup"): Boolean
    begin
        if not ElecVATSetup.GetRecordOnce() then
            exit;
        exit(OAuth20Setup."Feature GUID" = ElecVATSetup."OAuth Feature GUID");
    end;

    procedure RefreshAccessToken(var HttpError: Text): Boolean;
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        ElecVATLoggingMgt: Codeunit "Elec. VAT Logging Mgt.";
    begin
        CheckOAuthConfigured(false);
        GetOAuthSetup(OAuth20Setup);
        ElecVATLoggingMgt.LogRefreshAccessToken();
        exit(OAuth20Setup.RefreshAccessToken(HttpError));
    end;

    procedure InvokePostRequest(var ResponseJson: Text; var HttpLogError: Text; RequestPath: Text; ContentType: Text; Request: Text; ActivityLogContext: Text): Boolean
    begin
        exit(InvokeRequest(ResponseJson, HttpLogError, 'POST', RequestPath, ContentType, Request, ActivityLogContext));
    end;

    procedure InvokePostRequestTextXml(var ResponseJson: Text; var HttpLogError: Text; RequestPath: Text; ContentType: Text; Request: Text; ActivityLogContext: Text): Boolean
    begin
        exit(InvokeRequest(ResponseJson, HttpLogError, 'POST', RequestPath, ContentType, Request, ActivityLogContext));
    end;

    procedure InvokePostRequestJsonContentType(var ResponseJson: Text; var HttpLogError: Text; RequestPath: Text; Request: Text; ActivityLogContext: Text): Boolean
    begin
        exit(InvokeRequest(ResponseJson, HttpLogError, 'POST', RequestPath, GetJsonContentType(), Request, ActivityLogContext));
    end;

    procedure InvokeGetRequest(var ResponseJson: Text; var HttpLogError: Text; RequestPath: Text; ContentType: Text; Request: Text; ActivityLogContext: Text): Boolean
    begin
        exit(InvokeRequest(ResponseJson, HttpLogError, 'GET', RequestPath, GetJsonContentType(), Request, ActivityLogContext));
    end;

    procedure InvokePutRequest(var ResponseJson: Text; var HttpLogError: Text; RequestPath: Text; ContentType: Text; Request: Text; ActivityLogContext: Text): Boolean
    begin
        exit(InvokeRequest(ResponseJson, HttpLogError, 'PUT', RequestPath, ContentType, Request, ActivityLogContext));
    end;

    procedure IsError408Timeout(ResponseJson: Text): Boolean;
    var
        StatusCode: Integer;
        StatusReason: Text;
        StatusDetails: Text;
    begin
        if OAuth20Mgt.GetHttpStatusFromJsonResponse(ResponseJson, StatusCode, StatusReason, StatusDetails) then
            exit(StatusCode = 408);
    end;

    local procedure InvokeRequest(var ResponseJson: Text; var HttpLogError: Text; Method: Text; RequestPath: Text; ContentType: Text; Request: Text; ActivityLogContext: Text) Result: Boolean
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        ElecVATConnectionMgt: Codeunit "Elec. VAT Connection Mgt.";
        ElecVATLoggingMgt: Codeunit "Elec. VAT Logging Mgt.";
        JObject: JsonObject;
        JObject2: JsonObject;
        RequestJson: Text;
        HttpError: Text;
        OldServiceUrL: Text[250];
    begin
        GetOAuthSetup(OAuth20Setup);
        JObject.Add('Method', Method);
        JObject.Add('Content-Type', ContentType);
        if Request <> '' then
            if JObject2.ReadFrom(Request) then
                JObject.Add('Content', JObject2)
            else
                JObject.Add('Content', Request);
        if StrPos(RequestPath, ElecVATConnectionMgt.GetUploadVATReturnRequestPart()) <> 0 then
            JObject.Add('Content-Disposition', 'attachment; filename=mva-melding.xml');
        JObject.WriteTo(RequestJson);
        OldServiceUrL := OAuth20Setup."Service URL";
        OAuth20Setup."Service URL" := CopyStr(RequestPath, 1, MaxStrLen(OAuth20Setup."Service URL"));
        Result := OAuth20Setup.InvokeRequest(RequestJson, ResponseJson, HttpError, true);
        if not Result then
            TryParseErrors(HttpError, HttpLogError, ResponseJson);

        LogActivity(OAuth20Setup, ActivityLogContext, HttpLogError);
        OAuth20Setup.Get(OAuth20Setup.Code);
        if OAuth20Setup."Service URL" <> OldServiceUrL then begin
            OAuth20Setup."Service URL" := OldServiceUrL;
            OAuth20Setup.Modify();
        end;
        Commit();

        if Result then
            ElecVATLoggingMgt.LogInvokRequestSuccess();
    end;


    local procedure GetJsonContentType(): Text
    begin
        exit('application/json');
    end;

    local procedure TryParseErrors(var HttpError: Text; var HttpLogError: Text; ResponseJson: Text): Boolean
    var
        JObject: JsonObject;
        JToken: JsonToken;
        StatusCode: Integer;
        StatusReason: Text;
        StatusDetails: Text;
        ServicerrorMessage: Text;
    begin
        HttpLogError := HttpError;

        if not OAuth20Mgt.GetHttpStatusFromJsonResponse(ResponseJson, StatusCode, StatusReason, StatusDetails) then begin
            Session.LogMessage('0000G8G', NoHttpStatusErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', NOVATReturnSubmissionTok);
            exit(false);
        end;

        if not JObject.ReadFrom(ResponseJson) then begin
            Session.LogMessage('0000G8H', NoJsonResponseErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', NOVATReturnSubmissionTok);
            exit(false);
        end;

        if not JObject.SelectToken('Content', JToken) then
            if not JObject.SelectToken('ContentText', JToken) then begin
                Session.LogMessage('0000G8I', NoContentMessageErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', NOVATReturnSubmissionTok);
                exit(false);
            end;

        ServicerrorMessage := JToken.AsValue().AsText();
        if ServicerrorMessage = '' then begin
            Session.LogMessage('0000G8J', EmptyJsonErrMsgErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', NOVATReturnSubmissionTok);
            exit(false);
        end;

        if StatusCode = 0 then begin
            Session.LogMessage('0000G8K', NoContentStatusCodeErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', NOVATReturnSubmissionTok);
            exit(false);
        end;
        if StatusReason = '' then begin
            Session.LogMessage('0000G8L', EmptyStatusReasonErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', NOVATReturnSubmissionTok);
            exit(false);
        end;
        if ServicerrorMessage <> '' then begin
            HttpError := ServicerrorMessage;
            HttpLogError := StrSubstNo(HttpErrorTextWithDetailsTxt, StatusCode, StatusReason, HttpError);
            Session.LogMessage('0000G8M', HttpLogError, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', NOVATReturnSubmissionTok);
            exit(true);
        end;

        Session.LogMessage('0000G8N', CannotParseResponseErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', NOVATReturnSubmissionTok);
        exit(false);
    end;

    local procedure LogActivity(OAuth20Setup: Record "OAuth 2.0 Setup"; ActivityLogContext: Text; HttpError: Text)
    var
        ActivityLog: Record "Activity Log";
    begin
        with ActivityLog do
            if Get(OAuth20Setup."Activity Log ID") then begin
                if Description <> '' then
                    Description += ' ';
                Description := CopyStr(Description + ActivityLogContext, 1, MaxStrLen(Description));
                if HttpError <> '' then
                    "Activity Message" := CopyStr(HttpError, 1, MaxStrLen("Activity Message"));
                Modify();
            end;
    end;

    local procedure CheckOAuthConsistencySetup(OAuth20Setup: Record "OAuth 2.0 Setup")
    begin
        with OAuth20Setup do begin
            TestField(Scope, ScopeTxt);
            TestField("Authorization URL Path", AuthorizationURLPathTxt);
            TestField("Access Token URL Path", AccessTokenURLPathTxt);
            TestField("Refresh Token URL Path", RefreshTokenURLPathTxt);
            TestField("Authorization Response Type", AuthorizationResponseTypeTxt);
            TestField("Daily Limit", 1000);
        end;
    end;


    [NonDebuggable]
    internal procedure SetToken(var TokenKey: Guid; TokenValue: Text; TokenDataScope: DataScope) NewToken: Boolean
    begin
        if IsNullGuid(TokenKey) then
            NewToken := true;
        if NewToken then
            TokenKey := CreateGuid();

        IsolatedStorage.Set(TokenKey, TokenValue, TokenDataScope);
    end;

    [NonDebuggable]
    internal procedure SaveAltinnToken(TokenValue: Text)
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
    begin
        GetOAuthSetup(OAuth20Setup);
        SetToken(OAuth20Setup."Altinn Token", TokenValue, OAuth20Setup.GetTokenDataScope());
        OAuth20Setup.Modify();
    end;

    [NonDebuggable]
    local procedure GetToken(TokenKey: Guid; TokenDataScope: DataScope) TokenValue: Text
    begin
        if not HasToken(TokenKey, TokenDataScope) then
            exit('');

        IsolatedStorage.Get(TokenKey, TokenDataScope, TokenValue);
    end;

    local procedure HasToken(TokenKey: Guid; TokenDataScope: DataScope): Boolean
    begin
        exit(not IsNullGuid(TokenKey) and IsolatedStorage.Contains(TokenKey, TokenDataScope));
    end;

    [EventSubscriber(ObjectType::Table, Database::"OAuth 2.0 Setup", 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeleteEvent(var Rec: Record "OAuth 2.0 Setup")
    begin
        if Rec.IsTemporary() then
            exit;

        if not IsElectronicVATOAuthSetup(Rec) then
            exit;

        with Rec do begin
            DeleteToken("Client ID");
            DeleteToken("Client Secret");
            DeleteToken("Access Token");
            DeleteToken("Refresh Token");
        end;
    end;

    [NonDebuggable]
    [EventSubscriber(ObjectType::Table, Database::"OAuth 2.0 Setup", 'OnBeforeRequestAuthoizationCode', '', true, true)]
    local procedure OnBeforeRequestAuthoizationCode(OAuth20Setup: Record "OAuth 2.0 Setup"; var Processed: Boolean)
    var
        OAuth2ControlAddIn: Page OAuth2ControlAddIn;
        auth_error: Text;
        AuthorizationCode: Text;
        url: Text;
        state: Text;
    begin
        if not IsElectronicVATOAuthSetup(OAuth20Setup) or Processed then
            exit;
        Processed := true;

        CheckOAuthConsistencySetup(OAuth20Setup);
        state := Format(CreateGuid(), 0, 4);
        url :=
            StrSubstNo(CurrUrlWithStateTxt, OAuth20Mgt.GetAuthorizationURL(OAuth20Setup, GetToken(OAuth20Setup."Client ID", DataScope::Company)), state);
        OAuth2ControlAddIn.SetOAuth2Properties(url, state);
        OAuth2ControlAddIn.RunModal();
        auth_error := OAuth2ControlAddIn.GetAuthError();
        if auth_error <> '' then
            Error(auth_error);
        AuthorizationCode := OAuth2ControlAddIn.GetAuthCode();

        if AuthorizationCode <> '' then begin
            OAuth20Setup.Get(OAuth20Setup.Code);
            if not OAuth20Setup.RequestAccessToken(auth_error, AuthorizationCode) then
                Error(auth_error);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"OAuth 2.0 Setup", 'OnBeforeRequestAccessToken', '', true, true)]
    local procedure OnBeforeRequestAccessToken(var OAuth20Setup: Record "OAuth 2.0 Setup"; AuthorizationCode: Text; var Result: Boolean; var MessageText: Text; var Processed: Boolean)
    var
        RequestJSON: Text;
        AccessToken: Text;
        RefreshToken: Text;
        TokenDataScope: DataScope;
    begin
        if not IsElectronicVATOAuthSetup(OAuth20Setup) or Processed then
            exit;
        Processed := true;

        CheckOAuthConsistencySetup(OAuth20Setup);

        TokenDataScope := OAuth20Setup.GetTokenDataScope();

        Result :=
            OAuth20Mgt.RequestAccessTokenWithContentType(
                OAuth20Setup, RequestJSON, MessageText, AuthorizationCode,
                GetToken(OAuth20Setup."Client ID", DataScope::Company),
                GetToken(OAuth20Setup."Client Secret", DataScope::Company),
                AccessToken, RefreshToken, true);

        if Result then
            SaveTokens(OAuth20Setup, TokenDataScope, AccessToken, RefreshToken);
    end;

    [NonDebuggable]
    [EventSubscriber(ObjectType::Table, Database::"OAuth 2.0 Setup", 'OnBeforeRefreshAccessToken', '', true, true)]
    local procedure OnBeforeRefreshAccessToken(var OAuth20Setup: Record "OAuth 2.0 Setup"; var Result: Boolean; var MessageText: Text; var Processed: Boolean)
    var
        RequestJSON: Text;
        AccessToken: Text;
        RefreshToken: Text;
        TokenDataScope: DataScope;
        OldServiceUrl: Text[250];
    begin
        if not IsElectronicVATOAuthSetup(OAuth20Setup) or Processed then
            exit;
        Processed := true;

        CheckOAuthConsistencySetup(OAuth20Setup);

        TokenDataScope := OAuth20Setup.GetTokenDataScope();
        RefreshToken := GetToken(OAuth20Setup."Refresh Token", TokenDataScope);
        OldServiceUrl := OAuth20Setup."Service URL";
        ElecVATSetup.GetRecordOnce();
        OAuth20Setup."Service URL" := ElecVATSetup."Authentication URL";
        Result :=
            OAuth20Mgt.RefreshAccessTokenWithContentType(
                OAuth20Setup, RequestJSON, MessageText,
                GetToken(OAuth20Setup."Client ID", DataScope::Company),
                GetToken(OAuth20Setup."Client Secret", DataScope::Company),
                AccessToken, RefreshToken, true);
        OAuth20Setup."Service URL" := OldServiceUrl;

        if Result then
            SaveTokens(OAuth20Setup, TokenDataScope, AccessToken, RefreshToken);
    end;

    [NonDebuggable]
    local procedure SaveTokens(var OAuth20Setup: Record "OAuth 2.0 Setup"; TokenDataScope: DataScope; AccessToken: Text; RefreshToken: Text)
    var
        TypeHelper: Codeunit "Type Helper";
        NewAccessTokenDateTime: DateTime;
    begin
        SetToken(OAuth20Setup."Access Token", AccessToken, TokenDataScope);
        SetToken(OAuth20Setup."Refresh Token", RefreshToken, TokenDataScope);
        NewAccessTokenDateTime := TypeHelper.AddHoursToDateTime(CurrentDateTime(), 2);
        if OAuth20Setup."Access Token Due DateTime" = 0DT then
            OAuth20Setup."Access Token Due DateTime" := NewAccessTokenDateTime
        else
            if OAuth20Setup."Access Token Due DateTime" < NewAccessTokenDateTime then
                OAuth20Setup."Access Token Due DateTime" := NewAccessTokenDateTime;
        OAuth20Setup.Modify();
        Commit();
    end;

    [NonDebuggable]
    [EventSubscriber(ObjectType::Table, Database::"OAuth 2.0 Setup", 'OnBeforeInvokeRequest', '', true, true)]
    local procedure OnBeforeInvokeRequest(var OAuth20Setup: Record "OAuth 2.0 Setup"; RequestJSON: Text; var ResponseJSON: Text; var HttpError: Text; var Result: Boolean; var Processed: Boolean; RetryOnCredentialsFailure: Boolean)
    var
        TokenValue: Text;
    begin
        if not IsElectronicVATOAuthSetup(OAuth20Setup) or Processed then
            exit;
        Processed := true;

        CheckOAuthConsistencySetup(OAuth20Setup);
        ElecVATSetup.GetRecordOnce();
        ElecVATSetup.TestField("Submission Environment URL");
        if StrPos(OAuth20Setup."Service URL", ElecVATSetup."Submission Environment URL") = 1 then
            TokenValue := GetToken(OAuth20Setup."Altinn Token", OAuth20Setup.GetTokenDataScope())
        else
            TokenValue := GetToken(OAuth20Setup."Access Token", OAuth20Setup.GetTokenDataScope());
        Result :=
            OAuth20Mgt.InvokeRequest(
                OAuth20Setup, RequestJSON, ResponseJSON, HttpError, TokenValue, RetryOnCredentialsFailure);
    end;

    [EventSubscriber(ObjectType::Table, Database::"OAuth 2.0 Setup", 'OnAfterRequestAccessToken', '', true, true)]
    local procedure OnAfterRequestAccessToken(OAuth20Setup: Record "OAuth 2.0 Setup"; Result: Boolean; var MessageText: Text)
    begin
        if not IsElectronicVATOAuthSetup(OAuth20Setup) then
            exit;

        if Result then begin
            MessageText := '';
            if Confirm(CheckCompanyVATNoAfterSuccessAuthorizationQst) then
                Page.RunModal(Page::"Company Information")
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"OAuth 2.0 Mgt.", 'OnBeforeCheckEncryption', '', true, true)]
    local procedure OnBeforeCheckEncryption(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Connection", 'OnRegisterServiceConnection', '', true, true)]
    local procedure OnRegisterServiceConnection(var ServiceConnection: Record "Service Connection")
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
    begin
        if not GetOAuthSetup(OAuth20Setup) then
            exit;
        ServiceConnection.Status := OAuth20Setup.Status;
        ServiceConnection.InsertServiceConnection(
          ServiceConnection, OAuth20Setup.RecordId(), ServiceConnectionSetupLbl, '', PAGE::"OAuth 2.0 Setup");
    end;
}
