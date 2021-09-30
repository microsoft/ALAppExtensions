codeunit 148076 "Cash Document Attachments CZP"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Cash Desk] [Document Attachments]
        isInitialized := false;
    end;

    var
        CashDeskCZP: Record "Cash Desk CZP";
        CashDeskUserCZP: Record "Cash Desk User CZP";
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDocumentLineCZP: Record "Cash Document Line CZP";
        PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
        CashDocumentReleaseCZP: Codeunit "Cash Document-Release CZP";
        CashDocumentPostCZP: Codeunit "Cash Document-Post CZP";
        Assert: Codeunit Assert;
        LibraryRandom: Codeunit "Library - Random";
        LibraryCashDeskCZP: Codeunit "Library - Cash Desk CZP";
        LibraryCashDocumentCZP: Codeunit "Library - Cash Document CZP";
        CashDocumentTypeCZP: Enum "Cash Document Type CZP";
        isInitialized: Boolean;

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Cash Document Attachments CZP");
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Cash Document Attachments CZP");

        LibraryCashDeskCZP.CreateCashDeskCZP(CashDeskCZP);
        LibraryCashDeskCZP.SetupCashDeskCZP(CashDeskCZP, false);
        LibraryCashDeskCZP.CreateCashDeskUserCZP(CashDeskUserCZP, CashDeskCZP."No.", true, true, true);

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Cash Document Attachments CZP");
    end;

    [Test]
    procedure CashDocumentAttachDocument()
    var
        DocumentAttachment: Record "Document Attachment";
        TempBlob: Codeunit "Temp Blob";
        RecordRef: RecordRef;
        TextOutStream: OutStream;
        DocumentInStream: InStream;
    begin
        // [SCENARIO] Create random text document and attach to Cash Document
        Initialize();

        // [GIVEN] New receipt Cash Document created
        LibraryCashDocumentCZP.CreateCashDocument(CashDocumentHeaderCZP, CashDocumentLineCZP, CashDocumentTypeCZP::Receipt, CashDeskCZP."No.");

        // [GIVEN] New text document created
        TempBlob.CreateOutStream(TextOutStream);
        TextOutStream.WriteText(LibraryRandom.RandText(1000));

        // [WHEN] Attach document to Cash Document
        RecordRef.GetTable(CashDocumentHeaderCZP);
        TempBlob.CreateInStream(DocumentInStream);
        DocumentAttachment.SaveAttachmentFromStream(DocumentInStream, RecordRef, 'random.txt');

        // [THEN] One document attachment expected
        DocumentAttachment.SetRange("Table ID", Database::"Cash Document Header CZP");
        DocumentAttachment.SetRange("No.", CashDocumentHeaderCZP."No.");
        Assert.AreEqual(1, DocumentAttachment.Count(), 'One attachment was expected for this record.');

        // [THEN] Verify user security id
        DocumentAttachment.FindFirst();
        Assert.AreEqual(UserSecurityId(), DocumentAttachment."Attached By", 'AttachedBy is not eqal to USERSECURITYID');

        // [THEN] Verify file type
        Assert.AreEqual(8, DocumentAttachment."File Type", 'File type is not Other.');

        // [THEN] Verify attached date
        Assert.IsTrue(DocumentAttachment."Attached Date" > 0DT, 'Missing attach date');

        // [THEN] Verify doc ref id is not null
        Assert.IsTrue(DocumentAttachment."Document Reference ID".HasValue(), 'Document reference ID is null.');
    end;

    [Test]
    procedure CashDocumentPrintToAttachDocument()
    var
        DocumentAttachment: Record "Document Attachment";
    begin
        // [SCENARIO] Print Cash Document as attached PDF
        Initialize();

        // [GIVEN] New receipt Cash Document created
        LibraryCashDocumentCZP.CreateCashDocument(CashDocumentHeaderCZP, CashDocumentLineCZP, CashDocumentTypeCZP::Receipt, CashDeskCZP."No.");

        // [GIVEN] Release Cash Document
        CashDocumentReleaseCZP.Run(CashDocumentHeaderCZP);

        // [WHEN] Print Cash Document as PDF
        CashDocumentHeaderCZP.PrintToDocumentAttachment();
        RecallNotificationsForRecord(CashDocumentHeaderCZP);

        // [THEN] One document attachment expected
        DocumentAttachment.SetRange("Table ID", Database::"Cash Document Header CZP");
        DocumentAttachment.SetRange("No.", CashDocumentHeaderCZP."No.");
        Assert.AreEqual(1, DocumentAttachment.Count(), 'One attachment was expected for this record.');
    end;

    [Test]
    procedure CashDocumentAttachDocumentIsDeleted()
    var
        DocumentAttachment: Record "Document Attachment";
    begin
        // [SCENARIO] Delete Cash Document with document attached
        Initialize();

        // [GIVEN] New receipt Cash Document created
        LibraryCashDocumentCZP.CreateCashDocument(CashDocumentHeaderCZP, CashDocumentLineCZP, CashDocumentTypeCZP::Receipt, CashDeskCZP."No.");

        // [GIVEN] Release Cash Document
        CashDocumentReleaseCZP.Run(CashDocumentHeaderCZP);

        // [GIVEN] Print Cash Document as PDF
        CashDocumentHeaderCZP.PrintToDocumentAttachment();
        RecallNotificationsForRecord(CashDocumentHeaderCZP);

        // [WHEN] Deleted Cash Document
        CashDocumentHeaderCZP.Delete();

        // [THEN] No document attachment expected
        DocumentAttachment.SetRange("Table ID", Database::"Cash Document Header CZP");
        DocumentAttachment.SetRange("No.", CashDocumentHeaderCZP."No.");
        Assert.AreEqual(0, DocumentAttachment.Count(), 'No attachment was expected for this record.');
    end;

    [Test]
    procedure PostCashDocumentAttachDocument()
    var
        DocumentAttachment: Record "Document Attachment";
    begin
        // [SCENARIO] Post Cash Document with document attached
        Initialize();

        // [GIVEN] New receipt Cash Document created
        Clear(CashDocumentHeaderCZP);
        Clear(CashDocumentLineCZP);
        LibraryCashDocumentCZP.CreateCashDocument(CashDocumentHeaderCZP, CashDocumentLineCZP, CashDocumentTypeCZP::Receipt, CashDeskCZP."No.");

        // [GIVEN] Release Cash Document
        CashDocumentReleaseCZP.Run(CashDocumentHeaderCZP);

        // [GIVEN] Print Cash Document as PDF
        CashDocumentHeaderCZP.PrintToDocumentAttachment();
        RecallNotificationsForRecord(CashDocumentHeaderCZP);

        // [WHEN] Post Cash Document
        CashDocumentPostCZP.Run(CashDocumentHeaderCZP);

        // [THEN] No unposted cash document attachment expected
        DocumentAttachment.SetRange("Table ID", Database::"Cash Document Header CZP");
        DocumentAttachment.SetRange("No.", CashDocumentHeaderCZP."No.");
        Assert.AreEqual(0, DocumentAttachment.Count(), 'No attachment was expected for this record.');

        // [THEN] One posted cash document attachment expected
        DocumentAttachment.SetRange("Table ID", Database::"Posted Cash Document Hdr. CZP");
        Assert.AreEqual(1, DocumentAttachment.Count(), 'One attachment was expected for this record.');
    end;

    [Test]
    procedure PostedCashDocumentPrintToAttachDocument()
    var
        DocumentAttachment: Record "Document Attachment";
    begin
        // [SCENARIO] Print Posted Cash Document as attached PDF
        Initialize();

        // [GIVEN] New receipt Cash Document created
        Clear(CashDocumentHeaderCZP);
        Clear(CashDocumentLineCZP);
        LibraryCashDocumentCZP.CreateCashDocument(CashDocumentHeaderCZP, CashDocumentLineCZP, CashDocumentTypeCZP::Receipt, CashDeskCZP."No.");

        // [GIVEN] Post Cash Document
        CashDocumentPostCZP.Run(CashDocumentHeaderCZP);

        // [GIVEN] Get Posted Cash Document
        PostedCashDocumentHdrCZP.Get(CashDocumentHeaderCZP."Cash Desk No.", CashDocumentHeaderCZP."No.");

        // [WHEN] Print Posted Cash Document as PDF
        PostedCashDocumentHdrCZP.PrintToDocumentAttachment();
        RecallNotificationsForRecord(PostedCashDocumentHdrCZP);

        // [THEN] One document attachment expected
        DocumentAttachment.SetRange("Table ID", Database::"Posted Cash Document Hdr. CZP");
        DocumentAttachment.SetRange("No.", PostedCashDocumentHdrCZP."No.");
        Assert.AreEqual(1, DocumentAttachment.Count(), 'One attachment was expected for this record.');
    end;

    local procedure RecallNotificationsForRecord(ToRecallRecVariant: Variant)
    var
        RecordRef: RecordRef;
    begin
        RecordRef.GetTable(ToRecallRecVariant);
        RecallNotificationsForRecordID(RecordRef.RecordId);
    end;

    local procedure RecallNotificationsForRecordID(ToRecallRecordID: RecordID)
    var
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
    begin
        NotificationLifecycleMgt.RecallNotificationsForRecord(ToRecallRecordID, false);
    end;
}
