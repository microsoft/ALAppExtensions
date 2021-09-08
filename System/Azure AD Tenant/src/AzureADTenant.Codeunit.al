// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to fetch attributes concerning the current tenant.
/// </summary>
codeunit 433 "Azure AD Tenant"
{
    Access = Public;
    SingleInstance = true;

    var
        AzureADTenantImpl: Codeunit "Azure AD Tenant Impl.";

    /// <summary>
    /// Gets the tenant AAD ID.
    /// </summary>
    /// <returns>If it cannot be found, an empty string is returned.</returns>
    procedure GetAadTenantId(): Text
    begin
        exit(AzureADTenantImpl.GetAadTenantId());
    end;

    /// <summary>
    /// Gets the Azure Active Directory tenant domain name.
    /// If the Microsoft Graph API cannot be reached, the error is displayed.
    /// </summary>
    /// <returns>The AAD Tenant Domain Name.</returns>
    /// <error>Cannot retrieve the Azure Active Directory tenant domain name.</error>
    procedure GetAadTenantDomainName(): Text
    begin
        exit(AzureADTenantImpl.GetAadTenantDomainName());
    end;
}

