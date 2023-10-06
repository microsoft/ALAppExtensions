// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Azure.Identity;

using System;

codeunit 3705 "Azure AD Tenant Impl."
{
    Access = Internal;
    SingleInstance = true;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        NavTenantSettingsHelper: DotNet NavTenantSettingsHelper;
        TenantDomainNameErr: Label 'Failed to retrieve the Microsoft Entra tenant domain name.';

    procedure GetAadTenantId() TenantIdValue: Text
    begin
        NavTenantSettingsHelper.TryGetStringTenantSetting('AADTENANTID', TenantIdValue);
    end;

    procedure GetAadTenantDomainName(): Text;
    var
        AzureADGraph: Codeunit "Azure AD Graph";
        TenantInfo: DotNet TenantInfo;
    begin
        AzureADGraph.GetTenantDetail(TenantInfo);
        if not IsNull(TenantInfo) then
            exit(TenantInfo.InitialDomain());

        Error(TenantDomainNameErr);
    end;
}

