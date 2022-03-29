// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 2503 "Extension Operation Impl"
{
    Access = Internal;
    SingleInstance = false;
    Permissions = tabledata Media = r,
                  tabledata "NAV App Setting" = rm,
                  tabledata "NAV App Tenant Operation" = r,
                  tabledata "Published Application" = r;

    var
        DotNetALNavAppOperationInvoker: DotNet ALNavAppOperationInvoker;
        DotNetNavAppALInstaller: DotNet NavAppALInstaller;
        OperationInvokerHasBeenCreated: Boolean;
        InstallerHasBeenCreated: Boolean;
        ExtensionFileNameTxt: Label '%1_%2_%3.zip', Comment = '%1=Name, %2=Publisher, %3=Version', Locked = true;
        OperationProgressMsg: Label 'We are installing the extension. You can view the progress on the Status page.';
        CurrentOperationProgressMsg: Label 'Extension deployment is in progress. Please check the Deployment Status page for updates.';
        ScheduledOperationMajorProgressMsg: Label 'Extension deployment has been scheduled for the next major version. Please check the Deployment Status page for updates.';
        ScheduledOperationMinorProgressMsg: Label 'Extension deployment has been scheduled for the next minor version. Please check the Deployment Status page for updates.';
        DownloadExtensionSourceIsNotAllowedErr: Label 'The effective policies for this package do not allow you to download the source code. Contact the extension provider for more information.';
        DialogTitleTxt: Label 'Export';
        OutExtTxt: Label 'Text Files (*.txt)|*.txt|*.*';
        NotSufficientPermissionErr: Label 'You do not have sufficient permissions to manage extensions. Please contact your administrator.';

    local procedure AssertIsInitialized()
    begin
        if not InstallerHasBeenCreated then begin
            DotNetNavAppALInstaller := DotNetNavAppALInstaller.NavAppALInstaller();
            InstallerHasBeenCreated := true;
        end;
    end;

    procedure DeployExtension(AppId: Guid; lcid: Integer; IsUIEnabled: Boolean)
    begin
        CheckPermissions();
        InitializeOperationInvoker();
        DotNetALNavAppOperationInvoker.DeployTarget(AppId, Format(lcid));
        if IsUIEnabled then
            Message(OperationProgressMsg);
    end;


    procedure UploadExtension(PackageInStream: InStream; lcid: Integer)
    var
        DotNetALPackageDeploymentSchedule: DotNet ALPackageDeploymentSchedule;
    begin
        CheckPermissions();
        DotNetALPackageDeploymentSchedule := DotNetALPackageDeploymentSchedule.Immediate;
        InitializeOperationInvoker();
        DotNetALNavAppOperationInvoker.UploadPackage(PackageInStream, DotNetALPackageDeploymentSchedule, Format(lcid));
    end;

    procedure DeployAndUploadExtension(PackageInStream: InStream; lcid: Integer; DeployTo: Enum "Extension Deploy To"; SyncMode: Enum "Extension Sync Mode")
    var
        DotNetALPackageDeploymentSchedule: DotNet ALPackageDeploymentSchedule;
        DotNetALNavAppSyncMode: DotNet ALNavAppSyncMode;
    begin
        CheckPermissions();
        InitializeOperationInvoker();

        case SyncMode of
            SyncMode::Add:
                DotNetALNavAppSyncMode := DotNetALNavAppSyncMode.Add;
            SyncMode::"Force Sync":
                DotNetALNavAppSyncMode := DotNetALNavAppSyncMode.ForceSync;
        end;

        case DeployTo of
            DeployTo::"Current version":
                begin
                    DotNetALPackageDeploymentSchedule := DotNetALPackageDeploymentSchedule.Immediate;
                    DotNetALNavAppOperationInvoker.UploadPackage(PackageInStream, DotNetALPackageDeploymentSchedule, Format(lcid), DotNetALNavAppSyncMode);
                    Message(CurrentOperationProgressMsg);
                end;
            DeployTo::"Next minor version":
                begin
                    DotNetALPackageDeploymentSchedule := DotNetALPackageDeploymentSchedule.StageForNextMinorUpdate;
                    DotNetALNavAppOperationInvoker.UploadPackage(PackageInStream, DotNetALPackageDeploymentSchedule, Format(lcid), DotNetALNavAppSyncMode);
                    Message(ScheduledOperationMinorProgressMsg);
                end;
            DeployTo::"Next major version":
                begin
                    DotNetALPackageDeploymentSchedule := DotNetALPackageDeploymentSchedule.StageForNextUpdate;
                    DotNetALNavAppOperationInvoker.UploadPackage(PackageInStream, DotNetALPackageDeploymentSchedule, Format(lcid), DotNetALNavAppSyncMode);
                    Message(ScheduledOperationMajorProgressMsg);
                end;
        end;
    end;

    procedure UnpublishExtension(PackageID: Guid): Boolean
    var
        PublishedApplication: Record "Published Application";
        ExtensionInstallationImpl: Codeunit "Extension Installation Impl";
    begin
        PublishedApplication.SetRange("Package ID", PackageID);
        PublishedApplication.SetRange("Tenant Visible", true);
        PublishedApplication.SetFilter("Published As", '<>%1', PublishedApplication."Published As"::Global);

        if PublishedApplication.IsEmpty() then
            exit(false);

        if ExtensionInstallationImpl.IsInstalledByPackageId(PackageID) then
            exit(false);

        UnpublishUninstalledPerTenantExtension(PackageID);
        exit(true);
    end;

    procedure UnpublishUninstalledPerTenantExtension(PackageID: Guid)
    begin
        CheckPermissions();
        AssertIsInitialized();
        DotNetNavAppALInstaller.ALUnpublishNavTenantApp(PackageID);
    end;

    procedure GetExtensionSource(PackageId: Guid; var ExtensionSourceTempBlob: Codeunit "Temp Blob"; var CleanFileName: Text): Boolean
    var
        PublishedApplication: Record "Published Application";
        ExtensionInstallationImpl: Codeunit "Extension Installation Impl";
        DotNetNavDesignerALFunctions: DotNet NavDesignerALFunctions;
        NvOutStream: OutStream;
        FileName: Text;
        VersionString: Text;
    begin
        CheckPermissions();

        PublishedApplication.SetRange("Package ID", PackageID);
        PublishedApplication.SetRange("Tenant Visible", true);
        PublishedApplication.SetFilter("Published As", '<>%1', PublishedApplication."Published As"::Global);

        if not PublishedApplication.FindFirst() then
            exit(false);

        if not DotNetNavDesignerALFunctions.IsDownloadSourceCodeAllowedForCurrentUser(PublishedApplication."Runtime Package ID") then
            Error(DownloadExtensionSourceIsNotAllowedErr);

        ExtensionSourceTempBlob.CreateOutStream(NvOutStream);
        VersionString := ExtensionInstallationImpl.GetVersionDisplayString(PublishedApplication);

        DotNetNavDesignerALFunctions.GenerateDesignerPackageZipStreamByVersion(NvOutStream, PublishedApplication.ID, VersionString);

        FileName := StrSubstNo(ExtensionFileNameTxt, PublishedApplication.Name, PublishedApplication.Publisher, VersionString);
        CleanFileName := DotNetNavDesignerALFunctions.SanitizeDesignerFileName(FileName, '_');

        exit(true);
    end;

    procedure DownloadExtensionSource(PackageId: Guid): Boolean
    var
        TempBlob: Codeunit "Temp Blob";
        NvInStream: InStream;
        CleanFileName: Text;
    begin
        if not GetExtensionSource(PackageId, TempBlob, CleanFileName) then
            exit(false);

        TempBlob.CreateInStream(NvInStream);

        exit(DownloadFromStream(NvInStream, DialogTitleTxt, '', '*.*', CleanFileName));
    end;

    procedure DownloadDeploymentStatusDetails(OperationId: Guid)
    var
        TempBlob: Codeunit "Temp Blob";
        NavOutStream: OutStream;
        NavInStream: InStream;
        ToFile: Text;
    begin
        TempBlob.CreateOutStream(NavOutStream);
        GetDeploymentDetailedStatusMessageAsStream(OperationId, NavOutStream);

        TempBlob.CreateInStream(NavInStream);
        ToFile := 'Result' + OperationId + '.txt';
        DownloadFromStream(NavInStream, DialogTitleTxt, '', OutExtTxt, ToFile);
    end;

    procedure RefreshStatus(OperationID: Guid)
    begin
        InitializeOperationInvoker();
        DotNetALNavAppOperationInvoker.RefreshOperationStatus(OperationID);
    end;

    procedure ConfigureExtensionHttpClientRequestsAllowance(PackageId: Text; AreHttpClientRqstsAllowed: Boolean): Boolean
    var
        PublishedApplication: Record "Published Application";
        NavAppSetting: Record "NAV App Setting";
        PackageIDGuid: Guid;
    begin
        CheckPermissions();

        Evaluate(PackageIDGuid, PackageId);

        PublishedApplication.SetRange("Package ID", PackageIdGuid);
        PublishedApplication.SetRange("Tenant Visible", true);

        if not PublishedApplication.FindFirst() then
            exit(false);

        if not NavAppSetting.Get(PublishedApplication.ID) then
            exit(false);

        NavAppSetting.Validate("Allow HttpClient Requests", AreHttpClientRqstsAllowed);
        NavAppSetting.Modify(true);

        exit(true);
    end;

    local procedure InitializeOperationInvoker()
    begin
        if not OperationInvokerHasBeenCreated then begin
            DotNetALNavAppOperationInvoker := DotNetALNavAppOperationInvoker.ALNavAppOperationInvoker();
            OperationInvokerHasBeenCreated := true;
        end;
    end;

    local procedure CheckPermissions()
    var
        ApplicationObjectMetadata: Record "Application Object Metadata";
    begin
        if not ApplicationObjectMetadata.ReadPermission() then
            Error(NotSufficientPermissionErr);
    end;

#if not CLEAN17
    [Obsolete('This is the implementation of a method for which the required parameter is not accessible for Cloud development', '17.0')]
    procedure GetAllExtensionDeploymentStatusEntries(var NavAppTenantOperation: Record "NAV App Tenant Operation")
    begin
        if not NavAppTenantOperation.FindSet() then
            exit;
    end;
#endif

    procedure GetAllExtensionDeploymentStatusEntries(var TempExtensionDeploymentStatus: Record "Extension Deployment Status" temporary)
    var
        NavAppTenantOperation: Record "NAV App Tenant Operation";
    begin
        if not NavAppTenantOperation.FindSet() then
            exit;
        repeat
            TempExtensionDeploymentStatus.TransferFields(NavAppTenantOperation, true);
            TempExtensionDeploymentStatus.Insert();
        until NavAppTenantOperation.Next() = 0;
    end;

    procedure GetDeploymentDetailedStatusMessageAsStream(OperationId: Guid; OutStream: OutStream)
    begin
        InitializeOperationInvoker();
        DotNetALNavAppOperationInvoker.GetOperationDetailedStatusMessageAsStream(OperationId, OutStream);
    end;

    procedure GetDeploymentDetailedStatusMessage(OperationId: Guid): Text
    begin
        InitializeOperationInvoker();
        exit(DotNetALNavAppOperationInvoker.GetOperationDetailedStatusMessage(OperationId));
    end;

    procedure GetDeployOperationInfo(OperationId: Guid; var Version: Text; var Schedule: Text; var Publisher: Text; var AppName: Text; Description: Text)
    begin
        CheckPermissions();
        AppName := GetDeployOperationAppName(OperationId);
        if AppName = '' then
            AppName := Description;
        Publisher := GetDeployOperationAppPublisher(OperationId);
        Version := GetDeployOperationAppVersion(OperationId);
        Schedule := GetDeployOperationSchedule(OperationId);
    end;

    procedure GetDeployOperationAppName(OperationId: Guid): Text
    begin
        InitializeOperationInvoker();
        exit(DotNetALNavAppOperationInvoker.GetDeployOperationAppName(OperationId));
    end;

    procedure GetDeployOperationAppPublisher(OperationId: Guid): Text
    begin
        InitializeOperationInvoker();
        exit(DotNetALNavAppOperationInvoker.GetDeployOperationAppPublisher(OperationId));
    end;

    procedure GetDeployOperationAppVersion(OperationId: Guid): Text
    begin
        InitializeOperationInvoker();
        exit(DotNetALNavAppOperationInvoker.GetDeployOperationAppVersion(OperationId));
    end;

    procedure GetDeployOperationSchedule(OperationId: Guid): Text
    begin
        InitializeOperationInvoker();
        exit(DotNetALNavAppOperationInvoker.GetDeployOperationSchedule(OperationId));
    end;

    procedure GetDeployOperationJobId(OperationId: Guid): Text
    begin
        InitializeOperationInvoker();
        exit(DotNetALNavAppOperationInvoker.GetDeployOperationJobId(OperationId));
    end;

    procedure GetLatestVersionPackageIdByAppId(AppId: Guid): Guid
    var
        PublishedApplication: Record "Published Application";
        NullGuid: Guid;
    begin
        PublishedApplication.SetRange(ID, AppId);
        PublishedApplication.SetRange("Tenant Visible", true);
        PublishedApplication.SetCurrentKey(Name, "Version Major", "Version Minor", "Version Build", "Version Revision");
        PublishedApplication.Ascending(false);

        if PublishedApplication.FindFirst() then
            exit(PublishedApplication."Package ID");

        exit(NullGuid);
    end;

    procedure GetCurrentlyInstalledVersionPackageIdByAppId(AppId: Guid): Guid
    var
        NavAppInstalledApp: Record "NAV App Installed App";
        NullGuid: Guid;
    begin
        if NavAppInstalledApp.Get(AppId) then
            exit(NavAppInstalledApp."Package ID");

        exit(NullGuid);
    end;

    procedure GetSpecificVersionPackageIdByAppId(AppId: Guid; Name: Text; VersionMajor: Integer; VersionMinor: Integer; VersionBuild: Integer; VersionRevision: Integer): Guid
    var
        PublishedApplication: Record "Published Application";
        NullGuid: Guid;
    begin
        if AppId = NullGuid then
            exit(NullGuid);

        PublishedApplication.SetRange(ID, AppId);
        PublishedApplication.SetRange("Tenant Visible", true);

        if Name <> '' then
            PublishedApplication.SetRange(Name, Name);
        if VersionMajor <> 0 then
            PublishedApplication.SetRange("Version Major", VersionMajor);
        if VersionMinor <> 0 then
            PublishedApplication.SetRange("Version Minor", VersionMinor);
        if VersionBuild <> 0 then
            PublishedApplication.SetRange("Version Build", VersionBuild);
        if VersionRevision <> 0 then
            PublishedApplication.SetRange("Version Revision", VersionRevision);

        if PublishedApplication.Count() <> 1 then
            exit(NullGuid);

        if PublishedApplication.FindFirst() then
            exit(PublishedApplication."Package ID");
    end;

    procedure GetExtensionLogo(AppId: Guid; var Logo: Codeunit "Temp Blob")
    var
        PublishedApplication: Record "Published Application";
        Media: Record Media;
        LogoInStream: Instream;
        LogoOutStream: Outstream;
    begin
        PublishedApplication.SetRange(ID, AppId);
        PublishedApplication.SetRange("Tenant Visible", true);

        if PublishedApplication.FindFirst() then begin
            Media.SetRange(ID, PublishedApplication.Logo.MediaId());

            if not Media.FindFirst() then
                exit;

            Media.CalcFields(Content);
            Media.Content.CreateInStream(LogoInStream);

            Logo.CreateOutstream(LogoOutStream);
            CopyStream(LogoOutStream, LogoInStream);
        end;
    end;

    procedure GetAppName(AppId: Guid) AppName: Text
    var
        PublishedApplication: Record "Published Application";
    begin
        if PublishedApplication.ReadPermission then begin
            PublishedApplication.SetRange(ID, AppId);
            PublishedApplication.SetRange("Tenant Visible", true);

            if PublishedApplication.FindFirst() then
                AppName := PublishedApplication.Name;
        end;
    end;
}

