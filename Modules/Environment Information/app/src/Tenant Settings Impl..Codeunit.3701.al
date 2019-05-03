// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 3701 "Tenant Settings Impl."
{
    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        NavTenantSettingsHelper: DotNet NavTenantSettingsHelper;

    [Scope('OnPrem')]
    procedure GetTenantId() TenantIdValue: Text
    begin
        NavTenantSettingsHelper.TryGetStringTenantSetting('TENANTID',TenantIdValue);
    end;

    [Scope('OnPrem')]
    procedure GetAadTenantId() TenantAadIdValue: Text
    begin
        NavTenantSettingsHelper.TryGetStringTenantSetting('AADTENANTID',TenantAadIdValue);
    end;

    [Scope('OnPrem')]
    procedure GetTenantDisplayName() TenantNameValue: Text
    begin
        NavTenantSettingsHelper.TryGetStringTenantSetting('DISPLAYNAME',TenantNameValue);
    end;

    [Scope('OnPrem')]
    procedure GetApplicationFamily(): Text
    begin
        exit(NavTenantSettingsHelper.GetApplicationFamily);
    end;
}

