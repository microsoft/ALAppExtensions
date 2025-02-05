# E-Document Core

- [Getting Started](#getting-started)
- [How to Develop localization extension](#how-to-develop-localization-extension)

  1. [Create and setup new extension](#1-create-and-setup-new-extension)
  2. [Implement the document Interface](#2-implement-the-document-interface)
  3. [Implement the integration interface.](#3-implement-the-integration-interface)
  4. [Implement Setup wizard](#4-implement-setup-wizard)

- [Missing a feature?](#missing-a-feature)

## Getting Started

## How to Develop localization extension

In order to implement your localization on top of EDocument core application, you should undertake the following steps.

# 1. Create and setup new extension

Create a new extension and add dependency to "EDocument Core" application
In your app.json file, add dependency on "EDocument" extension:

```
"dependencies": [
    {
        "id":  "e1d97edc-c239-46b4-8d84-6368bdf67c8b",
        "name":  "E-Document Core",
        "publisher":  "Microsoft",
        "version":  "23.0.0.0"
    }
]
```

# 2. Implement the document Interface.

The E-Document interface comprises a collection of methods designed to streamline the export of Business Central documents (such as Sales Invoices) into E-Document blobs based on predefined format specifications. Furthermore, it facilitates the reverse process by enabling the import of documents from blobs back into Business Central.

First, you will need to extend the enum and associate it with your implementation codeunit:

```
enumextension 50100 "EDocument Format Ext" extends "E-Document Format"
{
    value(50100; "PEPPOL 3.x")
    {
        Implementation = "E-Document" = "PEPPOL EDocument";
    }
}
```

The document interface has been divided into two sections:

- Create an E-Document from a Business Central document that can be sent to a designated endpoint: Check, Create, CreateBatch
- Receive a document from the endpoint: GetBasicInfo, PrepareDocument

Here's an example of how you could implement each of the methods within the interface:

- Check: use it to run check on release/post action of a document to make sure all necessary fields to submit the document are available.

```
    procedure Check(var SourceDocumentHeader: RecordRef; EDocumentService: Record "E-Document Service"; EDocumentProcessingPhase: Enum "E-Document Processing Phase")
    var
        SalesHeader: Record "Sales Header";
    begin

        Case SourceDocumentHeader.Number of
            Database::"Sales Header":
                begin
                    SourceDocumentHeader.Field(SalesHeader.FieldNo("Customer Posting Group")).TestField();
                    SourceDocumentHeader.Field(SalesHeader.FieldNo("Posting Date")).TestField();
                end;
        End;
```

You also have the option to perform distinct checks depending on document processing phase.

```
    procedure Check(var SourceDocumentHeader: RecordRef; EDocumentService: Record "E-Document Service"; EDocumentProcessingPhase: Enum "E-Document Processing Phase")
    var
        SalesHeader: Record "Sales Header";
    begin

        Case SourceDocumentHeader.Number of
            Database::"Sales Header":
                case EDocumentProcessingPhase of
                    EDocumentProcessingPhase::Release:
                        begin
                            SourceDocumentHeader.Field(SalesHeader.FieldNo("Customer Posting Group")).TestField();
                            SourceDocumentHeader.Field(SalesHeader.FieldNo("Posting Date")).TestField();
                        end;
                    EDocumentProcessingPhase::Post:
                        begin
                            SourceDocumentHeader.Field(SalesHeader.FieldNo("Customer Posting Group")).TestField();
                            SourceDocumentHeader.Field(SalesHeader.FieldNo("Posting Date")).TestField();
                            SourceDocumentHeader.Field(SalesHeader.FieldNo("Bill-to Name")).TestField();
                        end;
                end;
        End;
    end;
```

- Create: Use it to create a blob representing the posted document.
  At this point, the core extension has created an "E-Document" record with initial information like the document type , and automatically determined the type of the document, that you can find in "Document Type" field.

> Note: The document type is automatically identified by the core extension based on the source document. In case you have introduced your custom document type, you will need to extend the "E-Document Type" enum and populate the "E-Document Type" field accordingly.

```
procedure Create(EDocumentService: Record "E-Document Service"; var EDocument: Record "E-Document"; var SourceDocumentHeader: RecordRef; var SourceDocumentLines: RecordRef; var TempBlob: Codeunit "Temp Blob")
    var
        OutStr: OutStream;
    begin
        TempBlob.CreateOutStream(OutStr);

        case EDocument."Document Type" of
            EDocument."Document Type"::"Sales Invoice":
                GenerateInvoiceXMLFile(SourceDocumentHeader, OutStr);
            EDocument."Document Type"::"Sales Credit Memo":
                GenerateCrMemoXMLFile(SourceDocumentHeader, OutStr);
        end;
    end;
```

- CreateBatch: use it to create a blob representing a batch of posted documents.
  Similar to create method, this functionality permits you to iterate through a collection of E-Documents and generate a singular blob that collectively represents them.

```
procedure CreateBatch(EDocumentService: Record "E-Document Service"; var EDocuments: Record "E-Document"; var SourceDocumentHeaders: RecordRef; var SourceDocumentsLines: RecordRef; var TempBlob: Codeunit "Temp Blob")
    var
        OutStr: OutStream;
    begin
        TempBlob.CreateOutStream(OutStr);
        if EDocuments.FindSet() then
            repeat
                OutStr.WriteText(EDocuments."Document No.");
            until EDocuments.Next() = 0;
    end;
```

- GetBasicInfo: use it to get the basic information of an E-Document from received blob.

```
procedure GetBasicInfo(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob")
    var
        XmlDoc: XmlDocument;
        DocInstr: InStream;
        NamespaceManager: XmlNamespaceManager;
    begin
        // Create an XML document from the blob
        TempBlob.CreateInStream(DocInstr);
        XmlDocument.ReadFrom(DocInstr, XmlDoc);

        // Parse the document to fill EDocument information
        EDocument."Bill-to/Pay-to No." := CopyStr(GetPEPPOLNode('//cac:InvoiceLine/cbc:ID', XmlDoc, NamespaceManager), 1, 20);
        EDocument."Bill-to/Pay-to Name" := CopyStr(GetPEPPOLNode('//cac:AccountingCustomerParty/cac:Party/cac:PartyName/cbc:Name', XmlDoc, NamespaceManager), 1, 20);
        Evaluate(EDocument."Document Date", GetPEPPOLNode('//cbc:IssueDate', XmlDoc, NamespaceManager));
        EDocument."Document Type" := EDocument."Document Type"::"Purchase Invoice";
    end;
```

- PrepareDocument: Use it to create a document from imported blob.

```
procedure PrepareDocument(var EDocument: Record "E-Document"; var CreatedDocumentHeader: RecordRef; var CreatedDocumentLines: RecordRef; var TempBlob: Codeunit "Temp Blob")
    begin

    end;
```

> Note: The "Create" and "CreateBatch" methods will generate a blob that is stored in the log table. When a user exports it, the EDocument core will export it without a predefined file extension. If you wish to specify the file extension, you can utilize the following event subscriber:

```
    [EventSubscriber(ObjectType::Table, Database::"E-Document Log", 'OnBeforeExportDataStorage', '', false, false)]
    local procedure MyProcedure()
    begin
    end;
```

# 3. Implement the integration interface.



The E-Document integration interface comprises a collection of methods designed to streamline the process of integrating with endpoints for submitting electronic documents.

First, you will need to extend the enum and associate it with your implementation codeunit:

```
enumextension 50100 Integration extends "Service Integration"
{
    value(50100; "Avalara")
    {
        Implementation = IDocumentSender = "Integration Impl.", IDocumentReceiver = "Integration Impl.";
    }
}
```

## Sending

Here's an example of how you could implement each of the methods within the IDocumentSender interface:

The `IDocumentSender` interface defines methods for sending E-Documents to an external service. By implementing this interface, you enable integration between an application and external E-Document services. This interface is part of the `Microsoft.eServices.EDocument.Integration.Interfaces` namespace and facilitates asynchronous and batch operations while ensuring proper logging of communication details.

### Key Features
- **Async Sending:** Supports asynchronous sending of E-Documents.
- **Batch Processing:** Enables sending multiple E-Documents using filters.
- **Automatic Logging:** Automatically logs HTTP request content and headers when provided in `SendContext`.

### How to Implement
To implement the `IDocumentSender` interface, you need to provide logic for the `Send` procedure, which handles sending E-Documents. Below is a detailed guide and example implementations.

### `Send` Method
The `Send` method is responsible for sending an E-Document to an external service. It takes three parameters:

- `EDocument`: The record representing the E-Document to be sent.
- `EDocumentService`: The record containing service configuration details such as the URL and access tokens.
- `SendContext`: A codeunit that provides context and resources for the send operation.

#### Example Implementation
Here is an example implementation of the `Send` method:

```al
procedure Send(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext)
var
    MyServiceSetup: Record MyServiceSetup;
    TempBlob: Codeunit "Temp Blob";
    HttpClient: HttpClient;
    HttpRequest: HttpRequestMessage;
    HttpResponse: HttpResponseMessage;
begin
    // Retrieve the TempBlob from SendContext
    SendContext.GetTempBlob(TempBlob);

    // Prepare the HTTP request using the TempBlob content
    HttpRequest := SendContext.Http().GetHttpRequestMessage();
    HttpRequest.Method := 'POST';
    HttpRequest.SetRequestUri(MyServiceSetup."Service URL");
    SetContent(HttpRequest, TempBlob); // Some method to do that

    // Add authorization headers
    HttpRequest.Headers.Add('Authorization', 'Bearer ' + MyServiceSetup."Access Token");

    // Send the request and capture the response
    HttpClient.Send(HttpRequest, HttpResponse);

    // Handle the response
    if HttpResponse.IsSuccessStatusCode() then
        Message('E-Document sent successfully.');
    else
        Error('Failed to send E-Document: %1', HttpResponse.ReasonPhrase);
end;
```

### Notes for Implementation
1. **Asynchronous Sending:** To support asynchronous sending, ensure that the implementation also includes the `IDocumentResponseHandler` interface. This enables the processing of responses for async requests.
2. **Batch Support:** When handling multiple E-Documents in batch operations, the `EDocument` record is populated using filters.
3. **Error Handling:** Properly handle HTTP response errors and log necessary details for debugging and monitoring.
4. **Logging:** Utilize the `SendContext` to log HTTP request details for traceability.

## Sending Async

The IDocumentResponseHandler interface provides a standardized method for retrieving responses from external E-Document services for asynchronously sent E-Documents. If the service is handling documents async, implement this interface on the same codeunit that implements IDocumentSender.

The primary purpose of the `IDocumentResponseHandler` is to retrieve the status of a previously sent E-Document from the external service and appropriately update the E-Document Service Status based on the response. It also logs relevant HTTP response details automatically for better traceability.

### Key Features
- **Asynchronous Response Handling:** Supports retrieving responses for asynchronously sent E-Documents.
- **Status Updates:** Automatically updates the E-Document status based on the external service's response.
- **Error Management:** Handles errors gracefully, including logging error details.
- **Automatic Logging:** Automatically logs HTTP request and response details when using `SendContext`.

### How to Implement
To implement the `IDocumentResponseHandler` interface, you need to provide logic for the `GetResponse` procedure, which handles retrieving the status of an E-Document. Below is a detailed guide and example implementation.

### `GetResponse` Method
The `GetResponse` method retrieves the response from the external service for an asynchronously sent E-Document. It takes three parameters:

- **`EDocument`**: The record representing the E-Document for which the response is being retrieved.
- **`EDocumentService`**: The record containing service configuration details such as the URL and access tokens.
- **`SendContext`**: A codeunit that provides context and resources for the get-response operation.

#### Example Implementation
Here is an example implementation of the `GetResponse` method:

```al
procedure GetResponse(
    var EDocument: Record "E-Document"; 
    var EDocumentService: Record "E-Document Service"; 
    SendContext: Codeunit SendContext
): Boolean
var
    MyServiceSetup: Record MyServiceSetup;
    HttpClient: HttpClient;
    HttpRequest: HttpRequestMessage;
    HttpResponse: HttpResponseMessage;
begin
    // Prepare the HTTP request to check the status of the E-Document
    HttpRequest := SendContext.Http().GetHttpRequestMessage();
    HttpRequest.Method := 'GET';
    HttpRequest.SetRequestUri(MyServiceSetup."Service URL" + '/status/' + EDocument."Document ID");
    HttpRequest.Headers.Add('Authorization', 'Bearer ' + MyServiceSetup."Access Token");

    // Send the HTTP request
    HttpClient.Send(HttpRequest, HttpResponse);

    // Set the response in SendContext for automatic logging
    SendContext.Http().SetHttpResponseMessage(HttpResponse);

    // Handle the response based on the HTTP status code
    if HttpResponse.IsSuccessStatusCode() then
        exit(true); // The document was successfully processed
    else if HttpResponse.HttpStatusCode() = 202 then
        exit(false); // The document is still being processed
    else begin
        // Log the error and set the status to "Sending Error"
        EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, 'Error retrieving response: ' + Format(HttpResponse.HttpStatusCode()));
        exit(false);
    end;
end;
```

## Receiving

The `IDocumentReceiver` interface provides a standardized method for receiving and downloading electronic documents (E-Documents) from external API services. If your system requires integration with an E-Document service, implement this interface to handle document retrieval and data download operations efficiently.

### Key Features
- **Document Retrieval**: Fetch one or more E-Documents from an external API and store their metadata in temporary blobs for processing.
- **Content Download**: Download the specific content (e.g., XML, PDF) of a document using its metadata.
- **Error Handling**: Log and handle errors gracefully during the retrieval and download processes.
- **Context Management**: Utilize `ReceiveContext` for managing HTTP requests and responses.

### How to Implement
To implement the `IDocumentReceiver` interface, you need to provide logic for the `ReceiveDocuments` and `DownloadDocument` methods. Below are detailed explanations and example implementations.

### `ReceiveDocuments` Method
The `ReceiveDocuments` method retrieves one or more documents from the external API and stores their metadata in temporary blobs for further processing.

#### Parameters
- **`EDocumentService`**: Record representing the E-Document Service configuration, including the API endpoint.
- **`DocumentsMetadata`**: Temporary blob list for storing retrieved document metadata.
- **`ReceiveContext`**: A codeunit providing context and resources for the receive operation.

#### Example Implementation
```al
procedure ReceiveDocuments(var EDocumentService: Record "E-Document Service"; DocumentsMetadata: Codeunit "Temp Blob List"; ReceiveContext: Codeunit ReceiveContext)
var
    HttpRequest: HttpRequestMessage;
    JsonResponse: JsonArray;
    DocumentBlob: Codeunit "Temp Blob";
    JsonObject: JsonObject;
    OutStream: OutStream;
begin
    // Prepare the HTTP request
    HttpRequest := ReceiveContext.Http().GetHttpRequestMessage();
    HttpRequest.Method := 'GET';
    HttpRequest.SetRequestUri(EDocumentService."Service URL" + '/documents');

    // Send the HTTP request
    HttpClient.Send(HttpRequest, ReceiveContext.Http().GetHttpResponseMessage());

    // Parse the JSON response
    JsonResponse.ReadFrom(HttpResponse.ContentAsText());

    // Iterate over each object in the JSON array and add a temp blob to the DocumentsMetadata list
    foreach JsonObject in JsonResponse do begin
        DocumentBlob.CreateOutStream(OutStream);
        JsonObject.WriteTo(OutStream);
        DocumentsMetadata.Add(DocumentBlob);
    end;
end;
```

---

### `DownloadDocument` Method
The `DownloadDocument` method downloads the content of a specific document (e.g., XML, PDF) using the document metadata.

#### Parameters
- **`EDocument`**: Record representing the specific E-Document.
- **`EDocumentService`**: Record containing service configuration details such as the URL and authentication tokens.
- **`DocumentMetadata`**: Temporary blob containing the metadata for the document.
- **`ReceiveContext`**: A codeunit providing context and resources for the download operation.

#### Example Implementation
```al
procedure DownloadDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; DocumentMetadata: Codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
var
    Request: Codeunit Requests;
    HttpExecutor: Codeunit "Http Executor";
    ResponseContent: Text;
    InStream: InStream;
    DocumentId: Text;
    OutStream: OutStream;
begin
    // Read the document ID from the DocumentMetadata
    DocumentMetadata.CreateInStream(InStream, TextEncoding::UTF8);
    InStream.ReadText(DocumentId);

    if DocumentId = '' then begin
        EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, DocumentIdNotFoundErr);
        exit;
    end;

    // Update the document record with the document ID
    EDocument."Document Id" := CopyStr(DocumentId, 1, MaxStrLen(EDocument."Document Id"));
    EDocument.Modify();

    // Prepare the HTTP request
    Request.Init();
    Request.Authenticate().CreateDownloadRequest(DocumentId);
    ReceiveContext.Http().SetHttpRequestMessage(Request.GetRequest());

    // Execute the HTTP request
    ResponseContent := HttpExecutor.ExecuteHttpRequest(Request, ReceiveContext.Http().GetHttpResponseMessage());

    // Store the response in the ReceiveContext
    ReceiveContext.GetTempBlob().CreateOutStream(OutStream, TextEncoding::UTF8);
    OutStream.WriteText(ResponseContent);
end;
```

## Sent Document Actions

The `ISentDocumentActions` interface provides a set of default actions for managing outgoing E-Documents through integration with external APIs. This interface simplifies the process of communicating with external services to manage document statuses effectively. Developers can use the provided methods to handle approval and cancellation processes seamlessly, ensuring accurate status updates within the system.

### Key Features

These actions allow you to:

- **Check Approval Status**: Verify whether a sent E-Document has been approved by the external service.
- **Check Cancellation Status**: Determine whether a sent E-Document has been successfully canceled by the external service.
- **Streamline Integration**: Standardize HTTP request handling for approval and cancellation workflows.

### How to Implement

To use the `ISentDocumentActions` interface, you need to implement the `GetApprovalStatus` and `GetCancellationStatus` methods. Each method interacts with the external API to manage the status of E-Documents.

### `GetApprovalStatus` Method

#### Parameters
- `EDocument`: Record of type "E-Document" representing the document to be approved.
- `EDocumentService`: Record of type "E-Document Service" for interacting with the external API.
- `ActionContext`: Codeunit `ActionContext` for managing HTTP requests and responses.

#### Example Implementation
```al
procedure GetApprovalStatus(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; ActionContext: Codeunit ActionContext): Boolean
var
    Request: Codeunit Requests;
    HttpExecutor: Codeunit "Http Executor";
    ResponseContent: Text;
begin
    // Prepare the HTTP request
    Request.Init();
    Request.Authenticate().CreateApprovalRequest(EDocument."Document ID");
    ActionContext.Http().SetHttpRequestMessage(Request.GetRequest());

    // Execute the HTTP request
    ResponseContent := HttpExecutor.ExecuteHttpRequest(Request, ActionContext.Http().GetHttpResponseMessage());

    // Process the response to determine the approval status
    if ResponseContent.Contains('approved') then begin
        ActionContext.SetStatus(ActionContext.GetStatus()."Approved");
        exit(true);
    end else if ResponseContent.Contains('rejected') then begin
        ActionContext.SetStatus(ActionContext.GetStatus()."Rejected");
        exit(true);
    end;

    exit(false);
end;
```

### `GetCancellationStatus` Method

#### Parameters
- `EDocument`: Record of type "E-Document" representing the document to be canceled.
- `EDocumentService`: Record of type "E-Document Service" for interacting with the external API.
- `ActionContext`: Codeunit `ActionContext` for managing HTTP requests and responses.

#### Example Implementation
```al
procedure GetCancellationStatus(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; ActionContext: Codeunit ActionContext): Boolean
var
    Request: Codeunit Requests;
    HttpExecutor: Codeunit "Http Executor";
    ResponseContent: Text;
begin
    // Prepare the HTTP request
    Request.Init();
    Request.Authenticate().CreateCancellationRequest(EDocument."Document ID");
    ActionContext.Http().SetHttpRequestMessage(Request.GetRequest());

    // Execute the HTTP request
    ResponseContent := HttpExecutor.ExecuteHttpRequest(Request, ActionContext.Http().GetHttpResponseMessage());

    // Process the response to determine the cancellation status
    if ResponseContent.Contains('canceled') then begin
        ActionContext.SetStatus(ActionContext.GetStatus()."Canceled");
        exit(true);
    end;

    exit(false);
end;
```

## Document Action

### Key Features

The `IDocumentAction` interface defines a general-purpose method for performing various actions on E-Documents. It allows developers to:

- **Perform Custom Actions**: Execute specified actions, such as resetting or updating the status of an E-Document.
- **Flexibly Integrate**: Use this interface to handle API requests and responses tailored to the specific action type.
- **Streamline Workflows**: Centralize action execution logic for consistent and maintainable integration. 
- **Handles Logging and Error Handling**: When using an action using the interface, you get all the logging and error handling for free. All build directly in the framework.

### How to Implement

To use the `IDocumentAction` interface, implement the `InvokeAction` method. This method executes a specified action by interacting with the external API and updates the E-Document status accordingly. Then extend the actions enum and call the `procedure InvokeAction(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; ActionType: Enum "Integration Action Type"; ActionContext: Codeunit ActionContext)` in the Integration Management codeunit to run the action. You can call this from your own action.

### `InvokeAction` Method

#### Parameters

- `EDocument`: Record of type "E-Document" representing the document on which the action is performed.
- `EDocumentService`: Record of type "E-Document Service" for interacting with the external API.
- `ActionContext`: Codeunit `ActionContext` for managing HTTP requests and responses.

#### Example Implementation

```al
procedure InvokeAction(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; ActionContext: Codeunit ActionContext): Boolean
var
    HttpClient: HttpClient;
    HttpRequestMessage: HttpRequestMessage;
    HttpResponseMessage: HttpResponseMessage;
begin
    // Initialize the HTTP request
    HttpRequestMessage.Method := 'POST';
    HttpRequestMessage.SetRequestUri('https://api.example.com/documents/reset');
    HttpRequestMessage.Content.WriteFromText('{"documentId": "' + EDocument."Document ID" + '"}');

    // Send the HTTP request and receive the response
    HttpClient.Send(HttpRequestMessage, HttpResponseMessage);

    // Process the response and set status
    if HttpResponseMessage.IsSuccessStatusCode() then begin
        ActionContext.SetStatus(Enum::"E-Document Service Status"::"MyStatus");
        exit(true);
    end;

    exit(false);
end;
```

## Helper Procedures

There is a set of EDocument Helper codeunit that consists of collection of utility methods that are highly recommended for building your localization app. These methods can assist you in various tasks, such as effortlessly logging any encountered error messages.

Codeunit list:

- "E-Document Helper"
- "E-Document Error Helper"
- "E-Document Import Helper"

```
procedure Create(EDocumentService: Record "E-Document Service"; var EDocument: Record "E-Document"; var SourceDocumentHeader: RecordRef; var SourceDocumentLines: RecordRef; var TempBlob: Codeunit "Temp Blob")
    var
        EDocumentHelper: Codeunit "E-Document Helper";
        OutStr: OutStream;
    begin
        TempBlob.CreateOutStream(OutStr);

        case EDocument."Document Type" of
            EDocument."Document Type"::"Sales Invoice":
                if not GenerateInvoiceXMLFile(SourceDocumentHeader, OutStr) then
                    EDocumeneHelper.LogSimpleErrorMessage(EDocument, 'Error <> happened while creating this document');

            EDocument."Document Type"::"Sales Credit Memo":
                if not GenerateCrMemoXMLFile(SourceDocumentHeader, OutStr) then
                    EDocumeneHelper.LogSimpleErrorMessage(EDocument, 'Error <> happened while creating this document');
        end;
    end;
```

## Missing a feature

If you believe there are any essential features that could enhance the ease of developing an e-document solution, kindly get in touch by generating an issue in this repository titled "E-document: < details >", and we will get back to you.
