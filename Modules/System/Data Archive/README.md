Provides an API that lets you add archiving to any app object that needs to archive data before deleting it. 
This API is in itself functionless, but relies on an implementation of the interface. As default, this is handled by a first-party preinstalled app, "Data Archive".

BaseApp and other apps will use this basic code flow:

~~~
procedure Foo()
var 
    DataArchive: Codeunit "Data Archive";  // System App
    Customer: Record Customer;
    RecRef: RecordRef;
    NewArchiveNo: Integer;
begin
    ...
    NewArchiveNo := DataArchiveInterface.Create('New Archive');
    ...
    RecRef.GetTable(Customer);
    DataArchiveInterface.SaveRecord(RecRef);
    ...
    DataArchiveInterface.Save();
    ...
end;
~~~


### Data Archive
This codeunit is the API for this feature and holds functions for creating/reopening an archive, saving a single record or a recordset, and either saving or discarding the archive.
It also enables turning on subscription for all delete operations, hence creating a 'recorder' of deleted data.

# Public Objects
## Data Archive Provider (Interface)

 Exposes an interface for Data Archive.
 Data Archive is called from application objects to store data.
 

### Create (Method) <a name="Create"></a> 

 Creates a new archive entry.
 

#### Syntax
```
procedure Create(Description: Text): Integer
```
#### Parameters
*Description ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name or description for the archive entry. Will typically be the calling object name.

#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The entry no. of the created archive entry - if any.
### Open (Method) <a name="Open"></a> 

 Opens an existing archive entry.
 

#### Syntax
```
procedure Open(ID: Integer)
```
#### Parameters
*ID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the archive entry.

### Save (Method) <a name="Save"></a> 

 Saves and closes the currently open archive entry.
 

#### Syntax
```
procedure Save()
```
### DiscardChanges (Method) <a name="DiscardChanges"></a> 

 Discards any additions and closes the currently open archive entry.
 

#### Syntax
```
procedure DiscardChanges()
```
### SaveRecord (Method) <a name="SaveRecord"></a> 

 Saves the supplied record to the currently open archive entry.
 

#### Syntax
```
procedure SaveRecord(var RecRef: RecordRef)
```
#### Parameters
*RecRef ([RecordRef](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/recordref/recordref-data-type))* 

The record will be copied to the archive.

### SaveRecord (Method) <a name="SaveRecord"></a> 

 Saves the supplied record to the currently open archive entry.
 

#### Syntax
```
procedure SaveRecord(RecordVar: Variant)
```
#### Parameters
*RecordVar ([Variant](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/variant/variant-data-type))* 

The record will be copied to the archive.

### SaveRecords (Method) <a name="SaveRecords"></a> 

 Saves all records within the filters to the currently open archive entry.
 

#### Syntax
```
procedure SaveRecords(var RecRef: RecordRef)
```
#### Parameters
*RecRef ([RecordRef](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/recordref/recordref-data-type))* 

All records for the RecRef within the filters will be copied to the archive.

### StartSubscriptionToDelete (Method) <a name="StartSubscriptionToDelete"></a> 

 Starts subscription to the OnDatabaseDelete trigger and calls SaveRecord with any deleted record.
 

#### Syntax
```
procedure StartSubscriptionToDelete()
```
### StartSubscriptionToDelete (Method) <a name="StartSubscriptionToDelete"></a> 

 Starts subscription to the OnDatabaseDelete trigger and calls SaveRecord with any deleted record.
 

#### Syntax
```
procedure StartSubscriptionToDelete(ResetSession: Boolean)
```
#### Parameters
*ResetSession ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

If true, then the session will be reset. This can be necessary if a deletion has already been made on any table that should be archived.

### StopSubscriptionToDelete (Method) <a name="StopSubscriptionToDelete"></a> 

 Stops the subscription to the OnDatabaseDelete trigger.
 

#### Syntax
```
procedure StopSubscriptionToDelete()
```
### DataArchiveProviderExists (Method) <a name="DataArchiveProviderExists"></a> 

 Informs the consumer app whether there is a provider for this interface.
 

