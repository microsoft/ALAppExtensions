// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides basic functionality for user settings. 
/// </summary>
codeunit 9176 "User Settings"
{
    /// <summary>
    /// Gets the page id for the User Settings page.
    /// </summary>
    /// <returns>The page ID for the User Settings page.</returns>
    procedure GetPageId(): Integer
    var
        UserSettingsImpl: Codeunit "User Settings Impl.";
    begin
        exit(UserSettingsImpl.GetPageId());
    end;

    /// <summary>
    /// Gets the settings for the given user.
    /// </summary>
    /// <param name="UserSecurityID">The user security id of the user.</param>
    /// <param name="UserSettings">The return Record with the settings od the User.</param>
    procedure GetUserSettings(UserSecurityID: Guid; var UserSettings : Record "User Settings") 
    var
        UserSettingsImpl: Codeunit "User Settings Impl.";
    begin
        UserSettingsImpl.GetUserSettings(UserSecurityID, UserSettings);
    end;

    /// <summary>
    /// Disables the teaching tips for a given user.
    /// </summary>
    /// <param name="UserSecurityID">The user security id of the user.</param>
    procedure DisableTeachingTips(UserSecurityId: Guid)
    var
        UserSettingsImpl: Codeunit "User Settings Impl.";
    begin
        UserSettingsImpl.DisableTeachingTips(UserSecurityId);
    end;

    /// <summary>
    /// Enables the teaching tips for a given user.
    /// </summary>
    /// <param name="UserSecurityID">The user security id of the user.</param>
    procedure EnableTeachingTips(UserSecurityId: Guid)
    var
        UserSettingsImpl: Codeunit "User Settings Impl.";
    begin
        UserSettingsImpl.EnableTeachingTips(UserSecurityId);
    end;

    /// <summary>
    /// Integration event to get the default profile.
    /// </summary>
    /// <param name="AllProfile">The return record that holds the default profile.</param>
    [IntegrationEvent(false, false)]
    procedure OnGetDefaultProfile(var AllProfile: Record "All Profile")
    begin
    end;
    
    /// <summary>
    /// Integration event that allows changing the settings page ID.
    /// </summary>
    /// <param name="SettingsPageID">The new page ID for the user settings page.</param>
    [IntegrationEvent(false, false)]
    procedure OnGetSettingsPageID(var SettingsPageID: Integer)
    begin
    end;

    /// <summary>
    /// Integration event that allows changing the behavior of opening the settings page.
    /// </summary>
    /// <param name="Handled">Set to true to skip the default behavior.</param>
    [IntegrationEvent(false, false)]
    procedure OnBeforeOpenSettings(var Handled: Boolean)
    begin
    end;

    /// <summary>
    /// Integration event that allows updating the User Settings record with extra values.
    /// </summary>
    /// <param name="UserSettings">The User settings record to update.</param>
    [IntegrationEvent(false, false)]
    procedure OnAfterGetUserSettings(var UserSettings: Record "User Settings")
    begin
    end;

    /// <summary>
    /// Integration event that allows updating the settings on related records.
    /// </summary>
    /// <param name="OldSettings">The value of the settings before any user interaction.</param>
    /// <param name="NewSettings">The value of the settings after user interaction.</param>
    [IntegrationEvent(false, false)]
    procedure OnUpdateUserSettings(OldSettings: Record "User Settings"; NewSettings: Record "User Settings")
    begin
    end;

    /// <summary>
    /// Integration event that fires every time the company is changed.
    /// </summary>
    /// <param name="NewCompanyName">The name of the new company.</param>
    /// <param name="IsSetupInProgress">Set to true if the given company is still setting up.</param>
    [IntegrationEvent(false, false)]
    procedure OnCompanyChange(NewCompanyName: Text; var IsSetupInProgress: Boolean)
    begin
    end;

#if not CLEAN19
    /// <summary>
    /// Integration event that fires every time the Role Center is changed.
    /// </summary>
    /// <param name="NewAllProfile">The All Profile Record that holds the new profile.</param>
    [Obsolete('Use "OnUpdateUserSettings" event instead.', '19.0')]
    [IntegrationEvent(false, false)]
    procedure OnUserRoleCenterChange(NewAllProfile: Record "All Profile")
    begin
    end;

    /// <summary>
    /// Integration event that fires every time the settings page closes.
    /// </summary>
    /// <param name="NewLanguageID">The Language ID selected.</param>
    /// <param name="NewLocaleID">The Locale ID selected.</param>
    /// <param name="NewTimeZoneID">The Time Zone selected.</param>
    /// <param name="NewCompany">The company selected.</param>
    /// <param name="NewAllProfile">The All Profile Record that holds the new profile.</param>
    [Obsolete('Use "OnUpdateUserSettings" event instead.', '19.0')]
    [IntegrationEvent(false, false)]
    procedure OnAfterQueryClosePage(NewLanguageID: Integer; NewLocaleID: Integer; NewTimeZoneID: Text[180]; NewCompany: Text; NewAllProfile: Record "All Profile")
    begin
    end;

    /// <summary>
    /// Integration event that fires every time the Language changes.
    /// </summary>
    /// <param name="OldLanguageId">The old Language ID.</param>
    /// <param name="NewLanguageId">The new Language ID selected.</param>
    [Obsolete('Use "OnUpdateUserSettings" event instead.', '19.0')]
    [IntegrationEvent(false, false)]
    procedure OnBeforeLanguageChange(OldLanguageId: Integer; NewLanguageId: Integer)
    begin
    end;

    /// <summary>
    /// Integration event that fires every time the work date changes.
    /// </summary>
    /// <param name="OldWorkdate">The old work date.</param>
    /// <param name="NewWorkdate">The new work date selected.</param>
    [Obsolete('Use "OnUpdateUserSettings" event instead.', '19.0')]
    [IntegrationEvent(false, false)]
    procedure OnBeforeWorkdateChange(OldWorkdate: Date; NewWorkdate: Date)
    begin
    end;    
#endif
}