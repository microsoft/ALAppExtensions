# Public Objects
## User Login Test Library (Codeunit 138049)
### InsertUserLogin (Method) <a name="InsertUserLogin"></a> 

 Creates login information for a user.
 

#### Syntax
```
procedure InsertUserLogin(UserSID: Guid; FirstLoginDate: Date; LastLoginDateTime: DateTime; PenultimateLoginDateTime: DateTime)
```
#### Parameters
*UserSID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The security ID of the user for whom to create the login information

*FirstLoginDate ([Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type))* 

Date to be entered as first login

*LastLoginDateTime ([DateTime](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/datetime/datetime-data-type))* 

Date time to be entered as last login

*PenultimateLoginDateTime ([DateTime](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/datetime/datetime-data-type))* 

Date time to be entered as penultimate login

### UpdateUserLogin (Method) <a name="UpdateUserLogin"></a> 

 Updates login information for a user.
 

#### Syntax
```
procedure UpdateUserLogin(UserSID: Guid; FirstLoginDate: Date; LastLoginDateTime: DateTime; PenultimateLoginDateTime: DateTime)
```
#### Parameters
*UserSID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The security ID of the user for whom to update the login information

*FirstLoginDate ([Date](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type))* 

Date to be entered as first login

*LastLoginDateTime ([DateTime](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/datetime/datetime-data-type))* 

Date time to be entered as last login

*PenultimateLoginDateTime ([DateTime](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/datetime/datetime-data-type))* 

Date time to be entered as penultimate login

### DeleteAllLoginInformation (Method) <a name="DeleteAllLoginInformation"></a> 

 Deletes all login information for a user.
 

#### Syntax
```
procedure DeleteAllLoginInformation(UserSID: Guid)
```
#### Parameters
*UserSID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The security ID of the user for whom to delete the login information

