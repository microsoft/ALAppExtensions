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


# Public Objects
## ABS Container (Table 9044)

 Holds information about containers in a storage account.
 


## ABS Container Content (Table 9043)

 Holds information about container content in a storage account.
 


## ABS Blob Client (Codeunit 9053)

 Provides functionality for using operations on blobs in Azure Blob storage.
 

### Initialize (Method) <a name="Initialize"></a> 

 Initializes the Azure Blob storage client.
 

#### Syntax
```
[NonDebuggable]
procedure Initialize(StorageAccount: Text; Container: Text; Authorization: Interface "Storage Service Authorization")
```
#### Parameters
*StorageAccount ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of Storage Account to use.

*Container ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the container to use.

*Authorization ([Interface "Storage Service Authorization"]())* 

The authorization to use.

### Initialize (Method) <a name="Initialize"></a> 

 Initializes the Azure BLOB Storage BLOB client.
 

#### Syntax
```
[NonDebuggable]
procedure Initialize(StorageAccount: Text; Container: Text; Authorization: Interface "Storage Service Authorization"; APIVersion: Enum "Storage Service API Version")
```
#### Parameters
*StorageAccount ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of Storage Account to use.

*Container ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the container to use.

*Authorization ([Interface "Storage Service Authorization"]())* 

The authorization to use.

*APIVersion ([Enum "Storage Service API Version"]())* 

The used API version to use.

### SetBaseUrl (Method) <a name="SetBaseUrl"></a> 

 The base URL to use when constructing the final URI.
 If not set, the base URL is https://%1.blob.core.windows.net where %1 is the storage account name.
 

Use %1 as a placeholder for the storage account name.

#### Syntax
```
procedure SetBaseUrl(BaseUrl: Text)
```
#### Parameters
*BaseUrl ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A valid URL string

### ListBlobs (Method) <a name="ListBlobs"></a> 

 Lists the blobs in a specific container.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/list-blobs
 

#### Syntax
```
procedure ListBlobs(var ContainerContent: Record "ABS Container Content"): Codeunit "ABS Operation Response"
```
#### Parameters
*ContainerContent ([Record "ABS Container Content"]())* 

Collection of the result (temporary record).

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### ListBlobs (Method) <a name="ListBlobs"></a> 

 Lists the blobs in a specific container.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/list-blobs
 

#### Syntax
```
procedure ListBlobs(var ContainerContent: Record "ABS Container Content"; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
```
#### Parameters
*ContainerContent ([Record "ABS Container Content"]())* 

Collection of the result (temporary record).

*OptionalParameters ([Codeunit "ABS Optional Parameters"]())* 

Optional parameters to pass.

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### PutBlobBlockBlobUI (Method) <a name="PutBlobBlockBlobUI"></a> 

 Uploads a file as a BlockBlob (with File Selection Dialog).
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
 

#### Syntax
```
procedure PutBlobBlockBlobUI(): Codeunit "ABS Operation Response"
```
#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### PutBlobBlockBlobUI (Method) <a name="PutBlobBlockBlobUI"></a> 

 Uploads a file as a BlockBlob (with File Selection Dialog).
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
 

#### Syntax
```
procedure PutBlobBlockBlobUI(OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
```
#### Parameters
*OptionalParameters ([Codeunit "ABS Optional Parameters"]())* 

Optional parameters to pass.

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### PutBlobBlockBlobStream (Method) <a name="PutBlobBlockBlobStream"></a> 

 Uploads the content of an InStream as a BlockBlob
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
 

#### Syntax
```
procedure PutBlobBlockBlobStream(BlobName: Text; var SourceStream: InStream): Codeunit "ABS Operation Response"
```
#### Parameters
*BlobName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the blob.

*SourceStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The Content of the Blob as InStream.

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### PutBlobBlockBlobStream (Method) <a name="PutBlobBlockBlobStream"></a> 

 Uploads the content of an InStream as a BlockBlob.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
 

#### Syntax
```
procedure PutBlobBlockBlobStream(BlobName: Text; var SourceStream: InStream; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
```
#### Parameters
*BlobName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the blob.

*SourceStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The Content of the Blob as InStream.

*OptionalParameters ([Codeunit "ABS Optional Parameters"]())* 

Optional parameters to pass.

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### PutBlobBlockBlobText (Method) <a name="PutBlobBlockBlobText"></a> 

 Uploads text as a BlockBlob.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
 

#### Syntax
```
procedure PutBlobBlockBlobText(BlobName: Text; SourceText: Text): Codeunit "ABS Operation Response"
```
#### Parameters
*BlobName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the blob.

*SourceText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Content of the Blob as Text.

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### PutBlobBlockBlobText (Method) <a name="PutBlobBlockBlobText"></a> 

 Uploads text as a BlockBlob.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
 

