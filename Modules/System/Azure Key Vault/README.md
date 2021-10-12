This module exposes functionality to extract secret values from Azure key vault.

# Public Objects
## Azure Key Vault (Codeunit 2200)

 Exposes functionality to handle the retrieval of azure key vault secrets, along with setting the provider and clear the secrets cache used.
 

### GetAzureKeyVaultSecret (Method) <a name="GetAzureKeyVaultSecret"></a> 

 Retrieves a secret from the key vault.
 

This is a try function.

#### Syntax
```
[TryFunction]
[Scope('OnPrem')]
[NonDebuggable]
procedure GetAzureKeyVaultSecret(SecretName: Text; var Secret: Text)
```
#### Parameters
*SecretName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the secret to retrieve.

*Secret ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Out parameter that holds the secret that was retrieved from the key vault.

### GetAzureKeyVaultCertificate (Method) <a name="GetAzureKeyVaultCertificate"></a> 

 Retrieves a certificate from the key vault.
 

This is a try function.

#### Syntax
```
[TryFunction]
[Scope('OnPrem')]
[NonDebuggable]
procedure GetAzureKeyVaultCertificate(CertificateName: Text; var Certificate: Text)
```
#### Parameters
*CertificateName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the secret to retrieve.

*Certificate ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Out parameter that holds the certificate as a base 64 encoded string that was retrieved from the key vault.

