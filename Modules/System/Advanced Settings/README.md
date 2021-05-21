The modules exposes advanced settings page and related integration events.
 

# Public Objects
## Advanced Settings (Codeunit 9202)
Advanced settings exposes integration events raised at Advance Settings Page open.

### OnBeforeOpenGeneralSetupExperience (Event) <a name="OnBeforeOpenGeneralSetupExperience"></a> 
Notifies that the Open General Setup Experience has been invoked.

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnBeforeOpenGeneralSetupExperience(var PageID: Integer; var Handled: Boolean)
```
#### Parameters
*PageID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The Page ID of the page been invoked.

*Handled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

The flag which if set, would stop executing the OpenGeneralSetupExperience of the assisted setup guide.


## Advanced Settings (Page 9202)
This page shows all the registered entries in the advanced settings page.

