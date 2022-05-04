// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132605 "Checklist Banner Test"
{
    Subtype = Test;
    EventSubscriberInstance = Manual;
    Permissions = tabledata "All Profile" = r,
                tabledata "User Personalization" = rm;

    var
        Any: Codeunit Any;
        Assert: Codeunit "Library Assert";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        PermissionsMock: Codeunit "Permissions Mock";
        ProfileID1: Code[30];
        ProfileID2: Code[30];
        CodeunitRunSuccessfully: Boolean;
        ReportRunSuccessfully: Boolean;
        FieldIncorrectLbl: Label 'The %1 is incorrect for the %2 checklist item.', Locked = true;

    trigger OnRun()
    begin
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('ChecklistBannerHandler,AssistedSetupWizardHandler,HyperlinkHandler,RequestPageHandler')]
    procedure TestChecklistBanner()
    var
        GuidedExperienceItem1: Record "Guided Experience Item";
        GuidedExperienceItem2: Record "Guided Experience Item";
        GuidedExperienceItem3: Record "Guided Experience Item";
        GuidedExperienceItem4: Record "Guided Experience Item";
        GuidedExperienceItem5: Record "Guided Experience Item";
        TempProfile1AllProfile: Record "All Profile" temporary;
        TempProfile2AllProfile: Record "All Profile" temporary;
        TempProfiles1And2AllProfile: Record "All Profile" temporary;
        ChecklistBannerTest: Codeunit "Checklist Banner Test";
        Checklist: Codeunit Checklist;
        ChecklistBannerContainer: Page "Checklist Banner Container";
        GuidedExperienceType: Enum "Guided Experience Type";
        ObjectType: ObjectType;
        Link1: Text[250];
        Link2: Text[250];
    begin
        BindSubscription(ChecklistBannerTest);
        Initialize(true);

        // [GIVEN] Lists of profiles
        AddRoleToList(TempProfile1AllProfile, ProfileID1);
        AddRoleToList(TempProfile2AllProfile, ProfileID2);
        AddRoleToList(TempProfiles1And2AllProfile, ProfileID1);
        AddRoleToList(TempProfiles1And2AllProfile, ProfileID2);

        // [GIVEN] The current company type is non-evaluation
        SetCompanyTypeToEvaluation(false);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] 2 links
        GetLink(Link1);
        GetLink(Link2);

        // [GIVEN] A few guided experience items
        InsertGuidedExperienceItem(GuidedExperienceItem1, GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"Assisted Setup Wizard", '');
        InsertGuidedExperienceItem(GuidedExperienceItem2, GuidedExperienceType::"Manual Setup", ObjectType::Codeunit, Codeunit::"Checklist Test Codeunit", '');
        InsertGuidedExperienceItem(GuidedExperienceItem3, GuidedExperienceType::Learn, ObjectType::MenuSuite, 0, Link1);
        InsertGuidedExperienceItem(GuidedExperienceItem4, GuidedExperienceType::"Manual Setup", ObjectType::Report, Report::"Checklist Test Report", '');
        InsertGuidedExperienceItem(GuidedExperienceItem5, GuidedExperienceType::Learn, ObjectType::MenuSuite, 0, Link2);

        // [GIVEN] Checklist items for the guided experience items
        Checklist.Insert(GuidedExperienceItem1."Guided Experience Type", GetObjectType(GuidedExperienceItem1."Object Type to Run"),
            GuidedExperienceItem1."Object ID to Run", 100, TempProfile1AllProfile, true);
        Checklist.Insert(GuidedExperienceItem2."Guided Experience Type", GetObjectType(GuidedExperienceItem2."Object Type to Run"),
            GuidedExperienceItem2."Object ID to Run", 200, TempProfiles1And2AllProfile, false);
        Checklist.Insert(GuidedExperienceItem3."Guided Experience Type", GuidedExperienceItem3.Link, 300, TempProfiles1And2AllProfile, true);
        Checklist.Insert(GuidedExperienceItem4."Guided Experience Type", GetObjectType(GuidedExperienceItem4."Object Type to Run"),
            GuidedExperienceItem4."Object ID to Run", 400, TempProfile1AllProfile, false);
        Checklist.Insert(GuidedExperienceItem5."Guided Experience Type", GuidedExperienceItem5.Link, 500, TempProfile2AllProfile, true);

        // [GIVEN] The current profile is set to ProfileID1
        SetCurrentProfile(ProfileID1);

        // [THEN] Verify how the change of profiles affects the user checklist status records
        CheckChangeOfProfiles();

        // [GIVEN] Some variables are enqueued for the verification process
        EnqueueGuidedExperienceItemFieldsInVariableStorage(GuidedExperienceItem1);
        EnqueueGuidedExperienceItemFieldsInVariableStorage(GuidedExperienceItem2);
        EnqueueGuidedExperienceItemFieldsInVariableStorage(GuidedExperienceItem3);
        LibraryVariableStorage.Enqueue(GuidedExperienceItem3.Link);
        EnqueueGuidedExperienceItemFieldsInVariableStorage(GuidedExperienceItem4);

        EnqueueGuidedExperienceItemFieldsInVariableStorage(GuidedExperienceItem5);
        LibraryVariableStorage.Enqueue(GuidedExperienceItem5.Link);
        //EnqueueGuidedExperienceItemFieldsInVariableStorage(GuidedExperienceItem3);
        //EnqueueGuidedExperienceItemFieldsInVariableStorage(GuidedExperienceItem5);

        // [WHEN] The checklist banner is run
        ChecklistBannerContainer.Run();

        // [THEN] Most of the verifications and the rest of the scenario for the first profile
        // are performed in the checklist banner page handler

        // [THEN] The codeunit corresponding to the second checklist item was run successfully
        Assert.IsTrue(ChecklistBannerTest.GetCodeunitRunSuccessfully(),
            'The codeunit corresponding to the second checklist item was not run successfully.');

        // [THEN] The report corresponding to the fourth checklist item was run successfully
        Assert.IsTrue(ChecklistBannerTest.GetReportRunSuccessfully(),
            'The report corresponding to the fourth checklist item was not run successfully.');

        UnbindSubscription(ChecklistBannerTest);
    end;

    local procedure InsertProfile(var ProfileID: Code[30])
    var
        AllProfile: Record "All Profile";
        ModuleInfo: ModuleInfo;
    begin
        ProfileID := CopyStr(Any.AlphanumericText(30), 1, MaxStrLen(ProfileID));
        AllProfile."Profile ID" := ProfileID;
        AllProfile.Scope := AllProfile.Scope::Tenant;
        AllProfile."App ID" := ModuleInfo.Id();
        AllProfile.Insert();
    end;

    local procedure Initialize(ShouldInsertProfiles: Boolean)
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        ChecklistItem: Record "Checklist Item";
        ChecklistItemRole: Record "Checklist Item Role";
        ChecklistItemUser: Record "Checklist Item User";
        UserChecklistStatus: Record "User Checklist Status";
    begin
        if ShouldInsertProfiles then begin
            InsertProfile(ProfileID1);
            InsertProfile(ProfileID2);
        end;

        GuidedExperienceItem.DeleteAll();
        ChecklistItem.DeleteAll();
        ChecklistItemRole.DeleteAll();
        ChecklistItemUser.DeleteAll();
        UserChecklistStatus.DeleteAll();

        LibraryVariableStorage.Clear();
    end;

    local procedure AddRoleToList(var TempAllProfile: Record "All Profile" temporary; ProfileID: Code[30])
    var
        AllProfile: Record "All Profile";
    begin
        AllProfile.SetRange("Profile ID", ProfileID);
        if AllProfile.FindFirst() then begin
            TempAllProfile.TransferFields(AllProfile);
            TempAllProfile.Insert();
        end;
    end;

    local procedure GetLink(var Link: Text[250])
    begin
        Link := CopyStr(Any.AlphanumericText(250), 1, 250);
    end;

    local procedure InsertGuidedExperienceItem(var GuidedExperienceItem: Record "Guided Experience Item"; GuidedExperienceType: Enum "Guided Experience Type"; ObjectType: ObjectType; ObjectId: Integer; Link: Text[250])
    var
        GuidedExperience: Codeunit "Guided Experience";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        ManualSetupCategory: Enum "Manual Setup Category";
        Title: Text[2048];
        ShortTitle: Text[50];
        Description: Text[1024];
        ExpectedDuration: Integer;
    begin
        Title := CopyStr(Any.AlphanumericText(MaxStrLen(GuidedExperienceItem.Title)), 1, MaxStrLen(GuidedExperienceItem.Title));
        ShortTitle := CopyStr(Any.AlphanumericText(MaxStrLen(GuidedExperienceItem."Short Title")), 1, MaxStrLen(GuidedExperienceItem."Short Title"));
        Description := CopyStr(Any.AlphanumericText(MaxStrLen(GuidedExperienceItem.Description)), 1, MaxStrLen(GuidedExperienceItem.Description));
        ExpectedDuration := Any.IntegerInRange(100);

        case GuidedExperienceType of
            GuidedExperienceType::"Assisted Setup":
                GuidedExperience.InsertAssistedSetup(Title, ShortTitle, Description, ExpectedDuration,
                    ObjectType, ObjectId, AssistedSetupGroup::Uncategorized, '', VideoCategory::Uncategorized, '');
            GuidedExperienceType::"Manual Setup":
                GuidedExperience.InsertManualSetup(Title, ShortTitle, Description, ExpectedDuration,
                    ObjectType, ObjectId, ManualSetupCategory::Uncategorized, '');
            GuidedExperienceType::Learn:
                GuidedExperience.InsertLearnLink(Title, ShortTitle, Description, ExpectedDuration, Link);
        end;

        GetGuidedExperienceItem(GuidedExperienceItem, GuidedExperienceType, ObjectType, ObjectId, Link);
    end;

    local procedure GetGuidedExperienceItem(var GuidedExperienceItem: Record "Guided Experience Item"; GuidedExperienceType: Enum "Guided Experience Type"; ObjectType: ObjectType; ObjectId: Integer; Link: Text[250])
    var
        GuidedExperienceImpl: Codeunit "Guided Experience Impl.";
        SpotlightTourType: Enum "Spotlight Tour Type";
    begin
        GuidedExperienceImpl.FilterGuidedExperienceItem(GuidedExperienceItem, GuidedExperienceType, ObjectType, ObjectId, Link, '', SpotlightTourType::None);
        if GuidedExperienceItem.FindFirst() then;
    end;

    local procedure GetObjectType(ObjectTypeToRun: Enum "Guided Experience Object Type"): ObjectType
    var
        GuidedExperienceImpl: Codeunit "Guided Experience Impl.";
    begin
        exit(GuidedExperienceImpl.GetObjectType(ObjectTypeToRun));
    end;

    local procedure SetCompanyTypeToEvaluation(Evaluation: Boolean)
    var
        Company: Record Company;
    begin
        Company.Get(CompanyName());
        Company."Evaluation Company" := Evaluation;
        Company.Modify();
    end;

    local procedure SetCurrentProfile(ProfileID: Code[30])
    var
        UserPersonalization: Record "User Personalization";
    begin
        UserPersonalization.Get(UserSecurityId());

        UserPersonalization."Profile ID" := ProfileID;
        UserPersonalization.Modify();
    end;

    local procedure CheckChangeOfProfiles()
    var
        SystemActionTriggers: Codeunit "System Action Triggers";
        ChecklistStatus: Enum "Checklist Status";
        PartID: Integer;
    begin
        // [WHEN] Calling GetRoleCenterBannerPartID (this will trigger the event subscriber 
        // that switches the role for the user checklist status and returns the ID of the checklist banner)
        SystemActionTriggers.GetRoleCenterBannerPartID(PartID);

        // [THEN] The return value of the event is the ID of the checklist banner page
        Assert.AreEqual(Page::"Checklist Banner", PartID, 'The return value of GetRoleCenterBannerPartID is wrong.');

        // [THEN] A user checklist status record will be created for the first profile
        VerifyUserChecklistStatus(ProfileID1, ChecklistStatus::"Not Started", true, true);

        // [GIVEN] The current profile is set to ProfileID2
        SetCurrentProfile(ProfileID2);

        // [WHEN] Calling GetRoleCenterBannerPartID again
        SystemActionTriggers.GetRoleCenterBannerPartID(PartID);

        // [THEN] The user checklist status for the first profile will be modified 
        // to reflect that this is no longer the active profile
        VerifyUserChecklistStatus(ProfileID1, ChecklistStatus::"Not Started", true, false);

        // [THEN] A new user checklist status will be created for the second profile
        VerifyUserChecklistStatus(ProfileID2, ChecklistStatus::"Not Started", true, true);

        // [GIVEN] The current profile is set back to ProfileID1
        SetCurrentProfile(ProfileID1);

        // [GIVEN] GetRoleCenterBannerPartID is called again to update the user 
        // checklist statuses for the 2 profiles
        SystemActionTriggers.GetRoleCenterBannerPartID(PartID);
    end;

    local procedure VerifyUserChecklistStatus(ProfileID: Code[30]; ChecklistStatus: Enum "Checklist Status"; IsVisible: Boolean; IsCurrentRoleCenter: Boolean)
    var
        UserChecklistStatus: Record "User Checklist Status";
    begin
        UserChecklistStatus.Get(UserId(), ProfileID);
        Assert.AreEqual(IsVisible, UserChecklistStatus."Is Visible", 'The banner''s visibility flag is set incorrectly.');
        Assert.AreEqual(ChecklistStatus, UserChecklistStatus."Checklist Status", 'The checklist status is incorrect.');
        Assert.AreEqual(IsCurrentRoleCenter, UserChecklistStatus."Is Current Role Center",
            'The Is Current Role Center flag is set incorrectly.');
    end;

    local procedure EnqueueGuidedExperienceItemFieldsInVariableStorage(GuidedExperienceItem: Record "Guided Experience Item")
    begin
        LibraryVariableStorage.Enqueue(GuidedExperienceItem."Short Title");
        LibraryVariableStorage.Enqueue(GuidedExperienceItem.Title);
        LibraryVariableStorage.Enqueue(GuidedExperienceItem.Description);
        LibraryVariableStorage.Enqueue(GetExpectedDurationText(GuidedExperienceItem."Expected Duration" * 60000));
    end;

    local procedure GetExpectedDurationText(ExpectedDuration: Duration): Text
    begin
        exit(Format(ExpectedDuration));
    end;

    procedure GetCodeunitRunSuccessfully(): Boolean
    begin
        exit(CodeunitRunSuccessfully);
    end;

    procedure GetReportRunSuccessfully(): Boolean
    begin
        exit(ReportRunSuccessfully);
    end;

    [PageHandler]
    [Scope('OnPrem')]
    procedure ChecklistBannerHandler(var ChecklistBannerContainer: TestPage "Checklist Banner Container")
    begin
        WelcomeStepForTheFirstProfile(ChecklistBannerContainer);
        GetStartedForFirstProfile(ChecklistBannerContainer);
        FirstChecklistItemForFirstProfile(ChecklistBannerContainer);
        SecondChecklistItemForTheFirstProfile(ChecklistBannerContainer);
        ThirdChecklistItemForTheFirstProfile(ChecklistBannerContainer);
        LastChecklistItemForTheFirstProfile(ChecklistBannerContainer);
        BackToChecklistForTheFirstProfile(ChecklistBannerContainer);
        GotItForTheFirstProfile(ChecklistBannerContainer);

        SwitchToSecondProfile(ChecklistBannerContainer);
        WelcomeStepForTheSecondProfile(ChecklistBannerContainer);
        GetStartedForSecondProfile(ChecklistBannerContainer);
        CurrentChecklistItemForTheSecondProfile(ChecklistBannerContainer);
        //SecondChecklistItemForTheSecondProfile(ChecklistBannerContainer);
    end;

    local procedure WelcomeStepForTheFirstProfile(var ChecklistBannerContainer: TestPage "Checklist Banner Container")
    var
        ChecklistStatus: Enum "Checklist Status";
    begin
        // [WHEN] Running the checklist banner page for the first time for the first profile
        // [THEN] The user checklist status for the first profile should reflect the correct state of the banner
        VerifyUserChecklistStatus(ProfileID1, ChecklistStatus::"Not Started", true, true);

        // [THEN] The labels and the visibility of the banner buttons are set correctly for the welcome step
        VerifyBannerTextsAndButtonsForWelcomeStep(ChecklistBannerContainer);
    end;

    local procedure GetStartedForFirstProfile(var ChecklistBannerContainer: TestPage "Checklist Banner Container")
    var
        ChecklistStatus: Enum "Checklist Status";
    begin
        // [WHEN] Clicking the Get started button
        ChecklistBannerContainer.ChecklistBanner.StartSetup.Invoke();

        // [THEN] The labels and the visibility of the banner buttons are set correctly for 0 to 50% completion
        VerifyBannerTextsAndButtonsFor0To50Completion(ChecklistBannerContainer);

        // [THEN] The user checklist status gets updated to "In progress" and the banner is still visible
        VerifyUserChecklistStatus(ProfileID1, ChecklistStatus::"In progress", true, true);
    end;

    local procedure FirstChecklistItemForFirstProfile(var ChecklistBannerContainer: TestPage "Checklist Banner Container")
    begin
        // [THEN] The first checklist item displays the correct information
        VerifyChecklistItemFields(ChecklistBannerContainer, 'first', false);

        // [WHEN] Running the first checklist item
        ChecklistBannerContainer.ChecklistBanner.TaskStart.Invoke();

        // [THEN] The assisted setup wizard gets displayed (see the assisted setup wizard handler)

        // [WHEN] The finish button is clicked on the assisted setup wizard and the 
        // guided experience item gets marked as completed (see the assisted setup wizard handler)

        // [THEN] The checklist item gets marked as completed automatically 
        VerifyCompletionStatusForChecklistItem(ChecklistBannerContainer, 'first', true);

        // [THEN] The status of the first checklist item is completed
        Assert.AreEqual('You completed this step', ChecklistBannerContainer.ChecklistBanner.TaskStatusText.Value(),
            'The status of the first checklist item is incorrect after completion.');

        // [THEN] The labels and the visibility of the banner buttons remain unchanged, as the completion percentage is 25%
        VerifyBannerTextsAndButtonsFor0To50Completion(ChecklistBannerContainer);
    end;

    local procedure SecondChecklistItemForTheFirstProfile(var ChecklistBannerContainer: TestPage "Checklist Banner Container")
    begin
        // [WHEN] Going to the next row of the checklist
        ChecklistBannerContainer.ChecklistBanner.Next();

        // [THEN] The second checklist item displays the correct information
        VerifyChecklistItemFields(ChecklistBannerContainer, 'second', false);

        // [THEN] The labels and the visibility of the banner buttons remain unchanged
        VerifyBannerTextsAndButtonsFor0To50Completion(ChecklistBannerContainer);

        // [WHEN] Running the second checklist item (a codeunit)
        ChecklistBannerContainer.ChecklistBanner.TaskStart.Invoke();

        // [THEN] The codeunit has run successfully
        // This verification is performed in the test method

        // [THEN] The checklist item does not get marked as completed automatically, 
        // since it is of type manual setup
        VerifyCompletionStatusForChecklistItem(ChecklistBannerContainer, 'second', false);

        // [WHEN] Marking the checklist item as completed
        ChecklistBannerContainer.ChecklistBanner.TaskMarkAsCompleted.SetValue(true);

        // [THEN] The checklist item gets marked as completed
        VerifyCompletionStatusForChecklistItem(ChecklistBannerContainer, 'second', true);

        // [THEN] The labels and visibility of the banner buttons gets updated, as the completion progress increases to 50%
        VerifyBannerTextsAndButtonsFor50to75Completion(ChecklistBannerContainer);
    end;

    local procedure ThirdChecklistItemForTheFirstProfile(var ChecklistBannerContainer: TestPage "Checklist Banner Container")
    begin
        // [WHEN] Going to the next row of the checklist
        ChecklistBannerContainer.ChecklistBanner.Next();

        // [THEN] The third checklist item displays the correct information
        VerifyChecklistItemFields(ChecklistBannerContainer, 'third', false);

        // [WHEN] Running the third checklist item (a link)
        ChecklistBannerContainer.ChecklistBanner.TaskStart.Invoke();

        // [THEN] The checklist item gets marked as completed automatically 
        VerifyCompletionStatusForChecklistItem(ChecklistBannerContainer, 'third', true);

        // [THEN] The labels and visibility of the banner buttons get updated, as the completion progress increases to 75%
        VerifyBannerTextsAndButtonsFor75to100Completion(ChecklistBannerContainer);
    end;

    local procedure LastChecklistItemForTheFirstProfile(var ChecklistBannerContainer: TestPage "Checklist Banner Container")
    var
        ChecklistStatus: Enum "Checklist Status";
    begin
        // [WHEN] Going to the next row of the checklist
        ChecklistBannerContainer.ChecklistBanner.Next();

        // [THEN] The fourth checklist item displays the correct information
        VerifyChecklistItemFields(ChecklistBannerContainer, 'fourth', false);

        // [WHEN] Running the fourth checklist item (a report)
        ChecklistBannerContainer.ChecklistBanner.TaskStart.Invoke();

        // [THEN] The report has run successfully
        // This verification is performed in the test method

        // [WHEN] Marking the checklist item as completed
        ChecklistBannerContainer.ChecklistBanner.TaskMarkAsCompleted.SetValue(true);

        // [THEN] The labels and button visibilities get updated, as the completion progress reaches 100%
        VerifyBannerTextsAndButtonsFor100Completion(ChecklistBannerContainer, false);

        // [THEN] The user checklist status gets updated to completed, but the banner is still visible
        VerifyUserChecklistStatus(ProfileID1, ChecklistStatus::Completed, true, true);
    end;

    local procedure BackToChecklistForTheFirstProfile(var ChecklistBannerContainer: TestPage "Checklist Banner Container")
    var
        ChecklistStatus: Enum "Checklist Status";
    begin
        // [WHEN] Clicking Back to checklist
        ChecklistBannerContainer.ChecklistBanner.BackToChecklist.Invoke();

        // [THEN] The labels and visibility of the banner buttons are correct
        VerifyBannerTextsAndButtonsFor100Completion(ChecklistBannerContainer, true);

        // [THEN] The checklist status should go back to "In progress"
        VerifyUserChecklistStatus(ProfileID1, ChecklistStatus::"In progress", true, true);

        // [THEN] The Revisit button is visible on the checklist
        Assert.IsTrue(ChecklistBannerContainer.ChecklistBanner.TaskStartOver.Visible(),
           'The Revisit button should be visible.');
    end;

    local procedure GotItForTheFirstProfile(var ChecklistBannerContainer: TestPage "Checklist Banner Container")
    var
        ChecklistStatus: Enum "Checklist Status";
    begin
        // [WHEN] Clicking Got it
        ChecklistBannerContainer.ChecklistBanner.CloseSetup.Invoke();

        // [THEN] The banner gets hidden 
        VerifyUserChecklistStatus(ProfileID1, ChecklistStatus::"In progress", false, true);
    end;

    local procedure SwitchToSecondProfile(var ChecklistBannerContainer: TestPage "Checklist Banner Container")
    var
        ChecklistBanner: Codeunit "Checklist Banner";
        PartID: Integer;
    begin
        // [GIVEN] The current profile is switched to ProfileID2
        SetCurrentProfile(ProfileID2);

        // [GIVEN] The event subscriber to GetRoleCenterBannerPartID is invoked 
        // in order to update the user checklist statuses for the 2 profiles
        ChecklistBanner.GetRoleCenterBannerPartID(PartID);

        // [WHEN] The checklist banner is closed and reopened to reflect the change in profiles
        ChecklistBannerContainer.Close();
        ChecklistBannerContainer.OpenView();
    end;

    local procedure WelcomeStepForTheSecondProfile(var ChecklistBannerContainer: TestPage "Checklist Banner Container")
    begin
        // [THEN] The labels and the visibility of the banner buttons are set correctly for the welcome step
        VerifyBannerTextsAndButtonsForWelcomeStep(ChecklistBannerContainer);
    end;

    local procedure GetStartedForSecondProfile(var ChecklistBannerContainer: TestPage "Checklist Banner Container")
    var
        ChecklistStatus: Enum "Checklist Status";
    begin
        // [WHEN] Clicking the Get started button
        ChecklistBannerContainer.ChecklistBanner.StartSetup.Invoke();

        // [THEN] The labels and the visibility of the banner buttons are set for 50 to 75% completion, 
        // since two of the three checklist items have already been completed using the first profile
        VerifyBannerTextsAndButtonsFor50to75Completion(ChecklistBannerContainer);

        // [THEN] The user checklist status gets updated to "In progress" and the banner is still visible
        VerifyUserChecklistStatus(ProfileID2, ChecklistStatus::"In progress", true, true);
    end;

    local procedure CurrentChecklistItemForTheSecondProfile(var ChecklistBannerContainer: TestPage "Checklist Banner Container")
    var
        ChecklistStatus: Enum "Checklist Status";
    begin
        // [THEN] The current checklist item for the second profile is the last checklist item, 
        // since it's the only one that has not been completed using the first profiles
        VerifyChecklistItemFields(ChecklistBannerContainer, 'last', false);

        // [WHEN] Invoking Skip on the checklist item
        ChecklistBannerContainer.ChecklistBanner.TaskSkip.Invoke();

        // [THEN] The user checklist status gets updated to Completed
        VerifyUserChecklistStatus(ProfileID2, ChecklistStatus::Completed, true, true);

        // [THEN] The labels and the visibility of the banner buttons are set correctly 
        // for 100% completion and the checklist is hidden
        VerifyBannerTextsAndButtonsFor100Completion(ChecklistBannerContainer, false);

        // [WHEN] Invoking Back to checklist
        ChecklistBannerContainer.ChecklistBanner.BackToChecklist.Invoke();

        // [THEN] The labels are still set for 100% completion, but the checklist is now visible
        VerifyBannerTextsAndButtonsFor100Completion(ChecklistBannerContainer, true);

        // [WHEN] Invoking revisit on the skipped checklist item
        ChecklistBannerContainer.ChecklistBanner.TaskStartOver.Invoke();

        // [THEN] The checklist item does not get marked as completed automatically,
        // as it is a link and the last checklist item, so this would prevent the user 
        // from watching the animation that denotes completing the checklist
        VerifyCompletionStatusForChecklistItem(ChecklistBannerContainer, 'last', false);

        // [WHEN] Marking the checklist item as complete
        ChecklistBannerContainer.ChecklistBanner.TaskMarkAsCompleted.SetValue(true);

        // [THEN] The checklist item is marked as completed
        VerifyCompletionStatusForChecklistItem(ChecklistBannerContainer, 'last', true);

        // [THEN] The labels and the visibility of the banner buttons are set correctly 
        // for 100% completion and the checklist is hidden
        VerifyBannerTextsAndButtonsFor100Completion(ChecklistBannerContainer, false);

        // [GIVEN] Back to checklist is invoked
        ChecklistBannerContainer.ChecklistBanner.BackToChecklist.Invoke();
    end;

    local procedure SecondChecklistItemForTheSecondProfile(var ChecklistBannerContainer: TestPage "Checklist Banner Container")
    begin
        // [WHEN] Invoking Previous
        ChecklistBannerContainer.ChecklistBanner.Previous();

        // [THEN] The currently displayed checklist item is the second one and it is marked as completed
        VerifyChecklistItemFields(ChecklistBannerContainer, 'second', true);
    end;

    local procedure VerifyBannerTextsAndButtonsForWelcomeStep(ChecklistBannerContainer: TestPage "Checklist Banner Container")
    begin
        VerifyBannerTexts(ChecklistBannerContainer,
            'Get started',
            'Get started:',
            'Hi, ready to set up your business?',
            'Complete a few steps to get ready for business',
            'We''ve prepared a few activities to get you and your team quickly started.');

        VerifyBannerButtonVisibility(ChecklistBannerContainer, true, false, false, false);
    end;

    local procedure VerifyBannerTextsAndButtonsFor0To50Completion(ChecklistBannerContainer: TestPage "Checklist Banner Container")
    begin
        VerifyBannerTexts(ChecklistBannerContainer,
            'Get started',
            'Get started:',
            'Here are a few steps that make you ready for business',
            'Complete a few steps to get ready for business',
            '');

        VerifyBannerButtonVisibility(ChecklistBannerContainer, false, false, true, false);
    end;

    local procedure VerifyBannerTextsAndButtonsFor50to75Completion(ChecklistBannerContainer: TestPage "Checklist Banner Container")
    begin
        VerifyBannerTexts(ChecklistBannerContainer,
            'Get started',
            'Get started:',
            'Continue the steps to get ready for business',
            'Continue the steps to get ready for business',
            '');

        VerifyBannerButtonVisibility(ChecklistBannerContainer, false, false, true, false);
    end;

    local procedure VerifyBannerTextsAndButtonsFor75to100Completion(ChecklistBannerContainer: TestPage "Checklist Banner Container")
    begin
        VerifyBannerTexts(ChecklistBannerContainer,
            'Get started',
            'Get started:',
            'Complete the last steps to get ready for business',
            'Complete the last steps to get ready for business',
            '');

        VerifyBannerButtonVisibility(ChecklistBannerContainer, false, false, true, false);
    end;

    local procedure VerifyBannerTextsAndButtonsFor100Completion(ChecklistBannerContainer: TestPage "Checklist Banner Container"; ChecklistVisible: Boolean)
    begin
        VerifyBannerTexts(ChecklistBannerContainer,
            'Get started',
            'Get started:',
            'All set, ready for business!',
            'All set, ready for business!',
            '');

        VerifyBannerButtonVisibility(ChecklistBannerContainer, false, true, false, not ChecklistVisible);
    end;

    local procedure VerifyBannerTexts(ChecklistBannerContainer: TestPage "Checklist Banner Container"; Title: Text; CollapsedTitle: Text; Header: Text; CollapsedHeader: Text; Description: Text)
    begin
        Assert.AreEqual(Title, ChecklistBannerContainer.ChecklistBanner.Title.Value(), 'The title is incorrect.');
        Assert.AreEqual(CollapsedTitle, ChecklistBannerContainer.ChecklistBanner.TitleCollapsed.Value(), 'The collapsed title is incorrect.');
        Assert.AreEqual(Header, ChecklistBannerContainer.ChecklistBanner.Header.Value(), 'The header is incorrect.');
        Assert.AreEqual(CollapsedHeader, ChecklistBannerContainer.ChecklistBanner.HeaderCollapsed.Value(), 'The collapsed header is incorrect.');
        Assert.AreEqual(Description, ChecklistBannerContainer.ChecklistBanner.Description.Value(), 'The description is incorrect.');
    end;

    local procedure VerifyBannerButtonVisibility(ChecklistBannerContainer: TestPage "Checklist Banner Container"; GetStartedVisibility: Boolean; GotItVisibility: Boolean; SkipChecklistVisibility: Boolean; BackToChecklistVisibility: Boolean)
    begin
        Assert.AreEqual(GetStartedVisibility, ChecklistBannerContainer.ChecklistBanner.StartSetup.Visible(),
            'The visibility of the Get Started button is set incorrectly.');
        Assert.AreEqual(GotItVisibility, ChecklistBannerContainer.ChecklistBanner.CloseSetup.Visible(),
            'The visibility of the Got it button is set incorrectly.');
        Assert.AreEqual(SkipChecklistVisibility, ChecklistBannerContainer.ChecklistBanner.SkipSetup.Visible(),
            'The visibility of the Skip checklist button is set incorrectly.');
        Assert.AreEqual(BackToChecklistVisibility, ChecklistBannerContainer.ChecklistBanner.BackToChecklist.Visible(),
            'The visibility of the Back to checklist button is set incorrectly.');
    end;

    local procedure VerifyChecklistItemFields(ChecklistBannerContainer: TestPage "Checklist Banner Container"; ChecklistItemIndex: Text; TaskCompletion: Boolean)
    begin
        Assert.AreEqual(LibraryVariableStorage.DequeueText(), ChecklistBannerContainer.ChecklistBanner.TaskTitle.Value(),
            StrSubstNo(FieldIncorrectLbl, 'short title', ChecklistItemIndex));
        Assert.AreEqual(LibraryVariableStorage.DequeueText(), ChecklistBannerContainer.ChecklistBanner.TaskHeader.Value(),
            StrSubstNo(FieldIncorrectLbl, 'title', ChecklistItemIndex));
        Assert.AreEqual(LibraryVariableStorage.DequeueText(), ChecklistBannerContainer.ChecklistBanner.TaskDescription.Value(),
            StrSubstNo(FieldIncorrectLbl, 'description', ChecklistItemIndex));
        Assert.AreEqual(LibraryVariableStorage.DequeueText(), ChecklistBannerContainer.ChecklistBanner.TaskStatusText.Value(),
            StrSubstNo(FieldIncorrectLbl, 'status', ChecklistItemIndex));

        VerifyCompletionStatusForChecklistItem(ChecklistBannerContainer, ChecklistItemIndex, TaskCompletion);
    end;

    local procedure VerifyCompletionStatusForChecklistItem(ChecklistBannerContainer: TestPage "Checklist Banner Container"; ChecklistItemIndex: Text; TaskCompletion: Boolean)
    var
        TaskMarkedAsCompleted: Boolean;
    begin
        Evaluate(TaskMarkedAsCompleted, ChecklistBannerContainer.ChecklistBanner.TaskMarkAsCompleted.Value());
        Assert.AreEqual(TaskCompletion, TaskMarkedAsCompleted, StrSubstNo(FieldIncorrectLbl, 'completion', ChecklistItemIndex));
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure AssistedSetupWizardHandler(var AssistedSetupWizard: TestPage "Assisted Setup Wizard")
    begin
        AssistedSetupWizard.Finish.Invoke();
    end;

    [RequestPageHandler]
    procedure RequestPageHandler(var ChecklistTestReport: TestRequestPage "Checklist Test Report")
    begin
        ChecklistTestReport.OK().Invoke();
    end;

    [HyperlinkHandler]
    procedure HyperlinkHandler(Message: Text[1024])
    begin
        Assert.AreEqual(LibraryVariableStorage.DequeueText(), Message,
            'The hyperlink is incorrect.');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Checklist Test Codeunit", 'OnChecklistTestCodeunitRun', '', true, true)]
    local procedure OnChecklistTestCodeunitRun()
    begin
        CodeunitRunSuccessfully := true;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Checklist Test Report", 'OnChecklistTestReportPostRun', '', true, true)]
    local procedure OnChecklistTestReportPostRun()
    begin
        ReportRunSuccessfully := true;
    end;
}