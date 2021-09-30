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
        RecRef: RecordRef;
        EntityBaseUrl: Text;
        AccessToken: Text;
        EnvironmentName: Text;
        EnvironmentNameAndEnvironment: Text;
        UserTaskUrl: Text;
    begin
        EntityBaseUrl := GetEntityBaseUrl(COHUBCompanyEndpoint);
        RecRef.GetTable(COHUBCompanyEndpoint);
        UserTaskUrl := EntityBaseUrl + StrSubstNo(UserTaskCompleteLbl, TaskId);

        COHUBEnviroment.Get(COHUBCompanyEndpoint."Enviroment No.");
        COHUBCore.GetEnviromentNameAndEnviroment(COHUBEnviroment, EnvironmentName, EnvironmentNameAndEnvironment);

        if not GetGuestAccessToken(COHUBCore.GetResourceUrl(), EnvironmentName, AccessToken, RecRef) then
            exit(false);

        exit(InvokeSecuredWebApiPostRequest(UserTaskUrl, AccessToken, APIResponse, RecRef))
    end;


    [Scope('OnPrem')]
    [NonDebuggable]
    procedure InvokeGetCompanies(var COHUBEnviroment: Record "COHUB Enviroment"; var APIResponse: Text; var CompanyAPIUrl: Text): Boolean
    var
        COHUBCore: Codeunit "COHUB Core";
        RecRef: RecordRef;
        AccessToken: Text;
        EnvironmentName: Text;
        EnvironmentNameAndEnvirnoment: Text;
        ResourceUrl: Text;
    begin
        RecRef.GetTable(COHUBEnviroment);
        ResourceUrl := COHUBCore.GetResourceUrl();
        COHUBCore.GetEnviromentNameAndEnviroment(COHUBEnviroment, EnvironmentName, EnvironmentNameAndEnvirnoment);
        CompanyAPIUrl := COHUBCore.GetFixedWebServicesUrl() + 'v2.0/' + EnvironmentNameAndEnvirnoment + '/ODataV4/Company';
        if not GetGuestAccessToken(ResourceUrl, EnvironmentName, AccessToken, RecRef) then
            exit(false);

        exit(InvokeSecuredWebApiGetRequest(CompanyAPIUrl, AccessToken, APIResponse, RecRef));
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
        RecRef: RecordRef;
        EntityBaseUrl: Text;
        CuesAPIUrl: Text;
        AccessToken: Text;
        EnvironmentName: Text;
        EnvironmentNameAndEnvironment: Text;
    begin
        EntityBaseUrl := GetEntityBaseUrl(COHUBCompanyEndpoint);
        RecRef.GetTable(COHUBCompanyEndpoint);
        CuesAPIUrl := EntityBaseUrl + CueAPISuffix;

        COHUBEnviroment.Get(COHUBCompanyEndpoint."Enviroment No.");
        COHUBCore.GetEnviromentNameAndEnviroment(COHUBEnviroment, EnvironmentName, EnvironmentNameAndEnvironment);

        if not GetGuestAccessToken(COHUBCore.GetResourceUrl(), EnvironmentName, AccessToken, RecRef) then
            exit(false);

        exit(InvokeSecuredWebApiGetRequest(CuesAPIUrl, AccessToken, APIResponse, RecRef));
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    local procedure InvokeSecuredWebApiGetRequest(Url: Text; AccessToken: Text; var ResponseContent: Text; RecRef: RecordRef): Boolean;
    var
        Client: HttpClient;
    begin
        GetHttpClient(Client);
        Client.DefaultRequestHeaders().Add('Authorization', 'Bearer ' + AccessToken);
        exit(InvokeWebApiGetRequestAndLogErrors(Client, Url, ResponseContent, RecRef));
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    local procedure InvokeSecuredWebApiPostRequest(Url: Text; AccessToken: Text; var ResponseContent: Text; RecRef: RecordRef): Boolean;
    var
        Client: HttpClient;
    begin
        GetHttpClient(Client);
        Client.DefaultRequestHeaders().Add('Authorization', 'Bearer ' + AccessToken);
        exit(InvokeWebApiPostRequestAndLogErrors(Client, Url, ResponseContent, RecRef));
    end;

    [Scope('OnPrem')]
    [NonDebuggable]

    local procedure TryInvokeWebApiGetRequest(Client: HttpClient; Url: Text; var ResponseContent: Text; var WasSuccessful: Boolean): Boolean;
    var
        HttpResponse: HttpResponseMessage;
        IsGetSuccess: Boolean;
    begin
        IsGetSuccess := Client.Get(Url, HttpResponse);
        if IsGetSuccess then begin
            HttpResponse.Content().ReadAs(ResponseContent);
            WasSuccessful := HttpResponse.IsSuccessStatusCode();
        end;

        exit(IsGetSuccess);
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    local procedure TryInvokeWebApiPostRequest(Client: HttpClient; Url: Text; var ResponseContent: Text; var WasSuccessful: Boolean): Boolean;
    var
        Request: HttpRequestMessage;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        HttpResponse: HttpResponseMessage;
        WasRequestSuccessful: Boolean;
    begin
        Content.GetHeaders(ContentHeaders);
        Content.Clear();
        ContentHeaders.Clear();
        ContentHeaders.Add('Content-Type', 'application/json');
        Request.Method('POST');
        Request.SetRequestUri(Url);
        WasRequestSuccessful := Client.Send(Request, HttpResponse);

        if WasRequestSuccessful then begin
            HttpResponse.Content().ReadAs(ResponseContent);
            WasSuccessful := HttpResponse.IsSuccessStatusCode();
        end;

        exit(WasRequestSuccessful);
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    local procedure InvokeWebApiGetRequestAndLogErrors(Client: HttpClient; Url: Text; var ResponseContent: Text; RecRef: RecordRef): Boolean;
    var
        COHUBCore: Codeunit "COHUB Core";
        WasSuccessful: Boolean;
    begin
        if TryInvokeWebApiGetRequest(Client, Url, ResponseContent, WasSuccessful) then
            if WasSuccessful then
                exit(true)
            else
                COHUBCore.LogFailure(ResponseContent, RecRef)
        else begin
            COHUBCore.LogFailure(GetLastErrorText(), RecRef);
            ClearLastError();
        end;

        exit(false);
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    local procedure InvokeWebApiPostRequestAndLogErrors(Client: HttpClient; Url: Text; var ResponseContent: Text; RecRef: RecordRef): Boolean;
    var
        COHUBCore: Codeunit "COHUB Core";
        WasSuccessful: Boolean;
    begin
        if TryInvokeWebApiPostRequest(Client, Url, ResponseContent, WasSuccessful) then
            if WasSuccessful then
                exit(true)
            else
                COHUBCore.LogFailure(ResponseContent, RecRef)
        else begin
            COHUBCore.LogFailure(GetLastErrorText(), RecRef);
            ClearLastError();
        end;

        exit(false);
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    local procedure GetHttpClient(var Client: HttpClient)
    begin
        Client.DefaultRequestHeaders().Clear();
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    local procedure GetEntityBaseUrl(var EnviromentCompanyEndpoint: Record "COHUB Company Endpoint"): Text;
    var
        CompanyName: Text;
        EntityBaseUrl: Text;
    begin
        CompanyName := EnviromentCompanyEndpoint."Company Name";
        CompanyName := CompanyName.Replace('''', '''''');
        EntityBaseUrl := EnviromentCompanyEndpoint."ODATA Company URL" + '(''' + CompanyName + ''')';

        exit(EntityBaseUrl);
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    local procedure GetGuestAccessToken(ResourceUrl: Text; EnvironmentName: Text; var AccessToken: Text; RecRef: RecordRef): Boolean
    var
        AzureADMgt: Codeunit "Azure AD Mgt.";
        COHUBCore: Codeunit "COHUB Core";
    begin
        AccessToken := AzureADMgt.GetGuestAccessToken(ResourceUrl, EnvironmentName);
        if AccessToken = '' then begin
            COHUBCore.LogFailure(StrSubstNo(ErrorAcquiringTokenTxt, EnvironmentName), RecRef);
            exit(false);
        end;

        exit(true);
    end;
}