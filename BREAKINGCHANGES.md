# Breaking Changes
### ...and how to resolve them
In this help document, you will find a list of known breaking changes which were introduced in the latest major release. You will also get help on the changes you need to do to your code to make it compile again against the latest version of the Business Central System Application and Base Application.

# Work in progress
The breaking changes are currently being identified. We will update this site with more help on this topic very soon.

# Can’t find what you’re looking for?
We’re working hard to make this a comprehensive list, but there’s always a chance that something is missing. If you can’t find what you’re looking for here, we suggest that you engage with other members of the Business Central community on Yammer, or reach out to us on GitHub to let us know.

# Modules
## Auto Format Module
**Error**: _Codeunit 'AutoFormatManagement' is missing_

**Solution**: Codeunit has been renamed to `codeunit 45 "Auto Format"`.
 
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

**Error**: _The event 'OnAfterCaptionClassTranslate' is not found in the target_

**Solution**: Event has been moved to `codeunit 42 "Caption Class"`, function `OnAfterCaptionClassResolve`.

---

## Client Type Management Module
**Error**: _Codeunit 'ClientTypeManagement' is missing_\
**Error**: _Codeunit '4' is missing_

**Solution**: Codeunit has been renamed to `codeunit 4030 "Client Type Management"`.

---

## Cryptography Management Module
**Error**: _'Codeunit "Encryption Management"' does not contain a definition for 'GenerateKeyedHash'_

**Solution**: Function has been moved to `codeunit 1266 "Cryptography Management"`, function `GenerateHash`.

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

## Password Dialog Module
**Error**: _The target Page "Set Password" for the extension object is not found_\
**Error**: _The target Page "Change Password" for the extension object is not found_

**Solution**: Page has been renamed to `page 9810 "Password Dialog"`, but is not extensible.

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

## Removed Functionality
**Error**: _'Codeunit "Type Helper"' does not contain a definition for 'WriteBlob'_\
**Error**: _'Codeunit "Type Helper"' does not contain a definition for 'ReadBlob'_\
**Error**: _'Codeunit "Type Helper"' does not contain a definition for 'GetBlobString'_

**Solution**: Use stream functions directly.

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
