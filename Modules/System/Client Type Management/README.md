This module is to allow testing of functionality that relies on a client type other than the one that the test is executed on.

Use this module to do the following:

- Get the client type of the user.

To see how to mock the client type in tests, see `SetClientType` in [codeunit "Test Client Type Subscriber"](https://github.com/microsoft/ALAppExtensions/blob/master/Modules/System%20Test%20Libraries/Client%20Type%20Management/src/TestClientTypeSubscriber.Codeunit.al).


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

The client type of the current session.
