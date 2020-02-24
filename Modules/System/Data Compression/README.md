The purpose of this module is to provide ability to create, update, read and dispose a binary data compression archive.


# Public Objects
## Data Compression (Codeunit 425)

 Exposes functionality to provide ability to create, update, read and dispose a binary data compression archive.
 This module supports compression and decompression with Zip format and GZip format.
 

### CreateZipArchive (Method) <a name="CreateZipArchive"></a> 

 Creates a new ZipArchive instance.
 

#### Syntax
```
procedure CreateZipArchive()
```
### OpenZipArchive (Method) <a name="OpenZipArchive"></a> 

 Creates a ZipArchive instance from the given InStream.
 

#### Syntax
```
procedure OpenZipArchive(InputStream: InStream; OpenForUpdate: Boolean)
```
#### Parameters
*InputStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The InStream that contains the content of the compressed archive.

*OpenForUpdate ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Indicates whether the archive should be opened in Update mode. The default (false) indicated the archive will be opened in Read mode.

### OpenZipArchive (Method) <a name="OpenZipArchive"></a> 

 Creates a ZipArchive instance from the given InStream.
 

#### Syntax
```
procedure OpenZipArchive(InputStream: InStream; OpenForUpdate: Boolean; EncodingCodePageNumber: Integer)
```
#### Parameters
*InputStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The InStream that contains the content of the compressed archive.

*OpenForUpdate ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Indicates whether the archive should be opened in Update mode. The default (false) indicated the archive will be opened in Read mode.

*EncodingCodePageNumber ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Specifies the code page number of the text encoding which is used for the compressed archive entry names in the input stream.

### OpenZipArchive (Method) <a name="OpenZipArchive"></a> 

 Creates a ZipArchive instance from the given instance of Temp Blob codeunit.
 

#### Syntax
```
procedure OpenZipArchive(TempBlob: Codeunit "Temp Blob"; OpenForUpdate: Boolean)
```
#### Parameters
*TempBlob ([Codeunit "Temp Blob"]())* 

The instance of Temp Blob codeunit that contains the content of the compressed archive.

*OpenForUpdate ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Indicates whether the archive should be opened in Update mode. The default (false) indicated the archive will be opened in Read mode.

### SaveZipArchive (Method) <a name="SaveZipArchive"></a> 

 Saves the ZipArchive to the given OutStream.
 

#### Syntax
```
procedure SaveZipArchive(OutputStream: OutStream)
```
#### Parameters
*OutputStream ([OutStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/outstream/outstream-data-type))* 

The OutStream to which the ZipArchive is saved.

### SaveZipArchive (Method) <a name="SaveZipArchive"></a> 

 Saves the ZipArchive to the given instance of Temp Blob codeunit.
 

#### Syntax
```
procedure SaveZipArchive(var TempBlob: Codeunit "Temp Blob")
```
#### Parameters
*TempBlob ([Codeunit "Temp Blob"]())* 

The instance of the Temp Blob codeunit to which the ZipArchive is saved.

### CloseZipArchive (Method) <a name="CloseZipArchive"></a> 

 Disposes the ZipArchive.
 

#### Syntax
```
procedure CloseZipArchive()
```
### GetEntryList (Method) <a name="GetEntryList"></a> 

 Returns the list of entries for the ZipArchive.
 

#### Syntax
```
procedure GetEntryList(var EntryList: List of [Text])
```
#### Parameters
*EntryList ([List of [Text]]())* 

The list that is populated with the list of entries of the ZipArchive instance.

### ExtractEntry (Method) <a name="ExtractEntry"></a> 

 Extracts an entry from the ZipArchive.
 

#### Syntax
```
procedure ExtractEntry(EntryName: Text; OutputStream: OutStream; var EntryLength: Integer)
```
#### Parameters
*EntryName ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name of the ZipArchive entry to be extracted.

*OutputStream ([OutStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/outstream/outstream-data-type))* 

The OutStream to which binary content of the extracted entry is saved.

*EntryLength ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The length of the extracted entry.

### AddEntry (Method) <a name="AddEntry"></a> 

 Adds an entry to the ZipArchive.
 

#### Syntax
```
procedure AddEntry(StreamToAdd: InStream; PathInArchive: Text)
```
#### Parameters
*StreamToAdd ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The InStream that contains the binary content that should be added as an entry in the ZipArchive.

*PathInArchive ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The path that the added entry should have within the ZipArchive.

### IsGZip (Method) <a name="IsGZip"></a> 

 Determines whether the given InStream is compressed with GZip.
 

#### Syntax
```
procedure IsGZip(InStream: InStream): Boolean
```
#### Parameters
*InStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

An InStream that contains binary content.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

Returns true if and only if the given InStream is compressed with GZip
### GZipCompress (Method) <a name="GZipCompress"></a> 

 Compresses a stream with GZip algorithm.
 The InStream that contains the content that should be compressed.The OutStream into which the compressed stream is copied to.

#### Syntax
```
procedure GZipCompress(InputStream: InStream; CompressedStream: OutStream)
```
#### Parameters
*InputStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The InStream that contains the content that should be compressed.

*CompressedStream ([OutStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/outstream/outstream-data-type))* 

The OutStream into which the compressed stream is copied to.

### GZipDecompress (Method) <a name="GZipDecompress"></a> 

 Decompresses a GZipStream.
 The InStream that contains the content that should be decompressed.The OutStream into which the decompressed stream is copied to.

#### Syntax
```
procedure GZipDecompress(InputStream: InStream; DecompressedStream: OutStream)
```
#### Parameters
*InputStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The InStream that contains the content that should be decompressed.

*DecompressedStream ([OutStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/outstream/outstream-data-type))* 

The OutStream into which the decompressed stream is copied to.

