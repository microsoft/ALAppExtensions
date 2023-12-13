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

### 1. Create and setup new extension

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

### 2. Implement the document Interface.

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

### 3. Implement the integration interface.

The E-Document integration interface comprises a collection of methods designed to streamline the process of integrating with endpoints for submitting electronic documents.

First, you will need to extend the enum and associate it with your implementation codeunit:

```
enumextension 50101 "EDocument Integration Ext" extends "E-Document Integration"
{
    value(50100; "Example Service")
    {
        Implementation = "E-Document Integration" = "Example Integration SVC";
    }
}
```

Here's an example of how you could implement each of the methods within the interface:

- Send: use it to send an E-Document to external service.

```
    procedure Send(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; var IsAsync: Boolean; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage);
    var
        // Record that hold integration setup
        ExampleIntegration: Record "Example - Test Integration";
        HttpClient: HttpClient;
        Payload: Text;
    begin
        ExampleIntegration.Get();
        Payload := EDocumentHelper.TempBlobToTxt(TempBlob);

        // Manipulate the payload and set the headers if needed
        HttpRequest.Content.WriteFrom(Payload);
        HttpRequest.Method := 'POST';
        HttpRequest.SetRequestUri(ExampleIntegration."Sending Endpoint");

        HttpClient.Send(HttpRequest, HttpResponse);

        // Parse the response if needed.
    end;
```

- SendBatch: use it to send a batch of E-Documents to external service.

```
    procedure SendBatch(var EDocuments: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; var IsAsync: Boolean; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage);
    var
        // Record that hold integration setup
        ExampleIntegration: Record "Example - Test Integration";
        HttpClient: HttpClient;
        Payload: Text;
    begin
        ExampleIntegration.Get();
        Payload := EDocumentHelper.TempBlobToTxt(TempBlob);

        // Manipulate the payload and set the headers if needed
        HttpRequest.Content.WriteFrom(Payload);
        HttpRequest.Method := 'POST';
        HttpRequest.SetRequestUri(ExampleIntegration."Sending Endpoint");

        HttpClient.Send(HttpRequest, HttpResponse);

        // Parse the response if needed.
    end;
```

- GetResponse: use it to get response of async send request.

```
    procedure GetResponse(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean;
    var
        // Record that hold integration setup
        ExampleIntegration: Record "Example - Test Integration";
        HttpClient: HttpClient;
    begin
        ExampleIntegration.Get();

        // Manipulate the payload and set the headers if needed
        HttpRequest.Method := 'GET';
        HttpRequest.SetRequestUri(ExampleIntegration."Get Response Endpoint");

        HttpClient.Send(HttpRequest, HttpResponse);

        // Parse the response if needed.
    end;
```

- GetApproval: use it to check if document is approved or rejected.

```
    procedure GetResponse(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean;
    var
        // Record that hold integration setup
        ExampleIntegration: Record "Example - Test Integration";
        HttpClient: HttpClient;
    begin
        ExampleIntegration.Get();

        // Manipulate the payload and set the headers if needed
        HttpRequest.Method := 'GET';
        HttpRequest.SetRequestUri(ExampleIntegration."Get Response Endpoint");

        HttpClient.Send(HttpRequest, HttpResponse);

        // Parse the response if needed.
    end;
```

- GetApproval: Use it to check if document is approved or rejected.

```
    procedure GetApproval(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean;
    var
        // Record that hold integration setup
        ExampleIntegration: Record "Example - Test Integration";
        HttpClient: HttpClient;
    begin
        ExampleIntegration.Get();

        // Manipulate the payload and set the headers if needed
        HttpRequest.Method := 'GET';
        HttpRequest.SetRequestUri(ExampleIntegration."Get Approval Endpoint");

        HttpClient.Send(HttpRequest, HttpResponse);

        // Parse the response if needed.
    end;
```

- Cancel: use it to send a cancel request for an E-Document.

```
    procedure Cancel(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage): Boolean;
    var
        // Record that hold integration setup
        ExampleIntegration: Record "Example - Test Integration";
        HttpClient: HttpClient;
    begin
        ExampleIntegration.Get();

        // Manipulate the payload and set the headers if needed
        HttpRequest.Method := 'Delete';
        HttpRequest.SetRequestUri(ExampleIntegration."Cancel Endpoint");

        HttpClient.Send(HttpRequest, HttpResponse);

        // Parse the response if needed.
    end;
```

