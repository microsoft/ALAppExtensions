# Public Objects
## Confirm Test Library (Codeunit 132513)
### SetGuiAllowed (Method) <a name="SetGuiAllowed"></a> 

 Sets the value of GUI allowed. This value will be used to determine if the confirm dialog should be shown in 
 GetResponse and GetResponseOrDefault functions when the subscription is bound.
 Uses [OnBeforeGuiAllowed](#OnBeforeGuiAllowed) event.
 

#### Syntax
```
[Scope('OnPrem')]
procedure SetGuiAllowed(IsGuiAllowed: Boolean)
```
#### Parameters
*IsGuiAllowed ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

The desired value of GUI allowed.

