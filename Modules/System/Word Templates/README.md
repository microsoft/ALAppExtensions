Use Word templates to create documents that incorporate data from Business Central using mail merge. For example, mail merge is a great way to personalize bulk communications with business partners by letter or email.

# Public Objects
## Word Template (Table 9988)

 Holds information about a Word template.
 


## Word Template (Codeunit 9987)

 Exposes functionality to create and consume Word templates.
 

### DownloadTemplate (Method) <a name="DownloadTemplate"></a> 

 Downloads the set template.
 

#### Syntax
```
procedure DownloadTemplate()
```
### DownloadDocument (Method) <a name="DownloadDocument"></a> 

 Downloads the resulting document.
 

#### Syntax
```
procedure DownloadDocument()
```
### GetTemplate (Method) <a name="GetTemplate"></a> 

 Gets an InStream for the template.
 

#### Syntax
```
procedure GetTemplate(var InStream: InStream)
```
#### Parameters
*InStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

Out parameter, the InStream to set.

### GetDocument (Method) <a name="GetDocument"></a> 

 Gets an InStream for the resulting document.
 

#### Syntax
```
procedure GetDocument(var DocumentInStream: InStream)
```
#### Parameters
*DocumentInStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

Out parameter, the InStream to set.

### Create (Method) <a name="Create"></a> 

 Creates a template with the fields of a table. The table is selected by the user via a popup window.
 

#### Syntax
```
procedure Create()
```
### Create (Method) <a name="Create"></a> 

 Creates a template with the fields of the given table.
 

#### Syntax
```
procedure Create(TableId: Integer)
```
#### Parameters
*TableId ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

Specifies the ID of the table whose fields will be used to populate the template.

### Create (Method) <a name="Create"></a> 

 Creates a template with given merge fields.
 

#### Syntax
```
procedure Create(MergeFields: List of [Text])
```
#### Parameters
*MergeFields ([List of [Text]]())* 

Names of mail merge fields to be available in the template.

### Load (Method) <a name="Load"></a> 
The document format is not recognized or not supported.


 Loads the template to be used for merging.
 

#### Syntax
```
procedure Load(WordTemplateCode: Code[30])
```
#### Parameters
*WordTemplateCode ([Code[30]](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type))* 

The code of the Word template to use.

### Load (Method) <a name="Load"></a> 
The document format is not recognized or not supported.


 Loads the template to be used for merging.
 

#### Syntax
```
procedure Load(WordTemplateStream: InStream)
```
#### Parameters
*WordTemplateStream ([InStream](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/instream/instream-data-type))* 

InStream of the Word template to use.

### Merge (Method) <a name="Merge"></a> 

 Performs mail merge on set template and given data. Output document is of type .docx.
 

#### Syntax
```
procedure Merge(Data: Dictionary of [Text, Text])
```
#### Parameters
*Data ([Dictionary of [Text, Text]]())* 

Input data to be merged into the document. The key is the merge field name and value is the replacement value.

### Merge (Method) <a name="Merge"></a> 

 Performs mail merge on set template and given data. Output document type is of specified save format.
 

#### Syntax
```
procedure Merge(Data: Dictionary of [Text, Text]; SaveFormat: Enum "Word Templates Save Format")
```
#### Parameters
*Data ([Dictionary of [Text, Text]]())* 

Input data to be merged into the document. The key is the merge field name and value is the replacement value.

*SaveFormat ([Enum "Word Templates Save Format"]())* 

Format of the document to generate.

### Merge (Method) <a name="Merge"></a> 

 Performs mail merge on set template and data taken from the Record associated with the Document. Output document is of type .docx.
 

#### Syntax
```
procedure Merge(SplitDocument: Boolean)
```
#### Parameters
*SplitDocument ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Specifies whether a separate document per record should be created.

### Merge (Method) <a name="Merge"></a> 

 Performs mail merge on set template and data taken from the Record associated with the Document. Output document type is of specified save format.
 

