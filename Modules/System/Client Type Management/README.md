The purpose of this module is to allow testing of units that rely on client type other than the one on which the test executes. 
This is achieved by using the method `GetCurrentClientType` in the unit to compare the client type and subscribing to the event `OnAfterGetCurrentClientType` to alter the client type in the test.


# Public Objects
## Client Type Management (Codeunit 4030)

 Exposes functionality to fetch the client type that the user is currently using.
 

### GetCurrentClientType (Method) <a name="GetCurrentClientType"></a> 
Example 
 `
 IF ClientTypeManagement.GetCurrentClientType IN [CLIENTTYPE::xxx, CLIENTTYPE::yyy] THEN
 `

Gets the current type of the client being used by the caller, e.g. Phone, Web, Tablet etc.

 Use the GetCurrentClientType wrapper method when you want to test a flow on a different type of client.

#### Syntax
```
procedure GetCurrentClientType(): ClientType
```
#### Return Value
*[ClientType](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/clienttype/clienttype-option)*


