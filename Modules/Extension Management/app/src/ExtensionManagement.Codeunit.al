// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 2504 "Extension Management"
{

    trigger OnRun()
    begin
    end;

    var
        ExtensionInstallationImpl: Codeunit "Extension Installation Impl";
        ExtensionOperationImpl: Codeunit "Extension Operation Impl";
        AppsourceEmbedRelativeTxt: Label 'https://appsource.microsoft.com/embed/en-us/marketplace?product=dynamics-365-business-central', Locked=true;
        ExtensionMarketplace: Codeunit "Extension Marketplace";

    /// <summary>
    /// Installs an extension, based on its PackageId and Locale Identifier.
    /// </summary>
    /// <param name="PackageId">The ID of the NAVApp extension package.</param>
    /// <param name="lcid">The Locale Identifier.</param>
    /// <param name="IsUIEnabled">Indicates whether the install operation is invoked through the UI.</param>
    procedure InstallExtension(PackageId: Guid;lcid: Integer;IsUIEnabled: Boolean): Boolean
    begin
        exit(ExtensionInstallationImpl.InstallExtension(PackageId,lcid,IsUIEnabled));
    end;

    /// <summary>
    /// Uninstalls an extension, based on its PackageId.
    /// </summary>
    /// <param name="PackageId">The ID of the NAVApp extension package.</param>
    /// <param name="IsUIEnabled">Indicates if the uninstall operation is invoked through the UI.</param>
    procedure UninstallExtension(PackageId: Guid;IsUIEnabled: Boolean): Boolean
    begin
        exit(ExtensionInstallationImpl.UninstallExtension(PackageId,IsUIEnabled));
    end;

    /// <summary>
    /// Uploads an extension, using a File Stream and based on the Locale Identifier.
    /// </summary>
    /// <param name="FileStream">The File Stream containing the extension to be uploaded.</param>
    /// <param name="lcid">The Locale Identifier.</param>
    procedure UploadExtension(FileStream: InStream;lcid: Integer)
    begin
        ExtensionOperationImpl.UploadExtension(FileStream,lcid);
    end;

    /// <summary>
    /// Deploys an extension, based on its PackageId and Locale Identifier.
    /// </summary>
    /// <param name="PackageId">The PackageId of the NAVApp extension to be deployed.</param>
    /// <param name="lcid">The Locale Identifier.</param>
    procedure DeployExtension(PackageId: Guid;lcid: Integer)
    begin
        ExtensionOperationImpl.DeployExtension(PackageId,lcid);
    end;

    /// <summary>
    /// Unpublishes an extension, based on its PackageId.
    /// </summary>
    /// <param name="PackageId">The PackageId of the NAVApp extension to be deployed.</param>
    procedure UnpublishExtension(PackageId: Guid)
    begin
        ExtensionOperationImpl.UnpublishTenantExtension(PackageId);
    end;

    /// <summary>
    /// Downloads the source of an extension, based on its PackageId.
    /// </summary>
    /// <param name="NAVApp">The NAVApp extension for which to download the source.</param>
    procedure DownloadExtensionSource(PackageId: Guid)
    begin
        ExtensionOperationImpl.DownloadExtensionSource(PackageId);
    end;

    /// <summary>
    /// Checks whether an extension is installed, based on its PackageId.
    /// </summary>
    /// <param name="PackageId">The ID of the NAVApp extension package.</param>
    /// <returns>The result of checking whether an extension is installed.</returns>
    procedure IsInstalledByPackageId(PackageId: Guid): Boolean
    begin
        exit(ExtensionInstallationImpl.IsInstalledByPackageId(PackageId));
    end;

    /// <summary>
    /// Checks whether an extension is installed, based on its AppId.
    /// </summary>
    /// <param name="AppId">The AppId of the NAVApp extension.</param>
    /// <returns>The result of checking whether an extension is installed.</returns>
    procedure IsInstalledByAppId(AppId: Guid): Boolean
    begin
        exit(ExtensionInstallationImpl.IsInstalledByAppId(AppId));
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
    procedure GetDeployOperationInfo(OperationId: Guid;var Version: Text;var Schedule: Text;var Publisher: Text;var AppName: Text;Description: Text)
    begin
        ExtensionOperationImpl.GetDeployOperationInfo(OperationId,Version,Schedule,Publisher,AppName,Description);
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
    /// Returns the URL to the library of the embed apps for Business Central on AppSoruce.
    /// </summary>
    procedure GetMarketplaceEmbeddedUrl(): Text
    begin
        exit(AppsourceEmbedRelativeTxt);
    end;

    /// <summary>
    /// Returns the AppId generated by AppSource for an extension published to the marketplace.
    /// </summary>
    /// <param name="ApplicationId">The Id of the extension that has been published to marketplace.</param>
    procedure GetMarketplaceAppId(AppId: Text): Guid
    begin
        exit(ExtensionMarketplace.MapMarketplaceIdToAppId(AppId));
    end;

    /// <summary>
    /// Returns the PackageId generated by AppSource for an extension published to the marketplace.
    /// </summary>
    /// <param name="ApplicationId">The Id of the extension that has been published to marketplace.</param>
    procedure GetMarketplacePackageId(PackageId: Text): Guid
    begin
        exit(ExtensionMarketplace.MapMarketplaceIdToPackageId(PackageId));
    end;

    /// <summary>
    /// Returns the PackageId of the latest Extension Version by the Extension AppId.
    /// </summary>
    /// <param name="AppId">The AppId of the extension.</param>
    [Scope('OnPrem')]
    procedure GetLatestVersionPackageIdByAppId(AppId: Guid): Guid
    begin
        exit(ExtensionOperationImpl.GetLatestVersionPackageIdByAppId(AppId));
    end;

    /// <summary>
    /// Returns the PackageId of the latest version of the extension by the extension's AppId.
    /// </summary>
    /// <param name="AppId">The AppId of the installed extension.</param>
    [Scope('OnPrem')]
    procedure GetCurrentInstalledVersionPackageIdByAppId(AppId: Guid): Guid
    begin
        exit(ExtensionOperationImpl.GetCurrentInstalledVersionPackageIdByAppId(AppId));
    end;

    /// <summary>
    /// Returns the PackageId of the version of the extension by the extension's AppId, Name, Version Major, Verion Minor, Version Build, Version Revision.
    /// </summary>
    /// <param name="AppId">The AppId of the extension.</param>
    /// <param name="Name">The input/output Name parameter of the extension. If there is no need to filter by this parameter, the default value is ''.</param>
    /// <param name="VersionMajor">The input/output Version Major parameter of the extension. If there is no need to filter by this parameter, the default value is "0".</param>
    /// <param name="VersionMinor">The input/output Version Minor parameter  of the extension. If there is no need to filter by this parameter, the default value is "0"..</param>
    /// <param name="VersionBuild">The input/output Version Build parameter  of the extension. If there is no need to filter by this parameter, the default value is "0".</param>
    /// <param name="VersionRevision">The input/output Version Revision parameter  of the extension. If there is no need to filter by this parameter, the default value is "0".</param>
    [Scope('OnPrem')]
    procedure GetSpecificVersionPackageIdByAppId(AppId: Guid;Name: Text;VersionMajor: Integer;VersionMinor: Integer;VersionBuild: Integer;VersionRevision: Integer): Guid
    begin
        exit(ExtensionOperationImpl.GetSpecificVersionPackageIdByAppId(AppId,Name,
            VersionMajor,VersionMinor,VersionBuild,VersionRevision));
    end;
}

