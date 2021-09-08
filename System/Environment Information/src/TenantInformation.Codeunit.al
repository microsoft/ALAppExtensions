// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to fetch attributes concerning the current tenant.
/// </summary>
codeunit 417 "Tenant Information"
{
    Access = Public;
    SingleInstance = true;

    var
        TenantInformationImpl: Codeunit "Tenant Information Impl.";

    /// <summary>
    /// Gets the tenant ID.
    /// </summary>
    /// <returns>If it cannot be found, an empty string is returned.</returns>
    procedure GetTenantId(): Text
    begin
        exit(TenantInformationImpl.GetTenantId());
    end;

    /// <summary>
    /// Gets the tenant name.
    /// </summary>
    /// <returns>If it cannot be found, an empty string is returned.</returns>
    procedure GetTenantDisplayName(): Text
    begin
        exit(TenantInformationImpl.GetTenantDisplayName());
    end;
}

