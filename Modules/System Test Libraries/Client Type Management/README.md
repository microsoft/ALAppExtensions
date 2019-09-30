# Public Objects
## Test Client Type Subscriber (Codeunit 130018)
### SetClientType (Method) <a name="SetClientType"></a> 

 Sets the client type that will be returned from the GetCurrentClientType function when the subscription is bound.
 Uses [OnAfterGetCurrentClientType](#OnAfterGetCurrentClientType) event.
 

#### Syntax
```
[Scope('OnPrem')]
procedure SetClientType(NewClientType: ClientType)
```
#### Parameters
*NewClientType ([ClientType](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/clienttype/clienttype-option))* 

The client type that will be returned from GetCurrentClientType.

