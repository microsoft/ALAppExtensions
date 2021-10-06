Contains helper methods for getting information about the tenant and general settings, such as determining whether this is a production or sandbox environment, or deployed as an online or on-premises version, and so on.

# Public Objects
## Environment Information (Codeunit 457)

 Exposes functionality to fetch attributes concerning the environment of the service on which the tenant is hosted.
 

### IsProduction (Method) <a name="IsProduction"></a> 

 Checks if environment type of tenant is Production.
 

#### Syntax
```
procedure IsProduction(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the environment type is Production, False otherwise.
### GetEnvironmentName (Method) <a name="GetEnvironmentName"></a> 

 Gets the name of the environment.
 

#### Syntax
```
procedure GetEnvironmentName(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The name of the environment.
### IsSandbox (Method) <a name="IsSandbox"></a> 

 Checks if environment type of tenant is Sandbox.
 

#### Syntax
```
procedure IsSandbox(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the environment type is a Sandbox, False otherwise.
### IsSaaS (Method) <a name="IsSaaS"></a> 

 Checks if the deployment type is SaaS (Software as a Service).
 

#### Syntax
```
procedure IsSaaS(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the deployment type is a SaaS, false otherwise.
### IsOnPrem (Method) <a name="IsOnPrem"></a> 

 Checks the deployment type is OnPremises.
 

#### Syntax
```
procedure IsOnPrem(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the deployment type is OnPremises, false otherwise.
### IsFinancials (Method) <a name="IsFinancials"></a> 

 Checks the application family is Financials.
 

#### Syntax
```
procedure IsFinancials(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the application family is Financials, false otherwise.
### IsSaaSInfrastructure (Method) <a name="IsSaaSInfrastructure"></a> 

 Checks if the deployment infrastucture is SaaS (Software as a Service).
 Note: This function will return false in a Docker container.
 

#### Syntax
```
procedure IsSaaSInfrastructure(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the deployment infrastructure type is a SaaS, false otherwise.
### GetApplicationFamily (Method) <a name="GetApplicationFamily"></a> 

 Gets the application family.
 

#### Syntax
```
procedure GetApplicationFamily(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The application family.
### VersionInstalled (Method) <a name="VersionInstalled"></a> 

 Gets the version which a given app was installed in.
 

#### Syntax
```
procedure VersionInstalled(AppID: Guid): Integer
```
#### Parameters
*AppID ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

The module ID of the app.

#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The major version number when the app was installed.

## Tenant Information (Codeunit 417)

 Exposes functionality to fetch attributes concerning the current tenant.
 

### GetTenantId (Method) <a name="GetTenantId"></a> 

 Gets the tenant ID.
 

#### Syntax
```
procedure GetTenantId(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

If it cannot be found, an empty string is returned.
### GetTenantDisplayName (Method) <a name="GetTenantDisplayName"></a> 

 Gets the tenant name.
 

#### Syntax
```
procedure GetTenantDisplayName(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

If it cannot be found, an empty string is returned.
