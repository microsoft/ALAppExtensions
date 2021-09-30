// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132593 "Document Sharing Test"
{
    EventSubscriberInstance = Manual;
    Subtype = Test;

    var
        LibraryAssert: Codeunit "Library Assert";
        DocumentSharingTest: Codeunit "Document Sharing Test";
        NoDocToShareErr: Label 'No document to share';
        NoDocServiceConfiguredErr: Label 'Document service is not configured';

    [Test]
    procedure InvalidDocumentSharingRecGivesError()
    var
        TempDocumentSharingRec: Record "Document Sharing" temporary;
        DocumentSharing: Codeunit "Document Sharing";
    begin
        Init();

        // [Given] An empty document sharing record.
        Clear(TempDocumentSharingRec);

        // [When] Document Sharing is invoked.
        asserterror DocumentSharing.Run(TempDocumentSharingRec);

        // [Then] An appropriate error is returned.
        LibraryAssert.ExpectedError(NoDocToShareErr);
    end;

    [Test]
    procedure InvalidDocumentServiceGivesError()
    var
        TempDocumentSharingRec: Record "Document Sharing" temporary;
        DocumentSharing: Codeunit "Document Sharing";
    begin
        Init();

        // [Given] A valid document sharing record and there is no document service to handle it.
        InitDocumentSharingRec(TempDocumentSharingRec);

        // [When] Document Sharing is invoked.
        asserterror DocumentSharing.Run(TempDocumentSharingRec);

        // [Then] An appropriate error is returned.
        LibraryAssert.ExpectedError(NoDocServiceConfiguredErr);
    end;

    [Test]
    [HandlerFunctions('HandleHyperlink')]
    procedure DocumentSharingUpdatesFieldsCorrectly()
    var
        TempDocumentSharingRec: Record "Document Sharing" temporary;
        DocumentSharing: Codeunit "Document Sharing";
    begin
        Init();

        // [Given] A valid document sharing record and there is a document service to handle it.
        BindSubscription(DocumentSharingTest);
        InitDocumentSharingRec(TempDocumentSharingRec);

        // [When] Document Sharing is invoked.
        DocumentSharing.Run(TempDocumentSharingRec);

        // [Then] The document sharing record is updated correctly.
        LibraryAssert.AreEqual('https://localhost/preview/url/', TempDocumentSharingRec.DocumentPreviewUri, 'Document preview uri not set as expected');
        LibraryAssert.AreEqual('https://localhost/document', TempDocumentSharingRec.DocumentUri, 'Document preview uri not set as expected');
    end;

    [Test]
    procedure ShareEnabledFalseWithNoDocumentService()
    var
        DocumentSharing: Codeunit "Document Sharing";
        ShareEnabled: Boolean;
    begin
        Init();

        // [Given] There is no document service to handle sharing.

        // [When] ShareEnabled is invoked.
        ShareEnabled := DocumentSharing.ShareEnabled();

        // [Then] the result is false.
        LibraryAssert.IsFalse(ShareEnabled, 'Sharing should not be enabled.');
    end;

    [Test]
    procedure ShareEnabledTrueWithDocumentService()
    var
        DocumentSharing: Codeunit "Document Sharing";
        ShareEnabled: Boolean;
    begin
        Init();

        // [Given] There is a document service to handle sharing.
        BindSubscription(DocumentSharingTest);

        // [When] ShareEnabled is invoked.
        ShareEnabled := DocumentSharing.ShareEnabled();

        // [Then] the result is true.
        LibraryAssert.IsTrue(ShareEnabled, 'Sharing should be enabled.');
    end;

    local procedure InitDocumentSharingRec(var DocumentSharingRec: Record "Document Sharing")
    var
        OutStr: OutStream;
    begin
        DocumentSharingRec.Name := 'My File.pdf';
        DocumentSharingRec.Extension := '.pdf';
        DocumentSharingRec.Data.CreateOutStream(OutStr);
        OutStr.WriteText('data');
        DocumentSharingRec.Insert();
    end;

    local procedure Init()
    begin
        UnbindSubscription(DocumentSharingTest);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Document Sharing", 'OnUploadDocument', '', false, false)]
    local procedure OnUploadDocument(var DocumentSharing: Record "Document Sharing" temporary; var Handled: Boolean)
    begin
        if Handled then
            exit;

        DocumentSharing.DocumentPreviewUri := 'https://localhost/preview/url/';
        DocumentSharing.DocumentUri := 'https://localhost/document';
        DocumentSharing.Modify();

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Document Sharing", 'OnCanUploadDocument', '', false, false)]
    local procedure OnCanUploadDocument(var CanUpload: Boolean)
    begin
        CanUpload := true;
    end;

    [HyperlinkHandler]
    procedure HandleHyperlink(url: Text)
    begin
        LibraryAssert.AreEqual('https://localhost/preview/url/', url, 'Should match preview uri');
    end;
}
