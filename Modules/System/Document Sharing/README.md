Enable document sharing flows through a valid document service
# Public Objects

## Document Sharing (Table 9560)

 Table stores state information about the document to be shared.
 
 To share a document some fields need to be set before initializing the share flow:

 ```
 TempDocumentSharing.Name := 'My Shared Document.pdf';
 TempDocumentSharing.Extension := '.pdf';
 TempDocumentSharing.Data := "Document Blob";
 TempDocumentSharing.Insert();

 // Invoke the document sharing codeunit with the rec
 DocumentSharing.Run(TempDocumentSharing);
```

## Document Sharing (Codeunit 9560)
 Codeunit which performs the document sharing. Must be ran with a valid temporary Document Sharing record.

### OnRun (Method) <a name="OnRun"></a> 

 Triggers the document sharing flow. Must provide a valid Document Sharing record (see above).
 

#### Syntax
```
procedure OnRun()
```

### Share (Method) <a name="Share"></a> 

 Performs the same as OnRun, triggers the document sharing flow with the Document Sharing record provided.

#### Syntax
```
procedure Share(var DocumentSharingRec: Record "Document Sharing")
```

### ShareEnabled (Method) <a name="ShareEnabled"></a> 

 Returns true if Document Sharing is enabled. Use this as a quick test to, for example, control visibility of a share action.

#### Syntax
```
procedure ShareEnabled(): Boolean
```

#### Return Value
*[Boolean](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/boolean/boolean-data-type)*