#### Syntax
```
procedure PutBlobBlockBlobText(BlobName: Text; SourceText: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
```
#### Parameters
*BlobName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the blob.

*SourceText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Content of the Blob as Text.

*OptionalParameters ([Codeunit "ABS Optional Parameters"]())* 

Optional parameters to pass.

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### PutBlobPageBlob (Method) <a name="PutBlobPageBlob"></a> 

 Creates a PageBlob.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
 

#### Syntax
```
procedure PutBlobPageBlob(BlobName: Text; ContentType: Text): Codeunit "ABS Operation Response"
```
#### Parameters
*BlobName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the blob.

*ContentType ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Value for Content-Type HttpHeader (e.g. 'text/plain; charset=UTF-8')

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### PutBlobPageBlob (Method) <a name="PutBlobPageBlob"></a> 

 Creates a PageBlob.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
 

#### Syntax
```
procedure PutBlobPageBlob(BlobName: Text; ContentType: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
```
#### Parameters
*BlobName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the blob.

*ContentType ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Value for Content-Type HttpHeader (e.g. 'text/plain; charset=UTF-8')

*OptionalParameters ([Codeunit "ABS Optional Parameters"]())* 

Optional parameters to pass.

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### PutBlobAppendBlobStream (Method) <a name="PutBlobAppendBlobStream"></a> 

 The Put Blob operation creates a new append blob
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
 Uses 'application/octet-stream' as Content-Type
 

#### Syntax
```
procedure PutBlobAppendBlobStream(BlobName: Text): Codeunit "ABS Operation Response"
```
#### Parameters
*BlobName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the blob.

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### PutBlobAppendBlobStream (Method) <a name="PutBlobAppendBlobStream"></a> 

 The Put Blob operation creates a new append blob
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
 Uses 'application/octet-stream' as Content-Type
 

#### Syntax
```
procedure PutBlobAppendBlobStream(BlobName: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
```
#### Parameters
*BlobName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the blob.

*OptionalParameters ([Codeunit "ABS Optional Parameters"]())* 

Optional parameters to pass.

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### PutBlobAppendBlobText (Method) <a name="PutBlobAppendBlobText"></a> 

 The Put Blob operation creates a new append blob
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
 Uses 'text/plain; charset=UTF-8' as Content-Type
 

#### Syntax
```
procedure PutBlobAppendBlobText(BlobName: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
```
#### Parameters
*BlobName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the blob.

*OptionalParameters ([Codeunit "ABS Optional Parameters"]())* 

Optional parameters to pass.

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### PutBlobAppendBlob (Method) <a name="PutBlobAppendBlob"></a> 

 The Put Blob operation creates a new append blob
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-blob
 

#### Syntax
```
procedure PutBlobAppendBlob(BlobName: Text; ContentType: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
```
#### Parameters
*BlobName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the blob.

*ContentType ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Value for Content-Type HttpHeader (e.g. 'text/plain; charset=UTF-8')

*OptionalParameters ([Codeunit "ABS Optional Parameters"]())* 

Optional parameters to pass.

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### AppendBlockText (Method) <a name="AppendBlockText"></a> 

 The Append Block operation commits a new block of data to the end of an existing append blob.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/append-block
 Uses 'text/plain; charset=UTF-8' as Content-Type
 

#### Syntax
```
procedure AppendBlockText(BlobName: Text; ContentAsText: Text): Codeunit "ABS Operation Response"
```
#### Parameters
*BlobName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the blob.

*ContentAsText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Text-variable containing the content that should be added to the Blob

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### AppendBlockText (Method) <a name="AppendBlockText"></a> 

 The Append Block operation commits a new block of data to the end of an existing append blob.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/append-block
 

#### Syntax
```
procedure AppendBlockText(BlobName: Text; ContentAsText: Text; ContentType: Text): Codeunit "ABS Operation Response"
```
#### Parameters
*BlobName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the blob.

*ContentAsText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Text-variable containing the content that should be added to the Blob

*ContentType ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Value for Content-Type HttpHeader (e.g. 'text/plain; charset=UTF-8')

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### AppendBlockText (Method) <a name="AppendBlockText"></a> 

 The Append Block operation commits a new block of data to the end of an existing append blob.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/append-block
 

#### Syntax
```
procedure AppendBlockText(BlobName: Text; ContentAsText: Text; ContentType: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
```
#### Parameters
*BlobName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the blob.

*ContentAsText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Text-variable containing the content that should be added to the Blob

*ContentType ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Value for Content-Type HttpHeader (e.g. 'text/plain; charset=UTF-8')

*OptionalParameters ([Codeunit "ABS Optional Parameters"]())* 

Optional parameters to pass.

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### AppendBlockStream (Method) <a name="AppendBlockStream"></a> 

 The Append Block operation commits a new block of data to the end of an existing append blob.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/append-block
 Uses 'application/octet-stream' as Content-Type
 

