This module contains secret providers. Use this module to do the following:

- Read secrets from the key vault that is specified in the app's manifest file.
- Read secrets from other secret providers.

# Public Objects
## App Key Vault Secret Provider (Codeunit 3800)

 Exposes functionality to retrieve app secrets from the key vault that is specified in the app's manifest file.
 


## In Memory Secret Provider (Codeunit 3802)

 An in-memory secret provider that can be populated with secrets from any source.
 


## Secret Provider (Interface)

 Abstraction for secret providers.
 

### GetSecret (Method) <a name="GetSecret"></a> 

 Retrieves a secret value.
 

#### Syntax
```
procedure GetSecret(SecretName: Text; var SecretValue: Text): Boolean
```
#### Parameters
*SecretName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the secret to retrieve.

*SecretValue ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The value of the secret, or the empty string if the value could not be retrieved.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the secret value could be retrieved; false otherwise.
