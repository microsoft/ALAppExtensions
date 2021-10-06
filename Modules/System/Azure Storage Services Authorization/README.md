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