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
*NewClientType ([ClientType](https://go.microsoft.com/fwlink/?linkid=2211600))* 

The client type that will be returned from GetCurrentClientType.

