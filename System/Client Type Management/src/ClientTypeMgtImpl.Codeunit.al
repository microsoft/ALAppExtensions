// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 4032 "Client Type Mgt. Impl."
{
    Access = Internal;
    SingleInstance = true;

    procedure GetCurrentClientType() CurrClientType: ClientType
    begin
        CurrClientType := CurrentClientType();
        OnAfterGetCurrentClientType(CurrClientType);
    end;

    /// <summary>
    /// An event that indicates that subscribers should set the client type that should be returned when the GetCurrentClientType is called.
    /// </summary>
    /// <remarks>
    /// Subscribe to this event from tests if you need to verify a different flow.
    /// This feature is for testing and is subject to a different SLA than production features.
    /// Do not use this event in a production environment. This should be subscribed to only in tests.
    /// </remarks>
    [InternalEvent(false)]
    local procedure OnAfterGetCurrentClientType(var CurrClientType: ClientType)
    begin
    end;
}

