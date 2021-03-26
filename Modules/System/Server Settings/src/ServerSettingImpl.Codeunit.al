// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 3703 "Server Setting Impl."
{
    Access = Internal;
    SingleInstance = true;

    var
        ALConfigSettings: DotNet ALConfigSettings;
        IsInitialized: Boolean;

    local procedure InitializeConfigSettings()
    begin
        if IsInitialized then
            exit;
        ALConfigSettings := ALConfigSettings.Instance();
        IsInitialized := true;
    end;

    procedure GetEnableSaaSExtensionInstallSetting() EnableSaaSExtensionInstall: Boolean
    begin
        InitializeConfigSettings();
        EnableSaaSExtensionInstall := ALConfigSettings.EnableSaasExtensionInstallConfigSetting();
        exit(EnableSaaSExtensionInstall);
    end;

    procedure GetIsSaasExcelAddinEnabled() SaasExcelAddinEnabled: Boolean
    begin
        InitializeConfigSettings();
        SaasExcelAddinEnabled := ALConfigSettings.IsSaasExcelAddinEnabled();
        exit(SaasExcelAddinEnabled);
    end;

    procedure GetApiServicesEnabled() ApiEnabled: Boolean
    begin
        InitializeConfigSettings();
        ApiEnabled := ALConfigSettings.ApiServicesEnabled();
        exit(ApiEnabled);
    end;

    procedure GetApiSubscriptionsEnabled() ApiSubscriptionsEnabled: Boolean
    begin
        InitializeConfigSettings();
        ApiSubscriptionsEnabled := ALConfigSettings.ApiSubscriptionsEnabled();
        exit(ApiSubscriptionsEnabled);
    end;

    procedure GetApiSubscriptionSendingNotificationTimeout() Timeout: Integer
    begin
        InitializeConfigSettings();
        Timeout := ALConfigSettings.ApiSubscriptionSendingNotificationTimeout();
        exit(Timeout);
    end;

    procedure GetApiSubscriptionMaxNumberOfNotifications() MaxNoOfNotifications: Integer
    begin
        InitializeConfigSettings();
        MaxNoOfNotifications := ALConfigSettings.ApiSubscriptionMaxNumberOfNotifications();
        exit(MaxNoOfNotifications);
    end;

    procedure GetApiSubscriptionDelayTime() DelayTime: Integer
    begin
        InitializeConfigSettings();
        DelayTime := ALConfigSettings.ApiSubscriptionDelayTime();
        exit(DelayTime);
    end;

    procedure GetTestAutomationEnabled() Enabled: Boolean
    begin
        InitializeConfigSettings();
        Enabled := ALConfigSettings.TestAutomationEnabled();
        exit(Enabled);
    end;

    procedure GetUsePermissionSetsFromExtensions(): Boolean
    begin
        InitializeConfigSettings();
        exit(ALConfigSettings.UsePermissionsFromExtensions());
    end;

    procedure GetEnableMembershipEntitlement(): Boolean
    begin
        InitializeConfigSettings();
        exit(ALConfigSettings.IsSaaS());
    end;
}

