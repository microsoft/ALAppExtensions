Provides a way to store various kinds of data. It consists of the TempBlob container to store BLOB data in-memory, the Persistent BLOB Management interface for storing BLOB data between sessions, and the TempBlob List interface for storing sequences of variables, each of which stores BLOB data. Potential uses are storing images, very long texts, PDF files, and so on.

# Public Objects
## Persistent Blob (Codeunit 4101)

 The interface for storing BLOB data between sessions.
 

### Create (Method) <a name="Create"></a> 

 Create a new empty PersistentBlob.
 

#### Syntax
```
procedure Create(): BigInteger
```
#### Return Value
*[BigInteger](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/biginteger/biginteger-data-type)*

The key of the new BLOB.
### Exists (Method) <a name="Exists"></a> 

 Check whether a BLOB with the Key exists.
 

#### Syntax
```
procedure Exists("Key": BigInteger): Boolean
```
#### Parameters
*Key ([BigInteger](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/biginteger/biginteger-data-type))* 

The key of the BLOB.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the BLOB with the given key exists.
### Delete (Method) <a name="Delete"></a> 

 Delete the BLOB with the Key.
 

#### Syntax
```
procedure Delete("Key": BigInteger): Boolean
```
#### Parameters
*Key ([BigInteger](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/biginteger/biginteger-data-type))* 

The key of the BLOB.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the BLOB with the given key was deleted.
### CopyFromInStream (Method) <a name="CopyFromInStream"></a> 

 Save the content of the stream to the PersistentBlob.
 

#### Syntax
```
procedure CopyFromInStream("Key": BigInteger; Source: InStream): Boolean
```
#### Parameters
*Key ([BigInteger](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/biginteger/biginteger-data-type))* 

The key of the BLOB.

*Source ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The InStream from which content will be copied to the PersistentBlob.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the BLOB with the given key was updated with the contents of the source.
### CopyToOutStream (Method) <a name="CopyToOutStream"></a> 

 Write the content of the PersistentBlob to the Destination OutStream.
 

#### Syntax
```
procedure CopyToOutStream("Key": BigInteger; Destination: OutStream): Boolean
```
#### Parameters
*Key ([BigInteger](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/biginteger/biginteger-data-type))* 

The key of the BLOB.

*Destination ([OutStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/outstream/outstream-data-type))* 

The OutStream to which the contents of the PersistentBlob will be copied.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the BLOB with the given Key was copied to the Destination.

## Temp Blob (Codeunit 4100)

 The container to store BLOB data in-memory.
 

### CreateInStream (Method) <a name="CreateInStream"></a> 

 Creates an InStream object with default encoding for the TempBlob. This enables you to read data from the TempBlob.
 

#### Syntax
```
procedure CreateInStream(var InStream: InStream)
```
#### Parameters
*InStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The InStream variable passed as a VAR to which the BLOB content will be attached.

### CreateInStream (Method) <a name="CreateInStream"></a> 

 Creates an InStream object with the specified encoding for the TempBlob. This enables you to read data from the TempBlob.
 

#### Syntax
```
procedure CreateInStream(var InStream: InStream; Encoding: TextEncoding)
```
#### Parameters
*InStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

The InStream variable passed as a VAR to which the BLOB content will be attached.

*Encoding ([TextEncoding](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-file-handling-and-text-encoding))* 

The text encoding to use.

### CreateOutStream (Method) <a name="CreateOutStream"></a> 

 Creates an OutStream object with default encoding for the TempBlob. This enables you to write data to the TempBlob.
 

#### Syntax
```
procedure CreateOutStream(var OutStream: OutStream)
```
#### Parameters
*OutStream ([OutStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/outstream/outstream-data-type))* 

The OutStream variable passed as a VAR to which the BLOB content will be attached.

### CreateOutStream (Method) <a name="CreateOutStream"></a> 

 Creates an OutStream object with the specified encoding for the TempBlob. This enables you to write data to the TempBlob.
 

#### Syntax
```
procedure CreateOutStream(var OutStream: OutStream; Encoding: TextEncoding)
```
#### Parameters
*OutStream ([OutStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/outstream/outstream-data-type))* 

The OutStream variable passed as a VAR to which the BLOB content will be attached.

*Encoding ([TextEncoding](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-file-handling-and-text-encoding))* 

The text encoding to use.

### HasValue (Method) <a name="HasValue"></a> 

 Determines whether the TempBlob has a value.
 

