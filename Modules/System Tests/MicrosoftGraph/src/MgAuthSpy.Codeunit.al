// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Test.Integration.Microsoft.Graph;

using System.Integration.Microsoft.Graph.Authorization;
using System.RestClient;

codeunit 135141 "Mg Auth. Spy" implements "Mg Authorization"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        _Invoked: Boolean;

    procedure IsInvoked(): Boolean
    begin
        exit(_invoked);
    end;

    procedure GetHttpAuthorization(): Interface "Http Authentication";
    var
        HttpAuthenticationAnonymous: Codeunit "Http Authentication Anonymous";
    begin
        _Invoked := true;
        exit(HttpAuthenticationAnonymous);
    end;
}