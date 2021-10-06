Provides functionality to work with storage accounts, containers and blobs from Azure Blob Storage Services.

Use the module to
- Create, delete and list containers in storage accounts.
- Build up a tool for uploading and downloading BLOBs to and from Azure Blob Storage Services.
- Manipulate data stored in Azure Blob Storage Services.

```
var
    procedure CreateMyFirstBlob()
    var
        ABSContainerClient: Codeunit "ABS Container Client";
        ABSBlobClient: Codeunit "ABS Blob Client";
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
        Response: Codeunit "ABS Operation Response";
        Authorization: Interface "Storage Service Authorization";
    begin
        Authorization := StorageServiceAuthorization.CreateSharedKey('<my shared key>');

        ABSContainerClient.Initialize('<storage account name>', Authorization);
        ABSContainerClient.CreateContainer('<my fist container>');

        ABSBlobClient.Initialize('<storage account name>', '<my fist container>', Authorization);
        ABSBlobClient.PutBlobBlockBlobText('<my first blob>', 'Yay! This is my first BLOB in Azure Blob Storage services!')
    end;
```