#### Syntax
```
procedure AppendBlockStream(BlobName: Text; ContentAsStream: InStream): Codeunit "ABS Operation Response"
```
#### Parameters
*BlobName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the blob.

*ContentAsStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

InStream containing the content that should be added to the Blob

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### AppendBlockStream (Method) <a name="AppendBlockStream"></a> 

 The Append Block operation commits a new block of data to the end of an existing append blob.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/append-block
 

#### Syntax
```
procedure AppendBlockStream(BlobName: Text; ContentAsStream: InStream; ContentType: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
```
#### Parameters
*BlobName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the blob.

*ContentAsStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

InStream containing the content that should be added to the Blob

*ContentType ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Value for Content-Type HttpHeader (e.g. 'text/plain; charset=UTF-8')

*OptionalParameters ([Codeunit "ABS Optional Parameters"]())* 



#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### AppendBlock (Method) <a name="AppendBlock"></a> 

 The Append Block operation commits a new block of data to the end of an existing append blob.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/append-block
 

#### Syntax
```
procedure AppendBlock(BlobName: Text; ContentType: Text; SourceContent: Variant; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
```
#### Parameters
*BlobName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the blob.

*ContentType ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Value for Content-Type HttpHeader (e.g. 'text/plain; charset=UTF-8')

*SourceContent ([Variant](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/variant/variant-data-type))* 

Variant containing the content that should be added to the Blob

*OptionalParameters ([Codeunit "ABS Optional Parameters"]())* 

Optional parameters to pass.

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### AppendBlockFromURL (Method) <a name="AppendBlockFromURL"></a> 

 The Append Block From URL operation commits a new block of data to the end of an existing append blob.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/append-block-from-url
 

#### Syntax
```
procedure AppendBlockFromURL(BlobName: Text; SourceUri: Text): Codeunit "ABS Operation Response"
```
#### Parameters
*BlobName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the blob.

*SourceUri ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Specifies the name of the source blob.

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### AppendBlockFromURL (Method) <a name="AppendBlockFromURL"></a> 

 The Append Block From URL operation commits a new block of data to the end of an existing append blob.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/append-block-from-url
 

#### Syntax
```
procedure AppendBlockFromURL(BlobName: Text; SourceUri: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
```
#### Parameters
*BlobName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the blob.

*SourceUri ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Specifies the name of the source blob.

*OptionalParameters ([Codeunit "ABS Optional Parameters"]())* 

Optional parameters to pass.

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### GetBlobAsFile (Method) <a name="GetBlobAsFile"></a> 

 Receives a Blob as a File from a Container.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-blob
 

#### Syntax
```
procedure GetBlobAsFile(BlobName: Text): Codeunit "ABS Operation Response"
```
#### Parameters
*BlobName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the blob.

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### GetBlobAsFile (Method) <a name="GetBlobAsFile"></a> 

 Receives a Blob as a File from a Container.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-blob
 

#### Syntax
```
procedure GetBlobAsFile(BlobName: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
```
#### Parameters
*BlobName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the blob.

*OptionalParameters ([Codeunit "ABS Optional Parameters"]())* 

Optional parameters to pass.

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### GetBlobAsStream (Method) <a name="GetBlobAsStream"></a> 

 Receives a Blob as a InStream from a Container.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-blob
 

#### Syntax
```
procedure GetBlobAsStream(BlobName: Text; var TargetStream: InStream): Codeunit "ABS Operation Response"
```
#### Parameters
*BlobName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the blob.

*TargetStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The result InStream containg the content of the Blob.

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### GetBlobAsStream (Method) <a name="GetBlobAsStream"></a> 

 Receives a Blob as a InStream from a Container.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-blob
 

#### Syntax
```
procedure GetBlobAsStream(BlobName: Text; var TargetStream: InStream; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
```
#### Parameters
*BlobName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the blob.

*TargetStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The result InStream containg the content of the Blob.

*OptionalParameters ([Codeunit "ABS Optional Parameters"]())* 

Optional parameters to pass.

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### GetBlobAsText (Method) <a name="GetBlobAsText"></a> 

 Receives a Blob as Text from a Container.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-blob
 

#### Syntax
```
procedure GetBlobAsText(BlobName: Text; var TargetText: Text): Codeunit "ABS Operation Response"
```
#### Parameters
*BlobName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the blob.

*TargetText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The result Text containg the content of the Blob.

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### GetBlobAsText (Method) <a name="GetBlobAsText"></a> 

 Receives a Blob as Text from a Container.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/get-blob
 

#### Syntax
```
procedure GetBlobAsText(BlobName: Text; var TargetText: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
```
#### Parameters
*BlobName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the blob.

*TargetText ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The result Text containg the content of the Blob.

*OptionalParameters ([Codeunit "ABS Optional Parameters"]())* 

