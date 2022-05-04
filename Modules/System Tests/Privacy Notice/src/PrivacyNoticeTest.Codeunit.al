codeunit 132535 "Privacy Notice Test"
{
    Subtype = Test;
    EventSubscriberInstance = Manual;

    var
        LibraryAssert: Codeunit "Library Assert";
        PrivacyNoticeInterface: Codeunit "Privacy Notice";
        PermissionsMock: Codeunit "Permissions Mock";
        AllowShowingPrivacyNotice: Boolean;
        MessageReceived: Text[1024];
        AdminDisabledIntegrationMsg: Label 'Your admin has disabled the integration with %1, please contact your administrator to approve this integration.', Comment = '%1 = a service name such as Microsoft Teams';
        PrivacyPermissionSetAdminTxt: Label 'Priv. Notice - Admin', Locked = true;
        PrivacyPermissionSetViewTxt: Label 'Priv. Notice - View', Locked = true;
        TestPrivacyNoticeNameTxt: Label 'Microsoft Test Privacy Notice', Locked = true;

    [Test]
    procedure ValidateCalcfieldBehaveAsExpected()
    var
        PrivacyNotice: Record "Privacy Notice";
        PrivacyNoticeApproval: Record "Privacy Notice Approval";
        PrivacyNoticeName: Text[50];
        EmptyGuid: Guid;
    begin
        // [GIVEN] A privacy notice and no privacy notice approval
        PrivacyNoticeName := 'ValidateCalcfieldBehaveAsExpected';
        PrivacyNotice.ID := PrivacyNoticeName;
        PrivacyNotice.Insert();

        // [THEN] Calculation of Enabled and Disabled will both be false for admin
        PrivacyNotice.SetRange("User SID Filter", EmptyGuid);
        PrivacyNotice.CalcFields(Enabled, Disabled);
        LibraryAssert.IsFalse(PrivacyNotice.Enabled, 'Privacy notice is enabled for admin.');
        LibraryAssert.IsFalse(PrivacyNotice.Disabled, 'Privacy notice is disabled for admin.');
        
        // [THEN] Calculation of Enabled and Disabled will both be false for current user
        PrivacyNotice.SetRange("User SID Filter", UserSecurityId());
        PrivacyNotice.CalcFields(Enabled, Disabled);
        LibraryAssert.IsFalse(PrivacyNotice.Enabled, 'Privacy notice is enabled for current user.');
        LibraryAssert.IsFalse(PrivacyNotice.Disabled, 'Privacy notice is disabled for current user.');

        // [GIVEN] The privacy notice is approved by the admin
        PrivacyNoticeApproval.ID := PrivacyNoticeName;
        PrivacyNoticeApproval."User SID" := EmptyGuid;
        PrivacyNoticeApproval.Approved := true;
        PrivacyNoticeApproval.Insert();
        
        // [THEN] The privacy notice enabled and disabled flags reflects this for admin
        PrivacyNotice.SetRange("User SID Filter", EmptyGuid);
        PrivacyNotice.CalcFields(Enabled, Disabled);
        LibraryAssert.IsTrue(PrivacyNotice.Enabled, 'Privacy notice should be enabled for admin. - 2');
        LibraryAssert.IsFalse(PrivacyNotice.Disabled, 'Privacy notice is disabled for admin. - 2');
        
        // [THEN] The privacy notice enabled and disabled flags reflects this for current user
        PrivacyNotice.SetRange("User SID Filter", UserSecurityId());
        PrivacyNotice.CalcFields(Enabled, Disabled);
        LibraryAssert.IsFalse(PrivacyNotice.Enabled, 'Privacy notice is enabled for current user. - 2');
        LibraryAssert.IsFalse(PrivacyNotice.Disabled, 'Privacy notice is disabled for current user. - 2');

        // [GIVEN] The privacy notice is rejected by the admin
        PrivacyNoticeApproval.Approved := false;
        PrivacyNoticeApproval.Modify();
        
        // [THEN] The privacy notice enabled and disabled flags reflects this for admin
        PrivacyNotice.SetRange("User SID Filter", EmptyGuid);
        PrivacyNotice.CalcFields(Enabled, Disabled);
        LibraryAssert.IsFalse(PrivacyNotice.Enabled, 'Privacy notice is enabled for admin. - 3');
        LibraryAssert.IsTrue(PrivacyNotice.Disabled, 'Privacy notice should be disabled for admin. - 3');
        
        // [THEN] The privacy notice enabled and disabled flags reflects this for current user
        PrivacyNotice.SetRange("User SID Filter", UserSecurityId());
        PrivacyNotice.CalcFields(Enabled, Disabled);
        LibraryAssert.IsFalse(PrivacyNotice.Enabled, 'Privacy notice is enabled for current user. - 3');
        LibraryAssert.IsFalse(PrivacyNotice.Disabled, 'Privacy notice is disabled for current user. - 3');
        
        // [GIVEN] The privacy notice is approved by the current user and disabled by the admin
        PrivacyNoticeApproval.ID := PrivacyNoticeName;
        PrivacyNoticeApproval."User SID" := UserSecurityId();
        PrivacyNoticeApproval.Approved := true;
        PrivacyNoticeApproval.Insert();
        
        // [THEN] The privacy notice enabled and disabled flags reflects this for admin
        PrivacyNotice.SetRange("User SID Filter", EmptyGuid);
        PrivacyNotice.CalcFields(Enabled, Disabled);
        LibraryAssert.IsFalse(PrivacyNotice.Enabled, 'Privacy notice is enabled for admin. - 4');
        LibraryAssert.IsTrue(PrivacyNotice.Disabled, 'Privacy notice should be disabled for admin. - 4');
        
        // [THEN] The privacy notice enabled and disabled flags reflects this for current user
        PrivacyNotice.SetRange("User SID Filter", UserSecurityId());
        PrivacyNotice.CalcFields(Enabled, Disabled);
        LibraryAssert.IsTrue(PrivacyNotice.Enabled, 'Privacy notice should be enabled for current user. - 4');
        LibraryAssert.IsFalse(PrivacyNotice.Disabled, 'Privacy notice is disabled for current user. - 4');
    end;

    [Test]
    [HandlerFunctions('AcceptPrivacyNotice')]
    procedure AdminApprovesPrivacyNotice()
    var
        PrivacyNotice: Record "Privacy Notice";
        PrivacyNoticeName: Text[50];
        EmptyGuid: Guid;
    begin
        Init();
        PermissionsMock.Set(PrivacyPermissionSetAdminTxt);

        // [GIVEN] A privacy notice
        PrivacyNoticeName := 'AdminApprovesPrivacyNotice';
        PrivacyNoticeInterface.CreatePrivacyNotice(PrivacyNoticeName, PrivacyNoticeName);
        LibraryAssert.AreEqual("Privacy Notice Approval State"::"Not set", PrivacyNoticeInterface.GetPrivacyNoticeApprovalState(PrivacyNoticeName), 'The privacy notice state was set incorrectly');
        
        // [WHEN] A privacy notice is approved through UI
        LibraryAssert.IsTrue(PrivacyNoticeInterface.ConfirmPrivacyNoticeApproval(PrivacyNoticeName), 'The privacy notice was not approved in the UI');
        LibraryAssert.AreEqual("Privacy Notice Approval State"::Agreed, PrivacyNoticeInterface.GetPrivacyNoticeApprovalState(PrivacyNoticeName), 'The privacy notice was not agreed to');

        // [THEN] The privacy notice is approved in the database
        PrivacyNotice.SetAutoCalcFields(Enabled, Disabled);
        PrivacyNotice.SetRange("User SID Filter", EmptyGuid);
        LibraryAssert.IsTrue(PrivacyNotice.Get(PrivacyNoticeName), 'No privacy notice record was created.');
        
        LibraryAssert.IsTrue(PrivacyNotice.Enabled, 'Privacy notice was not approved.');
    end;

    [Test]
    procedure TestConfirmPrivacyNoticeApprovalDoesNotStartAWriteTransaction()
    var
        PrivacyNotice: Record "Privacy Notice";
        PrivacyNoticeTest: Codeunit "Privacy Notice Test";
    begin
        Init();
        Commit(); // Write transaction started above
        PermissionsMock.Set(PrivacyPermissionSetAdminTxt);

        // [GIVEN] The default privacy notice does not exist
        PrivacyNotice.SetRange(ID, TestPrivacyNoticeNameTxt);
        LibraryAssert.RecordIsEmpty(PrivacyNotice);

        // [WHEN] The default privacy notice is automatically created (through event) and does not error out due to a started write transaction
        // [WHEN] The default privacy notice is rejected through event
        BindSubscription(PrivacyNoticeTest);
        LibraryAssert.IsFalse(PrivacyNoticeInterface.ConfirmPrivacyNoticeApproval(TestPrivacyNoticeNameTxt), 'The privacy notice was not approved in the UI');
        UnbindSubscription(PrivacyNoticeTest);

        // [THEN] A privacy notice was created
        LibraryAssert.RecordIsNotEmpty(PrivacyNotice);

        // [THEN] We are not in a write-transaction
        // If we are in a write-transaction, then we cannot run a codeunit but will throw an error with an error message (the codeunit doesn't actually do anything)
        // This is important since ConfirmPrivacyNoticeApproval will open a page which it cannot if we are in a write-tranaction.
        // However opening pages in tests during write-transactions does work
        ClearLastError();
        asserterror begin
            if Codeunit.Run(Codeunit::"Privacy Notice") then;
            Error('');
        end;
        LibraryAssert.AreEqual('', GetLastErrorText(), 'Codeunit could not be run, looks like we started a write-transaction during ConfirmPrivacyNoticeApproval');
    end;
    
    [Test]
    [HandlerFunctions('AcceptPrivacyNotice')]
    procedure AdminApprovesPrivacyNoticeAndDoesNotShowAfterwards()
    var
        PrivacyNotice: Record "Privacy Notice";
        PrivacyNoticeName: Text[50];
        EmptyGuid: Guid;
    begin
        Init();
        PermissionsMock.Set(PrivacyPermissionSetAdminTxt);
        
        // [GIVEN] A privacy notice
        PrivacyNoticeName := 'AdminApprovesPrivacyNoticeAndDoesNotShowAfterwards';
        PrivacyNoticeInterface.CreatePrivacyNotice(PrivacyNoticeName, PrivacyNoticeName);

        // [GIVEN] An approved privacy notice by admin
        LibraryAssert.IsTrue(PrivacyNoticeInterface.ConfirmPrivacyNoticeApproval(PrivacyNoticeName), 'The privacy notice was not approved in the UI');

        PrivacyNotice.SetAutoCalcFields(Enabled, Disabled);
        PrivacyNotice.SetRange("User SID Filter", EmptyGuid);
        LibraryAssert.IsTrue(PrivacyNotice.Get(PrivacyNoticeName), 'No privacy notice record was created.');
        
        LibraryAssert.IsTrue(PrivacyNotice.Enabled, 'Privacy notice was not approved.');

        // [WHEN] The admin triggers the privacy approval again
        // [THEN] The privacy notice dialog does not appear and it has been approved
        AllowShowingPrivacyNotice := false;
        LibraryAssert.IsTrue(PrivacyNoticeInterface.ConfirmPrivacyNoticeApproval(PrivacyNoticeName), 'The privacy notice approval was not saved.');
    end;

    [Test]
    [HandlerFunctions('AcceptPrivacyNotice')]
    procedure NoPrivacyNoticeInEvalCompany()
    var
        PrivacyNoticeName: Text[50];
    begin
        // [Scenario] Confirm that a privacy notice is by default Agreed to in Eval company but not in non-Eval company
        Init();
        PermissionsMock.Set(PrivacyPermissionSetAdminTxt);

        // [GIVEN] A privacy notice
        PrivacyNoticeName := 'NoPrivacyNoticeInEvalCompany';
        PrivacyNoticeInterface.CreatePrivacyNotice(PrivacyNoticeName, PrivacyNoticeName);

        // [GIVEN] We are in an evaluation company
        PermissionsMock.ClearAssignments();
        SetEvaluationCompany(true);
        PermissionsMock.Set(PrivacyPermissionSetAdminTxt);

        // [THEN] The status of the privacy notice is by default Agreed
        LibraryAssert.AreEqual("Privacy Notice Approval State"::Agreed, PrivacyNoticeInterface.GetPrivacyNoticeApprovalState(PrivacyNoticeName), 'The privacy notice was not agreed to');
        
        // [WHEN] A privacy notice checked
        // [THEN] The privacy notice is automatically approved without any UI
        AllowShowingPrivacyNotice := false;
        LibraryAssert.IsTrue(PrivacyNoticeInterface.ConfirmPrivacyNoticeApproval(PrivacyNoticeName), 'The privacy notice was not auto-approved');

        // [GIVEN] We are in a non-evaluation company
        PermissionsMock.ClearAssignments();
        SetEvaluationCompany(false);
        PermissionsMock.Set(PrivacyPermissionSetAdminTxt);
        
        // [THEN] The status of the privacy notice is by default "Not set"
        LibraryAssert.AreEqual("Privacy Notice Approval State"::"Not set", PrivacyNoticeInterface.GetPrivacyNoticeApprovalState(PrivacyNoticeName), 'The privacy notice was not agreed to');
        
        // [WHEN] The privacy notice checked
        // [THEN] The privacy notice is shown to the user (Handler function)
        AllowShowingPrivacyNotice := true;
        LibraryAssert.IsTrue(PrivacyNoticeInterface.ConfirmPrivacyNoticeApproval(PrivacyNoticeName), 'The privacy notice was not approved');
    end;

    [Test]
    [HandlerFunctions('AcceptPrivacyNotice')]
    procedure PrivacyNoticeShownIfDisagreedInEvalCompany()
    var
        PrivacyNoticeName: Text[50];
    begin
        Init();
        PermissionsMock.Set(PrivacyPermissionSetAdminTxt);

        // [GIVEN] A privacy notice that has been disagreed
        PrivacyNoticeName := 'PrivacyNoticeShownIfDisagreedInEvalCompany';
        PrivacyNoticeInterface.CreatePrivacyNotice(PrivacyNoticeName, PrivacyNoticeName);
        PrivacyNoticeInterface.SetApprovalState(PrivacyNoticeName, "Privacy Notice Approval State"::Disagreed);

        // [GIVEN] We are in an evaluation company
        PermissionsMock.ClearAssignments();
        SetEvaluationCompany(true);
        PermissionsMock.Set(PrivacyPermissionSetAdminTxt);

        // [THEN] The status of the privacy notice is disagreed
        LibraryAssert.AreEqual("Privacy Notice Approval State"::Disagreed, PrivacyNoticeInterface.GetPrivacyNoticeApprovalState(PrivacyNoticeName), 'The privacy notice was not agreed to');
        
        // [WHEN] The privacy notice checked
        // [THEN] The privacy notice is shown to the admin since it is currently disagreed to (Handler function)
        LibraryAssert.IsTrue(PrivacyNoticeInterface.ConfirmPrivacyNoticeApproval(PrivacyNoticeName), 'The privacy notice was not approved');
    end;
    
    [Test]
    [HandlerFunctions('AcceptPrivacyNotice')]
    procedure UserApprovesPrivacyNoticeAndDoesNotShowAfterwards()
    var
        PrivacyNotice: Record "Privacy Notice";
        PrivacyNoticeApproval: Record "Privacy Notice Approval";
        PrivacyNoticeName: Text[50];
        EmptyGuid: Guid;
    begin
        Init();
        PermissionsMock.Set(PrivacyPermissionSetViewTxt);
        
        // [GIVEN] A privacy notice
        PrivacyNoticeName := 'UserApprovesPrivacyNoticeAndDoesNotShowAfterwards';
        PrivacyNoticeInterface.CreatePrivacyNotice(PrivacyNoticeName, PrivacyNoticeName);

        // [WHEN] The user approves a privacy notice
        LibraryAssert.IsTrue(PrivacyNoticeInterface.ConfirmPrivacyNoticeApproval(PrivacyNoticeName), 'The privacy notice was not approved in the UI');
        LibraryAssert.AreEqual("Privacy Notice Approval State"::Agreed, PrivacyNoticeInterface.GetPrivacyNoticeApprovalState(PrivacyNoticeName), 'The privacy notice was not agreed to');

        // [THEN] A privacy notice is created
        LibraryAssert.IsTrue(PrivacyNotice.Get(PrivacyNoticeName), 'No privacy notice record was created.');
        
        // [THEN] There are no privacy notice approvals by the admin
        LibraryAssert.IsFalse(PrivacyNoticeApproval.Get(PrivacyNoticeName, EmptyGuid), 'Admin decision was made on this privacy notice!');

        // [THEN] There is an approved privacy notice for the user
        LibraryAssert.IsTrue(PrivacyNoticeApproval.Get(PrivacyNoticeName, UserSecurityId()), 'No privacy notice approval for the user!');
        LibraryAssert.IsTrue(PrivacyNoticeApproval.Approved, 'The user privacy notice was not approved!');

        // [WHEN] The user triggers the privacy approval again
        // [THEN] The privacy notice dialog does not appear and it has been approved
        AllowShowingPrivacyNotice := false;
        LibraryAssert.IsTrue(PrivacyNoticeInterface.ConfirmPrivacyNoticeApproval(PrivacyNoticeName), 'The privacy notice approval was not saved.');
    end;
    
    [Test]
    [HandlerFunctions('RejectPrivacyNotice')]
    procedure AdminRejectsPrivacyNoticeUserIsShownPrivacyNotice()
    var
        PrivacyNotice: Record "Privacy Notice";
        PrivacyNoticeApproval: Record "Privacy Notice Approval";
        PrivacyNoticeName: Text[50];
        EmptyGuid: Guid;
    begin
        Init();
        PermissionsMock.Set(PrivacyPermissionSetAdminTxt);
        
        // [GIVEN] A privacy notice
        PrivacyNoticeName := 'AdminRejectsPrivacyNoticeUserIsShownPrivacyNotice';
        PrivacyNoticeInterface.CreatePrivacyNotice(PrivacyNoticeName, PrivacyNoticeName);

        // [WHEN] The admin rejects the privacy notice from UI
        LibraryAssert.IsFalse(PrivacyNoticeInterface.ConfirmPrivacyNoticeApproval(PrivacyNoticeName), 'The privacy notice was not rejected in the UI');
        LibraryAssert.AreEqual("Privacy Notice Approval State"::"Not set", PrivacyNoticeInterface.GetPrivacyNoticeApprovalState(PrivacyNoticeName), 'A decision was stored for the privacy notice');

        // [THEN] A privacy notice is created
        LibraryAssert.IsTrue(PrivacyNotice.Get(PrivacyNoticeName), 'No privacy notice record was created.');
        
        // [THEN] There are a privacy notice approvals by the admin which is rejected
        LibraryAssert.IsFalse(PrivacyNoticeApproval.Get(PrivacyNoticeName, EmptyGuid), 'Admin privacy notice should not exist!');

        // [WHEN] The user triggers the privacy approval
        // [THEN] The privacy notice dialog does appear
        PermissionsMock.Set(PrivacyPermissionSetViewTxt);
        LibraryAssert.IsFalse(PrivacyNoticeInterface.ConfirmPrivacyNoticeApproval(PrivacyNoticeName), 'The privacy notice request should have been rejected by the user.');
    end;
    
    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure AdminRejectsPrivacyNoticeInListUserReceivesError()
    var
        PrivacyNotice: Record "Privacy Notice";
        PrivacyNoticeApproval: Record "Privacy Notice Approval";
        PrivacyNotices: TestPage "Privacy Notices";
        PrivacyNoticeName: Text[50];
        EmptyGuid: Guid;
    begin
        Init();
        PermissionsMock.Set(PrivacyPermissionSetAdminTxt);
        
        // [GIVEN] A privacy notice
        PrivacyNoticeName := 'AdminRejectsPrivacyNoticeInListUserReceivesError';
        PrivacyNoticeInterface.CreatePrivacyNotice(PrivacyNoticeName, PrivacyNoticeName);
        PrivacyNotice.Get(PrivacyNoticeName);

        // [WHEN] The admin rejects the privacy notice from UI
        PrivacyNotices.OpenEdit();
        PrivacyNotices.GoToRecord(PrivacyNotice);
        PrivacyNotices.Rejected.SetValue(true);
        PrivacyNotices.Close();

        // [THEN] There are a privacy notice approvals by the admin which is rejected
        LibraryAssert.IsTrue(PrivacyNoticeApproval.Get(PrivacyNoticeName, EmptyGuid), 'Admin privacy notice does not exist!');
        LibraryAssert.IsFalse(PrivacyNoticeApproval.Approved, 'The user privacy notice should not have been approved!');

        // [WHEN] The user triggers the privacy approval
        // [THEN] The privacy notice dialog does not appear, a message appears explaining the approval was rejected and returns false
        PermissionsMock.Set(PrivacyPermissionSetViewTxt);
        AllowShowingPrivacyNotice := false;
        LibraryAssert.IsFalse(PrivacyNoticeInterface.ConfirmPrivacyNoticeApproval(PrivacyNoticeName), 'The privacy notice request should have been rejected.');
        LibraryAssert.AreEqual(StrSubstNo(AdminDisabledIntegrationMsg, PrivacyNoticeName), MessageReceived, 'Wrong message was received upon calling privacy approval.');
    end;
    
    [Test]
    [HandlerFunctions('RejectPrivacyNotice')]
    procedure SecondUserToApproveAlsoReceivesPrivacyNotice()
    var
        PrivacyNotice: Record "Privacy Notice";
        PrivacyNoticeApproval: Record "Privacy Notice Approval";
        PrivacyNoticeName: Text[50];
    begin
        Init();

        // [GIVEN] A privacy notice
        PrivacyNoticeName := 'SecondUserToApproveAlsoReceivesPrivacyNotice';
        PrivacyNotice.ID := PrivacyNoticeName;
        PrivacyNotice.Insert();

        // [GIVEN] The privacy notice is approved by a user
        PrivacyNoticeApproval.ID := PrivacyNoticeName;
        PrivacyNoticeApproval."User SID" := CreateGuid();
        PrivacyNoticeApproval.Approved := true;
        PrivacyNoticeApproval.Insert();
        
        // [THEN] No decision has been made on the privacy notice for the current user
        LibraryAssert.AreEqual("Privacy Notice Approval State"::"Not set", PrivacyNoticeInterface.GetPrivacyNoticeApprovalState(PrivacyNoticeName), 'The privacy notice state was set incorrectly');

        // [WHEN] A second user invokes the privacy notice module
        // [THEN] The privacy notice is shown (handler) and the user can reject
        PermissionsMock.Set(PrivacyPermissionSetViewTxt);
        LibraryAssert.IsFalse(PrivacyNoticeInterface.ConfirmPrivacyNoticeApproval(PrivacyNoticeName), 'The privacy notice was not rejected in the UI');
        
        // [THEN] There are a privacy notice approvals by the user is rejected
        LibraryAssert.IsFalse(PrivacyNoticeApproval.Get(PrivacyNoticeName, UserSecurityId()), 'User privacy notice approval should not exist since it was rejected!');
    end;
    
    [Test]
    procedure UserApprovalDoesNotReflectOnPrivacyList()
    var
        PrivacyNotice: Record "Privacy Notice";
        PrivacyNoticeApproval: Record "Privacy Notice Approval";
        PrivacyNotices: TestPage "Privacy Notices";
        PrivacyNoticeApprovals: TestPage "Privacy Notice Approvals";
        PrivacyNoticeName: Text[50];
    begin
        Init();

        // [GIVEN] A privacy notice
        PrivacyNoticeName := 'UserApprovalDoesNotReflectOnPrivacyList';
        PrivacyNotice.ID := PrivacyNoticeName;
        PrivacyNotice."Integration Service Name" := PrivacyNoticeName;
        PrivacyNotice.Insert();

        // [GIVEN] The privacy notice is approved by a user
        PrivacyNoticeApproval.ID := PrivacyNoticeName;
        PrivacyNoticeApproval."User SID" := UserSecurityId();
        PrivacyNoticeApproval.Approved := true;
        PrivacyNoticeApproval.Insert();

        // [WHEN] The privacy list is opened
        // [THEN] The privacy notice has not been approved
        PrivacyNotices.Trap();
        Page.Run(Page::"Privacy Notices");
        PrivacyNotices.GoToRecord(PrivacyNotice);
        LibraryAssert.AreEqual(PrivacyNoticeName, PrivacyNotices.IntegrationServiceName.Value, 'Wrong integration service name');
        LibraryAssert.IsFalse(PrivacyNotices.Accepted.AsBoolean(), 'Privacy notice should not have been admin approved!');
        PrivacyNotices.Close();
        
        // [WHEN] The privacy approval list is opened
        // [THEN] The privacy notice has been approved by the current user
        PrivacyNoticeApprovals.Trap();
        Page.Run(Page::"Privacy Notice Approvals");
        PrivacyNoticeApprovals.GoToRecord(PrivacyNoticeApproval);
        LibraryAssert.AreEqual(PrivacyNoticeName, PrivacyNoticeApprovals.IntegrationServiceName.Value, 'Wrong integration service name on approvals page');
        LibraryAssert.IsTrue(PrivacyNoticeApprovals.Accepted.AsBoolean(), 'Privacy notice approval should have been approved!');
    end;
    
    [Test]
    procedure UserRejectAdminApprovesUserIsAutoApproved()
    var
        PrivacyNoticeApproval: Record "Privacy Notice Approval";
        PrivacyNoticeName: Text[50];
        EmptyGuid: Guid;
    begin
        Init();
        
        // [GIVEN] A privacy notice
        PrivacyNoticeName := 'UserRejectAdminApprovesUserIsAutoApproved';
        PrivacyNoticeInterface.CreatePrivacyNotice(PrivacyNoticeName, PrivacyNoticeName);

        // [GIVEN] The privacy notice is rejected by the current user
        PrivacyNoticeApproval.ID := PrivacyNoticeName;
        PrivacyNoticeApproval."User SID" := UserSecurityId();
        PrivacyNoticeApproval.Approved := false;
        PrivacyNoticeApproval.Insert();

        // [GIVEN] The privacy notice is accepted by the admin
        PrivacyNoticeApproval."User SID" := EmptyGuid;
        PrivacyNoticeApproval.Approved := true;
        PrivacyNoticeApproval.Insert();

        // [WHEN] A normal user invokes the privacy notice approval
        // [THEN] No Privacy Notice is shown
        // [THEN] The Privacy Notice is automatically approved (admin decision overrides)
        PermissionsMock.Set(PrivacyPermissionSetViewTxt);
        LibraryAssert.IsTrue(PrivacyNoticeInterface.ConfirmPrivacyNoticeApproval(PrivacyNoticeName), 'The privacy notice was not auto-approved');
    end;
    
    [Test]
    procedure NormalUsersCannotApproveForAllThroughPrivacyNoticesList()
    var
        PrivacyNoticeApproval: Record "Privacy Notice Approval";
        PrivacyNoticeName: Text[50];
        EmptyGuid: Guid;
    begin
        Init();
        
        // [GIVEN] A privacy notice
        PrivacyNoticeName := 'NormalUsersCannotApproveForAllThroughPrivacyNotice';
        PrivacyNoticeInterface.CreatePrivacyNotice(PrivacyNoticeName, PrivacyNoticeName);

        // [GIVEN] The privacy notice is rejected by the current user
        PrivacyNoticeApproval.ID := PrivacyNoticeName;
        PrivacyNoticeApproval."User SID" := UserSecurityId();
        PrivacyNoticeApproval.Approved := false;
        PrivacyNoticeApproval.Insert();

        // [GIVEN] The privacy notice is accepted by the admin
        PrivacyNoticeApproval."User SID" := EmptyGuid;
        PrivacyNoticeApproval.Approved := true;
        PrivacyNoticeApproval.Insert();

        // [WHEN] A normal user invokes the privacy notice approval
        // [THEN] No Privacy Notice is shown
        // [THEN] The Privacy Notice is automatically approved (admin decision overrides)
        PermissionsMock.Set(PrivacyPermissionSetViewTxt);
        LibraryAssert.IsTrue(PrivacyNoticeInterface.ConfirmPrivacyNoticeApproval(PrivacyNoticeName), 'The privacy notice was not auto-approved');
    end;

    local procedure Init()
    begin
        SetEvaluationCompany(false);
        AllowShowingPrivacyNotice := true;
        Clear(MessageReceived);
    end;

    local procedure SetEvaluationCompany(EvaluationCompany: Boolean)
    var
        Company: Record Company;
    begin
        Company.Get(CompanyName());
        Company."Evaluation Company" := EvaluationCompany;
        Company.Modify();
    end;

    [ModalPageHandler]
    procedure AcceptPrivacyNotice(var PrivacyNotice: TestPage "Privacy Notice")
    begin
        LibraryAssert.IsTrue(AllowShowingPrivacyNotice, 'Accept privacy notice ModalPageHandler should not have been called!');
        PrivacyNotice.Accept.Invoke();
    end;

    [ModalPageHandler]
    procedure RejectPrivacyNotice(var PrivacyNotice: TestPage "Privacy Notice")
    begin
        LibraryAssert.IsTrue(AllowShowingPrivacyNotice, 'Reject privacy notice ModalPageHandler should not have been called!');
        PrivacyNotice.Reject.Invoke();
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
        MessageReceived := Message;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Privacy Notice", 'OnRegisterPrivacyNotices', '', false, false)]
    local procedure OnRegisterPrivacyNotices(var TempPrivacyNotice: Record "Privacy Notice" temporary)
    begin
        TempPrivacyNotice.Init();
        TempPrivacyNotice.ID := TestPrivacyNoticeNameTxt;
        TempPrivacyNotice."Integration Service Name" := TestPrivacyNoticeNameTxt;
        TempPrivacyNotice.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Privacy Notice", 'OnBeforeShowPrivacyNotice', '', false, false)]
    local procedure OnBeforeShowPrivacyNotice(PrivacyNotice: Record "Privacy Notice"; var Handled: Boolean)
    begin
        Handled := true;
    end;

}

