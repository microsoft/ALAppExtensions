// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to fetch the client type that the user is currently using.
/// </summary>
codeunit 4030 "Client Type Management"
{
    Access = Public;
    SingleInstance = true;

    var
        ClientTypeMgtImpl: Codeunit "Client Type Mgt. Impl.";

    /// <summary>Gets the current type of the client being used by the caller, e.g. Phone, Web, Tablet etc.</summary>
    /// <remarks> Use the GetCurrentClientType wrapper method when you want to test a flow on a different type of client.</remarks>
    /// <example>Example 
    /// <code>
    /// IF ClientTypeManagement.GetCurrentClientType IN [CLIENTTYPE::xxx, CLIENTTYPE::yyy] THEN
    /// </code>
    /// </example>
    /// <returns>The client type of the current session.</returns>
    procedure GetCurrentClientType(): ClientType
    begin
        exit(ClientTypeMgtImpl.GetCurrentClientType());
    end;
}

