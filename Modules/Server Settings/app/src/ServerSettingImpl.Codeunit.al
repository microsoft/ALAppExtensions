// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 3703 "Server Setting Impl."
{
    SingleInstance = true;

    trigger OnRun()
    begin
    end;

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

    [Scope('OnPrem')]
    procedure GetEnableSaaSExtensionInstallSetting() EnableSaaSExtensionInstall: Boolean
    begin
        InitializeConfigSettings();
        EnableSaaSExtensionInstall := ALConfigSettings.EnableSaasExtensionInstallConfigSetting();
        exit(EnableSaaSExtensionInstall);
    end;

    [Scope('OnPrem')]
    procedure GetIsSaasExcelAddinEnabled() SaasExcelAddinEnabled: Boolean
    begin
        InitializeConfigSettings();
        SaasExcelAddinEnabled := ALConfigSettings.IsSaasExcelAddinEnabled();
        exit(SaasExcelAddinEnabled);
    end;

    [Scope('OnPrem')]
    procedure GetApiServicesEnabled() ApiEnabled: Boolean
    begin
        InitializeConfigSettings();
        ApiEnabled := ALConfigSettings.ApiServicesEnabled();
        exit(ApiEnabled);
    end;

    [Scope('OnPrem')]
    procedure GetApiSubscriptionsEnabled() ApiSubscriptionsEnabled: Boolean
    begin
        InitializeConfigSettings();
        ApiSubscriptionsEnabled := ALConfigSettings.ApiSubscriptionsEnabled();
        exit(ApiSubscriptionsEnabled);
    end;

    [Scope('OnPrem')]
    procedure GetApiSubscriptionSendingNotificationTimeout() Timeout: Integer
    begin
        InitializeConfigSettings();
        Timeout := ALConfigSettings.ApiSubscriptionSendingNotificationTimeout();
        exit(Timeout);
    end;

    [Scope('OnPrem')]
    procedure GetApiSubscriptionMaxNumberOfNotifications() MaxNoOfNotifications: Integer
    begin
        InitializeConfigSettings();
        MaxNoOfNotifications := ALConfigSettings.ApiSubscriptionMaxNumberOfNotifications();
        exit(MaxNoOfNotifications);
    end;

    [Scope('OnPrem')]
    procedure GetApiSubscriptionDelayTime() DelayTime: Integer
    begin
        InitializeConfigSettings();
        DelayTime := ALConfigSettings.ApiSubscriptionDelayTime();
        exit(DelayTime);
    end;
}

