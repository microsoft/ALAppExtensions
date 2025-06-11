namespace Microsoft.EServices.EDocumentConnector.Microsoft365;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Receive;
using System.Utilities;
using Microsoft.eServices.EDocument.Integration;

codeunit 148196 "OneDrive Sharepoint Int. Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Payables Bookkeeper Agent] E-Document connector for OneDrive and Sharepoint
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ReceiveSingleIncomingDocumentOneDrive()
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
        // [SCENARIO 540009] When using Receive Document functionality, and there is one document available in the specified OneDrive folder, one e-document is correctly created with attachment and name

        // [GIVEN] A setup for importing OneDrive documents as e-documents
        // [GIVEN] That one document is available (in test, this is determined by description TestImportOneDocumentTxt)
        Initialize(EDocumentService, Enum::"Service Integration"::TestOneDrive, TestImportOneDocumentTxt);
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
    procedure ReceiveOnlyPdfDocumentOneDrive()
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
        // [SCENARIO 540009] When using Receive Document functionality, and there are two documents available in the specified OneDrive folder, one e-document is not a PDF

        // [GIVEN] A setup for importing OneDrive documents as e-documents
        // [GIVEN] That one document is downloaded (in test, this is determined by description TestImportOnlyPdfDocumentsTxt)
        Initialize(EDocumentService, Enum::"Service Integration"::TestOneDrive, TestImportOnlyPdfDocumentsTxt);
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
    procedure ReceiveOnlyPdfDocumentSharepoint()
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
        // [SCENARIO 540009] When using Receive Document functionality, and there are two documents available in the specified Sharepoint folder, one e-document is not a PDF

        // [GIVEN] A setup for importing Sharepoint documents as e-documents
        // [GIVEN] That one document is downloaded (in test, this is determined by description TestImportOnlyPdfDocumentsTxt)
        Initialize(EDocumentService, Enum::"Service Integration"::TestSharepoint, TestImportOnlyPdfDocumentsTxt);
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
    procedure DontDownloadMalwareOneDrive()
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
        // [SCENARIO 540009] When using Receive Document functionality, and there are two documents available in the specified OneDrive folder, one e-document is marked as malware

        // [GIVEN] A setup for importing OneDrive documents as e-documents
        // [GIVEN] That one document is downloaded (in test, this is determined by description TestDontImportMalwareTxt)
        Initialize(EDocumentService, Enum::"Service Integration"::TestOneDrive, TestDontImportMalwareTxt);
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
    procedure DontDownloadMalwareSharepoint()
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
        // [SCENARIO 540009] When using Receive Document functionality, and there are two documents available in the specified Sharepoint folder, one e-document is marked as malware

        // [GIVEN] A setup for importing Sharepoint documents as e-documents
        // [GIVEN] That one document is downloaded (in test, this is determined by description TestDontImportMalwareTxt)
        Initialize(EDocumentService, Enum::"Service Integration"::TestSharepoint, TestDontImportMalwareTxt);
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
    procedure ReceiveSingleIncomingDocumentSharepoint()
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
        // [SCENARIO 540009] When using Receive Document functionality, and there is one document available in the specified Sharepoint folder, one e-document is correctly created with attachment and name

        // [GIVEN] A setup for importing Sharepoint documents as e-documents
        // [GIVEN] That one document is available (in test, this is determined by description TestImportOneDocumentTxt)
        Initialize(EDocumentService, Enum::"Service Integration"::TestSharepoint, TestImportOneDocumentTxt);
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
    procedure ReceiveMultipleIncomingDocumentOneDrive()
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
        // [SCENARIO 540009] When using Receive Document functionality, and there are multiple documents available in the specified OneDrive folder, one e-document is correctly created with attachment and name

        // [GIVEN] A setup for importing OneDrive documents as e-documents
        // [GIVEN] That multiple documents are available (in test, this is determined by description TestImportTwoDocumentsTxt)
        Initialize(EDocumentService, Enum::"Service Integration"::TestOneDrive, TestImportTwoDocumentsTxt);
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
        EDocument.SetRange("File Name", 'AnotherProposal.pdf');
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
    procedure ReceiveMultipleIncomingDocumentSharepoint()
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
        // [SCENARIO 540009] When using Receive Document functionality, and there are multiple documents available in the specified Sharepoint folder, one e-document is correctly created with attachment and name

        // [GIVEN] A setup for importing Sharepoint documents as e-documents
        // [GIVEN] That multiple documents are available (in test, this is determined by description TestImportTwoDocumentsTxt)
        Initialize(EDocumentService, Enum::"Service Integration"::TestSharepoint, TestImportTwoDocumentsTxt);
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
        EDocument.SetRange("File Name", 'AnotherProposal.pdf');
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
    procedure ReceiveNoIncomingDocumentOneDrive()
    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        EDocIntegrationManagement: Codeunit "E-Doc. Integration Management";
        ReceiveContext: Codeunit ReceiveContext;
        InitialIncomingDocumentCount: Integer;
    begin
        // [SCENARIO 540009] When using Receive Document functionality, and there are no documents available in the specified OneDrive folder, one e-document is correctly created with attachment and name

        // [GIVEN] A setup for importing OneDrive documents as e-documents
        // [GIVEN] That no document is available (in test, this is determined by description TestImportNoDocumentsTxt)
        Initialize(EDocumentService, Enum::"Service Integration"::TestOneDrive, TestImportNoDocumentsTxt);
        InitialIncomingDocumentCount := EDocument.Count();

        // [WHEN] ReceiveDocument method is called (either from UI or from scheduled task)
        EDocIntegrationManagement.ReceiveDocuments(EDocumentService, ReceiveContext);

        // [THEN] No new e-documents are created
        Assert.AreEqual(InitialIncomingDocumentCount, EDocument.Count(), '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ReceiveNoIncomingDocumentSharepoint()
    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        EDocIntegrationManagement: Codeunit "E-Doc. Integration Management";
        ReceiveContext: Codeunit ReceiveContext;
        InitialIncomingDocumentCount: Integer;
    begin
        // [SCENARIO 540009] When using Receive Document functionality, and there are no documents available in the specified Sharepoint folder, one e-document is correctly created with attachment and name

        // [GIVEN] A setup for importing Sharepoint documents as e-documents
        // [GIVEN] That no document is available (in test, this is determined by description TestImportNoDocumentsTxt)
        Initialize(EDocumentService, Enum::"Service Integration"::TestSharepoint, TestImportNoDocumentsTxt);
        InitialIncomingDocumentCount := EDocument.Count();

        // [WHEN] ReceiveDocument method is called (either from UI or from scheduled task)
        EDocIntegrationManagement.ReceiveDocuments(EDocumentService, ReceiveContext);

        // [THEN] No new e-documents are created
        Assert.AreEqual(InitialIncomingDocumentCount, EDocument.Count(), '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ReceiveSingleIncomingDocumentNoExtensionOneDrive()
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
        // [SCENARIO 540009] When using Receive Document functionality, and there is one document available in the specified OneDrive folder, one e-document is correctly created with attachment and name

        // [GIVEN] A setup for importing OneDrive documents as e-documents
        // [GIVEN] That one document is available (in test, this is determined by description TestImportOneDocumentNoExtTxt)
        Initialize(EDocumentService, Enum::"Service Integration"::TestOneDrive, TestImportOneDocumentNoExtTxt);
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
    procedure ReceiveSingleIncomingDocumentNoExtensionSharepoint()
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
        // [SCENARIO 540009] When using Receive Document functionality, and there is one document available in the specified Sharepoint folder, one e-document is correctly created with attachment and name

        // [GIVEN] A setup for importing Sharepoint documents as e-documents
        // [GIVEN] That one document is available (in test, this is determined by description TestImportOneDocumentNoExtTxt)
        Initialize(EDocumentService, Enum::"Service Integration"::TestSharepoint, TestImportOneDocumentNoExtTxt);
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
        SharepointSetup: Record "Sharepoint Setup";
        OneDriveSetup: Record "OneDrive Setup";
    begin
        SharepointSetup.DeleteAll();
        OneDriveSetup.DeleteAll();
        EDocumentService.DeleteAll(true);

        EDocumentService.Code := CopyStr(ServiceDescription, 1, MaxStrLen(EDocumentService.Code));
        EDocumentService."Service Integration V2" := ServiceIntegration;
        EDocumentService.Description := CopyStr(ServiceDescription, 1, MaxStrLen(EDocumentService.Description));
        EDocumentService.Insert();

        SharepointSetup."Documents Folder" := 'test';
        SharepointSetup."Imp. Documents Folder" := 'test';
        SharepointSetup.Enabled := true;
        SharepointSetup.Insert();

        OneDriveSetup."Documents Folder" := 'test';
        OneDriveSetup."Imp. Documents Folder" := 'test';
        OneDriveSetup.Enabled := true;
        OneDriveSetup.Insert();
    end;

    internal procedure DownloadDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; DocumentMetadataBlob: Codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
    var
        DriveProcessing: Codeunit "Drive Processing";
        DocumentId, FileId : Text;
        LocalOutStream: OutStream;
    begin
        DriveProcessing.ExtractItemIdAndName(DocumentMetadataBlob, DocumentId, FileId);

        ReceiveContext.GetTempBlob().CreateOutStream(LocalOutStream, TextEncoding::UTF8);
        LocalOutStream.WriteText(Format(EDocument."Index In Batch"));

        EDocument."Drive Item Id" := CopyStr(DocumentId, 1, MaxStrLen(EDocument."Drive Item Id"));
        EDocument."Source Details" := 'Document from Drive';
        EDocument.Modify();
        ReceiveContext.SetName(CopyStr(FileId, 1, 250));
    end;

    internal procedure ReceiveDocuments(var EDocumentService: Record "E-Document Service"; Documents: Codeunit "Temp Blob List"; ReceiveContext: Codeunit ReceiveContext)
    var
        DriveProcessing: Codeunit "Drive Processing";
        Mock: JSonObject;
    begin
        case EDocumentService.Description of
            TestImportOneDocumentTxt:
                Mock.ReadFrom('{ "id": "9FFFDB3C-5B87-4062-9606-1B008CA88E44", "name": "Contoso Project", "eTag": "2246BD2D-7811-4660-BD0F-1CF36133677B,1", "folder": {}, "size": 10911212, "value": [ { "id": "AFBBDD79-868E-452D-AD4D-24697D4A4044", "name": "Propsoal.pdf", "file": { "mimeType": "application/pdf" }, "size": 19001 } ] }');
            TestImportOneDocumentNoExtTxt:
                Mock.ReadFrom('{ "id": "9FFFDB3C-5B87-4062-9606-1B008CA88E44", "name": "Contoso Project", "eTag": "2246BD2D-7811-4660-BD0F-1CF36133677B,1", "folder": {}, "size": 10911212, "value": [ { "id": "AFBBDD79-868E-452D-AD4D-24697D4A4044", "name": "Propsoal", "file": { "mimeType": "application/pdf" }, "size": 19001 } ] }');
            TestImportTwoDocumentsTxt:
                Mock.ReadFrom('{ "id": "9FFFDB3C-5B87-4062-9606-1B008CA88E44", "name": "Contoso Project", "eTag": "2246BD2D-7811-4660-BD0F-1CF36133677B,1", "folder": {}, "size": 10911212, "value": [ { "id": "AFBBDD79-868E-452D-AD4D-24697D4A4044", "name": "Propsoal.pdf", "file": { "mimeType": "application/pdf" }, "size": 19001 }, { "id": "A91FE90A-2F2C-4EE6-B412-C4FFBA3F71A6", "name": "AnotherProposal.pdf", "file": { "mimeType": "application/pdf" }, "size": 91001 } ] }');
            TestImportNoDocumentsTxt:
                Mock.ReadFrom('{ "id": "9FFFDB3C-5B87-4062-9606-1B008CA88E44", "name": "Contoso Project", "eTag": "2246BD2D-7811-4660-BD0F-1CF36133677B,1", "folder": {}, "size": 10911212, "value": [ ] }');
            TestImportOnlyPdfDocumentsTxt:
                Mock.ReadFrom('{ "id": "9FFFDB3C-5B87-4062-9606-1B008CA88E44", "name": "Contoso Project", "eTag": "2246BD2D-7811-4660-BD0F-1CF36133677B,1", "folder": {}, "size": 10911212, "value": [ { "id": "AFBBDD79-868E-452D-AD4D-24697D4A4044", "name": "DoImport.pdf", "file": { "mimeType": "application/pdf" }, "size": 19001 }, { "id": "A91FE90A-2F2C-4EE6-B412-C4FFBA3F71A6", "name": "MeeTooIDontThinkSo.txt", "file": { "mimeType": "application/txt" }, "size": 91001 } ] }');
            TestDontImportMalwareTxt:
                Mock.ReadFrom('{ "id": "9FFFDB3C-5B87-4062-9606-1B008CA88E44", "name": "Contoso Project", "eTag": "2246BD2D-7811-4660-BD0F-1CF36133677B,1", "folder": {}, "size": 10911212, "value": [ { "id": "AFBBDD79-868E-452D-AD4D-24697D4A4044", "name": "DoImport.pdf", "file": { "mimeType": "application/pdf" }, "size": 19001 }, { "id": "A91FE90A-2F2C-4EE6-B412-C4FFBA3F71A6", "name": "MeeTooIDontThinkSo.pdf", "malware": { "description": "Ransom Wanted" }, "file": { "mimeType": "application/pdf" }, "size": 91001 } ] }');
        end;
        DriveProcessing.AddToDocumentsList(Documents, Mock);
        DriveProcessing.AddToReceiveContext(ReceiveContext, Mock);
    end;

    var
        Assert: Codeunit Assert;
        TestImportOneDocumentTxt: label 'TestImportOneDocument', Locked = true;
        TestImportTwoDocumentsTxt: label 'TestImportTwoDocuments', Locked = true;
        TestImportNoDocumentsTxt: label 'TestImportNoDocuments', Locked = true;
        TestImportOneDocumentNoExtTxt: label 'TestImportOneDocumentNoExt', Locked = true;
        TestImportOnlyPdfDocumentsTxt: label 'TestImportOnlyPdfDocuments', Locked = true;
        TestDontImportMalwareTxt: label 'TestDontImportMalware', Locked = true;

}

