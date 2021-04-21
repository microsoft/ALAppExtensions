codeunit 148061 "Document Attachment CZL"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        VIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL";
        VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";
        Assert: Codeunit Assert;
        LibraryRandom: Codeunit "Library - Random";
        isInitialized: Boolean;

    local procedure Initialize()
    begin
        if isInitialized then
            exit;

        isInitialized := true;
        Commit();
    end;

    [Test]
    procedure VIESDeclarationAttachDocument()
    var
        DocumentAttachment: Record "Document Attachment";
        TempBlob: Codeunit "Temp Blob";
        RecordRef: RecordRef;
        TextOutStream: OutStream;
        DocumentInStream: InStream;
    begin
        // [SCENARIO] Create random text document and attach to VIES Declaration
        // [FEATURE] Document Attachment
        Initialize();

        // [GIVEN] New VIES Declaration created
        VIESDeclarationHeaderCZL.Init();
        VIESDeclarationHeaderCZL."No." := CopyStr(LibraryRandom.RandText(20), 1, 20);
        VIESDeclarationHeaderCZL.Insert();

        // [GIVEN] New text document created
        TempBlob.CreateOutStream(TextOutStream);
        TextOutStream.WriteText(LibraryRandom.RandText(1000));

        // [WHEN] Attach document to VIES Declaration
        RecordRef.GetTable(VIESDeclarationHeaderCZL);
        TempBlob.CreateInStream(DocumentInStream);
        DocumentAttachment.SaveAttachmentFromStream(DocumentInStream, RecordRef, 'random.txt');

        // [THEN] One document attachment expected
        DocumentAttachment.SetRange("Table ID", Database::"VIES Declaration Header CZL");
        DocumentAttachment.SetRange("No.", VIESDeclarationHeaderCZL."No.");
        Assert.AreEqual(1, DocumentAttachment.Count(), 'One attachment was expected for this record.');

        // [THEN] Verify user security id
        DocumentAttachment.FindFirst();
        Assert.AreEqual(UserSecurityId(), DocumentAttachment."Attached By", 'AttachedBy is not eqal to USERSECURITYID');

        // [THEN] Verify file type
        Assert.AreEqual(8, DocumentAttachment."File Type", 'File type is not Other.');

        // [THEN] Verify table ID
        Assert.AreEqual(31075, DocumentAttachment."Table ID", 'Table Id does not match with VIES Declaration Header CZL');

        // [THEN] Verify record no
        Assert.AreEqual(VIESDeclarationHeaderCZL."No.", DocumentAttachment."No.", 'No. does not match with' + VIESDeclarationHeaderCZL."No.");

        // [THEN] Verify attached date
        Assert.IsTrue(DocumentAttachment."Attached Date" > 0DT, 'Missing attach date');

        // [THEN] Verify doc ref id is not null
        Assert.IsTrue(DocumentAttachment."Document Reference ID".HasValue, 'Document reference ID is null.');
    end;

    [Test]
    procedure VIESDeclarationPrintToAttachDocument()
    var
        DocumentAttachment: Record "Document Attachment";
        CompanyOfficialCZL: Record "Company Official CZL";
    begin
        // [SCENARIO] Print VIES Declaration as attached PDF
        // [FEATURE] Document Attachment
        Initialize();

        // [WHEN] Authorized employee filled
        CompanyOfficialCZL.Init();
        CompanyOfficialCZL."No." := 'EMPL0001';
        CompanyOfficialCZL.Insert();
        VIESDeclarationHeaderCZL."Authorized Employee No." := CompanyOfficialCZL."No.";
        VIESDeclarationHeaderCZL.Modify();

        // [WHEN] Print VIES Declaration as PDF
        VIESDeclarationHeaderCZL.PrintToDocumentAttachment();
        RecallNotificationsForRecord(VIESDeclarationHeaderCZL);

        // [THEN] Two document attachments expected
        DocumentAttachment.SetRange("Table ID", Database::"VIES Declaration Header CZL");
        DocumentAttachment.SetRange("No.", VIESDeclarationHeaderCZL."No.");
        Assert.AreEqual(2, DocumentAttachment.Count(), 'Two attachments were expected for this record.');
    end;

    [Test]
    procedure VIESDeclarationAttachDocumentIsDeleted()
    var
        DocumentAttachment: Record "Document Attachment";
    begin
        // [SCENARIO] Delete document attachment when deteled VIES Declaration
        // [FEATURE] Document Attachment
        Initialize();

        // [WHEN] Deleted VIES Declaration
        VIESDeclarationHeaderCZL.Delete();

        // [THEN] No document attachment expected
        DocumentAttachment.SetRange("Table ID", Database::"VIES Declaration Header CZL");
        DocumentAttachment.SetRange("No.", VIESDeclarationHeaderCZL."No.");
        Assert.AreEqual(0, DocumentAttachment.Count(), 'No attachment was expected for this record.');
    end;

    [Test]
    procedure VATCtrlReportAttachDocument()
    var
        DocumentAttachment: Record "Document Attachment";
        TempBlob: Codeunit "Temp Blob";
        RecordRef: RecordRef;
        TextOutStream: OutStream;
        DocumentInStream: InStream;
    begin
        // [SCENARIO] Create random text document and attach to VAT Ctrl. Report
        // [FEATURE] Document Attachment
        Initialize();

        // [GIVEN] New VIES Declaration created
        VATCtrlReportHeaderCZL.Init();
        VATCtrlReportHeaderCZL."No." := CopyStr(LibraryRandom.RandText(20), 1, 20);
        VATCtrlReportHeaderCZL.Insert();

        // [GIVEN] New text document created
        TempBlob.CreateOutStream(TextOutStream);
        TextOutStream.WriteText(LibraryRandom.RandText(1000));

        // [WHEN] Attach document to VIES Declaration
        RecordRef.GetTable(VATCtrlReportHeaderCZL);
        TempBlob.CreateInStream(DocumentInStream);
        DocumentAttachment.SaveAttachmentFromStream(DocumentInStream, RecordRef, 'random.txt');

        // [THEN] One document attachment expected
        DocumentAttachment.SetRange("Table ID", Database::"VAT Ctrl. Report Header CZL");
        DocumentAttachment.SetRange("No.", VATCtrlReportHeaderCZL."No.");
        Assert.AreEqual(1, DocumentAttachment.Count(), 'One attachment was expected for this record.');

        // [THEN] Verify user security id
        DocumentAttachment.FindFirst();
        Assert.AreEqual(UserSecurityId(), DocumentAttachment."Attached By", 'AttachedBy is not eqal to USERSECURITYID');

        // [THEN] Verify file type
        Assert.AreEqual(8, DocumentAttachment."File Type", 'File type is not Other.');

        // [THEN] Verify table ID
        Assert.AreEqual(31106, DocumentAttachment."Table ID", 'Table Id does not match with VAT Ctrl. Report Header CZL');

        // [THEN] Verify record no
        Assert.AreEqual(VATCtrlReportHeaderCZL."No.", DocumentAttachment."No.", 'No. does not match with' + VATCtrlReportHeaderCZL."No.");

        // [THEN] Verify attached date
        Assert.IsTrue(DocumentAttachment."Attached Date" > 0DT, 'Missing attach date');

        // [THEN] Verify doc ref id is not null
        Assert.IsTrue(DocumentAttachment."Document Reference ID".HasValue, 'Document reference ID is null.');
    end;

    [Test]
    procedure VATCtrlReportPrintToAttachDocument()
    var
        DocumentAttachment: Record "Document Attachment";
    begin
        // [SCENARIO] Print VAT Ctrl. Report as attached PDF
        // [FEATURE] Document Attachment
        Initialize();

        // [WHEN] Print VIES Declaration as PDF
        VATCtrlReportHeaderCZL.PrintToDocumentAttachment();
        RecallNotificationsForRecord(VATCtrlReportHeaderCZL);

        // [THEN] Two document attachments expected
        DocumentAttachment.SetRange("Table ID", Database::"VAT Ctrl. Report Header CZL");
        DocumentAttachment.SetRange("No.", VATCtrlReportHeaderCZL."No.");
        Assert.AreEqual(2, DocumentAttachment.Count(), 'Two attachments were expected for this record.');
    end;

    [Test]
    procedure VATCtrlReportAttachDocumentIsDeleted()
    var
        DocumentAttachment: Record "Document Attachment";
    begin
        // [SCENARIO] Delete document attachment when deteled VAT Ctrl. Report
        // [FEATURE] Document Attachment
        Initialize();

        // [WHEN] Deleted VIES Declaration
        VATCtrlReportHeaderCZL.Delete();

        // [THEN] No document attachment expected
        DocumentAttachment.SetRange("Table ID", Database::"VAT Ctrl. Report Header CZL");
        DocumentAttachment.SetRange("No.", VATCtrlReportHeaderCZL."No.");
        Assert.AreEqual(0, DocumentAttachment.Count(), 'No attachment was expected for this record.');
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
