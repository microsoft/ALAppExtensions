// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Azure.Functions;

using System.Utilities;

codeunit 7801 "Azure Functions Code Auth" implements "Azure Functions Authentication"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

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
        UriBuilder: Codeunit "Uri Builder";
    begin
        UriBuilder.Init(EndpointGlobal);
        UriBuilder.AddQueryParameter('Code', AuthenticationCodeGlobal);

        UriBuilder.GetUri(Uri);
        RequestMessage.SetRequestUri(Uri.GetAbsoluteUri());
        exit(true);
    end;
}