// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 7803 "Azure Functions Impl"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        SendRequstErr: Label 'Sending the request has failed.';
        HttpResponseErr: Label '%1.\\Response Code: %2 %3', Comment = '%1 = Default Error Message ; %2 = Status Code; %3 = Reason Phrase';
        AuthenticationFailedErr: Label 'Authentication failed';
        AzureFunctionCategoryLbl: Label 'Connect to Azure Functions', Locked = true;
        RequestSucceededMsg: Label 'Request sent to Azure function succeeded', Locked = true;
        RequestFailedErr: Label 'Request sent to Azure function failed: %1', Locked = true;

    [NonDebuggable]
    procedure SendGetRequest(AzureFunctionAuthentication: Interface "Azure Functions Authentication"; QueryDict: Dictionary of [Text, Text]): Codeunit "Azure Functions Response"
    begin
        exit(Send(AzureFunctionAuthentication, Enum::"Http Request Type"::GET, QueryDict, '', ''));
    end;

    [NonDebuggable]
    procedure SendPostRequest(AzureFunctionAuthentication: Interface "Azure Functions Authentication"; Body: Text; ContentTypeHeader: text): Codeunit "Azure Functions Response"
    var
        QueryDict: Dictionary of [Text, Text];
    begin
        exit(Send(AzureFunctionAuthentication, Enum::"Http Request Type"::POST, QueryDict, Body, ContentTypeHeader));
    end;

    [NonDebuggable]
    procedure Send(AzureFunctionAuthentication: Interface "Azure Functions Authentication"; RequestType: enum "Http Request Type"; QueryDict: Dictionary of [Text, Text]; Body: Text; ContentTypeHeader: text): Codeunit "Azure Functions Response"
    var
        Uri: Codeunit Uri;
        UriBuilder: Codeunit "Uri Builder";
        AzureFunctionResponse: Codeunit "Azure Functions Response";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ContentHeaders: HttpHeaders;
        ResponseMessage: HttpResponseMessage;
        KeyText: Text;
        Dimensions: Dictionary of [Text, Text];
    begin
        if AzureFunctionAuthentication.Authenticate(RequestMessage) then begin
            RequestMessage.Method(Format(RequestType));
            UriBuilder.Init(RequestMessage.GetRequestUri());

            if QueryDict.Count > 0 then begin
                foreach KeyText in QueryDict.Keys do
                    UriBuilder.AddQueryParameter(KeyText, QueryDict.Get(KeyText));

                UriBuilder.GetUri(Uri);
                RequestMessage.SetRequestUri(Uri.GetAbsoluteUri());
            end;

            if Body <> '' then begin
                RequestMessage.Content.WriteFrom(Body);
                RequestMessage.Content.GetHeaders(ContentHeaders);
                ContentHeaders.Remove('Content-Type');
                ContentHeaders.Add('Content-Type', ContentTypeHeader);
            end;

            if not Client.Send(RequestMessage, ResponseMessage) then
                AzureFunctionResponse.SetError(StrSubstNo(HttpResponseErr, SendRequstErr, ResponseMessage.HttpStatusCode, ResponseMessage.ReasonPhrase));

            UriBuilder.GetUri(Uri);
            Dimensions.Add('StatusCode', Format(ResponseMessage.HttpStatusCode));
            Dimensions.Add('FunctionHost', Format(Uri.GetHost()));

            if ResponseMessage.IsSuccessStatusCode then
                FeatureTelemetry.LogUsage('0000I74', AzureFunctionCategoryLbl, RequestSucceededMsg, Dimensions)
            else
                FeatureTelemetry.LogError('0000I7P', AzureFunctionCategoryLbl, StrSubstNo(RequestFailedErr, Uri.GetHost()), StrSubstNo(RequestFailedErr, Uri.GetHost()), '', Dimensions);

            AzureFunctionResponse.SetHttpResponse(ResponseMessage);
        end else
            AzureFunctionResponse.SetError(AuthenticationFailedErr);

        exit(AzureFunctionResponse);
    end;
}