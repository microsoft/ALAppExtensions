# Breaking Changes
### ...and how to resolve them
In this help document, you will find a list of known breaking changes which were introduced in the latest major release. You will also get help on the changes you need to do to your code to make it compile again against the latest version of the Business Central System Application and Base Application.

# Work in progress
The breaking changes are currently being identified. We will update this site with more help on this topic very soon.

# Modules

## Auto Format Module
**Error**: _Codeunit 'AutoFormatManagement' is missing_

**Solution**: Codeunit has been renamed to `codeunit 45 "Auto Format"`.

---

## Base64 Convert Module
**Error**: _'Codeunit "Type Helper"' does not contain a definition for 'ConvertValueFromBase64'_

**Solution**: Function has been moved to `codeunit 4110 "Base64 Convert"`, function `FromBase64`.

---

## BLOB Storage Module
**Error**: _Argument 1: cannot convert from 'Record TempBlob' to 'var Codeunit "Temp Blob"'_

**Solution**: Use `codeunit 4100 "Temp Blob"` API instead of the record API.

---

## Caption Class Module
**Error**: _'Codeunit' does not contain a definition for 'CaptionManagement'_

**Solution**: Events have been moved to `codeunit 42 "Caption Class"`.

---

## Client Type Management Module
**Error**: _Codeunit 'ClientTypeManagement' is missing_\
**Error**: _Codeunit '4' is missing_

**Solution**: Codeunit has been renamed to `codeunit 4030 "Client Type Management"`.

---

## Cryptography Management Module
**Error**: _'Codeunit "Encryption Management"' does not contain a definition for 'GenerateKeyedHash'_

**Solution**: Function has been moved to `codeunit 1266 "Encryption Management"`, function `GenerateHash`.

---

## Cues and KPIs Module
**Error**: _'Cue Setup' is inaccessible due to its protection level_

**Solution**: Access the table through the facade APIs, `codeunit 9701 "Cues And KPIs"`.

**Error**: _Codeunit 'Cue Setup' is missing_

**Solution**: Codeunit has been renamed to `codeunit 9701 "Cues And KPIs"`.

---

## Data Compression Module
**Error**: _Codeunit 'Zip Stream Wrapper' is missing_

**Solution**: Codeunit has been renamed to `codeunit 425 "Data Compression"`.

---

## Environment Information Module
**Error**: _'Codeunit "Permission Manager"' does not contain a definition for 'SoftwareAsAService'_

**Solution**: Function has been moved to `codeunit 457 "Environment Information"`, function `IsSaaS`.

**Error**: _'Codeunit "Permission Manager"' does not contain a definition for 'IsSandboxConfiguration'_

**Solution**: Function has been moved to `codeunit 457 "Environment Information"`, function `IsSandbox`.

**Error**: _'Codeunit "Tenant Settings"' does not contain a definition for 'IsSandbox'_

**Solution**: Function has been moved to `codeunit 457 "Environment Information"`, function `IsSandbox`.

**Error**: _'Codeunit "Identity Management"' does not contain a definition for 'IsInvAppId'_

**Solution**: Function has been moved to `codeunit 457 "Environment Information"`, function `IsInvoicing`.

---

## Extension Management Module
**Error**: _'Extension Installation Impl' is inaccessible due to its protection level_\
**Error**: _Codeunit 'NavExtensionInstallationMgmt' is missing_

**Solution**: Access the codeunit through the facade APIs, `codeunit 2504 "Extension Management"`.

**Error**: _'Extension Management' does not contain a definition for 'GetLatestVersionPackageId'_

**Solution**: Function has been renamed, function `GetLatestVersionPackageIdByAppId`.

**Error**: _'Extension Management' does not contain a definition for 'InstallNavExtension'_

**Solution**: Function has been renamed, function `InstallExtension`. Notice additional parameter IsUIEnabled that indicates whether the install operation is invoked through the UI.
	
---

## Field Selection Module
**Error**: _Page 'Field List' is missing"_\
**Error**: _Page 'Table Field List' is missing_\
**Error**: _Page '"Fields"' is missing"_

**Solution**: Access the page through the facade APIs, `codeunit 9806 "Field Selection"`.

---

## Filter Tokens Module
**Error**: _Codeunit 'TextManagement' is missing_\
**Error**: _'Codeunit' does not contain a definition for 'TextManagement'_

**Solution**: Codeunit has been renamed to `codeunit 41 "Filter Tokens"`.

---

## Headlines Module
**Error**: _Codeunit 'Headline Management' is missing_

**Solution**: Codeunit has been renamed to `codeunit 1439 Headlines`.

---

## Language Module
**Error**: _Codeunit 'LanguageManagement' is missing_

**Solution**: Codeunit was renamed to `codeunit 43 Language`.

**Error**: _'Record Language' does not contain a definition for 'GetUserLanguage'_

**Solution**: Function has been moved to `codeunit 43 Language`, function `GetUserLanguageCode`.

**Error**: _'Record Language' does not contain a definition for 'GetLanguageID'_

**Solution**: Function has been moved to `codeunit 43 Language`, function `GetLanguageId`.

---

## Manual Setup Module
**Error**: _'Business Setup Icon' is inaccessible due to its protection level_

**Solution**: Access the table through the facade APIs, `codeunit 1875 "Manual Setup"`.

**Error**: _Page '"Business Setup"' is missing_

**Solution**: Page has been renamed to `page 1875 "Manual Setup"`.

**Error**: _The event 'OnRegisterBusinessSetup' is not found in the target"_

**Solution**: Event has been moved to `codeunit 1875 "Manual Setup"`, function `OnRegisterManualSetup`.

---

