# Public Objects
## [Obsolete] Assisted Setup (Codeunit 3725)
Manage assisted setup guides by allowing the addition of new guides to the list, and updating whether a guide has been completed.

### Add (Method) <a name="Add"></a> 
Adds an assisted setup record from a given extension so that it can be shown in the list.

#### Syntax
```
[Obsolete('Replaced by Insert in the Guided Experience codeunit.', '18.0')]
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
[Obsolete('Replaced by Insert in the Guided Experience codeunit.', '18.0')]
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
[Obsolete('Replaced by Insert in the Guided Experience codeunit.', '18.0')]
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
[Obsolete('Replaced by Insert in the Guided Experience codeunit.', '18.0')]
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
[Obsolete('Replaced by AddTranslation(GuidedExperienceType, ObjectType, ObjectID, LanguageID, TranslatedName) in the Guided Experience codeunit.', '18.0')]
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
[Obsolete('Replaced by IsAssistedSetupComplete(ObjectType, ObjectID) in the Guided Experience codeunit.', '18.0')]
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
[Obsolete('Replaced by Exists(GuidedExperienceType, ObjectType, ObjectID) in the Guided Experience codeunit.', '18.0')]
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
[Obsolete('Replaced by AssistedSetupExistsAndIsNotComplete(ObjectType, ObjectID) in the Guided Experience codeunit.', '18.0')]
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
[Obsolete('Replaced by CompleteAssistedSetup(ObjectType, ObjectID) in the Guided Experience codeunit.', '18.0')]
procedure Complete(PageID: Integer)
```
#### Parameters
*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page to open when the user clicks the setup.

### Reset (Method) <a name="Reset"></a> 
Resets the status of the assisted setup guide so that it does not appear to have been completed.

#### Syntax
```
[Obsolete('Replaced by ResetAssistedSetup(ObjectType, ObjectID) in the Guided Experience codeunit.', '18.0')]
procedure Reset(PageID: Integer)
```
#### Parameters
*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page to open when the user clicks the setup.

### Run (Method) <a name="Run"></a> 
Issues the call to start the setup.

If the page does not exist the user can choose whether to delete the page record.

#### Syntax
```
[Obsolete('Replaced by RunAssistedSetup(GuidedExperienceType, ObjectType, ObjectID) in the Guided Experience codeunit.', '18.0')]
procedure Run(PageID: Integer)
```
#### Parameters
*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page to open when the user clicks the setup.

### Open (Method) <a name="Open"></a> 
Opens the Assisted Setup page with the setup guides in it.

#### Syntax
```
[Obsolete('Replaced by OpenAssistedSetup() in the Guided Experience codeunit.', '18.0')]
procedure Open()
```
### Open (Method) <a name="Open"></a> 
Opens the Assisted Setup page with the setup guides filtered on a selected group of guides.

#### Syntax
```
[Obsolete('Replaced by OpenAssistedSetup(AssistedSetupGroup) in the Guided Experience codeunit.', '18.0')]
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
[Obsolete('Replaced by Remove(GuidedExperienceType, ObjectType, ObjectID) in the Guided Experience codeunit.', '18.0')]
procedure Remove(PageID: Integer)
```
#### Parameters
*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page to be removed.

### OnRegister (Event) <a name="OnRegister"></a> 
Notifies the user that the list of assisted setup guides is being gathered, and that new guides might be added.

#### Syntax
```
[Obsolete('Replaced by OnAssistedSetupRegister() in the Guided Experience codeunit.', '18.0')]
[IntegrationEvent(false, false)]
internal procedure OnRegister()
```
### OnReRunOfCompletedSetup (Event) <a name="OnReRunOfCompletedSetup"></a> 
Notifies the user that a setup that was previously completed is being run again.

#### Syntax
```
[Obsolete('Replaced by OnReRunOfCompletedAssistedSetup(ExtensionID, ObjectType, ObjectID, Handled) in the Guided Experience codeunit.', '18.0')]
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
[Obsolete('Replaced by OnAfterRunAssistedSetup(ExtensionID, ObjectType, ObjectID) in the Guided Experience codeunit.', '18.0')]
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
[Obsolete('Replaced by OnBeforeOpenRoleBasedAssistedSetupExperience(ObjectType, ObjectID, Handled) in the Guided Experience codeunit.', '18.0')]
[IntegrationEvent(false, false)]
internal procedure OnBeforeOpenRoleBasedSetupExperience(var PageID: Integer; var Handled: Boolean)
```
#### Parameters
*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The Page ID of the page been invoked.

