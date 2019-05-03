// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 417 "Tenant Settings"
{
    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        TenantSettingsImpl: Codeunit "Tenant Settings Impl.";

    procedure GetTenantId(): Text
    begin
        // <summary>
        // Gets the tenant ID.
        // </summary>
        // <returns>If it cannot be found, an empty string is returned.</returns>
        exit(TenantSettingsImpl.GetTenantId);
    end;

    procedure GetAadTenantId(): Text
    begin
        // <summary>
        // Gets the tenant AAD ID.
        // </summary>
        // <returns>If it cannot be found, an empty string is returned.</returns>
        exit(TenantSettingsImpl.GetAadTenantId);
    end;

    procedure GetTenantDisplayName(): Text
    begin
        // <summary>
        // Gets the tenant name.
        // </summary>
        // <returns>If it cannot be found, an empty string is returned.</returns>
        exit(TenantSettingsImpl.GetTenantDisplayName);
    end;

    procedure GetApplicationFamily(): Text
    begin
        // <summary>
        // Gets the application family.
        // </summary>
        exit(TenantSettingsImpl.GetApplicationFamily);
    end;
}

