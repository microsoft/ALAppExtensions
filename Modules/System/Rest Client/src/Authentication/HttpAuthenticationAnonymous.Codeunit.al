// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.RestClient;

/// <summary>Implementation of the "Http Authentication" interface for a anonymous request.</summary>
codeunit 2358 "Http Authentication Anonymous" implements "Http Authentication"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    /// <summary>Indicates if authentication is required.</summary>
    /// <returns>False, because no authentication is required.</returns>
    procedure IsAuthenticationRequired(): Boolean
    begin
        exit(false);
    end;

    /// <summary>Gets the authorization headers.</summary>
    /// <returns>Empty dictionary, because no authentication is required.</returns>
    procedure GetAuthorizationHeaders() Header: Dictionary of [Text, SecretText]
    begin
    end;
}