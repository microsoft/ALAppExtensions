# Public Objects
## User Login Test Library (Codeunit 138049)
### InsertUserLogin (Method) <a name="InsertUserLogin"></a> 

 Creates login information for a user.
 

#### Syntax
```
procedure InsertUserLogin(UserSID: Guid; FirstLoginDate: Date; LastLoginDateTime: DateTime; PenultimateLoginDateTime: DateTime)
```
#### Parameters
*UserSID ([Guid](https://go.microsoft.com/fwlink/?linkid=2210122))* 

The security ID of the user for whom to create the login information

*FirstLoginDate ([Date](https://go.microsoft.com/fwlink/?linkid=2210124))* 

Date to be entered as first login

*LastLoginDateTime ([DateTime](https://go.microsoft.com/fwlink/?linkid=2210239))* 

Date time to be entered as last login

*PenultimateLoginDateTime ([DateTime](https://go.microsoft.com/fwlink/?linkid=2210239))* 

Date time to be entered as penultimate login

### UpdateUserLogin (Method) <a name="UpdateUserLogin"></a> 

 Updates login information for a user.
 

#### Syntax
```
procedure UpdateUserLogin(UserSID: Guid; FirstLoginDate: Date; LastLoginDateTime: DateTime; PenultimateLoginDateTime: DateTime)
```
#### Parameters
*UserSID ([Guid](https://go.microsoft.com/fwlink/?linkid=2210122))* 

The security ID of the user for whom to update the login information

*FirstLoginDate ([Date](https://go.microsoft.com/fwlink/?linkid=2210124))* 

Date to be entered as first login

*LastLoginDateTime ([DateTime](https://go.microsoft.com/fwlink/?linkid=2210239))* 

Date time to be entered as last login

*PenultimateLoginDateTime ([DateTime](https://go.microsoft.com/fwlink/?linkid=2210239))* 

Date time to be entered as penultimate login

### DeleteAllLoginInformation (Method) <a name="DeleteAllLoginInformation"></a> 

 Deletes all login information for a user.
 

#### Syntax
```
procedure DeleteAllLoginInformation(UserSID: Guid)
```
#### Parameters
*UserSID ([Guid](https://go.microsoft.com/fwlink/?linkid=2210122))* 

The security ID of the user for whom to delete the login information

