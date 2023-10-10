// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Integration.Microsoft.Graph;
using System.RestClient;

codeunit 9354 "Mg Request Helper"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        RestClient: Codeunit "Rest Client";

    procedure SetRestClient(var NewRestClient: Codeunit "Rest Client")
    begin
        RestClient := NewRestClient;
    end;

    procedure Get(MgUriBuilder: Codeunit "Mg Uri Builder"; MgOptionalParameters: Codeunit "Mg Optional Parameters") HttpResponseMessage: Codeunit "Http Response Message"
    begin
        PrepareRestClient(MgOptionalParameters);
        HttpResponseMessage := RestClient.Get(MgUriBuilder.GetUri());
    end;

    procedure Post(MgUriBuilder: Codeunit "Mg Uri Builder"; MgOptionalParameters: Codeunit "Mg Optional Parameters"; HttpContent: Codeunit "Http Content") HttpResponseMessage: Codeunit "Http Response Message"
    begin
        HttpResponseMessage := SendRequest(Enum::"Http Method"::POST, MgUriBuilder, MgOptionalParameters, HttpContent);
    end;

    procedure Patch(MgUriBuilder: Codeunit "Mg Uri Builder"; MgOptionalParameters: Codeunit "Mg Optional Parameters"; HttpContent: Codeunit "Http Content") HttpResponseMessage: Codeunit "Http Response Message"
    begin
        HttpResponseMessage := SendRequest(Enum::"Http Method"::PATCH, MgUriBuilder, MgOptionalParameters, HttpContent);
    end;

    procedure Delete(MgUriBuilder: Codeunit "Mg Uri Builder"; MgOptionalParameters: Codeunit "Mg Optional Parameters") HttpResponseMessage: Codeunit "Http Response Message"
    begin
        PrepareRestClient(MgOptionalParameters);
        HttpResponseMessage := RestClient.Delete(MgUriBuilder.GetUri());
    end;

    local procedure PrepareRestClient(MgOptionalParameters: Codeunit "Mg Optional Parameters")
    var
        RequestHeaders: Dictionary of [Text, Text];
        RequestHeaderName: Text;
    begin
        RequestHeaders := MgOptionalParameters.GetRequestHeaders();
        foreach RequestHeaderName in RequestHeaders.Keys() do
            RestClient.SetDefaultRequestHeader(RequestHeaderName, RequestHeaders.Get(RequestHeaderName));
    end;

    local procedure SendRequest(HttpMethod: Enum "Http Method"; MgUriBuilder: Codeunit "Mg Uri Builder"; MgOptionalParameters: Codeunit "Mg Optional Parameters"; HttpContent: Codeunit "Http Content") HttpResponseMessage: Codeunit "Http Response Message"
    begin
        PrepareRestClient(MgOptionalParameters);
        HttpResponseMessage := RestClient.Send(HttpMethod, MgUriBuilder.GetUri(), HttpContent);
    end;
}