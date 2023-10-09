// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135141 "Mg Auth. Spy" implements "Microsoft Graph Authorization"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        _Invoked: Boolean;

    [NonDebuggable]
    procedure Authorize(var HttpRequestMessage: HttpRequestMessage);
    begin
        _Invoked := true;
    end;

    procedure IsInvoked(): Boolean
    begin
        exit(_invoked);
    end;
}