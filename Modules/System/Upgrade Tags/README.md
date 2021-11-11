This module provides functionality for ensuring that the upgrade code is run only one time.

Use the following construct between the upgrade code:

```
if UpgradeTag.HasUpgradeTag(UpgradeTagValue) then
  exit;

DoUpgrade();

UpgradeTag.SetUpgradeTag(UpgradeTagValue);
```

To avoid running upgrade code on the next upgrade, do the following:
1. Register upgrade tags for new companies by subscribing to the OnGetPerCompanyUpgradeTags or OnGetPerDatabaseUpgradeTags events.
2. Register the OnInstallation upgrade tags of the extension, if applicable, by calling the UpgradeTag.SetUpgradeTag(UpgradeTagValue) in the OnInstall triggers.

This module must be used for upgrade purposes only.

Upgrade Tags are used within upgrade codeunits to know which upgrade methods have been run and to prevent executing the same upgrade code twice. 

They can also be used to skip the upgrade methods on a specific company or to fix the upgrade that went wrong.


# Public Objects
## Upgrade Tag (Codeunit 9999)

 The interface for registering upgrade tags.
 Format of the upgrade tag is:
 [CompanyPrefix]-[TFSID]-[Description]-[YYYYMMDD]
 Example:
 MS-29901-UpdateGLEntriesIntegrationRecordIDs-20161206
 

### HasUpgradeTag (Method) <a name="HasUpgradeTag"></a> 

 Verifies if the upgrade tag exists.
 

