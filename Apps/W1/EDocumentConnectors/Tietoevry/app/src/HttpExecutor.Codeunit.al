// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Tietoevry;

using System.Telemetry;

/// <summary>
/// Execute http requests for Tietoevry API
/// </summary>
codeunit 6397 "Http Executor"
{

    Access = Internal;

    /// <summary>
    /// Execute http calls. Handle response with error logging.
    /// </summary>
    procedure ExecuteHttpRequest(var Request: Codeunit Requests) Response: Text
    var
        HttpResponse: HttpResponseMessage;
    begin
        exit(this.ExecuteHttpRequest(Request, HttpResponse));
    end;

    /// <summary>
    /// Execute http calls. Handle response with error logging and store response in HttpResponse
    /// </summary>
    procedure ExecuteHttpRequest(var Request: Codeunit Requests; HttpResponse: HttpResponseMessage) Response: Text
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        HttpClient: HttpClient;
    begin
        FeatureTelemetry.LogUptake('', this.TietoevryProcessing.GetTietoevryTok(), Enum::"Feature Uptake Status"::Used);
        FeatureTelemetry.LogUsage('', this.TietoevryProcessing.GetTietoevryTok(), 'Tietoevry request.');

        HttpClient.Send(Request.GetRequest(), this.HttpResponseMessage);
        HttpResponse := this.HttpResponseMessage;
        this.HandleHttpResponse(this.HttpResponseMessage, Response);
    end;

    /// <summary>
    /// Return response from last http call
    /// </summary>
    procedure GetResponse(): HttpResponseMessage
    begin
        exit(this.HttpResponseMessage);
    end;

    /// <summary>
    /// Throw error for requests not of status 200 and 201.
    /// </summary>
    local procedure HandleHttpResponse(LocalHttpResponseMessage: HttpResponseMessage; var Response: Text)
    var
        FriendlyErrorMsg: Text;
    begin
        GetContent(LocalHttpResponseMessage, Response);
        case LocalHttpResponseMessage.HttpStatusCode() of
            200:
                begin
                    Session.LogMessage('', this.HTTPSuccessMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', this.TietoevryProcessing.GetTietoevryTok());
                    exit;
                end;
            201:
                begin
                    Session.LogMessage('', this.HTTPSuccessAndCreatedMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', this.TietoevryProcessing.GetTietoevryTok());
                    exit;
                end;
            400:
                FriendlyErrorMsg := this.HTTPBadRequestMsg;
            401:
                FriendlyErrorMsg := this.HTTPUnauthorizedMsg;
            402 .. 499:
                if not this.Parse400Messages(Response, FriendlyErrorMsg) then
                    FriendlyErrorMsg := this.HTTPBadRequestMsg;
            500:
                FriendlyErrorMsg := this.HTTPInternalServerErrorMsg;
            503:
                FriendlyErrorMsg := this.HTTPServiceUnavailableMsg;
            else
                FriendlyErrorMsg := this.HTTPGeneralErrMsg;
        end;

        FriendlyErrorMsg := StrSubstNo(this.HttpErrorMsg, LocalHttpResponseMessage.HttpStatusCode(), FriendlyErrorMsg);
        Session.LogMessage('', StrSubstNo(this.HttpErrorMsg, LocalHttpResponseMessage.HttpStatusCode(), Response), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', this.TietoevryProcessing.GetTietoevryTok());
        Error(FriendlyErrorMsg);
    end;

    [TryFunction]
    local procedure Parse400Messages(Content: Text; var Message: Text)
    var
        ResponseJson: JsonObject;
        JsonToken: JsonToken;
    begin
        ResponseJson.ReadFrom(Content);
        ResponseJson.Get('message', JsonToken);
        Message := JsonToken.AsValue().AsText();
    end;

    [TryFunction]
    local procedure GetContent(HttpResponseMsg: HttpResponseMessage; var Response: Text)
    begin
        HttpResponseMsg.Content.ReadAs(Response);
    end;

    var
        TietoevryProcessing: Codeunit Processing;
        HttpResponseMessage: HttpResponseMessage;
        HTTPSuccessMsg: Label 'The HTTP request was successful and the body contains the resource fetched.'; // 200
        HTTPSuccessAndCreatedMsg: Label 'The HTTP request was successful and a new resource was created.'; //201
        HTTPBadRequestMsg: Label 'The HTTP request was incorrectly formed or invalid.'; // 400
        HTTPUnauthorizedMsg: Label 'The HTTP request is not authorized. Authentication credentials are not valid.'; // 401
        HTTPInternalServerErrorMsg: Label 'The HTTP request is not successful. An internal server error occurred.'; // 500
        HTTPServiceUnavailableMsg: Label 'The HTTP request is not successful. The service is unavailable.'; // 503
        HTTPGeneralErrMsg: Label 'Something went wrong, try again later.';
        HttpErrorMsg: Label 'Error Code: %1, Error Message: %2', Comment = '%1 = Error Code, %2 = Error Message';
}