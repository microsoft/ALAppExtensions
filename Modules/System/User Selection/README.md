Provides a page where you look up and select one or more registered users. For example, this is useful for assigning a person to things like documents, processes, or items.

# Public Objects
## User Selection (Codeunit 9843)

 Provides basic functionality to open a search page and validate user information.
 

### Open (Method) <a name="Open"></a> 

 Opens the user lookup page and assigns the selected users on the  parameter.
 

#### Syntax
```
procedure Open(var SelectedUser: Record User): Boolean
```
#### Parameters
*SelectedUser ([Record User]())* 

The variable to return the selected users. Any filters on this record will influence the page view.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

Returns true if a user was selected.
### ValidateUserName (Method) <a name="ValidateUserName"></a> 

 Displays an error if there is no user with the given username and the user table is not empty.
 

#### Syntax
```
procedure ValidateUserName(UserName: Code[50])
```
#### Parameters
*UserName ([Code[50]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

The username to validate.

### HideExternalUsers (Method) <a name="HideExternalUsers"></a> 

 Sets Filter on the given User Record to exclude external users.
 

#### Syntax
```
procedure HideExternalUsers(var User: Record User)
```
#### Parameters
*User ([Record User]())* 

The User Record to return.


## User Lookup (Page 9843)

 Lookup page for users.
 

### GetSelectedUsers (Method) <a name="GetSelectedUsers"></a> 

 Gets the currently selected users.
 

#### Syntax
```
[Scope('OnPrem')]
procedure GetSelectedUsers(var SelectedUser: Record User)
```
#### Parameters
*SelectedUser ([Record User]())* 

A record that contains the currently selected users

