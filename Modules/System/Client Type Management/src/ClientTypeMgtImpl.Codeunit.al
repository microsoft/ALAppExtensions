// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 4032 "Client Type Mgt. Impl."
{
    Access = Internal;
    SingleInstance = true;

    procedure GetCurrentClientType() CurrClientType: ClientType
    var
        ClientTypeManagement: Codeunit "Client Type Management";
    begin
        CurrClientType := CurrentClientType();
        ClientTypeManagement.OnAfterGetCurrentClientType(CurrClientType);
    end;
}

