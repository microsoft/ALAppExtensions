This module provides methods for retrieving information about the Azure Active Directory tenant.

Use this module to do the following:

- Get the domain name associated with the tenant.
- Get the ID associated with the tenant.

# Public Objects
## Azure AD Tenant (Codeunit 433)

 Exposes functionality to fetch attributes concerning the current tenant.
 

### GetAadTenantId (Method) <a name="GetAadTenantId"></a> 

 Gets the tenant AAD ID.
 

#### Syntax
```
procedure GetAadTenantId(): Text
```
#### Return Value
*[Text](https://go.microsoft.com/fwlink/?linkid=2210031)*

If it cannot be found, an empty string is returned.
### GetAadTenantDomainName (Method) <a name="GetAadTenantDomainName"></a> 
Cannot retrieve the Azure Active Directory tenant domain name.


 Gets the Azure Active Directory tenant domain name.
 If the Microsoft Graph API cannot be reached, the error is displayed.
 

#### Syntax
```
procedure GetAadTenantDomainName(): Text
```
#### Return Value
*[Text](https://go.microsoft.com/fwlink/?linkid=2210031)*

The AAD Tenant Domain Name.
