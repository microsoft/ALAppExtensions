# Breaking Changes
### ...and how to resolve them
This document contains a list of the breaking changes that we know were introduced since 2019 release wave 2. For each breaking change we’ve provided some information about what you need to do to your code so that it will compile again against the latest version of the System Application and Base Application in Business central.

# Can’t find what you’re looking for?
This document is a work in progress because earlier changes are still being identified, and because sometimes a change can’t be avoided, for example, when addressing a performance issue. We will continue to update this list whenever we, or one of our partners, discover new issues. We’re working hard to make this a comprehensive list, but there’s always a chance that something is missing. If you can’t find what you’re looking for here, we suggest that you engage with other members of the Business Central community on [Yammer](https://www.yammer.com/dynamicsnavdev/), or reach out to us on [GitHub](https://github.com/microsoft/ALAppExtensions/issues) to let us know.

# 2020 release wave 1

## General

**Error**: _Field * is removed. Reason: *_\
**Error**: _Table * is removed. Reason: *_

**Solution**: Please review the reason for how to resolve this error.

**Error**: _cannot convert from 'Decimal' to the type of Argument 1 'Enum *'_

**Solution**: Convert a Decimal through the Enum's FromInteger functionality.

```
procedure EnumFromDecimal()
var
    d: Decimal;
    e: Enum MyEnum;
begin
    e := MyEnum.FromInteger(d);
end;
```

**Error**: _cannot convert from 'Enum 1' to the type of Argument 1 'Enum 2'_\
**Error**: _Cannot implicitly convert type 'Enum 1' to 'Enum 2'_

**Solution**: Set the AssignmentCompatibility option on the Enum to true;

**Error**: _A member of type Action with name * is already defined in Page * by the extension *_\
**Error**: _A member of type Field with name * is already defined in Page * by the extension *_\
**Error**: _A member of type Part with name * is already defined in Page * by the extension *_

**Solution**: Rename your Action/Field/Part to avoid duplicating the name. Names of Action/Field/Part must be unique.

# 2019 release wave 2

We’ve organized the breaking changes in this list according to the modules that they apply to. For example, we moved the TextManagement codeunit to the Filter Tokens module, so we’ve included the description of the change in the group for the module.

## Assisted Setup Module
**Error**: _'Assisted Setup' is inaccessible due to its protection level_

**Solution**: Please use the appropriate API methods in the `codeunit 3725 "Assisted Setup"`.

**Error**: _'Assisted Setup Icon' is inaccessible due to its protection level_

**Solution**: The table usage has been discontinued as the icons are going to be taken from the extension itself.

**Error**: _'Table "Assisted Setup"' does not contain a definition for 'SetStatus'_

**Solution**: Function has been discontinued. You may change the status to Complete by calling function `Complete` on `codeunit 3725 "Assisted Setup"`.

**Error**: _The event 'OnInitialize' is not found in the target"_

**Solution**: Event has been moved to `codeunit 3725 "Assisted Setup"`, function `OnRegister`.

**Error**: _The event 'OnUpdateAssistedSetupStatus' is not found in the target"_

**Solution**: Event has been moved to `codeunit 3725 "Assisted Setup"`, function `OnRegister`.

**Error**: _The event 'OnBeforeUpdateAssistedSetupStatus' is not found in the target"_

**Solution**: Event has been removed. You may alternatively use `codeunit 3725 "Assisted Setup"`, function `OnRegister`.

---

## Auto Format Module
**Error**: _Codeunit 'AutoFormatManagement' is missing_

**Solution**: Codeunit has been renamed to `codeunit 45 "Auto Format"`.

**Error**: _'Codeunit "Auto Format"' does not contain a definition for 'AutoFormatTranslate'_

**Solution**: The procedure `AutoFormatTranslate` has been renamed to `ResolveAutoFormat`. 
The procedure has also been refactored but the behavior is unchanged:
- The parameter `AutoFormatType: Enum Auto Format` replaces the parameter `AutoFormatType: Integer`.
- The logic for cases other than 0 (`Enum DefaultFormat`) and 11 (`Enum CustomFormatExpr`) has been moved to Base Application.

**Error**: _OnResolveAutoFormat has scope OnPrem_

**Solution**: The publisher `OnResolveAutoFormat` has the scope OnPrem, but everyone can subscribe to it and implement a new logic for formatting decimal numbers in text messages.
 
---

## Azure AD Plan Module
**Error**: _'User Plan' is inaccessible due to its protection level_     

**Solution**: OnPrem: access the table through the facade APIs, `codeunit 9016 "Azure AD Plan"`, or using the `query 774 "Users in Plans"`.
SaaS: access the table using the `query 774 "Users in Plans"`.

**Error**: _'Plan' is inaccessible due to its protection level_     

**Solution**: Access the table through the facade APIs, `codeunit 9016 "Azure AD Plan"`, or using the `query 775 Plan`.

**Error**: _'Codeunit \"Azure AD User Management\"' does not contain a definition for 'TryGetAzureUserPlanRoleCenterId'_

**Solution**: Function has been moved to `codeunit 9016 "Azure AD Plan"`, function `TryGetAzureUserPlanRoleCenterId`.

**Error**: _'Record Plan' does not contain a definition for 'GetInternalAdminPlanId'_

**Solution**: Function has been moved to `codeunit 9027 "Plan Ids"`, function `GetInternalAdminPlanId`.

**Error**: _'Record Plan' does not contain a definition for 'GetDelegatedAdminPlanId'_

**Solution**: Function has been moved to `codeunit 9027 "Plan Ids"`, function `GetDelegatedAdminPlanId`.

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

**Error**: _'Codeunit "Tenant Management"' does not contain a definition for 'IsSandbox'_

**Solution**: Function has been moved to `codeunit 457 "Environment Information"`, function `IsSandbox`.

---

## Base64 Convert Module
**Error**: _'Codeunit "Type Helper"' does not contain a definition for 'ConvertValueFromBase64'_

**Solution**: Function has been moved to `codeunit 4110 "Base64 Convert"`, function `FromBase64`.

**Error**: _'Codeunit "Type Helper"' does not contain a definition for 'ConvertValueToBase64'_

**Solution**: Function has been moved to `codeunit 4110 "Base64 Convert"`, function `ToBase64`.

---

## BLOB Storage Module
**Error**: _Argument 1: cannot convert from 'Record TempBlob' to 'var Codeunit "Temp Blob"'_

**Solution**: Use `codeunit 4100 "Temp Blob"` API instead of the record API.

**Error**: _'Codeunit "Temp Blob"' does not contain a definition for 'ToBase64String'_

**Solution**: Function has been moved to `codeunit 4110 "Base64 Convert"` function `ToBase64`.

**Error**: _'Codeunit "Temp Blob"' does not contain a definition for 'FromBase64String'_

**Solution**: Function has been moved to `codeunit 4110 "Base64 Convert"` function `FromBase64`.

**Error**: _'Codeunit "Temp Blob"' does not contain a definition for 'WriteAsText'_

**Solution**: Function has been removed. Replacement:

```
TempBlob.CreateOutStream(OutStream[, TextEncoding]);
OutStream.WriteText(Text);
```

**Error**: _'Codeunit "Temp Blob"' does not contain a definition for 'ReadAsText'_

**Solution**: Function has been removed. Replacement:

```
TempBlob.CreateInStream(InStream);
Result := InStream.ReadText;
```

**Error**: _'Codeunit "Temp Blob"' does not contain a definition for 'ReadAsTextWithCRLFLineSeparator'_

**Solution**: Function has been moved to `Codeunit 10 "Type Helper"` function `ReadAsTextWithSeparator`.

**Error**: _'Codeunit "Temp Blob"' does not contain a definition for 'StartReadingTextLines'_

**Solution**: Function has been removed. Replacement get the `InStream` and use the `ReadText` function.

**Error**: _'Codeunit "Temp Blob"' does not contain a definition for 'StartWritingTextLines'_

**Solution**: Function has been removed. Replacement get the `OutStream` and use the `WriteText` function.

**Error**: _'Codeunit "Temp Blob"' does not contain a definition for 'MoreTextLines'_

**Solution**: Function has been removed. Replacement use the function `EOS` from `InStream`.

**Error**: _'Codeunit "Temp Blob"' does not contain a definition for 'WriteTextLine'_

**Solution**: Function has been removed. Replacement:

```
TempBlob.CreateOutStream(OutStream);
OutStream.WriteText(Text);
```

**Error**: _'Codeunit "Temp Blob"' does not contain a definition for 'ReadTextLine'_

**Solution**: Function has been removed. Replacement:

```
TempBlob.CreateInStream(InStream);
Result := InStream.ReadText;
```

**Error**: _'Codeunit "Temp Blob"' does not contain a definition for 'GetHTMLImgSrc'_

**Solution**: Function has been moved to `codeunit 4112 "Image Helpers"` function `GetHTMLImgSrc`.

**Error**: _'Codeunit "Temp Blob"' does not contain a definition for 'GetImageType'_

**Solution**: Function has been moved to `codeunit 4112 "Image Helpers"` function `GetImageType`.

**Error**: _'Codeunit "Temp Blob"' does not contain a definition for 'GetXMLAsText'_

**Solution**: Function has been removed. Replacement:

```
TempBlob.CreateInStream(InStream);
Xml := XmlDocument.Create(Instream);
Xml.WriteTo(Text);
```

**Error**: _'Codeunit "Temp Blob"' does not contain a definition for 'TryDownloadFromUrl'_

**Solution**: Function has been removed. Replacement:

```
HttClient.Get(url, HttpResponseMessage);
HttpResponseMessage.Content.ReadAs(InStream);
TempBlob.CreateOutStream(OutStream);
CopyStream(OutStream, InStream);
```

---

## Caption Class Module
**Error**: _'Codeunit' does not contain a definition for 'CaptionManagement'_

**Solution**: Events have been moved to `codeunit 42 "Caption Class"`.

**Error**: _The event 'OnAfterCaptionClassTranslate' is not found in the target_

**Solution**: Event has been moved to `codeunit 42 "Caption Class"`, function `OnAfterCaptionClassResolve`.

---

## Client Type Management Module
**Error**: _Codeunit 'ClientTypeManagement' is missing_
**Error**: _Codeunit '4' is missing_

**Solution**: Codeunit has been renamed to `codeunit 4030 "Client Type Management"`.

---

## Confirm Management Module
**Error**: _'Codeunit "Confirm Management"' does not contain a definition for 'ConfirmProcess'_\

**Solution**: Function has been renamed to `GetResponseOrDefault`.

---

## Cryptography Management Module
**Error**: _Codeunit 'Encryption Management' is missing_

**Solution**: Codeunit has been renamed to `codeunit 1266 "Cryptography Management"`.

**Error**: _'Codeunit "Encryption Management"' does not contain a definition for 'GenerateKeyedHash'_

**Solution**: Function has been moved to `codeunit 1266 "Cryptography Management"`, function `GenerateHash`.

**Error**: _The event 'OnBeforeEncryptDataInAllCompaniesOnPrem' is not found in the target"_

**Solution**: Use the event `OnBeforeEnableEncryptionOnPrem` instead.

**Error**: _The event 'OnBeforeDecryptDataInAllCompaniesOnPrem' is not found in the target"_

**Solution**: Use the event `OnBeforeDisableEncryptionOnPrem` instead.

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

**Error**: _'Codeunit "File Management"' does not contain a definition for 'AddStreamToZipStream'_

**Solution**: Function has been moved to `codeunit 425 "Data Compression"`, function `AddEntry`.

**Error** _'Codeunit "Zip Stream Wrapper"' does not contain a definition for 'UploadZip'_

**Solution**: Function has been removed. Replacement:

```
UploadIntoStream('', '', '*.*', '', InStream);
DataCompression.OpenZipArchive(InStream, OpenForUpdate);
```

**Error** _'Codeunit "Zip Stream Wrapper"' does not contain a definition for 'OpenZipFromTempBlob'_

**Solution**: Function has been moved to `codeunit 425 "Data Compression"`, function `OpenZipArchive`.

**Error** _'Codeunit "Zip Stream Wrapper"' does not contain a definition for 'DownloadZip'_

**Solution**: Function has been removed. Replacement:

```
DataCompression.SaveZipArchive(TempBlob);
TempBlob.CreateInStream(InStream);
DownloadFromStream(InStream, '', '', '', OutputFileName);
```

**Error** _'Codeunit "Zip Stream Wrapper"' does not contain a definition for 'SaveZipToTempBlob'_

**Solution**: Function has been moved to `codeunit 425 "Data Compression"`, function `SaveZipArchive`.

---

## Environment Information Module
**Error**: _'Codeunit "Permission Manager"' does not contain a definition for 'SoftwareAsAService'_

**Solution**: Function has been moved to `codeunit 457 "Environment Information"`, function `IsSaaS`.

**Error**: _'Codeunit "Permission Manager"' does not contain a definition for 'IsSandboxConfiguration'_\
**Error**: _'Codeunit "Tenant Settings"' does not contain a definition for 'IsSandbox'_

**Solution**: Function has been moved to `codeunit 457 "Environment Information"`, function `IsSandbox`.

**Error**: _'Codeunit "Tenant Information"' does not contain a definition for 'GetPlatformVersion'_

**Solution**: The function a very technical term about the platform build number used internally by MS. Please use the alternate methods available in either `codeunit 417 "Tenant Information"` or `codeunit 457 "Environment Information"`.

---

## Extension Management Module
**Error**: _'Extension Installation Impl' is inaccessible due to its protection level_\
**Error**: _Codeunit 'NavExtensionInstallationMgmt' is missing_

**Solution**: Access the codeunit through the facade APIs, `codeunit 2504 "Extension Management"`.

**Error**: _'Extension Management' does not contain a definition for 'GetLatestVersionPackageId'_

**Solution**: Function has been renamed to function `GetLatestVersionPackageIdByAppId`.

**Error**: _'Extension Management' does not contain a definition for 'InstallNavExtension'_

**Solution**: Function has been renamed to function `InstallExtension`. Notice additional parameter IsUIEnabled that indicates whether the install operation is invoked through the UI.
	
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

**Error**: _The event 'OnBeforeMakeTextFilter' is not found in the target"_

**Solution**: Use the event `OnResolveTextFilterToken` instead.

**Error**: _The event 'OnAfterMakeTextFilter' is not found in the target"_

**Solution**: Use the event `OnResolveTextFilterToken` instead.

**Error**: _The event 'OnAfterMakeDateTimeFilter' is not found in the target"_

**Solution**: Use the events `OnResolveTimeTokenFromDateTimeFilter` and `OnResolveDateTokenFromDateTimeFilter` instead.

**Error**: _The event 'OnAfterMakeDateFilter' is not found in the target"_

**Solution**: Use the event `OnResolveDateFilterToken` instead.

**Error**: _The event 'OnAfterMakeTimeFilter' is not found in the target"_

**Solution**: Use the event `OnResolveTimeFilterToken` instead.

**Error**: _'Codeunit "TextManagement"' does not contain a definition for 'MakeText'_

**Solution**: Function has been removed as it had no callers.

**Error**: _'Codeunit "TextManagement"' does not contain a definition for 'MakeDateText'_

**Solution**: Function has been removed as it had no callers.

**Error**: _'Codeunit "TextManagement"' does not contain a definition for 'MakeTimeText'_

**Solution**: Function has been removed as it had no callers.

**Error**: _'Codeunit "TextManagement"' does not contain a definition for 'MakeDateTimeText'_

**Solution**: Function has been removed as it had no callers.

**Error**: _'Filter Tokens' does not contain a definition for 'EvaluateIncStr'_

**Solution**: The function has been removed. Please create a copy of the function if you need it.

```
procedure EvaluateIncStr(StringToIncrement: Code[50]; ErrorHint: Text)
begin
    if IncStr(StringToIncrement) = '' then
        Error('%1 contains no number and cannot be incremented.', ErrorHint);
end;
```

---

## Headlines Module
**Error**: _Codeunit 'Headline Management' is missing_

**Solution**: Codeunit has been renamed to `codeunit 1439 Headlines`.

---

## Language Module
**Error**: _Codeunit 'LanguageManagement' is missing_

**Solution**: Codeunit was renamed to `codeunit 43 Language`.

**Error**: _'Codeunit "LanguageManagement"' does not contain a definition for 'ApplicationLanguage'_

**Solution**: Function has been replaced by `GetDefaultApplicationLanguageId` in `codeunit 43 Language`.

**Error**: _'Codeunit "LanguageManagement"' does not contain a definition for 'LookupApplicationLanguage'_

**Solution**: Function has been replaced by `LookupApplicationLanguageId` in `codeunit 43 Language`.

**Error**: _'Record Language' does not contain a definition for 'GetUserLanguage'_

**Solution**: Function has been replaced by `GetUserLanguageCode` in `codeunit 43 Language`.

**Error**: _'Record Language' does not contain a definition for 'GetLanguageID'_

**Solution**: Function has been moved to `codeunit 43 Language`, function `GetLanguageId`. If empty language code could be expected, use `GetLanguageIdOrDefault` instead.

**Error**: _'Codeunit Language' does not contain a definition for 'TryGetCultureName'_

**Solution**: Function has been removed. The replacement:
```
[TryFunction]
procedure TryGetCultureName(Culture : Integer; VAR CultureName : Text)
var
    DotNet_CultureInfo: Codeunit DotNet_CultureInfo;
begin
    DotNet_CultureInfo.GetCultureInfoByName(Culture);
    CultureName := DotNet_CultureInfo.Name();
end;
```

**Error**: _'Codeunit Language' does not contain a definition for 'GetWindowsLanguageNameFromLanguageID'_

**Solution**: Function has been replaced by `GetWindowsLanguageName` in `codeunit 43 Language`.

**Error**: _'Codeunit Language' does not contain a definition for 'LookupWindowsLocale'_

**Solution**: Function has been replaced by `LookupWindowsLanguageId` in `codeunit 43 Language`

**Error**: _'Codeunit Language' does not contain a definition for 'GetLanguageCodeFromLanguageID'_

**Solution**: Function has been replaced by `GetLanguageCode` in `codeunit 43 Language`.

---

## Manual Setup Module
**Error**: _'Business Setup Icon' is inaccessible due to its protection level_

**Solution**: Access the table through the facade APIs, `codeunit 1875 "Manual Setup"`.

**Error**: _Page '"Business Setup"' is missing_

**Solution**: Page has been renamed to `page 1875 "Manual Setup"`.

**Error**: _The event 'OnRegisterBusinessSetup' is not found in the target"_

**Solution**: Event has been moved to `codeunit 1875 "Manual Setup"`, function `OnRegisterManualSetup`.

---

## Password Dialog Module
**Error**: _The target Page "Set Password" for the extension object is not found_\
**Error**: _The target Page "Change Password" for the extension object is not found_

**Solution**: Page has been renamed to `page 9810 "Password Dialog"`, but is not extensible.

---

## Record Link Management Module
**Error**: _'Codeunit "Type Helper"' does not contain a definition for 'WriteRecordLinkNote'_

**Solution**: Function has been moved to `codeunit 447 "Record Link Management"`, function `WriteNote`.

**Error**: _'Codeunit "Type Helper"' does not contain a definition for 'ReadRecordLinkNote'_

**Solution**: Function has been moved to `codeunit 447 "Record Link Management"`, function `ReadNote`.

---

## Satisfaction Survey Module
**Error**: _'Net Promoter Score' is inaccessible due to its protection level_
**Error**: _'Net Promoter Score Setup' is inaccessible due to its protection level_

**Solution**: Table is neither customizable nor accessible.

**Error**: _The target Page "Net Promoter Score Setup" for the extension object is not found_

**Solution**: Page is neither customizable nor accessible.

---

## Server Settings Module
**Error**: _Codeunit 'Server Config. Setting Handler' is missing_

**Solution**: Codeunit has been renamed to `codeunit 6723 "Server Setting"`.

---

## System Initialization Module
**Error**: _Codeunit 'Logon Management' is missing_\

**Solution**: Codeunit has been renamed to `codeunit 150 "System Initialization"`.

**Error**: _'Codeunit "System Initialization"' does not contain a definition for 'IsLogonInProgress'_\

**Solution**: Function has been moved to `codeunit 150 "System Initialization"`, function `IsInProgress`.

**Error**: _'Codeunit "System Initialization"' does not contain a definition for 'SetLogonInProgress'_

**Solution**: Function has been removed.

---

## Tenant License State Module

**Error**: _No overload for method 'GetStartDate' takes 1 arguments_\
**Error**: _No overload for method 'GetEndDate' takes 1 arguments_\

**Solution**: Method has been moved to `codeunit 2300 "Tenant License State"` without any parameters.

---

## Upgrade Tags Module
**Error**: _Codeunit 'Upgrade Tag Mgt' is missing_

**Solution**: Codeunit has been renamed to `codeunit 9999 "Upgrade Tag"`.

---

## User Login Times Module
**Error**: _'Codeunit "Permission Manager"' does not contain a definition for 'IsFirstLogin'_

**Solution**: Function has been moved to `codeunit 9026 "User Login Time Tracker"`, function `IsFirstLogin`.

**Error**: _'Table "User Login"' does not contain a definition for 'UserLoggedInAtOrAfter'_

**Solution**: Function has been moved to `codeunit 9026 "User Login Time Tracker"`, function `UserLoggedInSinceDateTime`.

---

## User Permissions Module
**Error**: _'Codeunit "Permission Manager"' does not contain a definition for 'IsSuper'_

**Solution**: Function has been moved to `codeunit 152 "User Permissions"`, function `IsSuper`.

---

## User Selection Module
**Error**: _'Codeunit "User Management"' does not contain a definition for 'ValidateUserID'_

**Solution**: Function has been moved to `codeunit 9843 "User Selection"`, function `ValidateUserName`.

**Error**: _'Codeunit "User Management"' does not contain a definition for 'LookupUserID'_

**Solution**: Function has been removed. Reason: the TableRelation property enables lookup logic on platform level.

**Design details**
The TableRelation property makes onLookup trigger redundant. However the ValidateTableRelation property requires validation logic in OnValidate trigger.

```
field(1; "User ID"; Code[50])
{
    Caption = 'User ID';
    DataClassification = EndUserIdentifiableInformation;
    NotBlank = true;
    TableRelation = User."User Name";
    ValidateTableRelation = false;

    trigger OnValidate()
    var
        UserSelection: Codeunit "User Selection";
    begin
        UserSelection.ValidateUserName("User ID");
    end;
}
```

If you want to enable DrillDown for non-editable page, you need to use `DisplayUserInformation` from Codeunit "User Management"  
```
field("User ID"; "User ID")
{
    ApplicationArea = Jobs;
    ToolTip = 'Specifies the ID of the user who posted the entry, to be used, for example, in the change log.';

    trigger OnDrillDown()
    var
        UserMgt: Codeunit "User Management";
    begin
        UserMgt.DisplayUserInformation("User ID");
    end;
} 
```
If you prefer platform support vote for the https://experience.dynamics.com/ideas/idea/?ideaid=4075b3be-5ba8-e811-b96f-0003ff68a2af.


---

## Video Module
**Error**: _'Product Video Buffer' is inaccessible due to its protection level_\
**Error**: _'SetURL(Text)' is inaccessible due to its protection level_

**Solution**: Access the table through the facade APIs, `codeunit 3710 Video`.

**Error**: _Page 'Video Player Page' is missing_

**Solution**: Access the page through the facade APIs, `codeunit 3710 Video`, function `Play`.

---

## Base Application
**Error**: _GlobalVarAccess in Event Publisher is set to false_

**Solution**: We do not set GlobalVarAccess anymore, as this property will be discontinued in the next major release of AL. We have set this property to `false` everywhere, but are ready to respond to requests here on GitHub to add additional events/parameters to mitigate this issue immediately.

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

**Error**: _The event 'OnIsAnyExtensionHeadlineVisible' is not found in the target_

**Solution**: Event has been moved to `codeunit 1440 "RC Headlines Page Common"`, function `OnIsAnyExtensionHeadlineVisible`.

**Error**: _'Codeunit "Identity Management"' does not contain a definition for 'IsInvAppId'_

**Solution**: Function has been moved to `codeunit 9995 "Env. Info Proxy"`, function `IsInvoicing`.

**Error**: _'Codeunit "Conf./Personalization Mgt."' does not contain a definition for 'GetCurrentProfileIDNoError'_

**Solution**: Profiles are no longer uniquely identified by their ID: use `'GetCurrentProfileNoError(var AllProfile: Record "All Profile")'` instead.

**Error**: _'Codeunit "Conf./Personalization Mgt."' does not contain a definition for 'ExportProfilesInZipFile'_\
**Error**: _'Codeunit "Conf./Personalization Mgt."' does not contain a definition for 'ExportProfiles'_\
**Error**: _'Codeunit "Conf./Personalization Mgt."' does not contain a definition for 'ImportProfiles'_

**Solution**: Export the profiles in the AL format using `DownloadProfileConfigurationPackage` instead.

**Error**: _'Codeunit "Conf./Personalization Mgt."' does not contain a definition for 'InsertProfile'_\
**Error**: _'Codeunit "Conf./Personalization Mgt."' does not contain a definition for 'InitializeProfiles'_\
**Error**: _The event 'OnInitializeProfiles' is not found in the target_

**Solution**: Use the [Profile](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-profile-object) objects built into the AL language instead.

**Error**: _'Codeunit "Conf./Personalization Mgt."' does not contain a definition for 'ImportTranslatedResources'_\
**Error**: _'Codeunit "Conf./Personalization Mgt."' does not contain a definition for 'ImportTranslatedResourcesWithFolderSelection'_\
**Error**: _'Codeunit "Conf./Personalization Mgt."' does not contain a definition for 'ExportTranslatedResources'_\
**Error**: _'Codeunit "Conf./Personalization Mgt."' does not contain a definition for 'ExportTranslatedResourcesWithFolderSelection'_\
**Error**: _'Codeunit "Conf./Personalization Mgt."' does not contain a definition for 'RemoveTranslatedResources'_\
**Error**: _'Codeunit "Conf./Personalization Mgt."' does not contain a definition for 'RemoveTranslatedResourcesWithLanguageSelection'_\
**Error**: _The event 'OnTranslateProfileID' is not found in the target_

**Solution**: Use the `CaptionML` and `ProfileDescriptionML` properties in the [Profile](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-profile-object) AL objects to translate the profile, and [Page Customization](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-page-customization-object) AL objects for other translations.

**Error**: _The event 'OnGetBuiltInRoleCenterFilter' is not found in the target_

**Solution**: Mark the profiles as `AllProfile.Enabled := false` to hide it from the profile selection, or subscribe to the [Page Trigger Events](https://docs.microsoft.com/en-us/dynamics-nav/event-types#PageEvents) to hide the profile from specific pages.

**Error**: _'Codeunit "Type Helper"' does not contain a definition for 'RegexReplace'_

**Solution**: Function has been removed. The alternative is in `codeunit 3001 DotNet_Regex`, function `Replace`.

**Error**: _'Codeunit "Type Helper"' does not contain a definition for 'RegexReplaceIgnoreCase'_\

**Solution**: Function has been removed. The replacement:
```
procedure RegexReplaceIgnoreCase(Input : Text; Pattern : Text; Replacement : Text)
var
    DotNet_Regex: Codeunit DotNet_Regex;
begin
    DotNet_Regex.RegexIgnoreCase(Pattern);
    DotNet_Regex.Replace(Input, Replacement);
end;
```

**Error**: _'Codeunit "Type Helper"' does not contain a definition for 'IsMatch'_

**Solution**: Function has been removed. The alternative is in `codeunit 3001 DotNet_Regex`, function `IsMatch`.

**Error**: _'Codeunit "Type Helper"' does not contain a definition for 'IsAsciiLetter'_

**Solution**: Function has been removed. The alternative is in `codeunit 3001 DotNet_Regex`, function `IsAsciiLetter`.

**Error**: _'Codeunit "Type Helper"' does not contain a definition for 'IsAlphanumeric'_

**Solution**: Function has been removed. The alternative is in `codeunit 3001 DotNet_Regex`, function `IsMatch`.

Example: `TypeHelper.IsAlphanumeric(InputString)` becomes `DotNet_Regex.IsMatch(InputString,'^[a-zA-Z0-9]*$')`

**Error**: _'Codeunit "Type Helper"' does not contain a definition for 'TextEndsWith'_

**Solution**: Function has been removed. The alternative is in `codeunit 3001 DotNet_Regex`, function `IsMatch`.

Example:
`TypeHelper.TextEndsWith(InputString, EndingString)` becomes `DotNet_Regex.IsMatch(InputString, EndingString + '$')`

**Error**:  _Codeunit "Item Tracking Management" does not contain a definition for 'CopyItemTracking2'_

**Solution**: Function is now an overload, function `CopyItemTracking`.

**Error**: _'Codeunit "Sales-Post Prepayments"' does not contain a definition for 'BuildInvLineBuffer2'_\
**Error**: _'Codeunit "Purchase-Post Prepayments"' does not contain a definition for 'BuildInvLineBuffer2'_

**Solution**: Function is now an overload, function `BuildInvLineBuffer`.

**Error**: _'Codeunit DimensionManagement' does not contain a definition for 'EditDimensionSet2'_

**Solution**: Function is now an overload, function `EditDimensionSet`.

**Error**: _The event 'OnMoveGenJournalLine' is not found in the target_

**Solution**: Event has been moved to `codeunit 12 "Gen. Jnl.-Post Line"`, function `OnMoveGenJournalLine`.

**Error**: _Table 'Cortana Intelligence Usage' is removed. Reason: Renamed to Azure AI Usage_

**Solution**: Table has been renamed to `table 2004 "Azure AI Usage"`.

**Error**: _Table 'Cortana Intelligence' is removed. Reason: Renamed to Cash Flow Azure AI Buffer_

**Solution**: Table has been renamed to `table 852 "Cash Flow Azure AI Buffer"`.

**Error**: _'Codeunit "CalendarManagement"' is missing'_

**Solution**: Codeunit was renamed to `Shop Calendar Management`.

**Error**: _'Codeunit "Calendar Management"' does not contain a definition for 'CheckCustomizedDateStatus'_

**Solution**: Function has been replaced, function `IsNonworkingDay`.

**Error**: _'Codeunit "Calendar Management"' does not contain a definition for 'CustomizedCalendarExistText'_

**Solution**: Function has been removed. Replacement function call `Format(CalendarMgmt.CustomizedChangesExist(Rec))`.

**Error**: _No overload for method CalendarMgt.'CustomizedChangesExist' takes 4 arguments_

**Solution**: Function parameters have changed. It now takes a variant record parameter. 

**Error**: _No overload for method CalendarMgt.'CheckDateStatus' takes 3 arguments_

**Solution**: Function parameters have changed. It now takes a "Customized Calendar Change" record parameter.

**Error**: _'Codeunit "SMTP Mail"' does not contain a definition for 'TrySend'_

**Solution**: Function has been renamed, function `Send`. If you were using `Send` before, that has been renamed to `SendShowError`.

**Error**: _SMTPMail.AddRecipients parameter cannot convert from 'Text' to 'List of [Text]'_\
**Error**: _SMTPMail.AddCC parameter cannot convert from 'Text' to 'List of [Text]'_\
**Error**: _SMTPMail.AddBCC parameter cannot convert from 'Text' to 'List of [Text]'_

**Solution**: Create a List of [Text] with the recipient(s).
```
procedure Adding()
var
    Recipients: List of [Text];
begin
    Recipients.Add('Email');
    SMTPMail.AddRecipients(Recipients);
end;
```

---

**Error**: 'Codeunit "Reservation Management"' does not contain a definition for 'DeleteReservEntries2'.

**Solution**: Is now an overload of DeleteReservEntries.

**Error**: 'Codeunit "User Setup Management"' does not contain a definition for 'CheckRespCenter2'.

**Solution**: Is now an overload of CheckRespCenter.

**Error**: 'Codeunit "User Setup Management"' does not contain a definition for 'GetSalesFilter2'.

**Solution**: Is now an overload of GetSalesFilter

**Error**: No overload for method 'CalcDateBOC' takes 9 arguments.

**Solution**: Has been changed to use a CustomCalendarChange: Array[2] of Record "Customized Calendar Change";
```
CustomCalendarChange[1].SetSource(CalChange."Source Type"::"Shipping Agent", "Shipping Agent Code", "Shipping Agent Service Code", '');
CustomCalendarChange[2].SetSource(CalChange."Source Type"::Location, "Location Code", '', '');
CalendarMgmt.CalcDateBOC2(Format("Shipping Time"), "Planned Delivery Date", CustomCalendarChange, true);
```

**Error**: 'Codeunit Language' does not contain a definition for 'SetGlobalLanguageByCode'

**Solution**: Function has been moved to `codeunit 53 "Translation Helper"`, function `SetGlobalLanguageByCode`.

**Error**: 'Codeunit Language' does not contain a definition for 'RestoreGlobalLanguage'

**Solution**: Function has been moved to `codeunit 53 "Translation Helper"`, function `RestoreGlobalLanguage`.

**Error**: 'Codeunit Language' does not contain a definition for 'GetTranslatedFieldCaption'

**Solution**: Function has been moved to `codeunit 53 "Translation Helper"`, function `GetTranslatedFieldCaption`.

---

## Removed Functionality
**Error**: _'Codeunit "Type Helper"' does not contain a definition for 'GetBlobString'_\
**Error**: _'Codeunit "Type Helper"' does not contain a definition for 'SetBlobString'_\
**Error**: _'Codeunit "Type Helper"' does not contain a definition for 'ReadBlob'_\
**Error**: _'Codeunit "Type Helper"' does not contain a definition for 'ReadTextBlob'_\
**Error**: _'Codeunit "Type Helper"' does not contain a definition for 'WriteBlobWithEncoding'_\
**Error**: _'Codeunit "Type Helper"' does not contain a definition for 'WriteBlob'_\
**Error**: _'Codeunit "Type Helper"' does not contain a definition for 'WriteTextToBlobIfChanged'_\
**Error**: _'Codeunit "Type Helper"' does not contain a definition for 'ReadTextBlobWithEncoding'_\
**Error**: _'Codeunit "Type Helper"' does not contain a definition for 'ReadTextBlobWithTextEncoding'_

**Solution**: Use stream functions directly.

**Error**: _'Codeunit "Type Helper"' does not contain a definition for 'TryConvertWordBlobToPdf'_\
**Error**: _'Codeunit "Type Helper"' does not contain a definition for 'FindFields'_\
**Error**: _'Codeunit "Type Helper"' does not contain a definition for 'Equals'_\
**Error**: _'Codeunit "Type Helper"' does not contain a definition for 'AddMinutesToDateTime'_

**Solution**: Function has been removed.

**Error**: _'Codeunit "File Management"' does not contain a definition for 'IsWebClient'_

**Solution**: Use ClientType options directly.

**Error**:  _Record "Job Queue Log Entry" does not contain a definition for 'GetErrorMessage'_

**Solution**: Use the "Error Message" field directly.

**Error**: _The object Page '%1' is not extensible_

**Solution**: If you need to extend a page, contact us through Yammer or GitHub. Include the use case, and we will decide whether to open things up for it.

**Error**: _The control '%1' is not found in the target_

**Solution**: The anchor control has been renamed or deleted. Update or change to a new anchor.

**Error**: _The action '%1' is not found in the target_

**Solution**: The anchor action has been renamed or deleted. Update or change to a new action.

**Error**: _The event 'OnOpenBusinessSetupPage' is not found in the target_
**Error**: _The event 'OnInitializeProfiles' is not found in the target_

**Solution**: Event has been removed.

**Error**: _Table 'Service Password' is removed. Reason: The suggested way to store the secrets is Isolated Storage, therefore Service Password will be removed._\
**Error**: _Table 'Encrypted Key/Value' is removed. Reason: The suggested way to store the secrets is Isolated Storage, therefore Encrypted Key/Value will be removed._

**Solution**: Table has been removed. Secrets should now be stored using [Isolated Storage](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-isolated-storage). Read more about [Changes in Secret Management](https://cloudblogs.microsoft.com/dynamics365/it/2019/08/14/changes-in-secret-management).

**Error**: _Codeunit 'Getting Started Mgt.' is missing_

**Solution**: Codeunit has been removed.

**Error**: _'"System Indicator"' does not contain a definition for 'Company+Database'_

**Solution**: Option has been removed. You may use the 'Custom' option and include 4 characters in "Custom System Indicator Text".

**Error**: _'Codeunit Language' does not contain a definition for 'TrySetGlobalLanguage'_

**Solution**: The function has been removed. If you require it, you can create a function that does the same functionality.

```
// <summary>
// TryFunction for setting the global language.
// </summary>
// <param name="LanguageId">The id of the language to be set as global</param>
[TryFunction]
local procedure TrySetGlobalLanguage(LanguageId: Integer)
begin
    GlobalLanguage(LanguageId);
end;
```

**Error**: _'Codeunit Language' does not contain a definition for 'TryGetCultureName'_

**Solution**: The function has been removed.

**Error**: _'Record "User Login"' does not contain a definition for 'UpdateLastLoginInfo'_

**Solution**: The function has been moved to `codeunit 9026 "User Login Time Tracker"`, function `CreateOrUpdateLoginInfo` and has OnPrem scope. 
