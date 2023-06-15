This module provides functionality to work with files and directories from Azure File Share Services.

# Public Objects

## AFS Handle

Holds information about file handles that are currently open.

### Object Definition

<table>
<tr><td><b>Object Type</b></td><td>Table</td></tr>
<tr><td><b>Object ID</b></td><td>8951</td></tr>
<tr><td><b>Object Name</b></td><td>AFS Handle</td></tr>
</table>

### Fields

| Number | Name | Type |
| ---- | ------- | ----------- |
| 1 | Entry No. | Integer |
| 10 | Handle ID | Text[50] |
| 11 | Path | Text[2048] |
| 12 | Client IP | Text[2048] |
| 13 | Open Time | DateTime |
| 14 | Last Reconnect Time | DateTime |
| 15 | File ID | Text[50] |
| 16 | Parent ID | Text[50] |
| 17 | Session ID | Text[50] |
| 20 | Next Marker | Text[2048] |

## AFS Directory Content

Holds information about directory content in a storage account.

### Object Definition

<table>
<tr><td><b>Object Type</b></td><td>Table</td></tr>
<tr><td><b>Object ID</b></td><td>8950</td></tr>
<tr><td><b>Object Name</b></td><td>AFS Directory Content</td></tr>
</table>

### Fields

| Number | Name | Type |
| ---- | ------- | ----------- |
| 1 | Entry No. | Integer |
| 2 | Parent Directory | Text[2048] |
| 3 | Level | Integer |
| 4 | Full Name | Text[2048] |
| 10 | Name | Text[2048] |
| 11 | Creation Time | DateTime |
| 12 | Last Modified | DateTime |
| 13 | Content Length | Integer |
| 14 | Last Access Time | DateTime |
| 15 | Change Time | DateTime |
| 16 | Resource Type | Enum "AFS File Resource Type" |
| 17 | Etag | Text[200] |
| 18 | Archive | Boolean |
| 19 | Hidden | Boolean |
| 20 | Last Write Time | DateTime |
| 21 | Read Only | Boolean |
| 22 | Permission Key | Text[200] |
| 100 | XML Value | Blob |
| 110 | URI | Text[2048] |


## AFS File Client


Provides functionality to access the Azure File Storage.

### Properties

| Property | Value |
| --- | --- |
| Object Type | Codeunit |
| Object Subtype | Normal |
| Object ID | 8950 |
| Accessibility Level | Public | 

### Procedures

#### `Initialize()`

Initializes the AFS Client.


##### Syntax

```al
Initialize(StorageAccount: Text, FileShare: Text, Authorization: Interface "Storage Service Authorization")
```

##### Parameters

*StorageAccount*<br>
&emsp;Type: Text <br>

The name of the storage account to use.

*FileShare*<br>
&emsp;Type: Text <br>

The name of the file share to use.

*Authorization*<br>
&emsp;Type: Interface  "Storage Service Authorization"<br>

The authorization to use.


#### `Initialize()`

Initializes the AFS Client.


##### Syntax

```al
Initialize(StorageAccount: Text, FileShare: Text, Authorization: Interface "Storage Service Authorization", APIVersion: Enum "Storage Service API Version")
```

##### Parameters

*StorageAccount*<br>
&emsp;Type: Text <br>

The name of the storage account to use.

*FileShare*<br>
&emsp;Type: Text <br>

The name of the file share to use.

*Authorization*<br>
&emsp;Type: Interface  "Storage Service Authorization"<br>

The authorization to use.

*APIVersion*<br>
&emsp;Type: Enum  "Storage Service API Version"<br>

The API Version to use.


#### `CreateFile()`

Creates a file in the file share.
This does not fill in the file content, it only initializes the file.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := CreateFile(FilePath: Text, InStream: InStream)
```

##### Parameters

*FilePath*<br>
&emsp;Type: Text <br>

The path where the file will be created.

*InStream*<br>
&emsp;Type: InStream <br>

The file content, only used to check file size.


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation response object.

#### `CreateFile()`

Creates a file in the file share.
This does not fill in the file content, it only initializes the file.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := CreateFile(FilePath: Text, InStream: InStream, AFSOptionalParameters: Codeunit "AFS Optional Parameters")
```

##### Parameters

*FilePath*<br>
&emsp;Type: Text <br>

The path where the file will be created.

*InStream*<br>
&emsp;Type: InStream <br>

The file content, only used to check file size.

*AFSOptionalParameters*<br>
&emsp;Type: Codeunit  "AFS Optional Parameters"<br>

Optional parameters to pass with the request.


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation response object.

#### `CreateFile()`

Creates a file in the file share.
This does not fill in the file content, it only initializes the file.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := CreateFile(FilePath: Text, FileSize: Integer)
```

##### Parameters

*FilePath*<br>
&emsp;Type: Text <br>

The path where the file will be created.

*FileSize*<br>
&emsp;Type: Integer <br>

The size of the file to initialize, in bytes.


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation response object.

#### `CreateFile()`

Creates a file in the file share.
This does not fill in the file content, it only initializes the file.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := CreateFile(FilePath: Text, FileSize: Integer, AFSOptionalParameters: Codeunit "AFS Optional Parameters")
```

