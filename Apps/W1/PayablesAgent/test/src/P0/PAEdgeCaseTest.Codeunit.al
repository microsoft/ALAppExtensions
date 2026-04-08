// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Test.Agents.PayablesAgent;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration;
using Microsoft.eServices.EDocument.Integration.Receive;
using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.EServices.EDocumentConnector.Microsoft365;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using System.Agents;
using System.TestLibraries.Agents;
using System.TestTools.AITestToolkit;
using System.Utilities;


codeunit 133710 "PA Edge Case Test"
{
    Subtype = Test;
    TestType = AITest;
    TestPermissions = Disabled;
    Access = Internal;

    local procedure Initialize()
    var
        OutlookSetup: Record "Outlook Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PostedPurchaseHeader: Record "Purch. Inv. Header";
        EDocument: Record "E-Document";
    begin
        if not OutlookSetup.FindFirst() then begin
            OutlookSetup.Validate("Consent Received", true);
            OutlookSetup.Insert();
        end else begin
            OutlookSetup.Validate("Consent Received", true);
            OutlookSetup.Modify();
        end;

        LibraryAgent.StopAllTasks();

        LibraryPayablesAgent.EnablePayableAgent();

        PostedPurchaseHeader.DeleteAll(false);
        PurchaseLine.DeleteAll(false);
        PurchaseHeader.DeleteAll(false);

        if EDocument.FindSet() then
            repeat
                EDocument.CleanupDocument();
                EDocument.Delete(false);
            until EDocument.Next() = 0;
    end;

    [Test]
    procedure TestReceiveCorruptPurchaseInvoiceShouldCreateAgentTask()
    var
        AgentTask: Record "Agent Task";
        EDocumentService: Record "E-Document Service";
        EDocument: Record "E-Document";
        EDocIntegrationManagement: Codeunit "E-Doc. Integration Management";
        EDocImport: Codeunit "E-Doc. Import";
        ReceiveContext: Codeunit ReceiveContext;
        AITTestContext: Codeunit "AIT Test Context";
        AnswerTxt: Text;
    begin
        Initialize();
        InitializeEDocService(EDocumentService, Enum::"Service Integration"::TestPAEdgeCases, TestImportOneCorruptDocumentTxt);
        EDocIntegrationManagement.ReceiveDocuments(EDocumentService, ReceiveContext);

        EDocument.SetRange("File Name", 'CorruptPropsoal.pdf');
        Assert.IsTrue(EDocument.FindLast(), '');
        EDocument."Source Details" := EDocumentService.Description;
        EDocument.Modify();

        EDocImport.ProcessIncomingEDocument(EDocument, EDocument.GetEDocumentService().GetDefaultImportParameters());
        AgentTask.SetRange("External ID", Format(EDocument."Entry No"));
        AnswerTxt := ConstructTestAnswer(AgentTask);
        AITTestContext.SetTestOutput(EdgeCaseTestContextTxt, TestImportOneCorruptDocumentTxt, AnswerTxt);
        Assert.IsTrue(AgentTask.FindFirst(), '');
        Assert.IsTrue(StrPos(AgentTask.Title, TestImportOneCorruptDocumentTxt) > 0, '');
    end;

    [Test]
    procedure TestReceivePDFThatIsNotAnInvoiceShouldCreateAgentTask()
    var
        AgentTask: Record "Agent Task";
        EDocumentService: Record "E-Document Service";
        EDocument: Record "E-Document";
        EDocIntegrationManagement: Codeunit "E-Doc. Integration Management";
        EDocImport: Codeunit "E-Doc. Import";
        ReceiveContext: Codeunit ReceiveContext;
        AITTestContext: Codeunit "AIT Test Context";
        AnswerTxt: Text;
    begin
        Initialize();
        InitializeEDocService(EDocumentService, Enum::"Service Integration"::TestPAEdgeCases, TestImportPDFNotAnInvoiceTxt);
        EDocIntegrationManagement.ReceiveDocuments(EDocumentService, ReceiveContext);

        EDocument.SetRange("File Name", 'NotAnInvoice.pdf');
        Assert.IsTrue(EDocument.FindLast(), '');
        EDocument."Source Details" := EDocumentService.Description;
        EDocument.Modify();

        EDocImport.ProcessIncomingEDocument(EDocument, EDocument.GetEDocumentService().GetDefaultImportParameters());
        AgentTask.SetRange("External ID", Format(EDocument."Entry No"));
        AnswerTxt := ConstructTestAnswer(AgentTask);
        AITTestContext.SetTestOutput(EdgeCaseTestContextTxt, TestImportPDFNotAnInvoiceTxt, AnswerTxt);
        Assert.IsTrue(AgentTask.FindFirst(), '');
        Assert.IsTrue(StrPos(AgentTask.Title, TestImportPDFNotAnInvoiceTxt) > 0, '')
    end;

    [Test]
    procedure TestReceiveEmailNoPDFAttachmentCreateAgentTask()
    var
        AgentTask: Record "Agent Task";
        EDocumentService: Record "E-Document Service";
        EDocument: Record "E-Document";
        EDocIntegrationManagement: Codeunit "E-Doc. Integration Management";
        EDocImport: Codeunit "E-Doc. Import";
        ReceiveContext: Codeunit ReceiveContext;
        AITTestContext: Codeunit "AIT Test Context";
        AnswerTxt: Text;
    begin
        Initialize();
        InitializeEDocService(EDocumentService, Enum::"Service Integration"::TestPAEdgeCases, TestImportEmailNoAttachmentTxt);
        EDocIntegrationManagement.ReceiveDocuments(EDocumentService, ReceiveContext);

        Assert.IsTrue(EDocument.FindLast(), '');
        EDocument."Source Details" := EDocumentService.Description;
        EDocument.Modify();

        EDocImport.ProcessIncomingEDocument(EDocument, EDocument.GetEDocumentService().GetDefaultImportParameters());
        AgentTask.SetRange("External ID", Format(EDocument."Entry No"));
        AnswerTxt := ConstructTestAnswer(AgentTask);
        AITTestContext.SetTestOutput(EdgeCaseTestContextTxt, TestImportEmailNoAttachmentTxt, AnswerTxt);
        Assert.IsTrue(AgentTask.FindFirst(), '');
        Assert.IsTrue(StrPos(AgentTask.Title, TestImportEmailNoAttachmentTxt) > 0, '')
    end;

    local procedure ConstructTestAnswer(var AgentTask: Record "Agent Task"): Text
    begin
        if not AgentTask.FindFirst() then
            exit(NoAgentTaskCreatedTxt);

        exit(StrSubstNo(AgentTaskCreatedTxt, AgentTask.Title));
    end;

    local procedure InitializeEDocService(var EDocumentService: Record "E-Document Service"; ServiceIntegration: Enum "Service Integration"; ServiceDescription: Text)
    var
        OutlookSetup: Record "Outlook Setup";
    begin
        OutlookSetup.DeleteAll();
        EDocumentService.DeleteAll(true);

        EDocumentService.Code := PayablesAgentEDocServiceTok;
        EDocumentService."Service Integration V2" := ServiceIntegration;
        EDocumentService.Description := CopyStr(ServiceDescription, 1, MaxStrLen(EDocumentService.Description));
        EDocumentService."Automatic Import Processing" := EDocumentService."Automatic Import Processing"::No;
        EDocumentService."Import Process" := EDocumentService."Import Process"::"Version 2.0";
        EDocumentService.Insert();

        OutlookSetup."Email Account ID" := CreateGuid();
        OutlookSetup.Validate("Consent Received", true);
        OutlookSetup.Insert();
    end;

    internal procedure DownloadDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; DocumentMetadataBlob: Codeunit "Temp Blob"; ReceiveContext: Codeunit ReceiveContext)
    var
        MessageId, FileId, ExternalMessageId, ContentType : Text;
        LocalOutStream: OutStream;
        LocalInStream: InStream;
        EmailInboxId, AttachmentId : BigInteger;
        ReceivedDateTime: DateTime;
    begin
        ExtractMessageAndAttachmentIds(DocumentMetadataBlob, EmailInboxId, MessageId, ExternalMessageId, FileId, AttachmentId, ReceivedDateTime, ContentType);

        ReceiveContext.GetTempBlob().CreateOutStream(LocalOutStream, TextEncoding::UTF8);
        case EDocumentService.Description of
            TestImportOneCorruptDocumentTxt:
                begin
                    // write something that is a corrupt PDF. e.g. '1'
                    ReceiveContext.SetFileFormat("E-Doc. File Format"::PDF);
                    LocalOutStream.WriteText(Format(EDocument."Index In Batch"));
                end;
            TestImportPDFNotAnInvoiceTxt:
                begin
                    // write a PDF that is not an invoice
                    ReceiveContext.SetFileFormat("E-Doc. File Format"::PDF);
                    NAVApp.GetResource('TestInvoices/NotAnInvoice.pdf', LocalInStream);
                    CopyStream(LocalOutStream, LocalInStream);
                end;
            TestImportEmailNoAttachmentTxt:
                begin
                    // mock situation when email with no PDF attachment is received
                    EDocument."Structure Data Impl." := Enum::"Structure Received E-Doc."::"Already Structured";
                    EDocument."Read into Draft Impl." := Enum::"E-Doc. Read Into Draft"::"Blank Draft";
                    EDocument.Modify();
                    LocalOutStream.WriteText(Format(EDocument."Index In Batch"));
                end;
            else
                LocalOutStream.WriteText(Format(EDocument."Index In Batch"));
        end;

        EDocument."Outlook Mail Message Id" := CopyStr(ExternalMessageId, 1, MaxStrLen(EDocument."Outlook Mail Message Id"));
        EDocument."Outlook Message Attachment Id" := CopyStr(Format(AttachmentId), 1, MaxStrLen(EDocument."Outlook Message Attachment Id"));
        EDocument.Modify();
        ReceiveContext.SetName(CopyStr(FileId, 1, 256));
        ReceiveContext.SetFileFormat("E-Doc. File Format"::PDF);
    end;

    local procedure ExtractMessageAndAttachmentIds(DocumentMetadataBlob: Codeunit "Temp Blob"; var EmailInboxId: BigInteger; var MessageId: Text; var ExternalMessageId: Text; var FileId: Text; var MailAttachmentId: BigInteger; var ReceivedDateTime: DateTime; var ContentType: Text)
    var
        Instream: InStream;
        ItemObject: JsonObject;
        EmailInboxIdTxt, ContentData : Text;
    begin
        DocumentMetadataBlob.CreateInStream(Instream);
        Instream.ReadText(ContentData);
        ItemObject.ReadFrom(ContentData);
        EmailInboxIdTxt := ItemObject.GetText('emailInboxId', true);
        if not Evaluate(EmailInboxId, EmailInboxIdTxt) then;
        MessageId := ItemObject.GetText('messageid', true);
        ExternalMessageId := ItemObject.GetText('externalmessageid');
        FileId := ItemObject.GetText('name');
        if not Evaluate(MailAttachmentId, ItemObject.GetText('id')) then
            if ItemObject.GetText('id') <> '' then
                Error('Invalid Attachment Id %1', FileId);
        if ItemObject.GetText('receiveddatetime') <> '' then
            if not Evaluate(ReceivedDateTime, ItemObject.GetText('receiveddatetime'), 9) then
                Error('Invalid Attachment Received Date Time %1', FileId);
        ContentType := ItemObject.GetText('contentType');
    end;

    internal procedure ReceiveDocuments(var EDocumentService: Record "E-Document Service"; Documents: Codeunit "Temp Blob List"; ReceiveContext: Codeunit ReceiveContext)
    var
        Mock: JsonObject;
        MockArray: JsonArray;
    begin
        case EDocumentService.Description of
            TestImportOneCorruptDocumentTxt:
                begin
                    Mock.ReadFrom('{ "@odata.type": "#microsoft.graph.fileAttachment", "@odata.mediaContentType": "application/pdf", "messageid" : "95514952-f342-47d1-8c0a-e77c4747156d", "receiveddatetime" : "2025-01-06T15:28:29Z", "externalmessageid" : "AAMkAGVlZWQ2YTA0LWU1M2YtNGQ5Ni1hBGY2LTcyYTZkODA3MzM0NABGAAAAAAAvbEHYnrF6RLhp0mCflYAeBwCTxOILDj3VTqP9lOsW0rxmAAAAAAEMAACTxOILDj3VTqP9lOsW0rxmAAAfYCJIAAA=", "id": 1, "contentId": "1", "name": "CorruptPropsoal.pdf", "contentType": "application/pdf", "size": 199264 }');
                    MockArray.Add(Mock);
                end;
            TestImportPDFNotAnInvoiceTxt:
                begin
                    Mock.ReadFrom('{ "@odata.type": "#microsoft.graph.fileAttachment", "@odata.mediaContentType": "application/pdf", "messageid" : "85514952-f342-47d1-8c0a-e77c4747156d", "receiveddatetime" : "2025-01-06T15:28:29Z", "externalmessageid" : "AAMkAGVlZWQ2YTA0LWU1M2YtNGQ5Mi1hBGY2LTcyYTZkODA3MzM0NABGAAAAAAAvbEHYnrF6RLhp0mCflYAeBwCTxOILDj3VTqP9lOsW0rxmAAAAAAEMAACTxOILDj3VTqP9lOsW0rxmAAAfYCJIAAA=", "id": 2, "contentId": "2", "name": "NotAnInvoice.pdf", "contentType": "application/pdf", "size": 199264 }');
                    MockArray.Add(Mock);
                end;
            TestImportEmailNoAttachmentTxt:
                begin
                    Mock.ReadFrom('{ "@odata.type": "#microsoft.graph.fileAttachment", "@odata.mediaContentType": "application/pdf", "messageid" : "85514952-f342-47d1-8c0a-e77c4747156d", "receiveddatetime" : "2025-01-06T15:28:29Z", "externalmessageid" : "AAMkAGVlZWQ2YTA0LWU1M2YtNGQ5Mi1hBGY2LTcyYTZkODA3MzM0NABGAAAAAAAvbEHYnrF6RLhp0mCflYAeBwCTxOILDj3VTqP9lOsW0rxmAAAAAAEMAACTxOILDj3VTqP9lOsW0rxmAAAfYCJIAAA=", "id": 0, "contentId": "none", "name": "' + NoSupportedAttachmentTxt + '", "contentType": "none", "size": 0 }');
                    MockArray.Add(Mock);
                end;
        end;
        BuildDocumentsList(Documents, MockArray);
    end;

    local procedure BuildDocumentsList(Documents: Codeunit "Temp Blob List"; var AttachmentsJson: JSonArray)
    var
        TempBlob: Codeunit "Temp Blob";
        AttachmentJson: JsonToken;
        OutStream: OutStream;
        AttachmentTxt: Text;
    begin
        foreach AttachmentJson in AttachmentsJson do begin
            Clear(TempBlob);
            TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
            AttachmentJson.WriteTo(AttachmentTxt);
            OutStream.WriteText(AttachmentTxt);
            Documents.Add(TempBlob);
        end;
    end;

    var
        LibraryAgent: Codeunit "Library - Agent";
        LibraryPayablesAgent: Codeunit "Library - Payables Agent";
        Assert: Codeunit Assert;
        TestImportOneCorruptDocumentTxt: label 'EmailWithCorruptPDF', Locked = true;
        TestImportPDFNotAnInvoiceTxt: label 'EmailWithNonInvoicePDF', Locked = true;
        TestImportEmailNoAttachmentTxt: label 'EmailWithNoPDFAttachment', Locked = true;
        NoSupportedAttachmentTxt: Label 'E-mail with no attachment of supported type.';
        PayablesAgentEDocServiceTok: Label 'AGENT', Locked = true;
        EdgeCaseTestContextTxt: Label 'Edge Case Test', Locked = true;
        NoAgentTaskCreatedTxt: Label 'No Agent task created.', Locked = true;
        AgentTaskCreatedTxt: Label 'Created Agent task with title ''%1''', Locked = true;
}
