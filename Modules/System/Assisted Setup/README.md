# Introduction
This module contains all pages that are used by assisted setup guides in Business Central. Assisted setup guides provide step-by-step guidance that helps simplify the process of setting up complex features. 

# What has been done
We have combined the assisted setup capabilities that already existed in Business Central in this module. If your extension provides setup assistance through a guide, you can add that guide to Assisted Setup for easy discoverability.  
 
The Assisted Setup module provides capabilities for:
 - Adding an assisted setup guide for a given extension, page ID, an optional video link that explains the feature, and a help link where the user can read more about it. 
 - Adding a translation for the name of the setup record. This is helpful when the extension is available in multiple languages. 
 - Checking whether a user has already completed the steps in an assisted setup guide. 
 - Completing an assisted setup guide, typically from the guide itself when the user clicks Finish. 
 - Running an assisted setup guide page that takes the user through the various steps to set up an extension. 

# Usage example
The Base Application adds quite a few assisted setup guides by subscribing to the OnRegister event. In the following example, the Data Migration Wizard is being added to the Assisted Setup through the API exposed for the module. See the details for codeunit 1814 "Assisted Setup Subscribers", which shows that the Data Migration Wizard, is added along with a video and a link to more information. Also, the English (United States) translation for the name is added. 
```
        CurrentGlobalLanguage := GLOBALLANGUAGE; 
        // Getting Started 
        AssistedSetup.Add(GetAppId(), PAGE::"Data Migration Wizard", DataMigrationTxt, AssistedSetupGroup::GettingStarted, VideoImportbusinessdataTxt, HelpImportbusinessdataTxt); 
        GLOBALLANGUAGE(1033); 
        AssistedSetup.AddTranslation(GetAppId(), PAGE::"Data Migration Wizard", 1033, DataMigrationTxt); 
        GLOBALLANGUAGE(CurrentGlobalLanguage); 
```

# Public Objects
## Assisted Setup (Codeunit 3725)
Manage assisted setup guides by allowing the addition of new guides to the list, and updating whether a guide has been completed.

### Add (Method) <a name="Add"></a> 
Adds an assisted setup record from a given extension so that it can be shown in the list.

#### Syntax
```
procedure Add(ExtensionID: Guid; PageID: Integer; AssistantName: Text; GroupName: Enum "Assisted Setup Group")
```
#### Parameters
*ExtensionID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The app ID of the extension to which the setup belongs.

*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page to open when the user clicks the setup.

*AssistantName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name as shown for the setup.

*GroupName ([Enum "Assisted Setup Group"]())* 

The assisted setup group enum that this belongs to.

### Add (Method) <a name="Add"></a> 
Adds an assisted setup record from a given extension so that it can be shown in the list.

#### Syntax
```
procedure Add(ExtensionID: Guid; PageID: Integer; AssistantName: Text; GroupName: Enum "Assisted Setup Group"; VideoLink: Text[250]; HelpLink: Text[250])
```
#### Parameters
*ExtensionID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The app ID of the extension to which the setup belongs.

*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page to open when the user clicks the setup.

*AssistantName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name as shown for the setup.

*GroupName ([Enum "Assisted Setup Group"]())* 

The assisted setup group enum that this belongs to.