##### Parameters

*FilePath*<br>
&emsp;Type: Text <br>

The path where the file will be created.

*FileSize*<br>
&emsp;Type: Integer <br>

The size of the file to initialize, in bytes.

*AFSOptionalParameters*<br>
&emsp;Type: Codeunit  "AFS Optional Parameters"<br>

Optional parameters to pass with the request.


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation response object.

#### `GetFileAsFile()`

Receives a file as a File from a file share.
The file will be downloaded through the browser.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := GetFileAsFile(FilePath: Text)
```

##### Parameters

*FilePath*<br>
&emsp;Type: Text <br>

The path to the file.


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation response object

#### `GetFileAsFile()`

Receives a file as a File from a file share.
The file will be downloaded through the browser.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := GetFileAsFile(FilePath: Text, AFSOptionalParameters: Codeunit "AFS Optional Parameters")
```

##### Parameters

*FilePath*<br>
&emsp;Type: Text <br>

The path to the file.

*AFSOptionalParameters*<br>
&emsp;Type: Codeunit  "AFS Optional Parameters"<br>

Optional parameters to pass with the request.


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation response object

#### `GetFileAsStream()`

Receives a file as a stream from a file share.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := GetFileAsStream(FilePath: Text, var TargetInStream: InStream)
```

##### Parameters

*FilePath*<br>
&emsp;Type: Text <br>

The path to the file.

*TargetInStream*<br>
&emsp;Type: InStream <br>

The result instream containing the content of the file.


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation response object

#### `GetFileAsStream()`

Receives a file as a stream from a file share.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := GetFileAsStream(FilePath: Text, var TargetInStream: InStream, AFSOptionalParameters: Codeunit "AFS Optional Parameters")
```

##### Parameters

*FilePath*<br>
&emsp;Type: Text <br>

The path to the file.

*TargetInStream*<br>
&emsp;Type: InStream <br>

The result instream containing the  content of the file.

*AFSOptionalParameters*<br>
&emsp;Type: Codeunit  "AFS Optional Parameters"<br>

Optional parameters to pass with the request.


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation response object

#### `GetFileAsText()`

Receives a file as a text from a file share.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := GetFileAsText(FilePath: Text, var TargetText: Text)
```

##### Parameters

*FilePath*<br>
&emsp;Type: Text <br>

The path to the file.

*TargetText*<br>
&emsp;Type: Text <br>

The result text containing the content of the file.


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation response object

#### `GetFileAsText()`

Receives a file as a text from a file share.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := GetFileAsText(FilePath: Text, var TargetText: Text, AFSOptionalParameters: Codeunit "AFS Optional Parameters")
```

##### Parameters

*FilePath*<br>
&emsp;Type: Text <br>

The path to the file.

*TargetText*<br>
&emsp;Type: Text <br>

The result text containing the content of the file.

*AFSOptionalParameters*<br>
&emsp;Type: Codeunit  "AFS Optional Parameters"<br>

Optional parameters to pass with the request.


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation response object

#### GetFileMetadata()

Receives file metadata as dictionary from a file share.

##### Syntax

```al
[Codeunit "AFS Operation Response"] := GetFileMetadata(FilePath: Text, var TargetMetadata: Dictionary of [Text, Text])
```

##### Parameters

*FilePath*<br>
&emsp;Type: Text <br>

The path to the file.

*TargetMetadata*<br>
&emsp;Type: Dictionary of [Text, Text] <br>

The result dictionary containing the metadata of the file in the form of metadata key and a value.


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation response object

#### GetFileMetadata()

Receives file metadata as dictionary from a file share.

##### Syntax

```al
[Codeunit "AFS Operation Response"] := GetFileMetadata(FilePath: Text, var TargetMetadata: Dictionary of [Text, Text], AFSOptionalParameters: Codeunit "AFS Optional Parameters")
```

##### Parameters

*FilePath*<br>
&emsp;Type: Text <br>

The path to the file.

*TargetMetadata*<br>
&emsp;Type: Dictionary of [Text, Text] <br>

The result dictionary containing the metadata of the file in the form of metadata key and a value.

*AFSOptionalParameters*<br>
&emsp;Type: Codeunit  "AFS Optional Parameters"<br>

Optional parameters to pass with the request.


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation response object

#### SetFileMetadata()

Sets the file metadata.

##### Syntax

```al
[Codeunit "AFS Operation Response"] := SetFileMetadata(FilePath: Text, Metadata: Dictionary of [Text, Text])
```

##### Parameters

*FilePath*<br>
&emsp;Type: Text <br>

The path to the file.

*Metadata*<br>
&emsp;Type: Dictionary of [Text, Text] <br>

The dictionary containing the metadata of the file in the form of metadata key and a value.


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation response object

#### SetFileMetadata()

Sets the file metadata.

##### Syntax

```al
[Codeunit "AFS Operation Response"] := SetFileMetadata(FilePath: Text, Metadata: Dictionary of [Text, Text], AFSOptionalParameters: Codeunit "AFS Optional Parameters")
```