Optional parameters to pass.

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### SetBlobExpiryRelativeToCreation (Method) <a name="SetBlobExpiryRelativeToCreation"></a> 

 The Set Blob Expiry operation sets an expiry time on an existing blob. This operation is only allowed on Hierarchical Namespace enabled accounts
 Sets the expiry time relative to the file creation time, x-ms-expiry-time must be specified as the number of milliseconds to elapse from creation time.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/set-blob-expiry
 

#### Syntax
```
procedure SetBlobExpiryRelativeToCreation(BlobName: Text; ExpiryTime: Integer): Codeunit "ABS Operation Response"
```
#### Parameters
*BlobName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the blob.

*ExpiryTime ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Number if miliseconds (Integer) until the expiration.

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### SetBlobExpiryRelativeToNow (Method) <a name="SetBlobExpiryRelativeToNow"></a> 

 The Set Blob Expiry operation sets an expiry time on an existing blob. This operation is only allowed on Hierarchical Namespace enabled accounts
 Sets the expiry relative to the current time, x-ms-expiry-time must be specified as the number of milliseconds to elapse from now.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/set-blob-expiry
 

#### Syntax
```
procedure SetBlobExpiryRelativeToNow(BlobName: Text; ExpiryTime: Integer): Codeunit "ABS Operation Response"
```
#### Parameters
*BlobName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the blob.

*ExpiryTime ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Number if miliseconds (Integer) until the expiration.

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### SetBlobExpiryAbsolute (Method) <a name="SetBlobExpiryAbsolute"></a> 

 The Set Blob Expiry operation sets an expiry time on an existing blob. This operation is only allowed on Hierarchical Namespace enabled accounts
 Sets the expiry to an absolute DateTime
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/set-blob-expiry
 

#### Syntax
```
procedure SetBlobExpiryAbsolute(BlobName: Text; ExpiryTime: DateTime): Codeunit "ABS Operation Response"
```
#### Parameters
*BlobName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the blob.

*ExpiryTime ([DateTime](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/datetime/datetime-data-type))* 

Absolute DateTime for the expiration.

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### SetBlobExpiryNever (Method) <a name="SetBlobExpiryNever"></a> 

 The Set Blob Expiry operation sets an expiry time on an existing blob. This operation is only allowed on Hierarchical Namespace enabled accounts
 Sets the file to never expire or removes the current expiry time, x-ms-expiry-time must not to be specified.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/set-blob-expiry
 

#### Syntax
```
procedure SetBlobExpiryNever(BlobName: Text): Codeunit "ABS Operation Response"
```
#### Parameters
*BlobName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 



#### Return Value
*[Codeunit "ABS Operation Response"]()*


### SetBlobTags (Method) <a name="SetBlobTags"></a> 

 The Set Blob Tags operation sets user-defined tags for the specified blob as one or more key-value pairs.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/set-blob-tags
 

#### Syntax
```
procedure SetBlobTags(BlobName: Text; Tags: Dictionary of [Text, Text]): Codeunit "ABS Operation Response"
```
#### Parameters
*BlobName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the blob.

*Tags ([Dictionary of [Text, Text]]())* 

A Dictionary of [Text, Text] which contains the Tags you want to set.

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### DeleteBlob (Method) <a name="DeleteBlob"></a> 

 The Delete Blob operation marks the specified blob or snapshot for deletion. The blob is later deleted during garbage collection.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/delete-blob
 

#### Syntax
```
procedure DeleteBlob(BlobName: Text): Codeunit "ABS Operation Response"
```
#### Parameters
*BlobName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the blob.

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### DeleteBlob (Method) <a name="DeleteBlob"></a> 

 The Delete Blob operation marks the specified blob or snapshot for deletion. The blob is later deleted during garbage collection.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/delete-blob
 

#### Syntax
```
procedure DeleteBlob(BlobName: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
```
#### Parameters
*BlobName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the blob.

*OptionalParameters ([Codeunit "ABS Optional Parameters"]())* 

Optional parameters to pass.

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### UndeleteBlob (Method) <a name="UndeleteBlob"></a> 

 The Undelete Blob operation restores the contents and metadata of a soft deleted blob and any associated soft deleted snapshots (version 2017-07-29 or later)
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/undelete-blob
 

#### Syntax
```
procedure UndeleteBlob(BlobName: Text): Codeunit "ABS Operation Response"
```
#### Parameters
*BlobName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the blob.

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### UndeleteBlob (Method) <a name="UndeleteBlob"></a> 

 The Undelete Blob operation restores the contents and metadata of a soft deleted blob and any associated soft deleted snapshots (version 2017-07-29 or later)
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/undelete-blob
 

#### Syntax
```
procedure UndeleteBlob(BlobName: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
```
#### Parameters
*BlobName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the blob.

