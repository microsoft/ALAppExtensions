This module provides methods for presenting a satisfaction survey to users.

Use this module to do the following:
- Activate and deactivate a satisfaction survey
- Present a satisfaction survey to users

# Public Objects
## Satisfaction Survey Mgt. (Codeunit 1433)

 Management codeunit that exposes various functions to work with Satisfaction Survey.
 

### TryShowSurvey (Method) <a name="TryShowSurvey"></a> 

 Tries to show the satisfaction survey dialog to the current user.
 The survey is only shown if the user is chosen for the survey.
 The method sends the request to the server and checks the response to check if the user is chosen for the survey.
 

#### Syntax
```
[Scope('OnPrem')]
procedure TryShowSurvey(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the survey is shown, false otherwise.
### TryShowSurvey (Method) <a name="TryShowSurvey"></a> 

 Tries to show the satisfaction survey dialog to the current user.
 Decision to show the survey or not is based on the response from the server on the check request.
 

#### Syntax
```
[Scope('OnPrem')]
procedure TryShowSurvey(Status: Integer; Response: Text): Boolean
```
#### Parameters
*Status ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Response status code

*Response ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Response body

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the survey is shown, false otherwise.
### TryGetCheckUrl (Method) <a name="TryGetCheckUrl"></a> 

 Gets the URL of the request to the server for checking if the dialog has to be presented to the current user.
 

#### Syntax
```
[Scope('OnPrem')]
procedure TryGetCheckUrl(var Url: Text): Boolean
```
#### Parameters
*Url ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The URL of the request to the server for checking if the dialog has to be presented to the current user.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the check URL is valid, false otherwise.
### GetRequestTimeoutAsync (Method) <a name="GetRequestTimeoutAsync"></a> 

 Gets the asynchronous request timeout.
 

#### Syntax
```
[Scope('OnPrem')]
procedure GetRequestTimeoutAsync(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The asynchronous request timeout in milliseconds.
### ResetState (Method) <a name="ResetState"></a> 

 Deletes the survey state and deactivates the survey for all users.
 

#### Syntax
```
[Scope('OnPrem')]
procedure ResetState(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the survey is deactivated for all users, false otherwise.
### ResetCache (Method) <a name="ResetCache"></a> 

 Resets the the cached survey parameters.
 

#### Syntax
```
[Scope('OnPrem')]
procedure ResetCache(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the cached survey parameters are reset, false otherwise.
### ActivateSurvey (Method) <a name="ActivateSurvey"></a> 

 Activates a try to show the survey for the current user.
 

#### Syntax
```
[Scope('OnPrem')]
procedure ActivateSurvey(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the survey state has been changed from inactive to active, false otherwise.
### DeactivateSurvey (Method) <a name="DeactivateSurvey"></a> 

 Deactivates a try to show the survey for the current user.
 

#### Syntax
```
[Scope('OnPrem')]
procedure DeactivateSurvey(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the survey state has been changed from active to inactive, false otherwise.

## Satisfaction Survey (Page 1433)

 Displays the satisfaction survey dialog box.
 

