// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132000 "Library - User Settings"
{
    /// <summary>
    /// Clears the settings for all users.
    /// </summary>
    procedure ClearAllSettings()
    var
        UserPersonalization: Record "User Personalization";
        ApplicationUserSettings: Record "Application User Settings";
    begin
        UserPersonalization.DeleteAll();
        ApplicationUserSettings.DeleteAll();
    end;

    /// <summary>
    /// Clears the settings for a user.
    /// </summary>
    /// <param name="UserSID">The user security ID</param>
    procedure ClearUserSettings(UserSID: Guid)
    var
        UserPersonalization: Record "User Personalization";
        ApplicationUserSettings: Record "Application User Settings";
    begin
        if UserPersonalization.Get(UserSID) then
            UserPersonalization.Delete();
        if ApplicationUserSettings.Get(UserSID) then
            ApplicationUserSettings.Delete();
    end;

    /// <summary>
    /// Clears the settings for the current user.
    /// </summary>
    procedure ClearCurrentUserSettings()
    begin
        ClearUserSettings(UserSecurityId())
    end;

    /// <summary>
    /// Creates user settings for a user
    /// </summary>
    /// <param name="UserSID">The user security ID</param>
    procedure CreateUserSettings(UserSID: Guid; var UserPersonalization: Record "User Personalization")
    begin
        if UserPersonalization.Get(UserSID) then
            exit;

        UserPersonalization.Init();
        UserPersonalization."User SID" := UserSID;
        UserPersonalization."Language ID" := 1026; // Bulgarian
        UserPersonalization.Insert();
    end;

}