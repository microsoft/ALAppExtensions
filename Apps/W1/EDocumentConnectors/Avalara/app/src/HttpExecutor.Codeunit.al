// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Avalara;

using System.Telemetry;

/// <summary>
/// Execute http requests for Avalara API
/// </summary>
codeunit 6377 "Http Executor"
{

    Access = Internal;

    /// <summary>
    /// Execute http calls. Handle response with error logging.
    /// </summary>
    procedure ExecuteHttpRequest(var Request: Codeunit Requests) Response: Text
    var
        HttpResponse: HttpResponseMessage;
    begin
        exit(ExecuteHttpRequest(Request, HttpResponse));
    end;

    /// <summary>
    /// Execute http calls. Handle response with error logging and store response in HttpResponse
    /// </summary>
    procedure ExecuteHttpRequest(var Request: Codeunit Requests; HttpResponse: HttpResponseMessage) Response: Text
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        HttpClient: HttpClient;
    begin
        FeatureTelemetry.LogUptake('0000NH9', this.AvalaraProcessing.GetAvalaraTok(), Enum::"Feature Uptake Status"::Used);
        FeatureTelemetry.LogUsage('0000NHA', this.AvalaraProcessing.GetAvalaraTok(), 'Avalara request.');

        HttpClient.Send(Request.GetRequest(), this.HttpResponseMessage);
        HttpResponse := this.HttpResponseMessage;
        HandleHttpResponse(this.HttpResponseMessage, Response);
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
                    Session.LogMessage('0000NHB', HTTPSuccessMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', this.AvalaraProcessing.GetAvalaraTok());
                    exit;
                end;
            201:
                begin
                    Session.LogMessage('0000NHC', HTTPSuccessAndCreatedMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', this.AvalaraProcessing.GetAvalaraTok());
                    exit;
                end;
            400:
                FriendlyErrorMsg := HTTPBadRequestMsg;
            401:
                FriendlyErrorMsg := HTTPUnauthorizedMsg;
            402 .. 499:
                if not Parse400Messages(Response, FriendlyErrorMsg) then
                    FriendlyErrorMsg := HTTPBadRequestMsg;
            500:
                FriendlyErrorMsg := HTTPInternalServerErrorMsg;
            503:
                FriendlyErrorMsg := HTTPServiceUnavailableMsg;
            else
                FriendlyErrorMsg := HTTPGeneralErrMsg;
        end;

        FriendlyErrorMsg := StrSubstNo(HttpErrorMsg, LocalHttpResponseMessage.HttpStatusCode(), FriendlyErrorMsg);
        Session.LogMessage('0000NHD', StrSubstNo(HttpErrorMsg, LocalHttpResponseMessage.HttpStatusCode(), Response), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', this.AvalaraProcessing.GetAvalaraTok());
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
        AvalaraProcessing: Codeunit Processing;
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