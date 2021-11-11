Enable document sharing flows through a valid document service
# Public Objects
## Document Sharing (Table 9560)

 Table containing the required state for document sharing.
 


## Document Sharing (Codeunit 9560)

 Codeunit to invoke document sharing flow.
 

### Share (Method) <a name="Share"></a> 

  TempDocumentSharing.Name := 'My Shared Document.pdf';
  TempDocumentSharing.Extension := '.pdf';
  TempDocumentSharing.Data := "Document Blob";
  TempDocumentSharing.Insert();
  DocumentSharing.Share(TempDocumentSharing);
 


 Triggers the document sharing flow.
 

#### Syntax
```
procedure Share(var DocumentSharingRec: Record "Document Sharing")
```
#### Parameters
*DocumentSharingRec ([Record "Document Sharing"]())* 

The record to invoke the share with.

### ShareEnabled (Method) <a name="ShareEnabled"></a> 

 Checks if document sharing is enabled.
 

#### Syntax
```
procedure ShareEnabled(): Boolean
```
#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*

Returns true if sharing is enabled, false otherwise.
### OnUploadDocument (Event) <a name="OnUploadDocument"></a> 

 Raised when the document needs to be uploaded.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnUploadDocument(var DocumentSharing: Record "Document Sharing" temporary; var Handled: Boolean)
```
#### Parameters
*DocumentSharing ([Record "Document Sharing" temporary]())* 

The record containing the document to be shared.

*Handled ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Specifies whether the event has been handled and no further execution should occur.

### OnCanUploadDocument (Event) <a name="OnCanUploadDocument"></a> 

 Raised to test if there are any document services that can handle the upload.
 

#### Syntax
```
[IntegrationEvent(false, false)]
internal procedure OnCanUploadDocument(var CanUpload: Boolean)
```
#### Parameters
*CanUpload ([Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type))* 

Specifies whether there is a subscriber that can handle the upload.


## Document Sharing (Page 9560)

 Page which will host the document service share ux
 

