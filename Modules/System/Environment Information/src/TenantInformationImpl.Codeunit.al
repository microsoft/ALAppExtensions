// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 3701 "Tenant Information Impl."
{
    Access = Internal;
    SingleInstance = true;

    var
        NavTenantSettingsHelper: DotNet NavTenantSettingsHelper;

    procedure GetTenantId() TenantIdValue: Text
    begin
        NavTenantSettingsHelper.TryGetStringTenantSetting('TENANTID', TenantIdValue);
    end;

    procedure GetTenantDisplayName() TenantNameValue: Text
    begin
        NavTenantSettingsHelper.TryGetStringTenantSetting('DISPLAYNAME', TenantNameValue);
    end;
}

