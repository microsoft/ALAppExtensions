// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Integration;

using System.Integration;
using System.TestLibraries.Utilities;

codeunit 132593 "Document Sharing Test"
{
    EventSubscriberInstance = Manual;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryAssert: Codeunit "Library Assert";
        DocumentSharingTest: Codeunit "Document Sharing Test";
        NoDocToShareErr: Label 'No file to share.';
        NoDocServiceConfiguredErr: Label 'Document service is not configured';
        NoShareQst: Label 'We couldn''t share this file. Would you like to open it?';
        NoDocUploadedErr: Label 'We couldn''t share or open this file.';
        PromptQst: Label 'The file has been copied to OneDrive. What would you like to do with it?';
        NoPromptOpenOnlyQst: Label 'Would you like to open this file?';
        AddEditedDocQst: Label 'Do you want to add the document you edited and saved?';
        ExpectedResultTxt: Label 'This is the resulting text';

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

    [Test]
    [HandlerFunctions('HandleShareUx')]
    procedure ShareIntentOpensDocumentSharingWhenValid()
    var
        TempDocumentSharingRec: Record "Document Sharing" temporary;
        DocumentSharing: Codeunit "Document Sharing";
    begin
        Init();

        // [Given] A valid document sharing record and there is a document service to handle it.
        BindSubscription(DocumentSharingTest);
        InitDocumentSharingRec(TempDocumentSharingRec);
        TempDocumentSharingRec."Document Sharing Intent" := TempDocumentSharingRec."Document Sharing Intent"::Share;
        TempDocumentSharingRec.Modify();

        // [When] Document Sharing is invoked.
        DocumentSharing.Run(TempDocumentSharingRec);

        // [Then] The document sharing page opens and is validated.
    end;

    [Test]
    [HandlerFunctions('ConfirmOpenHyperlink,HandleHyperlink')]
    procedure ShareIntentPromptsDocumentHyperlinkWhenMissingToken()
    var
        TempDocumentSharingRec: Record "Document Sharing" temporary;
        DocumentSharing: Codeunit "Document Sharing";
        OutStr: OutStream;
    begin
        Init();

        // [Given] A valid document sharing record and there is a document service to handle it.
        BindSubscription(DocumentSharingTest);
        InitDocumentSharingRec(TempDocumentSharingRec);
        TempDocumentSharingRec."Document Sharing Intent" := TempDocumentSharingRec."Document Sharing Intent"::Share;
        TempDocumentSharingRec.Data.CreateOutStream(OutStr);
        OutStr.WriteText('NoToken');
        TempDocumentSharingRec.Modify();

        // [When] Document Sharing is invoked, but no token will be returned.
        DocumentSharing.Run(TempDocumentSharingRec);

        // [Then] The document sharing page prompts to open the preview instead.
    end;

    [Test]
    procedure ShareIntentThrowsWhenInvalid()
    var
        TempDocumentSharingRec: Record "Document Sharing" temporary;
        DocumentSharing: Codeunit "Document Sharing";
        OutStr: OutStream;
    begin
        Init();

        // [Given] A valid document sharing record and there is a document service to handle it.
        BindSubscription(DocumentSharingTest);
        InitDocumentSharingRec(TempDocumentSharingRec);
        TempDocumentSharingRec."Document Sharing Intent" := TempDocumentSharingRec."Document Sharing Intent"::Share;
        TempDocumentSharingRec.Data.CreateOutStream(OutStr);
        OutStr.WriteText('SilentFail');
        TempDocumentSharingRec.Modify();

        // [When] Document Sharing is invoked, but the share fails.
        asserterror DocumentSharing.Run(TempDocumentSharingRec);

        // [Then] The appropriate error message is thrown.
        LibraryAssert.ExpectedError(NoDocUploadedErr);
    end;

    [Test]
    [HandlerFunctions('HandleHyperlink')]
    procedure OpenIntentOpensDocumentHyperlinkWhenValid()
    var
        TempDocumentSharingRec: Record "Document Sharing" temporary;
        DocumentSharing: Codeunit "Document Sharing";
    begin
        Init();

        // [Given] A valid document sharing record and there is a document service to handle it.
        BindSubscription(DocumentSharingTest);
        InitDocumentSharingRec(TempDocumentSharingRec);
        TempDocumentSharingRec."Document Sharing Intent" := TempDocumentSharingRec."Document Sharing Intent"::Open;
        TempDocumentSharingRec.Modify();

        // [When] Document Sharing is invoked.
        DocumentSharing.Run(TempDocumentSharingRec);

        // [Then] The document preview opens (in the handler).
    end;

    [Test]
    procedure OpenIntentThrowsWhenInvalid()
    var
        TempDocumentSharingRec: Record "Document Sharing" temporary;
        DocumentSharing: Codeunit "Document Sharing";
        OutStr: OutStream;
    begin
        Init();

        // [Given] A valid document sharing record and there is a document service to handle it.
        BindSubscription(DocumentSharingTest);
        InitDocumentSharingRec(TempDocumentSharingRec);
        TempDocumentSharingRec."Document Sharing Intent" := TempDocumentSharingRec."Document Sharing Intent"::Open;
        TempDocumentSharingRec.Data.CreateOutStream(OutStr);
        OutStr.WriteText('SilentFail');
        TempDocumentSharingRec.Modify();

        // [When] Document Sharing is invoked, but the open fails.
        asserterror DocumentSharing.Run(TempDocumentSharingRec);

        // [Then] The appropriate error message is thrown.
        LibraryAssert.ExpectedError(NoDocUploadedErr);
    end;

    [Test]
    [HandlerFunctions('PromptMenuOpenHyperlink,HandleHyperlink')]
    procedure PromptIntentShowsPromptWhenValidForHyperlink()
    var
        TempDocumentSharingRec: Record "Document Sharing" temporary;
        DocumentSharing: Codeunit "Document Sharing";
    begin
        Init();

        // [Given] A valid document sharing record and there is a document service to handle it.
        BindSubscription(DocumentSharingTest);
        InitDocumentSharingRec(TempDocumentSharingRec);
        TempDocumentSharingRec."Document Sharing Intent" := TempDocumentSharingRec."Document Sharing Intent"::Prompt;
        TempDocumentSharingRec.Modify();

        // [When] Document Sharing is invoked.
        DocumentSharing.Run(TempDocumentSharingRec);

        // [Then] The document preview opens (in the handler).
    end;

    [Test]
    [HandlerFunctions('PromptMenuOpenShare,HandleShareUx')]
    procedure PromptIntentShowsPromptWhenValidForShare()
    var
        TempDocumentSharingRec: Record "Document Sharing" temporary;
        DocumentSharing: Codeunit "Document Sharing";
    begin
        Init();

        // [Given] A valid document sharing record and there is a document service to handle it.
        BindSubscription(DocumentSharingTest);
        InitDocumentSharingRec(TempDocumentSharingRec);
        TempDocumentSharingRec."Document Sharing Intent" := TempDocumentSharingRec."Document Sharing Intent"::Prompt;
        TempDocumentSharingRec.Modify();

        // [When] Document Sharing is invoked.
        DocumentSharing.Run(TempDocumentSharingRec);

        // [Then] The document preview opens (in the handler).
    end;

    [Test]
    [HandlerFunctions('PromptOpenHyperlink,HandleHyperlink')]
    procedure PromptIntentShowsOpenConfirmationWhenOnlyOption()
    var
        TempDocumentSharingRec: Record "Document Sharing" temporary;
        DocumentSharing: Codeunit "Document Sharing";
        OutStr: OutStream;
    begin
        Init();

        // [Given] A valid document sharing record and there is a document service to handle it.
        BindSubscription(DocumentSharingTest);
        InitDocumentSharingRec(TempDocumentSharingRec);
        TempDocumentSharingRec."Document Sharing Intent" := TempDocumentSharingRec."Document Sharing Intent"::Prompt;
        TempDocumentSharingRec.Data.CreateOutStream(OutStr);
        OutStr.WriteText('NoToken');
        TempDocumentSharingRec.Modify();

        // [When] Document Sharing is invoked.
        DocumentSharing.Run(TempDocumentSharingRec);

        // [Then] The document sharing page prompts to open the preview instead.
    end;

    [Test]
    procedure PromptIntentShowsErrorWhenInvalid()
    var
        TempDocumentSharingRec: Record "Document Sharing" temporary;
        DocumentSharing: Codeunit "Document Sharing";
        OutStr: OutStream;
    begin
        Init();

        // [Given] A valid document sharing record and there is a document service to handle it.
        BindSubscription(DocumentSharingTest);
        InitDocumentSharingRec(TempDocumentSharingRec);
        TempDocumentSharingRec."Document Sharing Intent" := TempDocumentSharingRec."Document Sharing Intent"::Prompt;
        TempDocumentSharingRec.Data.CreateOutStream(OutStr);
        OutStr.WriteText('SilentFail');
        TempDocumentSharingRec.Modify();

        // [When] Document Sharing is invoked, but the open fails.
        asserterror DocumentSharing.Run(TempDocumentSharingRec);

        // [Then] The appropriate error message is thrown.
        LibraryAssert.ExpectedError(NoDocUploadedErr);
    end;

    [Test]
    [HandlerFunctions('PromptMenuCancelled')]
    procedure PromptIntentShowsErrorWhenCancelled()
    var
        TempDocumentSharingRec: Record "Document Sharing" temporary;
        DocumentSharing: Codeunit "Document Sharing";
    begin
        Init();

        // [Given] A valid document sharing record and there is a document service to handle it.
        BindSubscription(DocumentSharingTest);
        InitDocumentSharingRec(TempDocumentSharingRec);
        TempDocumentSharingRec."Document Sharing Intent" := TempDocumentSharingRec."Document Sharing Intent"::Prompt;
        TempDocumentSharingRec.Modify();

        // [When] Document Sharing is invoked, but the prompt is cancelled.
        asserterror DocumentSharing.Run(TempDocumentSharingRec);

        // [Then] The appropriate error message is thrown.
        LibraryAssert.ExpectedError(NoDocToShareErr);
    end;

    [Test]
    [HandlerFunctions('AddEditedDocument,HandleHyperlink')]
    procedure EditIntentOpensAndGetsEditedDocumentWhenValid()
    var
        TempDocumentSharingRec: Record "Document Sharing" temporary;
        DocumentSharing: Codeunit "Document Sharing";
        Result: Text;
        Instream: InStream;
    begin
        Init();

        // [Given] A valid document sharing record and there is a document service to handle it.
        BindSubscription(DocumentSharingTest);
        InitDocumentSharingRec(TempDocumentSharingRec, '.docx');
        TempDocumentSharingRec."Document Sharing Intent" := TempDocumentSharingRec."Document Sharing Intent"::Edit;
        TempDocumentSharingRec.Modify();

        // [When] Document Sharing is invoked.
        DocumentSharing.Run(TempDocumentSharingRec);

        // [Then] The document returned is correct.
        TempDocumentSharingRec.Data.CreateInStream(InStream);
        Instream.ReadText(Result);

        LibraryAssert.AreEqual(ExpectedResultTxt, Result, 'Returned document does not match expected document');
    end;

    [Test]
    procedure EditEnabledForFileTypes()
    var
        DocumentSharing: Codeunit "Document Sharing";
        FilenameTxt: Label 'filename';
        EditShouldBeEnabledErr: Label '%1 extension should be enabled for editing', Comment = '%1 = file extension';
        EditShouldNotBeEnabledErr: Label '%1 extension should not be enabled for editing', Comment = '%1 = file extension';
        Extension: Text;
        ExtensionsString: Text;
        Extensions: List of [Text];
    begin
        // [Given] A list of valid file extensions ('docx,xlsx'...)
        ExtensionsString := 'docx,xlsx,pptx,odt,txt';
        Extensions := ExtensionsString.Split(',');

        // [When] Document Sharing check is invoked
        // [Then] Edit is enabled for file extension
        foreach Extension in Extensions do
            LibraryAssert.IsTrue(DocumentSharing.EditEnabledForFile(FilenameTxt + '.' + Extension), StrSubstNo(EditShouldBeEnabledErr, Extension));

        // [Given] A list of invalid file extensions ('doc,xls,xml'...)
        ExtensionsString := 'doc,xls,xml';
        Extensions := ExtensionsString.Split(',');

        // [When] Document Sharing check is invoked
        // [Then] Edit is not enabled for file extension
        foreach Extension in Extensions do
            LibraryAssert.IsFalse(DocumentSharing.EditEnabledForFile(FilenameTxt + '.' + Extension), StrSubstNo(EditShouldNotBeEnabledErr, Extension));
    end;

    local procedure InitDocumentSharingRec(var DocumentSharingRec: Record "Document Sharing")
    begin
        InitDocumentSharingRec(DocumentSharingRec, '.pdf');
    end;

    local procedure InitDocumentSharingRec(var DocumentSharingRec: Record "Document Sharing"; Extension: Text)
    var
        OutStr: OutStream;
    begin
        DocumentSharingRec.Name := 'My File' + Extension;
        DocumentSharingRec.Extension := CopyStr(Extension, 1, MaxStrLen(DocumentSharingRec.Extension));
        DocumentSharingRec.Data.CreateOutStream(OutStr);
        OutStr.WriteText('data');
        DocumentSharingRec.Insert();
    end;

    local procedure Init()
    begin
        UnbindSubscription(DocumentSharingTest);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Document Sharing", 'OnDeleteDocument', '', false, false)]
    local procedure OnDeleteDocument(var DocumentSharing: Record "Document Sharing" temporary; var Handled: Boolean)
    begin
        if Handled then
            exit;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Document Sharing", 'OnGetFileContents', '', false, false)]
    local procedure OnGetFileContents(var DocumentSharing: Record "Document Sharing" temporary; var Handled: Boolean)
    var
        OutStream: OutStream;
    begin
        if Handled then
            exit;

        Handled := true;

        DocumentSharing.Data.CreateOutStream(OutStream);
        OutStream.WriteText(ExpectedResultTxt);
        DocumentSharing.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Document Sharing", 'OnUploadDocument', '', false, false)]
    local procedure OnUploadDocument(var DocumentSharing: Record "Document Sharing" temporary; var Handled: Boolean)
    var
        InStr: InStream;
        OutStr: OutStream;
        Data: Text;
    begin
        if Handled then
            exit;

        Handled := true;

        DocumentSharing.Data.CreateInStream(InStr);
        InStr.ReadText(Data);

        if Data = 'SilentFail' then
            exit;

        DocumentSharing.DocumentPreviewUri := 'https://localhost/preview/url/';
        DocumentSharing.DocumentUri := 'https://localhost/document';
        DocumentSharing.DocumentRootUri := 'https://localhost/root';

        if Data <> 'NoToken' then begin
            DocumentSharing.Token.CreateOutStream(OutStr);
            OutStr.WriteText('Definitely a valid token');
        end;
        DocumentSharing.Modify();
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

    [PageHandler]
    procedure HandleShareUx(var DocumentSharing: TestPage "Document Sharing")
    begin
        LibraryAssert.AreEqual('https://localhost/root', DocumentSharing.DocumentRootUri.Value, 'Should match the Document Root Uri');
        LibraryAssert.AreEqual('https://localhost/document', DocumentSharing.DocumentUri.Value, 'Should match the Document Uri');
        LibraryAssert.AreEqual('.pdf', DocumentSharing.Extension.Value, 'Should match the specified extension');
        LibraryAssert.AreEqual('My File.pdf', DocumentSharing.Name.Value, 'Should match the specified name');
        LibraryAssert.AreEqual('Definitely a valid token', DocumentSharing.SharingToken.Value, 'Should match the provided token');

        DocumentSharing.Close();
    end;

    [ConfirmHandler]
    procedure AddEditedDocument(Question: Text[1024]; var Reply: Boolean)
    begin
        LibraryAssert.AreEqual(AddEditedDocQst, Question, 'The prompt does not match the expected question');
        Reply := true;
    end;

    [ConfirmHandler]
    procedure ConfirmOpenHyperlink(Question: Text[1024]; var Reply: Boolean)
    begin
        LibraryAssert.AreEqual(NoShareQst, Question, 'The prompt does not match the expected question');
        Reply := true;
    end;

    [ConfirmHandler]
    procedure PromptOpenHyperlink(Question: Text[1024]; var Reply: Boolean)
    begin
        LibraryAssert.AreEqual(NoPromptOpenOnlyQst, Question, 'The prompt does not match the expected question');
        Reply := true;
    end;

    [StrMenuHandler]
    procedure PromptMenuOpenHyperlink(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        LibraryAssert.AreEqual(PromptQst, Instruction, 'This is not the expected prompt');
        Choice := 1;
    end;

    [StrMenuHandler]
    procedure PromptMenuOpenShare(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        LibraryAssert.AreEqual(PromptQst, Instruction, 'This is not the expected prompt');
        Choice := 2;
    end;

    [StrMenuHandler]
    procedure PromptMenuCancelled(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        LibraryAssert.AreEqual(PromptQst, Instruction, 'This is not the expected prompt');
        Choice := 0;
    end;
}
