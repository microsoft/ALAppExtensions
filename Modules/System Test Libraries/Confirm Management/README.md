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
*IsGuiAllowed ([Boolean](https://go.microsoft.com/fwlink/?linkid=2209954))* 

The desired value of GUI allowed.

