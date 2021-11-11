This module provides the tools needed to manage an extension.

Use this module to do the following:
- Install and uninstall extensions, with the option to use UI events
- Upload and deploy an extension
- Publish or unpublish extensions (publishing is available only in the client)
- Download a per-tenant extension source
- Check whether an extension is installed, which version, and whether its the latest
- Refresh and retrieve the extension deployment status and information
- Enable or disable http client requests
- Retrieve an extension's logo

# Public Objects
## Extension Deployment Status (Table 2508)
This temporary table is used to mirror the "NAV App Tenant Operation" system table and present details about the extension deployment status.///


## Data Out Of Geo. App (Codeunit 2506)

 Provides functions for adding, removing or checking if an App ID is within the list of apps that send data out of the Geolocation.
 

### Add (Method) <a name="Add"></a> 

 Adds an App ID to the list of apps that have data out of the geolocation.
 

#### Syntax
```
[Scope('OnPrem')]
procedure Add(AppID: Guid): Boolean
```
#### Parameters
*AppID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The App ID of the extension.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

The result of adding to the list. True if the data was added; false otherwise.
### Remove (Method) <a name="Remove"></a> 

 Removes an App ID from the list of apps that have data out of the geolocation.
 

#### Syntax
```
[Scope('OnPrem')]
procedure Remove(AppID: Guid): Boolean
```
#### Parameters
*AppID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The App ID of the extension.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

The result of removing from the list. True if the data was removed; false otherwise.
### Contains (Method) <a name="Contains"></a> 

 Checks if an App ID is in the list of apps that have data out of the geolocation.
 

#### Syntax
```
[Scope('OnPrem')]
procedure Contains(AppID: Guid): Boolean
```
#### Parameters
*AppID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The App ID of the extension.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

The result of checking whether an AppID is the list. True if the AppID was found; false otherwise.
### AlreadyInstalled (Method) <a name="AlreadyInstalled"></a> 

 Checks if any of the already installed extensions are in the list of apps that have data out of the geolocation.
 