#### Syntax
```
procedure HasValue(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the TempBlob has a value.
### Length (Method) <a name="Length"></a> 

 Determines the length of the data stored in the TempBlob.
 

#### Syntax
```
procedure Length(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The number of bytes stored in the BLOB.
### FromRecord (Method) <a name="FromRecord"></a> 

 Copies the value of the BLOB field on the RecordVariant in the specified field to the TempBlob.
 

#### Syntax
```
procedure FromRecord(RecordVariant: Variant; FieldNo: Integer)
```
#### Parameters
*RecordVariant ([Variant](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/variant/variant-data-type))* 

Any Record variable.

*FieldNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The field number of the BLOB field to be read.

### FromRecordRef (Method) <a name="FromRecordRef"></a> 

 Copies the value of the BLOB field on the RecordRef in the specified field to the TempBlob.
 

#### Syntax
```
procedure FromRecordRef(RecordRef: RecordRef; FieldNo: Integer)
```
#### Parameters
*RecordRef ([RecordRef](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/recordref/recordref-data-type))* 

A RecordRef variable attached to a Record.

*FieldNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The field number of the BLOB field to be read.

### ToRecordRef (Method) <a name="ToRecordRef"></a> 

 Copies the value of the TempBlob to the specified field on the RecordRef.
 

#### Syntax
```
procedure ToRecordRef(var RecordRef: RecordRef; FieldNo: Integer)
```
#### Parameters
*RecordRef ([RecordRef](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/recordref/recordref-data-type))* 

A RecordRef variable attached to a Record.

*FieldNo ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The field number of the Blob field to be written.

### FromFieldRef (Method) <a name="FromFieldRef"></a> 

 Copies the value of the FieldRef to the TempBlob.
 

#### Syntax
```
procedure FromFieldRef(BlobFieldRef: FieldRef)
```
#### Parameters
*BlobFieldRef ([FieldRef](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/fieldref/fieldref-data-type))* 

A FieldRef variable attached to a field for a record.

### ToFieldRef (Method) <a name="ToFieldRef"></a> 

 Copies the value of the TempBlob to the specified FieldRef.
 

#### Syntax
```
procedure ToFieldRef(var BlobFieldRef: FieldRef)
```
#### Parameters
*BlobFieldRef ([FieldRef](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/fieldref/fieldref-data-type))* 

A FieldRef variable attached to a field for a record.


## Temp Blob List (Codeunit 4102)

 The interface for storing sequences of variables, each of which stores BLOB data.
 

### Exists (Method) <a name="Exists"></a> 

 Check if an element with the given index exists.
 

#### Syntax
```
procedure Exists(Index: Integer): Boolean
```
#### Parameters
*Index ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The index of the TempBlob in the list.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if an element at the given index exists.
### Count (Method) <a name="Count"></a> 

 Returns the number of elements in the list.
 

#### Syntax
```
procedure Count(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The number of elements in the list.
### Get (Method) <a name="Get"></a> 
The index is larger than the number of elements in the list or less than one.


 Get an element from the list at any given position.
 

#### Syntax
```
procedure Get(Index: Integer; var TempBlob: Codeunit "Temp Blob")
```
#### Parameters
*Index ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The index of the TempBlob in the list.

*TempBlob ([Codeunit "Temp Blob"]())* 

The TempBlob to return.

### Set (Method) <a name="Set"></a> 
The index is larger than the number of elements in the list or less than one.


 Set an element at the given index from the parameter TempBlob.
 

#### Syntax
```
procedure Set(Index: Integer; TempBlob: Codeunit "Temp Blob"): Boolean
```
#### Parameters
*Index ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The index of the TempBlob in the list.

*TempBlob ([Codeunit "Temp Blob"]())* 

The TempBlob to set.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if successful.
### RemoveAt (Method) <a name="RemoveAt"></a> 
The index is larger than the number of elements in the list or less than one.


 Remove the element at a specified location from a non-empty list.
 

#### Syntax
```
procedure RemoveAt(Index: Integer): Boolean
```
#### Parameters
*Index ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The index of the TempBlob in the list.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if successful.
### IsEmpty (Method) <a name="IsEmpty"></a> 

 Return true if the list is empty, otherwise return false.
 

#### Syntax
```
procedure IsEmpty(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if the list is empty.
### Add (Method) <a name="Add"></a> 

 Adds a TempBlob to the end of the list.
 

#### Syntax
```
procedure Add(TempBlob: Codeunit "Temp Blob"): Boolean
```
#### Parameters
*TempBlob ([Codeunit "Temp Blob"]())* 

The TempBlob to add.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if successful.
### AddRange (Method) <a name="AddRange"></a> 

 Adds the elements of the specified TempBlobList to the end of the current TempBlobList object.
 

#### Syntax
```
procedure AddRange(TempBlobList: Codeunit "Temp Blob List"): Boolean
```
#### Parameters
*TempBlobList ([Codeunit "Temp Blob List"]())* 

The TempBlob list to add.

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

True if successful.
### GetRange (Method) <a name="GetRange"></a> 
The index is larger than the number of elements in the list or less than one.


 Get a copy of a range of elements in the list starting from index,
 

#### Syntax
```
procedure GetRange(Index: Integer; ElemCount: Integer; var TempBlobListOut: Codeunit "Temp Blob List")
```
#### Parameters
*Index ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The index of the first object.

*ElemCount ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The number of objects to be returned.

*TempBlobListOut ([Codeunit "Temp Blob List"]())* 

The TempBlobList to be returned passed as a VAR.