##### Parameters

*FilePath*<br>
&emsp;Type: Text <br>

The path to the file.

*Metadata*<br>
&emsp;Type: Dictionary of [Text, Text] <br>

The dictionary containing the metadata of the file in the form of metadata key and a value.

*AFSOptionalParameters*<br>
&emsp;Type: Codeunit  "AFS Optional Parameters"<br>

Optional parameters to pass with the request.


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation response object

#### `PutFileUI()`

Uploads a file to the file share.
User will be prompted to specify the file to send.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := PutFileUI()
```

##### Return

*Codeunit "AFS Operation Response"*<br>

An operation response object

#### `PutFileUI()`

Uploads a file to the file share.
User will be prompted to specify the file to send.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := PutFileUI(AFSOptionalParameters: Codeunit "AFS Optional Parameters")
```

##### Parameters

*AFSOptionalParameters*<br>
&emsp;Type: Codeunit  "AFS Optional Parameters"<br>

Optional parameters to pass with the request.


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation response object

#### `PutFileStream()`

Uploads a file to the file share from instream.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := PutFileStream(FilePath: Text, var SourceInStream: InStream)
```

##### Parameters

*FilePath*<br>
&emsp;Type: Text <br>

The path to the file.

*SourceInStream*<br>
&emsp;Type: InStream <br>

The source instream containing the content of the file.


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation response object

#### `PutFileStream()`

Uploads a file to the file share from instream.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := PutFileStream(FilePath: Text, var SourceInStream: InStream, AFSOptionalParameters: Codeunit "AFS Optional Parameters")
```

##### Parameters

*FilePath*<br>
&emsp;Type: Text <br>

The path to the file.

*SourceInStream*<br>
&emsp;Type: InStream <br>

The source instream containing the content of the file.

*AFSOptionalParameters*<br>
&emsp;Type: Codeunit  "AFS Optional Parameters"<br>

Optional parameters to pass with the request.


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation response object

#### `PutFileText()`

Uploads a file to the file share from text.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := PutFileText(FilePath: Text, var SourceText: Text)
```

##### Parameters

*FilePath*<br>
&emsp;Type: Text <br>

The path to the file.

*SourceText*<br>
&emsp;Type: Text <br>

The source text containing the content of the file.


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation response object

#### `PutFileText()`

Uploads a file to the file share from text.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := PutFileText(FilePath: Text, var SourceText: Text, AFSOptionalParameters: Codeunit "AFS Optional Parameters")
```

##### Parameters

*FilePath*<br>
&emsp;Type: Text <br>

The path to the file.

*SourceText*<br>
&emsp;Type: Text <br>

The source text containing the content of the file.

*AFSOptionalParameters*<br>
&emsp;Type: Codeunit  "AFS Optional Parameters"<br>

Optional parameters to pass with the request.


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation response object

#### `DeleteFile()`

Deletes a file from the file share.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := DeleteFile(FilePath: Text)
```

##### Parameters

*FilePath*<br>
&emsp;Type: Text <br>

The path to the file.


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation response object

#### `DeleteFile()`

Deletes a file from the file share.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := DeleteFile(FilePath: Text, AFSOptionalParameters: Codeunit "AFS Optional Parameters")
```

##### Parameters

*FilePath*<br>
&emsp;Type: Text <br>

The path to the file.

*AFSOptionalParameters*<br>
&emsp;Type: Codeunit  "AFS Optional Parameters"<br>

Optional parameters to pass with the request.


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation response object

#### `ListDirectory()`

Lists files and directories from the file share.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := ListDirectory(DirectoryPath: Text, var AFSDirectoryContent: Record "AFS Directory Content")
```

##### Parameters

*DirectoryPath*<br>
&emsp;Type: Text <br>

The path of the directory to list.

*AFSDirectoryContent*<br>
&emsp;Type: Record  "AFS Directory Content"<br>

The result collection with contents of the directory (temporary)


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation response object

#### `ListDirectory()`

Lists files and directories from the file share.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := ListDirectory(DirectoryPath: Text, var AFSDirectoryContent: Record "AFS Directory Content", AFSOptionalParameters: Codeunit "AFS Optional Parameters")
```

##### Parameters

*DirectoryPath*<br>
&emsp;Type: Text <br>

The path of the directory to list.

*AFSDirectoryContent*<br>
&emsp;Type: Record  "AFS Directory Content"<br>

The result collection with contents of the directory (temporary)

*AFSOptionalParameters*<br>
&emsp;Type: Codeunit  "AFS Optional Parameters"<br>

Optional parameters to pass with the request.


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation response object

#### `ListDirectory()`

