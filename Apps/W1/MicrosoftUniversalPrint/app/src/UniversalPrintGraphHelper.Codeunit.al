// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Device.UniversalPrint;

using System;
using System.Device;
using System.Azure.Identity;
using System.Integration;
using System.Utilities;

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
        NextLinkJsonToken: JsonToken;
        JArrayElement: JsonToken;
        ResponseContent: Text;
        RequestURL: Text;
        MorePrintSharesExist: Boolean;
    begin
        RequestURL := this.GetGraphPrintSharesUrl();
        repeat
            if not this.InvokeRequest(RequestURL, 'GET', '', ResponseContent, ErrorMessage) then
                exit(false);

            if not PrintShareJsonObject.ReadFrom(ResponseContent) then
                exit(false);

            if not PrintShareJsonObject.SelectToken('value', PrintShareJsonArrayToken) then
                exit(false);

            if not PrintShareJsonArrayToken.IsArray() then
                exit(false);

            foreach JArrayElement in PrintShareJsonArrayToken.AsArray() do
                PrintShares.add(JArrayElement);

            MorePrintSharesExist := PrintShareJsonObject.Get('@odata.nextLink', NextLinkJsonToken);
            if MorePrintSharesExist then
                RequestURL := NextLinkJsonToken.AsValue().AsText();
        until not MorePrintSharesExist;
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
        if not this.InvokeRequest(this.GetGraphPrintShareSelectUrl(ID), 'GET', '', ResponseContent, ErrorMessage) then
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
        if this.InvokeRequest(this.GetGraphPrintSharesUrl(), 'GET', '', ResponseContent, ErrorMessage, StatusCode) then
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
        BodyConfigJsonObject.Add('mediaSize', this.ConvertPaperSizeToUniversalPrintMediaSize(UniversalPrinterSettings."Paper Size"));
        if UniversalPrinterSettings.Landscape then
            BodyConfigJsonObject.Add('orientation', this.GetOrientationName(Enum::"Universal Printer Orientation"::landscape));

        BodyJsonObject.Add('configuration', BodyConfigJsonObject);
        if not this.InvokeRequest(this.GetGraphPrintShareJobsUrl(UniversalPrinterSettings."Print Share ID"), 'POST', Format(BodyJsonObject), ResponseContent, ErrorMessage) then
            exit(false);

        if not ResponseJsonObject.ReadFrom(ResponseContent) then
            exit(false);

        if not this.GetJsonKeyValue(ResponseJsonObject, 'id', JobId) then
            exit(false);

        if not ResponseJsonObject.SelectToken('documents', DocumentsJsonToken) then
            exit(false);

        Documents := DocumentsJsonToken.AsArray();
        if not Documents.Get(0, DocumentJsonToken) then
            exit(false);

        FirstDocument := DocumentJsonToken.AsObject();
        if not this.GetJsonKeyValue(FirstDocument, 'id', DocumentId) then
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

        if not this.InvokeRequest(this.GetGraphDocumentCreateUploadSessionUrl(PrintShareId, JobId, DocumentId), 'POST', Format(BodyJsonObject), ResponseContent, ErrorMessage) then
            exit(false);

        if not ResponseJsonObject.ReadFrom(ResponseContent) then
            exit(false);

        if not this.GetJsonKeyValue(ResponseJsonObject, 'uploadUrl', UploadUrl) then
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
        if not this.AddHeaders(UploadUrl, 'PUT', HttpWebRequestMgt) then
            exit(false);

        // E.g. value for 'Content-Range' is 'bytes 0-72796/4533322'
        ContentRange := 'bytes ' + Format(From) + '-' + Format("To") + '/' + Format(TotalSize);
        HttpWebRequestMgt.AddHeader('Content-Range', ContentRange);
        HttpWebRequestMgt.SetContentLength(TotalSize);
        HttpWebRequestMgt.AddBodyBlob(TempBlob);

        exit(this.InvokeRequestAndReadResponse(HttpWebRequestMgt, ResponseContent, ErrorMessage, StatusCode));
    end;

    procedure StartPrintJobRequest(PrintShareId: Text; JobId: Text; var JobStateDescription: Text; var ErrorMessage: Text): Boolean
    var
        ResponseJsonObject: JsonObject;
        ResponseContent: Text;
    begin
        if not this.InvokeRequest(this.GetGraphStartPrintJobUrl(PrintShareId, JobId), 'POST', '', ResponseContent, ErrorMessage) then
            exit(false);

        if not ResponseJsonObject.ReadFrom(ResponseContent) then
            exit(false);

        if not this.GetJsonKeyValue(ResponseJsonObject, 'description', JobStateDescription) then
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
        AccessToken := AzureADMgt.GetAccessToken(this.GetGraphDomain(), '', ShowDialog);
        if AccessToken = '' then begin
            Session.LogMessage('0000EFG', this.NoTokenTelemetryTxt, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', this.UniversalPrintTelemetryCategoryTxt);
            Error(this.UserNotAuthenticatedTxt);
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

        exit(this.InvokeRequestAndReadResponse(HttpWebRequestMgt, ResponseContent, ErrorMessage, StatusCode));
    end;

    local procedure InvokeRequestAndReadResponse(var HttpWebRequestMgt: Codeunit "Http Web Request Mgt."; var ResponseContent: Text; var ErrorMessage: Text; var StatusCode: DotNet HttpStatusCode): Boolean
    var
        ResponseHeaders: DotNet NameValueCollection;
        ResponseErrorMessage: Text;
        ResponseErrorDetails: Text;
        RequestId: Text;
    begin
        if HttpWebRequestMgt.SendRequestAndReadTextResponse(ResponseContent, ResponseErrorMessage, ResponseErrorDetails, StatusCode, ResponseHeaders) then
            exit(true);

        if not this.TryGetRequestIdfromHeaders(ResponseHeaders, RequestId) then
            RequestId := this.NotFoundTelemetryTxt;

        Session.LogMessage('0000EG1', StrSubstNo(this.InvokeWebRequestFailedTelemetryTxt, StatusCode, ResponseErrorMessage, RequestId),
        Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', this.UniversalPrintTelemetryCategoryTxt);

        Clear(ErrorMessage);
        if not IsNull(StatusCode) then
            if StatusCode in [401, 403, 404] then begin
                ErrorMessage := this.NoAccessTxt;
                exit(false);
            end;

        if ErrorMessage = '' then
            ErrorMessage := this.GetMessageFromErrorJSON(ResponseErrorDetails);

        if ErrorMessage = '' then
            ErrorMessage := ResponseErrorMessage;

        exit(false);
    end;

    [TryFunction]
    local procedure TryGetRequestIdfromHeaders(ResponseHeaders: DotNet NameValueCollection; var RequestId: Text)
    begin
        RequestId := ResponseHeaders.Get('Request-Id');
    end;

    local procedure ConvertPaperSizeToUniversalPrintMediaSize(PaperSize: Enum "Printer Paper Kind"): Text
    var
        UniversalPrintMediaSize: Text;
    begin
        // For universal print supported media sizes, refer https://learn.microsoft.com/en-us/graph/api/resources/printercapabilities?view=graph-rest-1.0#mediasizes-values
        case PaperSize of
            PaperSize::A3:
                UniversalPrintMediaSize := A3SizeTxt;
            PaperSize::A4:
                UniversalPrintMediaSize := A4SizeTxt;
            PaperSize::A5:
                UniversalPrintMediaSize := A5SizeTxt;
            PaperSize::A6:
                UniversalPrintMediaSize := A6SizeTxt;
            PaperSize::JapanesePostcard:
                UniversalPrintMediaSize := JPNHagakiSizeTxt;
            PaperSize::Executive:
                UniversalPrintMediaSize := NorthAmericaExecutiveSizeTxt;
            PaperSize::Ledger:
                UniversalPrintMediaSize := NorthAmericaLedgerSizeTxt;
            PaperSize::Legal:
                UniversalPrintMediaSize := NorthAmericaLegalSizeTxt;
            PaperSize::Letter:
                UniversalPrintMediaSize := NorthAmericaLetterSizeTxt;
            PaperSize::Statement:
                UniversalPrintMediaSize := NorthAmericaInvoiceSizeTxt
            else
                // Use the name value of the enum
                UniversalPrintMediaSize := Format(PaperSize);
        end;

        exit(UniversalPrintMediaSize);
    end;

    internal procedure GetPaperSizeFromUniversalPrintMediaSize(textValue: Text): Enum "Printer Paper Kind"
    var
        PrinterPaperKind: Enum "Printer Paper Kind";
        OrdinalValue: Integer;
        Index: Integer;
    begin
        // For universal print supported media sizes, refer https://learn.microsoft.com/en-us/graph/api/resources/printercapabilities?view=graph-rest-1.0#mediasizes-values
        case textValue of
            JPNHagakiSizeTxt:
                PrinterPaperKind := Enum::"Printer Paper Kind"::JapanesePostcard;
            NorthAmericaExecutiveSizeTxt:
                PrinterPaperKind := PrinterPaperKind::Executive;
            NorthAmericaLedgerSizeTxt:
                PrinterPaperKind := PrinterPaperKind::Ledger;
            NorthAmericaLegalSizeTxt:
                PrinterPaperKind := PrinterPaperKind::Legal;
            NorthAmericaLetterSizeTxt:
                PrinterPaperKind := PrinterPaperKind::Letter;
            NorthAmericaInvoiceSizeTxt:
                PrinterPaperKind := PrinterPaperKind::Statement;
            else begin
                Index := PrinterPaperKind.Names.IndexOf(textValue);
                if Index = 0 then
                    exit(Enum::"Printer Paper Kind"::A4);

                OrdinalValue := PrinterPaperKind.Ordinals.Get(Index);
                PrinterPaperKind := Enum::"Printer Paper Kind".FromInteger(OrdinalValue);
            end;
        end;
        exit(PrinterPaperKind);
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
        if this.GetJsonKeyValue(ErrorJsonObject, 'message', MessageValue) then
            exit(MessageValue);
    end;

    local procedure AddHeaders(Url: Text; Verb: Text; var HttpWebRequestMgt: Codeunit "Http Web Request Mgt."): Boolean
    var
        [NonDebuggable]
        AccessToken: Text;
    begin
        if not this.TryGetAccessToken(AccessToken, false) then
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
        exit(this.UniversalPrintTelemetryCategoryTxt);
    end;

    procedure GetUniversalPrintFeatureTelemetryName(): Text
    begin
        exit(this.UniversalPrintFeatureTelemetryNameTxt);
    end;

    procedure GetUniversalPrintPortalUrl(): Text
    begin
        exit(this.UniversalPrintPortalUrlTxt);
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
        // https://graph.microsoft.com/v1.0/print/shares/?$top=1000
        // NOTE: by default universal print returns 10 records only, which is too low for some customers.
        exit(this.GetGraphDomain() + this.GetGraphAPIVersion() + '/print/shares/?$top=1000');
    end;

    local procedure GetGraphPrintShareSelectUrl(PrintShareID: Text): Text
    begin
        // https://graph.microsoft.com/v1.0/print/shares/{PrintShareID}?$select=id,displayName,defaults,capabilities
        exit(this.GetGraphDomain() + this.GetGraphAPIVersion() + '/print/shares/' + this.GetGuidAsString(PrintShareID) + '?$select=id,displayName,defaults,capabilities');
    end;

    local procedure GetGraphPrintShareUrl(PrintShareID: Text): Text
    begin
        // https://graph.microsoft.com/v1.0/print/shares/{PrintShareID}
        exit(this.GetGraphDomain() + this.GetGraphAPIVersion() + '/print/shares/' + this.GetGuidAsString(PrintShareID));
    end;

    local procedure GetGraphPrintShareJobsUrl(PrintShareID: Text): Text
    begin
        // https://graph.microsoft.com/v1.0/print/shares/{PrintShareID}/jobs
        exit(this.GetGraphPrintShareUrl(this.GetGuidAsString(PrintShareID)) + '/jobs');
    end;

    local procedure GetGraphDocumentCreateUploadSessionUrl(PrintShareID: Text; PrintJobID: Text; PrintDocumentID: Text): Text
    begin
        // https://graph.microsoft.com/v1.0/print/shares/{PrintShareID}/jobs/{PrintJobID}/documents/{PrintDocumentID}/createUploadSession'
        exit(this.GetGraphPrintShareJobsUrl(this.GetGuidAsString(PrintShareID)) + '/' + PrintJobID + '/documents/' + PrintDocumentID + '/createUploadSession');
    end;

    local procedure GetGraphStartPrintJobUrl(PrintShareID: Text; PrintJobID: Text): Text
    begin
        // https://graph.microsoft.com/v1.0/print/shares/{PrintShareID}/jobs/{PrintJobID}/start
        exit(this.GetGraphPrintShareJobsUrl(this.GetGuidAsString(PrintShareID)) + '/' + PrintJobID + '/start');
    end;

    var
        UserNotAuthenticatedTxt: Label 'User cannot be authenticated with Microsoft Entra.';
        NoAccessTxt: Label 'You don''t have access to the data. Make sure your account has been assigned a Universal Print license and you have the required permissions.';
        UniversalPrintTelemetryCategoryTxt: Label 'Universal Print AL', Locked = true;
        UniversalPrintFeatureTelemetryNameTxt: Label 'Universal Print', Locked = true;
        NoTokenTelemetryTxt: Label 'Access token could not be retrieved.', Locked = true;
        InvokeWebRequestFailedTelemetryTxt: Label 'Invoking web request has failed. Status %1, Message %2, RequestId %3', Locked = true;
        NotFoundTelemetryTxt: Label 'Not Found.', Locked = true;
        UniversalPrintPortalUrlTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2153618', Locked = true;
        A3SizeTxt: Label 'A3', Locked = true;
        A4SizeTxt: Label 'A4', Locked = true;
        A5SizeTxt: Label 'A5', Locked = true;
        A6SizeTxt: Label 'A6', Locked = true;
        JPNHagakiSizeTxt: Label 'JPN Hagaki', Locked = true;
        NorthAmericaExecutiveSizeTxt: Label 'North America Executive', Locked = true;
        NorthAmericaInvoiceSizeTxt: Label 'North America Invoice', Locked = true;
        NorthAmericaLedgerSizeTxt: Label 'North America Ledger', Locked = true;
        NorthAmericaLegalSizeTxt: Label 'North America Legal', Locked = true;
        NorthAmericaLetterSizeTxt: Label 'North America Letter', Locked = true;
}

