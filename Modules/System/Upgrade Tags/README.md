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
### SetUpgradeTag (Method) <a name="SetUpgradeTag"></a> 

 Sets the upgrade tag.
 

#### Syntax
```
procedure SetUpgradeTag(NewTag: Code[250])
```
#### Parameters
*NewTag ([Code[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Tag code to save

### SetAllUpgradeTags (Method) <a name="SetAllUpgradeTags"></a> 

 This method should be used to set all upgrade tags in a new company. 
 The method is called from codeunit 2 - Company Initialize.
 

#### Syntax
```
procedure SetAllUpgradeTags()
```
### SetAllUpgradeTags (Method) <a name="SetAllUpgradeTags"></a> 

 This method should be used to set all upgrade tags in a new company. 
 The method is called from Copy Company Report
 

#### Syntax
```
procedure SetAllUpgradeTags(NewCompanyName: Code[30])
```
#### Parameters
*NewCompanyName ([Code[30]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

Name of the company set the upgrade tags

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
 

