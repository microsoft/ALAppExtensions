This module provides functionality for keeping track of when users sign in.

Use this module to do the following:
- Find out whether this is the first time a user has logged in
- Check whether any users have logged in since a given date, or date and time
- Retrieve the second to last date and time the current user logged in
- Create or update the current user's login information (the first, second to last, and last login dates)

# Public Objects
## User Login Time Tracker (Codeunit 9026)

 Exposes functionality to retrieve information about the user's first, penultimate and last login times.
 

### IsFirstLogin (Method) <a name="IsFirstLogin"></a> 

 Returns true if this is the first time the user logs in.
 

#### Syntax
```
procedure IsFirstLogin(UserSecurityID: Guid): Boolean
```
#### Parameters
*UserSecurityID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The User Security ID.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if this is the first time the user logs in and false otherwise.
### AnyUserLoggedInSinceDate (Method) <a name="AnyUserLoggedInSinceDate"></a> 

 Returns true if any user logged in on or after the specified date.
 

#### Syntax
```
procedure AnyUserLoggedInSinceDate(FromDate: Date): Boolean
```
#### Parameters
*FromDate ([Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type))* 

The date to start searching from.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if any user logged in on or after the specified date and false otherwise.
### UserLoggedInSinceDateTime (Method) <a name="UserLoggedInSinceDateTime"></a> 

 Returns true if the current user logged in at or after the specified DateTime.
 

#### Syntax
```
procedure UserLoggedInSinceDateTime(FromDateTime: DateTime): Boolean
```
#### Parameters
*FromDateTime ([DateTime](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/datetime/datetime-data-type))* 

The DateTime to start searching from.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the current user logged in at or after the specified DateTime and false otherwise.
### GetPenultimateLoginDateTime (Method) <a name="GetPenultimateLoginDateTime"></a> 

 Returns the penultimate login DateTime of the current user.
 

#### Syntax
```
procedure GetPenultimateLoginDateTime(): DateTime
```
#### Return Value
*[DateTime](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/datetime/datetime-data-type)*

The penultimate login DateTime of the current user, or 0DT if the user login cannot be found.
### CreateOrUpdateLoginInfo (Method) <a name="CreateOrUpdateLoginInfo"></a> 

 Updates or creates the last login information of the current user (first, last and penultimate login date).
 

#### Syntax
```
[Scope('OnPrem')]
procedure CreateOrUpdateLoginInfo()
```
### OnAfterCreateorUpdateLoginInfo (Event) <a name="OnAfterCreateorUpdateLoginInfo"></a> 

 Publishes an event that is fired whenever a user's login information is created or updated.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnAfterCreateorUpdateLoginInfo(UserSecurityId: Guid)
```
#### Parameters
*UserSecurityId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The User Security ID of the user that is being created or updated.