*Handled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

The flag which if set, would stop executing the OpenRoleBasedSetupExperience of the assisted setup guide.


## Checklist (Codeunit 1992)

 Manage the checklist presented to users by inserting and deleting checklist items and controling the visibility of the checklist.
 

### Insert (Method) <a name="Insert"></a> 

 Inserts a new checklist item.
 

#### Syntax
```
procedure Insert(GuidedExperienceType: Enum "Guided Experience Type"; ObjectTypeToRun: ObjectType; ObjectIDToRun: Integer; OrderID: Integer; var TempAllProfile: Record "All Profile" temporary; ShouldEveryoneComplete: Boolean)
```
#### Parameters
*GuidedExperienceType ([Enum "Guided Experience Type"]())* 

The type of guided experience item that the checklist item references.

*ObjectTypeToRun ([ObjectType]())* 

The object type run by the guided experience item that the checklist item references.

*ObjectIDToRun ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The object ID run by the guided experience item that the checklist item references.

*OrderID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The index at which this checklist item should appear in the list. Please be aware that if other extensions also insert checklist items, then this ID might not match the index in the list.

*TempAllProfile ([Record "All Profile" temporary]())* 

The roles that this checklist item should be displayed for.

*ShouldEveryoneComplete ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Boolean value that controls whether everyone should complete this checklist item. If false, the checklist item will be marked as completed for everyone, even if only one person completes it.

### Insert (Method) <a name="Insert"></a> 

 Inserts a new checklist item.
 

#### Syntax
```
procedure Insert(GuidedExperienceType: Enum "Guided Experience Type"; ObjectTypeToRun: ObjectType; ObjectIDToRun: Integer; OrderID: Integer; var TempUser: Record User temporary)
```
#### Parameters
*GuidedExperienceType ([Enum "Guided Experience Type"]())* 

The type of guided experience item that the checklist item references.

*ObjectTypeToRun ([ObjectType]())* 

The object type run by the guided experience item that the checklist item references.

*ObjectIDToRun ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The object ID run by the guided experience item that the checklist item references.

*OrderID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The index at which this checklist item should appear in the list. Please be aware that if other extensions also insert checklist items, then this ID might not match the index in the list.

*TempUser ([Record User temporary]())* 

The users that this checklist item should be displayed for.

### Insert (Method) <a name="Insert"></a> 

 Inserts a new checklist item.
 

#### Syntax
```
procedure Insert(GuidedExperienceType: Enum "Guided Experience Type"; Link: Text[250]; OrderID: Integer; var TempAllProfile: Record "All Profile" temporary; ShouldEveryoneComplete: Boolean)
```
#### Parameters
*GuidedExperienceType ([Enum "Guided Experience Type"]())* 

The type of guided experience item that the checklist item references.

