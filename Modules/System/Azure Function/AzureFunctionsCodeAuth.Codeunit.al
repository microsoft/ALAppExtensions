// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 7801 "Azure Functions Code Auth" implements "Azure Functions Authentication"
{
    Access = Internal;

    var
        [NonDebuggable]
        AuthenticationCodeGlobal, EndpointGlobal : Text;

    [NonDebuggable]
    procedure SetAuthParameters(Endpoint: Text; AuthenticationCode: Text)
    begin
        AuthenticationCodeGlobal := AuthenticationCode;
        EndpointGlobal := Endpoint;
    end;

    [NonDebuggable]
    procedure Authenticate(var RequestMessage: HttpRequestMessage): Boolean
    var
        Uri: Codeunit Uri;
        UriBuider: Codeunit "Uri Builder";
    begin
        UriBuider.Init(EndpointGlobal);
        UriBuider.AddQueryParameter('Code', AuthenticationCodeGlobal);

        UriBuider.GetUri(Uri);
        RequestMessage.SetRequestUri(Uri.GetAbsoluteUri());
        exit(true);
    end;
}