codeunit 20124 "AMC Bank REST Request Mgt."
{

    //new procedure for handling REST http call - as we can't use Codeunit 1290, as functions are missing
    var
        GlobalProgressDialogEnabled: Boolean;
        GLBEnableErrorException: Boolean;
        GLBHeadersHttpClient: HttpHeaders;
        GLBHeadersContentHttp: HttpHeaders;
        GLBResponseErrorText: Text;
        GlobalTimeout: Integer;
        GLBFromId: Integer;
        GLBToId: Integer;
        TryLoadErrorLbl: Label 'The web service returned an error message:\';
        WebLoadErrorLbl: Label 'Status code: %1', Comment = '%1=Http Statuscode';
        ProcessingDialogMsg: Label 'Please wait while the server is processing your request.\This may take several minutes.';
        ContentTypeTxt: Label 'application/json; charset=utf-8', Locked = true;
        FeatureConsentErr: Label 'The AMC Banking 365 Fundamentals feature is not enabled. You can enable the feature on the AMC Banking Setup page by turning on the Enabled toggle, or by using the assisted setup guide.';

    local procedure disposeGLBHttpVariable();
    begin
        GLBHeadersHttpClient.Clear();
        GLBHeadersContentHttp.Clear();
        CLEAR(GLBResponseErrorText);
        CLEAR(GLBFromId);
        CLEAR(GLBToId);
    end;

    procedure SetTimeout(NewTimeout: Integer)
    begin
        GlobalTimeout := NewTimeout;
    end;

    procedure DisableProgressDialog()
    begin
        GlobalProgressDialogEnabled := false;
    end;

    procedure InitializeHttp(Var InitHttpRequestMessage: HttpRequestMessage; URL: Text; MessageMethod: Text[6]);
    begin
        disposeGLBHttpVariable();
        GlobalProgressDialogEnabled := true;
        InitHttpRequestMessage.Method(MessageMethod);
        InitHttpRequestMessage.SetRequestUri(URL);
        InitHttpRequestMessage.GetHeaders(GLBHeadersHttpClient);
        SetHttpClientDefaults();
    end;

    local procedure SetHttpClientDefaults();
    var
    begin
        if (GLBHeadersHttpClient.Contains('Accept')) THEN
            GLBHeadersHttpClient.Remove('Accept');

        GLBHeadersHttpClient.Add('Accept', ContentTypeTxt);
    end;

    procedure SetHttpContentsDefaults(Var HeaderHttpRequestMessage: HttpRequestMessage);
    var
    begin
        HeaderHttpRequestMessage.Content().GetHeaders(GLBHeadersContentHttp);

        if (GLBHeadersContentHttp.Contains('Content-Type')) THEN
            GLBHeadersContentHttp.Remove('Content-Type');

        GLBHeadersContentHttp.Add('Content-Type', ContentTypeTxt);

        AddAMCSpecificHttpHeaders(HeaderHttpRequestMessage, GLBHeadersContentHttp);

    end;

    local procedure AddAMCSpecificHttpHeaders(HeaderHttpRequestMessage: HttpRequestMessage; var RequestHttpHeaders: HttpHeaders)
    var
        User: Record User;
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        AMCName: Text;
        AMCEmail: Text;
        AMCGUID: GUID;
        ContentOutStream: OutStream;
        ContentInStream: InStream;
    begin
        AMCGUID := DelChr(LowerCase(Format(UserSecurityId())), '=', '{}');
        User.SetRange("User Security ID", UserSecurityId());
        if (User.FindFirst()) then begin
            if (User."Full Name" <> '') then
                AMCName := User."Full Name"
            else
                AMCName := User."User Name";

            if (User."Authentication Email" <> '') then
                AMCEmail := User."Authentication Email"
            else
                AMCEmail := User."Contact Email";
        end;

        HeaderHttpRequestMessage.Content().GetHeaders(RequestHttpHeaders);

        if (RequestHttpHeaders.Contains('Amcname')) THEN
            RequestHttpHeaders.Remove('Amcname');

        Clear(TempBlob);
        Clear(ContentOutStream);
        Clear(ContentInStream);
        TempBlob.CreateOutStream(ContentOutStream);
        ContentOutStream.WriteText(AMCName);
        TempBlob.CreateInStream(ContentInStream);
        RequestHttpHeaders.Add('Amcname', Base64Convert.ToBase64(ContentInStream));

        if (RequestHttpHeaders.Contains('Amcemail')) THEN
            RequestHttpHeaders.Remove('Amcemail');

        Clear(TempBlob);
        Clear(ContentOutStream);
        Clear(ContentInStream);
        TempBlob.CreateOutStream(ContentOutStream);
        ContentOutStream.WriteText(AMCEmail);
        TempBlob.CreateInStream(ContentInStream);
        RequestHttpHeaders.Add('Amcemail', Base64Convert.ToBase64(ContentInStream));

        if (RequestHttpHeaders.Contains('Amcguid')) THEN
            RequestHttpHeaders.Remove('Amcguid');

        RequestHttpHeaders.Add('Amcguid', AMCGUID);

    end;

    procedure SendRestRequest(Handled: Boolean; Var RestHttpRequestMessage: HttpRequestMessage; Var HttpResponseMessage: HttpResponseMessage; webCall: Text; AppCaller: text[30]; CheckHttpStatus: Boolean): Boolean;
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        HttpClient: HttpClient;
        RequestHttpContent: HttpContent;
        ProcessingDialog: Dialog;
    begin
        if (Handled) then //Only used for mockup for testautomation
            exit(true);

        AMCBankingSetup.Get();
        if not AMCBankingSetup."AMC Enabled" then
            Error(FeatureConsentErr);

        if GlobalProgressDialogEnabled then
            ProcessingDialog.Open(ProcessingDialogMsg);

        RequestHttpContent := RestHttpRequestMessage.Content();
        LogHttpActivity(webCall, AppCaller, 'Send', '', '', RequestHttpContent, 'ok');
        if GlobalTimeout <= 0 then
            GlobalTimeout := 600000;
        HttpClient.Send(RestHttpRequestMessage, HttpResponseMessage);

        if GlobalProgressDialogEnabled then
            ProcessingDialog.Close();

        if (CheckHttpStatus) then
            exit(CheckHttpCallStatus(webCall, AppCaller, HttpResponseMessage))
        else
            exit(true);
    end;

    [IntegrationEvent(true, false)] //Used for mockup testing
    procedure OnBeforeSendRestRequest(var Handled: Boolean; Var RestHttpRequestMessage: HttpRequestMessage; Var HttpResponseMessage: HttpResponseMessage; webCall: Text; AppCaller: text[30]; CheckHttpStatus: Boolean)
    begin
    end;

    procedure CheckHttpCallStatus(webCall: Text; AppCaller: text[30]; Var HttpResponseMessage: HttpResponseMessage): Boolean;
    var
        Error_Text: Text;
    begin
        if (NOT HttpResponseMessage.IsSuccessStatusCode()) then begin
            Error_Text := TryLoadErrorLbl + StrSubstNo(WebLoadErrorLbl, FORMAT(HttpResponseMessage.HttpStatusCode()) + ' ' + HttpResponseMessage.ReasonPhrase());
            LogHttpActivity(webCall, AppCaller, Error_Text, '', '', HttpResponseMessage.Content(), 'error');
            ERROR(Error_Text);
        end;
        exit(TRUE);
    end;

    procedure GetRestResponse(Var HttpResponseMessage: HttpResponseMessage; Var ResponseTempBlob: Codeunit "Temp Blob")
    var
        ResponseOutStream: OutStream;
        ResponseJSON: Text;
    begin

        HttpResponseMessage.Content().ReadAs(ResponseJSON);

        if (ResponseJSON <> '') then begin
            CLEAR(ResponseTempBlob);
            ResponseTempBlob.CreateOutStream(ResponseOutStream);
            ResponseOutStream.WriteText(ResponseJson)
        end;
    end;

    procedure GetJsonObjectFromBlob(ResponseTempBlob: Codeunit "Temp Blob"; var ReponseJObject: DotNet JObject)
    var
        JSONManagement: Codeunit "JSON Management";
        JSONText: Text;
        JsonInStream: InStream;
    begin
        Clear(ReponseJObject);
        if ResponseTempBlob.HasValue() then begin
            ResponseTempBlob.CreateInStream(JsonInStream);
            JsonInStream.ReadText(JSONText);
            JSONManagement.InitializeFromString(JSONText);
            JSONManagement.GetJSONObject(ReponseJObject);
        end;
    end;


    procedure LogHttpActivity(SoapCall: Text; AppCaller: Text[30]; LogMessage: Text; HintText: Text; SupportUrl: Text; LogHttpContent: HttpContent; ResponseResult: Text) Id: Integer;
    var
        AMCBankingSetup: record "AMC Banking Setup";
        ActivityLog: Record "Activity Log";
        SubActivityLog: Record "Activity Log";
        TempBlob: CodeUnit "Temp Blob";
        RecordVariant: Variant;
        AMCBankWebLogStatus: Enum AMCBankWebLogStatus;
        LogInStream: InStream;
    begin
        AMCBankWebLogStatus := SetWeblogStatus(ResponseResult);
        AMCBankingSetup.Get();
        RecordVariant := AMCBankingSetup;

        if (AMCBankWebLogStatus = AMCBankWebLogStatus::Failed) then
            ActivityLog.LogActivity(RecordVariant, ActivityLog.Status::Failed, AppCaller, SoapCall, LogMessage)
        else
            ActivityLog.LogActivity(RecordVariant, ActivityLog.Status::Success, AppCaller, SoapCall, LogMessage);

        TempBlob.CreateInStream(LogInStream);
        CleanSecureContent(LogHttpContent, LogInStream);
        ActivityLog.SetDetailedInfoFromStream(LogInStream);
        ActivityLog."AMC Bank WebLog Status" := SetWeblogStatus(ResponseResult);
        ActivityLog.Modify();
        COMMIT();
        IF ((HintText <> '') OR (SupportUrl <> '')) THEN BEGIN
            if (AMCBankWebLogStatus = AMCBankWebLogStatus::Failed) then
                SubActivityLog.LogActivity(ActivityLog, SubActivityLog.Status::Failed, AppCaller, HintText, SupportUrl)
            else
                SubActivityLog.LogActivity(ActivityLog, SubActivityLog.Status::Success, AppCaller, HintText, SupportUrl);

            SubActivityLog."AMC Bank WebLog Status" := AMCBankWebLogStatus;
            SubActivityLog.Modify();
            COMMIT();
        END;

        EXIT(ActivityLog.ID);
    end;

    local procedure SetWeblogStatus(reponseResult: Text): ENUM AMCBankWebLogStatus
    begin
        CASE lowerCase(reponseResult) OF
            'ok':
                exit(AMCBankWebLogStatus::Success);
            'warning':
                exit(AMCBankWebLogStatus::Warning);
            'error':
                exit(AMCBankWebLogStatus::Failed);
        END;
        exit(AMCBankWebLogStatus::Failed);
    end;

    local procedure CleanSecureContent(LogHttpContent: HttpContent; var LogInStream: Instream);
    var
        JSONManagement: Codeunit "JSON Management";
        baseHttpContent: HttpContent;
        LogText: Text;
    begin
        LogHttpContent.ReadAs(LogText);
        JSONManagement.InitializeObject(LogText);
        if (JSONManagement.GetValue('modulepassword') <> '') then
            JSONManagement.SetValue('modulepassword', '**********');

        LogText := JSONManagement.WriteObjectToString();
        baseHttpContent.WriteFrom(LogText);
        baseHttpContent.ReadAs(LogInStream);

    end;

    procedure HasResponseErrors(ResponseTempBlob: Codeunit "Temp Blob"; RestCall: Text; JsonErrorKeyName: Text; Var ResponseResult: Text; AppCaller: Text[30]): Boolean;
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        JSONManagement: Codeunit "JSON Management";
        SyslogJSONManagement: Codeunit "JSON Management";
        JObject: DotNet JObject;
        LogId: Integer;
        HttpContent: HttpContent;
        ResponseInStream: InStream;
        SysLogText: Text;
        HintText: Text;
        URLText: Text;
    begin
        //Get result of call
        AMCBankingSetup.GET();

        GetJsonObjectFromBlob(ResponseTempBlob, JObject);
        ResponseTempBlob.CreateInStream(ResponseInStream);

        JSONManagement.InitializeObjectFromJObject(JObject);
        SysLogText := JSONManagement.GetValue(JsonErrorKeyName);

        SyslogJSONManagement.InitializeFromString(SysLogText);
        ResponseResult := lowercase(SyslogJSONManagement.GetValue('syslogtype'));
        if (ResponseResult <> 'ok') then begin

            GLBResponseErrorText := SyslogJSONManagement.GetValue('text');
            HintText := SyslogJSONManagement.GetValue('hinttext');
            URLText := SyslogJSONManagement.GetValue('url');

            HttpContent.WriteFrom(ResponseInStream);
            LogId := LogHttpActivity(RestCall, AppCaller, GLBResponseErrorText, HintText, URLText, HttpContent, ResponseResult);

            if (GLBFromId = 0) then begin
                GLBFromId := LogId;
                GLBToId := LogId;
            end
            else
                GLBToId := LogId;

            if (ResponseResult = 'error') then
                exit(TRUE)
            else
                exit(FALSE);
        end
        else begin
            HttpContent.WriteFrom(ResponseInStream);
            LogHttpActivity(RestCall, AppCaller, ResponseResult, '', '', HttpContent, ResponseResult);
        end;

        EXIT(FALSE);
    end;

    procedure ShowResponseError(ResponseResult: Text);
    var
        AMCBankingSetup: Record "AMC Banking Setup";
        ActivityLog: Record "Activity Log";
        DataTypeManagement: Codeunit "Data Type Management";
        RecordRef: RecordRef;
    begin
        IF (ResponseResult <> 'ok') THEN BEGIN
            IF (GUIALLOWED()) THEN
                IF ((GLBFromId <> 0) OR (GLBToId <> 0)) THEN
                    IF DataTypeManagement.GetRecordRef(AMCBankingSetup, RecordRef) THEN BEGIN
                        ActivityLog.SETRANGE(ActivityLog."Record ID", RecordRef.RECORDID());
                        ActivityLog.SETRANGE(ActivityLog.ID, GLBFromId, GLBToId);
                        PAGE.RUN(PAGE::"AMC Bank Webcall Log", ActivityLog);
                    END;

            if (GLBEnableErrorException) then
                error(GLBResponseErrorText);
        END;
    end;

    internal procedure GetGlobalFromActivityId(): Integer
    begin
        exit(GLBFromId);
    end;

    internal procedure GetGlobalToActivityId(): Integer
    begin
        exit(GLBToId);
    end;


    procedure GetEasyRegistartionURLRestCall(): Text;
    begin
        EXIT('GetEasyRegistartionURL');
    end;


}