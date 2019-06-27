// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
///
/// </summary>
codeunit 4030 "Client Type Management"
{
    Access = Public;
    SingleInstance = true;

    var
        ClientTypeMgtImpl: Codeunit "Client Type Mgt. Impl.";

        /// <summary>Gets the current type of the client being used by the caller, e.g. Phone, Web, Tablet etc.</summary>
        /// <remarks> Use the GetCurrentClientType wrapper method when you want to test a flow on a different type of client.</remarks>
        /// <example>Example<code>
        /// IF ClientTypeManagement.GetCurrentClientType IN [CLIENTTYPE::xxx, CLIENTTYPE::yyy] THEN
        /// </code></example>
    procedure GetCurrentClientType(): ClientType
    begin
        exit(ClientTypeMgtImpl.GetCurrentClientType());
    end;

    /// <summary>Subscribe to this event from tests if you need to verify a different flow.</summary>
    /// <remarks>
    /// Do not use this event in a production environment.
    /// This feature is for testing and is subject to a different SLA than production features.
    /// </remarks>
    [IntegrationEvent(false, false)]
    [Scope('OnPrem')]
    internal procedure OnAfterGetCurrentClientType(var CurrClientType: ClientType)
    begin
    end;
}

