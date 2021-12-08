codeunit 139521 "VAT Group Representative Logic"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        LibraryVATGroup: Codeunit "Library - VAT Group";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        IsInitialized: Boolean;
        GLAccountCategory: Enum "G/L Account Category";
        NotAllMembersSubmittedErr: Label 'One or more VAT group members have not submitted their VAT return for this period. Wait until all members have submitted before you continue.\\You can see the current submissions on the VAT Group Submission page.';
        SuggestLinesBeforeErr: Label 'You must run the Suggest Lines action before you include returns for the VAT group.';
        GroupAmtDoesntMatchTxt: Label 'Group amount does not match the VAT submission line amount';
        ReprAmtDoesntMatchTxt: Label 'Representative amount does not match the VAT return line amount';
        ControlShouldBeVisibleTxt: Label 'Control should be visible';
        ControlShouldNotBeVisibleTxt: Label 'Control should not be visible';
        VATGroupSettlementQst: Label 'Do you want to post the VAT settlement for the group members';
        VATGroupSettlementErr: Label 'Could not post the VAT group settlement because the following error occurred. %1', Comment = '%1 is the error itself';
        GenJournalTemplateDoesNotExistErr: Label 'No. Series must have a value in Gen. Journal Template: Name=%1. It cannot be zero or empty.', Comment = '%1 - gen. journal template name';
        NoDueBoxNoErr: Label 'The VAT Due Box No. is missing in VAT Report Setup.';
        NoVATSettlementAccountErr: Label 'The VAT Settlement Account is missing in VAT Report Setup.';
        NoGroupSettlementAccountErr: Label 'The Group Settlement Account is missing in VAT Report Setup.';
        NoGroupSettlementGenJnlTemplateErr: Label 'The Group Settlement General Journal Template is missing in VAT Report Setup.';
        VATGroupSettlementMsg: Label 'The VAT group settlement was posted successfully.';
        GroupMemberSubmissionTxt: Label '%1 of %2 submitted', Comment = '%1 = number, %2 = number ex. 2 of 4 submitted';
        VATSettlementForTxt: Label 'VAT Settlement for %1. %2 - %3', Comment = '%1 is the name of a VAT group member. %2 and %3 are dates';
        VATDueFromTxt: Label 'VAT Due from %1. %2 - %3', Comment = '%1 is the name of a VAT group member. %2 and %3 are dates';

    [Test]
    procedure TestVATPeriodsForRepresentative()
    var
        VATGroupApprovedMember: Record "VAT Group Approved Member";
        VATReturnPeriodList: TestPage "VAT Return Period List";
        MemberId: Guid;
        CurrentMemberCount: Integer;
        ExpectedText: Text;
    begin
        // [FEATURE] [UI]
        // [SCENARIO 374187] VAT Periods For Representative
        Initialize();

        // [GIVEN] Current Role is Group Representative
        // [GIVEN] We have at least 1 approved member
        MemberId := LibraryVATGroup.MockVATGroupApprovedMember();

        // [GIVEN] There is a VAT Periods set up
        LibraryVATGroup.MockVATReturnPeriod(DMY2Date(1, 1, 2020), DMY2Date(31, 1, 2020));

        // [GIVEN] There are VAT submissions for said period
        LibraryVATGroup.MockVATGroupSubmissionHeaderWithSubmittedDate(
          DMY2Date(1, 1, 2020), DMY2Date(31, 1, 2020), MemberId, '', CreateDateTime(DMY2Date(30, 1, 2020), Time()));

        // [WHEN] VAT Periods page is opened
        VATReturnPeriodList.OpenView();

        // [THEN]
        Assert.IsTrue(VATReturnPeriodList."Group Member Submissions".Visible(), ControlShouldBeVisibleTxt);

        // [THEN] Group member submissions column is shown with the correct number
        CurrentMemberCount := VATGroupApprovedMember.Count();
        ExpectedText := StrSubstNo(GroupMemberSubmissionTxt, 1, CurrentMemberCount);
        Assert.AreEqual(ExpectedText, VATReturnPeriodList."Group Member Submissions".Value(), 'wrong member submission count');
    end;

    [Test]
    procedure TestVATReturnGroupFlag()
    var
        VATReportHeader: Record "VAT Report Header";
        VATReportList: TestPage "VAT Report List";
        VATReport: TestPage "VAT Report";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 374187] VAT Return Group Flag
        Initialize();

        // [GIVEN] Current Role is Group Representative
        // [GIVEN] We have at least a VAT Return
        LibraryVATGroup.MockVATReportHeaderWithDates(VATReportHeader, DMY2Date(1, 1, 2020), DMY2Date(31, 1, 2020));

        // [WHEN] We navigate to the list of var returns
        VATReportList.OpenView();

        // [THEN] We can see the VAT Group Flag
        Assert.IsTrue(VATReportList."VAT Group Return".Visible(), ControlShouldBeVisibleTxt);

        // [WHEN] We open an individual VAT Return
        LibraryVATGroup.OpenVATReturnCard(VATReport, VATReportHeader);

        // [THEN] We can see the VAT Group Flag
        Assert.IsTrue(VATReport."VAT Group Return".Visible(), ControlShouldBeVisibleTxt);
        Assert.IsTrue(VATReport."Include VAT Group".Visible(), ControlShouldBeVisibleTxt);
    end;

    [Test]
    procedure TestIncludeVATGroupMembersNotSubmitted()
    var
        VATReportHeader: Record "VAT Report Header";
        VATReport: TestPage "VAT Report";
        MemberId: Guid;
    begin
        // [FEATURE] [UI]
        // [SCENARIO 374187] Include VAT Group Members Not Submitted
        Initialize();

        // [GIVEN] Current Role is Group Representative
        // [GIVEN] We have at least 1 approved member
        MemberId := LibraryVATGroup.MockVATGroupApprovedMember();

        // [GIVEN] We have at least one VAT Return
        LibraryVATGroup.MockVATReportHeaderWithDates(VATReportHeader, DMY2Date(1, 1, 2020), DMY2Date(31, 1, 2020));

        // [GIVEN] We have no member VAT Group submissions for the same period as the VAT return

        // [WHEN] We Navigate to the VAT Return Page and click the Inluce VAT Group Action
        LibraryVATGroup.OpenVATReturnCard(VATReport, VATReportHeader);
        asserterror VATReport."Include VAT Group".Invoke();

        // [THEN] An error will be shown
        Assert.ExpectedError(NotAllMembersSubmittedErr);
    end;

    [Test]
    procedure TestIncludeVATGroupNoSuggestLine()
    var
        VATReportHeader: Record "VAT Report Header";
        VATReport: TestPage "VAT Report";
        MemberId: Guid;
    begin
        // [FEATURE] [UI]
        // [SCENARIO 374187] Include VAT Group No Suggest Line
        Initialize();

        // [GIVEN] Current Role is Group Representative
        // [GIVEN] We have at least 1 approved member
        MemberId := LibraryVATGroup.MockVATGroupApprovedMember();

        // [GIVEN] We have at least one VAT Return
        LibraryVATGroup.MockVATReportHeaderWithDates(VATReportHeader, DMY2Date(1, 1, 2020), DMY2Date(31, 1, 2020));

        // [GIVEN] There are VAT submissions for said period
        LibraryVATGroup.MockVATGroupSubmissionHeaderWithSubmittedDate(
          DMY2Date(1, 1, 2020), DMY2Date(31, 1, 2020), MemberId, '', CreateDateTime(DMY2Date(30, 1, 2020), Time()));

        // [WHEN] We Navigate to the VAT Return Page and click the Inluce VAT Group Action
        LibraryVATGroup.OpenVATReturnCard(VATReport, VATReportHeader);

        // [THEN] An error will be shown
        asserterror VATReport."Include VAT Group".Invoke();
        Assert.ExpectedError(SuggestLinesBeforeErr);
    end;

    [Test]
    procedure TestIncludeVATGroupAmounts()
    var
        VATReportHeader: Record "VAT Report Header";
        VATGroupHelperFunctions: Codeunit "VAT Group Helper Functions";
        VATReport: TestPage "VAT Report";
        VATGroupMemberCalculation: TestPage "VAT Group Member Calculation";
        MemberId: Guid;
        VATGroupSubmissionHeaderNo: Code[20];
    begin
        // [FEATURE] [UI]
        // [SCENARIO 374187] Include VAT Group Amounts
        Initialize();

        // [GIVEN] Current Role is Group Representative
        // [GIVEN] We have at least 1 approved member
        MemberId := LibraryVATGroup.MockVATGroupApprovedMember();

        // [GIVEN] We have at least one VAT Return
        // [GIVEN] There are VAT submissions for said period
        CreateVATReturnWith3Lines(VATReportHeader);
        VATGroupSubmissionHeaderNo := CreateVATSubmissionWith3Lines(MemberId, 100, 200, 300);

        // [WHEN] We Navigate to the VAT Return Page and click the Include VAT Group Action
        VATGroupHelperFunctions.SetOriginalRepresentativeAmount(VATReportHeader);
        LibraryVATGroup.OpenVATReturnCard(VATReport, VATReportHeader);
        Assert.IsFalse(VATReport.VATReportLines."Group Amount".Visible(), ControlShouldNotBeVisibleTxt);
        Assert.IsFalse(VATReport.VATReportLines."Representative Amount".Visible(), ControlShouldNotBeVisibleTxt);
        VATReport."Include VAT Group".Invoke();

        // [THEN] New Columns Appear
        Assert.IsTrue(VATReport.VATReportLines."Group Amount".Visible(), ControlShouldBeVisibleTxt);
        Assert.IsTrue(VATReport.VATReportLines."Representative Amount".Visible(), ControlShouldBeVisibleTxt);

        // [THEN] the values are correctly compounded
        VATReport.VATReportLines.First();
        Assert.AreEqual(100, VATReport.VATReportLines."Group Amount".AsDecimal(), GroupAmtDoesntMatchTxt);
        Assert.AreEqual(
          100, VATReport.VATReportLines."Representative Amount".AsDecimal(), ReprAmtDoesntMatchTxt);
        Assert.AreEqual(200, VATReport.VATReportLines.Amount.AsDecimal(), GroupAmtDoesntMatchTxt);
        VATReport.VATReportLines.Next();

        Assert.AreEqual(200, VATReport.VATReportLines."Group Amount".AsDecimal(), GroupAmtDoesntMatchTxt);
        Assert.AreEqual(
          200, VATReport.VATReportLines."Representative Amount".AsDecimal(), ReprAmtDoesntMatchTxt);
        Assert.AreEqual(400, VATReport.VATReportLines.Amount.AsDecimal(), GroupAmtDoesntMatchTxt);
        VATReport.VATReportLines.Next();

        Assert.AreEqual(300, VATReport.VATReportLines."Group Amount".AsDecimal(), GroupAmtDoesntMatchTxt);
        Assert.AreEqual(
          300, VATReport.VATReportLines."Representative Amount".AsDecimal(), ReprAmtDoesntMatchTxt);
        Assert.AreEqual(600, VATReport.VATReportLines.Amount.AsDecimal(), GroupAmtDoesntMatchTxt);

        // [THEN] clicking on the group amount will open the VAT calculation page with proper values
        VATGroupMemberCalculation.Trap();
        VATReport.VATReportLines."Group Amount".Drilldown();
        VATGroupMemberCalculation.First();
        Assert.AreEqual(300, VATGroupMemberCalculation.Amount.AsDecimal(), 'the amount is wrong in the calculation');
        Assert.AreEqual('003', VATGroupMemberCalculation.BoxNo.Value(), 'the boxno is wrong in the calculation');
        Assert.AreEqual(
          VATGroupSubmissionHeaderNo, VATGroupMemberCalculation."VAT Group Submission No.".Value(),
          'the var group sub no. is wrong in the calculation');
        Assert.AreEqual(300, VATGroupMemberCalculation.Total.AsDecimal(), 'the total amount is wrong in the calculation');
    end;

    [Test]
    [HandlerFunctions('HandleVATSettlementReport')]
    procedure TestVATGroupSettlementAlreadyDone()
    var
        VATReportHeader: Record "VAT Report Header";
        VATReport: TestPage "VAT Report";
        MemberId: Guid;
    begin
        // [FEATURE] [UI]
        // [SCENARIO 374187] VAT Group Settlement Already Done
        Initialize();

        // [GIVEN] Current Role is Group Representative
        // [GIVEN] We have at least 1 approved member
        MemberId := LibraryVATGroup.MockVATGroupApprovedMember();

        // [GIVEN] We have at least one VAT Return
        // [GIVEN] There are VAT submissions for said period
        CreateVATReturnWith3Lines(VATReportHeader);
        CreateVATSubmissionWith3Lines(MemberId, 100, 200, 300);

        // [GIVEN] We have Included the VAT Group amounts
        LibraryVATGroup.IncludeVATGroup(VATReportHeader);

        // [GIVEN] The VAT Return is released and accepted
        // [WHEN] The VAT Group Settlement Posted flag is checked
        ReleaseAcceptVATReturn(VATReportHeader, true);

        // [THEN] The user can no longer post the VAT Group Settlement again
        LibraryVATGroup.OpenVATReturnCard(VATReport, VATReportHeader);
        Assert.IsFalse(VATReport."Post VAT Group Settlement".Visible(), ControlShouldNotBeVisibleTxt);

        // [THEN] The user won't be prompted to post VAT Group Settlement again after they use Calc. and Post VAT Settlement
        CalcAndPostVATSettlement(VATReportHeader);
    end;

    [Test]
    [HandlerFunctions('VATGroupSetupYesConfirmHandler')]
    procedure TestVATGroupSettlementWithPrerequisiteErrors()
    var
        VATReportHeader: Record "VAT Report Header";
        VATReportSetup: Record "VAT Report Setup";
        GenJournalTemplate: Record "Gen. Journal Template";
        VATReport: TestPage "VAT Report";
        MemberId: Guid;
        i: Integer;
    begin
        // [FEATURE] [UI]
        // [SCENARIO 374187] VAT Group Settlement With Prerequisite Errors
        Initialize();

        // [GIVEN] Current Role is Group Representative but no further setup for VAT Group settlement is done
        // [GIVEN] We have at least 1 approved member
        MemberId := LibraryVATGroup.MockVATGroupApprovedMember();

        // [GIVEN] We have at least one VAT Return
        // [GIVEN] There are VAT submissions for said period
        CreateVATReturnWith3Lines(VATReportHeader);
        CreateVATSubmissionWith3Lines(MemberId, 100, 200, 300);

        // [GIVEN] We have Included the VAT Group amounts
        LibraryVATGroup.IncludeVATGroup(VATReportHeader);

        // [GIVEN] The VAT Return is released and accepted
        // [GIVEN] The VAT Group Settlement Posted flag is not checked
        ReleaseAcceptVATReturn(VATReportHeader, false);

        // [GIVEN] The user can post the VAT Group Settlement
        LibraryVATGroup.OpenVATReturnCard(VATReport, VATReportHeader);
        Assert.IsTrue(VATReport."Post VAT Group Settlement".Visible(), ControlShouldBeVisibleTxt);

        // [WHEN] the user tries to Post VAT Group Settlement
        Commit();
        asserterror VATReport."Post VAT Group Settlement".Invoke();

        // [THEN] The prerequsite checks will trigger errors
        Assert.ExpectedError(StrSubstNo(VATGroupSettlementErr, NoDueBoxNoErr));
        VATReportSetup.Get();
        VATReportSetup."VAT Due Box No." := '001';
        VATReportSetup.Modify();
        Commit();

        asserterror VATReport."Post VAT Group Settlement".Invoke();
        Assert.ExpectedError(StrSubstNo(VATGroupSettlementErr, NoVATSettlementAccountErr));
        VATReportSetup."VAT Settlement Account" := CreateGLAccountNo(GLAccountCategory::Liabilities);
        VATReportSetup.Modify();
        Commit();

        asserterror VATReport."Post VAT Group Settlement".Invoke();
        Assert.ExpectedError(StrSubstNo(VATGroupSettlementErr, NoGroupSettlementAccountErr));
        VATReportSetup."Group Settlement Account" := CreateGLAccountNo(GLAccountCategory::Assets);
        VATReportSetup.Modify();
        Commit();

        asserterror VATReport."Post VAT Group Settlement".Invoke();
        Assert.ExpectedError(StrSubstNo(VATGroupSettlementErr, NoGroupSettlementGenJnlTemplateErr));
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        VATReportSetup."Group Settle. Gen. Jnl. Templ." := GenJournalTemplate.Name;
        VATReportSetup.Modify();
        Commit();

        asserterror VATReport."Post VAT Group Settlement".Invoke();
        Assert.ExpectedError(
            StrSubstNo(VATGroupSettlementErr, StrSubstNo(GenJournalTemplateDoesNotExistErr, GenJournalTemplate.Name)));

        for i := 1 to 5 do
            Assert.ExpectedMessage(VATGroupSettlementQst, LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('VATGroupSetupYesConfirmHandler,SuccessMessageHandler,HandleVATSettlementReport')]
    procedure TestVATGroupSettlementPostingFromDedicatedAction()
    var
        VATReportHeader: Record "VAT Report Header";
        VATReport: TestPage "VAT Report";
        GenJournalTemplateName: Code[10];
        DocumentNo: Code[20];
        MemberId: array[2] of Guid;
    begin
        // [FEATURE] [UI]
        // [SCENARIO 374187] VAT Group Settlement Posting From Dedicated Action
        Initialize();

        // [GIVEN] Current Role is Group Representative and all setup for VAT Group settlement is done
        ClearValidationCUIds();
        CreateGenJournalTemplateWithNoSeries(GenJournalTemplateName, DocumentNo, false);
        LibraryVATGroup.UpdateSettlementSetup(
            '001', CreateGLAccountNo(GLAccountCategory::Liabilities),
            CreateGLAccountNo(GLAccountCategory::Assets), GenJournalTemplateName);

        // [GIVEN] We have at least 1 approved member
        MemberId[1] := LibraryVATGroup.MockVATGroupApprovedMemberWithName('Member 1');
        MemberId[2] := LibraryVATGroup.MockVATGroupApprovedMemberWithName('Member 2');

        // [GIVEN] We have at least one VAT Return
        // [GIVEN] There are VAT submissions for said period
        CreateVATReturnWith3Lines(VATReportHeader);
        CreateVATSubmissionWith3Lines(MemberId[1], 100, 200, 300);
        CreateVATSubmissionWith3Lines(MemberId[2], 200, 200, 300);

        // [GIVEN] We have Included the VAT Group amounts
        LibraryVATGroup.IncludeVATGroup(VATReportHeader);

        // [GIVEN] The VAT Return is released and accepted
        // [GIVEN] The VAT Group Settlement Posted flag is not checked
        ReleaseAcceptVATReturn(VATReportHeader, false);

        // [GIVEN] The user can post the VAT Group Settlement
        LibraryVATGroup.OpenVATReturnCard(VATReport, VATReportHeader);
        Assert.IsTrue(VATReport."Post VAT Group Settlement".Visible(), ControlShouldBeVisibleTxt);

        // [WHEN] the user Posts the VAT Group Settlement
        Commit();
        VATReport."Post VAT Group Settlement".Invoke();

        // [THEN] It will be successful
        VATReport."VAT Group Settlement Posted".AssertEquals(true);

        // [THEN] The posted GL Entries are correct
        AssertPostedGLEntries(DocumentNo);

        // [THEN] The button would become invisible
        Assert.IsFalse(VATReport."Post VAT Group Settlement".Visible(), ControlShouldNotBeVisibleTxt);

        // [THEN] The user won't be prompted to post VAT Group Settlement again after they use Calc. and Post VAT Settlement
        CalcAndPostVATSettlement(VATReportHeader);

        Assert.ExpectedMessage(VATGroupSettlementQst, LibraryVariableStorage.DequeueText());
        Assert.ExpectedMessage(VATGroupSettlementMsg, LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
        ClearGlEntries(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('VATGroupSetupYesConfirmHandler,SuccessMessageHandler,HandleVATSettlementReport')]
    procedure TestVATGroupSettlementPostingFromDedicatedActionWithZeroAmount()
    var
        VATReportHeader: Record "VAT Report Header";
        VATReport: TestPage "VAT Report";
        GenJournalTemplateName: Code[10];
        DocumentNo: Code[20];
        MemberId: array[2] of Guid;
    begin
        // [FEATURE] [UI]
        // [SCENARIO 374187] VAT Group Settlement Posting From Dedicated Action
        Initialize();

        // [GIVEN] Current Role is Group Representative and all setup for VAT Group settlement is done
        ClearValidationCUIds();
        CreateGenJournalTemplateWithNoSeries(GenJournalTemplateName, DocumentNo, false);
        LibraryVATGroup.UpdateSettlementSetup(
            '001', CreateGLAccountNo(GLAccountCategory::Liabilities),
            CreateGLAccountNo(GLAccountCategory::Assets), GenJournalTemplateName);

        // [GIVEN] We have at least 1 approved member
        MemberId[1] := LibraryVATGroup.MockVATGroupApprovedMemberWithName('Member 1');
        MemberId[2] := LibraryVATGroup.MockVATGroupApprovedMemberWithName('Member 2');

        // [GIVEN] We have at least one VAT Return
        // [GIVEN] There are VAT submissions for said period
        CreateVATReturnWith3Lines(VATReportHeader);
        CreateVATSubmissionWith3Lines(MemberId[1], 0, 200, 300);
        CreateVATSubmissionWith3Lines(MemberId[2], 200, 200, 300);

        // [GIVEN] We have Included the VAT Group amounts
        LibraryVATGroup.IncludeVATGroup(VATReportHeader);

        // [GIVEN] The VAT Return is released and accepted
        // [GIVEN] The VAT Group Settlement Posted flag is not checked
        ReleaseAcceptVATReturn(VATReportHeader, false);

        // [GIVEN] The user can post the VAT Group Settlement
        LibraryVATGroup.OpenVATReturnCard(VATReport, VATReportHeader);
        Assert.IsTrue(VATReport."Post VAT Group Settlement".Visible(), ControlShouldBeVisibleTxt);

        // [WHEN] the user Posts the VAT Group Settlement
        Commit();
        VATReport."Post VAT Group Settlement".Invoke();

        // [THEN] It will be successful
        VATReport."VAT Group Settlement Posted".AssertEquals(true);

        // [THEN] The posted GL Entries are correct
        AssertPostedGLEntriesOneWithZero(DocumentNo);

        // [THEN] The button would become invisible
        Assert.IsFalse(VATReport."Post VAT Group Settlement".Visible(), ControlShouldNotBeVisibleTxt);

        // [THEN] The user won't be prompted to post VAT Group Settlement again after they use Calc. and Post VAT Settlement
        CalcAndPostVATSettlement(VATReportHeader);

        Assert.ExpectedMessage(VATGroupSettlementQst, LibraryVariableStorage.DequeueText());
        Assert.ExpectedMessage(VATGroupSettlementMsg, LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
        ClearGlEntries(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('VATGroupSetupYesConfirmHandler,SuccessMessageHandler,HandleVATSettlementReport')]
    procedure TestVATGroupSettlementPostingFromCalcPostVATReportWithZeroAmount()
    var
        VATReportHeader: Record "VAT Report Header";
        VATReport: TestPage "VAT Report";
        GenJournalTemplateName: Code[10];
        DocumentNo: Code[20];
        MemberId: array[2] of Guid;
    begin
        // [FEATURE] [UI]
        // [SCENARIO 374187] VAT Group Settlement Posting From Calc Post VAT Report
        Initialize();

        // [GIVEN] Current Role is Group Representative and all setup for VAT Group settlement is done
        ClearValidationCUIds();
        CreateGenJournalTemplateWithNoSeries(GenJournalTemplateName, DocumentNo, true);
        LibraryVATGroup.UpdateSettlementSetup(
            '001', CreateGLAccountNo(GLAccountCategory::Liabilities),
            CreateGLAccountNo(GLAccountCategory::Assets), GenJournalTemplateName);

        // [GIVEN] We have at least 1 approved member
        MemberId[1] := LibraryVATGroup.MockVATGroupApprovedMemberWithName('Member 1');
        MemberId[2] := LibraryVATGroup.MockVATGroupApprovedMemberWithName('Member 2');

        // [GIVEN] We have at least one VAT Return
        // [GIVEN] There are VAT submissions for said period
        CreateVATReturnWith3Lines(VATReportHeader);
        CreateVATSubmissionWith3Lines(MemberId[1], 0, 200, 300);
        CreateVATSubmissionWith3Lines(MemberId[2], 200, 200, 300);

        // [GIVEN] We have Included the VAT Group amounts
        LibraryVATGroup.IncludeVATGroup(VATReportHeader);

        // [GIVEN] The VAT Return is released and accepted
        // [GIVEN] The VAT Group Settlement Posted flag is not checked
        ReleaseAcceptVATReturn(VATReportHeader, false);

        // [GIVEN] The user can post the VAT Group Settlement
        LibraryVATGroup.OpenVATReturnCard(VATReport, VATReportHeader);
        Assert.IsTrue(VATReport."Post VAT Group Settlement".Visible(), ControlShouldBeVisibleTxt);

        // [WHEN] The user posts the VAT Group settlement triggered automatically after posting the normal Calc. Post VAT Settlement
        CalcAndPostVATSettlement(VATReportHeader);
        VATReport."VAT Group Settlement Posted".AssertEquals(true);

        // [THEN] The posted GL Entries are correct
        AssertPostedGLEntriesOneWithZero(DocumentNo);

        // [THEN] The button would become invisible
        Assert.IsFalse(VATReport."Post VAT Group Settlement".Visible(), ControlShouldNotBeVisibleTxt);

        // [THEN] The user won't be prompted to post VAT Group Settlement again after they use Calc. and Post VAT Settlement
        CalcAndPostVATSettlement(VATReportHeader);

        Assert.ExpectedMessage(VATGroupSettlementQst, LibraryVariableStorage.DequeueText());
        Assert.ExpectedMessage(VATGroupSettlementMsg, LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
        ClearGlEntries(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('VATGroupSetupYesConfirmHandler,SuccessMessageHandler,HandleVATSettlementReport')]
    procedure TestVATGroupSettlementPostingFromCalcPostVATReport()
    var
        VATReportHeader: Record "VAT Report Header";
        VATReport: TestPage "VAT Report";
        GenJournalTemplateName: Code[10];
        DocumentNo: Code[20];
        MemberId: array[2] of Guid;
    begin
        // [FEATURE] [UI]
        // [SCENARIO 374187] VAT Group Settlement Posting From Calc Post VAT Report
        Initialize();

        // [GIVEN] Current Role is Group Representative and all setup for VAT Group settlement is done
        ClearValidationCUIds();
        CreateGenJournalTemplateWithNoSeries(GenJournalTemplateName, DocumentNo, true);
        LibraryVATGroup.UpdateSettlementSetup(
            '001', CreateGLAccountNo(GLAccountCategory::Liabilities),
            CreateGLAccountNo(GLAccountCategory::Assets), GenJournalTemplateName);

        // [GIVEN] We have at least 1 approved member
        MemberId[1] := LibraryVATGroup.MockVATGroupApprovedMemberWithName('Member 1');
        MemberId[2] := LibraryVATGroup.MockVATGroupApprovedMemberWithName('Member 2');

        // [GIVEN] We have at least one VAT Return
        // [GIVEN] There are VAT submissions for said period
        CreateVATReturnWith3Lines(VATReportHeader);
        CreateVATSubmissionWith3Lines(MemberId[1], 100, 200, 300);
        CreateVATSubmissionWith3Lines(MemberId[2], 200, 200, 300);

        // [GIVEN] We have Included the VAT Group amounts
        LibraryVATGroup.IncludeVATGroup(VATReportHeader);

        // [GIVEN] The VAT Return is released and accepted
        // [GIVEN] The VAT Group Settlement Posted flag is not checked
        ReleaseAcceptVATReturn(VATReportHeader, false);

        // [GIVEN] The user can post the VAT Group Settlement
        LibraryVATGroup.OpenVATReturnCard(VATReport, VATReportHeader);
        Assert.IsTrue(VATReport."Post VAT Group Settlement".Visible(), ControlShouldBeVisibleTxt);

        // [WHEN] The user posts the VAT Group settlement triggered automatically after posting the normal Calc. Post VAT Settlement
        CalcAndPostVATSettlement(VATReportHeader);
        VATReport."VAT Group Settlement Posted".AssertEquals(true);

        // [THEN] The posted GL Entries are correct
        AssertPostedGLEntries(DocumentNo);

        // [THEN] The button would become invisible
        Assert.IsFalse(VATReport."Post VAT Group Settlement".Visible(), ControlShouldNotBeVisibleTxt);

        // [THEN] The user won't be prompted to post VAT Group Settlement again after they use Calc. and Post VAT Settlement
        CalcAndPostVATSettlement(VATReportHeader);

        Assert.ExpectedMessage(VATGroupSettlementQst, LibraryVariableStorage.DequeueText());
        Assert.ExpectedMessage(VATGroupSettlementMsg, LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
        ClearGlEntries(DocumentNo);
    end;

    local procedure Initialize()
    begin
        LibraryVariableStorage.Clear();
        LibraryVATGroup.ClearApprovedMembers();

        if IsInitialized then
            exit;

        LibraryVATGroup.EnableDefaultVATRepresentativeSetup();
        IsInitialized := true;

        Commit();
    end;

    local procedure ClearGlEntries(DocumentNo: Code[20])
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.DeleteAll();
    end;

    local procedure CreateGenJournalTemplateWithNoSeries(var TemplateName: Code[10]; var NextDocumentNo: Code[20]; SkipNextNoSeriesDocNo: Boolean)
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        GenJournalTemplate."No. Series" := LibraryERM.CreateNoSeriesCode('vat');
        GenJournalTemplate.Modify();
        TemplateName := GenJournalTemplate.Name;
        if SkipNextNoSeriesDocNo then
            NoSeriesManagement.GetNextNo(GenJournalTemplate."No. Series", WorkDate(), true);
        NextDocumentNo := NoSeriesManagement.GetNextNo(GenJournalTemplate."No. Series", WorkDate(), false);
    end;

    local procedure CreateGLAccountNo(Category: Enum "G/L Account Category"): Code[20]
    var
        GLAccount: Record "G/L Account";
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        GLAccount."Account Category" := Category;
        GLAccount.Modify();
        exit(GLAccount."No.");
    end;

    local procedure ClearValidationCUIds()
    var
        VATReportsConfiguration: Record "VAT Reports Configuration";
    begin
        VATReportsConfiguration.SetRange("VAT Report Type", VATReportsConfiguration."VAT Report Type"::"VAT Return");
        VATReportsConfiguration.ModifyAll("Validate Codeunit ID", 0);
    end;

    local procedure CreateVATReturnWith3Lines(var VATReportHeader: Record "VAT Report Header"): Code[20]
    var
        VATStatementReportLine: Record "VAT Statement Report Line";
    begin
        LibraryVATGroup.MockVATReportHeaderWithDates(VATReportHeader, DMY2Date(1, 1, 2020), DMY2Date(31, 1, 2020));
        LibraryVATGroup.MockVATStatementReportLineWithBoxNo(VATStatementReportLine, VATReportHeader, 100, '001', '001');
        LibraryVATGroup.MockVATStatementReportLineWithBoxNo(VATStatementReportLine, VATReportHeader, 200, '002', '002');
        LibraryVATGroup.MockVATStatementReportLineWithBoxNo(VATStatementReportLine, VATReportHeader, 300, '003', '003');
        exit(VATReportHeader."No.");
    end;

    local procedure CreateVATSubmissionWith3Lines(MemberId: Guid; Amount1: Decimal; Amount2: Decimal; Amount3: Decimal): Code[20]
    var
        VATGroupSubmissionHeader: Record "VAT Group Submission Header";
    begin
        VATGroupSubmissionHeader.Get(
          LibraryVATGroup.MockVATGroupSubmissionHeaderWithSubmittedDate(
            DMY2Date(1, 1, 2020), DMY2Date(31, 1, 2020), MemberId, '', CreateDateTime(DMY2Date(30, 1, 2020), Time())));
        LibraryVATGroup.MockVATGroupSubmissionLine(VATGroupSubmissionHeader, Amount1, '001', '001');
        LibraryVATGroup.MockVATGroupSubmissionLine(VATGroupSubmissionHeader, Amount2, '002', '002');
        LibraryVATGroup.MockVATGroupSubmissionLine(VATGroupSubmissionHeader, Amount3, '003', '003');
        exit(VATGroupSubmissionHeader."No.");
    end;

    local procedure ReleaseAcceptVATReturn(var VATReportHeader: Record "VAT Report Header"; VATGroupSettlementPosted: Boolean)
    var
        VATReport: TestPage "VAT Report";
    begin
        LibraryVATGroup.OpenVATReturnCard(VATReport, VATReportHeader);
        VATReport.Release.Invoke();
        VATReport.Close();

        VATReportHeader.Find();
        VATReportHeader.Status := VATReportHeader.Status::Accepted;
        VATReportHeader."VAT Group Settlement Posted" := VATGroupSettlementPosted;
        VATReportHeader.Modify();
    end;

    local procedure CalcAndPostVATSettlement(VATReportHeader: Record "VAT Report Header")
    var
        VATReport: TestPage "VAT Report";
    begin
        LibraryVATGroup.OpenVATReturnCard(VATReport, VATReportHeader);
        Commit();
        VATReport."Calc. and Post VAT Settlement".Invoke();
        VATReport.Close();
    end;

    local procedure AssertPostedGLEntries(DocumentNo: Code[20])
    var
        GLEntry: Record "G/L Entry";
        VATReportSetup: Record "VAT Report Setup";
        DateFrom: Date;
        DateTo: Date;
    begin
        GLEntry.SetRange("Document No.", DocumentNo);
        Assert.RecordCount(GLEntry, 4);

        GLEntry.CalcSums(Amount);
        Assert.AreEqual(0, GLEntry.Amount, 'The net sum should be 0');

        VATReportSetup.Get();
        DateFrom := DMY2Date(1, 1, 2020);
        DateTo := DMY2Date(31, 1, 2020);
        AssertPostedGLEntry(
            DocumentNo, VATReportSetup."VAT Settlement Account", 100,
            StrSubstNo(VATSettlementForTxt, 'Member 1', DateFrom, DateTo), false);
        AssertPostedGLEntry(
            DocumentNo, VATReportSetup."Group Settlement Account", -100,
            StrSubstNo(VATDueFromTxt, 'Member 1', DateFrom, DateTo), false);
        AssertPostedGLEntry(
            DocumentNo, VATReportSetup."VAT Settlement Account", 200,
            StrSubstNo(VATSettlementForTxt, 'Member 2', DateFrom, DateTo), false);
        AssertPostedGLEntry(
            DocumentNo, VATReportSetup."Group Settlement Account", -200,
            StrSubstNo(VATDueFromTxt, 'Member 2', DateFrom, DateTo), false);
    end;

    local procedure AssertPostedGLEntriesOneWithZero(DocumentNo: Code[20])
    var
        GLEntry: Record "G/L Entry";
        VATReportSetup: Record "VAT Report Setup";
        DateFrom: Date;
        DateTo: Date;
    begin
        GLEntry.SetRange("Document No.", DocumentNo);
        Assert.RecordCount(GLEntry, 2);

        GLEntry.CalcSums(Amount);
        Assert.AreEqual(0, GLEntry.Amount, 'The net sum should be 0');

        VATReportSetup.Get();
        DateFrom := DMY2Date(1, 1, 2020);
        DateTo := DMY2Date(31, 1, 2020);
        AssertPostedGLEntry(
            DocumentNo, VATReportSetup."VAT Settlement Account", 100,
            StrSubstNo(VATSettlementForTxt, 'Member 1', DateFrom, DateTo), true);
        AssertPostedGLEntry(
            DocumentNo, VATReportSetup."Group Settlement Account", -100,
            StrSubstNo(VATDueFromTxt, 'Member 1', DateFrom, DateTo), true);
        AssertPostedGLEntry(
            DocumentNo, VATReportSetup."VAT Settlement Account", 200,
            StrSubstNo(VATSettlementForTxt, 'Member 2', DateFrom, DateTo), false);
        AssertPostedGLEntry(
            DocumentNo, VATReportSetup."Group Settlement Account", -200,
            StrSubstNo(VATDueFromTxt, 'Member 2', DateFrom, DateTo), false);
    end;

    local procedure AssertPostedGLEntry(DocumentNo: Code[20]; GLAccountNo: Code[20]; Amount: Decimal; Description: Text; Empty: Boolean)
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.SetRange(Amount, Amount);
        GLEntry.SetRange(Description, Description);
        GLEntry.SetRange("G/L Account No.", GLAccountNo);
        if not Empty then
            Assert.RecordIsNotEmpty(GLEntry)
        else
            Assert.RecordIsEmpty(GLEntry)
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure HandleVATSettlementReport(var CalcAndPostVATSettlement: TestRequestPage "Calc. and Post VAT Settlement")
    begin
        // Open and close the vat settlement report to simulate usage.
        CalcAndPostVATSettlement.Cancel().Invoke();
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure VATGroupSetupYesConfirmHandler(Question: Text[1024]; var Response: Boolean)
    begin
        LibraryVariableStorage.Enqueue(Question);
        Response := true;
    end;

    [MessageHandler]
    [Scope('OnPrem')]
    procedure SuccessMessageHandler(Message: Text[1024])
    begin
        LibraryVariableStorage.Enqueue(Message);
    end;
}
