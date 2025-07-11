codeunit 148061 "Document Attachment CZL"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Core] [Document Attachments]
        isInitialized := false;
    end;

    var
        VIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL";
        VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";
        Assert: Codeunit Assert;
        LibraryRandom: Codeunit "Library - Random";
        isInitialized: Boolean;

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Document Attachment CZL");
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Document Attachment CZL");

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Document Attachment CZL");
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
        Initialize();

        // [GIVEN] New VIES Declaration has been created
        VIESDeclarationHeaderCZL.Init();
        VIESDeclarationHeaderCZL."No." := CopyStr(LibraryRandom.RandText(20), 1, 20);
        VIESDeclarationHeaderCZL.Insert();

        // [GIVEN] New text document has been created
        TempBlob.CreateOutStream(TextOutStream);
        TextOutStream.WriteText(LibraryRandom.RandText(1000));

        // [WHEN] Attach document to VIES Declaration
        RecordRef.GetTable(VIESDeclarationHeaderCZL);
        TempBlob.CreateInStream(DocumentInStream);
        DocumentAttachment.SaveAttachmentFromStream(DocumentInStream, RecordRef, 'random.txt');

        // [THEN] One document will be attached
        DocumentAttachment.SetRange("Table ID", Database::"VIES Declaration Header CZL");
        DocumentAttachment.SetRange("No.", VIESDeclarationHeaderCZL."No.");
        Assert.AreEqual(1, DocumentAttachment.Count(), 'One attachment was expected for this record.');

        // [THEN] Document will be attached by current user
        DocumentAttachment.FindFirst();
        Assert.AreEqual(UserSecurityId(), DocumentAttachment."Attached By", 'AttachedBy is not eqal to USERSECURITYID');

        // [THEN] Document attachment will be type text
        Assert.AreEqual(8, DocumentAttachment."File Type", 'File type is not Other.');

        // [THEN] Document attachment will have date and time
        Assert.IsTrue(DocumentAttachment."Attached Date" > 0DT, 'Missing attach date');

        // [THEN] Document attachment will have content
        Assert.IsTrue(DocumentAttachment."Document Reference ID".HasValue, 'Document reference ID is null.');
    end;

    [Test]
    procedure VIESDeclarationPrintToAttachDocument()
    var
        DocumentAttachment: Record "Document Attachment";
        CompanyOfficialCZL: Record "Company Official CZL";
    begin
        // [SCENARIO] Print VIES Declaration as attached PDF
        Initialize();

        // [GIVEN] New VIES Declaration has been created
        VIESDeclarationHeaderCZL.Init();
        VIESDeclarationHeaderCZL."No." := CopyStr(LibraryRandom.RandText(20), 1, 20);
        VIESDeclarationHeaderCZL.Insert();

        // [GIVEN] Authorized employee has been filled
        CompanyOfficialCZL.Init();
        CompanyOfficialCZL."No." := 'EMPL0001';
        CompanyOfficialCZL.Insert();
        VIESDeclarationHeaderCZL."Authorized Employee No." := CompanyOfficialCZL."No.";
        VIESDeclarationHeaderCZL.Modify();

        // [WHEN] Print VIES Declaration as PDF
        VIESDeclarationHeaderCZL.PrintToDocumentAttachment();
        RecallNotificationsForRecord(VIESDeclarationHeaderCZL);

        // [THEN] One document will be attached
        DocumentAttachment.SetRange("Table ID", Database::"VIES Declaration Header CZL");
        DocumentAttachment.SetRange("No.", VIESDeclarationHeaderCZL."No.");
        Assert.AreEqual(1, DocumentAttachment.Count(), 'One attachment was expected for this record.');
    end;

    [Test]
    procedure VIESDeclarationAttachDocumentIsDeleted()
    var
        DocumentAttachment: Record "Document Attachment";
        CompanyOfficialCZL: Record "Company Official CZL";
    begin
        // [SCENARIO] Delete document attachment when deteled VIES Declaration
        Initialize();

        // [GIVEN] New VIES Declaration has been created
        VIESDeclarationHeaderCZL.Init();
        VIESDeclarationHeaderCZL."No." := CopyStr(LibraryRandom.RandText(20), 1, 20);
        VIESDeclarationHeaderCZL.Insert();

        // [GIVEN] Authorized employee has been filled
        CompanyOfficialCZL.Init();
        CompanyOfficialCZL."No." := 'EMPL0002';
        CompanyOfficialCZL.Insert();
        VIESDeclarationHeaderCZL."Authorized Employee No." := CompanyOfficialCZL."No.";
        VIESDeclarationHeaderCZL.Modify();

        // [GIVEN] VIES Declaration has been printed as PDF
        VIESDeclarationHeaderCZL.PrintToDocumentAttachment();
        RecallNotificationsForRecord(VIESDeclarationHeaderCZL);

        // [WHEN] Delete VIES Declaration
        VIESDeclarationHeaderCZL.Delete();

        // [THEN] No document will be attached
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
        // [SCENARIO] Create random text document and attach to VAT Control Report
        Initialize();

        // [GIVEN] New VAT Control Report has been created
        VATCtrlReportHeaderCZL.Init();
        VATCtrlReportHeaderCZL."No." := CopyStr(LibraryRandom.RandText(20), 1, 20);
        VATCtrlReportHeaderCZL.Insert();

        // [GIVEN] New text document has been created
        TempBlob.CreateOutStream(TextOutStream);
        TextOutStream.WriteText(LibraryRandom.RandText(1000));

        // [WHEN] Attach document to VAT Control Report
        RecordRef.GetTable(VATCtrlReportHeaderCZL);
        TempBlob.CreateInStream(DocumentInStream);
        DocumentAttachment.SaveAttachmentFromStream(DocumentInStream, RecordRef, 'random.txt');

        // [THEN] One document will be attached
        DocumentAttachment.SetRange("Table ID", Database::"VAT Ctrl. Report Header CZL");
        DocumentAttachment.SetRange("No.", VATCtrlReportHeaderCZL."No.");
        Assert.AreEqual(1, DocumentAttachment.Count(), 'One attachment was expected for this record.');

        // [THEN] Document will be attached by current user
        DocumentAttachment.FindFirst();
        Assert.AreEqual(UserSecurityId(), DocumentAttachment."Attached By", 'AttachedBy is not eqal to USERSECURITYID');

        // [THEN] Document attachment will be type text
        Assert.AreEqual(8, DocumentAttachment."File Type", 'File type is not Other.');

        // [THEN] Document attachment will have date and time
        Assert.IsTrue(DocumentAttachment."Attached Date" > 0DT, 'Missing attach date');

        // [THEN] Document attachment will have content
        Assert.IsTrue(DocumentAttachment."Document Reference ID".HasValue, 'Document reference ID is null.');
    end;

    [Test]
    procedure VATCtrlReportPrintToAttachDocument()
    var
        DocumentAttachment: Record "Document Attachment";
    begin
        // [SCENARIO] Print VAT Control Report as attached PDF
        Initialize();

        // [GIVEN] New VAT Control Report has been created
        VATCtrlReportHeaderCZL.Init();
        VATCtrlReportHeaderCZL."No." := CopyStr(LibraryRandom.RandText(20), 1, 20);
        VATCtrlReportHeaderCZL.Insert();

        // [WHEN] Print VAT Control Report as PDF
        VATCtrlReportHeaderCZL.PrintToDocumentAttachment();
        RecallNotificationsForRecord(VATCtrlReportHeaderCZL);

        // [THEN] One document will be attached
        DocumentAttachment.SetRange("Table ID", Database::"VAT Ctrl. Report Header CZL");
        DocumentAttachment.SetRange("No.", VATCtrlReportHeaderCZL."No.");
        Assert.AreEqual(1, DocumentAttachment.Count(), 'One attachment was expected for this record.');
    end;

    [Test]
    procedure VATCtrlReportAttachDocumentIsDeleted()
    var
        DocumentAttachment: Record "Document Attachment";
    begin
        // [SCENARIO] Delete document attachment when deteled VAT Control Report
        Initialize();

        // [GIVEN] New VAT Control Report has been created
        VATCtrlReportHeaderCZL.Init();
        VATCtrlReportHeaderCZL."No." := CopyStr(LibraryRandom.RandText(20), 1, 20);
        VATCtrlReportHeaderCZL.Insert();

        // [GIVEN] VAT Control Report has been printed as PDF
        VATCtrlReportHeaderCZL.PrintToDocumentAttachment();
        RecallNotificationsForRecord(VATCtrlReportHeaderCZL);

        // [WHEN] Delete VAT Control Report
        VATCtrlReportHeaderCZL.Delete();

        // [THEN] No document will be attached
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