*OptionalParameters ([Codeunit "ABS Optional Parameters"]())* 

Optional parameters to pass.

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### CopyBlob (Method) <a name="CopyBlob"></a> 

 The Copy Blob operation copies a blob to a destination within the storage account.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/copy-blob
 

#### Syntax
```
procedure CopyBlob(BlobName: Text; SourceName: Text): Codeunit "ABS Operation Response"
```
#### Parameters
*BlobName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the blob.

*SourceName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Specifies the name of the source blob or file.

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### CopyBlob (Method) <a name="CopyBlob"></a> 

 The Copy Blob operation copies a blob to a destination within the storage account.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/copy-blob
 

#### Syntax
```
procedure CopyBlob(BlobName: Text; SourceName: Text; LeaseId: Guid; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
```
#### Parameters
*BlobName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the blob.

*SourceName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Specifies the name of the source blob or file.

*LeaseId ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

Required if the destination blob has an active lease. The lease ID specified must match the lease ID of the destination blob.

*OptionalParameters ([Codeunit "ABS Optional Parameters"]())* 

Optional parameters to pass.

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### PutBlockList (Method) <a name="PutBlockList"></a> 

 The Put Block List operation writes a blob by specifying the list of block IDs that make up the blob.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-block-list
 

#### Syntax
```
procedure PutBlockList(CommitedBlocks: Dictionary of [Text, Integer]; UncommitedBlocks: Dictionary of [Text, Integer]): Codeunit "ABS Operation Response"
```
#### Parameters
*CommitedBlocks ([Dictionary of [Text, Integer]]())* 

Dictionary of [Text, Integer] containing the list of commited blocks that should be put to the Blob

*UncommitedBlocks ([Dictionary of [Text, Integer]]())* 

Dictionary of [Text, Integer] containing the list of uncommited blocks that should be put to the Blob

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### PutBlockFromURL (Method) <a name="PutBlockFromURL"></a> 

 The Put Block From URL operation creates a new block to be committed as part of a blob where the contents are read from a URL.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-block-from-url
 

#### Syntax
```
procedure PutBlockFromURL(BlobName: Text; SourceUri: Text; BlockId: Text): Codeunit "ABS Operation Response"
```
#### Parameters
*BlobName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the blob.

*SourceUri ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Specifies the name of the source block blob.

*BlockId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Specifies the BlockId that should be put.

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### PutBlockFromURL (Method) <a name="PutBlockFromURL"></a> 

 The Put Block From URL operation creates a new block to be committed as part of a blob where the contents are read from a URL.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/put-block-from-url
 

#### Syntax
```
procedure PutBlockFromURL(BlobName: Text; SourceUri: Text; BlockId: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
```
#### Parameters
*BlobName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the blob.

*SourceUri ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Specifies the name of the source block blob.

*BlockId ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Specifies the BlockId that should be put.

*OptionalParameters ([Codeunit "ABS Optional Parameters"]())* 

Optional parameters to pass.

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object

## ABS Container Client (Codeunit 9052)

 Provides functionality to use operations on containers in Azure BLOB Services.
 

### Initialize (Method) <a name="Initialize"></a> 

 Initializes the Azure BLOB Storage container client.
 

#### Syntax
```
[NonDebuggable]
procedure Initialize(StorageAccount: Text; Authorization: Interface "Storage Service Authorization")
```
#### Parameters
*StorageAccount ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of Storage Account to use.

*Authorization ([Interface "Storage Service Authorization"]())* 

The authorization to use.

### Initialize (Method) <a name="Initialize"></a> 

 Initializes the Azure BLOB Storage container client.
 

#### Syntax
```
[NonDebuggable]
procedure Initialize(StorageAccount: Text; Authorization: Interface "Storage Service Authorization"; ApiVersion: Enum "Storage Service API Version")
```
#### Parameters
*StorageAccount ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The Storage Account to use.

*Authorization ([Interface "Storage Service Authorization"]())* 



*ApiVersion ([Enum "Storage Service API Version"]())* 

The API version to use.

### SetBaseUrl (Method) <a name="SetBaseUrl"></a> 

 The base URL to use when constructing the final URI.
 If not set, the base URL is https://%1.blob.core.windows.net where %1 is the storage account name.
 

Use %1 as a placeholder for the storage account name.

#### Syntax
```
procedure SetBaseUrl(BaseUrl: Text)
```
#### Parameters
*BaseUrl ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A valid URL string

### ListContainers (Method) <a name="ListContainers"></a> 

 List all containers in specific Storage Account.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/list-containers2
 

#### Syntax
```
procedure ListContainers(var Containers: Record "ABS Container"): Codeunit "ABS Operation Response"
```
#### Parameters
*Containers ([Record "ABS Container"]())* 



#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### ListContainers (Method) <a name="ListContainers"></a> 

 List all containers in specific Storage Account.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/list-containers2
 

