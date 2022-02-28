Stores and exposes user-specific settings such as assigned roles, preferred language and time-zone.

Use this module to:
- Retrieve settings for a user.
- Add additional settings for a user.
- Display user-specific settings.

# Public Objects
## User Settings (Table 9172)

 Temporary table that combines the settings defined by platform and application
 


## User Settings (Codeunit 9176)

 Provides basic functionality for user settings.
 

### GetPageId (Method) <a name="GetPageId"></a> 

 Gets the page id for the User Settings page.
 

#### Syntax
```
procedure GetPageId(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The page ID for the User Settings page.
### GetUserSettings (Method) <a name="GetUserSettings"></a> 

 Gets the settings for the given user.
 

#### Syntax
```
procedure GetUserSettings(UserSecurityID: Guid; var UserSettings : Record "User Settings")
```
#### Parameters
*UserSecurityID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The user security id of the user.

*UserSettings ([Record "User Settings"]())* 

The return Record with the settings od the User.

### DisableTeachingTips (Method) <a name="DisableTeachingTips"></a> 

 Disables the teaching tips for a given user.
 

#### Syntax
```
procedure DisableTeachingTips(UserSecurityId: Guid)
```
#### Parameters
*UserSecurityId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 



### EnableTeachingTips (Method) <a name="EnableTeachingTips"></a> 

 Enables the teaching tips for a given user.
 

#### Syntax
```
procedure EnableTeachingTips(UserSecurityId: Guid)
```
#### Parameters
*UserSecurityId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 



### OnGetDefaultProfile (Event) <a name="OnGetDefaultProfile"></a> 

 Integration event to get the default profile.
 

#### Syntax
```
[IntegrationEvent(false, false)]
procedure OnGetDefaultProfile(var AllProfile: Record "All Profile")
```
#### Parameters
*AllProfile ([Record "All Profile"]())* 

The return record that holds the default profile.

### OnGetSettingsPageID (Event) <a name="OnGetSettingsPageID"></a> 

 Integration event that allows changing the settings page ID.
 

#### Syntax
```
[IntegrationEvent(false, false)]
procedure OnGetSettingsPageID(var SettingsPageID: Integer)
```
#### Parameters
*SettingsPageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The new page ID for the user settings page.

### OnBeforeOpenSettings (Event) <a name="OnBeforeOpenSettings"></a> 

 Integration event that allows changing the behavior of opening the settings page.
 

#### Syntax
```
[IntegrationEvent(false, false)]
procedure OnBeforeOpenSettings(var Handled: Boolean)
```
#### Parameters
*Handled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Set to true to skip the default behavior.

### OnAfterGetUserSettings (Event) <a name="OnAfterGetUserSettings"></a> 

 Integration event that allows updating the User Settings record with extra values.
 

#### Syntax
```
[IntegrationEvent(false, false)]
procedure OnAfterGetUserSettings(var UserSettings: Record "User Settings")
```
#### Parameters
*UserSettings ([Record "User Settings"]())* 

The User settings record to update.

### OnUpdateUserSettings (Event) <a name="OnUpdateUserSettings"></a> 

 Integration event that allows updating the settings on related records.
 

#### Syntax
```
[IntegrationEvent(false, false)]
procedure OnUpdateUserSettings(OldSettings: Record "User Settings"; NewSettings: Record "User Settings")
```
#### Parameters
*OldSettings ([Record "User Settings"]())* 

The value of the settings before any user interaction.

*NewSettings ([Record "User Settings"]())* 

The value of the settings after user interaction.

### OnCompanyChange (Event) <a name="OnCompanyChange"></a> 

 Integration event that fires every time the company is changed.
 

#### Syntax
```
[IntegrationEvent(false, false)]
procedure OnCompanyChange(NewCompanyName: Text; var IsSetupInProgress: Boolean)
```
#### Parameters
*NewCompanyName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the new company.

*IsSetupInProgress ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Set to true if the given company is still setting up.

### OnUserRoleCenterChange (Event) <a name="OnUserRoleCenterChange"></a> 

 Integration event that fires every time the Role Center is changed.
 

#### Syntax
```
[Obsolete('Use "OnUpdateUserSettings" event instead.', '19.0')]
[IntegrationEvent(false, false)]
procedure OnUserRoleCenterChange(NewAllProfile: Record "All Profile")
```
#### Parameters
*NewAllProfile ([Record "All Profile"]())* 

The All Profile Record that holds the new profile.

### OnAfterQueryClosePage (Event) <a name="OnAfterQueryClosePage"></a> 

 Integration event that fires every time the settings page closes.
 

#### Syntax
```
[Obsolete('Use "OnUpdateUserSettings" event instead.', '19.0')]
[IntegrationEvent(false, false)]
procedure OnAfterQueryClosePage(NewLanguageID: Integer; NewLocaleID: Integer; NewTimeZoneID: Text[180]; NewCompany: Text; NewAllProfile: Record "All Profile")
```
#### Parameters
*NewLanguageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The Language ID selected.

*NewLocaleID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The Locale ID selected.

*NewTimeZoneID ([Text[180]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Time Zone selected.

*NewCompany ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The company selected.

*NewAllProfile ([Record "All Profile"]())* 

The All Profile Record that holds the new profile.

### OnBeforeLanguageChange (Event) <a name="OnBeforeLanguageChange"></a> 

 Integration event that fires every time the Language changes.
 

#### Syntax
```
[Obsolete('Use "OnUpdateUserSettings" event instead.', '19.0')]
[IntegrationEvent(false, false)]
procedure OnBeforeLanguageChange(OldLanguageId: Integer; NewLanguageId: Integer)
```
#### Parameters
*OldLanguageId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The old Language ID.

*NewLanguageId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The new Language ID selected.

### OnBeforeWorkdateChange (Event) <a name="OnBeforeWorkdateChange"></a> 

 Integration event that fires every time the work date changes.
 

#### Syntax
```
[Obsolete('Use "OnUpdateUserSettings" event instead.', '19.0')]
[IntegrationEvent(false, false)]
procedure OnBeforeWorkdateChange(OldWorkdate: Date; NewWorkdate: Date)
```
#### Parameters
*OldWorkdate ([Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type))* 

The old work date.

*NewWorkdate ([Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type))* 

The new work date selected.


## Accessible Companies (Page 9210)

 List page that contains the allowed companies for the current user.
 

### Initialize (Method) <a name="Initialize"></a> 
#### Syntax
```
procedure Initialize()
```

## Roles (Page 9212)

 List page that contains all available roles.
 

### Initialize (Method) <a name="Initialize"></a> 

  Initializes the page by populating the source record.
 

#### Syntax
```
procedure Initialize()
```

## User Personalization (Page 9214)

 Page that shows the settings of a given user.
 


## User Settings (Page 9204)

 Page that shows the settings of a given user.
 


## User Settings FactBox (Page 9208)

 A Factbox that shows the settings of a given user.
 


## User Settings List (Page 9206)

 List page that shows the settings of all users.
 

