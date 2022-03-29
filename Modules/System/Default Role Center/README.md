The modules exposes functionality to define default role center.

Example

```
[EventSubscriber(ObjectType::Codeunit, Codeunit::"Default Role Center", 'OnBeforeGetDefaultRoleCenter', '', false, false)]
local procedure SetRoleCenter(var RoleCenterId: Integer; var Handled: Boolean)
begin
    // Do not overwrite already defined default role center
    if Handled then
        exit;
        
    RoleCenterId := Page::MyAwesomeRoleCenterPage;

    // Set Handled to true so that other subscribers know that a default role center has been defined
    Handled := true;
end;
```

# Public Objects
## Default Role Center (Codeunit 9172)

 The codeunit that emits the event that sets the default Role Center.
 To use another Role Center by default, you must have a profile for it.
 

### OnBeforeGetDefaultRoleCenter (Event) <a name="OnBeforeGetDefaultRoleCenter"></a> 

 Integration event for setting the default Role Center ID.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnBeforeGetDefaultRoleCenter(var RoleCenterId: Integer; var Handled: Boolean)
```
#### Parameters
*RoleCenterId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Out parameter holding the Role Center ID.

*Handled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Handled pattern


## Blank Role Center (Page 8999)

 Empty role center to use in case no other role center is present when system is initializing.
 


## BLANK (Profile)

 Empty profile to use in case no other profile is present when system is initializing.
 

