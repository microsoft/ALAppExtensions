// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9151 "Microsoft Graph Client Impl."
{
    Access = Internal;


    var
        MgOperationResponse: Codeunit "Mg Operation Response";
        MicrosoftGraphRequestHelper: Codeunit "Microsoft Graph Request Helper";
        MicrosoftGraphAPIVersion: Enum "Microsoft Graph API Version";
        MicrosoftGraphAuthorization: Interface "Microsoft Graph Authorization";


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
        MgOptionalParameters: Codeunit "Mg Optional Parameters";
    begin
        exit(Get(RelativeUriToResource, MgOptionalParameters, FileInStream));
    end;

    procedure Get(RelativeUriToResource: Text; MgOptionalParameters: Codeunit "Mg Optional Parameters"; var FileInStream: InStream): Boolean
    var
        MicrosoftGraphUriBuilder: Codeunit "Microsoft Graph Uri Builder";
    begin
        MicrosoftGraphUriBuilder.Initialize(MicrosoftGraphAPIVersion, RelativeUriToResource, MgOptionalParameters.GetQueryParameters());
        MicrosoftGraphRequestHelper.SetAuthorization(MicrosoftGraphAuthorization);
        MgOperationResponse := MicrosoftGraphRequestHelper.Get(MicrosoftGraphUriBuilder, MgOptionalParameters);
        if not MgOperationResponse.TryGetResultAsStream(FileInStream) then
            exit(false);
        exit(MgOperationResponse.GetDiagnostics().IsSuccessStatusCode());
    end;

    procedure Post(RelativeUriToResource: Text; MgOptionalParameters: Codeunit "Mg Optional Parameters"; var RequestContentInStream: InStream; var FileInStream: InStream): Boolean
    var
        MicrosoftGraphHttpContent: Codeunit "Microsoft Graph Http Content";
        MicrosoftGraphUriBuilder: Codeunit "Microsoft Graph Uri Builder";
    begin
        MicrosoftGraphUriBuilder.Initialize(MicrosoftGraphAPIVersion, RelativeUriToResource, MgOptionalParameters.GetQueryParameters());
        MicrosoftGraphHttpContent.FromFileInStream(RequestContentInStream);
        MicrosoftGraphRequestHelper.SetAuthorization(MicrosoftGraphAuthorization);
        MgOperationResponse := MicrosoftGraphRequestHelper.Post(MicrosoftGraphUriBuilder, MgOptionalParameters, MicrosoftGraphHttpContent);
        if not MgOperationResponse.TryGetResultAsStream(FileInStream) then
            exit(false);
        exit(MgOperationResponse.GetDiagnostics().IsSuccessStatusCode());
    end;



    procedure Delete(RelativeUriToResource: Text): Boolean
    var
        MicrosoftGraphUriBuilder: Codeunit "Microsoft Graph Uri Builder";
    begin
        MicrosoftGraphUriBuilder.Initialize(MicrosoftGraphAPIVersion, RelativeUriToResource);
        MicrosoftGraphRequestHelper.SetAuthorization(MicrosoftGraphAuthorization);
        MgOperationResponse := MicrosoftGraphRequestHelper.Delete(MicrosoftGraphUriBuilder);
        exit(MgOperationResponse.GetDiagnostics().IsSuccessStatusCode());
    end;

}

