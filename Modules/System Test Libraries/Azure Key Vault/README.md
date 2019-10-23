# Public Objects
## Azure Key Vault Test Library (Codeunit 135210)
### SetAzureKeyVaultSecretProvider (Method) <a name="SetAzureKeyVaultSecretProvider"></a> 

 Sets the secret provider for the Azure key vault.
 

Use this function only for testing.

#### Syntax
```
procedure SetAzureKeyVaultSecretProvider(NewAzureKeyVaultSecretProvider: DotNet IAzureKeyVaultSecretProvider)
```
#### Parameters
*NewAzureKeyVaultSecretProvider ([DotNet IAzureKeyVaultSecretProvider]())* 

A new Azure Key Vault secret provider.

### ClearSecrets (Method) <a name="ClearSecrets"></a> 

 Clears the key vault cache. Use this function to reinitialize the Azure key vault.
 

Use this function only for testing.

#### Syntax
```
procedure ClearSecrets()
```
