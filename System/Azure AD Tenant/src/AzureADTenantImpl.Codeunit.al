// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 3705 "Azure AD Tenant Impl."
{
    Access = Internal;
    SingleInstance = true;

    var
        NavTenantSettingsHelper: DotNet NavTenantSettingsHelper;
        AADTenantDomainNameErr: Label 'Failed to retrieve the Azure Active Directory tenant domain name.';

    procedure GetAadTenantId() TenantAadIdValue: Text
    begin
        NavTenantSettingsHelper.TryGetStringTenantSetting('AADTENANTID', TenantAadIdValue);
    end;

    procedure GetAadTenantDomainName(): Text;
    var
        AzureADGraph: Codeunit "Azure AD Graph";
        TenantInfo: DotNet TenantInfo;
    begin
        AzureADGraph.GetTenantDetail(TenantInfo);
        if not IsNull(TenantInfo) then
            exit(TenantInfo.InitialDomain());

        Error(AADTenantDomainNameErr);
    end;
}

