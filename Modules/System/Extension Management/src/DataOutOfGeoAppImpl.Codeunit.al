// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 2505 "Data Out Of Geo. App Impl."
{
    Access = Internal;

    var
        GeoNotificationNewAppsMsg: Label 'This app may transfer data to other geographies than the current geography of your Dynamics 365 Business Central environment. This is to ensure proper functionality of the app.';
        GeoNotificationNewAppsIdTxt: Label '450a2e22-8051-44ed-94b9-e33304c375b0';

    procedure Add(AppID: Guid): Boolean
    begin
        exit(IsolatedStorage.Set(AppID, AppID, DataScope::Module));
    end;

    procedure Remove(AppID: Guid): Boolean
    begin
        if not IsolatedStorage.Contains(AppID, DataScope::Module) then
            exit(false);

        exit(IsolatedStorage.Delete(AppID, DataScope::Module));
    end;

    procedure Contains(AppID: Guid): Boolean
    begin
        Exit(IsolatedStorage.Contains(AppID, DataScope::Module));
    end;

    procedure AlreadyInstalled(): Boolean
    var
        NAVAppInstalledApp: Record "NAV App Installed App";
        Found: Boolean;
    begin
        if not NAVAppInstalledApp.FindSet() then
            exit(false);

        repeat
            if IsolatedStorage.Contains(NAVAppInstalledApp."App ID", DataScope::Module) then
                Found := true;
        until (NAVAppInstalledApp.Next() = 0) or Found;

        exit(Found);
    end;

    local procedure CreateNotification()
    var
        Notification: Notification;
    begin
        Notification.Id(GeoNotificationNewAppsIdTxt);
        Notification.Message(GeoNotificationNewAppsMsg);
        Notification.Send();
    end;

    internal procedure CheckAndFireNotification(AppID: Guid)
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if not EnvironmentInformation.IsSaaSInfrastructure() then
            exit;

        if Contains(AppID) then
            CreateNotification();
    end;
}