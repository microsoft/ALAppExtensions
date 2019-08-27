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

    [IntegrationEvent(false, false)]
    procedure OnAfterGetCurrentClientType(var CurrClientType: ClientType)
    begin
        // Subscribe to this event from tests if you need to verify a different flow.
        // This feature is for testing and is subject to a different SLA than production features.
        // Do not use this event in a production environment. This should be subscribed to only in tests.
    end;
}

