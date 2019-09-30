# Public Objects
## Environment Info Test Library (Codeunit 135094)
### SetTestabilitySandbox (Method) <a name="SetTestabilitySandbox"></a> 

 Sets the testability sandbox flag.
 


 This functions should only be used for testing purposes.
 

#### Syntax
```
[Scope('OnPrem')]
procedure SetTestabilitySandbox(EnableSandboxForTest: Boolean)
```
#### Parameters
*EnableSandboxForTest ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

The value to be set to the testability sandbox flag.

### SetTestabilitySoftwareAsAService (Method) <a name="SetTestabilitySoftwareAsAService"></a> 

 Sets the testability SaaS flag.
 


 This functions should only be used for testing purposes.
 

#### Syntax
```
[Scope('OnPrem')]
procedure SetTestabilitySoftwareAsAService(EnableSoftwareAsAServiceForTest: Boolean)
```
#### Parameters
*EnableSoftwareAsAServiceForTest ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

The value to be set to the testability SaaS flag.

### SetAppId (Method) <a name="SetAppId"></a> 

 Sets the App ID that of the current application (for example, 'FIN' - Financials) when the sunscription is bound.
 Uses [OnBeforeGetApplicationIdentifier](#OnBeforeGetApplicationIdentifier) event.
 

#### Syntax
```
[Scope('OnPrem')]
procedure SetAppId(NewAppId: Text)
```
#### Parameters
*NewAppId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The desired ne App ID.