*VideoLink ([Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The URL of the video that explains the purpose and use of this setup.

*HelpLink ([Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The help url that explains the purpose and usage of this setup.

### Add (Method) <a name="Add"></a> 
Adds an assisted setup record from a given extension so that it can be shown in the list.

#### Syntax
```
procedure Add(ExtensionID: Guid; PageID: Integer; AssistantName: Text; GroupName: Enum "Assisted Setup Group"; VideoLink: Text[250]; VideoCategory: Enum "Video Category"; HelpLink: Text[250])
```
#### Parameters
*ExtensionID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The app ID of the extension to which the setup belongs.

*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page to open when the user clicks the setup.

*AssistantName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name as shown for the setup.

*GroupName ([Enum "Assisted Setup Group"]())* 

The assisted setup group enum that this belongs to.

*VideoLink ([Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The URL of the video that explains the purpose and use of this setup.

*VideoCategory ([Enum "Video Category"]())* 

The category of the video for this setup.

*HelpLink ([Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The help url that explains the purpose and usage of this setup.

### Add (Method) <a name="Add"></a> 
Adds an assisted setup record from a given extension so that it can be shown in the list.

#### Syntax
```
procedure Add(ExtensionID: Guid; PageID: Integer; AssistantName: Text; GroupName: Enum "Assisted Setup Group"; VideoLink: Text[250]; VideoCategory: Enum "Video Category"; HelpLink: Text[250]; Description: Text[1024])
```
#### Parameters
*ExtensionID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The app ID of the extension to which the setup belongs.

*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page to open when the user clicks the setup.

*AssistantName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name as shown for the setup.

*GroupName ([Enum "Assisted Setup Group"]())* 

The assisted setup group enum that this belongs to.

*VideoLink ([Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The URL of the video that explains the purpose and use of this setup.

*VideoCategory ([Enum "Video Category"]())* 

The category of the video for this setup.

*HelpLink ([Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The help url that explains the purpose and usage of this setup.

*Description ([Text[1024]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The description of this setup.

### AddTranslation (Method) <a name="AddTranslation"></a> 
Adds the translation for the name of the setup.

#### Syntax
```
[Obsolete('ExtensionID is not required. Please use the function with the same name without this parameter.', '16.0')]
procedure AddTranslation(ExtensionID: Guid; PageID: Integer; LanguageID: Integer; TranslatedName: Text)
```
#### Parameters
*ExtensionID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The app ID of the extension to which the setup belongs.

*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page to open when the user clicks the setup.

*LanguageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The language ID for which the translation is made.

*TranslatedName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The translated text of the name.

### AddTranslation (Method) <a name="AddTranslation"></a> 
Adds the translation for the name of the setup.

#### Syntax
```
procedure AddTranslation(PageID: Integer; LanguageID: Integer; TranslatedName: Text)
```
#### Parameters
*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page to open when the user clicks the setup.

*LanguageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The language ID for which the translation is made.

*TranslatedName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The translated text of the name.

### IsComplete (Method) <a name="IsComplete"></a> 
Checks whether a user has already completed the setup.

#### Syntax
```
[Obsolete('ExtensionID is not required. Please use the function with the same name without this parameter.', '16.0')]
procedure IsComplete(ExtensionID: Guid; PageID: Integer): Boolean
```
#### Parameters
*ExtensionID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The app ID of the extension to which the setup belongs.

*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page to open when the user clicks the setup.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

Returns true if the given setup guide has been completed by the user, otherwise false.
### IsComplete (Method) <a name="IsComplete"></a> 
Checks whether a user has already completed the setup.

#### Syntax
```
procedure IsComplete(PageID: Integer): Boolean
```
#### Parameters
*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page to open when the user clicks the setup.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

Returns true if the given setup guide has been completed by the user, otherwise false.
### Exists (Method) <a name="Exists"></a> 
Checks whether an assisted setup guide exists.

#### Syntax
```
[Obsolete('ExtensionID is not required. Please use the function with the same name without this parameter.', '16.0')]
procedure Exists(ExtensionID: Guid; PageID: Integer): Boolean
```
#### Parameters
*ExtensionID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The app ID of the extension to which the setup belongs.

*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page to open when the user clicks the setup.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if an assisted setup guide for provided extension and page IDs exists; false otherwise.
### Exists (Method) <a name="Exists"></a> 
Checks whether an assisted setup guide exists.

#### Syntax
```
procedure Exists(PageID: Integer): Boolean
```
#### Parameters
*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page to open when the user clicks the setup.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if an assisted setup guide for provided extension and page IDs exists; false otherwise.
### ExistsAndIsNotComplete (Method) <a name="ExistsAndIsNotComplete"></a> 
Checks whether as assisted setup guide exists but has not been completed.

#### Syntax
```
[Obsolete('ExtensionID is not required. Please use the function with the same name without this parameter.', '16.0')]
procedure ExistsAndIsNotComplete(ExtensionID: Guid; PageID: Integer): Boolean
```
#### Parameters
*ExtensionID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The app ID of the extension to which the setup belongs.

*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page to open when the user clicks the setup.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if it exists and is incomplete, false otherwise.
### ExistsAndIsNotComplete (Method) <a name="ExistsAndIsNotComplete"></a> 
Checks whether as assisted setup guide exists but has not been completed.

#### Syntax
```
procedure ExistsAndIsNotComplete(PageID: Integer): Boolean
```
#### Parameters
*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page to open when the user clicks the setup.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if it exists and is incomplete, false otherwise.
### Complete (Method) <a name="Complete"></a> 
Sets the status of the assisted setup to Complete.

This is typically called from inside the assisted setup guide when the setup is finished.

#### Syntax
```
[Obsolete('ExtensionID is not required. Please use the function with the same name without this parameter.', '16.0')]
procedure Complete(ExtensionID: Guid; PageID: Integer)
```
#### Parameters
*ExtensionID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The app ID of the extension to which the setup belongs.

*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page to open when the user clicks the setup.

### Complete (Method) <a name="Complete"></a> 
Sets the status of the assisted setup to Complete.

This is typically called from inside the assisted setup guide when the setup is finished.

#### Syntax
```
procedure Complete(PageID: Integer)
```
#### Parameters
*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page to open when the user clicks the setup.

### Reset (Method) <a name="Reset"></a> 
Resets the status of the assisted setup guide so that it does not appear to have been completed.

#### Syntax
```
procedure Reset(PageID: Integer)
```
#### Parameters
*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page to open when the user clicks the setup.

### Run (Method) <a name="Run"></a> 
Issues the call to execute the setup.

#### Syntax
```
[Obsolete('ExtensionID is not required. Please use the function with the same name without this parameter.', '16.0')]
procedure Run(ExtensionID: Guid; PageID: Integer)
```
#### Parameters
*ExtensionID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The app ID of the extension to which the setup belongs.

*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page to open when the user clicks the setup.

### Run (Method) <a name="Run"></a> 
Issues the call to start the setup.

If the page does not exist the user can choose whether to delete the page record.

#### Syntax
```
procedure Run(PageID: Integer)
```
#### Parameters
*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page to open when the user clicks the setup.

### Open (Method) <a name="Open"></a> 
Opens the Assisted Setup page with the setup guides in it.

#### Syntax
```
procedure Open()
```
### Open (Method) <a name="Open"></a> 
Opens the Assisted Setup page with the setup guides filtered on a selected group of guides.

#### Syntax
```
procedure Open(AssistedSetupGroup: Enum "Assisted Setup Group")
```
#### Parameters
*AssistedSetupGroup ([Enum "Assisted Setup Group"]())* 

The group of guides to display on the Assisted Setup page.

### Remove (Method) <a name="Remove"></a> 
Removes an Assisted Setup so it will no longer be shown in the list.

The OnRegister subscriber which adds this PageID needs to be removed first.

#### Syntax
```
procedure Remove(PageID: Integer)
```
#### Parameters
*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page to be removed.

### OnRegister (Event) <a name="OnRegister"></a> 
Notifies the user that the list of assisted setup guides is being gathered, and that new guides might be added.

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnRegister()
```
### OnReRunOfCompletedSetup (Event) <a name="OnReRunOfCompletedSetup"></a> 
Notifies the user that a setup that was previously completed is being run again.

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnReRunOfCompletedSetup(ExtensionID: Guid; PageID: Integer; var Handled: Boolean)
```
#### Parameters
*ExtensionID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The app ID of the extension to which the setup belongs.

*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page to open when the user clicks the setup.

*Handled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

The flag which if set, would stop executing the run of the assisted setup guide.

### OnAfterRun (Event) <a name="OnAfterRun"></a> 
Notifies that the run of the assisted setup has finished.

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnAfterRun(ExtensionID: Guid; PageID: Integer)
```
#### Parameters
*ExtensionID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The app ID of the extension to which the setup belongs.

*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page to open when the user clicks the setup.

### OnBeforeOpenRoleBasedSetupExperience (Event) <a name="OnBeforeOpenRoleBasedSetupExperience"></a> 
Notifies that the Open Role Based Setup Experience has been invoked.

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnBeforeOpenRoleBasedSetupExperience(var PageID: Integer; var Handled: Boolean)
```
#### Parameters
*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The Page ID of the page been invoked.

*Handled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

The flag which if set, would stop executing the OpenRoleBasedSetupExperience of the assisted setup guide.


## Assisted Setup (Page 1801)
This page shows all registered assisted setup guides.


## Assisted Setup Group (Enum 1815)
The group to which the setup belongs. Please extend this enum to add your own group to classify the setups being added by your extension.

### Uncategorized (value: 0)


 A default group, specifying that the assisted setup is not categorized.
 