Lists files and directories from the file share.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := ListDirectory(DirectoryPath: Text, PreserveDirectoryContent: Boolean, var AFSDirectoryContent: Record "AFS Directory Content")
```

##### Parameters

*DirectoryPath*<br>
&emsp;Type: Text <br>

The path of the directory to list.

*PreserveDirectoryContent*<br>
&emsp;Type: Boolean <br>

Specifies if the result collection should be cleared before filling it with the response data.

*AFSDirectoryContent*<br>
&emsp;Type: Record  "AFS Directory Content"<br>

The result collection with contents of the directory (temporary)


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation response object

#### `ListDirectory()`

Lists files and directories from the file share.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := ListDirectory(DirectoryPath: Text, PreserveDirectoryContent: Boolean, var AFSDirectoryContent: Record "AFS Directory Content", AFSOptionalParameters: Codeunit "AFS Optional Parameters")
```

##### Parameters

*DirectoryPath*<br>
&emsp;Type: Text <br>

The path of the directory to list.

*PreserveDirectoryContent*<br>
&emsp;Type: Boolean <br>

Specifies if the result collection should be cleared before filling it with the response data.

*AFSDirectoryContent*<br>
&emsp;Type: Record  "AFS Directory Content"<br>

The result collection with contents of the directory (temporary)

*AFSOptionalParameters*<br>
&emsp;Type: Codeunit  "AFS Optional Parameters"<br>

Optional parameters to pass with the request.


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation response object

#### `CreateDirectory()`

Creates directory on the file share.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := CreateDirectory(DirectoryPath: Text)
```

##### Parameters

*DirectoryPath*<br>
&emsp;Type: Text <br>

The path of the directory to create.


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation response object

#### `CreateDirectory()`

Creates directory on the file share.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := CreateDirectory(DirectoryPath: Text, AFSOptionalParameters: Codeunit "AFS Optional Parameters")
```

##### Parameters

*DirectoryPath*<br>
&emsp;Type: Text <br>

The path of the directory to create.

*AFSOptionalParameters*<br>
&emsp;Type: Codeunit  "AFS Optional Parameters"<br>

Optional parameters to pass with the request.


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation response object

#### `DeleteDirectory()`

Deletes an empty directory from the file share.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := DeleteDirectory(DirectoryPath: Text)
```

##### Parameters

*DirectoryPath*<br>
&emsp;Type: Text <br>

The path of the directory to delete.


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation response object

#### `DeleteDirectory()`

Deletes an empty directory from the file share.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := DeleteDirectory(DirectoryPath: Text, AFSOptionalParameters: Codeunit "AFS Optional Parameters")
```

##### Parameters

*DirectoryPath*<br>
&emsp;Type: Text <br>

The path of the directory to delete.

*AFSOptionalParameters*<br>
&emsp;Type: Codeunit  "AFS Optional Parameters"<br>

Optional parameters to pass with the request.


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation response object

#### `CopyFile()`

Copies a file on the file share.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := CopyFile(SourceFileURI: Text, DestinationFilePath: Text)
```

##### Parameters

*SourceFileURI*<br>
&emsp;Type: Text <br>

The URI to the source file. If the source file is on a different share than the destination file, the URI needs to be authorized.

*DestinationFilePath*<br>
&emsp;Type: Text <br>

The path where to destination file should be created.


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation response object

#### `CopyFile()`

Copies a file on the file share.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := CopyFile(SourceFileURI: Text, DestinationFilePath: Text, AFSOptionalParameters: Codeunit "AFS Optional Parameters")
```

##### Parameters

*SourceFileURI*<br>
&emsp;Type: Text <br>

The URI to the source file. If the source file is on a different share than the destination file, the URI needs to be authorized.

*DestinationFilePath*<br>
&emsp;Type: Text <br>

The path where to destination file should be created.

*AFSOptionalParameters*<br>
&emsp;Type: Codeunit  "AFS Optional Parameters"<br>

Optional parameters to pass with the request.


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation response object

#### `AbortCopyFile()`

Stops a file copy operation that is in progress.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := AbortCopyFile(DestinationFilePath: Text, CopyID: Text)
```

##### Parameters

*DestinationFilePath*<br>
&emsp;Type: Text <br>

The path where to destination file should be created.

*CopyID*<br>
&emsp;Type: Text <br>

The ID of the copy opeartion to abort.


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation response object

#### `AbortCopyFile()`

Stops a file copy operation that is in progress.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := AbortCopyFile(DestinationFilePath: Text, CopyID: Text, AFSOptionalParameters: Codeunit "AFS Optional Parameters")
```

##### Parameters

*DestinationFilePath*<br>
&emsp;Type: Text <br>

The path where to destination file should be created.

*CopyID*<br>
&emsp;Type: Text <br>

The ID of the copy opeartion to abort.

*AFSOptionalParameters*<br>
&emsp;Type: Codeunit  "AFS Optional Parameters"<br>

Optional parameters to pass with the request.


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation response object

#### `ListHandles()`

Lists all the open handles to the file.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := ListHandles(Path: Text, var AFSHandle: Record "AFS Handle")
```

##### Parameters

*Path*<br>
&emsp;Type: Text <br>

The path to the file.

*AFSHandle*<br>
&emsp;Type: Record  "AFS Handle"<br>

The result collection containing all the handles to the file (temporary).


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation response object

#### `ListHandles()`

Lists all the open handles to the file.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := ListHandles(Path: Text, var AFSHandle: Record "AFS Handle", AFSOptionalParameters: Codeunit "AFS Optional Parameters")
```

