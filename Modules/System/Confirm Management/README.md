Contains helper methods that either display a confirm dialog when logic is run, or suppresses it if UI is not allowed, such as background sessions or webservice calls.

# Public Objects
## Confirm Management (Codeunit 27)

 Exposes functionality to raise a confirm dialog with a question that is to be asked to the user.
 

### GetResponseOrDefault (Method) <a name="GetResponseOrDefault"></a> 

 Raises a confirm dialog with a question and the default response on which the cursor is shown.
 If UI is not allowed, the default response is returned.
 

#### Syntax
```
procedure GetResponseOrDefault(ConfirmQuestion: Text; DefaultButton: Boolean): Boolean
```
#### Parameters
*ConfirmQuestion ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The question to be asked to the user.

*DefaultButton ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

The default response expected.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

The response of the user or the default response passed if no UI is allowed.
### GetResponse (Method) <a name="GetResponse"></a> 

 Raises a confirm dialog with a question and the default response on which the cursor is shown.
 If UI is not allowed, the function returns FALSE.
 

#### Syntax
```
procedure GetResponse(ConfirmQuestion: Text; DefaultButton: Boolean): Boolean
```
#### Parameters
*ConfirmQuestion ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The question to be asked to the user.

*DefaultButton ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

The default response expected.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

The response of the user or FALSE if no UI is allowed.
