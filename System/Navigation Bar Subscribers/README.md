Collection of the default subscribers to system events and corresponding overridable integration events for the Navigation Bar.
# Public Objects
## Navigation Bar Subscribers (Codeunit 154)
Collection of the default subscribers to system events and corresponding overridable integration events.

### OnBeforeDefaultOpenCompanySettings (Event) <a name="OnBeforeDefaultOpenCompanySettings"></a> 
Notifies that the Default Open Company Settings has been invoked.

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnBeforeDefaultOpenCompanySettings(var Handled: Boolean)
```
#### Parameters
*Handled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

The flag which if set, would stop executing the event.

### OnBeforeDefaultOpenRoleBasedSetupExperience (Event) <a name="OnBeforeDefaultOpenRoleBasedSetupExperience"></a> 
Notifies that the Default Open Role Based Setup Experience has been invoked.

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnBeforeDefaultOpenRoleBasedSetupExperience(var Handled: Boolean)
```
#### Parameters
*Handled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

The flag which if set, would stop executing the event.

### OnBeforeDefaultOpenGeneralSetupExperience (Event) <a name="OnBeforeDefaultOpenGeneralSetupExperience"></a> 
Notifies that the Default Open General Setup Experience has been invoked.

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnBeforeDefaultOpenGeneralSetupExperience(var Handled: Boolean)
```
#### Parameters
*Handled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

The flag which if set, would stop executing the event.

