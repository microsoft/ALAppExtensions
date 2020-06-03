// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1432 "Satisfaction Survey Impl."
{
    Access = Internal;

    var
        FinancialsUriSegmentTxt: Label 'financials', Locked = true;
        DisplayDataTxt: Label 'display/%1/?puid=%2', Locked = true;
        RenderDataTxt: Label 'render/%1/?culture=%2&puid=%3', Locked = true;
        NpsCategoryTxt: Label 'AL NPS Prompt', Locked = true;
        RequestFailedTxt: Label 'Request failed without status code.', Locked = true;
        NPSApiUrlEmptyTelemetryTxt: Label 'API URL is empty.', Locked = true;
        NoPermissionTxt: Label 'No permission.', Locked = true;
        NotSupportedTxt: Label 'Survey is not supported.', Locked = true;
        HttpsTxt: Label 'https://', Locked = true;
        InvalidCheckUrlTxt: Label 'Check URL is invalid.', Locked = true;
        ValidCheckUrlTxt: Label 'Check URL is valid.', Locked = true;
        AlreadyDeactivatedTxt: Label 'Survey is already deactivated.', Locked = true;
        AlreadyActivatedTxt: Label 'Survey is already activated.', Locked = true;
        DeactivatedTxt: Label 'Survey is deactivated.', Locked = true;
        ActivatedTxt: Label 'Survey is activated.', Locked = true;
        ActivatingForPuidTxt: Label 'Activating survey for PUID %1.', Locked = true;
        RequestFailedWithStatusCodeTxt: Label 'Request failed with status code %1.', Locked = true;
        CannotUseDefaultCredentialsTxt: Label 'Cannot use default credentials.', Locked = true;
        CannotSetRequestUriTxt: Label 'Cannot set request URI.', Locked = true;
        CannotGetRequestHeadersTxt: Label 'Cannot get request headers.', Locked = true;
        CannotAddRequestHeaderTxt: Label 'Cannot add request header %1: %2.', Locked = true;
        CannotReadResponseContentTxt: Label 'Cannot read response content.', Locked = true;
        DisplayTxt: Label 'display', Locked = true;
        MessageTypeTxt: Label 'msgType', Locked = true;
        EmptyPuidTxt: Label 'PUID is empty.', Locked = true;
        NoPromptTxt: Label 'No NPS prompt.', Locked = true;
        PositiveResponseTxt: Label 'Positive response.', Locked = true;
        NegativeResponseTxt: Label 'Negative response.', Locked = true;
        CannotGetPropertyTxt: Label 'Cannot get property %1.', Locked = true;
        RequestSuccessfulTxt: Label 'Request is successful.', Locked = true;
        CannotParseParametersTxt: Label 'Cannot parse parameters.', Locked = true;
        NPSPageTelemetryTxt: Label 'NPS prompt is displayed.', Locked = true;
        NpsApiUrlTxt: Label 'NpsApiUrl', Locked = true;
        NpsRequestTimeoutTxt: Label 'NpsRequestTimeout', Locked = true;
        NpsCacheLifeTimeTxt: Label 'NpsCacheLifeTime', Locked = true;
        NpsParametersTxt: Label 'NpsParameters', Locked = true;
        SecretNotFoundTxt: Label 'Secret %1 is not found.', Locked = true;
        ParameterNotFoundTxt: Label 'Parameter %1 is not found.', Locked = true;
        CouldNotInsertSetupRecordTxt: Label 'Inserting of the setup record has failed.', Locked = true;
        CouldNotModifySetupRecordTxt: Label 'Modification of the setup record has failed.', Locked = true;
        TooEarlyTxt: Label 'Too short time since last activation try.', Locked = true;

    procedure TryShowSurvey(): Boolean
    begin
        if not IsActivated() then begin
            SendTraceTag('0000838', NpsCategoryTxt, VERBOSITY::Normal, NoPromptTxt, DATACLASSIFICATION::SystemMetadata);
            exit(false);
        end;

        DeactivateSurvey();

        if not IsEnabled() then begin
            SendTraceTag('0000924', NpsCategoryTxt, VERBOSITY::Normal, NoPromptTxt, DATACLASSIFICATION::SystemMetadata);
            exit(false);
        end;

        Commit();

        SendTraceTag('00008MW', NpsCategoryTxt, VERBOSITY::Normal, NPSPageTelemetryTxt, DATACLASSIFICATION::SystemMetadata);
        PAGE.RunModal(PAGE::"Satisfaction Survey");
        SendTraceTag('00006ZF', NpsCategoryTxt, VERBOSITY::Normal, NPSPageTelemetryTxt, DATACLASSIFICATION::SystemMetadata);
        exit(true);
    end;

    procedure TryShowSurvey(Status: Integer; Response: Text): Boolean
    begin
        DeactivateSurvey();

        if not IsEnabled(Status, Response) then begin
            SendTraceTag('000098N', NpsCategoryTxt, VERBOSITY::Normal, NoPromptTxt, DATACLASSIFICATION::SystemMetadata);
            exit(false);
        end;

        Commit();

        SendTraceTag('000098O', NpsCategoryTxt, VERBOSITY::Normal, NPSPageTelemetryTxt, DATACLASSIFICATION::SystemMetadata);
        PAGE.RunModal(PAGE::"Satisfaction Survey");
        SendTraceTag('000098P', NpsCategoryTxt, VERBOSITY::Normal, NPSPageTelemetryTxt, DATACLASSIFICATION::SystemMetadata);
        exit(true);
    end;

    procedure ResetState(): Boolean
    var
        NetPromoterScore: Record "Net Promoter Score";
    begin
        if not NetPromoterScore.WritePermission() then
            exit(false);

        NetPromoterScore.DeleteAll();
        exit(true);
    end;

    procedure ResetCache(): Boolean
    var
        NetPromoterScoreSetup: Record "Net Promoter Score Setup";
    begin
        if not NetPromoterScoreSetup.WritePermission() then
            exit(false);

        NetPromoterScoreSetup.ModifyAll("Expire Time", CurrentDateTime() - 1000);
        exit(true);
    end;

    procedure ActivateSurvey(): Boolean
    var
        NetPromoterScore: Record "Net Promoter Score";
        EarliestActivateTime: DateTime;
        Puid: Text;
    begin
        if not IsSupported() then begin
            if GuiAllowed() then
                SendTraceTag('000098Q', NpsCategoryTxt, VERBOSITY::Normal, NotSupportedTxt, DATACLASSIFICATION::SystemMetadata);
            exit(false);
        end;

        Puid := GetPuid();
        if Puid = '' then begin
            SendTraceTag('000098R', NpsCategoryTxt, VERBOSITY::Normal, EmptyPuidTxt, DATACLASSIFICATION::SystemMetadata);
            exit(false);
        end;

        if not NetPromoterScore.WritePermission() then begin
            SendTraceTag('000098S', NpsCategoryTxt, VERBOSITY::Warning, NoPermissionTxt, DATACLASSIFICATION::SystemMetadata);
            exit(false);
        end;

        SendTraceTag('000098U', NpsCategoryTxt, VERBOSITY::Normal, StrSubstNo(ActivatingForPuidTxt, Puid), DATACLASSIFICATION::CustomerContent);

        if not NetPromoterScore.Get(UserSecurityId()) then begin
            NetPromoterScore.Init();
            NetPromoterScore."User SID" := UserSecurityId();
            NetPromoterScore."Last Request Time" := CurrentDateTime();
            NetPromoterScore."Send Request" := true;
            if NetPromoterScore.Insert() then begin
                SendTraceTag('00009FV', NpsCategoryTxt, VERBOSITY::Normal, ActivatedTxt, DATACLASSIFICATION::SystemMetadata);
                exit(true);
            end else begin
                SendTraceTag('00009N4', NpsCategoryTxt, VERBOSITY::Warning, CouldNotInsertSetupRecordTxt, DATACLASSIFICATION::SystemMetadata);
                exit(false);
            end;
        end;

        EarliestActivateTime := NetPromoterScore."Last Request Time" + MinDelayTime() * MillisecondsInMinute();
        if CurrentDateTime() < EarliestActivateTime then begin
            SendTraceTag('0000AW8', NpsCategoryTxt, VERBOSITY::Normal, TooEarlyTxt, DATACLASSIFICATION::SystemMetadata);
            exit(false);
        end;

        if not NetPromoterScore."Send Request" then begin
            SendTraceTag('000098T', NpsCategoryTxt, VERBOSITY::Normal, ActivatedTxt, DATACLASSIFICATION::SystemMetadata);
            NetPromoterScore."Last Request Time" := CurrentDateTime();
            NetPromoterScore."Send Request" := true;
            if NetPromoterScore.Modify() then
                exit(true)
            else begin
                SendTraceTag('00009N5', NpsCategoryTxt, VERBOSITY::Warning, CouldNotModifySetupRecordTxt, DATACLASSIFICATION::SystemMetadata);
                exit(false);
            end;
        end;

        SendTraceTag('00009FW', NpsCategoryTxt, VERBOSITY::Normal, AlreadyActivatedTxt, DATACLASSIFICATION::SystemMetadata);
        exit(false);
    end;

    procedure DeactivateSurvey(): Boolean
    var
        NetPromoterScore: Record "Net Promoter Score";
    begin
        if not IsSupported() then begin
            if GuiAllowed() then
                SendTraceTag('00009FX', NpsCategoryTxt, VERBOSITY::Normal, NotSupportedTxt, DATACLASSIFICATION::SystemMetadata);
            exit(false);
        end;

        if not NetPromoterScore.WritePermission() then begin
            SendTraceTag('00009FY', NpsCategoryTxt, VERBOSITY::Warning, NoPermissionTxt, DATACLASSIFICATION::SystemMetadata);
            exit(false);
        end;

        if not NetPromoterScore.Get(UserSecurityId()) then begin
            SendTraceTag('00009FZ', NpsCategoryTxt, VERBOSITY::Normal, AlreadyDeactivatedTxt, DATACLASSIFICATION::SystemMetadata);
            exit(false);
        end;

        if NetPromoterScore."Send Request" then begin
            NetPromoterScore."Send Request" := false;
            NetPromoterScore.Modify();
            SendTraceTag('00009G0', NpsCategoryTxt, VERBOSITY::Normal, DeactivatedTxt, DATACLASSIFICATION::SystemMetadata);
            exit(true);
        end;

        SendTraceTag('00009G1', NpsCategoryTxt, VERBOSITY::Normal, AlreadyDeactivatedTxt, DATACLASSIFICATION::SystemMetadata);
        exit(false);
    end;

    procedure TryGetCheckUrl(var CheckUrl: Text): Boolean
    begin
        CheckUrl := GetDisplayUrl();
        if CheckUrl.StartsWith(HttpsTxt) then begin
            SendTraceTag('00009G2', NpsCategoryTxt, VERBOSITY::Normal, ValidCheckUrlTxt, DATACLASSIFICATION::SystemMetadata);
            exit(true);
        end;
        SendTraceTag('00009G3', NpsCategoryTxt, VERBOSITY::Normal, InvalidCheckUrlTxt, DATACLASSIFICATION::SystemMetadata);
        exit(false);
    end;

    local procedure IsEnabled(): Boolean
    var
        Puid: Text;
        Data: Text;
        BaseUrl: Text;
        DisplayUrl: Text;
        ResponseText: Text;
        Display: Boolean;
    begin
        if not IsSupported() then
            exit(false);

        Puid := GetPuid();
        BaseUrl := GetApiUrl();

        if not IsConfigured(Puid, BaseUrl) then
            exit(false);

        Data := GetDisplayData(Puid);
        DisplayUrl := GetFullUrl(BaseUrl, Data);
        if not TryExecuteWebRequest(DisplayUrl, ResponseText) then
            exit(false);

        Display := GetDisplayProperty(ResponseText);
        exit(Display);
    end;

    local procedure IsEnabled(StatusCode: Integer; ResponseText: Text): Boolean
    var
        Display: Boolean;
    begin
        if not IsSupported() then
            exit(false);

        if StatusCode = 0 then begin
            SendTraceTag('000098V', NpsCategoryTxt, VERBOSITY::Warning, RequestFailedTxt, DATACLASSIFICATION::SystemMetadata);
            SendTraceTag('000098W', NpsCategoryTxt, VERBOSITY::Warning, ResponseText, DATACLASSIFICATION::CustomerContent);
            exit(false);
        end;

        if StatusCode <> 200 then begin
            if (StatusCode >= 400) and (StatusCode <= 499) then
                SendTraceTag('000098X', NpsCategoryTxt, VERBOSITY::Error, StrSubstNo(RequestFailedWithStatusCodeTxt, StatusCode), DATACLASSIFICATION::SystemMetadata)
            else
                SendTraceTag('000098Y', NpsCategoryTxt, VERBOSITY::Warning, StrSubstNo(RequestFailedWithStatusCodeTxt, StatusCode), DATACLASSIFICATION::SystemMetadata);
            exit(false);
        end;

        SendTraceTag('000098Z', NpsCategoryTxt, VERBOSITY::Normal, RequestSuccessfulTxt, DATACLASSIFICATION::SystemMetadata);

        Display := GetDisplayProperty(ResponseText);
        exit(Display);
    end;

    procedure IsCloseCallback(CallbackData: Text): Boolean
    var
        MessageType: Text;
    begin
        if not GetMessageType(CallbackData, MessageType) then
            exit(false);

        if UpperCase(MessageType) <> UpperCase('closeNpsDialog') then
            exit(false);

        exit(true);
    end;

    local procedure IsSupported(): Boolean
    var
        EnvironmentInfo: Codeunit "Environment Information";
    begin
        if not GuiAllowed() then
            exit(false);

        if not EnvironmentInfo.IsSaaS() then
            exit(false);

        if EnvironmentInfo.IsSandbox() then
            exit(false);

        if EnvironmentInfo.IsFinancials() then
            exit(not IsMobileDevice())
        else
            exit(false);
    end;

    local procedure IsConfigured(Puid: Text; BaseUrl: Text): Boolean
    begin
        if not HasWritePermission() then begin
            SendTraceTag('00008MX', NpsCategoryTxt, VERBOSITY::Normal, NoPermissionTxt, DATACLASSIFICATION::SystemMetadata);
            exit(false);
        end;

        if Puid = '' then begin
            SendTraceTag('00007K9', NpsCategoryTxt, VERBOSITY::Normal, EmptyPuidTxt, DATACLASSIFICATION::SystemMetadata);
            exit(false);
        end;

        if BaseUrl = '' then begin
            SendTraceTag('00006ZE', NpsCategoryTxt, VERBOSITY::Warning, NPSApiUrlEmptyTelemetryTxt, DATACLASSIFICATION::SystemMetadata);
            exit(false);
        end;

        exit(true);
    end;

    local procedure IsMobileDevice(): Boolean
    var
        ClientTypeManagement: Codeunit "Client Type Management";
    begin
        exit(ClientTypeManagement.GetCurrentClientType() in [CLIENTTYPE::Phone, CLIENTTYPE::Tablet]);
    end;

    local procedure HasWritePermission(): Boolean
    var
        NetPromoterScoreSetup: Record "Net Promoter Score Setup";
        NetPromoterScore: Record "Net Promoter Score";
    begin
        if not NetPromoterScoreSetup.WritePermission() then
            exit(false);

        if not NetPromoterScore.WritePermission() then
            exit(false);

        exit(true);
    end;

    local procedure IsActivated(): Boolean
    var
        NetPromoterScore: Record "Net Promoter Score";
    begin
        if not NetPromoterScore.Get(UserSecurityId()) then
            exit(false);

        exit(NetPromoterScore."Send Request");
    end;

    [TryFunction]
    local procedure TryExecuteWebRequest(RequestUrl: Text; var ResponseText: Text)
    var
        ErrorMessage: Text;
    begin
        // We use try function because the satisfaction survey must not break anything
        if not ExecuteWebRequest(RequestUrl, ResponseText, ErrorMessage) then
            Error(AddLastError(ErrorMessage));
    end;

    local procedure ExecuteWebRequest(RequestUrl: Text; var ResponseText: Text; var ErrorMessage: Text): Boolean
    var
        Client: HttpClient;
        RequestHeaders: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        StatusCode: Integer;
    begin
        ClearLastError();
        Client.Clear();
        Client.DefaultRequestHeaders().Clear();
        Client.Timeout := TimeoutInMilliseconds();

        if not Client.UseDefaultNetworkWindowsAuthentication() then begin
            ErrorMessage := CannotUseDefaultCredentialsTxt;
            SendTraceTag('00008TZ', NpsCategoryTxt, VERBOSITY::Error, ErrorMessage, DATACLASSIFICATION::SystemMetadata);
            exit(false);
        end;

        if not RequestMessage.GetHeaders(RequestHeaders) then begin
            ErrorMessage := CannotGetRequestHeadersTxt;
            SendTraceTag('00008U0', NpsCategoryTxt, VERBOSITY::Error, ErrorMessage, DATACLASSIFICATION::SystemMetadata);
            exit(false);
        end;

        if not AddRequestHeader(RequestHeaders, 'Accept', 'application/json', ErrorMessage) then
            exit(false);

        if not AddRequestHeader(RequestHeaders, 'Accept-Encoding', 'utf-8', ErrorMessage) then
            exit(false);

        if not AddRequestHeader(RequestHeaders, 'Connection', 'Keep-Alive', ErrorMessage) then
            exit(false);

        RequestMessage.Method('GET');
        if not RequestMessage.SetRequestUri(RequestUrl) then begin
            ErrorMessage := CannotSetRequestUriTxt;
            SendTraceTag('00008U1', NpsCategoryTxt, VERBOSITY::Error, ErrorMessage, DATACLASSIFICATION::SystemMetadata);
            exit(false);
        end;

        if not Client.Send(RequestMessage, ResponseMessage) then begin
            ErrorMessage := RequestFailedTxt;
            SendTraceTag('0000836', NpsCategoryTxt, VERBOSITY::Warning, ErrorMessage, DATACLASSIFICATION::SystemMetadata);
            exit(false);
        end;

        if not ResponseMessage.IsSuccessStatusCode() then begin
            StatusCode := ResponseMessage.HttpStatusCode();
            ErrorMessage := StrSubstNo(RequestFailedWithStatusCodeTxt, StatusCode);
            if (StatusCode >= 400) and (StatusCode <= 499) then
                SendTraceTag('0000837', NpsCategoryTxt, VERBOSITY::Error, ErrorMessage, DATACLASSIFICATION::SystemMetadata)
            else
                SendTraceTag('000022Q', NpsCategoryTxt, VERBOSITY::Warning, ErrorMessage, DATACLASSIFICATION::SystemMetadata);
            exit(false);
        end;

        if not ResponseMessage.Content().ReadAs(ResponseText) then begin
            ErrorMessage := CannotReadResponseContentTxt;
            SendTraceTag('00008U2', NpsCategoryTxt, VERBOSITY::Warning, ErrorMessage, DATACLASSIFICATION::SystemMetadata);
            exit(false);
        end;

        SendTraceTag('000093P', NpsCategoryTxt, VERBOSITY::Normal, RequestSuccessfulTxt, DATACLASSIFICATION::SystemMetadata);
        exit(true);
    end;

    local procedure AddRequestHeader(RequestHeaders: HttpHeaders; Name: Text; Value: Text; var ErrorMessage: Text): Boolean
    var
        LogMessage: Text;
    begin
        if RequestHeaders.Add(Name, Value) then
            exit(true);
        LogMessage := StrSubstNo(CannotAddRequestHeaderTxt, Name, Value);
        SendTraceTag('00008U3', NpsCategoryTxt, VERBOSITY::Error, ErrorMessage, DATACLASSIFICATION::SystemMetadata);
        ErrorMessage := LogMessage;
        exit(false);
    end;

    local procedure AddLastError(LogMessage: Text): Text
    var
        LastErrorText: Text;
        LogErrorTxt: Label '%1 %2', Comment = '%1 - Log message, %2 - Last error', Locked = true;
    begin
        LastErrorText := GetLastErrorText();
        if LastErrorText = '' then
            exit(LogMessage);
        exit(StrSubstNo(LogErrorTxt, LogMessage, LastErrorText));
    end;

    local procedure GetPuid(): Text
    var
        UserProperty: Record "User Property";
    begin
        if UserProperty.Get(UserSecurityId()) then
            exit(UserProperty."Authentication Object ID");

        exit('');
    end;

    local procedure GetDisplayUrl(): Text
    var
        Puid: Text;
        Data: Text;
        BaseUrl: Text;
        FullUrl: Text;
    begin
        BaseUrl := GetApiUrl();
        Puid := GetPuid();
        Data := GetDisplayData(Puid);
        FullUrl := GetFullUrl(BaseUrl, Data);
        exit(FullUrl);
    end;

    procedure GetRenderUrl(): Text
    var
        Puid: Text;
        Data: Text;
        BaseUrl: Text;
        FullUrl: Text;
    begin
        BaseUrl := GetApiUrl();
        Puid := GetPuid();
        Data := GetRenderData(Puid);
        FullUrl := GetFullUrl(BaseUrl, Data);
        exit(FullUrl);
    end;

    local procedure GetFullUrl(BaseUrl: Text; Data: Text): Text
    var
        FullUrl: Text;
        UrlTxt: Label '%1%2', Comment = '%1 - Base url, %2 - Data', Locked = true;
    begin
        if (BaseUrl <> '') and (Data <> '') then
            FullUrl := StrSubstNo(UrlTxt, BaseUrl, Data);
        exit(FullUrl);
    end;

    local procedure GetApiUrl(): Text
    var
        NetPromoterScoreSetup: Record "Net Promoter Score Setup";
        ApiUrl: Text;
    begin
        if not NetPromoterScoreSetup.Get() then;
        if CurrentDateTime() > NetPromoterScoreSetup."Expire Time" then
            RenewApiUrl(NetPromoterScoreSetup);
        ApiUrl := CalculateApiUrl(NetPromoterScoreSetup);
        exit(ApiUrl);
    end;

    local procedure RenewApiUrl(var NetPromoterScoreSetup: Record "Net Promoter Score Setup")
    var
        OutStream: OutStream;
        ApiUrl: Text;
        CacheLifeTime: Integer;
        RequestTimeout: Integer;
        Exists: Boolean;
    begin
        RequestTimeout := DefaultRequestTimeout();
        CacheLifeTime := DefaultCacheLifeTime();
        if not GetSurveyParameters(ApiUrl, RequestTimeout, CacheLifeTime) then
            ApiUrl := '';

        NetPromoterScoreSetup.LockTable();
        Exists := NetPromoterScoreSetup.Get();
        if ApiUrl = '' then begin
            CacheLifeTime := MinCacheLifeTime();
            Clear(NetPromoterScoreSetup."API URL");
        end else begin
            NetPromoterScoreSetup."API URL".CreateOutStream(OutStream);
            OutStream.Write(ApiUrl);
        end;
        NetPromoterScoreSetup."Request Timeout" := RequestTimeout;
        NetPromoterScoreSetup."Expire Time" := CurrentDateTime() + CacheLifeTime * MillisecondsInMinute();
        if Exists then begin
            if NetPromoterScoreSetup.Modify() then;
        end else
            if NetPromoterScoreSetup.Insert() then;
        Commit();
    end;

    local procedure CalculateApiUrl(var NetPromoterScoreSetup: Record "Net Promoter Score Setup"): Text
    var
        InStream: InStream;
        ApiUrl: Text;
    begin
        NetPromoterScoreSetup.CalcFields("API URL");
        if NetPromoterScoreSetup."API URL".HasValue() then begin
            NetPromoterScoreSetup."API URL".CreateInStream(InStream);
            InStream.Read(ApiUrl);
        end;
        exit(ApiUrl);
    end;

    local procedure GetDisplayData(Puid: Text): Text
    var
        Data: Text;
        AppUriSegment: Text;
    begin
        if Puid = '' then
            exit('');

        AppUriSegment := GetApplicationUriSegment();
        if AppUriSegment = '' then
            exit('');

        Data := StrSubstNo(DisplayDataTxt, AppUriSegment, Puid);
        exit(Data);
    end;

    local procedure GetRenderData(Puid: Text): Text
    var
        CultureInfo: DotNet CultureInfo;
        CultureName: Text;
        Data: Text;
        AppUriSegment: Text;
    begin
        Puid := GetPuid();
        if Puid = '' then
            exit('');

        AppUriSegment := GetApplicationUriSegment();
        if AppUriSegment = '' then
            exit('');

        CultureInfo := CultureInfo.CultureInfo(GlobalLanguage());
        CultureName := LowerCase(CultureInfo.Name());
        Data := StrSubstNo(RenderDataTxt, AppUriSegment, CultureName, Puid);
        exit(Data);
    end;

    local procedure GetApplicationUriSegment(): Text
    var
        EnvironmentInfo: Codeunit "Environment Information";
    begin
        if EnvironmentInfo.IsFinancials() then
            exit(FinancialsUriSegmentTxt)
        else
            exit('');
    end;

    local procedure GetDisplayProperty(JsonString: Text): Boolean
    var
        JObject: JsonObject;
        PropertyValue: Text;
        DisplayProperty: Boolean;
    begin
        if JObject.ReadFrom(JsonString) then
            if GetJsonPropertyValue(JObject, DisplayTxt, PropertyValue) then
                if Evaluate(DisplayProperty, PropertyValue, 2) then begin
                    if DisplayProperty then
                        SendTraceTag('000093Q', NpsCategoryTxt, VERBOSITY::Normal, PositiveResponseTxt, DATACLASSIFICATION::SystemMetadata)
                    else
                        SendTraceTag('000093R', NpsCategoryTxt, VERBOSITY::Normal, NegativeResponseTxt, DATACLASSIFICATION::SystemMetadata);
                    exit(DisplayProperty);
                end;
        SendTraceTag('000094U', NpsCategoryTxt, VERBOSITY::Warning, StrSubstNo(CannotGetPropertyTxt, DisplayTxt), DATACLASSIFICATION::SystemMetadata);
    end;

    local procedure GetMessageType(JsonString: Text; var MessageType: Text): Boolean
    var
        JObject: JsonObject;
    begin
        if JObject.ReadFrom(JsonString) then
            if GetJsonPropertyValue(JObject, MessageTypeTxt, MessageType) then
                exit(true);
        SendTraceTag('000093T', NpsCategoryTxt, VERBOSITY::Warning, StrSubstNo(CannotGetPropertyTxt, MessageTypeTxt), DATACLASSIFICATION::SystemMetadata);
        exit(false);
    end;

    local procedure GetJsonPropertyValue(JObject: JsonObject; PropertyPath: Text; var PropertyValue: Text): Boolean
    var
        JToken: JsonToken;
    begin
        if not JObject.SelectToken(PropertyPath, JToken) then
            exit(false);

        PropertyValue := JToken.AsValue().AsText();
        exit(true);
    end;

    local procedure GetSurveyParameters(var ApiUrl: Text; var RequestTimeoutMilliseconds: Integer; var CacheLifeTimeMinutes: Integer): Boolean
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        JObject: JsonObject;
        SecretValue: Text;
        RequestTimeoutValueTxt: Text;
        CacheLifeTimeValueTxt: Text;
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret(NpsParametersTxt, SecretValue) then begin
            SendTraceTag('0000832', NpsCategoryTxt, VERBOSITY::Warning,
              StrSubstNo(SecretNotFoundTxt, NpsParametersTxt), DATACLASSIFICATION::SystemMetadata);
            exit(false);
        end;

        if not JObject.ReadFrom(SecretValue) then begin
            SendTraceTag('000094V', NpsCategoryTxt, VERBOSITY::Warning, CannotParseParametersTxt, DATACLASSIFICATION::SystemMetadata);
            exit(false);
        end;

        if not GetJsonPropertyValue(JObject, NpsApiUrlTxt, ApiUrl) then begin
            SendTraceTag('0000833', NpsCategoryTxt, VERBOSITY::Warning,
              StrSubstNo(ParameterNotFoundTxt, NpsApiUrlTxt), DATACLASSIFICATION::SystemMetadata);
            exit(false);
        end;

        if GetJsonPropertyValue(JObject, NpsRequestTimeoutTxt, RequestTimeoutValueTxt) then
            if Evaluate(RequestTimeoutMilliseconds, RequestTimeoutValueTxt) then
                if (RequestTimeoutMilliseconds > 0) and (RequestTimeoutMilliseconds < MinRequestTimeout()) then
                    RequestTimeoutMilliseconds := MinRequestTimeout();
        if RequestTimeoutMilliseconds = 0 then begin
            SendTraceTag('0000834', NpsCategoryTxt, VERBOSITY::Warning,
              StrSubstNo(ParameterNotFoundTxt, NpsRequestTimeoutTxt), DATACLASSIFICATION::SystemMetadata);
            RequestTimeoutMilliseconds := DefaultRequestTimeout();
        end;

        if GetJsonPropertyValue(JObject, NpsCacheLifeTimeTxt, CacheLifeTimeValueTxt) then
            if Evaluate(CacheLifeTimeMinutes, CacheLifeTimeValueTxt) then
                if CacheLifeTimeMinutes < MinCacheLifeTime() then
                    CacheLifeTimeMinutes := MinCacheLifeTime();
        if CacheLifeTimeMinutes = 0 then begin
            SendTraceTag('0000835', NpsCategoryTxt, VERBOSITY::Warning,
              StrSubstNo(ParameterNotFoundTxt, NpsCacheLifeTimeTxt), DATACLASSIFICATION::SystemMetadata);
            CacheLifeTimeMinutes := DefaultCacheLifeTime();
        end;

        exit(true);
    end;

    procedure GetRequestTimeoutAsync(): Integer
    begin
        exit(30000); // 30 seconds
    end;

    local procedure TimeoutInMilliseconds(): Integer
    var
        NetPromoterScoreSetup: Record "Net Promoter Score Setup";
    begin
        if not NetPromoterScoreSetup.Get() then
            exit(DefaultRequestTimeout());
        if NetPromoterScoreSetup."Request Timeout" <= 0 then
            exit(DefaultRequestTimeout());
        if NetPromoterScoreSetup."Request Timeout" < MinRequestTimeout() then
            exit(MinRequestTimeout());
        exit(NetPromoterScoreSetup."Request Timeout");
    end;

    local procedure MinDelayTime(): Integer
    begin
        exit(30); // 30 minutes
    end;

    local procedure MinCacheLifeTime(): Integer
    begin
        exit(1); // one minute
    end;

    local procedure DefaultCacheLifeTime(): Integer
    begin
        exit(1440); // 24 hours
    end;

    local procedure MinRequestTimeout(): Integer
    begin
        exit(250); // 250 milliseconds
    end;

    local procedure DefaultRequestTimeout(): Integer
    begin
        exit(5000); // 5 seconds
    end;

    local procedure MillisecondsInMinute(): Integer
    begin
        exit(60000);
    end;
}

