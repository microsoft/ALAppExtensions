// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9131 "Microsoft Graph Client Impl."
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
        MicrosoftGraphUriBuilder: Codeunit "Microsoft Graph Uri Builder";
    begin
        MicrosoftGraphUriBuilder.Initialize(MicrosoftGraphAPIVersion, RelativeUriToResource);
        MicrosoftGraphRequestHelper.SetAuthorization(MicrosoftGraphAuthorization);
        MgOperationResponse := MicrosoftGraphRequestHelper.Get(MicrosoftGraphUriBuilder);
        if not MgOperationResponse.GetResultAsStream(FileInStream) then
            exit(false);
        if not MgOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            exit(false);
        exit(true);
    end;

    procedure Delete(RelativeUriToResource: Text): Boolean
    var
        MicrosoftGraphUriBuilder: Codeunit "Microsoft Graph Uri Builder";
    begin
        MicrosoftGraphUriBuilder.Initialize(MicrosoftGraphAPIVersion, RelativeUriToResource);
        MicrosoftGraphRequestHelper.SetAuthorization(MicrosoftGraphAuthorization);
        MgOperationResponse := MicrosoftGraphRequestHelper.Get(MicrosoftGraphUriBuilder);
        if not MgOperationResponse.GetResultAsStream(FileInStream) then
            exit(false);
        if not MgOperationResponse.GetDiagnostics().IsSuccessStatusCode() then
            exit(false);
        exit(true);
    end;

}

