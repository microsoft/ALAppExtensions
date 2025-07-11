codeunit 139520 "VAT Group Helper Funct Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryVATGroup: Codeunit "Library - VAT Group";
        LibraryUtility: Codeunit "Library - Utility";
        Assert: Codeunit Assert;
        VATGroupHelperFunctions: Codeunit "VAT Group Helper Functions";
        NoVATReportSetupErr: Label 'The VAT report setup was not found. You can create one on the VAT Report Setup page.';

    [Test]
    procedure TestSetOriginalRepresentativeAmountWithEmptyVATReportSetup()
    var
        VATReportHeader: Record "VAT Report Header";
    begin
        // [SCENARIO 374187] Set Original Representative Amount With Empty VAT Report Setup

        // [GIVEN] The VAT Report Setup table is empty
        LibraryVATGroup.DeleteVATReportSetup();

        // [WHEN] Calling SetOriginalRepresentativeAmount
        // [THEN] An error should be thrown
        asserterror VATGroupHelperFunctions.SetOriginalRepresentativeAmount(VATReportHeader);
        Assert.ExpectedError(NoVATReportSetupErr);
    end;

    [Test]
    procedure TestSetOriginalRepresentativeAmountWithMemberVATGroupRole()
    var
        VATReportHeader: Record "VAT Report Header";
        VATStatementReportLine: Record "VAT Statement Report Line";
        Amount: Decimal;
    begin
        // [SCENARIO 374187] Set Original Representative Amount With Member VAT Group Role
        Initialize();

        // [GIVEN] A VATReportSetup entry with VAT Group Role - Member
        // [GIVEN] A VATReportHeader
        LibraryVATGroup.MockDummyVATReportHeader(VATReportHeader);

        // [GIVEN] A statement report line that is connected to the VAT report header
        Amount := 100;
        LibraryVATGroup.MockVATStatementReportLine(VATStatementReportLine, VATReportHeader, Amount);

        // [WHEN] Calling SetOriginalRepresentativeAmount
        VATGroupHelperFunctions.SetOriginalRepresentativeAmount(VATReportHeader);

        // [THEN] The statement report line should not be updated
        VATStatementReportLine.Find();
        Assert.AreNotEqual(
          Amount, VATStatementReportLine."Representative Amount",
          'The representative amount should not have been updated for a member role.');
    end;

    [Test]
    procedure TestSetOriginalRepresentativeAmountSunshineScenario()
    var
        VATReportHeader: Record "VAT Report Header";
        ConnectedVATStatementReportLine: Record "VAT Statement Report Line";
        DisconnectedVATStatementReportLine: Record "VAT Statement Report Line";
        AmountOnConnectedLine: Decimal;
        AmountOnDisconnectedLine: Decimal;
    begin
        // [SCENARIO 374187] Set Original Representative Amount Sunshine Scenario

        // [GIVEN] A VATReportSetup entry with VAT Group Role - Representative
        LibraryVATGroup.EnableDefaultVATRepresentativeSetup();

        // [GIVEN] A VATReportHeader
        LibraryVATGroup.MockDummyVATReportHeader(VATReportHeader);

        // [GIVEN] A statement report line that is connected to the VAT report header
        AmountOnConnectedLine := 100;
        LibraryVATGroup.MockVATStatementReportLine(ConnectedVATStatementReportLine, VATReportHeader, AmountOnConnectedLine);

        // [GIVEN] A statement report line that is not connected to the VAT report header
        AmountOnDisconnectedLine := 1000;
        LibraryVATGroup.MockVATStatementReportLineWithNo(
          DisconnectedVATStatementReportLine, LibraryUtility.GenerateGUID(), AmountOnDisconnectedLine);

        // [WHEN] Calling SetOriginalRepresentativeAmount
        VATGroupHelperFunctions.SetOriginalRepresentativeAmount(VATReportHeader);

        // [THEN] The statement report line that is connected to the header will be updated
        ConnectedVATStatementReportLine.Find();
        Assert.AreEqual(
          AmountOnConnectedLine, ConnectedVATStatementReportLine."Representative Amount",
          'The representative amount was not updated correctly.');

        // [THEN] The statement report line that is not connected to the header will not be updated
        DisconnectedVATStatementReportLine.Find();
        Assert.AreNotEqual(
          AmountOnDisconnectedLine, DisconnectedVATStatementReportLine."Representative Amount",
          'The representative amount should not have been updated.');
    end;

    [Test]
    procedure TestCountApprovedMemberSubmissionsForPeriodWithNoApprovedMembers()
    var
        Count: Integer;
    begin
        // [SCENARIO 374187] Count Approved Member Submissions For Period With No Approved Members
        Initialize();

        // [GIVEN] There are no entries in the VAT Group Approved Member table
        // [WHEN] Calling CountApprovedMemberSubmissionsForPeriod
        Count := VATGroupHelperFunctions.CountApprovedMemberSubmissionsForPeriod(0D, Today());

        // [THEN] Count is 0
        Assert.AreEqual(0, Count, 'The count should be 0, as there are no approved members.');
    end;

    [Test]
    procedure TestCountApprovedMemberSubmissionsForPeriodWithWrongDates()
    var
        MemberID: Guid;
        Count: Integer;
    begin
        // [SCENARIO 374187] Count Approved Member Submissions For Period With Wrong Dates
        Initialize();

        // [GIVEN] A VAT Group Approved Member
        // [GIVEN] A group VAT submission header
        LibraryVATGroup.MockVATGroupSubmissionHeader(0D, DMY2Date(1, 1, 2019), MemberID);

        // [WHEN] Calling CountApprovedMemberSubmissionsForPeriod with dates for which there are
        // no submission headers
        Count := VATGroupHelperFunctions.CountApprovedMemberSubmissionsForPeriod(DMY2Date(2, 2, 2020), Today());

        // [THEN] Count is 0
        Assert.AreEqual(0, Count, 'The count should be 0, as there are no valid submission headers for the specified dates.');
    end;

    [Test]
    procedure TestCountApprovedMemberSubmissionsForWrongMemberId()
    var
        MemberID: Guid;
        Count: Integer;
    begin
        // [SCENARIO 374187] Count Approved Member Submissions For Wrong Member Id
        Initialize();

        // [GIVEN] A VAT Group Approved Member
        MemberID := LibraryVATGroup.MockVATGroupApprovedMember();

        // [GIVEN] A group VAT submission header
        LibraryVATGroup.MockVATGroupSubmissionHeader(0D, DMY2Date(1, 1, 2019), CreateGuid());

        // [WHEN] Calling CountApprovedMemberSubmissionsForPeriod with dates for which there are
        // submission headers
        Count := VATGroupHelperFunctions.CountApprovedMemberSubmissionsForPeriod(0D, DMY2Date(1, 1, 2019));

        // [THEN] Count is 0
        Assert.AreEqual(0, Count, 'The count should be 0, as there are no valid group member IDs for the submission headers.');
    end;

    [Test]
    procedure TestCountApprovedMemberSubmissionsForOneMember()
    var
        MemberID: Guid;
        Count: Integer;
    begin
        // [SCENARIO 374187] Count Approved Member Submissions For One Member
        Initialize();

        // [GIVEN] A VAT Group Approved Member
        MemberID := LibraryVATGroup.MockVATGroupApprovedMember();

        // [GIVEN] 2 group VAT submission headers for the approved member
        LibraryVATGroup.MockVATGroupSubmissionHeader(0D, DMY2Date(1, 1, 2019), MemberID);
        LibraryVATGroup.MockVATGroupSubmissionHeader(0D, DMY2Date(1, 1, 2019), MemberID);

        // [WHEN] Calling CountApprovedMemberSubmissionsForPeriod with dates for which there are
        // submission headers
        Count := VATGroupHelperFunctions.CountApprovedMemberSubmissionsForPeriod(0D, DMY2Date(1, 1, 2019));

        // [THEN] Count is 1
        Assert.AreEqual(1, Count, 'The count should be 1, as there is only one group member IDs with submission headers.');
    end;

    [Test]
    procedure TestCountApprovedMemberSubmissionsForTwoMembers()
    var
        MemberID: array[2] of Guid;
        Count: Integer;
    begin
        // [SCENARIO 374187] Count Approved Member Submissions For Two Members
        Initialize();

        // [GIVEN] 2 VAT Group Approved Members
        MemberID[1] := LibraryVATGroup.MockVATGroupApprovedMember();
        MemberID[2] := LibraryVATGroup.MockVATGroupApprovedMember();

        // [GIVEN] 2 group VAT submission headers for the the first member and one for the
        // second member
        LibraryVATGroup.MockVATGroupSubmissionHeader(0D, DMY2Date(1, 1, 2019), MemberID[1]);
        LibraryVATGroup.MockVATGroupSubmissionHeader(0D, DMY2Date(1, 1, 2019), MemberID[1]);
        LibraryVATGroup.MockVATGroupSubmissionHeader(0D, DMY2Date(1, 1, 2019), MemberID[2]);

        // [WHEN] Calling CountApprovedMemberSubmissionsForPeriod with the start and end dates
        // of the created submission headers
        Count := VATGroupHelperFunctions.CountApprovedMemberSubmissionsForPeriod(0D, DMY2Date(1, 1, 2019));

        // [THEN] Count is 2, as we have 2 members with submission headers
        Assert.AreEqual(2, Count, 'The count should be 2, as there are two group member IDs with submission headers.');
    end;

    [Test]
    procedure TestMarkReleasedVATSubmissionsWithNoApprovedMembers()
    var
        VATReportHeader: Record "VAT Report Header";
        VATGroupSubmissionHeader: Record "VAT Group Submission Header";
    begin
        // [SCENARIO 374187] Mark Released VAT Submissions With No Approved Members
        Initialize();
        VATGroupSubmissionHeader.DeleteAll();

        // [GIVEN] A VATReportSetup entry with VAT Group Role - Member
        // [GIVEN] A VATReportHeader        
        // [GIVEN] No VAT Group Approved Members
        LibraryVATGroup.MockDummyVATReportHeader(VATReportHeader);

        // [WHEN] Calling MarkReleasedVATSubmissions
        VATGroupHelperFunctions.MarkReleasedVATSubmissions(VATReportHeader);

        // [THEN] The VAT Group Submission Header should not get modified, as it is not linked
        // to a valid VAT Group Approved Member
        Assert.RecordIsEmpty(VATGroupSubmissionHeader);
    end;

    [Test]
    procedure TestMarkReleasedVATSubmissionsWithInvalidStartDate()
    var
        VATReportHeader: Record "VAT Report Header";
        VATGroupSubmissionHeader: Record "VAT Group Submission Header";
        SubmissionHeaderID: Guid;
        EndDate: Date;
    begin
        // [SCENARIO 374187] Mark Released VAT Submissions With Invalid Start Date
        Initialize();

        // [GIVEN] A VATReportSetup entry with VAT Group Role - Member
        // [GIVEN] A VATReportHeader
        EndDate := Today();
        LibraryVATGroup.MockVATReportHeaderWithDates(VATReportHeader, 0D, EndDate);

        // [GIVEN] A group VAT submission header with a different start date than that of the
        // report header's, but valid end date and VAT group return no.
        SubmissionHeaderID := LibraryVATGroup.MockVATGroupSubmissionHeader(DMY2Date(1, 1, 2019), EndDate, CreateGuid());

        // [WHEN] Calling MarkReleasedVATSubmissions
        VATGroupHelperFunctions.MarkReleasedVATSubmissions(VATReportHeader);

        // [THEN] The VAT Group Submission Header should not get modified, as it has a different
        // start date than the report header
        VATGroupSubmissionHeader.Get(SubmissionHeaderID);
        Assert.AreEqual(
          '', VATGroupSubmissionHeader."VAT Group Return No.",
          'The VAT Group Return No. should not have been modified');
    end;

    [Test]
    procedure TestMarkReleasedVATSubmissionsWithInvalidEndDate()
    var
        VATReportHeader: Record "VAT Report Header";
        VATGroupSubmissionHeader: Record "VAT Group Submission Header";
        SubmissionHeaderID: Guid;
        StartDate: Date;
    begin
        // [SCENARIO 374187] Mark Released VAT Submissions With Invalid End Date
        Initialize();

        // [GIVEN] A VATReportSetup entry with VAT Group Role - Member
        // [GIVEN] A VATReportHeader
        StartDate := 0D;
        LibraryVATGroup.MockVATReportHeaderWithDates(VATReportHeader, StartDate, Today());

        // [GIVEN] A group VAT submission header with a different end date than that of the
        // report header's, but a valid start date and VAT group return no.
        SubmissionHeaderID := LibraryVATGroup.MockVATGroupSubmissionHeader(StartDate, DMY2Date(8, 8, 2019), CreateGuid());

        // [WHEN] Calling MarkReleasedVATSubmissions
        VATGroupHelperFunctions.MarkReleasedVATSubmissions(VATReportHeader);

        // [THEN] The VAT Group Submission Header should not get modified, as it has a different
        // end date than the report header
        VATGroupSubmissionHeader.Get(SubmissionHeaderID);
        Assert.AreEqual(
          '', VATGroupSubmissionHeader."VAT Group Return No.",
          'The VAT Group Return No. should not have been modified');
    end;

    [Test]
    procedure TestMarkReleasedVATSubmissionsWithInvalidVATGroupReturnNo()
    var
        VATReportHeader: Record "VAT Report Header";
        VATGroupSubmissionHeader: Record "VAT Group Submission Header";
        SubmissionHeaderID: Guid;
        StartDate: Date;
        EndDate: Date;
        VATGroupReturnNo: Code[20];
    begin
        // [SCENARIO 374187] Mark Released VAT Submissions With Invalid VAT Group Return No
        Initialize();

        // [GIVEN] A VATReportSetup entry with VAT Group Role - Member
        // [GIVEN] A VATReportHeader
        StartDate := 0D;
        EndDate := Today();
        LibraryVATGroup.MockVATReportHeaderWithDates(VATReportHeader, StartDate, EndDate);

        // [GIVEN] A group VAT submission header with valid start and end dates, but an invalid VAT group return no.
        VATGroupReturnNo := 'code';
        SubmissionHeaderID :=
          LibraryVATGroup.MockVATGroupSubmissionHeaderWithGroupReturnNo(StartDate, EndDate, CreateGuid(), VATGroupReturnNo);

        // [WHEN] Calling MarkReleasedVATSubmissions
        VATGroupHelperFunctions.MarkReleasedVATSubmissions(VATReportHeader);

        // [THEN] The VAT Group Submission Header should not get modified, as it has an invalid VAT
        // group return no.
        VATGroupSubmissionHeader.Get(SubmissionHeaderID);
        Assert.AreEqual(
          VATGroupReturnNo, VATGroupSubmissionHeader."VAT Group Return No.",
          'The VAT Group Return No. should not have been modified');
    end;

    [Test]
    procedure TestMarkReleasedVATSubmissionsForOneSubmissionHeader()
    var
        VATReportHeader: Record "VAT Report Header";
        VATGroupSubmissionHeader: Record "VAT Group Submission Header";
        MemberID: Guid;
        SubmissionHeaderID: Guid;
        StartDate: Date;
        EndDate: Date;
    begin
        // [SCENARIO 374187] Mark Released VAT Submissions For One Submission Header
        Initialize();

        // [GIVEN] A VATReportSetup entry with VAT Group Role - Member
        // [GIVEN] A VATReportHeader
        StartDate := 0D;
        EndDate := Today();
        LibraryVATGroup.MockVATReportHeaderWithDates(VATReportHeader, StartDate, EndDate);

        // [GIVEN] A VAT Group Approved Member
        MemberID := LibraryVATGroup.MockVATGroupApprovedMember();

        // [GIVEN] A group VAT submission header for the approved member and with the start and end date
        // of the VAT report header
        SubmissionHeaderID := LibraryVATGroup.MockVATGroupSubmissionHeader(StartDate, EndDate, MemberID);

        // [WHEN] Calling MarkReleasedVATSubmissions
        VATGroupHelperFunctions.MarkReleasedVATSubmissions(VATReportHeader);

        // [THEN] The VAT Group Submission Header group return no. should be updated to VatReportHeaderNo
        VATGroupSubmissionHeader.Get(SubmissionHeaderID);
        Assert.AreEqual(
          VATReportHeader."No.", VATGroupSubmissionHeader."VAT Group Return No.",
          'The VAT Group Return No. should have been updated');
    end;

    [Test]
    procedure TestMarkReleasedVATSubmissionsForTwoSubmissionHeadersFromDifferentMembers()
    var
        VATReportHeader: Record "VAT Report Header";
        VATGroupSubmissionHeader: Record "VAT Group Submission Header";
        MemberID: array[2] of Guid;
        SubmissionHeaderID: array[2] of Guid;
        StartDate: Date;
        EndDate: Date;
    begin
        // [SCENARIO 374187] Mark Released VAT Submissions For Two Submission Headers From Different Members
        Initialize();

        // [GIVEN] A VATReportSetup entry with VAT Group Role - Member
        // [GIVEN] A VATReportHeader
        StartDate := 0D;
        EndDate := Today();
        LibraryVATGroup.MockVATReportHeaderWithDates(VATReportHeader, StartDate, EndDate);

        // [GIVEN] Two VAT Group Approved Members
        MemberID[1] := LibraryVATGroup.MockVATGroupApprovedMember();
        MemberID[2] := LibraryVATGroup.MockVATGroupApprovedMember();

        // [GIVEN] Two group VAT submission headers for the approved members and with the start and end date
        // of the VAT report header
        SubmissionHeaderID[1] := LibraryVATGroup.MockVATGroupSubmissionHeader(StartDate, EndDate, MemberID[1]);
        SubmissionHeaderID[2] := LibraryVATGroup.MockVATGroupSubmissionHeader(StartDate, EndDate, MemberID[2]);

        // [WHEN] Calling MarkReleasedVATSubmissions
        VATGroupHelperFunctions.MarkReleasedVATSubmissions(VATReportHeader);

        // [THEN] The VAT Group Submission Header group return no. should be updated to VatReportHeaderNo
        // for both submission headers
        VATGroupSubmissionHeader.Get(SubmissionHeaderID[1]);
        Assert.AreEqual(
          VATReportHeader."No.", VATGroupSubmissionHeader."VAT Group Return No.",
          'The VAT Group Return No. should have been updated for the first submission header');
        VATGroupSubmissionHeader.Get(SubmissionHeaderID[1]);
        Assert.AreEqual(
          VATReportHeader."No.", VATGroupSubmissionHeader."VAT Group Return No.",
          'The VAT Group Return No. should have been updated for the second submission header');
    end;

    [Test]
    procedure TestMarkReleasedVATSubmissionsForTwoSubmissionHeadersFromTheSameMember()
    var
        VATReportHeader: Record "VAT Report Header";
        VATGroupSubmissionHeader: Record "VAT Group Submission Header";
        MemberID: Guid;
        SubmissionHeaderID: array[2] of Guid;
        StartDate: Date;
        EndDate: Date;
    begin
        // [SCENARIO 374187] Mark Released VAT Submissions For Two Submission Headers From The Same Member
        Initialize();

        // [GIVEN] A VATReportSetup entry with VAT Group Role - Member
        // [GIVEN] A VATReportHeader
        StartDate := 0D;
        EndDate := Today();
        LibraryVATGroup.MockVATReportHeaderWithDates(VATReportHeader, StartDate, EndDate);

        // [GIVEN] A VAT Group Approved Member
        MemberID := LibraryVATGroup.MockVATGroupApprovedMember();

        // [GIVEN] Two group VAT submission headers for the same approved member and with the start and end date
        // of the VAT report header, but with different submitted on date times
        SubmissionHeaderID[1] := LibraryVATGroup.MockVATGroupSubmissionHeader(StartDate, EndDate, MemberID);
        SubmissionHeaderID[2] :=
          LibraryVATGroup.MockVATGroupSubmissionHeaderWithSubmittedDate(StartDate, EndDate, MemberID, '', CreateDateTime(Today(), 0T));

        // [WHEN] Calling MarkReleasedVATSubmissions
        VATGroupHelperFunctions.MarkReleasedVATSubmissions(VATReportHeader);

        // [THEN] Only the second VAT Group Submission Header group return no. should be updated to VatReportHeaderNo,
        // as it has a greater Submitted On parameter
        VATGroupSubmissionHeader.Get(SubmissionHeaderID[1]);
        Assert.AreEqual(
          '', VATGroupSubmissionHeader."VAT Group Return No.",
          'The VAT Group Return No. should NOT have been updated for the first submission header');
        VATGroupSubmissionHeader.Get(SubmissionHeaderID[2]);
        Assert.AreEqual(
          VATReportHeader."No.", VATGroupSubmissionHeader."VAT Group Return No.",
          'The VAT Group Return No. should have been updated for the second submission header');
    end;

    [Test]
    procedure TestMarkReopenedVATSubmissions()
    var
        VATReportHeader: Record "VAT Report Header";
        VATGroupSubmissionHeader: Record "VAT Group Submission Header";
        ValidSubmissionHeader1: Guid;
        ValidSubmissionHeader2: Guid;
        InvalidSubmissionHeader: Guid;
    begin
        // [SCENARIO 374187] Mark Reopened VAT Submissions
        Initialize();

        // [GIVEN] A VATReportHeader
        LibraryVATGroup.MockDummyVATReportHeader(VATReportHeader);

        // [GIVEN] Three VAT Group Submission Headers - two corresponding to the VAT report header
        // defined above and one not
        ValidSubmissionHeader1 :=
          LibraryVATGroup.MockVATGroupSubmissionHeaderWithGroupReturnNo(0D, Today(), CreateGuid(), VATReportHeader."No.");
        ValidSubmissionHeader2 :=
          LibraryVATGroup.MockVATGroupSubmissionHeaderWithGroupReturnNo(0D, Today(), CreateGuid(), VATReportHeader."No.");
        InvalidSubmissionHeader := LibraryVATGroup.MockVATGroupSubmissionHeaderWithGroupReturnNo(0D, Today(), CreateGuid(), 'invalid code');

        // [WHEN] Calling MarkReopenedVATSubmissions
        VATGroupHelperFunctions.MarkReopenedVATSubmissions(VATReportHeader);

        // [THEN] The valid submission headers' VAT Group Return No. should be updated to ''
        VATGroupSubmissionHeader.Get(ValidSubmissionHeader1);
        Assert.AreEqual(
          '', VATGroupSubmissionHeader."VAT Group Return No.",
          'The first submission header should have been reopened');
        VATGroupSubmissionHeader.Get(ValidSubmissionHeader2);
        Assert.AreEqual(
          '', VATGroupSubmissionHeader."VAT Group Return No.",
          'The second submission header should have been reopened');

        // [THEN] The invalid submission header's VAT Group Return No. should NOT be updated to ''
        VATGroupSubmissionHeader.Get(InvalidSubmissionHeader);
        Assert.AreNotEqual(
          '', VATGroupSubmissionHeader."VAT Group Return No.",
          'The third submission header should NOT have been reopened');
    end;

    [Test]
    procedure TestPrepareVATCalculationForNoApprovedMembers()
    var
        VATReportHeader: Record "VAT Report Header";
        VATStatementReportLine: Record "VAT Statement Report Line";
        VATGroupMemberCalculation: TestPage "VAT Group Member Calculation";
    begin
        // [SCENARIO 374187] Prepare VAT Calculation For No Approved Members
        Initialize();

        // [GIVEN] There are no VAT Group Approved Members
        // [WHEN] Invoking PrepareVATCalculation
        VATGroupMemberCalculation.Trap();
        VATGroupHelperFunctions.PrepareVATCalculation(VATReportHeader, VATStatementReportLine);

        // [THEN] The VAT Group Member Calculation page is empty
        Assert.IsFalse(VATGroupMemberCalculation.First(), 'The page should be empty');
    end;

    [Test]
    procedure TestPrepareVATCalculationForReleasedStatusAndNoValidSubmissions()
    var
        VATReportHeader: Record "VAT Report Header";
        VATStatementReportLine: Record "VAT Statement Report Line";
        VATGroupMemberCalculation: TestPage "VAT Group Member Calculation";
        MemberId: Guid;
        StartDate: Date;
        EndDate: Date;
    begin
        // [SCENARIO 374187] Prepare VAT Calculation For Released Status And No Valid Submissions
        Initialize();

        // [GIVEN] One VAT Group Approved Member
        MemberId := LibraryVATGroup.MockVATGroupApprovedMember();

        // [GIVEN] A VAT Report Header with Released status
        StartDate := 0D;
        EndDate := Today();
        LibraryVATGroup.MockVATReportHeaderWithState(VATReportHeader, StartDate, EndDate, VATReportHeader.Status::Released);

        // [GIVEN] No submission headers for the specified start date
        LibraryVATGroup.MockVATGroupSubmissionHeader(DMY2Date(1, 1, 2019), DMY2Date(2, 2, 2019), MemberId);

        // [WHEN] Invoking PrepareVATCalculation
        VATGroupMemberCalculation.Trap();
        VATGroupHelperFunctions.PrepareVATCalculation(VATReportHeader, VATStatementReportLine);

        // [THEN] The VAT Group Member Calculation page is empty
        Assert.IsFalse(VATGroupMemberCalculation.First(), 'The page should be empty');
    end;

    [Test]
    procedure TestPrepareVATCalculationForOpenStatusAndNoValidSubmissions()
    var
        VATReportHeader: Record "VAT Report Header";
        VATStatementReportLine: Record "VAT Statement Report Line";
        VATGroupMemberCalculation: TestPage "VAT Group Member Calculation";
        MemberId: Guid;
        StartDate: Date;
        EndDate: Date;
    begin
        // [SCENARIO 374187] Prepare VAT Calculation For Open Status And No Valid Submissions
        Initialize();

        // [GIVEN] One VAT Group Approved Member
        MemberId := LibraryVATGroup.MockVATGroupApprovedMember();

        // [GIVEN] A VAT Report Header with Open status
        StartDate := 0D;
        EndDate := Today();
        LibraryVATGroup.MockVATReportHeaderWithState(VATReportHeader, StartDate, EndDate, VATReportHeader.Status::Open);

        // [GIVEN] No submission headers for the specified start date
        LibraryVATGroup.MockVATGroupSubmissionHeader(DMY2Date(1, 1, 2019), DMY2Date(2, 2, 2019), MemberId);

        // [WHEN] Invoking PrepareVATCalculation
        VATGroupMemberCalculation.Trap();
        VATGroupHelperFunctions.PrepareVATCalculation(VATReportHeader, VATStatementReportLine);

        // [THEN] The VAT Group Member Calculation page is empty
        Assert.IsFalse(VATGroupMemberCalculation.First(), 'The page should be empty');
    end;

    [Test]
    procedure TestPrepareVATCalculationForReleasedStatusAndNoValidSubmissionLines()
    var
        VATReportHeader: Record "VAT Report Header";
        VATStatementReportLine: Record "VAT Statement Report Line";
        VATGroupMemberCalculation: TestPage "VAT Group Member Calculation";
        MemberID: array[2] of Guid;
        StartDate: Date;
        EndDate: Date;
    begin
        // [SCENARIO 374187] Prepare VAT Calculation For Released Status And No Valid Submission Lines
        Initialize();

        // [GIVEN] Two VAT Group Approved Member
        MemberID[1] := LibraryVATGroup.MockVATGroupApprovedMember();
        MemberID[2] := LibraryVATGroup.MockVATGroupApprovedMember();

        // [GIVEN] A VAT Report Header with Released status
        StartDate := 0D;
        EndDate := Today();
        LibraryVATGroup.MockVATReportHeaderWithState(VATReportHeader, StartDate, EndDate, VATReportHeader.Status::Released);

        // [GIVEN] Two submission headers matching the report header and one that doesn't
        LibraryVATGroup.MockVATGroupSubmissionHeaderWithGroupReturnNo(StartDate, EndDate, MemberID[1], VATReportHeader."No.");
        LibraryVATGroup.MockVATGroupSubmissionHeaderWithGroupReturnNo(StartDate, EndDate, MemberID[2], VATReportHeader."No.");
        LibraryVATGroup.MockVATGroupSubmissionHeaderWithGroupReturnNo(DMY2Date(1, 1, 2019), EndDate, MemberID[2], VATReportHeader."No.");

        // [WHEN] Invoking PrepareVATCalculation
        VATGroupMemberCalculation.Trap();
        VATGroupHelperFunctions.PrepareVATCalculation(VATReportHeader, VATStatementReportLine);

        // [THEN] The VAT Group Member Calculation page is empty, since the headers do not have
        // any corresponding lines
        Assert.IsFalse(VATGroupMemberCalculation.First(), 'The page should be empty');
    end;

    [Test]
    procedure TestPrepareVATCalculationForOpenStatusAndNoValidSubmissionLines()
    var
        VATReportHeader: Record "VAT Report Header";
        VATStatementReportLine: Record "VAT Statement Report Line";
        VATGroupMemberCalculation: TestPage "VAT Group Member Calculation";
        MemberID: array[2] of Guid;
        StartDate: Date;
        EndDate: Date;
    begin
        // [SCENARIO 374187] Prepare VAT Calculation For Open Status And No Valid Submission Lines
        Initialize();

        // [GIVEN] Two VAT Group Approved Member
        MemberID[1] := LibraryVATGroup.MockVATGroupApprovedMember();
        MemberID[2] := LibraryVATGroup.MockVATGroupApprovedMember();

        // [GIVEN] A VAT Report Header with Open status
        StartDate := 0D;
        EndDate := Today();
        LibraryVATGroup.MockVATReportHeaderWithState(VATReportHeader, StartDate, EndDate, VATReportHeader.Status::Open);

        // [GIVEN] Two submission headers matching the report header and one that doesn't
        LibraryVATGroup.MockVATGroupSubmissionHeaderWithGroupReturnNo(StartDate, EndDate, MemberID[1], VATReportHeader."No.");
        LibraryVATGroup.MockVATGroupSubmissionHeaderWithGroupReturnNo(StartDate, EndDate, MemberID[2], VATReportHeader."No.");
        LibraryVATGroup.MockVATGroupSubmissionHeaderWithGroupReturnNo(DMY2Date(1, 1, 2019), EndDate, MemberID[2], VATReportHeader."No.");

        // [WHEN] Invoking PrepareVATCalculation
        VATGroupMemberCalculation.Trap();
        VATGroupHelperFunctions.PrepareVATCalculation(VATReportHeader, VATStatementReportLine);

        // [THEN] The VAT Group Member Calculation page is empty, since the headers do not have
        // any corresponding lines
        Assert.IsFalse(VATGroupMemberCalculation.First(), 'The page should be empty');
    end;

    [Test]
    procedure TestPrepareVATCalculationForReleasedStatusAndValidSubmissionLines()
    var
        VATReportHeader: Record "VAT Report Header";
        VATStatementReportLine: Record "VAT Statement Report Line";
        VATGroupSubmissionHeader: array[3] of Record "VAT Group Submission Header";
        VATGroupMemberCalculation: TestPage "VAT Group Member Calculation";
        MemberId: array[2] of Guid;
        StartDate: Date;
        EndDate: Date;
        Amount: array[3] of Decimal;
        BoxNo: array[3] of Text[30];
        SubmittedOn: array[2] of DateTime;
        i: Integer;
    begin
        // [SCENARIO 374187] Prepare VAT Calculation For Released Status And Valid Submission Lines
        Initialize();

        // [GIVEN] Two VAT Group Approved Member
        MemberId[1] := LibraryVATGroup.MockVATGroupApprovedMemberWithName('Member 1');
        MemberId[2] := LibraryVATGroup.MockVATGroupApprovedMemberWithName('Member 2');

        // [GIVEN] A VAT Report Header with Released status
        StartDate := 0D;
        EndDate := Today();
        LibraryVATGroup.MockVATReportHeaderWithState(VATReportHeader, StartDate, EndDate, VATReportHeader.Status::Released);

        // [GIVEN] Two submission headers matching the report header and one that doesn't
        SubmittedOn[1] := CreateDateTime(DMY2Date(12, 12, 2019), 0T);
        SubmittedOn[2] := CreateDateTime(0D, 0T);
        VATGroupSubmissionHeader[1].Get(
          LibraryVATGroup.MockVATGroupSubmissionHeaderWithSubmittedDate(
            StartDate, EndDate, MemberId[1], VATReportHeader."No.", SubmittedOn[1]));
        VATGroupSubmissionHeader[2].Get(
          LibraryVATGroup.MockVATGroupSubmissionHeaderWithSubmittedDate(
            StartDate, EndDate, MemberId[2], VATReportHeader."No.", SubmittedOn[2]));
        VATGroupSubmissionHeader[3].Get(
          LibraryVATGroup.MockVATGroupSubmissionHeaderWithSubmittedDate(
            DMY2Date(1, 1, 2019), EndDate, MemberId[2], VATReportHeader."No.", SubmittedOn[1]));

        // [GIVEN] Submission lines for all 3 submission headers
        Amount[1] := 1.25;
        Amount[2] := 25.12;
        Amount[3] := 13;
        BoxNo[1] := 'Text1';
        BoxNo[2] := 'Text2';
        BoxNo[3] := 'Text3';
        for i := 1 to ArrayLen(VATGroupSubmissionHeader) do
            LibraryVATGroup.MockVATGroupSubmissionLine(VATGroupSubmissionHeader[i], Amount[i], BoxNo[i], VATStatementReportLine."Row No.");

        // [WHEN] Invoking PrepareVATCalculation
        VATGroupMemberCalculation.Trap();
        VATGroupHelperFunctions.PrepareVATCalculation(VATReportHeader, VATStatementReportLine);

        // [THEN] The VAT Group Member Calculation page should not be empty
        Assert.IsTrue(VATGroupMemberCalculation.First(), 'The page should not be empty');

        // [THEN] There are 2 rows on the page, corresponding to the valid statement headers
        if VATGroupMemberCalculation.Amount.Value() = Format(Amount[1]) then begin
            VerifyVATGroupCalculation(
              VATGroupMemberCalculation, Amount[1], BoxNo[1], 'Member 1', VATGroupSubmissionHeader[1]."No.", SubmittedOn[1]);
            Assert.IsTrue(VATGroupMemberCalculation.Next(), 'The page should have a second record');
            VerifyVATGroupCalculation(
                VATGroupMemberCalculation, Amount[2], BoxNo[2], 'Member 2', VATGroupSubmissionHeader[2]."No.", SubmittedOn[2]);
        end else begin
            VerifyVATGroupCalculation(
                VATGroupMemberCalculation, Amount[2], BoxNo[2], 'Member 2', VATGroupSubmissionHeader[2]."No.", SubmittedOn[2]);
            Assert.IsTrue(VATGroupMemberCalculation.Next(), 'The page should have a second record');
            VerifyVATGroupCalculation(
                VATGroupMemberCalculation, Amount[1], BoxNo[1], 'Member 1', VATGroupSubmissionHeader[1]."No.", SubmittedOn[1]);
        end;

        // [THEN] There is no row on the page corresponding to the invalid statement header
        Assert.IsFalse(VATGroupMemberCalculation.Next(), 'There should not be a third row on the page');
    end;

    [Test]
    procedure TestPrepareVATCalculationForOpenStatusAndValidSubmissionLines()
    var
        VATReportHeader: Record "VAT Report Header";
        VATStatementReportLine: Record "VAT Statement Report Line";
        VATGroupSubmissionHeader: array[3] of Record "VAT Group Submission Header";
        VATGroupMemberCalculation: TestPage "VAT Group Member Calculation";
        MemberId: array[2] of Guid;
        StartDate: Date;
        EndDate: Date;
        Amount: array[3] of Decimal;
        BoxNo: array[3] of Text[30];
        SubmittedOn: array[2] of DateTime;
        i: Integer;
    begin
        // [SCENARIO 374187] Prepare VAT Calculation For Open Status And Valid Submission Lines
        Initialize();

        // [GIVEN] Two VAT Group Approved Member
        MemberId[1] := LibraryVATGroup.MockVATGroupApprovedMemberWithName('Member 1');
        MemberId[2] := LibraryVATGroup.MockVATGroupApprovedMemberWithName('Member 2');

        // [GIVEN] A VAT Report Header with Open status
        StartDate := 0D;
        EndDate := Today();
        LibraryVATGroup.MockVATReportHeaderWithState(VATReportHeader, StartDate, EndDate, VATReportHeader.Status::Open);

        // [GIVEN] Two submission headers matching the report header and one that doesn't
        SubmittedOn[1] := CreateDateTime(DMY2Date(12, 12, 2019), 0T);
        SubmittedOn[2] := CreateDateTime(0D, 0T);
        VATGroupSubmissionHeader[1].Get(
          LibraryVATGroup.MockVATGroupSubmissionHeaderWithSubmittedDate(StartDate, EndDate, MemberId[1], '', SubmittedOn[1]));
        VATGroupSubmissionHeader[2].Get(
          LibraryVATGroup.MockVATGroupSubmissionHeaderWithSubmittedDate(StartDate, EndDate, MemberId[2], '', SubmittedOn[2]));
        VATGroupSubmissionHeader[3].Get(
          LibraryVATGroup.MockVATGroupSubmissionHeaderWithSubmittedDate(DMY2Date(1, 1, 2019), EndDate, MemberId[2], '', SubmittedOn[1]));

        // [GIVEN] Submission lines for all 3 submission headers
        Amount[1] := 1.25;
        Amount[2] := 25.12;
        Amount[3] := 13;
        BoxNo[1] := 'Text1';
        BoxNo[2] := 'Text2';
        BoxNo[3] := 'Text3';
        for i := 1 to ArrayLen(VATGroupSubmissionHeader) do
            LibraryVATGroup.MockVATGroupSubmissionLine(VATGroupSubmissionHeader[i], Amount[i], BoxNo[i], VATStatementReportLine."Row No.");

        // [WHEN] Invoking PrepareVATCalculation
        VATGroupMemberCalculation.Trap();
        VATGroupHelperFunctions.PrepareVATCalculation(VATReportHeader, VATStatementReportLine);

        // [THEN] The VAT Group Member Calculation page should not be empty
        Assert.IsTrue(VATGroupMemberCalculation.First(), 'The page should not be empty');

        // [THEN] There are 2 rows on the page, corresponding to the valid statement headers
        if VATGroupMemberCalculation.Amount.Value() = Format(Amount[1]) then begin
            VerifyVATGroupCalculation(
                VATGroupMemberCalculation, Amount[1], BoxNo[1], 'Member 1', VATGroupSubmissionHeader[1]."No.", SubmittedOn[1]);
            Assert.IsTrue(VATGroupMemberCalculation.Next(), 'The page should have a second record');
            VerifyVATGroupCalculation(
                VATGroupMemberCalculation, Amount[2], BoxNo[2], 'Member 2', VATGroupSubmissionHeader[2]."No.", SubmittedOn[2]);
        end else begin
            VerifyVATGroupCalculation(
                VATGroupMemberCalculation, Amount[2], BoxNo[2], 'Member 2', VATGroupSubmissionHeader[2]."No.", SubmittedOn[2]);
            Assert.IsTrue(VATGroupMemberCalculation.Next(), 'The page should have a second record');
            VerifyVATGroupCalculation(
                VATGroupMemberCalculation, Amount[1], BoxNo[1], 'Member 1', VATGroupSubmissionHeader[1]."No.", SubmittedOn[1]);
        end;

        // [THEN] There is no row on the page corresponding to the invalid statement header
        Assert.IsFalse(VATGroupMemberCalculation.Next(), 'There should not be a third row on the page');
    end;

    [Test]
    procedure DefaultRepresentativeBCVersion()
    var
        DummyVATReportSetup: Record 743;
    begin
        // [SCENARIO 374187] The default representative NAV\BC version = "Business Central"
        Assert.AreEqual(
          VATGroupHelperFunctions.GetVATGroupDefaultBCVersion(),
          DummyVATReportSetup."VAT Group BC Version"::BC, 'GetVATGroupDefaultBCVersion');
    end;

    local procedure Initialize()
    begin
        LibraryVATGroup.EnableDefaultVATMemberSetup();
        LibraryVATGroup.ClearApprovedMembers();
    end;

    local procedure VerifyVATGroupCalculation(VATGroupMemberCalculation: TestPage "VAT Group Member Calculation"; Amount: Decimal; BoxNo: Text[30]; GroupMemberName: Text[250]; VATGroupSubmissionNo: Code[20]; SubmittedOn: DateTime)
    begin
        Assert.AreEqual(Format(Amount), VATGroupMemberCalculation.Amount.Value(), 'The amount is incorrect');
        Assert.AreEqual(Format(BoxNo), VATGroupMemberCalculation.BoxNo.Value(), 'The Box No. is incorrect');
        Assert.AreEqual(Format(GroupMemberName), VATGroupMemberCalculation."Group Member Name".Value(),
          'The Group Member Name is incorrect');
        Assert.AreEqual(Format(VATGroupSubmissionNo), VATGroupMemberCalculation."VAT Group Submission No.".Value(),
          'The VAT Group Submission No. is incorrect');
        Assert.AreEqual(SubmittedOn, VATGroupMemberCalculation.SubmittedOn.AsDateTime(),
          'The Submitted On field is incorrect');
    end;
}
