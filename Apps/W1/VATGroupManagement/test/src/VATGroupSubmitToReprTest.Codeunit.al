codeunit 139740 "VAT Group Submit To Repr. Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryVATGroup: Codeunit "Library - VAT Group";
        NoVATReportSetupErr: Label 'The VAT report setup was not found. You can create one on the VAT Report Setup page.';
        NotFoundErr: Label 'Not Found: cannot locate the requested resource.';
        InvalidSyntaxErr: Label 'Bad Request: the server could not understand the request due to invalid syntax.';
        HasErrorsMsg: Label 'One or more errors were found. You must resolve all the errors before you can proceed.';

    [Test]
    procedure TestVATReportSetupMissing()
    begin
        // [SCENARIO 374187] VAT Report Setup Missing
        Initialize();

        // [WHEN] The "VAT Report Setup" table is empty
        LibraryVATGroup.DeleteVATReportSetup();

        // [THEN] A error is expected
        asserterror Codeunit.Run(Codeunit::"VAT Group Submit To Represent.");
        Assert.ExpectedError(NoVATReportSetupErr);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure TestFailureInSend()
    var
        VATReportHeader: Record "VAT Report Header";
    begin
        // [SCENARIO 374187] Failure In Send
        Initialize();

        // [WHEN] The "VAT Report Setup" table is configured but the API URL is wrong
        LibraryVATGroup.EnableDefaultVATMemberSetup();
        LibraryVATGroup.UpdateRepresentativeCompanyName(LibraryUtility.GenerateGUID());

        // [THEN] A error is expected
        InitVATReportHeader(VATReportHeader);
        Codeunit.Run(Codeunit::"VAT Group Submit To Represent.", VATReportHeader);

        VerifyErrorMessage(VATReportHeader, NotFoundErr);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure TestFailureInSendMissingApprovedMember()
    var
        VATReportHeader: Record "VAT Report Header";
    begin
        // [SCENARIO 374187] Failure In Send Missing Approved Member
        Initialize();

        // [GIVEN] The "VAT Report Setup" table is configured but the API URL is wrong
        LibraryVATGroup.EnableDefaultVATMemberSetup();

        // [GIVEN] The "VAT Report Header" table is configured
        InitVATReportHeader(VATReportHeader);

        // [GIVEN] The Status of a VAT Report is Open (Default Status)
        Assert.AreEqual(VATReportHeader.Status, VATReportHeader.Status::Open, 'Status should be Open');

        // [WHEN] The submission is sent
        Codeunit.Run(Codeunit::"VAT Group Submit To Represent.", VATReportHeader);

        VerifyErrorMessage(VATReportHeader, InvalidSyntaxErr);
    end;

    [Test]
    procedure TestSuccessfulSend()
    var
        VATReportHeader: Record "VAT Report Header";
        VATGroupSubmissionHeader: Record "VAT Group Submission Header";
        VATGroupSubmissionLine: Record "VAT Group Submission Line";
    begin
        // [SCENARIO 374187] Successful Send
        Initialize();

        // [GIVEN] The "VAT Report Setup" table is configured
        LibraryVATGroup.EnableDefaultVATMemberSetup();

        // [GIVEN] The "VAT Group Approved Member" contains the member ID of the current submission.
        LibraryVATGroup.UpdateMemberId(LibraryVATGroup.MockVATGroupApprovedMember());

        // [GIVEN] The "VAT Report Header" table is configured
        InitVATReportHeader(VATReportHeader);

        // [GIVEN] The Status of a VAT Report is Open (Default Status)
        Assert.AreEqual(VATReportHeader.Status, VATReportHeader.Status::Open, 'Status should be Open');

        // [WHEN] The submission is sent
        Commit();
        Codeunit.Run(Codeunit::"VAT Group Submit To Represent.", VATReportHeader);

        // [THEN] The Status should be Submitted
        Assert.AreEqual(VATReportHeader.Status, VATReportHeader.Status::Submitted, 'Status should be Submitted');

        // [THEN] There should be submissions in the VAT Group Submission table and lines.
        Assert.RecordIsNotEmpty(VATGroupSubmissionHeader);

        VATGroupSubmissionLine.SetFilter("VAT Group Submission No.", VATReportHeader."No.");
        Assert.RecordIsNotEmpty(VATGroupSubmissionLine);
    end;

    local procedure Initialize()
    begin
        LibraryVariableStorage.Clear();
    end;

    local procedure InitVATReportHeader(var VATReportHeader: Record "VAT Report Header")
    begin
        LibraryVATGroup.MockVATReportHeaderWithDates(VATReportHeader, Today(), Today());
        InitVATReportLines(VATReportHeader);
        InitVATReportLines(VATReportHeader);
    end;

    local procedure InitVATReportLines(VATReportHeader: Record "VAT Report Header")
    var
        VATStatementReportLine: Record "VAT Statement Report Line";
    begin
        LibraryVATGroup.MockVATStatementReportLineWithBoxNo(
          VATStatementReportLine, VATReportHeader,
          LibraryRandom.RandDecInRange(0, 1000000, 2), '00' + Format(LibraryRandom.RandInt(9)), Format(LibraryRandom.RandInt(1000)));
    end;

    local procedure VerifyErrorMessage(var VATReportHeader: Record "VAT Report Header"; ExpectedError: Text)
    var
        ErrorMessage: Record "Error Message";
    begin
        ErrorMessage.SETRANGE("Context Record ID", VATReportHeader.RecordId());
        ErrorMessage.FindFirst();
        Assert.ExpectedMessage(ExpectedError, ErrorMessage.Description);

        Assert.ExpectedMessage(HasErrorsMsg, LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
        LibraryVariableStorage.Enqueue(Message);
    end;
}