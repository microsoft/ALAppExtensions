Helper functions on RecordLinks.

# Public Objects
## Record Link Management (Codeunit 447)

 Exposes functionality to administer record links related to table records.
 

### CopyLinks (Method) <a name="CopyLinks"></a> 
OnAfterCopyLinks


 Copies all the links from one record to the other and sets Notify to FALSE for them.
 

#### Syntax
```
procedure CopyLinks(FromRecord: Variant; ToRecord: Variant)
```
#### Parameters
*FromRecord ([Variant](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/variant/variant-data-type))* 

The source record from which links are copied.

*ToRecord ([Variant](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/variant/variant-data-type))* 

The destination record to which links are copied.

### WriteNote (Method) <a name="WriteNote"></a> 

 Writes the Note BLOB into the format the client code expects.
 

#### Syntax
```
procedure WriteNote(var RecordLink: Record "Record Link"; Note: Text)
```
#### Parameters
*RecordLink ([Record "Record Link"]())* 

The record link passed as a VAR to which the note is added.

*Note ([Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type))* 

The note to be added.

### ReadNote (Method) <a name="ReadNote"></a> 

 Read the Note BLOB
 

#### Syntax
```
procedure ReadNote(RecordLink: Record "Record Link"): Text
```
#### Parameters
*RecordLink ([Record "Record Link"]())* 

The record link from which the note is read.

#### Return Value
*[Text](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type)*

The note as a text.
### RemoveOrphanedLinks (Method) <a name="RemoveOrphanedLinks"></a> 

 Iterates over the record link table and removes those with obsolete record ids.
 

#### Syntax
```
procedure RemoveOrphanedLinks()
```
### OnAfterCopyLinks (Event) <a name="OnAfterCopyLinks"></a> 

 Integration event for after copying links from one record to the other.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnAfterCopyLinks(FromRecord: Variant; ToRecord: Variant)
```
#### Parameters
*FromRecord ([Variant](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/variant/variant-data-type))* 

The source record from which links are copied.

*ToRecord ([Variant](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/variant/variant-data-type))* 

The destination record to which links are copied.


## Remove Orphaned Record Links (Codeunit 459)

 This codeunit is created so that record links that have obsolete record ids can be deleted in a scheduled task.
 

