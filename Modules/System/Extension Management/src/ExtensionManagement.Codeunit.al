// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Apps;

using System.Utilities;

/// <summary>
/// Provides features for installing and uninstalling, downloading and uploading, configuring and publishing extensions and their dependencies.
/// </summary>
codeunit 2504 "Extension Management"
{
    Access = Public;

    var
        ExtensionInstallationImpl: Codeunit "Extension Installation Impl";
        ExtensionOperationImpl: Codeunit "Extension Operation Impl";
        ExtensionMarketplace: Codeunit "Extension Marketplace";

    /// <summary>
    /// Installs an extension, based on its PackageId and Locale Identifier.
    /// </summary>
    /// <param name="PackageId">The ID of the extension package.</param>
    /// <param name="lcid">The Locale Identifier.</param>
    /// <param name="IsUIEnabled">Indicates whether the install operation is invoked through the UI.</param>
    /// <returns>True if the extention is installed successfully; false otherwise.</returns>
    procedure InstallExtension(PackageId: Guid; lcid: Integer; IsUIEnabled: Boolean): Boolean
    begin
        exit(ExtensionInstallationImpl.InstallExtension(PackageId, lcid, IsUIEnabled));
    end;

    /// <summary>
    /// Uninstalls an extension, based on its PackageId.
    /// </summary>
    /// <param name="PackageId">The ID of the extension package.</param>
    /// <param name="IsUIEnabled">Indicates if the uninstall operation is invoked through the UI.</param>
    /// <returns>True if the extention is uninstalled successfully; false otherwise.</returns>
    procedure UninstallExtension(PackageId: Guid; IsUIEnabled: Boolean): Boolean
    begin
        exit(ExtensionInstallationImpl.UninstallExtension(PackageId, IsUIEnabled));
    end;

    /// <summary>
    /// Uninstalls an extension, based on its PackageId and permanently deletes the tables that contain data for the extension.
    /// </summary>
    /// <param name="PackageId">The ID of the extension package.</param>
    /// <param name="IsUIEnabled">Indicates if the uninstall operation is invoked through the UI.</param>
    /// <returns>True if the extention is uninstalled successfully; false otherwise.</returns>
    procedure UninstallExtensionAndDeleteExtensionData(PackageId: Guid; IsUIEnabled: Boolean): Boolean
    begin
        exit(ExtensionInstallationImpl.UninstallExtension(PackageId, IsUIEnabled, true));
    end;

    /// <summary>
    /// Uploads an extension, using a File Stream and based on the Locale Identifier.
    /// This method is only applicable in SaaS environment.
    /// </summary>
    /// <param name="FileStream">The File Stream containing the extension to be uploaded.</param>
    /// <param name="lcid">The Locale Identifier.</param>
    procedure UploadExtension(FileStream: InStream; lcid: Integer)
    begin
        ExtensionOperationImpl.UploadExtension(FileStream, lcid);
    end;

    /// <summary>
    /// Deploys an extension, based on its ID and Locale Identifier.
    /// This method is only applicable in SaaS environment.
    /// </summary>
    /// <param name="AppId">The AppId of the extension.</param>
    /// <param name="lcid">The Locale Identifier.</param>
    /// <param name="IsUIEnabled">Indicates whether the install operation is invoked through the UI.</param>
    procedure DeployExtension(AppId: Guid; lcid: Integer; IsUIEnabled: Boolean)
    begin
        ExtensionOperationImpl.DeployExtension(AppId, lcid, IsUIEnabled);
    end;

    /// <summary>
    /// Unpublishes an extension, based on its PackageId. 
    /// An extension can only be unpublished, if it is a per-tenant one and it has been uninstalled first.
    /// </summary>
    /// <param name="PackageId">The PackageId of the extension.</param>
    /// <returns>True if the extention is unpublished successfully; false otherwise.</returns>
    procedure UnpublishExtension(PackageId: Guid): Boolean
    begin
        exit(ExtensionOperationImpl.UnpublishExtension(PackageId));
    end;

    /// <summary>
    /// Downloads the source of an extension, based on its PackageId.
    /// </summary>
    /// <param name="PackageId">The PackageId of the extension.</param>
    /// <returns>True if the operation was successful; false otherwise.</returns>
    procedure DownloadExtensionSource(PackageId: Guid): Boolean
    begin
        exit(ExtensionOperationImpl.DownloadExtensionSource(PackageId));
    end;

    /// <summary>
    /// Retrives the source of an extension, based on its PackageId.
    /// </summary>
    /// <param name="PackageId">The PackageId of the extension.</param>
    /// <param name="ExtensionSourceTempBlob">TempBlob where the zip is stored.</param>
    /// <returns>True if the operation was successful; false otherwise.</returns>
    procedure GetExtensionSource(PackageId: Guid; var ExtensionSourceTempBlob: Codeunit "Temp Blob"): Boolean
    var
        FileName: Text;
    begin
        exit(ExtensionOperationImpl.GetExtensionSource(PackageId, ExtensionSourceTempBlob, FileName));
    end;

    /// <summary>
    /// Checks whether an extension is installed, based on its PackageId.
    /// </summary>
    /// <param name="PackageId">The ID of the extension package.</param>
    /// <returns>The result of checking whether an extension is installed.</returns>
    procedure IsInstalledByPackageId(PackageId: Guid): Boolean
    begin
        exit(ExtensionInstallationImpl.IsInstalledByPackageId(PackageId));
    end;

    /// <summary>
    /// Checks whether an extension is installed, based on its AppId.
    /// </summary>
    /// <param name="AppId">The AppId of the extension.</param>
    /// <returns>The result of checking whether an extension is installed.</returns>
    procedure IsInstalledByAppId(AppId: Guid): Boolean
    begin
        exit(ExtensionInstallationImpl.IsInstalledByAppId(AppId));
    end;

    /// <summary>
    /// Retrieves a list of all the Deployment Status Entries
    /// </summary>
    /// <param name="TempExtensionDeploymentStatus">Gets the list of all the Deployment Status Entries in a temporary record.</param>
    procedure GetAllExtensionDeploymentStatusEntries(var TempExtensionDeploymentStatus: Record "Extension Deployment Status" temporary)
    begin
        ExtensionOperationImpl.GetAllExtensionDeploymentStatusEntries(TempExtensionDeploymentStatus);
    end;

    /// <summary>
    /// Retrieves the AppName,Version,Schedule,Publisher by the NAVApp Tenant OperationId.
    /// </summary>
    /// <param name="OperationId">The OperationId of the NAVApp Tenant.</param>
    /// <param name="Version">Gets the Version of the NavApp.</param>
    /// <param name="Schedule">Gets the Schedule of the NavApp.</param>
    /// <param name="Publisher">Gets the Publisher of the NavApp.</param>
    /// <param name="AppName">Gets the AppName of the NavApp.</param>
    /// <param name="Description">The Description of the NavApp; in case no name is provided, the description will replace the AppName.</param>
    procedure GetDeployOperationInfo(OperationId: Guid; var Version: Text; var Schedule: Text; var Publisher: Text; var AppName: Text; Description: Text)
    begin
        ExtensionOperationImpl.GetDeployOperationInfo(OperationId, Version, Schedule, Publisher, AppName, Description);
    end;

    /// <summary>
    /// Refreshes the status of the Operation.
    /// </summary>
    /// <param name="OperationId">The Id of the operation to be refreshed.</param>
    procedure RefreshStatus(OperationId: Guid)
    begin
        ExtensionOperationImpl.RefreshStatus(OperationId);
    end;

    /// <summary>
    /// Allows or disallows Http Client requests against the specified extension.
    /// </summary>
    /// <param name="PackageId">The Id of the extension to configure.</param>
    /// <param name="AreHttpClientRqstsAllowed">The value to set for "Allow HttpClient Requests".</param>
    /// <returns>True configuration was successful; false otherwise.</returns>
    procedure ConfigureExtensionHttpClientRequestsAllowance(PackageId: Text; AreHttpClientRqstsAllowed: Boolean): Boolean
    begin
        ExtensionOperationImpl.ConfigureExtensionHttpClientRequestsAllowance(PackageId, AreHttpClientRqstsAllowed);
    end;

    /// <summary>
    /// Gets the PackageId of the latest Extension Version by the Extension AppId.
    /// </summary>
    /// <param name="AppId">The AppId of the extension.</param>
    /// <returns>The package ID by app ID. Empty GUID, if package with the provided app ID does not exist.</returns>
    procedure GetLatestVersionPackageIdByAppId(AppId: Guid): Guid
    begin
        exit(ExtensionOperationImpl.GetLatestVersionPackageIdByAppId(AppId));
    end;

    /// <summary>
    /// Gets the PackageId of the latest version of the extension by the extension's AppId.
    /// </summary>
    /// <param name="AppId">The AppId of the installed extension.</param>
    /// <returns>The package ID of the installed version of an extenstion. Empty GUID, if package with the provided app ID does not exist.</returns>
    procedure GetCurrentlyInstalledVersionPackageIdByAppId(AppId: Guid): Guid
    begin
        exit(ExtensionOperationImpl.GetCurrentlyInstalledVersionPackageIdByAppId(AppId));
    end;

    /// <summary>
    /// Gets the package ID of the version of the extension by the extension's AppId, Name, Version Major, Version Minor, Version Build, Version Revision.
    /// </summary>
    /// <param name="AppId">The AppId of the extension.</param>
    /// <param name="Name">The input/output Name parameter of the extension. If there is no need to filter by this parameter, the default value is ''.</param>
    /// <param name="VersionMajor">The input/output Version Major parameter of the extension. If there is no need to filter by this parameter, the default value is "0".</param>
    /// <param name="VersionMinor">The input/output Version Minor parameter  of the extension. If there is no need to filter by this parameter, the default value is "0"..</param>
    /// <param name="VersionBuild">The input/output Version Build parameter  of the extension. If there is no need to filter by this parameter, the default value is "0".</param>
    /// <param name="VersionRevision">The input/output Version Revision parameter  of the extension. If there is no need to filter by this parameter, the default value is "0".</param>
    /// <returns>The package ID of the extension with the specified paramters.</returns>
    procedure GetSpecificVersionPackageIdByAppId(AppId: Guid; Name: Text; VersionMajor: Integer; VersionMinor: Integer; VersionBuild: Integer; VersionRevision: Integer): Guid
    begin
        exit(ExtensionOperationImpl.GetSpecificVersionPackageIdByAppId(AppId, Name,
            VersionMajor, VersionMinor, VersionBuild, VersionRevision));
    end;

    /// <summary>
    /// Gets the logo of an extension.
    /// </summary>
    /// <param name="AppId">The App ID of the extension.</param>
    /// <param name="LogoTempBlob">Out parameter holding the logo of the extension.</param> 
    procedure GetExtensionLogo(AppId: Guid; var LogoTempBlob: Codeunit "Temp Blob")
    begin
        ExtensionOperationImpl.GetExtensionLogo(AppId, LogoTempBlob);
    end;

    /// <summary>
    /// Uploads an extension to current version, next minor or next major, using a File Stream and based on the Locale Identifier.
    /// This method is only applicable in SaaS environment.
    /// </summary>
    /// <param name="FileInStream">The File Stream containing the extension to be uploaded.</param>
    /// <param name="lcid">The Locale Identifier.</param>
    /// <param name="DeployTo">The version that the extension will be deployed to.</param>
    procedure UploadExtensionToVersion(FileInStream: InStream; lcid: Integer; DeployTo: Enum "Extension Deploy To")
    begin
        UploadExtensionToVersion(FileInStream, lcid, DeployTo, "Extension Sync Mode"::Add);
    end;

    /// <summary>
    /// Uploads an extension to current version, next minor or next major, using a File Stream and based on the Locale Identifier.
    /// This method is only applicable in SaaS environment.
    /// </summary>
    /// <param name="FileInStream">The File Stream containing the extension to be uploaded.</param>
    /// <param name="lcid">The Locale Identifier.</param>
    /// <param name="DeployTo">The version that the extension will be deployed to.</param>
    /// <param name="SyncMode">The desired sync mode.</param>
    procedure UploadExtensionToVersion(FileInStream: InStream; lcid: Integer; DeployTo: Enum "Extension Deploy To"; SyncMode: Enum "Extension Sync Mode")
    begin
        ExtensionOperationImpl.DeployAndUploadExtension(FileInStream, lcid, DeployTo, SyncMode);
    end;

    /// <summary>
    /// Installs an extension, based on its extension id.
    /// </summary>
    /// <param name="AppId">The ID of the extension package.</param>
    procedure InstallMarketplaceExtension(AppId: Guid)
    begin
        ExtensionMarketplace.InstallAppsourceExtensionWithRefreshSession(AppId, '');
    end;

    /// <summary>
    /// Returns the Name of the app given the App Id.
    /// </summary>
    /// <param name="AppId">The unique identifier of the app.</param>
    /// <returns>The name of the app.</returns>
    procedure GetAppName(AppId: Guid): Text
    begin
        exit(ExtensionOperationImpl.GetAppName(AppId))
    end;

    /// <summary>
    /// Returns the detailed message from a deployment operation.
    /// </summary>
    /// <param name="OperationId">The Id of the operation to get the detailed message from.</param>
    /// <returns>The detailed message as text.</returns>
    procedure GetDeploymentDetailedStatusMessage(OperationId: Guid): Text
    begin
        exit(ExtensionOperationImpl.GetDeploymentDetailedStatusMessage(OperationId));
    end;

    /// <summary>
    /// Writes the detailed message from a deployment operation to a stream.
    /// </summary>
    /// <param name="OperationId">The Id of the operation to get the detailed message from.</param>
    /// <param name="OutStream">An OutStream to write the message to.</param>
    /// <returns></returns>
    procedure GetDeploymentDetailedStatusMessageAsStream(OperationId: Guid; OutStream: OutStream)
    begin
        ExtensionOperationImpl.GetDeploymentDetailedStatusMessageAsStream(OperationId, OutStream);
    end;
}