- ReceiveDocument: use it to receive E-Document from external service.

```
   procedure ReceiveDocument(var TempBlob: Codeunit "Temp Blob"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage);
    var
        // Record that hold integration setup
        ExampleIntegration: Record "Example - Test Integration";
        HttpClient: HttpClient;
        Result: Text;
    begin
        ExampleIntegration.Get();

        HttpRequest.Method := 'GET';
        HttpRequest.SetRequestUri(ExampleIntegration."Receiving Endpoint");

        HttpClient.Send(HttpRequest, HttpResponse);

        HttpResponse.Content.ReadAs(Result);
        WriteToTempBlob(TempBlob, Result);
    end;
```

- GetDocumentCountInBatch: use it to define how many received documents in batch import.

```
    procedure GetDocumentCountInBatch(var TempBlob: Codeunit "Temp Blob"): Integer
    begin
        // Parse the TempBlob to find how many documents in the batch.
        exit(1);
    end;

```

- GetIntegrationSetup: use it to define the integration setup of a service

```
    procedure GetIntegrationSetup(var SetupPage: Integer; var SetupTable: Integer)
    begin
        SetupPage := page::"Example - Test Integration";
        SetupTable := Database::"Example - Test Integration";
    end;
```

### 4. Implement Setup Wizard

Create a setup wizard that directs customers through the process of configuring E-Documents, gathering all necessary details for seamless integration with the service.

1. Create Wizard Page
2. First page should show an introduction about the feature
3. Integration Setup information: this can be url endpoints, username/passwords, certificates and schema uris
4. Setup Sending profiles
5. If your service will submit documents to the endpoint, get consent from the user and enable HTTP outgoing calls for document core extension and your localization

Here is an example Wizard

