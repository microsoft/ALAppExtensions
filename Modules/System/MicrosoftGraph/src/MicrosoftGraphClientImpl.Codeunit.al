// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9031 "Microsoft Graph Client Impl."
{
    Access = Internal;


    var
        UriBuilder: Codeunit "Uri Builder";
        MicrosoftGraphAuthorization: Interface "Microsoft Graph Authorization";
        MicrosoftGraphAPIVersion: Enum "Microsoft Graph API Version";
        MgOperationResponse: Codeunit "Mg Operation Response";
        MicrosoftGraphRequestHelper: Codeunit "Microsoft Graph Request Helper";


    procedure Initialize(NewMicrosoftGraphAPIVersion: Enum "Microsoft Graph API Version"; NewMicrosoftGraphAuthorization: Interface "Microsoft Graph Authorization")
    begin
        MicrosoftGraphAPIVersion := NewMicrosoftGraphAPIVersion;
        MicrosoftGraphAuthorization := NewMicrosoftGraphAuthorization;
    end;

    procedure GetDiagnostics(): Interface "HTTP Diagnostics"
    begin
        exit(MgOperationResponse.GetDiagnostics());
    end;

    procedure Get(RelativeUriToResource: Text; var FileInStream: InStream): Boolean
    var
        MgGraphHttpRequestMessage: HttpRequestMessage;
        MgGraphHttpResponseMessage: HttpResponseMessage;
        MgGraphHttpClient: HttpClient;
        MicrosoftGraphUriBuilder: Codeunit "Microsoft Graph Uri Builder";
    begin
        MicrosoftGraphUriBuilder.Initialize(MicrosoftGraphAPIVersion, RelativeUriToResource);
        MicrosoftGraphRequestHelper.SetAuthorization(MicrosoftGraphAuthorization);
        MgOperationResponse := MicrosoftGraphRequestHelper.Get(MicrosoftGraphUriBuilder);
        if not MgOperationResponse.GetResultAsStream(FileInStream) then
            exit(false);
        if not MgOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            exit(false);
    end;

}