##### Parameters

*Path*<br>
&emsp;Type: Text <br>

The path to the file.

*AFSHandle*<br>
&emsp;Type: Record  "AFS Handle"<br>

The result collection containing all the handles to the file (temporary).

*AFSOptionalParameters*<br>
&emsp;Type: Codeunit  "AFS Optional Parameters"<br>

Optional parameters to pass with the request.


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation response object

#### `RenameFile()`

Renames a file on the file share.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := RenameFile(SourceFilePath: Text, DestinationFilePath: Text)
```

##### Parameters

*SourceFilePath*<br>
&emsp;Type: Text <br>

The path to the source file.

*DestinationFilePath*<br>
&emsp;Type: Text <br>

The path to which the file will be renamed.


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation response object

#### `RenameFile()`

Renames a file on the file share.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := RenameFile(SourceFilePath: Text, DestinationFilePath: Text, AFSOptionalParameters: Codeunit "AFS Optional Parameters")
```

##### Parameters

*SourceFilePath*<br>
&emsp;Type: Text <br>

The path to the source file.

*DestinationFilePath*<br>
&emsp;Type: Text <br>

The path to which the file will be renamed.

*AFSOptionalParameters*<br>
&emsp;Type: Codeunit  "AFS Optional Parameters"<br>

Optional parameters to pass with the request.


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation response object

#### `AcquireLease()`

Requests a new lease. If the file does not have an active lease, the file service creates a lease on the file.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := AcquireLease(FilePath: Text, ProposedLeaseId: Guid, var LeaseId: Guid)
```

##### Parameters

*FilePath*<br>
&emsp;Type: Text <br>

The path to the file.

*ProposedLeaseId*<br>
&emsp;Type: Guid <br>

The proposed id for the new lease.

*LeaseId*<br>
&emsp;Type: Guid <br>

Guid containing the response value from x-ms-lease-id HttpHeader


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation reponse object

#### `AcquireLease()`

Requests a new lease. If the file does not have an active lease, the file service creates a lease on the file.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := AcquireLease(FilePath: Text, ProposedLeaseId: Guid, AFSOptionalParameters: Codeunit "AFS Optional Parameters", var LeaseId: Guid)
```

##### Parameters

*FilePath*<br>
&emsp;Type: Text <br>

The path to the file.

*ProposedLeaseId*<br>
&emsp;Type: Guid <br>

The proposed id for the new lease.

*AFSOptionalParameters*<br>
&emsp;Type: Codeunit  "AFS Optional Parameters"<br>

Optional parameters to pass with the request.

*LeaseId*<br>
&emsp;Type: Guid <br>

Guid containing the response value from x-ms-lease-id HttpHeader


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation reponse object

#### `ChangeLease()`

Changes a lease id to a new lease id.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := ChangeLease(FilePath: Text, ProposedLeaseId: Guid, var LeaseId: Guid)
```

##### Parameters

*FilePath*<br>
&emsp;Type: Text <br>

The path to the file.

*ProposedLeaseId*<br>
&emsp;Type: Guid <br>

The proposed id for the new lease.

*LeaseId*<br>
&emsp;Type: Guid <br>

Previous lease id. Will be replaced by a new lease id if the request is successful.


##### Return

*Codeunit "AFS Operation Response"*<br>

Return value of type Codeunit "AFS Operation Response".

#### `ChangeLease()`

Changes a lease id to a new lease id.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := ChangeLease(FilePath: Text, ProposedLeaseId: Guid, AFSOptionalParameters: Codeunit "AFS Optional Parameters", var LeaseId: Guid)
```

##### Parameters

*FilePath*<br>
&emsp;Type: Text <br>

The path to the file.

*ProposedLeaseId*<br>
&emsp;Type: Guid <br>

The proposed id for the new lease.

*AFSOptionalParameters*<br>
&emsp;Type: Codeunit  "AFS Optional Parameters"<br>

Optional parameters to pass with the request.

*LeaseId*<br>
&emsp;Type: Guid <br>

Previous lease id. Will be replaced by a new lease id if the request is successful.


##### Return

*Codeunit "AFS Operation Response"*<br>

Return value of type Codeunit "AFS Operation Response".

#### `ReleaseLease()`

Releases a lease on a File if it is no longer needed so that another client may immediately acquire a lease against the file.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := ReleaseLease(FilePath: Text, LeaseId: Guid)
```

##### Parameters

*FilePath*<br>
&emsp;Type: Text <br>

The path to the file.

*LeaseId*<br>
&emsp;Type: Guid <br>

The Guid for the lease that should be released


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation reponse object

#### `ReleaseLease()`

Releases a lease on a File if it is no longer needed so that another client may immediately acquire a lease against the file.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := ReleaseLease(FilePath: Text, LeaseId: Guid, AFSOptionalParameters: Codeunit "AFS Optional Parameters")
```

##### Parameters

*FilePath*<br>
&emsp;Type: Text <br>

The path to the file.

*LeaseId*<br>
&emsp;Type: Guid <br>