#### Syntax
```
procedure ListContainers(var Containers: Record "ABS Container"; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
```
#### Parameters
*Containers ([Record "ABS Container"]())* 



*OptionalParameters ([Codeunit "ABS Optional Parameters"]())* 

Optional parameters to pass.

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### CreateContainer (Method) <a name="CreateContainer"></a> 

 Creates a new container in the Storage Account.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/create-container
 

#### Syntax
```
procedure CreateContainer(ContainerName: Text): Codeunit "ABS Operation Response"
```
#### Parameters
*ContainerName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the container.

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### CreateContainer (Method) <a name="CreateContainer"></a> 

 Creates a new container in the Storage Account.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/create-container
 

#### Syntax
```
procedure CreateContainer(ContainerName: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
```
#### Parameters
*ContainerName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the container to create.

*OptionalParameters ([Codeunit "ABS Optional Parameters"]())* 

Optional parameters to pass.

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### DeleteContainer (Method) <a name="DeleteContainer"></a> 

 Deletes a container from the Storage Account.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/delete-container
 

#### Syntax
```
procedure DeleteContainer(ContainerName: Text): Codeunit "ABS Operation Response"
```
#### Parameters
*ContainerName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the container.

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object
### DeleteContainer (Method) <a name="DeleteContainer"></a> 

 Deletes a container from the Storage Account.
 see: https://docs.microsoft.com/en-us/rest/api/storageservices/delete-container
 

#### Syntax
```
procedure DeleteContainer(ContainerName: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
```
#### Parameters
*ContainerName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the container to delete.

*OptionalParameters ([Codeunit "ABS Optional Parameters"]())* 

Optional parameters to pass.

#### Return Value
*[Codeunit "ABS Operation Response"]()*

An operation reponse object

## ABS Operation Response (Codeunit 9050)

 Holder object for holding for ABS client operations result.
 

### IsSuccessful (Method) <a name="IsSuccessful"></a> 

 Checks whether the operation was successful.
 

