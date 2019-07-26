// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to fetch attributes concerning the current tenant.
/// </summary>
codeunit 417 "Tenant Settings"
{
    Access = Public;
    SingleInstance = true;

    var
        TenantSettingsImpl: Codeunit "Tenant Settings Impl.";

        /// <summary>
        /// Gets the tenant ID.
        /// </summary>
        /// <returns>If it cannot be found, an empty string is returned.</returns>
    procedure GetTenantId(): Text
    begin
        exit(TenantSettingsImpl.GetTenantId());
    end;

    /// <summary>
    /// Gets the tenant AAD ID.
    /// </summary>
    /// <returns>If it cannot be found, an empty string is returned.</returns>
    procedure GetAadTenantId(): Text
    begin
        exit(TenantSettingsImpl.GetAadTenantId());
    end;

    /// <summary>
    /// Gets the tenant name.
    /// </summary>
    /// <returns>If it cannot be found, an empty string is returned.</returns>
    procedure GetTenantDisplayName(): Text
    begin
        exit(TenantSettingsImpl.GetTenantDisplayName());
    end;

    /// <summary>
    /// Gets the application family.
    /// </summary>
    procedure GetApplicationFamily(): Text
    begin
        exit(TenantSettingsImpl.GetApplicationFamily());
    end;
}