```
page 6138 "Edocument Setup Wizard"
{
    PageType = NavigatePage;
    ApplicationArea = All;
    Caption = 'E-Document setup wizard';

    layout
    {
        area(Content)
        {
            group(MediaStandard)
            {
                Caption = '';
                Editable = false;
                Visible = TopBannerVisible;
                field("MediaResourcesStandard Media Reference"; MediaResourcesStandard."Media Reference")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            group(FirstPage)
            {

                Caption = '';
                Visible = FirstStepVisible;
                group("IntroductionGroup")
                {
                    Caption = 'Welcome to Edocument service';
                    Visible = FirstStepVisible;

                    group(LearnMoreLinkGroup)
                    {
                        Caption = '';

                        field(CanLearnMore; YouCanLearnMoreTxt)
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;
                            Editable = false;
                            MultiLine = true;
                        }
                    }
                }
            }

            group(SetupService)
            {
                Caption = '';
                Visible = SetupServiceStepVisible;

                field("Service Name"; EdocFormat.Code)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Service Name';
                }
                field(Description; EdocFormat.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Document Format"; EdocFormat."Document Format")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Service Integration"; EdocFormat."Service Integration")
                {
                    ApplicationArea = Basic, Suite;
                }

            }

            group(SetupSendingProfiles)
            {
                Caption = '';
                Visible = SetupSendingProfilesStepVisible;

                field(UseWithDefaultDocSendingProfile; UseWithDefaultDocSendingProfile)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Use with default Sending Profile';
                }
            }
            group(FinalPage)
            {
                Visible = FinalStepVisible;
                group("That's it!")
                {
                    Caption = 'That''s it!';

                    group(ChooseFinishGroup)
                    {
                        Caption = '';
                        Visible = true;
                        field(ChooseFinish; ChooseFinishTxt)
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;
                            Editable = false;
                            MultiLine = true;
                        }
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ActionBack)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Back';
                Enabled = BackActionEnabled;
                Visible = BackActionEnabled;
                Image = PreviousRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    NextStep(true);
                end;
            }
            action(ActionNext)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Next';
                Enabled = NextActionEnabled;
                Image = NextRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    NextStep(false);
                end;
            }

            action(ActionFinishAndEnable)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Finish';
                Enabled = FinishActionEnabled;
                Image = Approve;
                InFooterBar = true;

                trigger OnAction()
                begin
                    FinishAndEnableAction();
                end;
            }
        }
    }

    trigger OnInit()
    begin
        LoadTopBanners();
    end;

    trigger OnOpenPage()
    begin
        Step := Step::Start;
        EnableControls();


    end;

    local procedure FinishAndEnableAction()
    var
        EDocumentHelper: codeunit "E-Document Helper";
    begin
        // Insert E-Document Services

        // Insert Document Sending Profile

        // Insert WorkFlows
        // You can find detailed examples in codeunit "E-Document Workflow Setup"

        // Enable EDocument Core extension to send http calls after getting user's consent
        EDocumentHelper.AllowEDocumentCoreHttpCalls();

        // Setup retention policy if needed
    end;

    local procedure LoadTopBanners()
    begin
        if MediaRepositoryStandard.Get('AssistedSetup-NoText-400px.png', Format(ClientTypeManagement.GetCurrentClientType())) and
           MediaRepositoryDone.Get('AssistedSetupDone-NoText-400px.png', Format(ClientTypeManagement.GetCurrentClientType()))
        then
            if MediaResourcesStandard.Get(MediaRepositoryStandard."Media Resources Ref") and
               MediaResourcesDone.Get(MediaRepositoryDone."Media Resources Ref")
            then
                TopBannerVisible := MediaResourcesDone."Media Reference".HasValue;
    end;

    local procedure NextStep(Backwards: Boolean)
    begin

        if Backwards then
            Step -= 1
        else
            Step += 1;

        EnableControls();
    end;

    local procedure EnableControls()
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowStartStep();
            Step::SetupService:
                ShowSetupServiceStep();
            Step::SetupSendingProfiles:
                ShowSetupSendingProfilesStep();
            Step::Finish:
                ShowFinalStep();
        END;
    end;

    local procedure ShowStartStep()
    begin
        FirstStepVisible := true;
        BackActionEnabled := false;
    end;

    local procedure ShowSetupServiceStep()
    begin
        FirstStepVisible := false;
        SetupServiceStepVisible := true;
        SetupSendingProfilesStepVisible := false;
        FinalStepVisible := false;

        BackActionEnabled := true;
    end;

    local procedure ShowSetupSendingProfilesStep()
    begin
        FirstStepVisible := false;
        SetupServiceStepVisible := false;
        SetupSendingProfilesStepVisible := true;
        FinalStepVisible := false;

        BackActionEnabled := true;
    end;

    local procedure ShowFinalStep()
    begin
        FirstStepVisible := false;
        SetupServiceStepVisible := false;
        SetupSendingProfilesStepVisible := false;
        FinalStepVisible := true;

        FinishActionEnabled := true;
        NextActionEnabled := false;
        BackActionEnabled := true;
    end;

    local procedure ResetControls()
    begin
        BackActionEnabled := true;
        NextActionEnabled := true;

        FirstStepVisible := false;
        SetupServiceStepVisible := false;
        SetupSendingProfilesStepVisible := false;
        FinalStepVisible := false;
    end;

    var
        MediaRepositoryStandard: Record "Media Repository";
        MediaRepositoryDone: Record "Media Repository";
        MediaResourcesStandard: Record "Media Resources";
        MediaResourcesDone: Record "Media Resources";
        EdocFormat: Record "E-Document Service" temporary;
        ClientTypeManagement: Codeunit "Client Type Management";

        Step: Option Start,SetupService,SetupSendingProfiles,Finish;
        TopBannerVisible: Boolean;
        BackActionEnabled, NextActionEnabled, FinishActionEnabled : Boolean;
        FirstStepVisible, SetupServiceStepVisible, SetupSendingProfilesStepVisible, FinalStepVisible : Boolean;
        UseWithDefaultDocSendingProfile: Boolean;
        YouCanLearnMoreTxt: Label 'This wizard helps you to setup a connection to an electronic invoicing setup.';
        ChooseFinishTxt: Label 'Click ''Finish'' to insert the service connection. \You will still have to setup the settings for the endpoint and import/export mapping.';
}
```

#### Helper Procedures

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

### Missing a feature

If you believe there are any essential features that could enhance the ease of developing an e-document solution, kindly get in touch by generating an issue in this repository titled "E-document: < details >", and we will get back to you.
