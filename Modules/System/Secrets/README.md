This module contains secret providers. Use this module to do the following:

- Read secrets from the key vault that is specified in the app's manifest file.
- Read secrets from other secret providers.
# Public Objects
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

## App Key Vault Secret Provider (Codeunit 3800)

 Exposes functionality to retrieve app secrets from the key vault that is specified in the app's manifest file.
 

### TryInitializeFromCurrentApp (Method) <a name="TryInitializeFromCurrentApp"></a> 

 Identifies the calling app and initializes the codeunit with the app's key vaults.
 

#### Syntax
```
[TryFunction]
[NonDebuggable]
procedure TryInitializeFromCurrentApp()
```
### GetSecret (Method) <a name="GetSecret"></a> 

 Retrieves a secret value from one of the app's key vaults.
 

#### Syntax
```
[NonDebuggable]
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

## In Memory Secret Provider (Codeunit 3802)

 An in-memory secret provider that can be populated with secrets from any source.
 

### AddSecret (Method) <a name="AddSecret"></a> 

 Adds a secret to the secret provider. If the secret is already present in the secret provider, its value will be overwritten.
 

#### Syntax
```
[NonDebuggable]
procedure AddSecret(SecretName: Text; SecretValue: Text)
```
#### Parameters
*SecretName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the secret.

*SecretValue ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The value of the secret.

### GetSecret (Method) <a name="GetSecret"></a> 

 Retrieves a secret value from the secret provider.
 

#### Syntax
```
[NonDebuggable]
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