#### Syntax
```
procedure HasUpgradeTag(Tag: Code[250]): Boolean
```
#### Parameters
*Tag ([Code[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Tag code to check

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the Tag with given code exist.
### HasUpgradeTag (Method) <a name="HasUpgradeTag"></a> 

 Verifies if the upgrade tag exists.
 

#### Syntax
```
procedure HasUpgradeTag(Tag: Code[250]; TagCompanyName: Code[30]): Boolean
```
#### Parameters
*Tag ([Code[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Tag code to check

*TagCompanyName ([Code[30]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Name of the company to check existance of tag

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the Tag with given code exist.
### SetDatabaseUpgradeTag (Method) <a name="SetDatabaseUpgradeTag"></a> 

 Sets the upgrade tag for database upgrades.
 

#### Syntax
```
procedure SetDatabaseUpgradeTag(NewTag: Code[250])
```
#### Parameters
*NewTag ([Code[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Tag code to save

### SetUpgradeTag (Method) <a name="SetUpgradeTag"></a> 

 Sets the upgrade tag.
 

#### Syntax
```
procedure SetUpgradeTag(NewTag: Code[250])
```
#### Parameters
*NewTag ([Code[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Tag code to save

### SetSkippedUpgrade (Method) <a name="SetSkippedUpgrade"></a> 

 Sets the upgrade tag to skipped.
 

#### Syntax
```
procedure SetSkippedUpgrade(ExistingTag: Code[250]; SkipUpgrade: Boolean)
```
#### Parameters
*ExistingTag ([Code[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Tag code to set the Skipped Upgrade field

*SkipUpgrade ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Sets the Skipped Upgrade field

### SetSkippedUpgrade (Method) <a name="SetSkippedUpgrade"></a> 

 Sets the upgrade tag to skipped.
 

#### Syntax
```
procedure SetSkippedUpgrade(ExistingTag: Code[250]; TagCompanyName: Code[30]; SkipUpgrade: Boolean)
```
#### Parameters
*ExistingTag ([Code[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Tag code to set the Skipped Upgrade field

*TagCompanyName ([Code[30]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Name of the company to check existance of tag

*SkipUpgrade ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Sets the Skipped Upgrade field

### HasUpgradeTagSkipped (Method) <a name="HasUpgradeTagSkipped"></a> 

 Check if the upgrade tag is skipped.
 

#### Syntax
```
procedure HasUpgradeTagSkipped(ExistingTag: Code[250]; TagCompanyName: Code[30]): Boolean
```
#### Parameters
*ExistingTag ([Code[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Tag code to set the Skipped Upgrade field

*TagCompanyName ([Code[30]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Name of the company to check existance of tag

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*


### SetAllUpgradeTags (Method) <a name="SetAllUpgradeTags"></a> 

 This method should be used to set all upgrade tags in a new company.
 The method is called from codeunit 2 - Company Initialize.
 

#### Syntax
```
procedure SetAllUpgradeTags()
```
### SetAllUpgradeTags (Method) <a name="SetAllUpgradeTags"></a> 

 This method should be used to set all upgrade tags in a new company.
 

#### Syntax
```
procedure SetAllUpgradeTags(NewCompanyName: Code[30])
```
#### Parameters
*NewCompanyName ([Code[30]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Name of the company set the upgrade tags

### CopyUpgradeTags (Method) <a name="CopyUpgradeTags"></a> 

 This method should be used to copy all upgrade tags from a company to another company.
 

#### Syntax
```
procedure CopyUpgradeTags(FromCompanyName: Code[30]; ToCompanyName: Code[30])
```
#### Parameters
*FromCompanyName ([Code[30]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Name of the company from which to take the upgrade tags.

*ToCompanyName ([Code[30]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Name of the company to which to copy the upgrade tags.

### GetPerCompanyUpgradeTags (Method) <a name="GetPerCompanyUpgradeTags"></a> 

 With this method you get all the upgrade tags by company in a list.
 

#### Syntax
```
procedure GetPerCompanyUpgradeTags(var PerCompanyUpgradeTags: List of [Code[250]])
```
#### Parameters
*PerCompanyUpgradeTags ([List of [Code[250]]]())* 


 List of upgrade tags that should be inserted if they do not exist.
 

### GetPerDatabaseUpgradeTags (Method) <a name="GetPerDatabaseUpgradeTags"></a> 

 With this method you get all the upgrade tags by database in a list.
 

#### Syntax
```
procedure GetPerDatabaseUpgradeTags(var PerDatabaseUpgradeTags: List of [Code[250]])
```
#### Parameters
*PerDatabaseUpgradeTags ([List of [Code[250]]]())* 



### BackupUpgradeTags (Method) <a name="BackupUpgradeTags"></a> 

 This function is used for cloud migration to backup upgrade tags before cloud migration is triggered.
 Using the function if cloud migration is not enabled will throw an error.
 

#### Syntax
```
procedure BackupUpgradeTags(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

ID of the backup, used in [RestoreUpgradeTagsFromBackup](#RestoreUpgradeTagsFromBackup) method.
### RestoreUpgradeTagsFromBackup (Method) <a name="RestoreUpgradeTagsFromBackup"></a> 

 This function is used to restore Upgrade tags after cloud migration.
 Using the function if cloud migration is not enabled will throw an error.
 

#### Syntax
```
procedure RestoreUpgradeTagsFromBackup(BackupId: Integer; RestoreMissingTagsOnly: Boolean)
```
#### Parameters
*BackupId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

ID of the backup, created by [BackupUpgradeTags](#BackupUpgradeTags) method.

*RestoreMissingTagsOnly ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

This parameter indicates if the function should restore the entire table or only insert back the missing upgrade tags.

### OnGetPerCompanyUpgradeTags (Event) <a name="OnGetPerCompanyUpgradeTags"></a> 

 Use this event if you want to add upgrade tag for PerCompany upgrade method for a new company.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnGetPerCompanyUpgradeTags(var PerCompanyUpgradeTags: List of [Code[250]])
```
#### Parameters
*PerCompanyUpgradeTags ([List of [Code[250]]]())* 


 List of upgrade tags that should be inserted if they do not exist.
 

### OnGetPerDatabaseUpgradeTags (Event) <a name="OnGetPerDatabaseUpgradeTags"></a> 

 Use this event if you want to add upgrade tag for PerDatabase upgrade method for a new company.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnGetPerDatabaseUpgradeTags(var PerDatabaseUpgradeTags: List of [Code[250]])
```
#### Parameters
*PerDatabaseUpgradeTags ([List of [Code[250]]]())* 


 List of upgrade tags that should be inserted if they do not exist.
 

### OnSetAllUpgradeTags (Event) <a name="OnSetAllUpgradeTags"></a> 

 Use this event if you want to skip or run logic when we register all tags for a company.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnSetAllUpgradeTags(NewCompanyName: Text; var SkipSetAllUpgradeTags: Boolean)
```
#### Parameters
*NewCompanyName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Name of the company to set the upgrade tags.

*SkipSetAllUpgradeTags ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Specifies if the setting of the tags for the company should be skipped.

