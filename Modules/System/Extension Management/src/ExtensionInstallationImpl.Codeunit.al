// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 2500 "Extension Installation Impl"
{
    Access = Internal;
    Permissions = TableData "NAV App Installed App" = rimd,
                  TableData "NAV App" = rimd;
    SingleInstance = false;

    var
        DotNetNavAppALInstaller: DotNet NavAppALInstaller;
        InstallerHasBeenCreated: Boolean;
        InstalledTxt: Label 'Installed';
        NotInstalledTxt: Label 'Not Installed';
        FullVersionStringTxt: Label '%1.%2.%3.%4', Comment = '%1=Version Major, %2=Version Minor, %3=Version build, %4=Version revision';
        NoRevisionVersionStringTxt: Label '%1.%2.%3', Comment = '%1=Version Major, %2=Version Minor, %3=Version build';
        NoBuildVersionStringTxt: Label '%1.%2', Comment = '%1=Version Major, %2=Version Minor';
        PermissionErr: Label 'You do not have the required permissions to install the selected app. Contact your Partner or system administrator to install the app or assign you permissions.';
        DependenciesFoundQst: Label 'The extension %1 has a dependency on one or more extensions: %2. \ \Do you want to install %1 and all of its dependencies?', Comment = '%1=name of app, %2=semicolon separated list of uninstalled dependencies';
        DependentsFoundQst: Label 'The extension %1 is a dependency for one or more extensions: %2. \ \Do you want to uninstall %1 and all of its dependents?', Comment = '%1=name of app, %2=semicolon separated list of installed dependents';
        AlreadyInstalledMsg: Label 'The extension %1 is already installed.', Comment = '%1=name of app';
        RestartActivityInstallMsg: Label 'The %1 extension was successfully installed. All active users must sign out and sign in again to see the navigation changes.', Comment = 'Indicates that users need to restart their activity to pick up new menusuite items. %1=Name of Extension';
        AlreadyUninstalledMsg: Label 'The extension %1 is not installed.', Comment = '%1=name of app';
        RestartActivityUninstallMsg: Label 'The %1 extension was successfully uninstalled. All active users must sign out and sign in again to see the navigation changes.', Comment = 'Indicates that users need to restart their activity to pick up new menusuite items. %1=Name of Extension';
        NotSufficientPermissionErr: Label 'You do not have sufficient permissions to manage extensions. Please contact your administrator.';

    procedure IsInstalledByPackageId(PackageID: Guid): Boolean
    var
        NAVAppInstalledApp: Record "NAV App Installed App";
    begin
        // Checks whether the user is entitled to make extension changes.
        if (not NAVAppInstalledApp.ReadPermission()) or (not NAVAppInstalledApp.WritePermission()) then
            Error(PermissionErr);

        NAVAppInstalledApp.SetRange("Package ID", PackageID);
        exit(not NAVAppInstalledApp.IsEmpty());
    end;

    procedure IsInstalledByAppId(AppID: Guid): Boolean
    var
        NAVAppInstalledApp: Record "NAV App Installed App";
    begin
        // Checks whether the user is entitled to make extension changes.
        if (not NAVAppInstalledApp.ReadPermission()) or (not NAVAppInstalledApp.WritePermission()) then
            Error(PermissionErr);

        exit(NAVAppInstalledApp.Get(AppID));
    end;

    procedure InstallExtension(PackageId: Guid; Lcid: Integer; IsUIEnabled: Boolean): Boolean
    var
        NavApp: Record "NAV App";
    begin
        CheckPermissions();
        if IsUIEnabled = true then
            exit(InstallExtensionWithConfirmDialog(PackageId, Lcid));

        if not NAVApp.Get(PackageId) then
            exit(false);

        exit(InstallExtensionSilently(PackageId, Lcid));
    end;

    procedure InstallExtensionSilently(PackageID: Guid; Lcid: Integer): Boolean
    begin
        CheckPermissions();
        AssertIsInitialized();
        DotNetNavAppALInstaller.ALInstallNavApp(PackageID, Lcid);

        if not IsInstalledByPackageId(PackageID) then
            exit(false);

        exit(true);
    end;

    procedure InstallExtensionWithConfirmDialog(PackageId: Guid; Lcid: Integer): Boolean
    var
        NAVApp: Record "NAV App";
        ConfirmManagement: Codeunit "Confirm Management";
        Dependencies: Text;
        CanChange: Boolean;
    begin
        CheckPermissions();
        if not NAVApp.Get(PackageId) then
            exit(false);

        if IsInstalledByPackageId(PackageId) then begin
            Message(StrSubstNo(AlreadyInstalledMsg, NAVApp.Name));
            exit(false);
        end;

        Dependencies := GetDependenciesForExtensionToInstall(PackageId);

        Dependencies := GetNonExcludedApps(Dependencies);
        CanChange := true;
        if StrLen(Dependencies) <> 0 then
            CanChange := ConfirmManagement.GetResponse(StrSubstNo(DependenciesFoundQst,
                  NAVApp.Name, Dependencies), false);

        if CanChange then
            InstallExtensionSilently(PackageId, Lcid);

        // If successfully installed, message users to restart activity for menusuites
        if IsInstalledByPackageId(PackageId) then
            Message(StrSubstNo(RestartActivityInstallMsg, NAVApp.Name))
        else
            exit(false);

        exit(true);
    end;

    procedure GetExtensionInstalledDisplayString(PackageId: Guid): Text
    begin
        if IsInstalledByPackageId(PackageId) then
            exit(InstalledTxt);

        exit(NotInstalledTxt);
    end;

    procedure GetDependenciesForExtensionToInstall(PackageID: Guid): Text
    begin
        AssertIsInitialized();
        exit(DotNetNavAppALInstaller.ALGetAppDependenciesToInstallString(PackageID));
    end;

    procedure GetDependentForExtensionToUninstall(PackageID: Guid): Text
    begin
        AssertIsInitialized();
        exit(DotNetNavAppALInstaller.ALGetDependentAppsToUninstallString(PackageID));
    end;

    local procedure AssertIsInitialized()
    begin
        if not InstallerHasBeenCreated then begin
            DotNetNavAppALInstaller := DotNetNavAppALInstaller.NavAppALInstaller();
            InstallerHasBeenCreated := true;
        end;
    end;

    local procedure CheckPermissions()
    var
        NAVAppObjectMetadata: Record "NAV App Object Metadata";
    begin
        if not NavAppObjectMetadata.ReadPermission() then
            Error(NotSufficientPermissionErr);
    end;

    procedure UninstallExtension(PackageID: Guid; IsUIEnabled: Boolean): Boolean
    var
        NAVApp: Record "NAV App";
    begin
        CheckPermissions();
        if IsUIEnabled = true then
            exit(UninstallExtensionWithConfirmDialog(PackageID));

        if not NAVApp.Get(PackageId) then
            exit(false);

        exit(UninstallExtensionSilently(PackageID));
    end;

    procedure UninstallExtensionSilently(PackageID: Guid): Boolean
    begin
        CheckPermissions();
        AssertIsInitialized();
        DotNetNavAppALInstaller.ALUninstallNavApp(PackageID);

        if IsInstalledByPackageId(PackageID) then
            exit(false);

        exit(true);
    end;

    procedure UninstallExtensionWithConfirmDialog(PackageId: Guid): Boolean
    var
        NAVApp: Record "NAV App";
        ConfirmManagement: Codeunit "Confirm Management";
        Dependents: Text;
        CanChange: Boolean;
    begin
        CheckPermissions();
        if not NAVApp.Get(PackageId) then
            exit(false);

        if not IsInstalledByPackageId(PackageId) then begin
            Message(StrSubstNo(AlreadyUninstalledMsg, NAVApp.Name));
            exit(false);
        end;

        Dependents := GetDependentForExtensionToUninstall(PackageId);

        Dependents := GetNonExcludedApps(Dependents);

        CanChange := true;
        if StrLen(Dependents) <> 0 then
            CanChange := ConfirmManagement.GetResponse(StrSubstNo(DependentsFoundQst,
                  NAVApp.Name, Dependents), false);

        if CanChange then
            UninstallExtensionSilently(PackageId)
        else
            exit(false);

        // If successfully uninstalled, message users to restart activity for menusuites
        if not IsInstalledByPackageId(PackageId) then
            Message(StrSubstNo(RestartActivityUninstallMsg, NAVApp.Name))
        else
            exit(false);

        exit(true);
    end;

    procedure GetNonExcludedApps(Dependents: Text): Text
    var
        newDependentsText: Text;
        auxString: Text;
        pos: Integer;
    begin
        newDependentsText := '';
        auxString := '';

        pos := StrPos(Dependents, ';');
        if pos = 0 then
            if StrPos(Dependents, '_Exclude_') > 0 then
                exit('')
            else
                exit(Dependents);

        while pos > 0 do begin
            auxString := CopyStr(Dependents, 1, pos);
            if StrPos(auxString, '_Exclude_') = 0 then
                newDependentsText := newDependentsText + auxString;

            Dependents := CopyStr(Dependents, pos + 1);
            pos := StrPos(Dependents, ';');
        end;

        exit(newDependentsText);
    end;

    procedure GetVersionDisplayString(NAVApp: Record "NAV App"): Text
    begin
        if NAVApp."Version Build" <= -1 then
            exit(StrSubstNo(NoBuildVersionStringTxt, NAVApp."Version Major", NAVApp."Version Minor"));

        if NAVApp."Version Revision" <= -1 then
            exit(StrSubstNo(NoRevisionVersionStringTxt, NAVApp."Version Major", NAVApp."Version Minor", NAVApp."Version Build"));

        exit(StrSubstNo(FullVersionStringTxt, NAVApp."Version Major",
            NAVApp."Version Minor", NAVApp."Version Build", NAVApp."Version Revision"));
    end;

    procedure IsInstalledNoPermissionCheck(ExtensionName: Text[250]): Boolean
    var
        NAVAppInstalledApp: Record "NAV App Installed App";
    begin
        NAVAppInstalledApp.SetFilter(Name, '%1', ExtensionName);
        exit(not NAVAppInstalledApp.IsEmpty());
    end;

    procedure RunExtensionInstallation(NAVApp: Record "NAV App"): Boolean
    var
        ExtensionDetails: Page "Extension Details";
    begin
        ExtensionDetails.SetRecord(NAVApp);
        ExtensionDetails.Run();
        exit(ExtensionDetails.Editable());
    end;
}

