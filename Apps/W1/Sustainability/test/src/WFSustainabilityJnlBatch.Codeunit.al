namespace Microsoft.Test.Sustainability;

using Microsoft.Sustainability.Workflow;
using System.TestLibraries.Utilities;
using Microsoft.Sustainability.Journal;
using System.Automation;
using System.Security.User;
using System.Environment.Configuration;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Setup;
using System.Threading;

codeunit 148207 "WF Sustainability Jnl. Batch"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Workflow] [Approval]
    end;

    var
        Assert: Codeunit Assert;
        LibraryRandom: Codeunit "Library - Random";
        LibraryWorkflow: Codeunit "Library - Workflow";
        SustWorkflowEventHandling: Codeunit "Sust. Workflow Event Handling";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibrarySustainability: Codeunit "Library - Sustainability";
        LibraryDocumentApprovals: Codeunit "Library - Document Approvals";
        SustainabilityJournalMgt: Codeunit "Sustainability Journal Mgt.";
        DialogTok: Label 'Dialog';
        ApprovalRequestExistsErr: Label 'An approval request already exists.';
        AccountCodeLbl: Label 'AccountCode%1', Locked = true, Comment = '%1 = Number';
        CategoryCodeLbl: Label 'CategoryCode%1', Locked = true, Comment = '%1 = Number';
        SubcategoryCodeLbl: Label 'SubcategoryCode%1', Locked = true, Comment = '%1 = Number';
        CancelApprovalRequestJournalBatchActionMustBeEnabledLbl: Label 'Cancel Approval Request Journal Batch action must be enabled.';
        CancelApprovalRequestJournalBatchActionMustBeDisabledLbl: Label 'Cancel Approval Request Journal Batch action must be disabled.';
        SendApprovalRequestJournalBatchActionMustBeDisabledLbl: Label 'Send Approval Request Journal Batch action must be disabled.';
        ApprovalCommentActionMustBeVisibleLbl: Label 'Approval Comment action must be visible.';
        ApprovalCommentActionMustNotBeVisibleLbl: Label 'Approval Comment action must not be visible.';
        ApproveActionMustNotBeVisibleLbl: Label 'Approve action must not be visible.';
        RejectActionMustNotBeVisibleLbl: Label 'Reject action must not be visible.';
        DelegateActionMustNotBeVisibleLbl: Label 'Delegate action must not be visible.';
        ApproveActionMustBeVisibleLbl: Label 'Approve action must be visible.';
        RejectActionMustBeVisibleLbl: Label 'Reject action must be visible.';
        DelegateActionMustBeVisibleLbl: Label 'Delegate action must be visible.';
        PageContainsWrongNumberOfCommentsLbl: Label 'The %1 page contains the wrong number of comments. Comments must be equal to %2', Comment = '%1 = Page Name, %2 = No. of Comments';
        TestCommentLbl: Label 'Test Comment';
        IsInitialized: Boolean;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure DirectApproverApprovesRequestForSustainabilityJournalBatch()
    var
        Workflow: Record Workflow;
        ApprovalEntry: Record "Approval Entry";
        ApproverUserSetup: Record "User Setup";
        RequestorUserSetup: Record "User Setup";
        SustainabilityJournalBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
    begin
        // [SCENARIO 546878] Verify Approver approves the request for the Sustainability Journal Batch.
        Initialize();

        // [GIVEN] Create Direct Approval and Enable Workflow.
        CreateDirectApprovalEnabledWorkflow(Workflow);

        // [GIVEN] Create a Sustainability Journal Line.
        CreateSustainabilityJournalBatchWithOneJournalLine(SustainabilityJournalBatch, SustainabilityJournalLine);

        // [GIVEN] Create an Approval Setup.
        CreateApprovalSetup(ApproverUserSetup, RequestorUserSetup);

        // [GIVEN] Save a transaction.
        Commit();

        // [WHEN] Send an Approval Request for Sustainability Journal.
        SendApprovalRequestForSustainabilityJournal(SustainabilityJournalLine);

        // [THEN] Verify Open Approval Entry.
        LibraryDocumentApprovals.GetApprovalEntries(ApprovalEntry, SustainabilityJournalBatch.RecordId());
        VerifyOpenApprovalEntry(ApprovalEntry, ApproverUserSetup, RequestorUserSetup);

        // [GIVEN] Assign an Approval Entry.
        AssignApprovalEntry(ApprovalEntry, RequestorUserSetup);

        // [WHEN] Approve an Approve Entry.
        Approve(ApprovalEntry);

        // [THEN] Verify Approval Entry is Approved.
        ApprovalEntry.Reset();
        LibraryDocumentApprovals.GetApprovalEntries(ApprovalEntry, SustainabilityJournalBatch.RecordId());
        VerifyApprovalEntryIsApproved(ApprovalEntry);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure DirectApproverRejectsRequestForSustainabilityJournalBatch()
    var
        Workflow: Record Workflow;
        ApprovalEntry: Record "Approval Entry";
        ApproverUserSetup: Record "User Setup";
        RequestorUserSetup: Record "User Setup";
        NotificationEntry: Record "Notification Entry";
        SustainabilityJournalBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
    begin
        // [SCENARIO 546878] Verify Approver Reject the request for the Sustainability Journal Batch.
        Initialize();

        // [GIVEN] Create Direct Approval and Enable Workflow.
        CreateDirectApprovalEnabledWorkflow(Workflow);

        // [GIVEN] Create a Sustainability Journal Line.
        CreateSustainabilityJournalBatchWithOneJournalLine(SustainabilityJournalBatch, SustainabilityJournalLine);

        // [GIVEN] Create an Approval Setup.
        CreateApprovalSetup(ApproverUserSetup, RequestorUserSetup);

        // [GIVEN] Save a transaction.
        Commit();

        // [WHEN] Send an Approval Request and Run Notification Entry Dispatcher for Sustainability Journal.
        SendApprovalRequestForSustainabilityJournal(SustainabilityJournalLine);
        RunNotificationEntryDispatcher();

        // [THEN] Verify Open Approval Entry.
        LibraryDocumentApprovals.GetApprovalEntries(ApprovalEntry, SustainabilityJournalBatch.RecordId());
        VerifyOpenApprovalEntry(ApprovalEntry, ApproverUserSetup, RequestorUserSetup);

        // [GIVEN] Assign Aan pproval Entry.
        AssignApprovalEntry(ApprovalEntry, RequestorUserSetup);

        // [WHEN] Reject an Approve Entry.
        Reject(ApprovalEntry);

        // [THEN] Verify Approval Entry is Rejected.
        ApprovalEntry.Reset();
        LibraryDocumentApprovals.GetApprovalEntries(ApprovalEntry, SustainabilityJournalBatch.RecordId());
        VerifyApprovalEntryIsRejected(ApprovalEntry);

        // [THEN] Verify Notification Entry is created.
        NotificationEntry.Init();
        NotificationEntry.SetRange("Triggered By Record", ApprovalEntry.RecordId());
        Assert.RecordCount(NotificationEntry, 1);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure DirectApproverDelegateRequestForSustainabilityJournalBatch()
    var
        Workflow: Record Workflow;
        ApprovalEntry: Record "Approval Entry";
        ApproverUserSetup: Record "User Setup";
        RequestorUserSetup: Record "User Setup";
        SubstituteUserSetup: Record "User Setup";
        SustainabilityJournalBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
    begin
        // [SCENARIO 546878] Verify Approver Delegate the request for the Sustainability Journal Batch.
        Initialize();

        // [GIVEN] Create Direct Approval and Enable Workflow.
        CreateDirectApprovalEnabledWorkflow(Workflow);

        // [GIVEN] Create a Sustainability Journal Line.
        CreateSustainabilityJournalBatchWithOneJournalLine(SustainabilityJournalBatch, SustainabilityJournalLine);

        // [GIVEN] Create an Approval Setup.
        CreateApprovalSetup(ApproverUserSetup, RequestorUserSetup);

        // [GIVEN] Save a transaction.
        Commit();

        // [WHEN] Send an Approval Request for Sustainability Journal.
        SendApprovalRequestForSustainabilityJournal(SustainabilityJournalLine);

        // [THEN] Verify Open Approval Entry.
        LibraryDocumentApprovals.GetApprovalEntries(ApprovalEntry, SustainabilityJournalBatch.RecordId());
        VerifyOpenApprovalEntry(ApprovalEntry, ApproverUserSetup, RequestorUserSetup);

        // [GIVEN] Assign an Approval Entry.
        AssignApprovalEntry(ApprovalEntry, RequestorUserSetup);

        // [GIVEN] Create MockUp User Setup and Set Substitute User.
        LibraryDocumentApprovals.CreateMockupUserSetup(SubstituteUserSetup);
        LibraryDocumentApprovals.SetSubstitute(RequestorUserSetup, SubstituteUserSetup);

        // [WHEN] Delegate an Approve Entry.
        Delegate(ApprovalEntry);

        // [THEN] Verify Open Approval Entry.
        ApprovalEntry.Reset();
        LibraryDocumentApprovals.GetApprovalEntries(ApprovalEntry, SustainabilityJournalBatch.RecordId());
        VerifyOpenApprovalEntry(ApprovalEntry, SubstituteUserSetup, ApproverUserSetup);

        // [GIVEN] Assign an Approval Entry.
        AssignApprovalEntry(ApprovalEntry, RequestorUserSetup);

        // [WHEN] Approve an Approve Entry.
        Approve(ApprovalEntry);

        // [THEN] Verify Approval Entry is Approved.
        ApprovalEntry.Reset();
        LibraryDocumentApprovals.GetApprovalEntries(ApprovalEntry, SustainabilityJournalBatch.RecordId());
        VerifyApprovalEntryIsApproved(ApprovalEntry);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure RequestorCancelsRequestToDirectApproverForSustainabilityJournalBatch()
    var
        Workflow: Record Workflow;
        ApprovalEntry: Record "Approval Entry";
        ApproverUserSetup: Record "User Setup";
        RequestorUserSetup: Record "User Setup";
        SustainabilityJournalBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
    begin
        // [SCENARIO 546878] Verify Requestor Cancels the request for the Sustainability Journal Batch.
        Initialize();

        // [GIVEN] Create Direct Approval and Enable Workflow.
        CreateDirectApprovalEnabledWorkflow(Workflow);

        // [GIVEN] Create a Sustainability Journal Line.
        CreateSustainabilityJournalBatchWithOneJournalLine(SustainabilityJournalBatch, SustainabilityJournalLine);

        // [GIVEN] Create an Approval Setup.
        CreateApprovalSetup(ApproverUserSetup, RequestorUserSetup);

        // [GIVEN] Check User can cancel the Approval Request for Sustainability Journal Batch.
        CheckUserCanCancelTheApprovalRequestForSustainabilityJournalBatch(SustainabilityJournalBatch.Name, false);

        // [GIVEN] Save a transaction.
        Commit();

        // [WHEN] Send an Approval Request for Sustainability Journal.
        SendApprovalRequestForSustainabilityJournal(SustainabilityJournalLine);

        // [THEN] Verify Open Approval Entry.
        LibraryDocumentApprovals.GetApprovalEntries(ApprovalEntry, SustainabilityJournalBatch.RecordId());
        VerifyOpenApprovalEntry(ApprovalEntry, ApproverUserSetup, RequestorUserSetup);

        // [GIVEN] Check User can cancel the Approval Request for Sustainability Journal Batch.
        CheckUserCanCancelTheApprovalRequestForSustainabilityJournalBatch(SustainabilityJournalBatch.Name, true);

        // [WHEN] Cancel an Approval Request for Sustainability Journal.
        CancelApprovalRequestForSustainabilityJournal(SustainabilityJournalBatch.Name);

        // [THEN] Verify Approval Entry is Cancelled.
        ApprovalEntry.Reset();
        LibraryDocumentApprovals.GetApprovalEntries(ApprovalEntry, SustainabilityJournalBatch.RecordId());
        VerifyApprovalEntryIsCancelled(ApprovalEntry);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure RequestorCancelsFilteredRequestToDirectApproverForSustainabilityJournalBatch()
    var
        Workflow: Record Workflow;
        ApprovalEntry: Record "Approval Entry";
        ApproverUserSetup: Record "User Setup";
        RequestorUserSetup: Record "User Setup";
        SustainabilityJournalBatch: Record "Sustainability Jnl. Batch";
    begin
        // [SCENARIO 546878] Verify Requestor cancels the filtered request for the Sustainability Journal Batch.
        Initialize();

        // [GIVEN] Create Direct Approval and Enable Workflow.
        CreateDirectApprovalEnabledWorkflow(Workflow);

        // [GIVEN] Create multiple Sustainability Journal Line.
        CreateSustainabilityJournalBatchWithMultipleJournalLine(SustainabilityJournalBatch);

        // [GIVEN] Create an Approval Setup.
        CreateApprovalSetup(ApproverUserSetup, RequestorUserSetup);

        // [GIVEN] Check User can cancel the Approval Request for Sustainability Journal Batch.
        CheckUserCanCancelTheApprovalRequestForSustainabilityJournalBatch(SustainabilityJournalBatch.Name, false);

        // [GIVEN] Save a transaction.
        Commit();

        // [WHEN] Send Filtered Approval Request.
        SendFilteredApprovalRequest(SustainabilityJournalBatch.Name);

        // [THEN] Verify Open Approval Entry.
        LibraryDocumentApprovals.GetApprovalEntries(ApprovalEntry, SustainabilityJournalBatch.RecordId());
        VerifyOpenApprovalEntry(ApprovalEntry, ApproverUserSetup, RequestorUserSetup);

        // [GIVEN] Check User can cancel the Approval Request for Sustainability Journal Batch.
        CheckUserCanCancelTheApprovalRequestForSustainabilityJournalBatch(SustainabilityJournalBatch.Name, true);

        // [WHEN] Cancel an Approval Request for Sustainability Journal.
        CancelApprovalRequestForSustainabilityJournal(SustainabilityJournalBatch.Name);

        // [THEN] Verify Approval Entry is Cancelled.
        ApprovalEntry.Reset();
        LibraryDocumentApprovals.GetApprovalEntries(ApprovalEntry, SustainabilityJournalBatch.RecordId());
        VerifyApprovalEntryIsCancelled(ApprovalEntry);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure DirectApproverApprovesRequestWithCommentForSustainabilityJournalBatch()
    var
        Workflow: Record Workflow;
        ApprovalEntry: Record "Approval Entry";
        ApproverUserSetup: Record "User Setup";
        RequestorUserSetup: Record "User Setup";
        SustainabilityJournalBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
    begin
        // [SCENARIO 546878] Verify Direct Approver approves the request with comment for the Sustainability Journal Batch.
        Initialize();

        // [GIVEN] Create Direct Approval and Enable Workflow.
        CreateDirectApprovalEnabledWorkflow(Workflow);

        // [GIVEN] Create a Sustainability Journal Line.
        CreateSustainabilityJournalBatchWithOneJournalLine(SustainabilityJournalBatch, SustainabilityJournalLine);

        // [GIVEN] Create an Approval Setup.
        CreateApprovalSetup(ApproverUserSetup, RequestorUserSetup);

        // [GIVEN] Check Comments for Document on Sustainability Journal Batch.
        CheckCommentsForDocumentOnSustainabilityJournalPage(SustainabilityJournalBatch, 0, false);

        // [GIVEN] Save a transaction.
        Commit();

        // [WHEN] Send an Approval Request for Sustainability Journal.
        SendApprovalRequestForSustainabilityJournal(SustainabilityJournalLine);

        // [THEN] Verify Open Approval Entry.
        LibraryDocumentApprovals.GetApprovalEntries(ApprovalEntry, SustainabilityJournalBatch.RecordId());
        VerifyOpenApprovalEntry(ApprovalEntry, ApproverUserSetup, RequestorUserSetup);

        // [GIVEN] Assign an Approval Entry.
        AssignApprovalEntry(ApprovalEntry, RequestorUserSetup);

        // [GIVEN] Check Comments for Document on Sustainability Journal Batch , Approval Entries and Requests To Approve Page.
        CheckCommentsForDocumentOnSustainabilityJournalPage(SustainabilityJournalBatch, 0, true);
        CheckCommentsForDocumentOnApprovalEntriesPage(ApprovalEntry, 1);
        CheckCommentsForDocumentOnRequestsToApprovePage(ApprovalEntry, 1);

        // [WHEN] Approve an Approve Entry.
        Approve(ApprovalEntry);

        // [THEN] Verify Approval Entry is Approved.
        ApprovalEntry.Reset();
        LibraryDocumentApprovals.GetApprovalEntries(ApprovalEntry, SustainabilityJournalBatch.RecordId());
        VerifyApprovalEntryIsApproved(ApprovalEntry);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure DirectApproverApprovesFilteredRequestForSustainabilityJournalBatch()
    var
        Workflow: Record Workflow;
        ApprovalEntry: Record "Approval Entry";
        ApproverUserSetup: Record "User Setup";
        RequestorUserSetup: Record "User Setup";
        SustainabilityJournalBatch: Record "Sustainability Jnl. Batch";
    begin
        // [SCENARIO 546878] Verify Direct Approver approves the filtered request for the Sustainability Journal Batch.
        Initialize();

        // [GIVEN] Create Direct Approval and Enable Workflow.
        CreateDirectApprovalEnabledWorkflow(Workflow);

        // [GIVEN] Create multiple Sustainability Journal Line.
        CreateSustainabilityJournalBatchWithMultipleJournalLine(SustainabilityJournalBatch);

        // [GIVEN] Create an Approval Setup.
        CreateApprovalSetup(ApproverUserSetup, RequestorUserSetup);

        // [GIVEN] Save a transaction.
        Commit();

        // [WHEN] Send Filtered Approval Request.
        SendFilteredApprovalRequest(SustainabilityJournalBatch.Name);

        // [THEN] Verify Open Approval Entry.
        LibraryDocumentApprovals.GetApprovalEntries(ApprovalEntry, SustainabilityJournalBatch.RecordId());
        VerifyOpenApprovalEntry(ApprovalEntry, ApproverUserSetup, RequestorUserSetup);

        // [GIVEN] Assign an Approval Entry.
        AssignApprovalEntry(ApprovalEntry, RequestorUserSetup);

        // [WHEN] Approve an Approve Entry.
        Approve(ApprovalEntry);

        // [THEN] Verify Approval Entry is Approved.
        ApprovalEntry.Reset();
        LibraryDocumentApprovals.GetApprovalEntries(ApprovalEntry, SustainabilityJournalBatch.RecordId());
        VerifyApprovalEntryIsApproved(ApprovalEntry);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure DirectApproverRejectsFilteredRequestForSustainabilityJournalBatch()
    var
        Workflow: Record Workflow;
        ApprovalEntry: Record "Approval Entry";
        ApproverUserSetup: Record "User Setup";
        RequestorUserSetup: Record "User Setup";
        SustainabilityJournalBatch: Record "Sustainability Jnl. Batch";
    begin
        // [SCENARIO 546878] Verify Direct Approver rejects the filtered request for the Sustainability Journal Batch.
        Initialize();

        // [GIVEN] Create Direct Approval and Enable Workflow.
        CreateDirectApprovalEnabledWorkflow(Workflow);

        // [GIVEN] Create multiple Sustainability Journal Line.
        CreateSustainabilityJournalBatchWithMultipleJournalLine(SustainabilityJournalBatch);

        // [GIVEN] Create an Approval Setup.
        CreateApprovalSetup(ApproverUserSetup, RequestorUserSetup);

        // [GIVEN] Save a transaction.
        Commit();

        // [WHEN] Send Filtered Approval Request.
        SendFilteredApprovalRequest(SustainabilityJournalBatch.Name);

        // [THEN] Verify Open Approval Entry.
        LibraryDocumentApprovals.GetApprovalEntries(ApprovalEntry, SustainabilityJournalBatch.RecordId());
        VerifyOpenApprovalEntry(ApprovalEntry, ApproverUserSetup, RequestorUserSetup);

        // [GIVEN] Assign an Approval Entry.
        AssignApprovalEntry(ApprovalEntry, RequestorUserSetup);

        // [WHEN] Reject an Approve Entry.
        Reject(ApprovalEntry);

        // [THEN] Verify Approval Entry is Rejected.
        ApprovalEntry.Reset();
        LibraryDocumentApprovals.GetApprovalEntries(ApprovalEntry, SustainabilityJournalBatch.RecordId());
        VerifyApprovalEntryIsRejected(ApprovalEntry);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure DirectApproverDelegatesFilteredRequestForSustainabilityJournalBatch()
    var
        Workflow: Record Workflow;
        ApprovalEntry: Record "Approval Entry";
        ApproverUserSetup: Record "User Setup";
        RequestorUserSetup: Record "User Setup";
        SubstituteUserSetup: Record "User Setup";
        SustainabilityJournalBatch: Record "Sustainability Jnl. Batch";
    begin
        // [SCENARIO 546878] Verify Direct Approver delegates the filtered request for the Sustainability Journal Batch.
        Initialize();

        // [GIVEN] Create Direct Approval and Enable Workflow.
        CreateDirectApprovalEnabledWorkflow(Workflow);

        // [GIVEN] Create multiple Sustainability Journal Line.
        CreateSustainabilityJournalBatchWithMultipleJournalLine(SustainabilityJournalBatch);

        // [GIVEN] Create an Approval Setup.
        CreateApprovalSetup(ApproverUserSetup, RequestorUserSetup);

        // [GIVEN] Save a transaction.
        Commit();

        // [WHEN] Send Filtered Approval Request.
        SendFilteredApprovalRequest(SustainabilityJournalBatch.Name);

        // [THEN] Verify Open Approval Entry.
        LibraryDocumentApprovals.GetApprovalEntries(ApprovalEntry, SustainabilityJournalBatch.RecordId());
        VerifyOpenApprovalEntry(ApprovalEntry, ApproverUserSetup, RequestorUserSetup);

        // [GIVEN] Assign an Approval Entry.
        AssignApprovalEntry(ApprovalEntry, RequestorUserSetup);

        // [GIVEN] Create MockUp User Setup and Set Substitute User.
        LibraryDocumentApprovals.CreateMockupUserSetup(SubstituteUserSetup);
        LibraryDocumentApprovals.SetSubstitute(RequestorUserSetup, SubstituteUserSetup);

        // [WHEN] Delegate an Approve Entry.
        Delegate(ApprovalEntry);

        // [THEN] Verify Open Approval Entry.
        ApprovalEntry.Reset();
        LibraryDocumentApprovals.GetApprovalEntries(ApprovalEntry, SustainabilityJournalBatch.RecordId());
        VerifyOpenApprovalEntry(ApprovalEntry, SubstituteUserSetup, ApproverUserSetup);

        // [GIVEN] Assign an Approval Entry.
        AssignApprovalEntry(ApprovalEntry, RequestorUserSetup);

        // [WHEN] Approve an Approve Entry.
        Approve(ApprovalEntry);

        // [THEN] Verify Approval Entry is Approved.
        ApprovalEntry.Reset();
        LibraryDocumentApprovals.GetApprovalEntries(ApprovalEntry, SustainabilityJournalBatch.RecordId());
        VerifyApprovalEntryIsApproved(ApprovalEntry);
    end;

    [Test]
    procedure TrySendJournalBatchApprovalRequestWhenOpenBatchEntryExists()
    var
        Workflow: Record Workflow;
        SustainabilityJournalBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
        SustApprovalsMgmt: Codeunit "Sust. Approvals Mgmt.";
    begin
        // [SCENARIO 546878] Stan cannot send Approval Request for Journal Batch when another Open Approval Request for the Batch already exists.
        Initialize();

        // [GIVEN] Create a Sustainability Journal Line.
        CreateSustainabilityJournalBatchWithOneJournalLine(SustainabilityJournalBatch, SustainabilityJournalLine);

        // [GIVEN] Workflow is enabled.
        CreateDirectApprovalWorkflow(Workflow);
        EnableWorkflow(Workflow);

        // [GIVEN] Open Approval Request for Sustainability. Journal Batch.
        CreateOpenApprovalEntryForCurrentUser(SustainabilityJournalBatch.RecordId());

        // [WHEN] Try Send Journal Batch Approval Request.
        asserterror SustApprovalsMgmt.TrySendJournalBatchApprovalRequest(SustainabilityJournalLine);

        // [THEN] An approval request already exists.
        Assert.ExpectedErrorCode(DialogTok);
        Assert.ExpectedError(ApprovalRequestExistsErr);
    end;

    [Test]
    procedure TrySendJournalBatchApprovalRequestWhenOpenLineEntryExists()
    var
        Workflow: Record Workflow;
        SustainabilityJournalBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
        SustApprovalsMgmt: Codeunit "Sust. Approvals Mgmt.";
    begin
        // [SCENARIO 546878] Stan cannot send Approval Request for Journal Batch when another Open Approval Request for Journal Line from the Batch already exists.
        Initialize();

        // [GIVEN] Create a Sustainability Journal Line.
        CreateSustainabilityJournalBatchWithOneJournalLine(SustainabilityJournalBatch, SustainabilityJournalLine);

        // [GIVEN] Workflow is enabled.
        CreateDirectApprovalWorkflow(Workflow);
        EnableWorkflow(Workflow);

        // [GIVEN] Open Approval Request for Sustainability. Journal Line.
        CreateOpenApprovalEntryForCurrentUser(SustainabilityJournalLine.RecordId());

        // [WHEN] Try Send Journal Batch Approval Request.
        asserterror SustApprovalsMgmt.TrySendJournalBatchApprovalRequest(SustainabilityJournalLine);

        // [THEN] Error thrown: An approval request already exists.
        Assert.ExpectedErrorCode(DialogTok);
        Assert.ExpectedError(ApprovalRequestExistsErr);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure TrySendJournalBatchApprovalRequestWhenNoEntryExists()
    var
        Workflow: Record Workflow;
        ApproverUserSetup: Record "User Setup";
        RequestorUserSetup: Record "User Setup";
        ApprovalEntry: Record "Approval Entry";
        SustainabilityJournalBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
        SustApprovalsMgmt: Codeunit "Sust. Approvals Mgmt.";
    begin
        // [SCENARIO 546878] Stan can send Approval Request for Journal Batch when Batch and Line requests do not exist.
        Initialize();

        // [GIVEN] Create a Sustainability Journal Line.
        CreateSustainabilityJournalBatchWithOneJournalLine(SustainabilityJournalBatch, SustainabilityJournalLine);

        // [GIVEN] Workflow is enabled.
        CreateDirectApprovalWorkflow(Workflow);
        EnableWorkflow(Workflow);

        // [GIVEN] Create an Approval Setup.
        CreateApprovalSetup(ApproverUserSetup, RequestorUserSetup);

        // [WHEN] Send Approval Request
        SustApprovalsMgmt.TrySendJournalBatchApprovalRequest(SustainabilityJournalLine);

        // [THEN] Verify Open Approval Entry.
        LibraryDocumentApprovals.GetApprovalEntries(ApprovalEntry, SustainabilityJournalBatch.RecordId());
        VerifyOpenApprovalEntry(ApprovalEntry, ApproverUserSetup, RequestorUserSetup);
    end;


    [Test]
    procedure ApprovalActionsVisibilityOnSustainabilityJournalBatch()
    var
        Workflow: Record Workflow;
        ApproverUserSetup: Record "User Setup";
        RequestorUserSetup: Record "User Setup";
        SustainabilityJournalBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
        SustainabilityJournal: TestPage "Sustainability Journal";
    begin
        // [SCENARIO 546878] Verify approval actions visibility on the Sustainability Journal Batch.
        Initialize();

        // [GIVEN] Create an Approval Setup.
        CreateApprovalSetup(ApproverUserSetup, RequestorUserSetup);

        // [GIVEN] Create a Sustainability Journal Line.
        CreateSustainabilityJournalBatchWithOneJournalLine(SustainabilityJournalBatch, SustainabilityJournalLine);

        // [GIVEN] Create Direct Approval Workflow.
        CreateDirectApprovalWorkflow(Workflow);

        // [GIVEN] Save a transaction.
        Commit();

        // [WHEN] Open Sustainability Journal.
        SustainabilityJournal.OpenEdit();
        SustainabilityJournal."Journal Batch Name".SetValue(SustainabilityJournalBatch.Name);

        // [THEN] Verify Action must not be visible and enabled.
        Assert.IsFalse(SustainabilityJournal.SendApprovalRequestJournalBatch.Enabled(), SendApprovalRequestJournalBatchActionMustBeDisabledLbl);
        Assert.IsFalse(SustainabilityJournal.CancelApprovalRequestJournalBatch.Enabled(), CancelApprovalRequestJournalBatchActionMustBeDisabledLbl);
        Assert.IsFalse(SustainabilityJournal.Approve.Visible(), ApproveActionMustNotBeVisibleLbl);
        Assert.IsFalse(SustainabilityJournal.Reject.Visible(), RejectActionMustNotBeVisibleLbl);
        Assert.IsFalse(SustainabilityJournal.Delegate.Visible(), DelegateActionMustNotBeVisibleLbl);
        SustainabilityJournal.Close();

        // [GIVEN] Enable Workflow.
        EnableWorkflow(Workflow);

        // [GIVEN] Create Open Approval Entry For Current User.
        CreateOpenApprovalEntryForCurrentUser(SustainabilityJournalBatch.RecordId());

        // [GIVEN] Save a transaction.
        Commit();

        // [WHEN] Open Sustainability Journal.
        SustainabilityJournal.OpenEdit();
        SustainabilityJournal."Journal Batch Name".SetValue(SustainabilityJournalBatch.Name);

        // [THEN] Verify Action must be visible and enabled.
        Assert.IsFalse(SustainabilityJournal.SendApprovalRequestJournalBatch.Enabled(), SendApprovalRequestJournalBatchActionMustBeDisabledLbl);
        Assert.IsTrue(SustainabilityJournal.CancelApprovalRequestJournalBatch.Enabled(), CancelApprovalRequestJournalBatchActionMustBeEnabledLbl);
        Assert.IsTrue(SustainabilityJournal.Approve.Visible(), ApproveActionMustBeVisibleLbl);
        Assert.IsTrue(SustainabilityJournal.Reject.Visible(), RejectActionMustBeVisibleLbl);
        Assert.IsTrue(SustainabilityJournal.Delegate.Visible(), DelegateActionMustBeVisibleLbl);
        SustainabilityJournal.Close();
    end;

    local procedure Initialize()
    var
        Workflow: Record Workflow;
        UserSetup: Record "User Setup";
        SustJournalTemplate: Record "Sustainability Jnl. Template";
        NotificationSetup: Record "Notification Setup";
        NotificationEntry: Record "Notification Entry";
        ApprovalEntry: Record "Approval Entry";
        ApprovalCommentLine: Record "Approval Comment Line";
        LibraryApplicationArea: Codeunit "Library - Application Area";
        WorkflowSetup: Codeunit "Workflow Setup";
    begin
        LibraryApplicationArea.EnableFoundationSetup();
        LibrarySustainability.CleanUpBeforeTesting();
        LibraryVariableStorage.Clear();
        Workflow.ModifyAll(Enabled, false, true);
        UserSetup.DeleteAll();
        SustJournalTemplate.DeleteAll();
        NotificationSetup.DeleteAll();
        NotificationEntry.DeleteAll();
        ApprovalEntry.DeleteAll();
        ApprovalCommentLine.DeleteAll();
        WorkflowSetup.InitWorkflow();

        if IsInitialized then
            exit;

        IsInitialized := true;
    end;

    local procedure CreateApprovalSetup(var ApproverUserSetup: Record "User Setup"; var RequestorUserSetup: Record "User Setup")
    var
        NotificationSetup: Record "Notification Setup";
    begin
        LibraryDocumentApprovals.CreateOrFindUserSetup(RequestorUserSetup, CopyStr(UserId, 1, 208));
        LibraryDocumentApprovals.CreateMockupUserSetup(ApproverUserSetup);
        LibraryDocumentApprovals.SetApprover(RequestorUserSetup, ApproverUserSetup);

        LibraryWorkflow.CreateNotificationSetup(NotificationSetup, CopyStr(UserId, 1, 50), NotificationSetup."Notification Type"::Approval, NotificationSetup."Notification Method"::Note);
    end;

    local procedure CreateDirectApprovalWorkflow(var Workflow: Record Workflow)
    begin
        LibraryWorkflow.CopyWorkflowTemplate(Workflow, CopyStr(SustWorkflowEventHandling.SustJournalBatchApprovalWorkflowCode(), 1, 17));
    end;

    local procedure CreateDirectApprovalEnabledWorkflow(var Workflow: Record Workflow)
    begin
        LibraryWorkflow.CreateEnabledWorkflow(Workflow, CopyStr(SustWorkflowEventHandling.SustJournalBatchApprovalWorkflowCode(), 1, 17));
    end;

    local procedure EnableWorkflow(var Workflow: Record Workflow)
    begin
        Workflow.Validate(Enabled, true);
        Workflow.Modify(true);
    end;

    local procedure CreateSustainabilityJournalBatchWithOneJournalLine(var SustainabilityJnlBatch: Record "Sustainability Jnl. Batch"; var SustainabilityJournalLine: Record "Sustainability Jnl. Line")
    var
        SustainabilityAccount: Record "Sustainability Account";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        SustainabilityJnlBatch := SustainabilityJournalMgt.GetASustainabilityJournalBatch(false);
        SustainabilityAccount := CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        CreateSustainabilityJournalLine(SustainabilityJnlBatch, SustainabilityJournalLine, SustainabilityAccount, LibraryRandom.RandIntInRange(10, 20));
    end;

    local procedure CreateSustainabilityJournalBatchWithMultipleJournalLine(var SustainabilityJnlBatch: Record "Sustainability Jnl. Batch")
    var
        SustainabilityAccount: Record "Sustainability Account";
        SustainabilityJournalLine1: Record "Sustainability Jnl. Line";
        SustainabilityJournalLine2: Record "Sustainability Jnl. Line";
        SustainabilityJournalLine3: Record "Sustainability Jnl. Line";
        CategoryCode: Code[20];
        SubcategoryCode: Code[20];
        AccountCode: Code[20];
    begin
        SustainabilityJnlBatch := SustainabilityJournalMgt.GetASustainabilityJournalBatch(false);
        SustainabilityAccount := CreateSustainabilityAccount(AccountCode, CategoryCode, SubcategoryCode, LibraryRandom.RandInt(10));

        CreateSustainabilityJournalLine(SustainabilityJnlBatch, SustainabilityJournalLine1, SustainabilityAccount, LibraryRandom.RandIntInRange(10, 20));
        CreateSustainabilityJournalLine(SustainabilityJnlBatch, SustainabilityJournalLine2, SustainabilityAccount, LibraryRandom.RandIntInRange(30, 40));
        LibraryVariableStorage.Enqueue(SustainabilityJournalLine2."Line No.");
        CreateSustainabilityJournalLine(SustainabilityJnlBatch, SustainabilityJournalLine3, SustainabilityAccount, LibraryRandom.RandIntInRange(50, 60));
    end;

    local procedure CreateSustainabilityJournalLine(SustainabilityJnlBatch: Record "Sustainability Jnl. Batch"; var SustainabilityJournalLine: Record "Sustainability Jnl. Line"; SustainabilityAccount: Record "Sustainability Account"; LineNo: Integer)
    var
        SustainabilitySetup: Record "Sustainability Setup";
    begin
        SustainabilitySetup.Get();

        SustainabilityJournalLine := LibrarySustainability.InsertSustainabilityJournalLine(SustainabilityJnlBatch, SustainabilityAccount, LineNo);
        SustainabilityJournalLine.Validate(Description, SustainabilityAccount."No.");
        SustainabilityJournalLine.Validate("Unit of Measure", SustainabilitySetup."Emission Unit of Measure Code");
        SustainabilityJournalLine.Validate("Custom Amount", LibraryRandom.RandInt(10));
        SustainabilityJournalLine.Modify(true);
    end;

    local procedure CreateSustainabilityAccount(var AccountCode: Code[20]; var CategoryCode: Code[20]; var SubcategoryCode: Code[20]; i: Integer): Record "Sustainability Account"
    begin
        CreateSustainabilitySubcategory(CategoryCode, SubcategoryCode, i);
        AccountCode := StrSubstNo(AccountCodeLbl, i);
        exit(LibrarySustainability.InsertSustainabilityAccount(
          AccountCode, '', CategoryCode, SubcategoryCode, Enum::"Sustainability Account Type"::Posting, '', true));
    end;

    local procedure CreateSustainabilitySubcategory(var CategoryCode: Code[20]; var SubcategoryCode: Code[20]; i: Integer)
    begin
        CategoryCode := StrSubstNo(CategoryCodeLbl, i);
        CreateSustainabilityCategory(CategoryCode, i);

        SubcategoryCode := StrSubstNo(SubcategoryCodeLbl, i);
        LibrarySustainability.InsertAccountSubcategory(CategoryCode, SubcategoryCode, SubcategoryCode, 0, 0, 0, false);
    end;

    local procedure CreateSustainabilityCategory(var CategoryCode: Code[20]; i: Integer)
    begin
        CategoryCode := StrSubstNo(CategoryCodeLbl, i);
        LibrarySustainability.InsertAccountCategory(
            CategoryCode, CategoryCode, Enum::"Emission Scope"::"Water/Waste", Enum::"Calculation Foundation"::Custom,
            false, false, false, CopyStr(LibraryRandom.RandText(10), 1, 100), false);
    end;

    local procedure CreateOpenApprovalEntryForCurrentUser(RecordID: RecordID)
    var
        ApprovalEntry: Record "Approval Entry";
    begin
        ApprovalEntry.Init();
        ApprovalEntry."Document Type" := ApprovalEntry."Document Type"::" ";
        ApprovalEntry."Document No." := '';
        ApprovalEntry."Table ID" := RecordID.TableNo;
        ApprovalEntry."Record ID to Approve" := RecordID;
        ApprovalEntry."Sender ID" := CopyStr(UserId, 1, 50);
        ApprovalEntry."Approver ID" := CopyStr(UserId, 1, 50);
        ApprovalEntry.Status := ApprovalEntry.Status::Open;
        ApprovalEntry."Sequence No." := 1;
        ApprovalEntry.Insert();
    end;

    local procedure SendApprovalRequestForSustainabilityJournal(var SustainabilityJournalLine: Record "Sustainability Jnl. Line")
    var
        SustainabilityJournal: TestPage "Sustainability Journal";
    begin
        SustainabilityJournal.OpenView();
        SustainabilityJournal.GoToRecord(SustainabilityJournalLine);
        SustainabilityJournal.SendApprovalRequestJournalBatch.Invoke();
    end;

    local procedure SendFilteredApprovalRequest(SustJournalBatchName: Code[20])
    var
        SustainabilityJournal: TestPage "Sustainability Journal";
    begin
        SustainabilityJournal.OpenView();
        SustainabilityJournal."Journal Batch Name".SetValue(SustJournalBatchName);
        SustainabilityJournal.FILTER.SetFilter("Line No.", Format(LibraryVariableStorage.DequeueInteger())); // 2nd line
        SustainabilityJournal.SendApprovalRequestJournalBatch.Invoke();
    end;

    local procedure CancelApprovalRequestForSustainabilityJournal(SustJournalBatchName: Code[20])
    var
        SustainabilityJournal: TestPage "Sustainability Journal";
    begin
        SustainabilityJournal.OpenView();
        SustainabilityJournal."Journal Batch Name".SetValue(SustJournalBatchName);
        SustainabilityJournal.CancelApprovalRequestJournalBatch.Invoke();
    end;

    local procedure AssignApprovalEntry(var ApprovalEntry: Record "Approval Entry"; UserSetup: Record "User Setup")
    begin
        ApprovalEntry."Approver ID" := UserSetup."User ID";
        ApprovalEntry."Sender ID" := UserSetup."Approver ID";
        ApprovalEntry.Modify();
    end;

    local procedure Approve(var ApprovalEntry: Record "Approval Entry")
    var
        RequestsToApproveTestPage: TestPage "Requests to Approve";
    begin
        RequestsToApproveTestPage.OpenView();
        RequestsToApproveTestPage.GotoRecord(ApprovalEntry);
        RequestsToApproveTestPage.Approve.Invoke();
    end;

    local procedure Reject(var ApprovalEntry: Record "Approval Entry")
    var
        SustainabilityJournalTestPage: TestPage "Sustainability Journal";
        RequestsToApproveTestPage: TestPage "Requests to Approve";
    begin
        RequestsToApproveTestPage.OpenView();
        RequestsToApproveTestPage.GotoRecord(ApprovalEntry);
        SustainabilityJournalTestPage.Trap();

        RequestsToApproveTestPage.Record.Invoke();
        SustainabilityJournalTestPage.Reject.Invoke();
    end;

    local procedure Delegate(var ApprovalEntry: Record "Approval Entry")
    var
        SustainabilityJournalTestPage: TestPage "Sustainability Journal";
        RequestsToApproveTestPage: TestPage "Requests to Approve";
    begin
        RequestsToApproveTestPage.OpenView();
        RequestsToApproveTestPage.GotoRecord(ApprovalEntry);
        SustainabilityJournalTestPage.Trap();

        RequestsToApproveTestPage.Record.Invoke();
        SustainabilityJournalTestPage.Delegate.Invoke();
    end;

    local procedure RunNotificationEntryDispatcher()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object ID to Run", CODEUNIT::"Notification Entry Dispatcher");
        JobQueueEntry.FindFirst();
        Codeunit.Run(Codeunit::"Notification Entry Dispatcher", JobQueueEntry);
    end;

    local procedure VerifyApprovalEntryIsApproved(ApprovalEntry: Record "Approval Entry")
    begin
        ApprovalEntry.TestField(Status, ApprovalEntry.Status::Approved);
    end;

    local procedure VerifyApprovalEntryIsOpen(ApprovalEntry: Record "Approval Entry")
    begin
        ApprovalEntry.TestField(Status, ApprovalEntry.Status::Open);
    end;

    local procedure VerifyApprovalEntryIsRejected(ApprovalEntry: Record "Approval Entry")
    begin
        ApprovalEntry.TestField(Status, ApprovalEntry.Status::Rejected);
    end;

    local procedure VerifyApprovalEntryIsCancelled(ApprovalEntry: Record "Approval Entry")
    begin
        ApprovalEntry.TestField(Status, ApprovalEntry.Status::Canceled);
    end;

    local procedure VerifyApprovalEntrySenderID(ApprovalEntry: Record "Approval Entry"; SenderId: Code[50])
    begin
        ApprovalEntry.TestField("Sender ID", SenderId);
    end;

    local procedure VerifyApprovalEntryApproverID(ApprovalEntry: Record "Approval Entry"; ApproverId: Code[50])
    begin
        ApprovalEntry.TestField("Approver ID", ApproverId);
    end;

    local procedure VerifyOpenApprovalEntry(var ApprovalEntry: Record "Approval Entry"; ApproverUserSetup: Record "User Setup"; RequestorUserSetup: Record "User Setup")
    begin
        Assert.RecordCount(ApprovalEntry, 1);
        VerifyApprovalEntryIsOpen(ApprovalEntry);
        VerifyApprovalEntrySenderID(ApprovalEntry, RequestorUserSetup."User ID");
        VerifyApprovalEntryApproverID(ApprovalEntry, ApproverUserSetup."User ID");
    end;

    local procedure CheckUserCanCancelTheApprovalRequestForSustainabilityJournalBatch(SustJournalBatchName: Code[20]; CancelActionExpectedEnabled: Boolean)
    var
        SustainabilityJournal: TestPage "Sustainability Journal";
    begin
        SustainabilityJournal.OpenView();
        SustainabilityJournal."Journal Batch Name".SetValue(SustJournalBatchName);
        if CancelActionExpectedEnabled then
            Assert.AreEqual(CancelActionExpectedEnabled, SustainabilityJournal.CancelApprovalRequestJournalBatch.Enabled(), CancelApprovalRequestJournalBatchActionMustBeEnabledLbl)
        else
            Assert.AreEqual(CancelActionExpectedEnabled, SustainabilityJournal.CancelApprovalRequestJournalBatch.Enabled(), CancelApprovalRequestJournalBatchActionMustBeDisabledLbl);
        SustainabilityJournal.Close();
    end;

    local procedure CheckCommentsForDocumentOnSustainabilityJournalPage(SustainabilityJournalBatch: Record "Sustainability Jnl. Batch"; NumberOfExpectedComments: Integer; CommentActionIsVisible: Boolean)
    var
        ApprovalComments: TestPage "Approval Comments";
        SustainabilityJournal: TestPage "Sustainability Journal";
        NumberOfComments: Integer;
    begin
        ApprovalComments.Trap();

        SustainabilityJournal.OpenView();
        SustainabilityJournal."Journal Batch Name".SetValue(SustainabilityJournalBatch.Name);

        if CommentActionIsVisible then
            Assert.AreEqual(CommentActionIsVisible, SustainabilityJournal.Comments.Visible(), ApprovalCommentActionMustBeVisibleLbl)
        else
            Assert.AreEqual(CommentActionIsVisible, SustainabilityJournal.Comments.Visible(), ApprovalCommentActionMustNotBeVisibleLbl);

        if CommentActionIsVisible then begin
            SustainabilityJournal.Comments.Invoke();
            if ApprovalComments.First() then
                repeat
                    NumberOfComments += 1;
                until ApprovalComments.Next();

            Assert.AreEqual(
                NumberOfExpectedComments,
                NumberOfComments,
                StrSubstNo(PageContainsWrongNumberOfCommentsLbl, ApprovalComments.Caption(), NumberOfExpectedComments));

            ApprovalComments.Comment.SetValue(TestCommentLbl + Format(NumberOfExpectedComments));
            ApprovalComments.Next();
            ApprovalComments.Close();
        end;

        SustainabilityJournal.Close();
    end;

    local procedure CheckCommentsForDocumentOnApprovalEntriesPage(ApprovalEntry: Record "Approval Entry"; NumberOfExpectedComments: Integer)
    var
        ApprovalComments: TestPage "Approval Comments";
        ApprovalEntries: TestPage "Approval Entries";
        NumberOfComments: Integer;
    begin
        ApprovalComments.Trap();

        ApprovalEntries.OpenView();
        ApprovalEntries.GotoRecord(ApprovalEntry);

        ApprovalEntries.Comments.Invoke();
        if ApprovalComments.First() then
            repeat
                NumberOfComments += 1;
            until ApprovalComments.Next();

        Assert.AreEqual(
            NumberOfExpectedComments,
            NumberOfComments,
            StrSubstNo(PageContainsWrongNumberOfCommentsLbl, ApprovalComments.Caption(), NumberOfExpectedComments));

        ApprovalComments.Close();
        ApprovalEntries.Close();
    end;

    local procedure CheckCommentsForDocumentOnRequestsToApprovePage(ApprovalEntry: Record "Approval Entry"; NumberOfExpectedComments: Integer)
    var
        ApprovalComments: TestPage "Approval Comments";
        RequestsToApprove: TestPage "Requests to Approve";
        NumberOfComments: Integer;
    begin
        ApprovalComments.Trap();

        RequestsToApprove.OpenView();
        RequestsToApprove.GotoRecord(ApprovalEntry);

        RequestsToApprove.Comments.Invoke();
        if ApprovalComments.First() then
            repeat
                NumberOfComments += 1;
            until ApprovalComments.Next();

        Assert.AreEqual(
            NumberOfExpectedComments,
            NumberOfComments,
            StrSubstNo(PageContainsWrongNumberOfCommentsLbl, ApprovalComments.Caption(), NumberOfExpectedComments));

        ApprovalComments.Close();
        RequestsToApprove.Close();
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;
}