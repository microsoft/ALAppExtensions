This module provides functionality for authenticating to the [Azure Storage Services REST API](https://docs.microsoft.com/en-us/rest/api/storageservices/).

> This module does not store credentials for Azure Storage services.  
> Use caution when you store and pass credentials.  
> We recommend that you familiarize yourself with [Azure security baseline for Azure Storage](https://docs.microsoft.com/en-us/security/benchmark/azure/baselines/storage-security-baseline).

### Access Key / Shared Key
An access key is one possible way to authenticate requests against the API. See [Authorize with Shared Key](https://docs.microsoft.com/en-us/rest/api/storageservices/authorize-with-shared-key) for more information.

#### Examle

```
    [NonDebuggable]
    procedure GetSharedKeyAuthorization(): Interface "Storage Service Authorization"
    var
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
    begin
        exit(StorageServiceAuthorization.CreateSharedKey('<my shared key>'));
    end;
```

### SAS (Shared Access Signature)
A SAS (Shared Access Signature) is one possible way to authenticate requests against the API. See [Grant limited access to Azure Storage resources using shared access signatures (SAS)](https://docs.microsoft.com/en-us/azure/storage/common/storage-sas-overview) for more information.

#### Examle
```
    [NonDebuggable]
    procedure GetSASAuthorization(): Interface "Storage Service Authorization"
    var
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
        Services: List of [Enum "SAS Service Type"];
        Resources: List of [Enum "SAS Resource Type"];
        Permissions: List of [Enum "SAS Permission"];
        Expiry: DateTime;
    begin
        Services.Add(Enum::"SAS Service Type"::Blob);
        Services.Add(Enum::"SAS Service Type"::File);

        Resources.Add(Enum::"SAS Resource Type"::Object);

        Permissions.Add(Enum::"SAS Permission"::List);
        Expiry := CurrentDateTime() + 5;

        exit(StorageServiceAuthorization.CreateAccountSAS('<signing key',
                                                        StorageServiceAuthorization.GetDefaultAPIVersion(),
                                                        Services,
                                                        Resources,
                                                        Permissions,
                                                        Expiry));
    end;
```
# Public Objects
## SAS Parameters (Table 9064)

 Optional parameters for Shared Access Signature authorization for Azure Storage Services.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/create-account-sas
 


## Storage Service Authorization (Interface)

 Common interface for different authorization options.
 

### Authorize (Method) <a name="Authorize"></a> 

 Authorizes an HTTP request by providing the needed authorization information to it.
 

#### Syntax
```
procedure Authorize(var HttpRequest: HttpRequestMessage; StorageAccount: Text)
```
#### Parameters
*HttpRequest ([HttpRequestMessage]())* 

The HTTP request to authorize.

*StorageAccount ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the storage account to authorize against.


## Storage Service Authorization (Codeunit 9062)

 Exposes methods to create different kinds of authorizations for HTTP Request made to Azure Storage Services.
 

### CreateAccountSAS (Method) <a name="CreateAccountSAS"></a> 

 Creates an account SAS (Shared Access Signature) for authorizing HTTP request to Azure Storage Services.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/create-account-sas
 

#### Syntax
```
[NonDebuggable]
procedure CreateAccountSAS(SigningKey: Text; SignedVersion: Enum "Storage Service API Version"; SignedServices: List of [Enum "SAS Service Type"]; SignedResources: List of [Enum "SAS Resource Type"]; SignedPermissions: List of [Enum "SAS Permission"]; SignedExpiry: DateTime): Interface "Storage Service Authorization"
```
#### Parameters
*SigningKey ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The signing key to use.

*SignedVersion ([Enum "Storage Service API Version"]())* 

Specifies the signed storage service version to use to authorize requests made with this account SAS. Must be set to version 2015-04-05 or later.

*SignedServices ([List of [Enum "SAS Service Type"]]())* 

Specifies the signed services accessible with the account SAS.

*SignedResources ([List of [Enum "SAS Resource Type"]]())* 



*SignedPermissions ([List of [Enum "SAS Permission"]]())* 

Specifies the signed permissions for the account SAS. Permissions are only valid if they match the specified signed resource type; otherwise they are ignored.

*SignedExpiry ([DateTime](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/datetime/datetime-data-type))* 

The time at which the shared access signature becomes invalid.

#### Return Value
*[Interface "Storage Service Authorization"]()*

An account SAS authorization.
### CreateAccountSAS (Method) <a name="CreateAccountSAS"></a> 

 Creates an account SAS (Shared Access Signature) for authorizing HTTP request to Azure Storage Services.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/create-account-sas
 

#### Syntax
```
[NonDebuggable]
procedure CreateAccountSAS(SigningKey: Text; SignedVersion: Enum "Storage Service API Version"; SignedServices: List of [Enum "SAS Service Type"];
                                                                    SignedResources: List of [Enum "SAS Resource Type"];
                                                                    SignedPermissions: List of [Enum "SAS Permission"];
                                                                    SignedExpiry: DateTime;
                                                                    OptionalParams: Record "SAS Parameters"): Interface "Storage Service Authorization"
```
#### Parameters
*SigningKey ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The signing key to use.

*SignedVersion ([Enum "Storage Service API Version"]())* 

Specifies the signed storage service version to use to authorize requests made with this account SAS. Must be set to version 2015-04-05 or later.

*SignedServices ([List of [Enum "SAS Service Type"]]())* 

Specifies the signed services accessible with the account SAS.

*SignedResources ([List of [Enum "SAS Resource Type"]]())* 



*SignedPermissions ([List of [Enum "SAS Permission"]]())* 

Specifies the signed permissions for the account SAS. Permissions are only valid if they match the specified signed resource type; otherwise they are ignored.

*SignedExpiry ([DateTime](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/datetime/datetime-data-type))* 

The time at which the shared access signature becomes invalid.

*OptionalParams ([Record "SAS Parameters"]())* 

See table "Stor. Serv. SAS Parameters".

#### Return Value
*[Interface "Storage Service Authorization"]()*

An account SAS authorization.
### CreateSharedKey (Method) <a name="CreateSharedKey"></a> 

 Creates a Shared Key authorization mechanism for HTTP requests to Azure Storage Services.
 See: https://docs.microsoft.com/en-us/rest/api/storageservices/authorize-with-shared-key
 

#### Syntax
```
[NonDebuggable]
procedure CreateSharedKey(SharedKey: Text): Interface "Storage Service Authorization"
```
#### Parameters
*SharedKey ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The shared key to use.

#### Return Value
*[Interface "Storage Service Authorization"]()*

A Shared Key authorization.
### CreateSharedKey (Method) <a name="CreateSharedKey"></a> 

 Creates a Shared Key authorization mechanism for HTTP requests to Azure Storage Services.
 See: https://docs.microsoft.com/en-us/rest/api/storageservices/authorize-with-shared-key
 

#### Syntax
```
[NonDebuggable]
procedure CreateSharedKey(SharedKey: Text; ApiVersion: Enum "Storage Service API Version"): Interface "Storage Service Authorization"
```
#### Parameters
*SharedKey ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The shared key to use.

*ApiVersion ([Enum "Storage Service API Version"]())* 

The API version to use.

#### Return Value
*[Interface "Storage Service Authorization"]()*

A Shared Key authorization.
### GetDefaultAPIVersion (Method) <a name="GetDefaultAPIVersion"></a> 

 Get the default Storage Service API Version.
 

#### Syntax
```
procedure GetDefaultAPIVersion(): Enum "Storage Service API Version"
```
#### Return Value
*[Enum "Storage Service API Version"]()*

The default Storage Service API Version

## Storage Service API Version (Enum 9060)

 Defines the available API versions for Azure Storage Services.
 See: https://docs.microsoft.com/en-us/rest/api/storageservices/previous-azure-storage-service-versions
 

### 2020-10-02 (value: 0)


## SAS Permission (Enum 9064)

 Defines the possible permissions for account SAS.
 See: https://docs.microsoft.com/en-us/rest/api/storageservices/create-account-sas#account-sas-permissions-by-operation
 

### Read (value: 0)

### Add (value: 1)

### Create (value: 2)

### Write (value: 3)

### Delete (value: 4)

### List (value: 5)

### Permanent Delete (value: 6)

### Update (value: 7)

### Process (value: 8)


## SAS Resource Type (Enum 9063)

 Defines the possible resource types for account SAS.
 See: https://docs.microsoft.com/en-us/rest/api/storageservices/create-account-sas#specifying-account-sas-parameters
 

### Service (value: 0)

### Container (value: 1)

### Object (value: 2)


## SAS Service Type (Enum 9062)

 Defines the possible service types for account SAS
 More Information: https://docs.microsoft.com/en-us/rest/api/storageservices/create-account-sas#specifying-account-sas-parameters
 

### Blob (value: 0)

### Queue (value: 1)

### Table (value: 2)

### File (value: 3)

