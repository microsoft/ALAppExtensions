// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 2500 "Extension Installation Impl"
{
    Access = Internal;
    Permissions = tabledata "NAV App Installed App" = rimd,
                  tabledata "Published Application" = rimd;
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
        ClearExtensionSchemaQst: Label 'Enabling Delete Extension Data will delete the tables that contain data for the %1 extension and all of its dependents on uninstall. This action cannot be undone. Do you want to continue?', Comment = '%1=name of app';
        ClearExtensionSchemaMsg: Label 'You have selected to delete extension data for the %1 extension and all of its dependents: %2. Continuing uninstall will delete the tables that contain data for the %1 extension and all of its dependents. This action cannot be undone. Do you want to continue?', Comment = '%1=name of app ,%2= all dependent extensions';
        NotSufficientPermissionErr: Label 'You do not have sufficient permissions to manage extensions. Please contact your administrator.';
        InstallationBestPracticesUrlLbl: Label 'https://go.microsoft.com/fwlink/?linkid=2138922', comment = 'link to the best practices and tips about the installing and publishing a new extension.', Locked = true;
        DisclaimerUrlLbl: Label 'https://go.microsoft.com/fwlink/?linkid=2193002&clcid=0x409', comment = 'link to the Business Central PTE disclaimer.', Locked = true;
        PrivacyPolicyUrlLbl: Label 'https://go.microsoft.com/fwlink/?LinkId=521839', comment = 'link to the privacy and cookies docs.', Locked = true;

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
        PublishedApplication: Record "Published Application";
    begin
        CheckPermissions();
        if IsUIEnabled = true then
            exit(InstallExtensionWithConfirmDialog(PackageId, Lcid));

        PublishedApplication.SetRange("Package ID", PackageId);
        PublishedApplication.SetRange("Tenant Visible", true);
        if PublishedApplication.IsEmpty() then
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
        PublishedApplication: Record "Published Application";
        ConfirmManagement: Codeunit "Confirm Management";
        Dependencies: Text;
        CanChange: Boolean;
    begin
        CheckPermissions();

        PublishedApplication.SetRange("Package ID", PackageId);
        PublishedApplication.SetRange("Tenant Visible", true);
        if not PublishedApplication.FindFirst() then
            exit(false);

        if IsInstalledByPackageId(PackageId) then begin
            Message(StrSubstNo(AlreadyInstalledMsg, PublishedApplication.Name));
            exit(false);
        end;

        Dependencies := GetDependenciesForExtensionToInstall(PackageId);

        Dependencies := GetNonExcludedApps(Dependencies);
        CanChange := true;
        if StrLen(Dependencies) <> 0 then
            CanChange := ConfirmManagement.GetResponse(StrSubstNo(DependenciesFoundQst,
                  PublishedApplication.Name, Dependencies), false);

        if CanChange then
            InstallExtensionSilently(PackageId, Lcid);

        // If successfully installed, message users to restart activity for menusuites
        if IsInstalledByPackageId(PackageId) then
            Message(StrSubstNo(RestartActivityInstallMsg, PublishedApplication.Name))
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

    procedure GetExtensionInstalledDisplayString(Installed: Boolean): Text
    begin
        if Installed then
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
    begin
        if not CanManageExtensions() then
            Error(NotSufficientPermissionErr);
    end;

    procedure CanManageExtensions(): Boolean
    var
        ApplicationObjectMetadata: Record "Application Object Metadata";
    begin
        exit(ApplicationObjectMetadata.ReadPermission());
    end;

    procedure UninstallExtension(PackageID: Guid; IsUIEnabled: Boolean): Boolean
    begin
        exit(UninstallExtension(PackageID, IsUIEnabled, false));
    end;

    procedure UninstallExtension(PackageID: Guid; IsUIEnabled: Boolean; ClearSchema: Boolean): Boolean
    var
        PublishedApplication: Record "Published Application";
    begin
        CheckPermissions();
        if IsUIEnabled = true then
            exit(UninstallExtensionWithConfirmDialog(PackageID, ClearSchema, ClearSchema));

        PublishedApplication.SetRange("Package ID", PackageID);
        PublishedApplication.SetRange("Tenant Visible", true);

        if PublishedApplication.IsEmpty() then
            exit(false);

        exit(UninstallExtensionSilently(PackageID, ClearSchema, ClearSchema));
    end;

    local procedure UninstallExtensionSilently(PackageID: Guid; ClearData: Boolean; ClearSchema: Boolean): Boolean
    begin
        CheckPermissions();
        AssertIsInitialized();
        DotNetNavAppALInstaller.ALUninstallNavApp(PackageID, ClearData, ClearSchema);

        if IsInstalledByPackageId(PackageID) then
            exit(false);

        exit(true);
    end;

    procedure UninstallExtensionWithConfirmDialog(PackageId: Guid; ClearData: Boolean; ClearSchema: Boolean): Boolean
    var
        PublishedApplication: Record "Published Application";
        ConfirmManagement: Codeunit "Confirm Management";
        Dependents: Text;
    begin
        CheckPermissions();

        PublishedApplication.SetRange("Package ID", PackageId);
        PublishedApplication.SetRange("Tenant Visible", true);
        if not PublishedApplication.FindFirst() then
            exit(false);

        if not IsInstalledByPackageId(PackageId) then begin
            Message(StrSubstNo(AlreadyUninstalledMsg, PublishedApplication.Name));
            exit(false);
        end;

        Dependents := GetDependentForExtensionToUninstall(PackageId);

        Dependents := GetNonExcludedApps(Dependents);

        if StrLen(Dependents) <> 0 then
            if not ConfirmManagement.GetResponse(
                StrSubstNo(DependentsFoundQst, PublishedApplication.Name, Dependents), false)
            then
                exit(false);

        if ClearSchema then
            if not ConfirmManagement.GetResponse(
                StrSubstNo(ClearExtensionSchemaMsg, PublishedApplication.Name, Dependents), false)
            then
                exit(false);

        UninstallExtensionSilently(PackageId, ClearData, ClearSchema);

        // If successfully uninstalled, message users to restart activity for menusuites
        if not IsInstalledByPackageId(PackageId) then
            Message(StrSubstNo(RestartActivityUninstallMsg, PublishedApplication.Name))
        else
            exit(false);

        exit(true);
    end;

    procedure GetClearExtensionSchemaConfirmation(PackageId: Guid; var ClearSchema: Boolean)
    var
        PublishedApplication: Record "Published Application";
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if not ClearSchema then
            exit;

        PublishedApplication.SetRange("Package ID", PackageId);
        PublishedApplication.SetRange("Tenant Visible", true);
        if not PublishedApplication.FindFirst() then
            ClearSchema := false
        else
            ClearSchema := ConfirmManagement.GetResponse(
                StrSubstNo(ClearExtensionSchemaQst, PublishedApplication.Name), false);
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

    procedure GetVersionDisplayString(PublishedApplication: Record "Published Application"): Text
    begin
        if PublishedApplication."Version Build" <= -1 then
            exit(StrSubstNo(NoBuildVersionStringTxt, PublishedApplication."Version Major", PublishedApplication."Version Minor"));

        if PublishedApplication."Version Revision" <= -1 then
            exit(StrSubstNo(NoRevisionVersionStringTxt, PublishedApplication."Version Major", PublishedApplication."Version Minor", PublishedApplication."Version Build"));

        exit(StrSubstNo(FullVersionStringTxt, PublishedApplication."Version Major",
            PublishedApplication."Version Minor", PublishedApplication."Version Build", PublishedApplication."Version Revision"));
    end;

    procedure GetInstallationBestPracticesURL(): Text;
    begin
        exit(InstallationBestPracticesUrlLbl);
    end;

    procedure GetDisclaimerURL(): Text;
    begin
        exit(DisclaimerUrlLbl);
    end;

    procedure GetPrivacyAndCookeisURL(): Text;
    begin
        exit(PrivacyPolicyUrlLbl);
    end;

    procedure RunExtensionInstallation(PublishedApplication: Record "Published Application"): Boolean
    var
        ExtensionDetails: Page "Extension Details";
    begin
        ExtensionDetails.SetRecord(PublishedApplication);
        ExtensionDetails.Run();
        exit(ExtensionDetails.Editable());
    end;
}

