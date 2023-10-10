// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Integration.Microsoft.Graph;
using System.Integration.Microsoft.Graph.Authorization;
using System.RestClient;

codeunit 9351 "Mg Client Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;


    var
        MgRequestHelper: Codeunit "Mg Request Helper";
        RestClient: Codeunit "Rest Client";
        MicrosoftGraphAPIVersion: Enum "Mg API Version";
        MicrosoftGraphAuthorization: Interface "Mg Authorization";
        MicrosoftGraphBaseUrl: Text;


    procedure Initialize(NewMicrosoftGraphAPIVersion: Enum "Mg API Version";
    NewMicrosoftGraphAuthorization: Interface "Mg Authorization")
    begin
        MicrosoftGraphAPIVersion := NewMicrosoftGraphAPIVersion;
        MicrosoftGraphAuthorization := NewMicrosoftGraphAuthorization;
        RestClient.Initialize(MicrosoftGraphAuthorization.GetHttpAuthorization());
    end;

    procedure Initialize(NewMicrosoftGraphAPIVersion: Enum "Mg API Version";
    NewMicrosoftGraphAuthorization: Interface "Mg Authorization"; HttpClientHandlerInstance: Interface "Http Client Handler")
    begin
        MicrosoftGraphAPIVersion := NewMicrosoftGraphAPIVersion;
        MicrosoftGraphAuthorization := NewMicrosoftGraphAuthorization;
        RestClient.Initialize(HttpClientHandlerInstance, MicrosoftGraphAuthorization.GetHttpAuthorization());
    end;

    procedure SetBaseUrl(BaseUrl: Text)
    begin
        MicrosoftGraphBaseUrl := BaseUrl;
    end;

    procedure Get(RelativeUriToResource: Text; var HttpResponseMessage: Codeunit "Http Response Message"): Boolean
    var
        MgOptionalParameters: Codeunit "Mg Optional Parameters";
    begin
        exit(Get(RelativeUriToResource, MgOptionalParameters, HttpResponseMessage));
    end;

    procedure Get(RelativeUriToResource: Text; MgOptionalParameters: Codeunit "Mg Optional Parameters"; var HttpResponseMessage: Codeunit "Http Response Message"): Boolean
    var
        MicrosoftGraphUriBuilder: Codeunit "Mg Uri Builder";
    begin
        Clear(HttpResponseMessage);
        MicrosoftGraphUriBuilder.Initialize(MicrosoftGraphBaseUrl, MicrosoftGraphAPIVersion, RelativeUriToResource, MgOptionalParameters.GetQueryParameters());
        MgRequestHelper.SetRestClient(RestClient);
        HttpResponseMessage := MgRequestHelper.Get(MicrosoftGraphUriBuilder, MgOptionalParameters);
        exit(HttpResponseMessage.GetIsSuccessStatusCode());
    end;

    procedure Post(RelativeUriToResource: Text; MgOptionalParameters: Codeunit "Mg Optional Parameters"; RequestHttpContent: Codeunit "Http Content"; var HttpResponseMessage: Codeunit "Http Response Message"): Boolean
    var
        MicrosoftGraphUriBuilder: Codeunit "Mg Uri Builder";
    begin
        MicrosoftGraphUriBuilder.Initialize(MicrosoftGraphBaseUrl, MicrosoftGraphAPIVersion, RelativeUriToResource, MgOptionalParameters.GetQueryParameters());
        MgRequestHelper.SetRestClient(RestClient);
        HttpResponseMessage := MgRequestHelper.Post(MicrosoftGraphUriBuilder, MgOptionalParameters, RequestHttpContent);
        exit(HttpResponseMessage.GetIsSuccessStatusCode());
    end;

    procedure Patch(RelativeUriToResource: Text; MgOptionalParameters: Codeunit "Mg Optional Parameters"; RequestHttpContent: Codeunit "Http Content"; var HttpResponseMessage: Codeunit "Http Response Message"): Boolean
    var
        MicrosoftGraphUriBuilder: Codeunit "Mg Uri Builder";
    begin
        MicrosoftGraphUriBuilder.Initialize(MicrosoftGraphBaseUrl, MicrosoftGraphAPIVersion, RelativeUriToResource, MgOptionalParameters.GetQueryParameters());
        MgRequestHelper.SetRestClient(RestClient);
        HttpResponseMessage := MgRequestHelper.Patch(MicrosoftGraphUriBuilder, MgOptionalParameters, RequestHttpContent);
        exit(HttpResponseMessage.GetIsSuccessStatusCode());
    end;

    procedure Delete(RelativeUriToResource: Text; MgOptionalParameters: Codeunit "Mg Optional Parameters"; var HttpResponseMessage: Codeunit "Http Response Message"): Boolean
    var
        MicrosoftGraphUriBuilder: Codeunit "Mg Uri Builder";
    begin
        MicrosoftGraphUriBuilder.Initialize(MicrosoftGraphBaseUrl, MicrosoftGraphAPIVersion, RelativeUriToResource);
        MgRequestHelper.SetRestClient(RestClient);
        HttpResponseMessage := MgRequestHelper.Delete(MicrosoftGraphUriBuilder, MgOptionalParameters);
        exit(HttpResponseMessage.GetIsSuccessStatusCode());
    end;

}