#### Syntax
```
procedure DataArchiveProviderExists(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

Returns true if a provider for this interface is installed.
### SetDataArchiveProvider (Method) <a name="SetDataArchiveProvider"></a> 

 Sets the instance of the provider. Needed for self-reference.
 

#### Syntax
```
procedure SetDataArchiveProvider(var NewDataArchiveProvider: Interface "Data Archive Provider")
```
#### Parameters
*NewDataArchiveProvider ([Interface "Data Archive Provider"]())* 

The global instance of IDataArchiveProvider.


## Data Archive (Codeunit 600)

 Exposes functionality to archive / save data before deleting it.
 

### Create (Method) <a name="Create"></a> 
The archive has already been created or opened.


 Creates a new archive entry.
 

#### Syntax
```
procedure Create(Description: Text): Integer
```
#### Parameters
*Description ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name or description for the archive entry. Will typically be the calling object name.

#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The entry no. of the created archive entry - if any.
### CreateAndStartLoggingDeletions (Method) <a name="CreateAndStartLoggingDeletions"></a> 
The archive has already been created or opened.


 Creates a new archive entry, resets the session and starts logging all new deletions.
 

#### Syntax
```
procedure CreateAndStartLoggingDeletions(Description: Text): Integer
```
#### Parameters
*Description ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The name or description for the archive entry. Will typically be the calling object name.

#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*

The entry no. of the created archive entry - if any.
### Open (Method) <a name="Open"></a> 
The archive has already been created or opened.


 Opens an existing archive entry.
 

#### Syntax
```
procedure Open(ID: Integer)
```
#### Parameters
*ID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the archive entry.

### Save (Method) <a name="Save"></a> 
The archive must be created or opened first.


 Saves and closes the currently open archive entry.
 

#### Syntax
```
procedure Save()
```
### DiscardChanges (Method) <a name="DiscardChanges"></a> 
The archive must be created or opened first.


 Discards any additions and closes the currently open archive entry.
 

#### Syntax
```
procedure DiscardChanges()
```
### SaveRecord (Method) <a name="SaveRecord"></a> 
The archive must be created or opened first.


 Saves the supplied record to the currently open archive entry.
 

#### Syntax
```
procedure SaveRecord(RecordVar: Variant)
```
#### Parameters
*RecordVar ([Variant](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/variant/variant-data-type))* 

The record will be copied to the archive.

### SaveRecord (Method) <a name="SaveRecord"></a> 
The archive must be created or opened first.


 Saves the supplied record to the currently open archive entry.
 

#### Syntax
```
procedure SaveRecord(var RecRef: RecordRef)
```
#### Parameters
*RecRef ([RecordRef](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/recordref/recordref-data-type))* 

The record will be copied to the archive.

### SaveRecords (Method) <a name="SaveRecords"></a> 
The archive must be created or opened first.


 Saves all records within the filters to the currently open archive entry.
 

#### Syntax
```
procedure SaveRecords(var RecRef: RecordRef)
```
#### Parameters
*RecRef ([RecordRef](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/recordref/recordref-data-type))* 



### StartSubscriptionToDelete (Method) <a name="StartSubscriptionToDelete"></a> 

 Starts subscription to the OnDatabaseDelete trigger and calls SaveRecord with any deleted record.
 

#### Syntax
```
procedure StartSubscriptionToDelete()
```
### StartSubscriptionToDelete (Method) <a name="StartSubscriptionToDelete"></a> 

 Starts subscription to the OnDatabaseDelete trigger and calls SaveRecord with any deleted record.
 

#### Syntax
```
procedure StartSubscriptionToDelete(ResetSession: Boolean)
```
#### Parameters
*ResetSession ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 



### StopSubscriptionToDelete (Method) <a name="StopSubscriptionToDelete"></a> 

 Stops the subscription to the OnDatabaseDelete trigger.
 

#### Syntax
```
procedure StopSubscriptionToDelete()
```
### DataArchiveProviderExists (Method) <a name="DataArchiveProviderExists"></a> 

 Informs the consumer app whether there is a provider for this interface.
 

#### Syntax
```
procedure DataArchiveProviderExists(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

Returns true if a provider for this interface is installed.
### SetDataArchiveProvider (Method) <a name="SetDataArchiveProvider"></a> 

 Checks if there is an implementation of an IDataArchiveProvider
 

#### Syntax
```
procedure SetDataArchiveProvider(var NewDataArchiveProvider: Interface "Data Archive Provider")
```
#### Parameters
*NewDataArchiveProvider ([Interface "Data Archive Provider"]())* 



### OnDataArchiveImplementationExists (Event) <a name="OnDataArchiveImplementationExists"></a> 

 Checks if there is an implementation of an IDataArchiveProvider
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnDataArchiveImplementationExists(var Exists: Boolean)
```
#### Parameters
*Exists ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

A subscriber should set the value to true if it is an implementation of IDataArchiveProvider.

### OnDataArchiveImplementationBind (Event) <a name="OnDataArchiveImplementationBind"></a> 

 Asks for an implementation of an IDataArchiveProvider
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnDataArchiveImplementationBind(var IDataArchiveProvider: Interface "Data Archive Provider"; var IsBound: Boolean)
```
#### Parameters
*IDataArchiveProvider ([Interface "Data Archive Provider"]())* 



*IsBound ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

The first subscriber should set this parameter to true. If it was already true, the code should just exit immediately without binding a provider.

