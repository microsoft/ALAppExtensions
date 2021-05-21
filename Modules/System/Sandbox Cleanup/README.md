Provides an event in order to be able to clean up data when copying the environment to sandbox.
# Public Objects
## Sandbox Cleanup (Codeunit 1884)

 Codeunit that raises an event that could be used to clean up data when copying a company to sandbox environment.
 

### OnClearConfiguration (Event) <a name="OnClearConfiguration"></a> 

 Subscribe to this event to clean up data when copying a company to a sandbox environment.
 

#### Syntax
```
[Obsolete('Separated into two events for clearing of company-specific data and environment-specific data. OnClearCompanyConfiguration and OnClearDatabaseConfiguration', '17.1')]
[IntegrationEvent(false, false)]
internal procedure OnClearConfiguration(CompanyName: Text)
```
#### Parameters
*CompanyName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the company.

### OnClearCompanyConfiguration (Event) <a name="OnClearCompanyConfiguration"></a> 

 Subscribe to this event to clean up company-specific data when copying to a sandbox environment.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnClearCompanyConfiguration(CompanyName: Text)
```
#### Parameters
*CompanyName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the company.

### OnClearDatabaseConfiguration (Event) <a name="OnClearDatabaseConfiguration"></a> 

 Subscribe to this event to clean up environment-specific data when copying to a sandbox environment.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnClearDatabaseConfiguration()
```
