This module contains functionality for initializing the application.

Use this module to do the following:
- Check whether initialization is currently in progress.
- Add custom functionality to run when the application is initialized.

# Public Objects
## System Initialization (Codeunit 150)

 Exposes functionality to check whether the system is initializing as well as an event to subscribed to in order to execute logic right after the system has initialized.
 

### IsInProgress (Method) <a name="IsInProgress"></a> 

 Checks whether the system initialization is currently in progress.
 

#### Syntax
```
procedure IsInProgress(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True, if the system initialization is in progress; false, otherwise
### OnAfterInitialization (Event) <a name="OnAfterInitialization"></a> 

 Integration event for after the system initialization.
 Subscribe to this event in order to execute additional initialization steps.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnAfterInitialization()
```
