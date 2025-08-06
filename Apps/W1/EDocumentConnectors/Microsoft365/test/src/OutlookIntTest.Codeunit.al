namespace Microsoft.EServices.EDocumentConnector.Microsoft365;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Receive;
using System.Utilities;
using Microsoft.eServices.EDocument.Integration;

codeunit 148198 "Outlook Int. Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Payables Bookkeeper Agent] E-Document connector for Outlook
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ReceiveSingleIncomingDocument()
    var
        EDocument: Record "E-Document";
        EDocumentLog: Record "E-Document Log";
        EDocDataStorage: Record "E-Doc. Data Storage";
        EDocumentService: Record "E-Document Service";
        EDocIntegrationManagement: Codeunit "E-Doc. Integration Management";
        ReceiveContext: Codeunit ReceiveContext;
        InitialIncomingDocumentCount: Integer;
        TestInStream: InStream;
        EDocDataStorageContentTxt: Text;
    begin
        // [SCENARIO 540007] When using Receive Document functionality, and there is one document available in the specified Outlook shared mailbox, one e-document is correctly created with attachment and name

        // [GIVEN] A setup for importing Outlook attachments as e-documents
        // [GIVEN] That one document is available (in test, this is determined by description TestImportOneDocumentTxt)
        Initialize(EDocumentService, Enum::"Service Integration"::TestOutlook, TestImportOneDocumentTxt);
        InitialIncomingDocumentCount := EDocument.Count();

        // [WHEN] ReceiveDocument method is called (either from UI or from scheduled task)
        EDocIntegrationManagement.ReceiveDocuments(EDocumentService, ReceiveContext);

        // [THEN] One new e-document is created with correct name and attachment
        Assert.AreEqual(InitialIncomingDocumentCount + 1, EDocument.Count(), '');
        EDocument.SetRange("File Name", 'Propsoal.pdf');
        Assert.IsTrue(EDocument.FindLast(), '');
        EDocumentLog.SetRange("E-Doc. Entry No", EDocument."Entry No");
        Assert.IsTrue(EDocumentLog.FindFirst(), '');
        Assert.IsTrue(EDocDataStorage.Get(EDocumentLog."E-Doc. Data Storage Entry No."), '');
        EDocDataStorage.CalcFields("Data Storage");
        EDocDataStorage."Data Storage".CreateInStream(TestInStream);
        TestInStream.ReadText(EDocDataStorageContentTxt);
        Assert.AreEqual('1', EDocDataStorageContentTxt, '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ReceiveOnlyPdfDocument()
    var
        EDocument: Record "E-Document";
        EDocumentLog: Record "E-Document Log";
        EDocDataStorage: Record "E-Doc. Data Storage";
        EDocumentService: Record "E-Document Service";
        EDocIntegrationManagement: Codeunit "E-Doc. Integration Management";
        ReceiveContext: Codeunit ReceiveContext;
        InitialIncomingDocumentCount: Integer;
        TestInStream: InStream;
        EDocDataStorageContentTxt: Text;
    begin
        // [SCENARIO 540007] When using Receive Document functionality, and there are two documents available in the specified Outlook shared mailbox, one e-document is not a PDF

        // [GIVEN] A setup for importing Outlook attachments as e-documents
        // [GIVEN] That one document is downloaded (in test, this is determined by description TestImportOnlyPdfDocumentsTxt)
        Initialize(EDocumentService, Enum::"Service Integration"::TestOutlook, TestImportOnlyPdfDocumentsTxt);
        InitialIncomingDocumentCount := EDocument.Count();

        // [WHEN] ReceiveDocument method is called (either from UI or from scheduled task)
        EDocIntegrationManagement.ReceiveDocuments(EDocumentService, ReceiveContext);

        // [THEN] One new e-document is created with correct name and attachment
        Assert.AreEqual(InitialIncomingDocumentCount + 1, EDocument.Count(), '');
        EDocument.SetRange("File Name", 'DoImport.pdf');
        Assert.IsTrue(EDocument.FindFirst(), '');
        EDocumentLog.SetRange("E-Doc. Entry No", EDocument."Entry No");
        Assert.IsTrue(EDocumentLog.FindFirst(), '');
        Assert.IsTrue(EDocDataStorage.Get(EDocumentLog."E-Doc. Data Storage Entry No."), '');
        EDocDataStorage.CalcFields("Data Storage");
        EDocDataStorage."Data Storage".CreateInStream(TestInStream);
        TestInStream.ReadText(EDocDataStorageContentTxt);
        Assert.AreEqual('1', EDocDataStorageContentTxt, '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ReceiveMultipleIncomingDocument()
    var
        EDocument: Record "E-Document";
        EDocumentLog: Record "E-Document Log";
        EDocDataStorage: Record "E-Doc. Data Storage";
        EDocumentService: Record "E-Document Service";
        EDocIntegrationManagement: Codeunit "E-Doc. Integration Management";
        ReceiveContext: Codeunit ReceiveContext;
        InitialIncomingDocumentCount: Integer;
        TestInStream: InStream;
        EDocDataStorageContentTxt: Text;
    begin
        // [SCENARIO 540007] When using Receive Document functionality, and there are multiple documents available in the specified Outlook shared mailbox, one e-document is correctly created with attachment and name

        // [GIVEN] A setup for importing Outlook attachments as e-documents
        // [GIVEN] That multiple documents are available (in test, this is determined by description TestImportTwoDocumentsTxt)
        Initialize(EDocumentService, Enum::"Service Integration"::TestOutlook, TestImportTwoDocumentsTxt);
        InitialIncomingDocumentCount := EDocument.Count();

        // [WHEN] ReceiveDocument method is called (either from UI or from scheduled task)
        EDocIntegrationManagement.ReceiveDocuments(EDocumentService, ReceiveContext);

        // [THEN] Two new e-documents are created with correct name and attachment
        Assert.AreEqual(InitialIncomingDocumentCount + 2, EDocument.Count(), '');
        EDocument.SetRange("File Name", 'Propsoal.pdf');
        Assert.IsTrue(EDocument.FindLast(), '');
        EDocumentLog.SetRange("E-Doc. Entry No", EDocument."Entry No");
        Assert.IsTrue(EDocumentLog.FindFirst(), '');
        Assert.IsTrue(EDocDataStorage.Get(EDocumentLog."E-Doc. Data Storage Entry No."), '');
        EDocDataStorage.CalcFields("Data Storage");
        EDocDataStorage."Data Storage".CreateInStream(TestInStream);
        TestInStream.ReadText(EDocDataStorageContentTxt);
        Assert.AreEqual('1', EDocDataStorageContentTxt, '');
        Clear(TestInStream);
        EDocument.SetRange("File Name", 'Medical-Bill-Receipt.pdf');
        Assert.IsTrue(EDocument.FindFirst(), '');
        EDocumentLog.SetRange("E-Doc. Entry No", EDocument."Entry No");
        Assert.IsTrue(EDocumentLog.FindFirst(), '');
        Assert.IsTrue(EDocDataStorage.Get(EDocumentLog."E-Doc. Data Storage Entry No."), '');
        EDocDataStorage.CalcFields("Data Storage");
        EDocDataStorage."Data Storage".CreateInStream(TestInStream);
        TestInStream.ReadText(EDocDataStorageContentTxt);
        Assert.AreEqual('2', EDocDataStorageContentTxt, '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ReceiveMultipleDocumentsFromMultipleMessages()
    var
        EDocument: Record "E-Document";
        EDocumentLog: Record "E-Document Log";
        EDocDataStorage: Record "E-Doc. Data Storage";
        EDocumentService: Record "E-Document Service";
        EDocIntegrationManagement: Codeunit "E-Doc. Integration Management";
        ReceiveContext: Codeunit ReceiveContext;
        InitialIncomingDocumentCount: Integer;
        TestInStream: InStream;
        EDocDataStorageContentTxt, FirstDocMessageId, SecondDocMessageId, ThirdDocMessageId : Text;
    begin
        // [SCENARIO 540007] When using Receive Document functionality, and there are multiple documents available in the specified Outlook shared mailbox, one e-document is correctly created with attachment and name

        // [GIVEN] A setup for importing Outlook attachments as e-documents
        // [GIVEN] That multiple documents are available (in test, this is determined by description TestImportTwoDocumentsTxt)
        Initialize(EDocumentService, Enum::"Service Integration"::TestOutlook, TestImportDocumentsFromTwoMessagesTxt);
        InitialIncomingDocumentCount := EDocument.Count();

        // [WHEN] ReceiveDocument method is called (either from UI or from scheduled task)
        EDocIntegrationManagement.ReceiveDocuments(EDocumentService, ReceiveContext);

        // [THEN] Two new e-documents are created with correct name and attachment
        Assert.AreEqual(InitialIncomingDocumentCount + 3, EDocument.Count(), '');
        EDocument.SetRange("File Name", 'PropsoalX.pdf');
        Assert.IsTrue(EDocument.FindFirst(), '');
        FirstDocMessageId := EDocument."Outlook Mail Message Id";
        EDocumentLog.SetRange("E-Doc. Entry No", EDocument."Entry No");
        Assert.IsTrue(EDocumentLog.FindFirst(), '');
        Assert.IsTrue(EDocDataStorage.Get(EDocumentLog."E-Doc. Data Storage Entry No."), '');
        EDocDataStorage.CalcFields("Data Storage");
        EDocDataStorage."Data Storage".CreateInStream(TestInStream);
        TestInStream.ReadText(EDocDataStorageContentTxt);
        Assert.AreEqual('1', EDocDataStorageContentTxt, '');
        Clear(TestInStream);
        EDocument.SetRange("File Name", 'Medical-Bill-ReceiptX.pdf');
        Assert.IsTrue(EDocument.FindFirst(), '');
        SecondDocMessageId := EDocument."Outlook Mail Message Id";
        EDocumentLog.SetRange("E-Doc. Entry No", EDocument."Entry No");
        Assert.IsTrue(EDocumentLog.FindFirst(), '');
        Assert.IsTrue(EDocDataStorage.Get(EDocumentLog."E-Doc. Data Storage Entry No."), '');
        EDocDataStorage.CalcFields("Data Storage");
        EDocDataStorage."Data Storage".CreateInStream(TestInStream);
        TestInStream.ReadText(EDocDataStorageContentTxt);
        Assert.AreEqual('2', EDocDataStorageContentTxt, '');
        EDocument.SetRange("File Name", 'AnotherPropsoalX.pdf');
        Assert.IsTrue(EDocument.FindFirst(), '');
        ThirdDocMessageId := EDocument."Outlook Mail Message Id";
        EDocumentLog.SetRange("E-Doc. Entry No", EDocument."Entry No");
        Assert.IsTrue(EDocumentLog.FindFirst(), '');
        Assert.IsTrue(EDocDataStorage.Get(EDocumentLog."E-Doc. Data Storage Entry No."), '');
        EDocDataStorage.CalcFields("Data Storage");
        EDocDataStorage."Data Storage".CreateInStream(TestInStream);
        TestInStream.ReadText(EDocDataStorageContentTxt);
        Assert.AreEqual('3', EDocDataStorageContentTxt, '');

        // verify message ids
        Assert.AreNotEqual('', FirstDocMessageId, '');
        Assert.AreNotEqual('', SecondDocMessageId, '');
        Assert.AreNotEqual('', ThirdDocMessageId, '');
        Assert.AreEqual(SecondDocMessageId, FirstDocMessageId, '');
        Assert.AreNotEqual(SecondDocMessageId, ThirdDocMessageId, '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ReceiveNoIncomingDocument()
    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        EDocIntegrationManagement: Codeunit "E-Doc. Integration Management";
        ReceiveContext: Codeunit ReceiveContext;
        InitialIncomingDocumentCount: Integer;
    begin
        // [SCENARIO 540007] When using Receive Document functionality, and there are no documents available in the specified Outlook shared mailbox, one e-document is correctly created with attachment and name

        // [GIVEN] A setup for importing Outlook attachments as e-documents
        // [GIVEN] That no document is available (in test, this is determined by description TestImportNoDocumentsTxt)
        Initialize(EDocumentService, Enum::"Service Integration"::TestOutlook, TestImportNoDocumentsTxt);
        InitialIncomingDocumentCount := EDocument.Count();

        // [WHEN] ReceiveDocument method is called (either from UI or from scheduled task)
        EDocIntegrationManagement.ReceiveDocuments(EDocumentService, ReceiveContext);

        // [THEN] No new e-documents are created
        Assert.AreEqual(InitialIncomingDocumentCount, EDocument.Count(), '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ReceiveSingleIncomingDocumentNoExtension()
    var
        EDocument: Record "E-Document";
        EDocumentLog: Record "E-Document Log";
        EDocDataStorage: Record "E-Doc. Data Storage";
        EDocumentService: Record "E-Document Service";
        EDocIntegrationManagement: Codeunit "E-Doc. Integration Management";
        ReceiveContext: Codeunit ReceiveContext;
        InitialIncomingDocumentCount: Integer;
        TestInStream: InStream;
        EDocDataStorageContentTxt: Text;
    begin
        // [SCENARIO 540007] When using Receive Document functionality, and there is one document available in the specified Outlook shared mailbox, one e-document is correctly created with attachment and name

        // [GIVEN] A setup for importing Outlook attachments as e-documents
        // [GIVEN] That one document is available (in test, this is determined by description TestImportOneDocumentNoExtTxt)
        Initialize(EDocumentService, Enum::"Service Integration"::TestOutlook, TestImportOneDocumentNoExtTxt);
        InitialIncomingDocumentCount := EDocument.Count();

        // [WHEN] ReceiveDocument method is called (either from UI or from scheduled task)
        EDocIntegrationManagement.ReceiveDocuments(EDocumentService, ReceiveContext);

        // [THEN] One new e-document is created with correct name and attachment
        Assert.AreEqual(InitialIncomingDocumentCount + 1, EDocument.Count(), '');
        EDocument.SetRange("File Name", 'Propsoal');
        Assert.IsTrue(EDocument.FindFirst(), '');
        EDocumentLog.SetRange("E-Doc. Entry No", EDocument."Entry No");
        Assert.IsTrue(EDocumentLog.FindFirst(), '');
        Assert.IsTrue(EDocDataStorage.Get(EDocumentLog."E-Doc. Data Storage Entry No."), '');
        EDocDataStorage.CalcFields("Data Storage");
        EDocDataStorage."Data Storage".CreateInStream(TestInStream);
        TestInStream.ReadText(EDocDataStorageContentTxt);
        Assert.AreEqual('1', EDocDataStorageContentTxt, '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SetupRecordSetsLastSynchedAtToEnabledAt()
    var
        OutlookSetup: Record "Outlook Setup";
        EDocumentService: Record "E-Document Service";
    begin
        // [SCENARIO 579019] When enabling OutlookSetup, it sets the LastSyncAt to EnabledAt by default

        // [GIVEN] A setup for importing Outlook attachments as e-documents
        Initialize(EDocumentService, Enum::"Service Integration"::TestOutlook, TestImportOneDocumentNoExtTxt);

        // [WHEN] Setup is enabled
        OutlookSetup.Get();
        OutlookSetup.Validate("Enabled", true);

        // [THEN] EnabledAt is not 0DT, and LastSyncAt is equal to EnabledAt
        Assert.AreNotEqual(OutlookSetup."Enabled At", 0DT, '');
        Assert.AreEqual(OutlookSetup."Enabled At", OutlookSetup."Last Sync At", '');
    end;

    local procedure Initialize(var EDocumentService: Record "E-Document Service"; ServiceIntegration: Enum "Service Integration"; ServiceDescription: Text)
    var
        OutlookSetup: Record "Outlook Setup";
    begin
        OutlookSetup.DeleteAll();
        EDocumentService.DeleteAll(true);

        EDocumentService.Code := CopyStr(ServiceDescription, 1, MaxStrLen(EDocumentService.Code));
        EDocumentService."Service Integration V2" := ServiceIntegration;
        EDocumentService.Description := CopyStr(ServiceDescription, 1, MaxStrLen(EDocumentService.Description));
        EDocumentService.Insert();

        OutlookSetup."Email Account ID" := CreateGuid();
        OutlookSetup.Insert();
    end;

    internal procedure DownloadDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; DocumentMetadataBlob: Codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
    var
        OutlookProcessing: Codeunit "Outlook Processing";
        MessageId, FileId, ExternalMessageId, ContentType : Text;
        LocalOutStream: OutStream;
        EmailInboxId, AttachmentId : BigInteger;
        ReceivedDateTime: DateTime;
        ContentId: Text[2048];
    begin
        OutlookProcessing.ExtractMessageAndAttachmentIds(DocumentMetadataBlob, EmailInboxId, MessageId, ExternalMessageId, FileId, AttachmentId, ReceivedDateTime, ContentType, ContentId);

        ReceiveContext.GetTempBlob().CreateOutStream(LocalOutStream, TextEncoding::UTF8);
        LocalOutStream.WriteText(Format(EDocument."Index In Batch"));

        EDocument."Outlook Mail Message Id" := CopyStr(ExternalMessageId, 1, MaxStrLen(EDocument."Outlook Mail Message Id"));
        EDocument."Outlook Message Attachment Id" := ContentId;
        EDocument.Modify();
        ReceiveContext.SetName(CopyStr(FileId, 1, 256));

        ReceiveContext.SetFileFormat("E-Doc. File Format"::PDF);
    end;

    internal procedure ReceiveDocuments(var EDocumentService: Record "E-Document Service"; Documents: Codeunit "Temp Blob List"; ReceiveContext: Codeunit ReceiveContext)
    var
        OutlookProcessing: Codeunit "Outlook Processing";
        MockArray: JsonArray;
    begin
        case EDocumentService.Description of
            TestImportOneDocumentTxt:
                AddMockAttachment(MockArray, '{ "@odata.type": "#microsoft.graph.fileAttachment", "@odata.mediaContentType": "application/pdf", "messageid" : "95514952-f342-47d1-8c0a-e77c4747156d", "receiveddatetime" : "2025-01-06T15:28:29Z", "externalmessageid" : "AAMkAGVlZWQ2YTA0LWU1M2YtNGQ5Ni1hBGY2LTcyYTZkODA3MzM0NABGAAAAAAAvbEHYnrF6RLhp0mCflYAeBwCTxOILDj3VTqP9lOsW0rxmAAAAAAEMAACTxOILDj3VTqP9lOsW0rxmAAAfYCJIAAA=", "id": 1, "contentId": "1", "name": "Propsoal.pdf", "contentType": "application/pdf", "size": 199264 }');
            TestImportOneDocumentNoExtTxt:
                AddMockAttachment(MockArray, '{ "@odata.type": "#microsoft.graph.fileAttachment", "@odata.mediaContentType": "application/pdf", "messageid" : "b2b07b38-05b2-450a-90c9-cbe4e01c4039", "receiveddatetime" : "2025-01-06T16:28:29Z", "externalmessageid" : "AAMkAGVlZWQ2YTA0LWU1M2YtNGQ5Ni1hCGY2LTcyYTZkODA3MzM0NABGAAAAAAAvbEHYnrF6RLhp0mCflYAeBwCTxOILDj3VTqP9lOsW0rxmAAAAAAEMAACTxOILDj3VTqP9lOsW0rxmAAAfYCJIAAA=", "id": "1", "contentId": "1", "name": "Propsoal", "contentType": "application/pdf", "size": 199264 }');
            TestImportTwoDocumentsTxt:
                begin
                    AddMockAttachment(MockArray, '{ "@odata.type": "#microsoft.graph.fileAttachment", "@odata.mediaContentType": "application/pdf", "messageid" : "8fcc15ea-5b25-4f36-9eda-4c2570f0a1f4", "receiveddatetime" : "2025-01-06T17:28:29Z", "externalmessageid" : "AAMkAGVlZWQ2YTA0LWU1M2YtNGQ5Ni1hDGY2LTcyYTZkODA3MzM0NABGAAAAAAAvbEHYnrF6RLhp0mCflYAeBwCTxOILDj3VTqP9lOsW0rxmAAAAAAEMAACTxOILDj3VTqP9lOsW0rxmAAAfYCJIAAA=", "id": "1", "contentId": "1", "name": "Propsoal.pdf", "contentType": "application/pdf", "size": 199264 }');
                    AddMockAttachment(MockArray, '{ "@odata.type": "#microsoft.graph.fileAttachment", "@odata.mediaContentType": "application/pdf", "messageid" : "f6389eb3-bb77-4bb1-823d-c2612b8c846d", "receiveddatetime" : "2025-01-06T17:28:29Z", "externalmessageid" : "AAMkAGVlZWQ2YTA0LWU1M2YtNGQ5Ni1hDGY2LTcyYTZkODA3MzM0NABGAAAAAAAvbEHYnrF6RLhp0mCflYAeBwCTxOILDj3VTqP9lOsW0rxmAAAAAAEMAACTxOILDj3VTqP9lOsW0rxmAAAfYCJIAAA=", "id": "2", "contentId": "2", "name": "Medical-Bill-Receipt.pdf", "contentType": "application/pdf", "size": 88764 }');
                end;
            TestImportNoDocumentsTxt:
                AddMockAttachment(MockArray, '{ "@odata.type": "#microsoft.graph.fileAttachment", "@odata.mediaContentType": "application/pdf", "messageid" : "55df1e6b-2d26-4de2-adb3-81c9d5139278", "receiveddatetime" : "2025-01-06T18:28:29Z", "externalmessageid" : "AAMkAGVlZWQ2YTA0LWU1M2YtNGQ5Ni1hEGY2LTcyYTZkODA3MzM0NABGAAAAAAAvbEHYnrF6RLhp0mCflYAeBwCTxOILDj3VTqP9lOsW0rxmAAAAAAEMAACTxOILDj3VTqP9lOsW0rxmAAAfYCJIAAA=", "id": "1", "contentId": "1", "name": "Propsoal", "contentType": "application/vnd.openxmlformats-officedocument.wordprocessingml.document", "size": 199264 }');
            TestImportOnlyPdfDocumentsTxt:
                begin
                    AddMockAttachment(MockArray, '{ "@odata.type": "#microsoft.graph.fileAttachment", "@odata.mediaContentType": "application/pdf", "messageid" : "4bd7aed7-0cd5-4584-a856-deff4729d3be", "receiveddatetime" : "2025-01-06T19:28:29Z", "externalmessageid" : "AAMkAGVlZWQ2YTA0LWU1M2YtNGQ5Ni1hFGY2LTcyYTZkODA3MzM0NABGAAAAAAAvbEHYnrF6RLhp0mCflYAeBwCTxOILDj3VTqP9lOsW0rxmAAAAAAEMAACTxOILDj3VTqP9lOsW0rxmAAAfYCJIAAA=", "id": "1", "contentId": "1", "name": "DoImport.pdf", "contentType": "application/pdf", "size": 199264 }');
                    AddMockAttachment(MockArray, '{ "@odata.type": "#microsoft.graph.fileAttachment", "@odata.mediaContentType": "application/pdf", "messageid" : "9fd5761d-22af-40b3-9d5a-9326e5021ca4", "receiveddatetime" : "2025-01-06T19:28:29Z", "externalmessageid" : "AAMkAGVlZWQ2YTA0LWU1M2YtNGQ5Ni1hFGY2LTcyYTZkODA3MzM0NABGAAAAAAAvbEHYnrF6RLhp0mCflYAeBwCTxOILDj3VTqP9lOsW0rxmAAAAAAEMAACTxOILDj3VTqP9lOsW0rxmAAAfYCJIAAA=", "id": "2", "contentId": "2", "name": "DontImport.docx", "contentType": "application/vnd.openxmlformats-officedocument.wordprocessingml.document", "size": 199264 }');
                end;
            TestImportDocumentsFromTwoMessagesTxt:
                begin
                    // Scenario: Two emails, the first email has two attachments, the second email has one attachment
                    AddMockAttachment(MockArray, '{ "@odata.type": "#microsoft.graph.fileAttachment", "@odata.mediaContentType": "application/pdf", "messageid" : "56333810-80bf-4979-9e70-ea43e9b6bfd0","receiveddatetime" : "2025-01-06T20:28:29Z",  "externalmessageid" : "GAMkAGVlZWQ2YTA0LWU1M2YtNGQ5Ni1hGGY2LTcyYTZkODA3MzM0NABGAAAAAAAvbEHYnrF6RLhp0mCflYAeBwCTxOILDj3VTqP9lOsW0rxmAAAAAAEMAACTxOILDj3VTqP9lOsW0rxmAAAfYCJIAAA=", "id": "1", "contentId": "1", "name": "PropsoalX.pdf", "contentType": "application/pdf", "size": 199264 }');
                    AddMockAttachment(MockArray, '{ "@odata.type": "#microsoft.graph.fileAttachment", "@odata.mediaContentType": "application/pdf", "messageid" : "56333810-80bf-4979-9e70-ea43e9b6bfd0", "receiveddatetime" : "2025-01-06T20:28:29Z", "externalmessageid" : "GAMkAGVlZWQ2YTA0LWU1M2YtNGQ5Ni1hGGY2LTcyYTZkODA3MzM0NABGAAAAAAAvbEHYnrF6RLhp0mCflYAeBwCTxOILDj3VTqP9lOsW0rxmAAAAAAEMAACTxOILDj3VTqP9lOsW0rxmAAAfYCJIAAA=", "id": "2", "contentId": "2", "name": "Medical-Bill-ReceiptX.pdf", "contentType": "application/pdf", "size": 88764 }');
                    AddMockAttachment(MockArray, '{ "@odata.type": "#microsoft.graph.fileAttachment", "@odata.mediaContentType": "application/pdf", "messageid" : "e66c9cfb-2771-4f10-ad57-071c38ba2582", "receiveddatetime" : "2025-01-06T21:28:29Z", "externalmessageid" : "DAMkAGVlZWQ2YTA0LWU1M2YtNGQ5Ni1hHGY2LTcyYTZkODA3MzM0NABGAAAAAAAvbEHYnrF6RLhp0mCflYAeBwCTxOILDj3VTqP9lOsW0rxmAAAAAAEMAACTxOILDj3VTqP9lOsW0rxmAAAfYCJIAAA=", "id": "3", "contentId": "3", "name": "AnotherPropsoalX.pdf", "contentType": "application/pdf", "size": 88764 }');
                end;
        end;
        OutlookProcessing.BuildDocumentsList(Documents, MockArray);
    end;

    local procedure AddMockAttachment(var MockArray: JsonArray; JsonText: Text)
    var
        OutlookProcessing: Codeunit "Outlook Processing";
        Mock: JsonObject;
    begin
        Mock.ReadFrom(JsonText);
        if OutlookProcessing.IgnoreMailAttachment(Mock.GetInteger('size'), Mock.GetText('contentType')) then
            exit;
        MockArray.Add(Mock);
    end;

    var
        Assert: Codeunit Assert;
        TestImportOneDocumentTxt: label 'TestImportOneDocument', Locked = true;
        TestImportTwoDocumentsTxt: label 'TestImportTwoDocuments', Locked = true;
        TestImportNoDocumentsTxt: label 'TestImportNoDocuments', Locked = true;
        TestImportOneDocumentNoExtTxt: label 'TestImportOneDocumentNoExt', Locked = true;
        TestImportOnlyPdfDocumentsTxt: label 'TestImportOnlyPdfDocuments', Locked = true;
        TestImportDocumentsFromTwoMessagesTxt: label 'TestImportDocumentsFromTwoMessages', Locked = true;
}