#### Syntax
```
procedure Merge(SplitDocument: Boolean; SaveFormat: Enum "Word Templates Save Format")
```
#### Parameters
*SplitDocument ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Specifies whether a separate document per record should be created.

*SaveFormat ([Enum "Word Templates Save Format"]())* 

Format of the document to generate.

### Merge (Method) <a name="Merge"></a> 

 Performs mail merge on set template and data taken from the given Record. Output document is of type .docx.
 

#### Syntax
```
procedure Merge(RecordVariant: Variant; SplitDocument: Boolean)
```
#### Parameters
*RecordVariant ([Variant](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/variant/variant-data-type))* 

The Record to take data from, any filters on the Record will be respected.

*SplitDocument ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Specifies whether a separate document per record should be created.

### Merge (Method) <a name="Merge"></a> 

 Performs mail merge on set template and data taken from the given Record. Output document type is of specified save format.
 

#### Syntax
```
procedure Merge(RecordVariant: Variant; SplitDocument: Boolean; SaveFormat: Enum "Word Templates Save Format")
```
#### Parameters
*RecordVariant ([Variant](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/variant/variant-data-type))* 

The Record to take data from, any filters on the Record will be respected.

*SplitDocument ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Specifies whether a separate document per record should be created.

*SaveFormat ([Enum "Word Templates Save Format"]())* 

Format of the document to generate.

### AddTable (Method) <a name="AddTable"></a> 

 Add a table to the list of available tables for Word templates.
 

#### Syntax
```
procedure AddTable(TableID: Integer)
```
#### Parameters
*TableID ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 

The ID of the table to add.

### GetTableId (Method) <a name="GetTableId"></a> 

 Get the table ID for this Template.
 

The function Load needs to be called before this function.

#### Syntax
```
procedure GetTableId(): Integer
```
#### Return Value
*[Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type)*



## Word Template Creation Wizard (Page 9995)

 Wizard to create a Word template.
 

### SetTableNo (Method) <a name="SetTableNo"></a> 
#### Syntax
```
procedure SetTableNo(Value: Integer)
```
#### Parameters
*Value ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 



### OnSetTableNo (Event) <a name="OnSetTableNo"></a> 
#### Syntax
```
[IntegrationEvent(false, false)]
local procedure OnSetTableNo(Value: Integer)
```
#### Parameters
*Value ([Integer](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/integer/integer-data-type))* 




## Word Templates (Page 9989)

 Presents a list of available Word templates.
 


## Word Template Selection Wizard (Page 9996)

 A wizard to select a Word template and apply it for a record.
 

### SetTemplate (Method) <a name="SetTemplate"></a> 

 Sets the template to apply. If not set, the user will be prompted to choose a template as part of the wizard.
 

#### Syntax
```
procedure SetTemplate(WordTemplate: Record "Word Template")
```
#### Parameters
*WordTemplate ([Record "Word Template"]())* 

The template to set.

### SetData (Method) <a name="SetData"></a> 

 Sets the record to be used when applying the template.
 

#### Syntax
```
procedure SetData(RecordVariant: Variant)
```
#### Parameters
*RecordVariant ([Variant](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/variant/variant-data-type))* 

The record to set.


## Word Templates Table Lookup (Page 9988)

 A look-up page to select a table to be used in a Word template.
 

### GetRecord (Method) <a name="GetRecord"></a> 
#### Syntax
```
procedure GetRecord(var SelectedRecord: Record "Word Templates Table")
```
#### Parameters
*SelectedRecord ([Record "Word Templates Table"]())* 




## Word Templates Save Format (Enum 9987)

 Specifies the available formats in which the user can generate documents from Word templates.
 

### Doc (value: 10)


 Saves the document in the Microsoft Word 97 - 2007 Document format.
 

### Docx (value: 20)


 Saves the document as an Office Open XML WordprocessingML Document (macro-free).
 

### PDF (value: 40)


 Saves the document as PDF (Adobe Portable Document) format.
 

### Html (value: 50)


 Saves the document in the HTML format.
 

### Text (value: 70)


 Saves the document in the plain text format.
 

