codeunit 1164 "COHUB API Request"
{
    Access = Internal;

    var
        ErrorAcquiringTokenTxt: Label 'Could not get an access token. This is required to get the data from the companies in Dynamics 365. Enviroment name:  %1', Locked = true;
        ActivityCuesSuffixParmsTxt: Label '/AccountantPortalActivityCues', Locked = true;
        FinanceCuesSuffixParmsTxt: Label '/AccountantPortalFinanceCues', Locked = true;
        UserTasksSuffixParmsTxt: Label '/AccountantPortalUserTasks', Locked = true;
        UserTaskCompleteLbl: Label '/UserTaskSetComplete(%1)/NAV.SetComplete', Locked = true;


    trigger OnRun()
    begin

    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    procedure InvokePostUserTaskComplete(var COHUBCompanyEndpoint: Record "COHUB Company Endpoint"; var APIResponse: Text; TaskId: Integer): Boolean
    var
        COHUBEnviroment: Record "COHUB Enviroment";
        COHUBCore: Codeunit "COHUB Core";
        CompanyEndpointRecordRef: RecordRef;
        EntityBaseUrl: Text;
        AccessToken: Text;
        EnvironmentName: Text;
        EnvironmentNameAndEnvironment: Text;
        UserTaskUrl: Text;
    begin
        EntityBaseUrl := GetEntityBaseUrl(COHUBCompanyEndpoint);
        CompanyEndpointRecordRef.GetTable(COHUBCompanyEndpoint);
        UserTaskUrl := EntityBaseUrl + StrSubstNo(UserTaskCompleteLbl, TaskId);

        COHUBEnviroment.Get(COHUBCompanyEndpoint."Enviroment No.");
        COHUBCore.GetEnviromentNameAndEnviroment(COHUBEnviroment, EnvironmentName, EnvironmentNameAndEnvironment);

        if not GetGuestAccessToken(COHUBCore.GetResourceUrl(), EnvironmentName, AccessToken, CompanyEndpointRecordRef) then
            exit(false);

        exit(InvokeSecuredWebApiPostRequest(UserTaskUrl, AccessToken, APIResponse, CompanyEndpointRecordRef))
    end;


    [Scope('OnPrem')]
    [NonDebuggable]
    procedure InvokeGetCompanies(var COHUBEnviroment: Record "COHUB Enviroment"; var APIResponse: Text; var CompanyAPIUrl: Text): Boolean
    var
        COHUBCore: Codeunit "COHUB Core";
        COHUBEnvironmentRecordRef: RecordRef;
        AccessToken: Text;
        EnvironmentName: Text;
        EnvironmentNameAndEnvirnoment: Text;
        ResourceUrl: Text;
    begin
        COHUBEnvironmentRecordRef.GetTable(COHUBEnviroment);
        ResourceUrl := COHUBCore.GetResourceUrl();
        COHUBCore.GetEnviromentNameAndEnviroment(COHUBEnviroment, EnvironmentName, EnvironmentNameAndEnvirnoment);
        CompanyAPIUrl := COHUBCore.GetFixedWebServicesUrl() + 'v2.0/' + EnvironmentNameAndEnvirnoment + '/ODataV4/Company';
        if not GetGuestAccessToken(ResourceUrl, EnvironmentName, AccessToken, COHUBEnvironmentRecordRef) then
            exit(false);

        exit(InvokeSecuredWebApiGetRequest(CompanyAPIUrl, AccessToken, APIResponse, COHUBEnvironmentRecordRef));
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    procedure InvokeActivityCuesAPI(var COHUBCompanyEndpoint: Record "COHUB Company Endpoint"; var APIResponse: Text): Boolean
    begin
        exit(InvokeAPI(COHUBCompanyEndpoint, ActivityCuesSuffixParmsTxt, APIResponse));
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    procedure InvokeFinanceCuesAPI(var COHUBCompanyEndpoint: Record "COHUB Company Endpoint"; var APIResponse: Text): Boolean
    begin
        exit(InvokeAPI(COHUBCompanyEndpoint, FinanceCuesSuffixParmsTxt, APIResponse));
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    procedure InvokeUserTasksAPI(var COHUBCompanyEndpoint: Record "COHUB Company Endpoint"; var APIResponse: Text): Boolean
    begin
        exit(InvokeAPI(COHUBCompanyEndpoint, UserTasksSuffixParmsTxt, APIResponse));
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    local procedure InvokeAPI(var COHUBCompanyEndpoint: Record "COHUB Company Endpoint"; CueAPISuffix: Text; var APIResponse: Text): Boolean
    var
        COHUBEnviroment: Record "COHUB Enviroment";
        COHUBCore: Codeunit "COHUB Core";
        COHUBCompanyEndpointRecordRef: RecordRef;
        EntityBaseUrl: Text;
        CuesAPIUrl: Text;
        AccessToken: Text;
        EnvironmentName: Text;
        EnvironmentNameAndEnvironment: Text;
    begin
        EntityBaseUrl := GetEntityBaseUrl(COHUBCompanyEndpoint);
        COHUBCompanyEndpointRecordRef.GetTable(COHUBCompanyEndpoint);
        CuesAPIUrl := EntityBaseUrl + CueAPISuffix;

        COHUBEnviroment.Get(COHUBCompanyEndpoint."Enviroment No.");
        COHUBCore.GetEnviromentNameAndEnviroment(COHUBEnviroment, EnvironmentName, EnvironmentNameAndEnvironment);

        if not GetGuestAccessToken(COHUBCore.GetResourceUrl(), EnvironmentName, AccessToken, COHUBCompanyEndpointRecordRef) then
            exit(false);

        exit(InvokeSecuredWebApiGetRequest(CuesAPIUrl, AccessToken, APIResponse, COHUBCompanyEndpointRecordRef));
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    local procedure InvokeSecuredWebApiGetRequest(Url: Text; AccessToken: Text; var ResponseContent: Text; SourceRecordRef: RecordRef): Boolean;
    var
        RequestHttpClient: HttpClient;
    begin
        GetHttpClient(RequestHttpClient);
        RequestHttpClient.DefaultRequestHeaders().Add('Authorization', 'Bearer ' + AccessToken);
        exit(InvokeWebApiGetRequestAndLogErrors(RequestHttpClient, Url, ResponseContent, SourceRecordRef));
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    local procedure InvokeSecuredWebApiPostRequest(Url: Text; AccessToken: Text; var ResponseContent: Text; SourceRecordRef: RecordRef): Boolean;
    var
        RequestHttpClient: HttpClient;
    begin
        GetHttpClient(RequestHttpClient);
        RequestHttpClient.DefaultRequestHeaders().Add('Authorization', 'Bearer ' + AccessToken);
        exit(InvokeWebApiPostRequestAndLogErrors(RequestHttpClient, Url, ResponseContent, SourceRecordRef));
    end;

    [Scope('OnPrem')]
    [NonDebuggable]

    local procedure TryInvokeWebApiGetRequest(WebRequestHttpClient: HttpClient; Url: Text; var ResponseContent: Text; var WasSuccessful: Boolean): Boolean;
    var
        WebHttpResponseMessage: HttpResponseMessage;
        IsGetSuccess: Boolean;
    begin
        IsGetSuccess := WebRequestHttpClient.Get(Url, WebHttpResponseMessage);
        if IsGetSuccess then begin
            WebHttpResponseMessage.Content().ReadAs(ResponseContent);
            WasSuccessful := WebHttpResponseMessage.IsSuccessStatusCode();
        end;

        exit(IsGetSuccess);
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    local procedure TryInvokeWebApiPostRequest(WebRequestHttpClient: HttpClient; Url: Text; var ResponseContent: Text; var WasSuccessful: Boolean): Boolean;
    var
        WebHttpRequestMessage: HttpRequestMessage;
        WebHttpContent: HttpContent;
        ContentHeaders: HttpHeaders;
        WebRequestHttpResponseMessage: HttpResponseMessage;
        WasRequestSuccessful: Boolean;
    begin
        WebHttpContent.GetHeaders(ContentHeaders);
        WebHttpContent.Clear();
        ContentHeaders.Clear();
        ContentHeaders.Add('Content-Type', 'application/json');
        WebHttpRequestMessage.Method('POST');
        WebHttpRequestMessage.SetRequestUri(Url);
        WasRequestSuccessful := WebRequestHttpClient.Send(WebHttpRequestMessage, WebRequestHttpResponseMessage);

        if WasRequestSuccessful then begin
            WebRequestHttpResponseMessage.Content().ReadAs(ResponseContent);
            WasSuccessful := WebRequestHttpResponseMessage.IsSuccessStatusCode();
        end;

        exit(WasRequestSuccessful);
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    local procedure InvokeWebApiGetRequestAndLogErrors(WebRequestHttpClient: HttpClient; Url: Text; var ResponseContent: Text; SourceRecordRef: RecordRef): Boolean;
    var
        COHUBCore: Codeunit "COHUB Core";
        WasSuccessful: Boolean;
    begin
        if TryInvokeWebApiGetRequest(WebRequestHttpClient, Url, ResponseContent, WasSuccessful) then
            if WasSuccessful then
                exit(true)
            else
                COHUBCore.LogFailure(ResponseContent, SourceRecordRef)
        else begin
            COHUBCore.LogFailure(GetLastErrorText(), SourceRecordRef);
            ClearLastError();
        end;

        exit(false);
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    local procedure InvokeWebApiPostRequestAndLogErrors(WebRequestHttpClient: HttpClient; Url: Text; var ResponseContent: Text; SourceRecordRef: RecordRef): Boolean;
    var
        COHUBCore: Codeunit "COHUB Core";
        WasSuccessful: Boolean;
    begin
        if TryInvokeWebApiPostRequest(WebRequestHttpClient, Url, ResponseContent, WasSuccessful) then
            if WasSuccessful then
                exit(true)
            else
                COHUBCore.LogFailure(ResponseContent, SourceRecordRef)
        else begin
            COHUBCore.LogFailure(GetLastErrorText(), SourceRecordRef);
            ClearLastError();
        end;

        exit(false);
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    local procedure GetHttpClient(var WebRequestHttpClient: HttpClient)
    begin
        WebRequestHttpClient.DefaultRequestHeaders().Clear();
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    local procedure GetEntityBaseUrl(var COHUBCompanyEndpoint: Record "COHUB Company Endpoint"): Text;
    var
        CompanyName: Text;
        EntityBaseUrl: Text;
    begin
        CompanyName := COHUBCompanyEndpoint."Company Name";
        CompanyName := CompanyName.Replace('''', '''''');
        EntityBaseUrl := COHUBCompanyEndpoint."ODATA Company URL" + '(''' + CompanyName + ''')';

        exit(EntityBaseUrl);
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    local procedure GetGuestAccessToken(ResourceUrl: Text; EnvironmentName: Text; var AccessToken: Text; SourceRecordRef: RecordRef): Boolean
    var
        AzureADMgt: Codeunit "Azure AD Mgt.";
        COHUBCore: Codeunit "COHUB Core";
    begin
        AccessToken := AzureADMgt.GetGuestAccessToken(ResourceUrl, EnvironmentName);
        if AccessToken = '' then begin
            COHUBCore.LogFailure(StrSubstNo(ErrorAcquiringTokenTxt, EnvironmentName), SourceRecordRef);
            exit(false);
        end;

        exit(true);
    end;
}