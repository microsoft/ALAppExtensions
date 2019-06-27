// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 2503 "Extension Operation Impl"
{
    Access = Internal;
    SingleInstance = false;

    var
        DotNetALNavAppOperationInvoker: DotNet ALNavAppOperationInvoker;
        DotNetALPackageDeploymentSchedule: DotNet ALPackageDeploymentSchedule;
        DotNetNavAppALInstaller: DotNet NavAppALInstaller;
        OperationInvokerHasBeenCreated: Boolean;
        InstallerHasBeenCreated: Boolean;
        ExtensionFileNameTxt: Label '%1_%2_%3.zip', Comment = '%1=Name, %2=Publisher, %3=Version', Locked = true;
        CurrentOperationProgressMsg: Label 'Extension deployment is in progress. Please check the Deployment Status page for updates.';
        ScheduledOperationMajorProgressMsg: Label 'Extension deployment has been scheduled for the next major version. Please check the Deployment Status page for updates.';
        ScheduledOperationMinorProgressMsg: Label 'Extension deployment has been scheduled for the next minor version. Please check the Deployment Status page for updates.';
        DialogTitleTxt: Label 'Export';
        OutExtTxt: Label 'Text Files (*.txt)|*.txt|*.*';

    local procedure AssertIsInitialized()
    begin
        if not InstallerHasBeenCreated then begin
            DotNetNavAppALInstaller := DotNetNavAppALInstaller.NavAppALInstaller();
            InstallerHasBeenCreated := true;
        end;
    end;

    [Scope('OnPrem')]
    procedure DeployExtension(PackageId: Guid; lcid: Integer)
    var
        NAVApp: Record "NAV App";
    begin
        if NAVApp.Get(PackageId) then begin
            InitializeOperationInvoker();
            DotNetALNavAppOperationInvoker.DeployTarget(NAVApp.ID, Format(lcid));
        end;
    end;

    [Scope('OnPrem')]
    procedure UploadExtension(PackageStream: InStream; lcid: Integer)
    begin
        DotNetALPackageDeploymentSchedule := DotNetALPackageDeploymentSchedule.Immediate;
        InitializeOperationInvoker();
        DotNetALNavAppOperationInvoker.UploadPackage(PackageStream, DotNetALPackageDeploymentSchedule, Format(lcid));
    end;

    [Scope('OnPrem')]
    procedure DeployAndUploadExtension(FileStream: InStream; LanguageID: Integer; DeployTo: Option "Current version","Next minor version","Next major version")
    var
        DotNetALPackageDeploymentSchedule: DotNet ALPackageDeploymentSchedule;
    begin
        case DeployTo of
            DeployTo::"Current version":
                begin
                    DotNetALPackageDeploymentSchedule := DotNetALPackageDeploymentSchedule.Immediate;
                    UploadExtension(FileStream, LanguageID);
                    Message(CurrentOperationProgressMsg);
                end;
            DeployTo::"Next minor version":
                begin
                    DotNetALPackageDeploymentSchedule := DotNetALPackageDeploymentSchedule.StageForNextMinorUpdate;
                    UploadExtension(FileStream, LanguageID);
                    Message(ScheduledOperationMinorProgressMsg);
                end;
            DeployTo::"Next major version":
                begin
                    DotNetALPackageDeploymentSchedule := DotNetALPackageDeploymentSchedule.StageForNextUpdate;
                    UploadExtension(FileStream, LanguageID);
                    Message(ScheduledOperationMajorProgressMsg);
                end;
        end;
    end;

    [Scope('OnPrem')]
    procedure UnpublishTenantExtension(PackageID: Guid)
    begin
        AssertIsInitialized();
        DotNetNavAppALInstaller.ALUnpublishNavTenantApp(PackageID);
    end;

    [Scope('OnPrem')]
    procedure DownloadExtensionSource(PackageId: Guid)
    var
        NAVApp: Record "NAV App";
        TempBlob: Codeunit "Temp Blob";
        ExtensionInstallationImpl: Codeunit "Extension Installation Impl";
        DotNetNavDesignerALFunctions: DotNet NavDesignerALFunctions;
        NvOutStream: OutStream;
        NvInStream: InStream;
        FileName: Text;
        VersionString: Text;
        CleanFileName: Text;
    begin
        NAVApp.Get(PackageId);
        TempBlob.CreateOutStream(NvOutStream);
        VersionString :=
          ExtensionInstallationImpl.GetVersionDisplayString(NAVApp);

        DotNetNavDesignerALFunctions.GenerateDesignerPackageZipStreamByVersion(NvOutStream, NAVApp.ID, VersionString);
        FileName := StrSubstNo(ExtensionFileNameTxt, NAVApp.Name, NAVApp.Publisher, VersionString);
        CleanFileName := DotNetNavDesignerALFunctions.SanitizeDesignerFileName(FileName, '_');

        TempBlob.CreateInStream(NvInStream);

        DownloadFromStream(NvInStream, DialogTitleTxt, '', '*.*', CleanFileName);
    end;

    [Scope('OnPrem')]
    procedure DownloadDeploymentStatusDetails(OperationId: Guid)
    var
        TempBlob: Codeunit "Temp Blob";
        NavOutStream: OutStream;
        NavInStream: InStream;
        DummyToFile: Text;
    begin
        TempBlob.CreateOutStream(NavOutStream);
        GetDeploymentDetailedStatusMessageAsStream(OperationId, NavOutStream);

        TempBlob.CreateInStream(NavInStream);

        DownloadFromStream(NavInStream, DialogTitleTxt, '', OutExtTxt, DummyToFile);
    end;

    [Scope('OnPrem')]
    procedure RefreshStatus(OperationID: Guid)
    begin
        InitializeOperationInvoker();
        DotNetALNavAppOperationInvoker.RefreshOperationStatus(OperationID);
    end;

    [Scope('OnPrem')]
    local procedure InitializeOperationInvoker()
    begin
        if not OperationInvokerHasBeenCreated then begin
            DotNetALNavAppOperationInvoker := DotNetALNavAppOperationInvoker.ALNavAppOperationInvoker();
            OperationInvokerHasBeenCreated := true;
        end;
    end;

    [Scope('OnPrem')]
    procedure GetDeploymentDetailedStatusMessageAsStream(OperationId: Guid; OutStream: OutStream)
    begin
        InitializeOperationInvoker();
        DotNetALNavAppOperationInvoker.GetOperationDetailedStatusMessageAsStream(OperationId, OutStream);
    end;

    [Scope('OnPrem')]
    procedure GetDeploymentDetailedStatusMessage(OperationId: Guid): Text
    begin
        InitializeOperationInvoker();
        exit(DotNetALNavAppOperationInvoker.GetOperationDetailedStatusMessage(OperationId));
    end;

    [Scope('OnPrem')]
    procedure GetDeployOperationInfo(OperationId: Guid; var Version: Text; var Schedule: Text; var Publisher: Text; var AppName: Text; Description: Text)
    begin
        AppName := GetDeployOperationAppName(OperationId);
        if AppName = '' then
            AppName := Description;
        Publisher := GetDeployOperationAppPublisher(OperationId);
        Version := GetDeployOperationAppVersion(OperationId);
        Schedule := GetDeployOperationSchedule(OperationId);
    end;

    [Scope('OnPrem')]
    procedure GetDeployOperationAppName(OperationId: Guid): Text
    begin
        InitializeOperationInvoker();
        exit(DotNetALNavAppOperationInvoker.GetDeployOperationAppName(OperationId));
    end;

    [Scope('OnPrem')]
    procedure GetDeployOperationAppPublisher(OperationId: Guid): Text
    begin
        InitializeOperationInvoker();
        exit(DotNetALNavAppOperationInvoker.GetDeployOperationAppPublisher(OperationId));
    end;

    [Scope('OnPrem')]
    procedure GetDeployOperationAppVersion(OperationId: Guid): Text
    begin
        InitializeOperationInvoker();
        exit(DotNetALNavAppOperationInvoker.GetDeployOperationAppVersion(OperationId));
    end;

    [Scope('OnPrem')]
    procedure GetDeployOperationSchedule(OperationId: Guid): Text
    begin
        InitializeOperationInvoker();
        exit(DotNetALNavAppOperationInvoker.GetDeployOperationSchedule(OperationId));
    end;

    [Scope('OnPrem')]
    procedure GetDeployOperationJobId(OperationId: Guid): Text
    begin
        InitializeOperationInvoker();
        exit(DotNetALNavAppOperationInvoker.GetDeployOperationJobId(OperationId));
    end;

    [Scope('OnPrem')]
    procedure GetLatestVersionPackageIdByAppId(AppId: Guid): Guid
    var
        NavAppTable: Record "NAV App";
        NullGuid: Guid;
    begin
        NavAppTable.SetRange(ID, AppId);
        NavAppTable.SetCurrentKey(Name, "Version Major", "Version Minor", "Version Build", "Version Revision");
        NavAppTable.Ascending(false);
        if NavAppTable.FindFirst() then
            exit(NavAppTable."Package ID");

        exit(NullGuid);
    end;

    [Scope('OnPrem')]
    procedure GetCurrentInstalledVersionPackageIdByAppId(AppId: Guid): Guid
    var
        NavAppTable: Record "NAV App";
        ExtensionInstallationImpl: Codeunit "Extension Installation Impl";
        NullGuid: Guid;
    begin
        NavAppTable.SetRange(ID, AppId);
        NavAppTable.SetCurrentKey(Name, "Version Major", "Version Minor", "Version Build", "Version Revision");
        NavAppTable.Ascending(false);
        if NavAppTable.FindSet() then
            repeat
                if ExtensionInstallationImpl.IsInstalledByPackageId(NavAppTable."Package ID") then
                    exit(NavAppTable."Package ID");
            until NavAppTable.Next() = 0;
        exit(NullGuid);
    end;

    [Scope('OnPrem')]
    procedure GetSpecificVersionPackageIdByAppId(AppId: Guid; Name: Text; VersionMajor: Integer; VersionMinor: Integer; VersionBuild: Integer; VersionRevision: Integer): Guid
    var
        NavAppTable: Record "NAV App";
        NullGuid: Guid;
    begin
        if AppId = NullGuid then
            exit(NullGuid);
        NavAppTable.SetRange(ID, AppId);
        if Name <> '' then
            NavAppTable.SetRange(Name, Name);
        if VersionMajor <> 0 then
            NavAppTable.SetRange("Version Major", VersionMajor);
        if VersionMinor <> 0 then
            NavAppTable.SetRange("Version Minor", VersionMinor);
        if VersionBuild <> 0 then
            NavAppTable.SetRange("Version Build", VersionBuild);
        if VersionRevision <> 0 then
            NavAppTable.SetRange("Version Revision", VersionRevision);

        if NavAppTable.Count() <> 1 then
            exit(NullGuid);
        if NavAppTable.FindFirst() then
            exit(NavAppTable."Package ID");
    end;
}

