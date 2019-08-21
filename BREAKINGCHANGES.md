# Breaking Changes
### ...and how to resolve them
In this help document, you will find a list of known breaking changes which were introduced in the latest major release. You will also get help on the changes you need to do to your code to make it compile again against the latest version of the Business Central System Application and Base Application.

# Work in progress
The breaking changes are currently being identified. We will update this site with more help on this topic very soon.

# Modules

## BLOB Storage Module
**Error**: _Argument 1: cannot convert from 'Record TempBlob' to 'var Codeunit "Temp Blob"'_

**Solution**: Use `codeunit 4100 "Temp Blob"` API instead of the record API.

---

## Cryptography Management Module
**Error**: _Codeunit "Encryption Management"' does not contain a definition for 'GenerateKeyedHash'_

**Solution**: Function has been moved to `codeunit 1266 "Encryption Management"`, function `GenerateHash`

---

## Environment Information Module
**Error**: _Codeunit "Permission Manager"' does not contain a definition for 'SoftwareAsAService'_

**Solution**: Function has been moved to `codeunit 457 "Environment Information"`, function `IsSaaS`.

**Error**: _Codeunit "Tenant Settings"' does not contain a definition for 'IsSandbox'_

**Solution**: Function has been moved to `codeunit 457 "Environment Information"`, function `IsSandbox`.

**Error**: _Codeunit "Permission Manager"' does not contain a definition for 'IsSandboxConfiguration'_

**Solution**: Function has been moved to `codeunit 457 "Environment Information"`, function `IsSandbox`

---

## Language Module
**Error**: _Codeunit 'LanguageManagement' is missing_

**Solution**: Codeunit was renamed to `codeunit 43 Language`.

**Error**: _'Record Language' does not contain a definition for 'GetUserLanguage'_

**Solution**: Function has been moved to `codeunit 43 Language`, function `GetUserLanguageCode`.

**Error**: _Record Language' does not contain a definition for 'GetLanguageID'_

**Solution**: Function has been moved to `codeunit 43 Language`, function `GetLanguageId`.

---

## Tenant Settings Module
**Error**: _Codeunit 'Tenant Management' is missing_

**Solution**: Codeunit was split into `codeunit 417 "Tenant Settings"` and `codeunit 457 "Environment Information"`.

**Error**: _Codeunit "Identity Management"' does not contain a definition for 'GetAadTenantId'_

**Solution**: Function has been moved to `codeunit 417 "Tenant Settings"`, function `GetAadTenantIds`

---

## User Permissions Module
**Error**: _Codeunit "Permission Manager"' does not contain a definition for 'IsSuper'_

**Solution**: Function has been moved to `codeunit 152 "User Permissions"`, function `IsSuper`

---

## Removed Functions
**Error**: _Codeunit "Type Helper"' does not contain a definition for 'WriteBlob'_

**Solution**: Use stream functions directly.

**Error**: _Codeunit "Type Helper"' does not contain a definition for 'ReadBlob'_

**Solution**: Use stream functions directly.