// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
///  Provides helper functionality related to Graph Api
/// </summary>
codeunit 2752 "Universal Print Graph Helper"
{
    /// <summary>
    /// Retrieves the list of user print shares.
    /// </summary>
    [Scope('OnPrem')]
    procedure GetPrintSharesList(var PrintShares: JsonArray; var ErrorMessage: Text): Boolean
    var
        PrintShareJsonObject: JsonObject;
        PrintShareJsonArrayToken: JsonToken;
        ResponseContent: Text;
    begin
        if not InvokeRequest(GetGraphPrintSharesUrl(), 'GET', '', ResponseContent, ErrorMessage) then
            exit(false);

        if not PrintShareJsonObject.ReadFrom(ResponseContent) then
            exit(false);

        if not PrintShareJsonObject.SelectToken('value', PrintShareJsonArrayToken) then
            exit(false);

        if not PrintShareJsonArrayToken.IsArray() then
            exit(false);

        PrintShares := PrintShareJsonArrayToken.AsArray();
        exit(true);
    end;

    /// <summary>
    /// Retrieves the user print share.
    /// </summary>
    [Scope('OnPrem')]
    procedure GetPrintShare(ID: Guid; var PrintShare: JsonObject; var ErrorMessage: Text): Boolean
    var
        ResponseContent: Text;
    begin
        if not InvokeRequest(GetGraphPrintShareSelectUrl(ID), 'GET', '', ResponseContent, ErrorMessage) then
            exit(false);

        if not PrintShare.ReadFrom(ResponseContent) then
            exit(false);

        exit(true);
    end;

    /// <summary>
    /// Retrieves whether the user has license and access.
    /// </summary>
    [Scope('OnPrem')]
    procedure CheckLicense(): Boolean
    var
        ResponseContent: Text;
        ErrorMessage: Text;
        StatusCode: DotNet HttpStatusCode;
    begin
        if InvokeRequest(GetGraphPrintSharesUrl(), 'GET', '', ResponseContent, ErrorMessage, StatusCode) then
            exit(true);

        if not IsNull(StatusCode) then
            exit(not (StatusCode in [401, 403, 404]));

        exit(false);
    end;

    [Scope('OnPrem')]
    procedure CreatePrintJobRequest(UniversalPrinterSettings: Record "Universal Printer Settings"; var JobId: Text; var DocumentId: Text; var ErrorMessage: Text): Boolean
    var
        ResponseJsonObject: JsonObject;
        BodyJsonObject: JsonObject;
        BodyConfigJsonObject: JsonObject;
        DocumentsJsonToken: JsonToken;
        Documents: JsonArray;
        DocumentJsonToken: JsonToken;
        FirstDocument: JsonObject;
        ResponseContent: Text;
    begin
        BodyConfigJsonObject.Add('outputBin', UniversalPrinterSettings."Paper Tray");
        if UniversalPrinterSettings.Landscape then
            BodyConfigJsonObject.Add('orientation', GetOrientationName(Enum::"Universal Printer Orientation"::landscape));

        BodyJsonObject.Add('configuration', BodyConfigJsonObject);
        if not InvokeRequest(GetGraphPrintShareJobsUrl(UniversalPrinterSettings."Print Share ID"), 'POST', Format(BodyJsonObject), ResponseContent, ErrorMessage) then
            exit(false);

        if not ResponseJsonObject.ReadFrom(ResponseContent) then
            exit(false);

        if not GetJsonKeyValue(ResponseJsonObject, 'id', JobId) then
            exit(false);

        if not ResponseJsonObject.SelectToken('documents', DocumentsJsonToken) then
            exit(false);

        Documents := DocumentsJsonToken.AsArray();
        if not Documents.Get(0, DocumentJsonToken) then
            exit(false);

        FirstDocument := DocumentJsonToken.AsObject();
        if not GetJsonKeyValue(FirstDocument, 'id', DocumentId) then
            exit(false);

        exit(true);
    end;

    local procedure GetOrientationName(Orientation: Enum "Universal Printer Orientation"): Text
    begin
        exit(Orientation.Names.Get(Orientation.Ordinals.IndexOf(Orientation.AsInteger())));
    end;

    procedure CreateUploadSessionRequest(PrintShareId: Text; FileName: Text; DocumentType: Text; Size: BigInteger; JobId: Text; DocumentId: Text; var UploadUrl: Text; var ErrorMessage: Text): Boolean
    var
        BodyPropertiesJsonObject: JsonObject;
        BodyJsonObject: JsonObject;
        ResponseContent: Text;
        ResponseJsonObject: JsonObject;
    begin
        BodyPropertiesJsonObject.Add('documentName', FileName);
        BodyPropertiesJsonObject.Add('contentType', DocumentType);
        BodyPropertiesJsonObject.Add('size', Size);
        BodyJsonObject.Add('properties', BodyPropertiesJsonObject);

        if not InvokeRequest(GetGraphDocumentCreateUploadSessionUrl(PrintShareId, JobId, DocumentId), 'POST', Format(BodyJsonObject), ResponseContent, ErrorMessage) then
            exit(false);

        if not ResponseJsonObject.ReadFrom(ResponseContent) then
            exit(false);

        if not GetJsonKeyValue(ResponseJsonObject, 'uploadUrl', UploadUrl) then
            exit(false);

        exit(true);
    end;

    procedure UploadDataRequest(PrintShareId: Text; UploadUrl: Text; TempBlob: Codeunit "Temp Blob"; From: BigInteger; "To": BigInteger; TotalSize: BigInteger; JobId: Text; DocumentId: Text; var ErrorMessage: Text): Boolean
    var
        HttpWebRequestMgt: Codeunit "Http Web Request Mgt.";
        ContentRange: Text;
        ResponseContent: Text;
        StatusCode: DotNet HttpStatusCode;
    begin
        if not AddHeaders(UploadUrl, 'PUT', HttpWebRequestMgt) then
            exit(false);

        // E.g. value for 'Content-Range' is 'bytes 0-72796/4533322'
        ContentRange := 'bytes ' + Format(From) + '-' + Format("To") + '/' + Format(TotalSize);
        HttpWebRequestMgt.AddHeader('Content-Range', ContentRange);
        HttpWebRequestMgt.SetContentLength(TotalSize);
        HttpWebRequestMgt.AddBodyBlob(TempBlob);

        exit(InvokeRequestAndReadResponse(HttpWebRequestMgt, ResponseContent, ErrorMessage, StatusCode));
    end;

    procedure StartPrintJobRequest(PrintShareId: Text; JobId: Text; var JobStateDescription: Text; var ErrorMessage: Text): Boolean
    var
        ResponseJsonObject: JsonObject;
        ResponseContent: Text;
    begin
        if not InvokeRequest(GetGraphStartPrintJobUrl(PrintShareId, JobId), 'POST', '', ResponseContent, ErrorMessage) then
            exit(false);

        if not ResponseJsonObject.ReadFrom(ResponseContent) then
            exit(false);

        if not GetJsonKeyValue(ResponseJsonObject, 'description', JobStateDescription) then
            exit(false);

        exit(true);
    end;

    procedure GetJsonKeyValue(var JObject: JsonObject; KeyName: Text; var KeyValue: Text): Boolean
    var
        JToken: JsonToken;
    begin
        if not JObject.Get(KeyName, JToken) then
            exit(false);

        KeyValue := JToken.AsValue().AsText();
        exit(true);
    end;

    [TryFunction]
    [NonDebuggable]
    internal procedure TryGetAccessToken(var AccessToken: Text; ShowDialog: Boolean)
    var
        AzureADMgt: Codeunit "Azure AD Mgt.";
    begin
        AccessToken := AzureADMgt.GetAccessToken(GetGraphDomain(), '', ShowDialog);
        if AccessToken = '' then begin
            Session.LogMessage('0000EFG', NoTokenTelemetryTxt, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UniversalPrintTelemetryCategoryTxt);
            Error(UserNotAuthenticatedTxt);
        end;
    end;

    local procedure InvokeRequest(Url: Text; Verb: Text; Body: Text; var ResponseContent: Text; var ErrorMessage: Text): Boolean
    var
        StatusCode: DotNet HttpStatusCode;
    begin
        exit(InvokeRequest(Url, Verb, Body, ResponseContent, ErrorMessage, StatusCode));
    end;

    local procedure InvokeRequest(Url: Text; Verb: Text; Body: Text; var ResponseContent: Text; var ErrorMessage: Text; var StatusCode: DotNet HttpStatusCode): Boolean
    var
        HttpWebRequestMgt: Codeunit "Http Web Request Mgt.";
    begin
        if not AddHeaders(Url, Verb, HttpWebRequestMgt) then
            exit(false);

        HttpWebRequestMgt.SetContentType('application/json');
        if Verb <> 'GET' then
            HttpWebRequestMgt.AddBodyAsText(Body);

        exit(InvokeRequestAndReadResponse(HttpWebRequestMgt, ResponseContent, ErrorMessage, StatusCode));
    end;

    local procedure InvokeRequestAndReadResponse(var HttpWebRequestMgt: Codeunit "Http Web Request Mgt."; var ResponseContent: Text; var ErrorMessage: Text; var StatusCode: DotNet HttpStatusCode): Boolean
    var
        ResponseHeaders: DotNet NameValueCollection;
        ResponseErrorMessage: Text;
        ResponseErrorDetails: Text;
    begin
        if HttpWebRequestMgt.SendRequestAndReadTextResponse(ResponseContent, ResponseErrorMessage, ResponseErrorDetails, StatusCode, ResponseHeaders) then
            exit(true);

        Session.LogMessage('0000EG1', StrSubstNo(InvokeWebRequestFailedTelemetryTxt, StatusCode, ResponseErrorMessage),
        Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', UniversalPrintTelemetryCategoryTxt);
        Clear(ErrorMessage);

        if not IsNull(StatusCode) then
            if StatusCode in [401, 403, 404] then begin
                ErrorMessage := NoAccessTxt;
                exit(false);
            end;

        if ErrorMessage = '' then
            ErrorMessage := GetMessageFromErrorJSON(ResponseErrorDetails);

        if ErrorMessage = '' then
            ErrorMessage := ResponseErrorMessage;

        exit(false);
    end;

    local procedure GetMessageFromErrorJSON(ErrorResponseContent: Text): Text
    var
        ResponseJsonObject: JsonObject;
        PropertyBag: JsonToken;
        ErrorJsonObject: JsonObject;
        MessageValue: Text;
    begin
        if ErrorResponseContent = '' then
            exit;

        if not ResponseJsonObject.ReadFrom(ErrorResponseContent) then
            exit;

        if not ResponseJsonObject.Get('error', PropertyBag) then
            exit;

        ErrorJsonObject := PropertyBag.AsObject();
        if GetJsonKeyValue(ErrorJsonObject, 'message', MessageValue) then
            exit(MessageValue);
    end;

    local procedure AddHeaders(Url: Text; Verb: Text; var HttpWebRequestMgt: Codeunit "Http Web Request Mgt."): Boolean
    var
        [NonDebuggable]
        AccessToken: Text;
    begin
        if not TryGetAccessToken(AccessToken, false) then
            exit(false);
        HttpWebRequestMgt.Initialize(Url);
        HttpWebRequestMgt.DisableUI();
        HttpWebRequestMgt.SetReturnType('application/json');
        HttpWebRequestMgt.SetMethod(Verb);
        HttpWebRequestMgt.AddHeader('Authorization', 'Bearer ' + AccessToken);
        exit(true);
    end;

    procedure GetUniversalPrintTelemetryCategory(): Text
    begin
        exit(UniversalPrintTelemetryCategoryTxt);
    end;

    procedure GetUniversalPrintFeatureTelemetryName(): Text
    begin
        exit(UniversalPrintFeatureTelemetryNameTxt);
    end;

    procedure GetUniversalPrintPortalUrl(): Text
    begin
        exit(UniversalPrintPortalUrlTxt);
    end;

    local procedure GetGuidAsString(GuidValue: Guid): Text
    begin
        // Converts guid to string
        // Example: Converts {21EC2020-3AEA-4069-A2DD-08002B30309D} to 21ec2020-3aea-4069-a2dd-08002b30309d
        exit(LowerCase(Format(GuidValue, 0, 4)));
    end;

    local procedure GetGraphDomain(): Text
    var
        UrlHelper: Codeunit "Url Helper";
        Domain: Text;
    begin
        Domain := UrlHelper.GetGraphUrl();
        if Domain <> '' then
            exit(Domain);

        exit('https://graph.microsoft.com/');
    end;

    local procedure GetGraphAPIVersion(): Text
    begin
        exit('v1.0');
    end;

    local procedure GetGraphPrintSharesUrl(): Text
    begin
        // https://graph.microsoft.com/v1.0/print/shares/
        exit(GetGraphDomain() + GetGraphAPIVersion() + '/print/shares');
    end;

    local procedure GetGraphPrintShareSelectUrl(PrintShareID: Text): Text
    begin
        // https://graph.microsoft.com/v1.0/print/shares/{PrintShareID}?$select=id,displayName,defaults,capabilities
        exit(GetGraphPrintSharesUrl() + '/' + GetGuidAsString(PrintShareID) + '?$select=id,displayName,defaults,capabilities');
    end;

    local procedure GetGraphPrintShareUrl(PrintShareID: Text): Text
    begin
        // https://graph.microsoft.com/v1.0/print/shares/{PrintShareID}
        exit(GetGraphPrintSharesUrl() + '/' + GetGuidAsString(PrintShareID));
    end;

    local procedure GetGraphPrintShareJobsUrl(PrintShareID: Text): Text
    begin
        // https://graph.microsoft.com/v1.0/print/shares/{PrintShareID}/jobs
        exit(GetGraphPrintShareUrl(GetGuidAsString(PrintShareID)) + '/jobs');
    end;

    local procedure GetGraphDocumentCreateUploadSessionUrl(PrintShareID: Text; PrintJobID: Text; PrintDocumentID: Text): Text
    begin
        // https://graph.microsoft.com/v1.0/print/shares/{PrintShareID}/jobs/{PrintJobID}/documents/{PrintDocumentID}/createUploadSession'
        exit(GetGraphPrintShareJobsUrl(GetGuidAsString(PrintShareID)) + '/' + PrintJobID + '/documents/' + PrintDocumentID + '/createUploadSession');
    end;

    local procedure GetGraphStartPrintJobUrl(PrintShareID: Text; PrintJobID: Text): Text
    begin
        // https://graph.microsoft.com/v1.0/print/shares/{PrintShareID}/jobs/{PrintJobID}/start
        exit(GetGraphPrintShareJobsUrl(GetGuidAsString(PrintShareID)) + '/' + PrintJobID + '/start');
    end;

    var
        UserNotAuthenticatedTxt: Label 'User cannot be authenticated with Azure AD.';
        NoAccessTxt: Label 'You don''t have access to the data. Make sure your account has been assigned a Universal Print license and you have the required permissions.';
        UniversalPrintTelemetryCategoryTxt: Label 'Universal Print AL', Locked = true;
        UniversalPrintFeatureTelemetryNameTxt: Label 'Universal Print', Locked = true;
        NoTokenTelemetryTxt: Label 'Access token could not be retrieved.', Locked = true;
        InvokeWebRequestFailedTelemetryTxt: Label 'Invoking web request has failed. Status %1, Message %2', Locked = true;
        UniversalPrintPortalUrlTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2153618', Locked = true;
}

