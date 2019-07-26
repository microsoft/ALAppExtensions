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
        OperationProgressMsg: Label 'We are installing the extension. You can view the progress on the Status page.';
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

    procedure DeployExtension(PackageId: Guid; lcid: Integer; IsUIEnabled: Boolean)
    var
        NAVApp: Record "NAV App";
    begin
        if NAVApp.Get(PackageId) then
            DeployExtensionByAppId(NAVApp.ID, lcid, IsUIEnabled);
    end;

    procedure DeployExtensionByAppId(AppId: GUID; lcid: Integer; IsUIEnabled: Boolean)
    begin
        InitializeOperationInvoker();
        DotNetALNavAppOperationInvoker.DeployTarget(AppId, Format(lcid));
        if IsUIEnabled then
            Message(OperationProgressMsg);
    end;


    procedure UploadExtension(PackageStream: InStream; lcid: Integer)
    begin
        DotNetALPackageDeploymentSchedule := DotNetALPackageDeploymentSchedule.Immediate;
        InitializeOperationInvoker();
        DotNetALNavAppOperationInvoker.UploadPackage(PackageStream, DotNetALPackageDeploymentSchedule, Format(lcid));
    end;

    procedure DeployAndUploadExtension(PackageStream: InStream; lcid: Integer; DeployTo: Option "Current version","Next minor version","Next major version")
    var
        DotNetALPackageDeploymentSchedule: DotNet ALPackageDeploymentSchedule;
    begin
        InitializeOperationInvoker();
        case DeployTo of
            DeployTo::"Current version":
                begin
                    DotNetALPackageDeploymentSchedule := DotNetALPackageDeploymentSchedule.Immediate;
                    DotNetALNavAppOperationInvoker.UploadPackage(PackageStream, DotNetALPackageDeploymentSchedule, Format(lcid));
                    Message(CurrentOperationProgressMsg);
                end;
            DeployTo::"Next minor version":
                begin
                    DotNetALPackageDeploymentSchedule := DotNetALPackageDeploymentSchedule.StageForNextMinorUpdate;
                    DotNetALNavAppOperationInvoker.UploadPackage(PackageStream, DotNetALPackageDeploymentSchedule, Format(lcid));
                    Message(ScheduledOperationMinorProgressMsg);
                end;
            DeployTo::"Next major version":
                begin
                    DotNetALPackageDeploymentSchedule := DotNetALPackageDeploymentSchedule.StageForNextUpdate;
                    DotNetALNavAppOperationInvoker.UploadPackage(PackageStream, DotNetALPackageDeploymentSchedule, Format(lcid));
                    Message(ScheduledOperationMajorProgressMsg);
                end;
        end;
    end;

    procedure UnpublishExtension(PackageID: Guid): Boolean
    var
        NavApp: Record "NAV App";
        ExtensionInstallationImpl: Codeunit "Extension Installation Impl";
    begin
        if not (NavApp.Get(PackageID)) then
            exit(false);

        if (NavApp.Scope <> 1) then
            exit(false);

        if ExtensionInstallationImpl.IsInstalledByPackageId(PackageID) then
            exit(false);

        UnpublishUninstalledPerTenantExtension(PackageID);
        exit(true);
    end;

    procedure UnpublishUninstalledPerTenantExtension(PackageID: Guid)
    begin
        AssertIsInitialized();
        DotNetNavAppALInstaller.ALUnpublishNavTenantApp(PackageID);
    end;

    procedure DownloadExtensionSource(PackageId: Guid): Boolean
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
        if not NAVApp.Get(PackageId) then
            exit(false);

        if (NavApp.Scope <> 1) then
            exit(false);

        TempBlob.CreateOutStream(NvOutStream);
        VersionString :=
          ExtensionInstallationImpl.GetVersionDisplayString(NAVApp);

        DotNetNavDesignerALFunctions.GenerateDesignerPackageZipStreamByVersion(NvOutStream, NAVApp.ID, VersionString);
        FileName := StrSubstNo(ExtensionFileNameTxt, NAVApp.Name, NAVApp.Publisher, VersionString);
        CleanFileName := DotNetNavDesignerALFunctions.SanitizeDesignerFileName(FileName, '_');

        TempBlob.CreateInStream(NvInStream);

        exit(DownloadFromStream(NvInStream, DialogTitleTxt, '', '*.*', CleanFileName));

    end;

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

    procedure RefreshStatus(OperationID: Guid)
    begin
        InitializeOperationInvoker();
        DotNetALNavAppOperationInvoker.RefreshOperationStatus(OperationID);
    end;

    procedure ConfigureExtensionHttpClientRequestsAllowance(PackageId: Text; AreHttpClientRqstsAllowed: Boolean): Boolean
    var
        NavApp: Record "NAV App";
        NavAppSetting: Record "NAV App Setting";
    begin
        if not NavApp.Get(PackageId) then
            exit(false);

        if not NavAppSetting.get(NavApp.ID) then
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