The Guid for the lease that should be released

*AFSOptionalParameters*<br>
&emsp;Type: Codeunit  "AFS Optional Parameters"<br>

Optional parameters to pass with the request.


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation reponse object

#### `BreakLease()`

Breaks a lease on a file.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := BreakLease(FilePath: Text, LeaseId: Guid)
```

##### Parameters

*FilePath*<br>
&emsp;Type: Text <br>

The path to the file.

*LeaseId*<br>
&emsp;Type: Guid <br>

The Guid for the lease that should be broken


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation reponse object

#### `BreakLease()`

Breaks a lease on a file.


##### Syntax

```al
[Codeunit "AFS Operation Response"] := BreakLease(FilePath: Text, LeaseId: Guid, AFSOptionalParameters: Codeunit "AFS Optional Parameters")
```

##### Parameters

*FilePath*<br>
&emsp;Type: Text <br>

The path to the file.

*LeaseId*<br>
&emsp;Type: Guid <br>

The Guid for the lease that should be broken

*AFSOptionalParameters*<br>
&emsp;Type: Codeunit  "AFS Optional Parameters"<br>

Optional parameters to pass with the request.


##### Return

*Codeunit "AFS Operation Response"*<br>

An operation reponse object


## AFS Operation Response


Stores the response of an AFS client operation.

### Properties

| Property | Value |
| --- | --- |
| Object Type | Codeunit |
| Object Subtype | Normal |
| Object ID | 8959 |
| Accessibility Level | Public | 

### Procedures

#### `IsSuccessful()`

Checks whether the operation was successful.


##### Syntax

```al
[Boolean] := IsSuccessful()
```

##### Return

*Boolean*<br>

True if the operation was successful; otherwise - false.

#### `GetError()`

Gets the error (if any) of the response.


##### Syntax

```al
[Text] := GetError()
```

##### Return

*Text*<br>

Text representation of the error that occurred during the operation.

#### `GetHeaders()`

Gets the HttpHeaders (if any) of the response.


##### Syntax

```al
[HttpHeaders] := GetHeaders()
```

##### Return

*HttpHeaders*<br>

HttpHeaders.

#### `SetError()`


##### Syntax

```al
SetError(Error: Text)
```

##### Parameters

*Error*<br>
&emsp;Type: Text <br>


#### `GetResultAsText()`

Gets the result of a AFS client operation as text,


##### Syntax

```al
[Boolean] := GetResultAsText(var Result: Text)
```

##### Parameters

*Result*<br>
&emsp;Type: Text <br>


##### Return

*Boolean*<br>

False if an runtime error occurred. Otherwise true.

#### `GetResultAsStream()`

Gets the result of a AFS client operation as stream,


##### Syntax

```al
[Boolean] := GetResultAsStream(var ResultInStream: InStream)
```

##### Parameters

*ResultInStream*<br>
&emsp;Type: InStream <br>


##### Return

*Boolean*<br>

False if an runtime error occurred. Otherwise true.

#### `SetHttpResponse()`


##### Syntax

```al
SetHttpResponse(NewHttpResponseMessage: HttpResponseMessage)
```

##### Parameters

*NewHttpResponseMessage*<br>
&emsp;Type: HttpResponseMessage <br>


#### `GetHeaderValueFromResponseHeaders()`


##### Syntax

```al
[Text] := GetHeaderValueFromResponseHeaders(HeaderName: Text)
```

##### Parameters

*HeaderName*<br>
&emsp;Type: Text <br>



## AFS Optional Parameters


Holds procedures to format headers and parameters to be used in requests.

### Properties

| Property | Value |
| --- | --- |
| Object Type | Codeunit |
| Object Subtype | Normal |
| Object ID | 8956 |
| Accessibility Level | Public | 

### Procedures

#### `Range()`

Sets the value for 'x-ms-range' HttpHeader for a request.


##### Syntax

```al
Range(BytesStartValue: Integer, BytesEndValue: Integer)
```

##### Parameters

*BytesStartValue*<br>
&emsp;Type: Integer <br>

Integer value specifying the Bytes start range value

*BytesEndValue*<br>
&emsp;Type: Integer <br>

Integer value specifying the Bytes end range value


#### `Write()`

Sets the value for 'x-ms-write' HttpHeader for a request.


##### Syntax

```al
Write(Value: Enum "AFS Write")
```

##### Parameters

*Value*<br>
&emsp;Type: Enum  "AFS Write"<br>

Enum "AFS Write" value specifying the HttpHeader value


#### `LeaseId()`

Sets the value for 'x-ms-lease-id' HttpHeader for a request.


##### Syntax

```al
LeaseId(Value: Guid)
```

##### Parameters

*Value*<br>
&emsp;Type: Guid <br>

Guid value specifying the LeaseID


#### `LeaseAction()`

Sets the value for 'x-ms-lease-action' HttpHeader for a request.


##### Syntax

```al
LeaseAction(Value: Enum "AFS Lease Action")
```

##### Parameters

*Value*<br>
&emsp;Type: Enum  "AFS Lease Action"<br>

Enum "AFS Lease Action" value specifying the LeaseAction


#### `LeaseDuration()`

Sets the value for 'x-ms-lease-duration' HttpHeader for a request.


##### Syntax

```al
LeaseDuration(Value: Integer)
```

##### Parameters

*Value*<br>
&emsp;Type: Integer <br>

Integer value specifying the LeaseDuration in seconds


#### `ProposedLeaseId()`

Sets the value for 'x-ms-proposed-lease-id' HttpHeader for a request.


##### Syntax

```al
ProposedLeaseId(Value: Guid)
```

##### Parameters

*Value*<br>
&emsp;Type: Guid <br>

Guid value specifying the ProposedLeaseId in seconds


#### `ClientRequestId()`

Sets the value for 'x-ms-client-request-id' HttpHeader for a request.


##### Syntax

```al
ClientRequestId(Value: Text)
```

##### Parameters

*Value*<br>
&emsp;Type: Text <br>

Text value specifying the HttpHeader value


#### `FileLastWriteTime()`

Sets the value for 'x-ms-file-last-write-time' HttpHeader for a request.


##### Syntax

```al
FileLastWriteTime(Value: Enum "AFS File Last Write Time")
```

##### Parameters

*Value*<br>
&emsp;Type: Enum  "AFS File Last Write Time"<br>

Enum "AFS File Last Write Time" value specifying the HttpHeader value


#### `FileRequestIntent()`

Sets the value for 'x-ms-file-request-intent' HttpHeader for a request, 'backup' is an acceptable value.


##### Syntax

```al
FileRequestIntent(Value: Text)
```

##### Parameters

*Value*<br>
&emsp;Type: Text <br>

Text value specifying the HttpHeader value


#### `FilePermission()`

Sets the value for 'x-ms-file-permission' HttpHeader for a request.


##### Syntax

```al
FilePermission(Value: Text)
```

##### Parameters

*Value*<br>
&emsp;Type: Text <br>

Text value specifying the HttpHeader value


#### `FilePermissionKey()`

Sets the value for 'x-ms-file-permission-key' HttpHeader for a request.


##### Syntax

```al
FilePermissionKey(Value: Text)
```

##### Parameters

*Value*<br>
&emsp;Type: Text <br>

Text value specifying the HttpHeader value


#### `FileAttributes()`

Sets the value for 'x-ms-file-attributes' HttpHeader for a request.


##### Syntax

```al
FileAttributes(Value: List of [Enum "AFS File Attribute"])
```

##### Parameters

*Value*<br>
&emsp;Type: List  of [Enum "AFS File Attribute"]<br>

Text value specifying the HttpHeader value


#### `FileCreationTime()`

Sets the value for 'x-ms-file-creation-time' HttpHeader for a request.


##### Syntax

```al
FileCreationTime(Value: DateTime)
```

##### Parameters

*Value*<br>
&emsp;Type: DateTime <br>

Datetime of the file creation


#### `FileLastWriteTime()`

Sets the value for 'x-ms-file-last-write-time' HttpHeader for a request.


##### Syntax

```al
FileLastWriteTime(Value: DateTime)
```

##### Parameters

*Value*<br>
&emsp;Type: DateTime <br>

Datetime of the file last write time


#### `FileChangeTime()`

Sets the value for 'x-ms-file-change-time' HttpHeader for a request.


##### Syntax

```al
FileChangeTime(Value: DateTime)
```

##### Parameters

*Value*<br>
&emsp;Type: DateTime <br>

Datetime of the file last change time


#### `Meta()`

Sets the value for 'x-ms-meta-name' HttpHeader for a request. name should adhere to C# identifiers naming convention.


##### Syntax

```al
Meta(Key: Text, Value: Text)
```

##### Parameters

*Key*<br>
&emsp;Type: Text <br>

Text value specifying the metadata name key

*Value*<br>
&emsp;Type: Text <br>

Text value specifying the HttpHeader value


#### `FilePermissionCopyMode()`

Sets the value for 'x-ms-file-permission-copy-mode' HttpHeader for a request.


##### Syntax

```al
FilePermissionCopyMode(Value: Enum "AFS File Permission Copy Mode")
```

##### Parameters

*Value*<br>
&emsp;Type: Enum  "AFS File Permission Copy Mode"<br>

Enum "AFS File Permission Copy Mode" value specifying the HttpHeader value


#### `CopySource()`

Sets the value for 'x-ms-copy-source' HttpHeader for a request.


##### Syntax

```al
CopySource(Value: Text)
```

##### Parameters

*Value*<br>
&emsp;Type: Text <br>

Text value specifying the HttpHeader value


#### `AllowTrailingDot()`

Sets the value for 'x-ms-allow-trailing-dot' HttpHeader for a request.


##### Syntax

```al
AllowTrailingDot(Value: Boolean)
```

##### Parameters

*Value*<br>
&emsp;Type: Boolean <br>

Boolean value specifying the HttpHeader value


#### `FileRenameReplaceIfExists()`

Sets the value for 'x-ms-file-rename-replace-if-exists' HttpHeader for a request.


##### Syntax

```al
FileRenameReplaceIfExists(Value: Boolean)
```

##### Parameters

*Value*<br>
&emsp;Type: Boolean <br>

Boolean value specifying the HttpHeader value


#### `FileRenameIgnoreReadOnly()`

Sets the value for 'x-ms-file-rename-ignore-readonly' HttpHeader for a request.


##### Syntax

```al
FileRenameIgnoreReadOnly(Value: Boolean)
```

##### Parameters

*Value*<br>
&emsp;Type: Boolean <br>

Boolean value specifying the HttpHeader value


#### `SourceLeaseId()`

Sets the value for 'x-ms-source-lease-id' HttpHeader for a request.


##### Syntax

```al
SourceLeaseId(Value: Guid)
```

##### Parameters

*Value*<br>
&emsp;Type: Guid <br>

Guid value specifying the SourceLeaseID


#### `DestinationLeaseId()`

Sets the value for 'x-ms-destination-lease-id' HttpHeader for a request.


##### Syntax

```al
DestinationLeaseId(Value: Guid)
```

##### Parameters

*Value*<br>
&emsp;Type: Guid <br>

Guid value specifying the DestinationLeaseID


#### `FileCopyIgnoreReadOnly()`

Sets the value for 'x-ms-file-copy-ignore-readonly' HttpHeader for a request.


##### Syntax

```al
FileCopyIgnoreReadOnly(Value: Boolean)
```

##### Parameters

*Value*<br>
&emsp;Type: Boolean <br>

Boolean value specifying the HttpHeader value


#### `FileCopySetArchive()`

Sets the value for 'x-ms-file-copy-set-archive' HttpHeader for a request.


##### Syntax

```al
FileCopySetArchive(Value: Boolean)
```

##### Parameters

*Value*<br>
&emsp;Type: Boolean <br>

Boolean value specifying the HttpHeader value


#### `FileExtendedInfo()`

Sets the value for 'x-ms-file-extended-info' HttpHeader for a request.


##### Syntax

```al
FileExtendedInfo(Value: Boolean)
```

##### Parameters

*Value*<br>
&emsp;Type: Boolean <br>

Boolean value specifying the HttpHeader value


#### `RangeGetContentMD5()`

Sets the value for 'x-ms-range-get-content-md5' HttpHeader for a request.


##### Syntax

```al
RangeGetContentMD5(Value: Boolean)
```

##### Parameters

*Value*<br>
&emsp;Type: Boolean <br>

Boolean value specifying the HttpHeader value


#### `Recursive()`

Sets the value for 'x-ms-recursive' HttpHeader for a request.


##### Syntax

```al
Recursive(Value: Boolean)
```

##### Parameters

*Value*<br>
&emsp;Type: Boolean <br>

Boolean value specifying the HttpHeader value


#### `Timeout()`

Sets the optional timeout value for the request.


##### Syntax

```al
Timeout(Value: Integer)
```

##### Parameters

*Value*<br>
&emsp;Type: Integer <br>

Timeout in seconds. Most operations have a max. limit of 30 seconds. For more Information see: https://go.microsoft.com/fwlink/?linkid=2210591


#### `Prefix()`

Filters the results to return only blobs whose names begin with the specified prefix.


##### Syntax

```al
Prefix(Value: Text)
```

##### Parameters

*Value*<br>
&emsp;Type: Text <br>

Prefix to search for


#### `ShareSnapshot()`

Specifies the share snapshot to query for the list of files and directories.


##### Syntax

```al
ShareSnapshot(Value: DateTime)
```

##### Parameters

*Value*<br>
&emsp;Type: DateTime <br>

Datetime of the snapshot to query


#### `Marker()`

A string value that identifies the portion of the list to be returned with the next list operation.


##### Syntax

```al
Marker(Value: Text)
```

##### Parameters

*Value*<br>
&emsp;Type: Text <br>

Text marker that was returned in previous operation


#### `MaxResults()`

Specifies the maximum number of files or directories to return


##### Syntax

```al
MaxResults(Value: Integer)
```

##### Parameters

*Value*<br>
&emsp;Type: Integer <br>

Max. number of results to return. Must be positive, must not be greater than 5000


#### `Include()`

Specifies one or more properties to include in the response.


##### Syntax

```al
Include(Value: List of [Enum "AFS Properties"])
```

##### Parameters

*Value*<br>
&emsp;Type: List  of [Enum "AFS Properties"]<br>

List of properties to include.


#### `SetRequestHeader()`


##### Syntax

```al
SetRequestHeader(Header: Text, HeaderValue: Text)
```

##### Parameters

*Header*<br>
&emsp;Type: Text <br>

*HeaderValue*<br>
&emsp;Type: Text <br>


#### `GetRequestHeaders()`


##### Syntax

```al
[Dictionary of [Text, Text]] := GetRequestHeaders()
```

#### `SetParameter()`


##### Syntax

```al
SetParameter(Header: Text, HeaderValue: Text)
```

##### Parameters

*Header*<br>
&emsp;Type: Text <br>

*HeaderValue*<br>
&emsp;Type: Text <br>


#### `GetParameters()`


##### Syntax

```al
[Dictionary of [Text, Text]] := GetParameters()
```

