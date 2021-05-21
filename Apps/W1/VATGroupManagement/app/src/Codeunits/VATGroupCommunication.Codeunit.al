codeunit 4700 "VAT Group Communication"
{
    var
        VATReportSetup: Record "VAT Report Setup";
        NoVATSetupErr: Label 'The VAT Report Setup could not be found.';
        BearerTokenFromCacheErr: Label 'The Bearer token could not be retrieved from cache. Please refresh the VAT Group bearer token by logging in the %1 page', Comment = '%1 the caption of a page.';
        OAuthFailedNoErr: label 'Authorization has failed with an unexpected error.';
        OAuthFailedErr: Label 'Authorization has failed with the error %1', Comment = '%1 is the error description.';
        URLAppendixCompanyLbl: Label '/api/microsoft/vatgroup/v1.0/companies(name=''%1'')', Locked = true;
        URLAppendixLbl: Label '/api/microsoft/vatgroup/v1.0', Locked = true;
        URLAppendixCompany2018Lbl: Label '/api/v1.0/companies(name=''%1'')', Locked = true;
        URLAppendix2018Lbl: Label '/api/v1.0', Locked = true;
        URLAppendixCompany2017Lbl: Label '/OData/Company(''%1'')', Locked = true;
        URLAppendix2017Lbl: Label '/OData', Locked = true;
        VATGroupSubmissionStatusEndpointTxt: Label '/vatGroupSubmissionStatus?$filter=no eq ''%1'' and groupMemberId eq %2&$select=no,status', Locked = true;
        VATGroupSubmissionStatusEndpoint2017Txt: Label '/vatGroupSubmissionStatus?$filter=no eq ''%1'' and groupMemberId eq (guid''%2'')&$select=no,status&$format=json', Locked = true;
        InvalidSyntaxErr: Label 'Bad Request: the server could not understand the request due to invalid syntax.'; // 400
        UnauthorizedErr: Label 'Unauthorized: authentication credentials are not valid.'; // 401
        ForbiddenErr: Label 'Forbidden: missing permissions to access the requested resource.'; // 403
        NotFoundErr: Label 'Not Found: cannot locate the requested resource.'; // 404 
        InternalServerErrorErr: Label 'Internal Server Error: the server cannot process the request.'; // 500
        ServiceUnavailableErr: Label 'Service Unavailable: the server is not available, try again later.'; // 503
        GeneralHttpErr: Label 'Something went wrong, try again later.';
        // Telemetry
        VATGroupTok: Label 'VATGroupTelemetryCategoryTok', Locked = true;
        HttpSuccessMsg: Label 'The http request was successful and the resource was created', Locked = true;
        BearerTokenSuccessMsg: Label 'The OAuth2 authentication was successfull, a token has been issued.', Locked = true;
        HttpErrorMsg: Label 'Error Code: %1, Error Msg: %2', Locked = true;
        OAuthAuthorityUrlTxt: Label 'https://login.microsoftonline.com/common/oauth2', Locked = true;
        BCResourceURLTxt: Label 'https://api.businesscentral.dynamics.com', Locked = true;
        BCReadWriteScopeTok: Label '/Financials.ReadWrite.All', Locked = true;
        BCUserImpersonationScopeTok: Label '/user_impersonation', Locked = true;
        AuthTokenOrCodeNotReceivedErr: Label 'No access token or authorization error code received.', Locked = true;
        VATGroupClientIdAKVSecretNameLbl: Label 'vatgroup-clientid', Locked = true;
        VATGroupClientSecretAKVSecretNameLbl: Label 'vatgroup-clientsecret', Locked = true;
        MissingClientIdOrSecretTelemetryTxt: Label 'The Client Id or Client Secret could not be retrieved from Azure Key Vault.', Locked = true;
        VATReportSetupIsLoaded: Boolean;

    [TryFunction]
    internal procedure Send(Method: Text; Endpoint: Text; Content: Text; var HttpResponseBodyText: Text; IsBatch: Boolean)
    var
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
    begin
        CheckLoadVATReportSetup();

        HttpRequestMessage.Method(Method);
        if IsBatch then
            HttpRequestMessage.SetRequestUri(PrepareBatchURI(Endpoint))
        else
            HttpRequestMessage.SetRequestUri(PrepareURI(Endpoint));
        PrepareHeaders(HttpRequestMessage, IsBatch);
        PrepareContent(HttpRequestMessage, Content);

        if VATReportSetup."Authentication Type" = VATReportSetup."Authentication Type"::WindowsAuthentication then
            HttpClient.UseDefaultNetworkWindowsAuthentication();

        HttpClient.Send(HttpRequestMessage, HttpResponseMessage);
        HttpResponseMessage.Content().ReadAs(HttpResponseBodyText);
        HandleHttpResponse(HttpResponseMessage);
    end;

    local procedure HandleHttpResponse(HttpResponseMessage: HttpResponseMessage)
    var
        FriendlyErrorMsg, ErrorMsg : Text;
    begin
        case HttpResponseMessage.HttpStatusCode() of
            200:
                begin
                    Session.LogMessage('0000D7D', HttpSuccessMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', VATGroupTok);
                    exit;
                end;
            201:
                begin
                    Session.LogMessage('0000DAE', HttpSuccessMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', VATGroupTok);
                    exit;
                end;
            400:
                FriendlyErrorMsg := InvalidSyntaxErr;
            401:
                FriendlyErrorMsg := UnauthorizedErr;
            403:
                FriendlyErrorMsg := ForbiddenErr;
            404:
                FriendlyErrorMsg := NotFoundErr;
            500:
                FriendlyErrorMsg := InternalServerErrorErr;
            503:
                FriendlyErrorMsg := ServiceUnavailableErr;
            else
                FriendlyErrorMsg := GeneralHttpErr;
        end;

        HttpResponseMessage.Content().ReadAs(ErrorMsg);
        Session.LogMessage('0000D7E', StrSubstNo(HttpErrorMsg, HttpResponseMessage.HttpStatusCode(), ErrorMsg), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', VATGroupTok);
        Error(FriendlyErrorMsg);
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    internal procedure GetBearerToken(ClientId: Text; ClientSecret: Text; AuthorityURL: Text; RedirectURL: Text; ResourceURL: Text)
    var
        OAuth2: Codeunit OAuth2;
        EnvironmentInformation: Codeunit "Environment Information";
        PromptInteraction: Enum "Prompt Interaction";
        Scopes: List of [Text];
        BearerToken, AuthError : Text;
    begin
        if not VATReportSetup.Get() then
            Error(NoVATSetupErr);

        if EnvironmentInformation.IsSaaSInfrastructure() and VATReportSetup."Group Representative On SaaS" then begin
            GetClientIDAndSecretFromAKV(ClientId, ClientSecret);
            AuthorityURL := OAuthAuthorityUrlTxt;
            RedirectURL := '';                     //empty is the default BCOnline redirect URI.
            ResourceURL := BCResourceURLTxt;
        end;

        CreateScopesFromResourceURL(ResourceURL, Scopes);
        OAuth2.AcquireTokenByAuthorizationCode(ClientId,
            ClientSecret,
            AuthorityURL,
            RedirectURL,
            Scopes,
            PromptInteraction::Login,
            BearerToken,
            AuthError);

        if BearerToken <> '' then begin
            Message(BearerTokenSuccessMsg);
            exit;
        end;

        if AuthError = '' then begin
            Session.LogMessage('0000DJK', AuthTokenOrCodeNotReceivedErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', VATGroupTok);
            Error(OAuthFailedNoErr);
        end else begin
            Session.LogMessage('0000DJL', AuthError, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', VATGroupTok);
            Error((StrSubstNo(OAuthFailedErr, AuthError)));
        end;
    end;

    [NonDebuggable]
    local procedure GetBearerTokenFromCache(): Text
    var
        OAuth2: Codeunit OAuth2;
        EnvironmentInformation: Codeunit "Environment Information";
        VATReportSetupPage: Page "VAT Report Setup";
        Scopes: List of [Text];
        BearerToken: Text;
        AKVClientId: Text;
        AKVClientSecret: Text;
    begin
        if not VATReportSetup.Get() then
            Error(NoVATSetupErr);

        if EnvironmentInformation.IsSaaSInfrastructure() and VATReportSetup."Group Representative On SaaS" then begin
            GetClientIDAndSecretFromAKV(AKVClientId, AKVClientSecret);
            CreateScopesFromResourceURL(BCResourceURLTxt, Scopes);
            OAuth2.AcquireAuthorizationCodeTokenFromCache(AKVClientId,
                AKVClientSecret,
                '',                     //empty is the default BCOnline redirect URI.
                OAuthAuthorityUrlTxt,
                Scopes,
                BearerToken)
        end else begin
            CreateScopesFromResourceURL(VATReportSetup."Resource URL", Scopes);
            OAuth2.AcquireAuthorizationCodeTokenFromCache(VATReportSetup.GetSecret(VATReportSetup."Client ID Key"),
                VATReportSetup.GetSecret(VATReportSetup."Client Secret Key"),
                VATReportSetup."Redirect URL",
                VATReportSetup."Authority URL",
                Scopes,
                BearerToken);
        end;

        if BearerToken = '' then
            Error(BearerTokenFromCacheErr, VATReportSetupPage.Caption());

        exit(BearerToken);
    end;

    [NonDebuggable]
    local procedure PrepareHeaders(HttpRequestMessage: HttpRequestMessage; IsBatch: Boolean)
    var
        Base64Convert: Codeunit "Base64 Convert";
        HttpRequestHeaders: HttpHeaders;
        Base64AuthHeader: Text;
    begin
        HttpRequestMessage.GetHeaders(HttpRequestHeaders);

        HttpRequestHeaders.Add('Accept', 'application/json');

        if VATReportSetup."Authentication Type" = VATReportSetup."Authentication Type"::WebServiceAccessKey then begin
            Base64AuthHeader := Base64Convert.ToBase64(VATReportSetup.GetSecret(VATReportSetup."User Name Key") + ':' + VATReportSetup.GetSecret(VATReportSetup."Web Service Access Key Key"));
            HttpRequestHeaders.Add('Authorization', 'Basic ' + Base64AuthHeader);
        end;

        if VATReportSetup."Authentication Type" = VATReportSetup."Authentication Type"::OAuth2 then
            HttpRequestHeaders.Add('Authorization', 'Bearer ' + GetBearerTokenFromCache());

        if IsBatch then
            HttpRequestHeaders.Add('Prefer', 'odata.continue-on-error');
    end;

    local procedure PrepareContent(HttpRequestMessage: HttpRequestMessage; Content: Text)
    var
        HttpContent: HttpContent;
        HttpContentHeaders: HttpHeaders;
    begin
        if Content = '' then
            exit;

        HttpContent.GetHeaders(HttpContentHeaders);
        HttpContent.WriteFrom(Content);
        HttpContentHeaders.Remove('Content-Type');
        HttpContentHeaders.Add('Content-Type', 'application/json');
        HttpRequestMessage.Content(HttpContent);
    end;

    [NonDebuggable]
    local procedure GetClientIDAndSecretFromAKV(var ClientId: Text; var ClientSecret: Text)
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret(VATGroupClientIdAKVSecretNameLbl, ClientId) then
            Session.LogMessage('0000DJM', MissingClientIdOrSecretTelemetryTxt, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', VATGroupTok);

        if not AzureKeyVault.GetAzureKeyVaultSecret(VATGroupClientSecretAKVSecretNameLbl, ClientSecret) then
            Session.LogMessage('0000DJN', MissingClientIdOrSecretTelemetryTxt, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', VATGroupTok);
    end;

    internal procedure PrepareURI(Endpoint: Text) Result: Text
    begin
        CheckLoadVATReportSetup();
        Result := VATReportSetup."Group Representative API URL";
        CASE VATReportSetup."VAT Group BC Version" OF
            VATReportSetup."VAT Group BC Version"::BC:
                Result += StrSubstNo(URLAppendixCompanyLbl, VATReportSetup."Group Representative Company");
            VATReportSetup."VAT Group BC Version"::NAV2018:
                Result += StrSubstNo(URLAppendixCompany2018Lbl, VATReportSetup."Group Representative Company");
            VATReportSetup."VAT Group BC Version"::NAV2017:
                Result += StrSubstNo(URLAppendixCompany2017Lbl, VATReportSetup."Group Representative Company");
        END;
        Result += Endpoint;
    end;

    internal procedure GetVATGroupSubmissionStatusEndpoint(): Text
    begin
        CheckLoadVATReportSetup();
        case VATReportSetup."VAT Group BC Version" of
            VATReportSetup."VAT Group BC Version"::BC,
            VATReportSetup."VAT Group BC Version"::NAV2018:
                exit(VATGroupSubmissionStatusEndpointTxt);
            VATReportSetup."VAT Group BC Version"::NAV2017:
                exit(VATGroupSubmissionStatusEndpoint2017Txt);
        end;
    end;

    local procedure PrepareBatchURI(Endpoint: Text) Result: Text
    begin
        Result := VATReportSetup."Group Representative API URL";
        case VATReportSetup."VAT Group BC Version" of
            VATReportSetup."VAT Group BC Version"::BC:
                Result += URLAppendixLbl;
            VATReportSetup."VAT Group BC Version"::NAV2018:
                Result += URLAppendix2018Lbl;
            VATReportSetup."VAT Group BC Version"::NAV2017:
                Result += URLAppendix2017Lbl;
        end;
        Result += Endpoint;
    end;

    local procedure CheckLoadVATReportSetup()
    begin
        if not VATReportSetupIsLoaded then begin
            if not VATReportSetup.Get() then
                Error(NoVATSetupErr);
            VATReportSetupIsLoaded := true;
        end;
    end;

    local procedure CreateScopesFromResourceURL(ResourceURL: Text; var Scopes: List of [Text])
    begin
        Scopes.Add(ResourceURL + BCReadWriteScopeTok);
        Scopes.Add(ResourceURL + BCUserImpersonationScopeTok);
    end;
}