#### Syntax
```
[Scope('OnPrem')]
procedure AlreadyInstalled(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

The result of checking whether an already installed extension is in the list apps that have data out of the geolocation. True if at least one installed extension was found in the list; false otherwise.

## Extension Management (Codeunit 2504)

 Provides features for installing and uninstalling, downloading and uploading, configuring and publishing extensions and their dependencies.
 

### InstallExtension (Method) <a name="InstallExtension"></a> 

 Installs an extension, based on its PackageId and Locale Identifier.
 

#### Syntax
```
procedure InstallExtension(PackageId: Guid; lcid: Integer; IsUIEnabled: Boolean): Boolean
```
#### Parameters
*PackageId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The ID of the extension package.

*lcid ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The Locale Identifier.

*IsUIEnabled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Indicates whether the install operation is invoked through the UI.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the extention is installed successfully; false otherwise.
### UninstallExtension (Method) <a name="UninstallExtension"></a> 

 Uninstalls an extension, based on its PackageId.
 

#### Syntax
```
procedure UninstallExtension(PackageId: Guid; IsUIEnabled: Boolean): Boolean
```
#### Parameters
*PackageId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The ID of the extension package.

*IsUIEnabled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Indicates if the uninstall operation is invoked through the UI.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the extention is uninstalled successfully; false otherwise.
### UninstallExtensionAndDeleteExtensionData (Method) <a name="UninstallExtensionAndDeleteExtensionData"></a> 

 Uninstalls an extension, based on its PackageId and permanently deletes the tables that contain data for the extension.
 

#### Syntax
```
procedure UninstallExtensionAndDeleteExtensionData(PackageId: Guid; IsUIEnabled: Boolean): Boolean
```
#### Parameters
*PackageId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The ID of the extension package.

*IsUIEnabled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Indicates if the uninstall operation is invoked through the UI.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the extention is uninstalled successfully; false otherwise.
### UploadExtension (Method) <a name="UploadExtension"></a> 

 Uploads an extension, using a File Stream and based on the Locale Identifier.
 This method is only applicable in SaaS environment.
 

#### Syntax
```
procedure UploadExtension(FileStream: InStream; lcid: Integer)
```
#### Parameters
*FileStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The File Stream containing the extension to be uploaded.

*lcid ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The Locale Identifier.

### DeployExtension (Method) <a name="DeployExtension"></a> 

 Deploys an extension, based on its ID and Locale Identifier.
 This method is only applicable in SaaS environment.
 

#### Syntax
```
procedure DeployExtension(AppId: Guid; lcid: Integer; IsUIEnabled: Boolean)
```
#### Parameters
*AppId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The AppId of the extension.

*lcid ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The Locale Identifier.

*IsUIEnabled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Indicates whether the install operation is invoked through the UI.

### UnpublishExtension (Method) <a name="UnpublishExtension"></a> 

 Unpublishes an extension, based on its PackageId.
 An extension can only be unpublished, if it is a per-tenant one and it has been uninstalled first.
 

#### Syntax
```
procedure UnpublishExtension(PackageId: Guid): Boolean
```
#### Parameters
*PackageId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The PackageId of the extension.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the extention is unpublished successfully; false otherwise.
### DownloadExtensionSource (Method) <a name="DownloadExtensionSource"></a> 

 Downloads the source of an extension, based on its PackageId.
 

#### Syntax
```
procedure DownloadExtensionSource(PackageId: Guid): Boolean
```
#### Parameters
*PackageId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The PackageId of the extension.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the operation was successful; false otherwise.
### GetExtensionSource (Method) <a name="GetExtensionSource"></a> 

 Retrives the source of an extension, based on its PackageId.
 

#### Syntax
```
procedure GetExtensionSource(PackageId: Guid; var ExtensionSourceTempBlob: Codeunit "Temp Blob"): Boolean
```
#### Parameters
*PackageId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The PackageId of the extension.

*ExtensionSourceTempBlob ([Codeunit "Temp Blob"]())* 

TempBlob where the zip is stored.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the operation was successful; false otherwise.
### IsInstalledByPackageId (Method) <a name="IsInstalledByPackageId"></a> 

 Checks whether an extension is installed, based on its PackageId.
 

#### Syntax
```
procedure IsInstalledByPackageId(PackageId: Guid): Boolean
```
#### Parameters
*PackageId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The ID of the extension package.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

The result of checking whether an extension is installed.
### IsInstalledByAppId (Method) <a name="IsInstalledByAppId"></a> 

 Checks whether an extension is installed, based on its AppId.
 

#### Syntax
```
procedure IsInstalledByAppId(AppId: Guid): Boolean
```
#### Parameters
*AppId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The AppId of the extension.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

The result of checking whether an extension is installed.
### GetAllExtensionDeploymentStatusEntries (Method) <a name="GetAllExtensionDeploymentStatusEntries"></a> 

 Retrieves a list of all the Deployment Status Entries
 

#### Syntax
```
[Obsolete('Required parameter is not accessible for Cloud development', '17.0')]
procedure GetAllExtensionDeploymentStatusEntries(var NavAppTenantOperation: Record "NAV App Tenant Operation")
```
#### Parameters
*NavAppTenantOperation ([Record "NAV App Tenant Operation"]())* 

Gets the list of all the Deployment Status Entries.

### GetAllExtensionDeploymentStatusEntries (Method) <a name="GetAllExtensionDeploymentStatusEntries"></a> 

 Retrieves a list of all the Deployment Status Entries
 

#### Syntax
```
procedure GetAllExtensionDeploymentStatusEntries(var TempExtensionDeploymentStatus: Record "Extension Deployment Status" temporary)
```
#### Parameters
*TempExtensionDeploymentStatus ([Record "Extension Deployment Status" temporary]())* 

Gets the list of all the Deployment Status Entries in a temporary record.

### GetDeployOperationInfo (Method) <a name="GetDeployOperationInfo"></a> 

 Retrieves the AppName,Version,Schedule,Publisher by the NAVApp Tenant OperationId.
 

#### Syntax
```
procedure GetDeployOperationInfo(OperationId: Guid; var Version: Text; var Schedule: Text; var Publisher: Text; var AppName: Text; Description: Text)
```
#### Parameters
*OperationId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The OperationId of the NAVApp Tenant.

*Version ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Gets the Version of the NavApp.

*Schedule ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Gets the Schedule of the NavApp.

*Publisher ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Gets the Publisher of the NavApp.

*AppName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Gets the AppName of the NavApp.

*Description ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Description of the NavApp; in case no name is provided, the description will replace the AppName.

### RefreshStatus (Method) <a name="RefreshStatus"></a> 

 Refreshes the status of the Operation.
 

#### Syntax
```
procedure RefreshStatus(OperationId: Guid)
```
#### Parameters
*OperationId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The Id of the operation to be refreshed.

### ConfigureExtensionHttpClientRequestsAllowance (Method) <a name="ConfigureExtensionHttpClientRequestsAllowance"></a> 

 Allows or disallows Http Client requests against the specified extension.
 

#### Syntax
```
procedure ConfigureExtensionHttpClientRequestsAllowance(PackageId: Text; AreHttpClientRqstsAllowed: Boolean): Boolean
```
#### Parameters
*PackageId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Id of the extension to configure.

*AreHttpClientRqstsAllowed ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

The value to set for "Allow HttpClient Requests".

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True configuration was successful; false otherwise.
### GetLatestVersionPackageIdByAppId (Method) <a name="GetLatestVersionPackageIdByAppId"></a> 

 Gets the PackageId of the latest Extension Version by the Extension AppId.
 

#### Syntax
```
procedure GetLatestVersionPackageIdByAppId(AppId: Guid): Guid
```
#### Parameters
*AppId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The AppId of the extension.

#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The package ID by app ID. Empty GUID, if package with the provided app ID does not exist.
### GetCurrentlyInstalledVersionPackageIdByAppId (Method) <a name="GetCurrentlyInstalledVersionPackageIdByAppId"></a> 

 Gets the PackageId of the latest version of the extension by the extension's AppId.
 

#### Syntax
```
procedure GetCurrentlyInstalledVersionPackageIdByAppId(AppId: Guid): Guid
```
#### Parameters
*AppId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The AppId of the installed extension.

#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The package ID of the installed version of an extenstion. Empty GUID, if package with the provided app ID does not exist.
### GetSpecificVersionPackageIdByAppId (Method) <a name="GetSpecificVersionPackageIdByAppId"></a> 

 Gets the package ID of the version of the extension by the extension's AppId, Name, Version Major, Version Minor, Version Build, Version Revision.
 

#### Syntax
```
procedure GetSpecificVersionPackageIdByAppId(AppId: Guid; Name: Text; VersionMajor: Integer; VersionMinor: Integer; VersionBuild: Integer; VersionRevision: Integer): Guid
```
#### Parameters
*AppId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The AppId of the extension.

*Name ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The input/output Name parameter of the extension. If there is no need to filter by this parameter, the default value is ''.

*VersionMajor ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The input/output Version Major parameter of the extension. If there is no need to filter by this parameter, the default value is "0".

*VersionMinor ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The input/output Version Minor parameter  of the extension. If there is no need to filter by this parameter, the default value is "0"..

*VersionBuild ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The input/output Version Build parameter  of the extension. If there is no need to filter by this parameter, the default value is "0".

*VersionRevision ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The input/output Version Revision parameter  of the extension. If there is no need to filter by this parameter, the default value is "0".

#### Return Value
*[Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type)*

The package ID of the extension with the specified paramters.
### GetExtensionLogo (Method) <a name="GetExtensionLogo"></a> 

 Gets the logo of an extension.
 

#### Syntax
```
procedure GetExtensionLogo(AppId: Guid; var Logo: Codeunit "Temp Blob")
```
#### Parameters
*AppId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The App ID of the extension.

*Logo ([Codeunit "Temp Blob"]())* 

Out parameter holding the logo of the extension.

### UploadExtensionToVersion (Method) <a name="UploadExtensionToVersion"></a> 

 Uploads an extension to current version, next minor or next major, using a File Stream and based on the Locale Identifier.
 This method is only applicable in SaaS environment.
 

#### Syntax
```
procedure UploadExtensionToVersion(FileStream: InStream; lcid: Integer; DeployTo: Enum "Extension Deploy To")
```
#### Parameters
*FileStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The File Stream containing the extension to be uploaded.

*lcid ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The Locale Identifier.

*DeployTo ([Enum "Extension Deploy To"]())* 

The version that the extension will be deployed to.

### UploadExtensionToVersion (Method) <a name="UploadExtensionToVersion"></a> 

 Uploads an extension to current version, next minor or next major, using a File Stream and based on the Locale Identifier.
 This method is only applicable in SaaS environment.
 

#### Syntax
```
procedure UploadExtensionToVersion(FileStream: InStream; lcid: Integer; DeployTo: Enum "Extension Deploy To"; SyncMode: Enum "Extension Sync Mode")
```
#### Parameters
*FileStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The File Stream containing the extension to be uploaded.

*lcid ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The Locale Identifier.

*DeployTo ([Enum "Extension Deploy To"]())* 

The version that the extension will be deployed to.

*SyncMode ([Enum "Extension Sync Mode"]())* 

The desired sync mode.

### GetMarketplaceEmbeddedUrl (Method) <a name="GetMarketplaceEmbeddedUrl"></a> 

 Returns a link to appsource market page
 

#### Syntax
```
[Obsolete('Replaced by "Extension Marketplace".GetMarketplaceEmbeddedUrl procedure.', '17.0')]
PROCEDURE GetMarketplaceEmbeddedUrl(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*


### GetMessageType (Method) <a name="GetMessageType"></a> 

 Extraxts the message type from appsource response.
 

#### Syntax
```
[Obsolete('Replaced by "Extension Marketplace".GetMessageType procedure.', '17.0')]
procedure GetMessageType(JObject: DotNet JObject): Text
```
#### Parameters
*JObject ([DotNet JObject]())* 

Appsourece response payload as a json object

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*


### GetApplicationIdFromData (Method) <a name="GetApplicationIdFromData"></a> 

 Extraxts the appsource application ID from appsource response.
 

#### Syntax
```
[Obsolete('Replaced by "Extension Marketplace".GetApplicationIdFromData procedure.', '17.0')]
procedure GetApplicationIdFromData(JObject: DotNet JObject): Text
```
#### Parameters
*JObject ([DotNet JObject]())* 

Appsourece response payload as a json object

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Application Id in text format
### MapMarketplaceIdToPackageId (Method) <a name="MapMarketplaceIdToPackageId"></a> 

 Extraxts the package ID from appsource response.
 

#### Syntax
```
[Obsolete('Replaced by "Extension Marketplace".MapMarketplaceIdToPackageId procedure.', '17.0')]
procedure MapMarketplaceIdToPackageId(ApplicationId: Text): GUID
```
#### Parameters
*ApplicationId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Appsource market application ID

#### Return Value
*[GUID]()*

Package ID as a GUID
### GetTelementryUrlFromData (Method) <a name="GetTelementryUrlFromData"></a> 

 Extracts the telemetry URL from appsource response.
 

#### Syntax
```
[Obsolete('Replaced by "Extension Marketplace".GetTelementryUrlFromData procedure.', '17.0')]
procedure GetTelementryUrlFromData(JObject: DotNet JObject): Text
```
#### Parameters
*JObject ([DotNet JObject]())* 

Appsourece response payload as a json object

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*


### MapMarketplaceIdToAppId (Method) <a name="MapMarketplaceIdToAppId"></a> 

 Extracts the app ID from appsource response.
 

#### Syntax
```
[Obsolete('Replaced by "Extension Marketplace".MapMarketplaceIdToAppId procedure.', '17.0')]
procedure MapMarketplaceIdToAppId(ApplicationId: Text): GUID
```
#### Parameters
*ApplicationId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Appsource market application ID

#### Return Value
*[GUID]()*


### GetAppName (Method) <a name="GetAppName"></a> 

 Returns the Name of the app given the App Id.
 

#### Syntax
```
procedure GetAppName(AppId: Guid): Text
```
#### Parameters
*AppId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The unique identifier of the app.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The name of the app.

## Extension Deployment Status (Page 2508)

 Displays the deployment status for extensions that are deployed or are scheduled for deployment.
 


## Extension Details (Page 2501)

 Displays details about the selected extension, and offers features for installing and uninstalling it.
 


## Extension Details Part (Page 2504)

 Displays information about the extension.
 


## Extension Installation (Page 2503)

 Installs the selected extension.
 


## Extension Logo Part (Page 2506)

 Displays the extension logo.
 


## Extension Management (Page 2500)

 Lists the available extensions, and provides features for managing them.
 


## Extension Marketplace (Page 2502)

 Shows the Extension Marketplace.
 

### PerformAction (Method) <a name="PerformAction"></a> 
#### Syntax
```
LOCAL PROCEDURE PerformAction(ActionName: Text)
```
#### Parameters
*ActionName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 




## Extension Settings (Page 2511)

 Displays settings for the selected extension, and allows users to edit them.
 


## Extn Deployment Status Detail (Page 2509)

 Displays details about the deployment status of the selected extension.
 


## Marketplace Extn Deployment (Page 2510)

 Provides an interface for installing extensions from AppSource.
 


## Upload And Deploy Extension (Page 2507)

 Allows users to upload an extension and schedule its deployment.
 


## Extension Deploy To (Enum 2504)

 Specifies the version in which the extension is deployed.
 

### Current version (value: 0)


 Current version.
 

### Next minor version (value: 1)


 Next minor version
 

### Next major version (value: 2)


 Next major version
 


## Extension Sync Mode (Enum 2505)

 Specifies how to sync the extension.
 

### Add (value: 0)


 Modifies the database schema by creating or extending the tables required to
 satisfy the app's metadata. This mode considers existing versions of the specified
 app in its calculations.
 

### Force Sync (value: 3)


 A destructive sync mode which makes the resulting schema match the extension in question
 regardless of its starting state. This means no change is off limits. This also means
 that changes which delete things (tables, fields, etc.) also delete the data they contain.
 


 This mode is intended for use when e.g. renaming tables. It can lead to data loss if used
 without caution.
 

