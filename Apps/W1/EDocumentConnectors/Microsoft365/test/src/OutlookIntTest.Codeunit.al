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
        Assert.IsTrue(EDocument.FindFirst(), '');
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
        FirstDocMessageId := EDocument."Mail Message Id";
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
        SecondDocMessageId := EDocument."Mail Message Id";
        EDocumentLog.SetRange("E-Doc. Entry No", EDocument."Entry No");
        Assert.IsTrue(EDocumentLog.FindFirst(), '');
        Assert.IsTrue(EDocDataStorage.Get(EDocumentLog."E-Doc. Data Storage Entry No."), '');
        EDocDataStorage.CalcFields("Data Storage");
        EDocDataStorage."Data Storage".CreateInStream(TestInStream);
        TestInStream.ReadText(EDocDataStorageContentTxt);
        Assert.AreEqual('2', EDocDataStorageContentTxt, '');
        EDocument.SetRange("File Name", 'AnotherPropsoalX.pdf');
        Assert.IsTrue(EDocument.FindFirst(), '');
        ThirdDocMessageId := EDocument."Mail Message Id";
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
        MessageId, FileId, ExternalMessageId : Text;
        LocalOutStream: OutStream;
        AttachmentId: BigInteger;
    begin
        OutlookProcessing.ExtractMessageAndAttachmentIds(DocumentMetadataBlob, MessageId, ExternalMessageId, FileId, AttachmentId);

        ReceiveContext.GetTempBlob().CreateOutStream(LocalOutStream, TextEncoding::UTF8);
        LocalOutStream.WriteText(Format(EDocument."Index In Batch"));

        OutlookProcessing.UpdateEDocumentAfterMailAttachmentDownload(EDocument, ExternalMessageId, Format(AttachmentId));
        OutlookProcessing.UpdateReceiveContextAfterDocumentDownload(ReceiveContext, FileId);
    end;

    internal procedure ReceiveDocuments(var EDocumentService: Record "E-Document Service"; Documents: Codeunit "Temp Blob List"; ReceiveContext: Codeunit ReceiveContext)
    var
        OutlookProcessing: Codeunit "Outlook Processing";
        Mock: JsonObject;
        MockArray: JsonArray;
    begin
        case EDocumentService.Description of
            TestImportOneDocumentTxt:
                begin
                    Mock.ReadFrom('{ "@odata.type": "#microsoft.graph.fileAttachment", "@odata.mediaContentType": "application/pdf", "messageid" : "9", "externalmessageid" : "AAMkAGVlZWQ2YTA0LWU1M2YtNGQ5Ni1hBGY2LTcyYTZkODA3MzM0NABGAAAAAAAvbEHYnrF6RLhp0mCflYAeBwCTxOILDj3VTqP9lOsW0rxmAAAAAAEMAACTxOILDj3VTqP9lOsW0rxmAAAfYCJIAAA=", "id": 1, "name": "Propsoal.pdf", "contentType": "application/pdf", "size": 199264 }');
                    MockArray.Add(Mock);
                end;
            TestImportOneDocumentNoExtTxt:
                begin
                    Mock.ReadFrom('{ "@odata.type": "#microsoft.graph.fileAttachment", "@odata.mediaContentType": "application/pdf", "messageid" : "10", "externalmessageid" : "AAMkAGVlZWQ2YTA0LWU1M2YtNGQ5Ni1hCGY2LTcyYTZkODA3MzM0NABGAAAAAAAvbEHYnrF6RLhp0mCflYAeBwCTxOILDj3VTqP9lOsW0rxmAAAAAAEMAACTxOILDj3VTqP9lOsW0rxmAAAfYCJIAAA=", "id": "1", "name": "Propsoal", "contentType": "application/pdf", "size": 199264 }');
                    MockArray.Add(Mock);
                end;
            TestImportTwoDocumentsTxt:
                begin
                    Mock.ReadFrom('{ "@odata.type": "#microsoft.graph.fileAttachment", "@odata.mediaContentType": "application/pdf", "messageid" : "1", "externalmessageid" : "AAMkAGVlZWQ2YTA0LWU1M2YtNGQ5Ni1hDGY2LTcyYTZkODA3MzM0NABGAAAAAAAvbEHYnrF6RLhp0mCflYAeBwCTxOILDj3VTqP9lOsW0rxmAAAAAAEMAACTxOILDj3VTqP9lOsW0rxmAAAfYCJIAAA=", "id": "1", "name": "Propsoal.pdf", "contentType": "application/pdf", "size": 199264 }');
                    MockArray.Add(Mock);
                    Mock.ReadFrom('{ "@odata.type": "#microsoft.graph.fileAttachment", "@odata.mediaContentType": "application/pdf", "messageid" : "2", "externalmessageid" : "AAMkAGVlZWQ2YTA0LWU1M2YtNGQ5Ni1hDGY2LTcyYTZkODA3MzM0NABGAAAAAAAvbEHYnrF6RLhp0mCflYAeBwCTxOILDj3VTqP9lOsW0rxmAAAAAAEMAACTxOILDj3VTqP9lOsW0rxmAAAfYCJIAAA=", "id": "2", "name": "Medical-Bill-Receipt.pdf", "contentType": "application/pdf", "size": 88764 }');
                    MockArray.Add(Mock);
                end;
            TestImportNoDocumentsTxt:
                begin
                    Mock.ReadFrom('{ "@odata.type": "#microsoft.graph.fileAttachment", "@odata.mediaContentType": "application/pdf", "messageid" : "3", "externalmessageid" : "AAMkAGVlZWQ2YTA0LWU1M2YtNGQ5Ni1hEGY2LTcyYTZkODA3MzM0NABGAAAAAAAvbEHYnrF6RLhp0mCflYAeBwCTxOILDj3VTqP9lOsW0rxmAAAAAAEMAACTxOILDj3VTqP9lOsW0rxmAAAfYCJIAAA=", "id": "1", "name": "Propsoal", "contentType": "application/vnd.openxmlformats-officedocument.wordprocessingml.document", "size": 199264 }');
                    MockArray.Add(Mock);
                end;
            TestImportOnlyPdfDocumentsTxt:
                begin
                    Mock.ReadFrom('{ "@odata.type": "#microsoft.graph.fileAttachment", "@odata.mediaContentType": "application/pdf", "messageid" : "4", "externalmessageid" : "AAMkAGVlZWQ2YTA0LWU1M2YtNGQ5Ni1hFGY2LTcyYTZkODA3MzM0NABGAAAAAAAvbEHYnrF6RLhp0mCflYAeBwCTxOILDj3VTqP9lOsW0rxmAAAAAAEMAACTxOILDj3VTqP9lOsW0rxmAAAfYCJIAAA=", "id": "1", "name": "DoImport.pdf", "contentType": "application/pdf", "size": 199264 }');
                    MockArray.Add(Mock);
                    Mock.ReadFrom('{ "@odata.type": "#microsoft.graph.fileAttachment", "@odata.mediaContentType": "application/pdf", "messageid" : "5", "externalmessageid" : "AAMkAGVlZWQ2YTA0LWU1M2YtNGQ5Ni1hFGY2LTcyYTZkODA3MzM0NABGAAAAAAAvbEHYnrF6RLhp0mCflYAeBwCTxOILDj3VTqP9lOsW0rxmAAAAAAEMAACTxOILDj3VTqP9lOsW0rxmAAAfYCJIAAA=", "id": "2", "name": "DontImport.docx", "contentType": "application/vnd.openxmlformats-officedocument.wordprocessingml.document", "size": 199264 }');
                    MockArray.Add(Mock);
                end;
            TestImportDocumentsFromTwoMessagesTxt:
                begin
                    Mock.ReadFrom('{ "@odata.type": "#microsoft.graph.fileAttachment", "@odata.mediaContentType": "application/pdf", "messageid" : "6", "externalmessageid" : "AAMkAGVlZWQ2YTA0LWU1M2YtNGQ5Ni1hGGY2LTcyYTZkODA3MzM0NABGAAAAAAAvbEHYnrF6RLhp0mCflYAeBwCTxOILDj3VTqP9lOsW0rxmAAAAAAEMAACTxOILDj3VTqP9lOsW0rxmAAAfYCJIAAA=", "id": "1", "name": "PropsoalX.pdf", "contentType": "application/pdf", "size": 199264 }');
                    MockArray.Add(Mock);
                    Mock.ReadFrom('{ "@odata.type": "#microsoft.graph.fileAttachment", "@odata.mediaContentType": "application/pdf", "messageid" : "7", "externalmessageid" : "AAMkAGVlZWQ2YTA0LWU1M2YtNGQ5Ni1hGGY2LTcyYTZkODA3MzM0NABGAAAAAAAvbEHYnrF6RLhp0mCflYAeBwCTxOILDj3VTqP9lOsW0rxmAAAAAAEMAACTxOILDj3VTqP9lOsW0rxmAAAfYCJIAAA=", "id": "2", "name": "Medical-Bill-ReceiptX.pdf", "contentType": "application/pdf", "size": 88764 }');
                    MockArray.Add(Mock);
                    Mock.ReadFrom('{ "@odata.type": "#microsoft.graph.fileAttachment", "@odata.mediaContentType": "application/pdf", "messageid" : "8", "externalmessageid" : "AAMkAGVlZWQ2YTA0LWU1M2YtNGQ5Ni1hHGY2LTcyYTZkODA3MzM0NABGAAAAAAAvbEHYnrF6RLhp0mCflYAeBwCTxOILDj3VTqP9lOsW0rxmAAAAAAEMAACTxOILDj3VTqP9lOsW0rxmAAAfYCJIAAA=", "id": "3", "name": "AnotherPropsoalX.pdf", "contentType": "application/pdf", "size": 88764 }');
                    MockArray.Add(Mock);
                end;
        end;
        OutlookProcessing.BuildDocumentsList(Documents, MockArray);
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

