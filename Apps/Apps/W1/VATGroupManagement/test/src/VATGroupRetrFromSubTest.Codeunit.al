codeunit 139522 "VAT Group Retr. From Sub Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryVATGroup: Codeunit "Library - VAT Group";
        SuggestLinesBeforeErr: Label 'You must run the Suggest Lines action before you include returns for the VAT group.';

    [Test]
    procedure TestVATStatementReportLineMissing()
    var
        VATStatementReportLine: Record "VAT Statement Report Line";
    begin
        // [SCENARIO 374187] VAT Statement Report Line Missing

        // [WHEN] The table "VAT Statement Report Line" is empty
        VATStatementReportLine.DeleteAll();

        // [WHEN] Running the codeunit "VAT Group Retrieve From Sub."
        // [THEN] An error is expected
        asserterror Codeunit.Run(Codeunit::"VAT Group Retrieve From Sub.");
        Assert.ExpectedError(SuggestLinesBeforeErr);
    end;

    [Test]
    procedure TestVATGroupRetrieveFromSubExecution()
    var
        VATReportHeader: Record "VAT Report Header";
        VATStatementReportLine: Record "VAT Statement Report Line";
        VATGroupSubmissionHeader: Record "VAT Group Submission Header";
        MemberID: Guid;
    begin
        // [SCENARIO 374187] VAT Group Retrieve From Sub Execution

        // [WHEN] The tables are correctly configured
        LibraryVATGroup.MockVATReportHeaderWithDates(VATReportHeader, Today(), Today());
        LibraryVATGroup.MockVATStatementReportLineWithBoxNo(VATStatementReportLine, VATReportHeader, 0, '', 'TestBoxNo');
        LibraryVATGroup.UpdateVATReportLineAmounts(VATStatementReportLine, 100, 200, 0);
        MemberID := LibraryVATGroup.MockVATGroupApprovedMember();
        VATGroupSubmissionHeader.GET(LibraryVATGroup.MockVATGroupSubmissionHeader(Today(), Today(), MemberID));
        LibraryVATGroup.MockVATGroupSubmissionLine(VATGroupSubmissionHeader, 128, 'TestBoxNo', '');

        // [WHEN] Running the codeunit "VAT Group Retrieve From Sub."
        Codeunit.Run(Codeunit::"VAT Group Retrieve From Sub.", VATReportHeader);

        // [THEN] The Amount in the table "VAT Statement Report Line" is correctly updated
        VATStatementReportLine.FindFirst();
        Assert.AreEqual(VATStatementReportLine.Amount, 328, 'The Amount should be 328');
    end;
}
