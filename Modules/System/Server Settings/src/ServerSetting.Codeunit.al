// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to fetch some application server settings for the server which hosts the current tenant.
/// </summary>
codeunit 6723 "Server Setting"
{
    Access = Public;
    SingleInstance = true;

    var
        ServerSettingImpl: Codeunit "Server Setting Impl.";

    /// <summary>Checks whether online extensions can be installed on the server.</summary>
    /// <returns>True, if they can be installed; otherwise, false.</returns>
    /// <remarks>Gets the value of the server setting EnableSaasExtensionInstallConfigSetting.</remarks>
    [Scope('OnPrem')]
    procedure GetEnableSaaSExtensionInstallSetting(): Boolean
    begin
        exit(ServerSettingImpl.GetEnableSaaSExtensionInstallSetting());
    end;

    /// <summary>Checks whether Excel add-in is enabled on the server.</summary>
    /// <returns>True if enabled; otherwise, false.</returns>
    /// <remarks>Gets the value of the server setting IsSaasExcelAddinEnabled.</remarks>
    procedure GetIsSaasExcelAddinEnabled(): Boolean
    begin
        exit(ServerSettingImpl.GetIsSaasExcelAddinEnabled());
    end;

    /// <summary>Checks whether the API Services are enabled.</summary>
    /// <returns>True if enabled; otherwise, false.</returns>
    /// <remarks>Gets the value of the server setting ApiServicesEnabled.</remarks>
    [Scope('OnPrem')]
    procedure GetApiServicesEnabled(): Boolean
    begin
        exit(ServerSettingImpl.GetApiServicesEnabled());
    end;

    /// <summary>Checks whether the API subscriptions are enabled.</summary>
    /// <returns>True if enabled; otherwise, false.</returns>
    /// <remarks>Gets the value of the server setting ApiSubscriptionsEnabled.</remarks>
    [Scope('OnPrem')]
    procedure GetApiSubscriptionsEnabled(): Boolean
    begin
        exit(ServerSettingImpl.GetApiSubscriptionsEnabled());
    end;

    /// <summary>Gets the timeout for the notifications sent by API subscriptions.</summary>
    /// <returns>The timeout value in milliseconds.</returns>
    /// <remarks>Gets the value of the server setting ApiSubscriptionSendingNotificationTimeout.</remarks>
    [Scope('OnPrem')]
    procedure GetApiSubscriptionSendingNotificationTimeout(): Integer
    begin
        exit(ServerSettingImpl.GetApiSubscriptionSendingNotificationTimeout());
    end;

    /// <summary>Gets the maximum number of notifications that API subscriptions can send.</summary>
    /// <returns>The maximum number of notifications that can be sent.</returns>
    /// <remarks>Gets the value of the server setting ApiSubscriptionMaxNumberOfNotifications.</remarks>
    [Scope('OnPrem')]
    procedure GetApiSubscriptionMaxNumberOfNotifications(): Integer
    begin
        exit(ServerSettingImpl.GetApiSubscriptionMaxNumberOfNotifications());
    end;

    /// <summary>Gets the delay when starting to process API subscriptions.</summary>
    /// <returns>The time value in milliseconds.</returns>
    /// <remarks>Gets the value of the server setting ApiSubscriptionDelayTime.</remarks>
    [Scope('OnPrem')]
    procedure GetApiSubscriptionDelayTime(): Integer
    begin
        exit(ServerSettingImpl.GetApiSubscriptionDelayTime());
    end;

    /// <summary>Checks whether the Test Automation is enabled.</summary>
    /// <returns>True if enabled; otherwise, false.</returns>
    /// <remarks>Gets the value of the server setting TestAutomationEnabled.</remarks>
    [Scope('OnPrem')]
    procedure GetTestAutomationEnabled(): Boolean
    begin
        exit(ServerSettingImpl.GetTestAutomationEnabled());
    end;

    /// <summary>Checks whether permissions are read from the permission table in SQL or from metadata (.al code)</summary>
    /// <returns>True if enabled; otherwise, false.</returns>
    /// <remarks>Gets the value of the server setting UsePermissionSetsFromExtensions.</remarks>
    procedure GetUsePermissionSetsFromExtensions(): Boolean
    begin
        exit(ServerSettingImpl.GetUsePermissionSetsFromExtensions());
    end;

    /// <summary>Checks whether Entitlements are enabled</summary>
    /// <returns>True if enabled; otherwise false.</returns>
    /// <remarks>Gets the value of the server setting EnableMembershipEntitlement.</remarks>
    procedure GetEnableMembershipEntitlement(): Boolean
    begin
        exit(ServerSettingImpl.GetEnableMembershipEntitlement());
    end;
}