#### Syntax
```
procedure IsSuccessful(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the operation was successful; otherwise - false.
### GetError (Method) <a name="GetError"></a> 

 Gets the error (if any) of the response.
 

#### Syntax
```
procedure GetError(): Text
```
#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

Text representation of the error that occurred during the operation.

## ABS Optional Parameters (Codeunit 9047)

 Holder for the optional Azure Blob Storage HTTP headers and URL parameters.
 

### LeaseId (Method) <a name="LeaseId"></a> 

 Sets the value for 'x-ms-lease-id' HttpHeader for a request.
 

#### Syntax
```
procedure LeaseId("Value": Guid)
```
#### Parameters
*Value ([Guid](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/guid/guid-data-type))* 

Guid value specifying the LeaseID

### SourceLeaseId (Method) <a name="SourceLeaseId"></a> 

 Sets the value for 'x-ms-source-lease-id' HttpHeader for a request.
 

#### Syntax
```
procedure SourceLeaseId("Value": Text)
```
#### Parameters
*Value ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Text value specifying the source LeaseID

### Origin (Method) <a name="Origin"></a> 

 Sets the value for 'Origin' HttpHeader for a request.
 

#### Syntax
```
procedure Origin("Value": Text)
```
#### Parameters
*Value ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Text value specifying the HttpHeader value

### AccessControlRequestMethod (Method) <a name="AccessControlRequestMethod"></a> 

 Sets the value for 'Access-Control-Request-Method' HttpHeader for a request.
 

#### Syntax
```
procedure AccessControlRequestMethod("Value": Enum "Http Request Type")
```
#### Parameters
*Value ([Enum "Http Request Type"]())* 

Text value specifying the HttpHeader value

### AccessControlRequestHeaders (Method) <a name="AccessControlRequestHeaders"></a> 

 Sets the value for 'Access-Control-Request-Headers' HttpHeader for a request.
 

#### Syntax
```
procedure AccessControlRequestHeaders("Value": Text)
```
#### Parameters
*Value ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Text value specifying the HttpHeader value

### ClientRequestId (Method) <a name="ClientRequestId"></a> 

 Sets the value for 'x-ms-client-request-id' HttpHeader for a request.
 

#### Syntax
```
procedure ClientRequestId("Value": Text)
```
#### Parameters
*Value ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Text value specifying the HttpHeader value

### BlobPublicAccess (Method) <a name="BlobPublicAccess"></a> 

 Sets the value for 'x-ms-blob-public-access' HttpHeader for a request.
 

#### Syntax
```
procedure BlobPublicAccess("Value": Enum "ABS Blob Public Access")
```
#### Parameters
*Value ([Enum "ABS Blob Public Access"]())* 

Enum "Blob Public Access" value specifying the HttpHeader value

### Metadata (Method) <a name="Metadata"></a> 

 Sets the value for 'x-ms-meta-[MetaName]' HttpHeader for a request.
 

#### Syntax
```
procedure Metadata(MetaName: Text; "Value": Text)
```
#### Parameters
*MetaName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the Metadata-value.

*Value ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Text value specifying the Metadata value

### TagsValue (Method) <a name="TagsValue"></a> 

 Sets the value for 'x-ms-tags' HttpHeader for a request.
 

#### Syntax
```
procedure TagsValue("Value": Text)
```
#### Parameters
*Value ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Text value specifying the HttpHeader value

### SourceIfModifiedSince (Method) <a name="SourceIfModifiedSince"></a> 

 Sets the value for 'x-ms-source-if-modified-since' HttpHeader for a request.
 

#### Syntax
```
procedure SourceIfModifiedSince("Value": DateTime)
```
#### Parameters
*Value ([DateTime](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/datetime/datetime-data-type))* 

DateTime value specifying the HttpHeader value

### SourceIfUnmodifiedSince (Method) <a name="SourceIfUnmodifiedSince"></a> 

 Sets the value for 'x-ms-source-if-unmodified-since' HttpHeader for a request.
 

#### Syntax
```
procedure SourceIfUnmodifiedSince("Value": DateTime)
```
#### Parameters
*Value ([DateTime](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/datetime/datetime-data-type))* 

DateTime value specifying the HttpHeader value

### SourceIfMatch (Method) <a name="SourceIfMatch"></a> 

 Sets the value for 'x-ms-source-if-match' HttpHeader for a request.
 

#### Syntax
```
procedure SourceIfMatch("Value": Text)
```
#### Parameters
*Value ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Text value specifying the HttpHeader value

### SourceIfNoneMatch (Method) <a name="SourceIfNoneMatch"></a> 

 Sets the value for 'x-ms-source-if-none-match' HttpHeader for a request.
 

#### Syntax
```
procedure SourceIfNoneMatch("Value": Text)
```
#### Parameters
*Value ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Text value specifying the HttpHeader value

### CopySourceName (Method) <a name="CopySourceName"></a> 

 Sets the value for 'x-ms-copy-source' HttpHeader for a request.
 

#### Syntax
```
procedure CopySourceName("Value": Text)
```
#### Parameters
*Value ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Text value specifying the HttpHeader value

### RehydratePriority (Method) <a name="RehydratePriority"></a> 

 Sets the value for 'x-ms-rehydrate-priority' HttpHeader for a request.
 

#### Syntax
```
procedure RehydratePriority("Value": Enum "ABS Rehydrate Priority")
```
#### Parameters
*Value ([Enum "ABS Rehydrate Priority"]())* 

Enum "Rehydrate Priority" value specifying the HttpHeader value

### BlobExpiryOption (Method) <a name="BlobExpiryOption"></a> 

 Sets the value for 'x-ms-expiry-option' HttpHeader for a request.
 

#### Syntax
```
procedure BlobExpiryOption("Value": Enum "ABS Blob Expiry Option")
```
#### Parameters
*Value ([Enum "ABS Blob Expiry Option"]())* 

Enum "Blob Expiry Option" value specifying the HttpHeader value

### BlobExpiryTime (Method) <a name="BlobExpiryTime"></a> 

 Sets the value for 'x-ms-expiry-time' HttpHeader for a request.
 

#### Syntax
```
procedure BlobExpiryTime("Value": Integer)
```
#### Parameters
*Value ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Integer value specifying the HttpHeader value

### BlobExpiryTime (Method) <a name="BlobExpiryTime"></a> 

 Sets the value for 'x-ms-expiry-time' HttpHeader for a request.
 

#### Syntax
```
procedure BlobExpiryTime("Value": DateTime)
```
#### Parameters
*Value ([DateTime](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/datetime/datetime-data-type))* 

DateTime value specifying the HttpHeader value

### BlobAccessTier (Method) <a name="BlobAccessTier"></a> 

 Sets the value for 'x-ms-access-tier' HttpHeader for a request.
 

#### Syntax
```
procedure BlobAccessTier("Value": Enum "ABS Blob Access Tier")
```
#### Parameters
*Value ([Enum "ABS Blob Access Tier"]())* 

Enum "Blob Access Tier" value specifying the HttpHeader value

### Range (Method) <a name="Range"></a> 

 Sets the value for 'x-ms-range' HttpHeader for a request.
 

#### Syntax
```
procedure Range(BytesStartValue: Integer; BytesEndValue: Integer)
```
#### Parameters
*BytesStartValue ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Integer value specifying the Bytes start range value

*BytesEndValue ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Integer value specifying the Bytes end range value

### SourceRange (Method) <a name="SourceRange"></a> 

 Sets the value for 'x-ms-source-range' HttpHeader for a request.
 

#### Syntax
```
procedure SourceRange(BytesStartValue: Integer; BytesEndValue: Integer)
```
#### Parameters
*BytesStartValue ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Integer value specifying the Bytes start range value

*BytesEndValue ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Integer value specifying the Bytes end range value

### RequiresSync (Method) <a name="RequiresSync"></a> 

 Sets the value for 'x-ms-requires-sync' HttpHeader for a request.
 

#### Syntax
```
procedure RequiresSync("Value": Boolean)
```
#### Parameters
*Value ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Boolean value specifying the HttpHeader value

### Timeout (Method) <a name="Timeout"></a> 

 Sets the optional timeout value for the request.
 

#### Syntax
```
procedure Timeout("Value": Integer)
```
#### Parameters
*Value ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Timeout in seconds. Most operations have a max. limit of 30 seconds. For more Information see: https://docs.microsoft.com/en-us/rest/api/storageservices/setting-timeouts-for-blob-service-operations

### VersionId (Method) <a name="VersionId"></a> 

 The versionid parameter is an opaque DateTime value that, when present, specifies the Version of the blob to retrieve.
 

#### Syntax
```
procedure VersionId("Value": DateTime)
```
#### Parameters
*Value ([DateTime](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/datetime/datetime-data-type))* 

The DateTime identifying the version

### Snapshot (Method) <a name="Snapshot"></a> 

 The snapshot parameter is an opaque DateTime value that, when present, specifies the blob snapshot to retrieve.
 

#### Syntax
```
procedure Snapshot("Value": DateTime)
```
#### Parameters
*Value ([DateTime](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/datetime/datetime-data-type))* 

The DateTime identifying the Snapshot

### Snapshot (Method) <a name="Snapshot"></a> 

 The snapshot parameter is an opaque DateTime value that, when present, specifies the blob snapshot to retrieve.
 

#### Syntax
```
procedure Snapshot("Value": Text)
```
#### Parameters
*Value ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The DateTime identifying the Snapshot

### Prefix (Method) <a name="Prefix"></a> 

 Filters the results to return only blobs whose names begin with the specified prefix.
 

#### Syntax
```
procedure Prefix("Value": Text)
```
#### Parameters
*Value ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Prefix to search for

### Delimiter (Method) <a name="Delimiter"></a> 

 When the request includes this parameter, the operation returns a BlobPrefix element in the response body
 that acts as a placeholder for all blobs with names that begin with the same substring until the delimiter character is reached.
 The delimiter may be a single character or a string.
 

#### Syntax
```
procedure Delimiter("Value": Text)
```
#### Parameters
*Value ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

Delimiting character/string

### MaxResults (Method) <a name="MaxResults"></a> 

 Specifies the maximum number of blobs to return
 

#### Syntax
```
procedure MaxResults("Value": Integer)
```
#### Parameters
*Value ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Max. number of results to return. Must be positive, must not be greater than 5000

### BlockId (Method) <a name="BlockId"></a> 

 Identifiers the ID of a Block in BlockBlob
 

#### Syntax
```
procedure BlockId("Value": Text)
```
#### Parameters
*Value ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

A valid Base64 string value that identifies the block. Prior to encoding, the string must be less than or equal to 64 bytes


## ABS Blob Access Tier (Enum 9042)

 Azure storage offers different access tiers.
 Azure Blog storage offers access tiers that let you manage the cost of storing large amounts of unstructured data, such as text or binary data.allowing you to store blob object data in the most cost-effective manner.
 See: https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blob-storage-tiers
 

### Hot (value: 0)


 Optimized for storing data that is accessed frequently.
 

### Cool (value: 1)


 Optimized for storing data that is infrequently accessed and stored for at least 30 days.
 

### Archive (value: 3)


 Optimized for storing data that is rarely accessed and stored for at least 180 days with flexible latency requirements, on the order of hours.
 


## ABS Blob Public Access (Enum 9043)

 Indicator of whether data in the container may be accessed publicly and the level of access.
 

### Container (value: 0)


  Indicates full public read access for container and blob data. Clients can use anonymous requests to enumerate blobs in the container, but cannot enumerate containers in the storage account.
 

### Blob (value: 1)


Indicates public read access to blob data in this container. The blob data can be read via anonymous request, but container data is not available. Clients cannot enumerate blobs in the container via anonymous request.
 


## ABS Block List Type (Enum 9044)

 Specifies whether to return the list of committed blocks, the list of uncommitted blocks, or both lists together
 

### Committed (value: 0)

### Uncommitted (value: 1)

### All (value: 2)


## ABS Rehydrate Priority (Enum 9046)

 Indicates the priority with which to rehydrate an archived blob.
 The priority can be set on a blob only one time. This header will be ignored on subsequent requests to the same blob. The default priority without this header is Standard.
 

### Standard (value: 0)


 Standard priority. Default value.
 

### High (value: 1)


 High priority
 

