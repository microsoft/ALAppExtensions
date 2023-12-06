namespace Microsoft.EServices;

codeunit 13608 "Nemhandel Status Page Bckgrnd"
{
    Access = Internal;

    var
        NemhandelMgt: Codeunit "Nemhandel Status Mgt.";
        EnvironmentBlocksErr: Label 'Environment blocks an outgoing HTTP request to ''%1''.', Comment = '%1 - url, e.g. https://microsoft.com', Locked = true;
        ConnectionErr: Label 'Could not connect to the remote service %1.', Comment = '%1 - url, e.g. https://microsoft.com', Locked = true;
        HttpResponseDetailsTxt: Label 'HTTP response: request URI: %1; Response (part): %2; Status code: %3; Reason: %4', Comment = '%1 - request URI, %2 - response text, %3 - status code, %4 - reason', Locked = true;
        NemhandelsregisteretCategoryTxt: Label 'Nemhandelsregisteret', Locked = true;
        NemhandelCompanyStatusKeyLbl: Label 'NemhandelCompanyStatus', Locked = true;
        CVRNumberKeyLbl: Label 'CVRNumber', Locked = true;

    trigger OnRun()
    var
        InputParams: Dictionary of [Text, Text];
        Results: Dictionary of [Text, Text];
        CompanyStatus: Enum "Nemhandel Company Status";
        CVRNumber: Text;
    begin
        InputParams := Page.GetBackgroundParameters();
        if InputParams.Get(GetCVRNumberKey(), CVRNumber) then;

        // Send request to Nemhandel to determine if the company is registered
        CompanyStatus := GetCompanyStatus(CVRNumber);

        Results.Add(GetStatusKey(), Format(CompanyStatus));
        Page.SetBackgroundTaskResult(Results);
    end;

    procedure GetCompanyStatus(CVRNumber: Text) CompanyStatus: Enum "Nemhandel Company Status"
    var
        HttpClientNemhandel: Interface "Http Client Nemhandel Status";
        HttpResponseMsgNemhandel: Interface "Http Response Msg Nemhandel";
        HttpRequestMessage: HttpRequestMessage;
        HttpRequestURI: Text;
        ResponseCVRNumber: Text;
        ErrorMessage: Text;
        ContentString: Text;
        HttpStatusCode: Integer;
        HttpStatusReason: Text;
        HttpResponseLogMessage: Text;
    begin
        if CVRNumber = '' then
            exit("Nemhandel Company Status"::NotRegistered);

        HttpClientNemhandel := NemhandelMgt.GetHttpClient();
        HttpRequestURI := HttpClientNemhandel.GetRequestURI(CVRNumber);
        if not HttpClientNemhandel.SendGetRequest(HttpRequestURI, HttpRequestMessage, HttpResponseMsgNemhandel) then
            if HttpResponseMsgNemhandel.IsBlockedByEnvironment() then
                ErrorMessage := StrSubstNo(EnvironmentBlocksErr, HttpRequestMessage.GetRequestUri())
            else
                ErrorMessage := StrSubstNo(ConnectionErr, HttpRequestMessage.GetRequestUri());
        if ErrorMessage <> '' then begin
            Session.LogMessage(
                '0000L9W', ErrorMessage, Verbosity::Warning, DataClassification::EndUserIdentifiableInformation,
                TelemetryScope::ExtensionPublisher, 'Category', NemhandelsregisteretCategoryTxt);
            CompanyStatus := "Nemhandel Company Status"::Unknown;
            exit;
        end;

        HttpStatusCode := 0;
        HttpStatusReason := '';
        ProcessHttpResponseMessage(HttpResponseMsgNemhandel, ResponseCVRNumber, ContentString, HttpStatusCode, HttpStatusReason);
        HttpResponseLogMessage :=
            StrSubstNo(HttpResponseDetailsTxt, HttpRequestMessage.GetRequestUri(), CopyStr(ContentString, 1, 50), HttpStatusCode, HttpStatusReason);

        case HttpStatusCode of
            200:
                begin
                    if ResponseCVRNumber.Contains(CVRNumber) then
                        CompanyStatus := "Nemhandel Company Status"::Registered
                    else
                        CompanyStatus := "Nemhandel Company Status"::NotRegistered;
                    Session.LogMessage(
                        '0000L9X', HttpResponseLogMessage, Verbosity::Normal, DataClassification::EndUserIdentifiableInformation,
                        TelemetryScope::ExtensionPublisher, 'Category', NemhandelsregisteretCategoryTxt);
                end;
            404:
                begin
                    CompanyStatus := "Nemhandel Company Status"::NotRegistered;
                    Session.LogMessage(
                        '0000L9Y', HttpResponseLogMessage, Verbosity::Normal, DataClassification::EndUserIdentifiableInformation,
                        TelemetryScope::ExtensionPublisher, 'Category', NemhandelsregisteretCategoryTxt);
                end;
            else begin
                CompanyStatus := "Nemhandel Company Status"::Unknown;
                Session.LogMessage(
                    '0000L9Z', HttpResponseLogMessage, Verbosity::Normal, DataClassification::EndUserIdentifiableInformation,
                    TelemetryScope::ExtensionPublisher, 'Category', NemhandelsregisteretCategoryTxt);
            end;
        end;
    end;

    procedure GetStatusKey(): Text
    begin
        exit(NemhandelCompanyStatusKeyLbl);
    end;

    procedure GetCVRNumberKey(): Text
    begin
        exit(CVRNumberKeyLbl);
    end;

    procedure SetHttpClient(HttpClientNemhandel: Interface "Http Client Nemhandel Status")
    begin
        NemhandelMgt.SetHttpClient(HttpClientNemhandel);
    end;

    local procedure ProcessHttpResponseMessage(HttpResponseMsgNemhandel: Interface "Http Response Msg Nemhandel"; var ResponseCVRNumber: Text; var ContentString: Text; var HttpStatusCode: Integer; var HttpStatusReason: Text)
    var
        Result: Boolean;
        ContentJson: JsonObject;
        CVRNumberToken: JsonToken;
    begin
        Result := HttpResponseMsgNemhandel.IsSuccessStatusCode();
        HttpStatusCode := HttpResponseMsgNemhandel.HttpStatusCode();
        HttpStatusReason := HttpResponseMsgNemhandel.ReasonPhrase();

        if not Result then
            exit;

        ContentString := HttpResponseMsgNemhandel.GetResponseBodyAsText();

        ContentJson := HttpResponseMsgNemhandel.GetResponseBody();
        if ContentJson.Get('cvrNummer', CVRNumberToken) then
            if CVRNumberToken.WriteTo(ResponseCVRNumber) then;
    end;
}