*Link ([Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The URL that is open by the guided experience item that the checklist item references.

*OrderID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The index at which this checklist item should appear in the list. Please be aware that if other extensions also insert checklist items, then this ID might not match the index in the list.

*TempAllProfile ([Record "All Profile" temporary]())* 

The roles that this checklist item should be displayed for.

*ShouldEveryoneComplete ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Boolean value that controls whether everyone should complete this checklist item. If false, the checklist item will be marked as completed for everyone, even if only one person completes it.

### Insert (Method) <a name="Insert"></a> 

 Inserts a new checklist item.
 

#### Syntax
```
procedure Insert(GuidedExperienceType: Enum "Guided Experience Type"; Link: Text[250]; OrderID: Integer; var TempUser: Record User temporary)
```
#### Parameters
*GuidedExperienceType ([Enum "Guided Experience Type"]())* 

The type of guided experience item that the checklist item references.

*Link ([Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The URL that is open by the guided experience item that the checklist item references.

*OrderID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The index at which this checklist item should appear in the list. Please be aware that if other extensions also insert checklist items, then this ID might not match the index in the list.

*TempUser ([Record User temporary]())* 

The users that this checklist item should be displayed for.

### Insert (Method) <a name="Insert"></a> 

 Inserts a new checklist item for a spotlight tour.
 

#### Syntax
```
procedure Insert(PageID: Integer; SpotlightTourType: Enum "Spotlight Tour Type"; OrderID: Integer; var TempAllProfile: Record "All Profile" temporary; ShouldEveryoneComplete: Boolean)
```
#### Parameters
*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page that the spotlight tour will run on.

*SpotlightTourType ([Enum "Spotlight Tour Type"]())* 

The type of spotlight tour.

*OrderID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The index at which this checklist item should appear in the list. Please be aware that if other extensions also insert checklist items, then this ID might not match the index in the list.

*TempAllProfile ([Record "All Profile" temporary]())* 

The roles that this checklist item should be displayed for.

*ShouldEveryoneComplete ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Boolean value that controls whether everyone should complete this checklist item. If false, the checklist item will be marked as completed for everyone, even if only one person completes it.

### Insert (Method) <a name="Insert"></a> 

 Inserts a new checklist item for a spotlight tour.
 

#### Syntax
```
procedure Insert(PageID: Integer; SpotlightTourType: Enum "Spotlight Tour Type"; OrderID: Integer; var TempUser: Record User temporary)
```
#### Parameters
*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page that the spotlight tour will run on.

*SpotlightTourType ([Enum "Spotlight Tour Type"]())* 

The type of spotlight tour.

*OrderID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The index at which this checklist item should appear in the list. Please be aware that if other extensions also insert checklist items, then this ID might not match the index in the list.

*TempUser ([Record User temporary]())* 



### Delete (Method) <a name="Delete"></a> 

 Deletes a checklist item.
 

#### Syntax
```
procedure Delete(GuidedExperienceType: Enum "Guided Experience Type"; ObjectTypeToRun: ObjectType; ObjectID: Integer)
```
#### Parameters
*GuidedExperienceType ([Enum "Guided Experience Type"]())* 

The type of guided experience item that the checklist item references.

*ObjectTypeToRun ([ObjectType]())* 

The object type run by the guided experience item that the checklist item references.

*ObjectID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 



### Delete (Method) <a name="Delete"></a> 

 Deletes a checklist item.
 

#### Syntax
```
procedure Delete(GuidedExperienceType: Enum "Guided Experience Type"; Link: Text[250])
```
#### Parameters
*GuidedExperienceType ([Enum "Guided Experience Type"]())* 

The type of guided experience item that the checklist item references.

*Link ([Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The URL that is open by the guided experience item that the checklist item references.

### Delete (Method) <a name="Delete"></a> 

 Deletes a spotlight tour checklist item.
 

#### Syntax
```
procedure Delete(PageID: Integer; SpotlightTourType: Enum "Spotlight Tour Type")
```
#### Parameters
*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page that the spotlight tour runs on.

*SpotlightTourType ([Enum "Spotlight Tour Type"]())* 

The type of spotlight tour.

### ShouldInitializeChecklist (Method) <a name="ShouldInitializeChecklist"></a> 

 Checks whether the checklist should be initialized.
 

#### Syntax
```
[Obsolete('Replaced by ShouldInitializeChecklist(ShouldSkipForEvaluationCompany).', '19.0')]
procedure ShouldInitializeChecklist(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the checklist should be initialized and false otherwise.
### ShouldInitializeChecklist (Method) <a name="ShouldInitializeChecklist"></a> 

 Checks whether the checklist should be initialized for the current company.
 

#### Syntax
```
procedure ShouldInitializeChecklist(ShouldSkipForEvaluationCompany: Boolean): Boolean
```
#### Parameters
*ShouldSkipForEvaluationCompany ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

If true, then the function will always return false for evaluation companies.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the checklist should be initialized and false otherwise.
### MarkChecklistSetupAsDone (Method) <a name="MarkChecklistSetupAsDone"></a> 

 Marks the checklist setup as done.
 

#### Syntax
```
procedure MarkChecklistSetupAsDone()
```
### InitializeGuidedExperienceItems (Method) <a name="InitializeGuidedExperienceItems"></a> 

 Initializes the guided experience items.
 

#### Syntax
```
procedure InitializeGuidedExperienceItems()
```
### UpdateUserName (Method) <a name="UpdateUserName"></a> 

 Updates the user name for checklist records that have it as a primary key.
 

#### Syntax
```
procedure UpdateUserName(var RecRef: RecordRef; Company: Text[30]; UserName: Text[50]; TableID: Integer)
```
#### Parameters
*RecRef ([RecordRef](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/recordref/recordref-data-type))* 

The recordref that poins to the record that is to be modified.

*Company ([Text[30]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The company in which the table is to be modified.

*UserName ([Text[50]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The new user name.

*TableID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The table for which the user name is to be modified.

### IsChecklistVisible (Method) <a name="IsChecklistVisible"></a> 

 Checks whether the checklist is visible for the current user on the profile that the user is currently on.
 

#### Syntax
```
procedure IsChecklistVisible(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the checklist is visible and false otherwise.
### SetChecklistVisibility (Method) <a name="SetChecklistVisibility"></a> 

 Sets the checklist visibility for the current user and the profile that the user is currently using.
 

#### Syntax
```
procedure SetChecklistVisibility(Visible: Boolean)
```
#### Parameters
*Visible ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

True if the checklist should be visible and false otherwise.

### OnChecklistLoading (Event) <a name="OnChecklistLoading"></a> 

 Event that is triggered when the checklist is being loaded.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnChecklistLoading()
```

## Guided Experience (Codeunit 1990)

 Manage the guided experience items that users can access.
 

### InsertManualSetup (Method) <a name="InsertManualSetup"></a> 
Inserts a manual setup page.

#### Syntax
```
procedure InsertManualSetup(Title: Text[2048]; ShortTitle: Text[50]; Description: Text[1024]; ExpectedDuration: Integer; ObjectTypeToRun: ObjectType; ObjectIDToRun: Integer; ManualSetupCategory: Enum "Manual Setup Category"; Keywords: Text[250])
```
#### Parameters
*Title ([Text[2048]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The title of the manual setup.

*ShortTitle ([Text[50]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A short title used for the checklist.

*Description ([Text[1024]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The description of the manual setup.

*ExpectedDuration ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

How many minutes the setup is expected to take.

*ObjectTypeToRun ([ObjectType]())* 

The type of the object to be run as part of the setup.

*ObjectIDToRun ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the object to be run as part of the setup.

*ManualSetupCategory ([Enum "Manual Setup Category"]())* 

The category that this manual setup belongs to.

*Keywords ([Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The keywords related to the manual setup.

### InsertAssistedSetup (Method) <a name="InsertAssistedSetup"></a> 
Inserts an assisted setup page.

#### Syntax
```
procedure InsertAssistedSetup(Title: Text[2048]; ShortTitle: Text[50]; Description: Text[1024]; ExpectedDuration: Integer; ObjectTypeToRun: ObjectType; ObjectIDToRun: Integer; AssistedSetupGroup: Enum "Assisted Setup Group"; VideoUrl: Text[250]; VideoCategory: Enum "Video Category"; HelpUrl: Text[250])
```
#### Parameters
*Title ([Text[2048]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The title of the assisted setup.

*ShortTitle ([Text[50]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A short title used for the checklist.

*Description ([Text[1024]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The description of the assisted setup.

*ExpectedDuration ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

How many minutes the setup is expected to take.

*ObjectTypeToRun ([ObjectType]())* 

The type of the object to be run as part of the setup.

*ObjectIDToRun ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the object to be run as part of the setup.

*AssistedSetupGroup ([Enum "Assisted Setup Group"]())* 

The assisted setup group enum that this belongs to.

*VideoUrl ([Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The URL of the video that explains the purpose and use of this setup.

*VideoCategory ([Enum "Video Category"]())* 

The category of the video for this setup.

*HelpUrl ([Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 



### InsertLearnPage (Method) <a name="InsertLearnPage"></a> 
Inserts a learn page.

#### Syntax
```
[Obsolete('Use InsertManualSetup instead.', '19.0')]
procedure InsertLearnPage(Title: Text[2048]; ShortTitle: Text[50]; Description: Text[1024]; ExpectedDuration: Integer; PageID: Integer)
```
#### Parameters
*Title ([Text[2048]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The title of the learn page.

*ShortTitle ([Text[50]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A short title used for the checklist.

*Description ([Text[1024]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The description of the learn page.

*ExpectedDuration ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

How many minutes the learn page would take to read.

*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the learn page.

### InsertLearnLink (Method) <a name="InsertLearnLink"></a> 
Inserts a learn link.

#### Syntax
```
procedure InsertLearnLink(Title: Text[2048]; ShortTitle: Text[50]; Description: Text[1024]; ExpectedDuration: Integer; Link: Text[250])
```
#### Parameters
*Title ([Text[2048]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The title of the learn link.

*ShortTitle ([Text[50]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A short title used for the checklist.

*Description ([Text[1024]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The description of the learn link.

*ExpectedDuration ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

How many minutes the user should expect to spend using the link.

*Link ([Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The learn link.

### InsertTour (Method) <a name="InsertTour"></a> 
Inserts a tour for a page.

#### Syntax
```
procedure InsertTour(Title: Text[2048]; ShortTitle: Text[50]; Description: Text[1024]; ExpectedDuration: Integer; PageID: Integer)
```
#### Parameters
*Title ([Text[2048]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The title of the tour.

*ShortTitle ([Text[50]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A short title used for the checklist.

*Description ([Text[1024]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The description of the tour.

*ExpectedDuration ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

How many minutes the user should expect to spend taking the tour.

*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page that the tour is run on.

### InsertSpotlightTour (Method) <a name="InsertSpotlightTour"></a> 
Inserts a spotlight tour for a page.

#### Syntax
```
procedure InsertSpotlightTour(Title: Text[2048]; ShortTitle: Text[50]; Description: Text[1024]; ExpectedDuration: Integer; PageID: Integer; SpotlighTourType: Enum "Spotlight Tour Type"; SpotlightTourTexts: Dictionary of [Enum "Spotlight Tour Text", Text])
```
#### Parameters
*Title ([Text[2048]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The title of the manual setup.

*ShortTitle ([Text[50]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A short title used for the checklist.

*Description ([Text[1024]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The description of the manual setup.

*ExpectedDuration ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

How many minutes the tour is expected to take.

*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page that the spotlight tour will be run on.

*SpotlighTourType ([Enum "Spotlight Tour Type"]())* 



*SpotlightTourTexts ([Dictionary of [Enum "Spotlight Tour Text", Text]]())* 

The texts that will be displayed during the spotlight tour.

### InsertApplicationFeature (Method) <a name="InsertApplicationFeature"></a> 
Inserts a guided experience item for an application feature.

#### Syntax
```
procedure InsertApplicationFeature(Title: Text[2048]; ShortTitle: Text[50]; Description: Text[1024]; ExpectedDuration: Integer; ObjectTypeToRun: ObjectType; ObjectIDToRun: Integer)
```
#### Parameters
*Title ([Text[2048]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The title of the application feature.

*ShortTitle ([Text[50]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A short title used for the checklist.

*Description ([Text[1024]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The description of the application feature.

*ExpectedDuration ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

How many minutes the user should expect to spend .

*ObjectTypeToRun ([ObjectType]())* 

The object type to run for the application feature.

*ObjectIDToRun ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The object ID to run for the application feature.

### InsertVideo (Method) <a name="InsertVideo"></a> 
Inserts a guided experience item for a video.

#### Syntax
```
procedure InsertVideo(Title: Text[2048]; ShortTitle: Text[50]; Description: Text[1024]; ExpectedDuration: Integer; VideoURL: Text[250]; VideoCategory: Enum "Video Category")
```
#### Parameters
*Title ([Text[2048]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The title of the video.

*ShortTitle ([Text[50]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A short title used for the checklist.

*Description ([Text[1024]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The description of the video.

*ExpectedDuration ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The duration of the video in minutes.

*VideoURL ([Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 



*VideoCategory ([Enum "Video Category"]())* 

The category of the video.

### OpenManualSetupPage (Method) <a name="OpenManualSetupPage"></a> 
Opens the Manual Setup page containing the setup guides.

#### Syntax
```
procedure OpenManualSetupPage()
```
### OpenManualSetupPage (Method) <a name="OpenManualSetupPage"></a> 
Opens the Manual Setup page with the setup guides filtered on a selected group of guides.

#### Syntax
```
procedure OpenManualSetupPage(ManualSetupCategory: Enum "Manual Setup Category")
```
#### Parameters
*ManualSetupCategory ([Enum "Manual Setup Category"]())* 

The group which the view should be filtered to.

### AddTranslationForSetupObjectTitle (Method) <a name="AddTranslationForSetupObjectTitle"></a> 
Adds the translation for the title of the setup object.

#### Syntax
```
procedure AddTranslationForSetupObjectTitle(GuidedExperienceType: Enum "Guided Experience Type"; ObjectType: ObjectType; ObjectID: Integer; LanguageID: Integer; Translation: Text)
```
#### Parameters
*GuidedExperienceType ([Enum "Guided Experience Type"]())* 

The type of setup object.

*ObjectType ([ObjectType]())* 

The object type that identifies the guided experience item.

*ObjectID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The object ID that identifies the guided experience item.

*LanguageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The language ID for which the translation is made.

*Translation ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The translated text of the title.

### AddTranslationForSetupObjectDescription (Method) <a name="AddTranslationForSetupObjectDescription"></a> 
Adds the translation for the description of the setup object.

#### Syntax
```
procedure AddTranslationForSetupObjectDescription(GuidedExperienceType: Enum "Guided Experience Type"; ObjectType: ObjectType; ObjectID: Integer; LanguageID: Integer; Translation: Text)
```
#### Parameters
*GuidedExperienceType ([Enum "Guided Experience Type"]())* 

The type of setup object.

*ObjectType ([ObjectType]())* 

The object type that identifies the guided experience item.

*ObjectID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The object ID that identifies the guided experience item.

*LanguageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The language ID for which the translation is made.

*Translation ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The translated text of the description.

### IsAssistedSetupComplete (Method) <a name="IsAssistedSetupComplete"></a> 
Checks whether a user has completed the setup corresponding to the object type and ID.

#### Syntax
```
procedure IsAssistedSetupComplete(ObjectType: ObjectType; ObjectID: Integer): Boolean
```
#### Parameters
*ObjectType ([ObjectType]())* 

The object type that identifies the guided experience item.

*ObjectID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The object ID that identifies the guided experience item.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

Returns true if the given setup guide has been completed by a user, otherwise false.
### Exists (Method) <a name="Exists"></a> 
Checks whether a guided experience item exists for the given object type and ID.

#### Syntax
```
procedure Exists(GuidedExperienceType: Enum "Guided Experience Type"; ObjectType: ObjectType; ObjectID: Integer): Boolean
```
#### Parameters
*GuidedExperienceType ([Enum "Guided Experience Type"]())* 

The type of setup object.

*ObjectType ([ObjectType]())* 

The object type that identifies the guided experience item.

*ObjectID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The object ID that identifies the guided experience item.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if a guided experience item exists for the provided object type and ID; false otherwise.
### Exists (Method) <a name="Exists"></a> 
Checks whether a guided experience item exists for the link.

#### Syntax
```
procedure Exists(GuidedExperienceType: Enum "Guided Experience Type"; Link: Text[250]): Boolean
```
#### Parameters
*GuidedExperienceType ([Enum "Guided Experience Type"]())* 

The type of setup object.

*Link ([Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The link that identifies the guided experience item.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if a guided experience item exists for the provided link; false otherwise.
### AssistedSetupExistsAndIsNotComplete (Method) <a name="AssistedSetupExistsAndIsNotComplete"></a> 
Checks whether a guided experience item exists but has not been completed for the given object type and ID.

#### Syntax
```
procedure AssistedSetupExistsAndIsNotComplete(ObjectType: ObjectType; ObjectID: Integer): Boolean
```
#### Parameters
*ObjectType ([ObjectType]())* 

The object type that identifies the guided experience item.

*ObjectID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The object ID that identifies the guided experience item.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if it exists and is incomplete, false otherwise.
### CompleteAssistedSetup (Method) <a name="CompleteAssistedSetup"></a> 
Sets the status of the guided experience item to complete.

This is typically called from inside the guided experience item when the setup is finished.

#### Syntax
```
procedure CompleteAssistedSetup(ObjectType: ObjectType; ObjectID: Integer)
```
#### Parameters
*ObjectType ([ObjectType]())* 

The object type that identifies the guided experience item.

*ObjectID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The object ID that identifies the guided experience item.

### ResetAssistedSetup (Method) <a name="ResetAssistedSetup"></a> 
Resets the status of the guided experience item so that it does not appear to have been completed.

#### Syntax
```
procedure ResetAssistedSetup(ObjectType: ObjectType; ObjectID: Integer)
```
#### Parameters
*ObjectType ([ObjectType]())* 

The object type that identifies the guided experience item.

*ObjectID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The object ID that identifies the guided experience item.

### Run (Method) <a name="Run"></a> 
Issues the call to start the guided experience item.

#### Syntax
```
procedure Run(GuidedExperienceType: Enum "Guided Experience Type"; ObjectType: ObjectType; ObjectID: Integer)
```
#### Parameters
*GuidedExperienceType ([Enum "Guided Experience Type"]())* 

The type of setup object.

*ObjectType ([ObjectType]())* 

The object type that identifies the guided experience item.

*ObjectID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The object ID that identifies the guided experience item.

### OpenAssistedSetup (Method) <a name="OpenAssistedSetup"></a> 
Opens the Assisted Setup page with the setup guides in it.

#### Syntax
```
procedure OpenAssistedSetup()
```
### OpenAssistedSetup (Method) <a name="OpenAssistedSetup"></a> 
Opens the Assisted Setup page with the setup guides filtered on a selected group of guides.

#### Syntax
```
procedure OpenAssistedSetup(AssistedSetupGroup: Enum "Assisted Setup Group")
```
#### Parameters
*AssistedSetupGroup ([Enum "Assisted Setup Group"]())* 

The group of guides to display on the Assisted Setup page.

### Remove (Method) <a name="Remove"></a> 
Removes a guided experience item.

The OnRegister subscriber which adds this guided experience item needs to be removed first.

#### Syntax
```
procedure Remove(GuidedExperienceType: Enum "Guided Experience Type"; ObjectType: ObjectType; ObjectID: Integer)
```
#### Parameters
*GuidedExperienceType ([Enum "Guided Experience Type"]())* 

The type of setup object.

*ObjectType ([ObjectType]())* 

The object type that identifies the guided experience item.

*ObjectID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The object ID that identifies the guided experience item.

### Remove (Method) <a name="Remove"></a> 
Removes a guided experience item.

The OnRegister subscriber which adds this guided experience item needs to be removed first.

#### Syntax
```
procedure Remove(GuidedExperienceType: Enum "Guided Experience Type"; Link: Text[250])
```
#### Parameters
*GuidedExperienceType ([Enum "Guided Experience Type"]())* 

The type of guided experience item.

*Link ([Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The link that identifies the guided experience item.

### Remove (Method) <a name="Remove"></a> 

 Removes a guided experience item.
 

#### Syntax
```
procedure Remove(GuidedExperienceType: Enum "Guided Experience Type"; ObjectType: ObjectType; ObjectID: Integer; SpotlightTourType: Enum "Spotlight Tour Type")
```
#### Parameters
*GuidedExperienceType ([Enum "Guided Experience Type"]())* 

The type of guided experience item.

*ObjectType ([ObjectType]())* 

The object type of the guided experience item.

*ObjectID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The object ID of the guided experience item.

*SpotlightTourType ([Enum "Spotlight Tour Type"]())* 

The type of spotlight tour of the guided experience item.

### OnRegisterAssistedSetup (Event) <a name="OnRegisterAssistedSetup"></a> 
Notifies that the list of assisted setups is being gathered, and that new items might be added.

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnRegisterAssistedSetup()
```
### OnReRunOfCompletedAssistedSetup (Event) <a name="OnReRunOfCompletedAssistedSetup"></a> 
Notifies that an assisted setup that was previously completed is being run again.

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnReRunOfCompletedAssistedSetup(ExtensionID: Guid; ObjectType: ObjectType; ObjectID: Integer; var Handled: Boolean)
```
#### Parameters
*ExtensionID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The app ID of the extension to which the item belongs.

*ObjectType ([ObjectType]())* 

The object type that identifies the assisted setup.

*ObjectID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The object ID that identifies the assisted setup.

*Handled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

The flag which if set, would stop executing the run of the assisted setup.

### OnAfterRunAssistedSetup (Event) <a name="OnAfterRunAssistedSetup"></a> 
Notifies that the run of the assisted setup has finished.

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnAfterRunAssistedSetup(ExtensionID: Guid; ObjectType: ObjectType; ObjectID: Integer)
```
#### Parameters
*ExtensionID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The app ID of the extension to which the setup belongs.

*ObjectType ([ObjectType]())* 

The object type that identifies the assisted setup.

*ObjectID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The object ID that identifies the assisted setup.

### OnBeforeOpenRoleBasedAssistedSetupExperience (Event) <a name="OnBeforeOpenRoleBasedAssistedSetupExperience"></a> 
Notifies that the Open Role Based Setup Experience has been invoked.

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnBeforeOpenRoleBasedAssistedSetupExperience(var PageID: Integer; var Handled: Boolean)
```
#### Parameters
*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the page being invoked.

*Handled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

The flag which if set, would stop executing the OpenRoleBasedSetupExperience of the assisted setup guide.

### OnRegisterManualSetup (Event) <a name="OnRegisterManualSetup"></a> 

 The event that is raised so that subscribers can add the new manual setups that can be displayed in the Manual Setup page.
 

#### Syntax
```
[IntegrationEvent(true, false)]
internal procedure OnRegisterManualSetup()
```
### OnRegisterGuidedExperienceItem (Event) <a name="OnRegisterGuidedExperienceItem"></a> 

 The event that is raised so that subscribers can add the new guided experience items.
 

#### Syntax
```
[IntegrationEvent(true, false)]
internal procedure OnRegisterGuidedExperienceItem()
```

## [Obsolete] Manual Setup (Codeunit 1875)

 The manual setup aggregates all cases where the functionality is setup manually. Typically this is accomplished
 by registering the setup page ID of the extension that contains the functionality.
 

### Insert (Method) <a name="Insert"></a> 
Insert a manual setup page for an extension.

#### Syntax
```
[Obsolete('Replaced by Insert in the Guided Experience codeunit. See below how to invoke the new function.', '18.0')]
procedure Insert(Name: Text[50]; Description: Text[250]; Keywords: Text[250]; RunPage: Integer; ExtensionId: Guid; Category: Enum "Manual Setup Category")
```
#### Parameters
*Name ([Text[50]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the setup.

*Description ([Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The description of the setup.

*Keywords ([Text[250]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The keywords related to the setup.

*RunPage ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The page ID of the setup page to be run.

*ExtensionId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The ID of the extension that the caller is in. This is used to fetch the icon for the setup.

*Category ([Enum "Manual Setup Category"]())* 

The category that this manual setup belongs to.

### Open (Method) <a name="Open"></a> 
Opens the Manual Setup page with the setup guides in it.

#### Syntax
```
[Obsolete('Replaced by OpenManualSetup() in the Guided Experience codeunit.', '18.0')]
procedure Open()
```
### Open (Method) <a name="Open"></a> 
Opens the Manual Setup page with the setup guides filtered on a selected group of guides.

#### Syntax
```
[Obsolete('Replaced by OpenManualSetup(ManualSetupCategory) in the Guided Experience codeunit.', '18.0')]
procedure Open(ManualSetupCategory: Enum "Manual Setup Category")
```
#### Parameters
*ManualSetupCategory ([Enum "Manual Setup Category"]())* 

The group which the view should be filtered to.

### GetPageIDs (Method) <a name="GetPageIDs"></a> 
Register the manual setups and get the list of page IDs that have been registered.

#### Syntax
```
[Obsolete('The manual setups are now persisted in the Guided Experience Item table.', '18.0')]
procedure GetPageIDs(var PageIDs: List of [Integer])
```
#### Parameters
*PageIDs ([List of [Integer]]())* 

The reference to the list of page IDs for manual setups.

### OnRegisterManualSetup (Event) <a name="OnRegisterManualSetup"></a> 

 The event that is raised so that subscribers can add the new manual setups that can be displayed in the Manual Setup page.
 


 The subscriber should call [Insert](#Insert) on the Sender object.
 

#### Syntax
```
[Obsolete('Replaced by OnRegisterManualSetup in the Guided Experience codeunit.', '18.0')]
[IntegrationEvent(true, false)]
internal procedure OnRegisterManualSetup()
```

## Assisted Setup (Page 1801)
This page shows all registered assisted setup guides.


## Checklist (Page 1993)

 Lists all checklist items and provides capabilities to edit and insert new ones based on existing guided experience items.
 


## Checklist Administration (Page 1992)

 Provides capabilities to edit and insert new checklist items based on existing guided experience items.
 


## Checklist Item Roles (Page 1994)

 Lists the roles that a checklist item should be displayed to.
 


## Checklist Item Users (Page 1995)

 Lists the users that a checklist item should be displayed to.
 


## Checklist Banner (Page 1990)

 Lists the checklist items that a user should go through to finalize their onboarding experience.
 


## Checklist Resurfacing (Page 1997)

## Guided Experience Item List (Page 1996)

 Lists guided experience items.
 


## Manual Setup (Page 1875)
This page shows all registered manual setups.


## Assisted Setup Group (Enum 1815)
The group to which the setup belongs. Please extend this enum to add your own group to classify the setups being added by your extension.

### Uncategorized (value: 0)


 A default group, specifying that the assisted setup is not categorized.
 


## Guided Experience Type (Enum 1990)
### Assisted Setup (value: 0)

### Manual Setup (value: 1)

### Learn (value: 2)

### Tour (value: 3)

### Spotlight Tour (value: 4)

### Video (value: 5)

### Application Feature (value: 6)


## Manual Setup Category (Enum 1875)
The category enum is used to navigate the setup page, which can have many records. It is encouraged to extend this enum and use the newly defined options.

### Uncategorized (value: 0)


 A default category, specifying that the manual setup is not categorized.
 


## Spotlight Tour Text (Enum 1997)

 Specifies the exact step of a spotlight tour that a text belongs to.
 

### Step1Title (value: 0)


 The title for the first step in the spotlight tour.
 

### Step1Text (value: 1)


 The text for the first step in the spotlight tour.
 

### Step2Title (value: 2)


 The title for the second step in the spotlight tour.
 

### Step2Text (value: 3)


 The text for the second step in the spotlight tour.
 


## Spotlight Tour Type (Enum 1996)

 Specifies the type of a spotlight tour.
 

### None (value: 0)


 Default value - none.
 

### Open in Excel (value: 1)


 Specifies that the tour spotlights the Open in Excel functionality on the page.
 

### Share to Teams (value: 2)


 Specifies that the tour spotlights the Share to Teams functionality on the page.
 