## Server Settings Module
**Error**: _Codeunit 'Server Config. Setting Handler' is missing_

**Solution**: Codeunit has been renamed to `codeunit 6723 "Server Setting"`.

---

## Azure AD Tenant Module
**Error**: _Codeunit 'Tenant Management' is missing_

**Solution**: Codeunit was split into `codeunit 417 "Tenant Settings"` and `codeunit 457 "Environment Information"` and `codeunit 433 "Azure AD Tenant"`.

**Error**: _'Codeunit "Identity Management"' does not contain a definition for 'GetAadTenantId'_

**Solution**: Function has been moved to `codeunit 433 "Azure AD Tenant"`, function `GetAadTenantId`.

**Error**: _'Codeunit "Tenant Management"' does not contain a definition for 'GetAadTenantId'_

**Solution**: Function has been moved to `codeunit 433 "Azure AD Tenant"`, function `GetAadTenantId`.

**Error**: _'Codeunit "Tenant Management"' does not contain a definition for 'GetAadTenantDomainName'_

**Solution**: Function has been moved to `codeunit 433 "Azure AD Tenant"`, function `GetAadTenantDomainName`.
 
---

## User Permissions Module
**Error**: _'Codeunit "Permission Manager"' does not contain a definition for 'IsSuper'_

**Solution**: Function has been moved to `codeunit 152 "User Permissions"`, function `IsSuper`.

---

## User Selection Module
**Error**: _'Codeunit "User Management"' does not contain a definition for 'ValidateUserID'_

**Solution**: Function has been moved to `codeunit 9843 "User Selection"`, function `ValidateUserName`.

**Error**: _'Codeunit "User Management"' does not contain a definition for 'LookupUserID'_

**Solution**: Function has been moved to `codeunit 9843 "User Selection"`, function `Open` and returns the User record.

---

## Video Module
**Error**: _'Product Video Buffer' is inaccessible due to its protection level_

**Solution**: Access the table through the facade APIs, `codeunit 3710 Video`.

**Error**: _Page 'Video Player Page' is missing_

**Solution**: Access the page through the facade APIs, `codeunit 3710 Video`, function `Play`.

---

## BaseApp
**Error**: _'Codeunit' does not contain a definition for 'Headline RC Order Processor'_\
**Error**: _'Codeunit' does not contain a definition for 'Headline RC Accountant'_\
**Error**: _'Codeunit' does not contain a definition for 'Headline RC Business Manager'_\
**Error**: _'Codeunit' does not contain a definition for 'Headline RC Administrator'_\
**Error**: _'Codeunit' does not contain a definition for 'Headline RC Team Member'_\
**Error**: _'Codeunit' does not contain a definition for 'Headline RC Project Manager'_\
**Error**: _'Codeunit' does not contain a definition for 'Headline RC Relationship Mgt.'_\
**Error**: _'Codeunit' does not contain a definition for 'Headline RC Prod. Planner'_\
**Error**: _'Codeunit' does not contain a definition for 'Headline RC Serv. Dispatcher'_\
**Error**: _Codeunit 'Headline RC Business Manager' is missing_

**Solution**: Codeunits were combined into `codeunit 1441 "RC Headlines Executor"`.

**Error**: _Table 'Headline RC Business Manager' is removed. Reason: Replaced with "RC Headlines User Data" table_\
**Error**: _Table 'Headline RC Prod. Planner' is removed. Reason: Replaced with "RC Headlines User Data" table_\
**Error**: _Table 'Headline RC Serv. Dispatcher' is removed. Reason: Replaced with "RC Headlines User Data" table_\
**Error**: _Table 'Headline RC Administrator' is removed. Reason: Replaced with "RC Headlines User Data" table_\
**Error**: _Table 'Headline RC Team Member' is removed. Reason: Replaced with "RC Headlines User Data" table_\
**Error**: _Table 'Headline RC Project Manager' is removed. Reason: Replaced with "RC Headlines User Data" table_\
**Error**: _Table 'Headline RC Relationship Mgt.' is removed. Reason: Replaced with "RC Headlines User Data" table_\
**Error**: _Table 'Headline RC Order Processor' is removed. Reason: Replaced with "RC Headlines User Data" table_\
**Error**: _Table 'Headline RC Accountant' is removed. Reason: Replaced with "RC Headlines User Data" table_

**Solution**: Tables were combined into `table 1458 "RC Headlines User Data"`.

**Error**:  _Codeunit "Item Tracking Management" does not contain a definition for 'CopyItemTracking2'_

**Solution**: Function is now an overload, function `CopyItemTracking`.

**Error**: _'Codeunit "Sales-Post Prepayments"' does not contain a definition for 'BuildInvLineBuffer2'_\
**Error**: _'Codeunit "Purchase-Post Prepayments"' does not contain a definition for 'BuildInvLineBuffer2'_

**Solution**: Function is now an overload, function `BuildInvLineBuffer`.

**Error**: _'Codeunit DimensionManagement' does not contain a definition for 'EditDimensionSet2'_

**Solution**: Function is now an overload, function `EditDimensionSet`.

**Error**: _'Codeunit "File Management"' does not contain a definition for 'IsWebClient'_

**Solution**: Use ClientType options directly.

---

## Removed Functions
**Error**: _Codeunit "Type Helper"' does not contain a definition for 'WriteBlob'_

**Solution**: Use stream functions directly.

**Error**: _Codeunit "Type Helper"' does not contain a definition for 'ReadBlob'_

**Solution**: Use stream functions directly.

**Error**:  _Record "Job Queue Log Entry" does not contain a definition for 'GetErrorMessage'_

**Solution**: Use the "Error Message" field directly.
