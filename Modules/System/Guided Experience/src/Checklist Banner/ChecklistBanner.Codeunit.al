// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1996 "Checklist Banner"
{
    Access = Internal;

    Permissions = tabledata "Checklist Item Buffer" = rimd,
                  tabledata "User Checklist Status" = rim,
                  tabledata "Checklist Item" = r,
                  tabledata "Guided Experience Item" = ri,
                  tabledata "Checklist Item User" = rim,
                  tabledata "Checklist Item Role" = r,
                  tabledata "Spotlight Tour Text" = r,
                  tabledata User = r,
                  tabledata "User Personalization" = r,
                  tabledata "All Profile" = r,
                  tabledata Company = r;

    var
        CompletedStepLbl: Label 'You completed this step';
        SkippedStepLbl: Label 'You skipped this step';
        BannerTitleLbl: Label 'Get started', MaxLength = 50, Comment = '*Onboarding Checklist*';
        CollapsedBannerTitleLbl: Label 'Get started:', MaxLength = 50, Comment = '*Onboarding Checklist*';
        BannerHeaderWelcomeLbl: Label 'Hi, ready to set up your business?', MaxLength = 50, Comment = '*Onboarding Checklist* %1 = The user''s name';
        BannerHeaderWelcomeEvaluationLbl: Label 'Hi, meet Business Central!', MaxLength = 50, Comment = '*Onboarding Checklist* %1 = The user''s name';
        BannerHeader0To50CompletedLbl: Label 'Here are a few steps that make you ready for business', MaxLength = 60, Comment = '*Onboarding Checklist*';
        BannerHeaderInProgressEvaluationLbl: Label 'Here are a few things you can try out', MaxLength = 60, Comment = '*Onboarding Checklist*';
        BannerHeader50To75CompletedLbl: Label 'Continue the steps to get ready for business', MaxLength = 60, Comment = '*Onboarding Checklist*';
        BannerHeader75To100CompletedLbl: Label 'Complete the last steps to get ready for business', MaxLength = 60, Comment = '*Onboarding Checklist*';
        BannerHeaderCompletedLbl: Label 'All set, ready for business!', MaxLength = 50, Comment = '*Onboarding Checklist*';
        BannerHeaderCompletedEvaluationLbl: Label 'Thank you for trying Business Central!', MaxLength = 50, Comment = '*Onboarding Checklist*';
        CollapsedBannerHeaderWelcomeLbl: Label 'Complete a few steps to get ready for business', MaxLength = 60, Comment = '*Onboarding Checklist*';
        CollapsedBannerHeaderWelcomeEvaluationLbl: Label 'Here are a few things you can try out', MaxLength = 60, Comment = '*Onboarding Checklist*';
        CollapsedBannerHeader0To50CompletedLbl: Label 'Complete a few steps to get ready for business', MaxLength = 60, Comment = '*Onboarding Checklist*';
        CollapsedBannerHeader50To75CompletedLbl: Label 'Continue the steps to get ready for business', MaxLength = 60, Comment = '*Onboarding Checklist*';
        CollapsedBannerHeader75To100CompletedLbl: Label 'Complete the last steps to get ready for business', MaxLength = 60, Comment = '*Onboarding Checklist*';
        BannerDescriptionWelcomeLbl: Label 'We''ve prepared a few activities to get you and your team quickly started.', MaxLength = 125, Comment = '*Onboarding Checklist*';
        BannerDescriptionWelcomeEvaluationLbl: Label 'You''re all set to try out our demo company, Cronus. Go explore on your own, or take a quick tour first.', MaxLength = 125, Comment = '*Onboarding Checklist*';
        BannerDescriptionInProgressEvaluationLbl: Label 'The Cronus company data you are using is for demonstration, evaluation, and training purposes.', MaxLength = 125, Comment = '*Onboarding Checklist*';
        BannerDescriptionCompletedLbl: Label 'Start exploring Business Central now. You can revisit the checklist later and enable additional features as you need them.', MaxLength = 125, Comment = '*Onboarding Checklist*';
        BannerDescriptionCompletedEvaluationLbl: Label 'Continue exploring the Cronus demo company to learn more.​', MaxLength = 125, Comment = '*Onboarding Checklist*';
        UserChecklistStatusUpdateLbl: Label 'User checklist status updated: %1 to %2', Locked = true;
        ChecklistItemStatusUpdateLbl: Label 'Checklist item status updated: %1 to %2', Locked = true;

    procedure GetAllChecklistItems(var ChecklistItemBufferTemp: Record "Checklist Item Buffer" temporary)
    var
        ChecklistItem: Record "Checklist Item";
        RandomRoleID: Code[30];
    begin
        RandomRoleID := CopyStr(CreateGuid(), 1, MaxStrLen(RandomRoleID));

        ChecklistItem.SetCurrentKey("Order ID");
        if ChecklistItem.FindSet() then
            repeat
                AddChecklistItemToBuffer(ChecklistItemBufferTemp, ChecklistItem.Code, 0, true, ChecklistItemBufferTemp.Status::"Not Started", RandomRoleID);
            until ChecklistItem.Next() = 0;

        ChecklistItemBufferTemp.Reset();
    end;

    procedure GetStatusText(var ChecklistItemBuffer: Record "Checklist Item Buffer"): Text
    begin
        case ChecklistItemBuffer.Status of
            ChecklistItemBuffer.Status::"Not Started":
                exit(GetExpectedDurationText(GetExpectedDurationInMiliseconds(ChecklistItemBuffer."Expected Duration")));
            ChecklistItemBuffer.Status::Skipped:
                exit(SkippedStepLbl);
            ChecklistItemBuffer.Status::Completed:
                exit(CompletedStepLbl);
        end
    end;

    procedure UpdateUserChecklistStatus(UserName: Text; NewStatus: Enum "Checklist Status")
    var
        UserChecklistStatus: Record "User Checklist Status";
        UserPersonalization: Record "User Personalization";
        ChecklistImplementation: Codeunit "Checklist Implementation";
        GuidedExperienceImpl: Codeunit "Guided Experience Impl.";
        Dimensions: Dictionary of [Text, Text];
        OldStatus: Enum "Checklist Status";
        UserNameCode: Code[50];
        OldStatusInDefaultLanguage: Text;
        NewStatusInDefaultLanguage: Text;
    begin
        UserNameCode := CopyStr(UserName, 1, 50);

        if ChecklistImplementation.GetUserChecklistStatusForCurrentRole(UserChecklistStatus) then begin
            OldStatus := UserChecklistStatus."Checklist Status";
            if OldStatus = NewStatus then
                exit;

            UserChecklistStatus."Checklist Status" := NewStatus;
            UserChecklistStatus.Modify();
        end
        else begin
            OldStatus := OldStatus::"Not Started";

            if UserPersonalization.Get(UserSecurityId()) then
                ChecklistImplementation.CreateNewUserChecklistStatus(UserChecklistStatus, UserNameCode,
                    UserPersonalization."Profile ID", NewStatus, true);
        end;

        GetUserChecklistStatusDimensionsInDefaultLanguage(OldStatus, NewStatus, OldStatusInDefaultLanguage, NewStatusInDefaultLanguage);
        GetCustomDimensionsForUserChecklistStatusUpdate(Dimensions, OldStatusInDefaultLanguage, NewStatusInDefaultLanguage);

        if UserPersonalization."Profile ID" = '' then
            if UserPersonalization.Get(UserSecurityId()) then;

        GuidedExperienceImpl.AddCompanyNameDimension(Dimensions);
        GuidedExperienceImpl.AddRoleDimension(Dimensions, UserPersonalization);

        Session.LogMessage('0000EIQ', StrSubstNo(UserChecklistStatusUpdateLbl, OldStatusInDefaultLanguage, NewStatusInDefaultLanguage),
            Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, Dimensions);
    end;

    procedure UpdateChecklistItemUserStatus(var ChecklistItemBuffer: Record "Checklist Item Buffer"; UserName: Text; NewStatus: Enum "Checklist Item Status")
    var
        UserPersonalization: Record "User Personalization";
        GuidedExperienceItem: Record "Guided Experience Item";
        GuidedExperienceImpl: Codeunit "Guided Experience Impl.";
        OldStatus: Enum "Checklist Item Status";
        Dimensions: Dictionary of [Text, Text];
        OldStatusInDefaultLanguage: Text;
        NewStatusInDefaultLanguage: Text;
    begin
        if not ShouldModifyStatus(ChecklistItemBuffer.Status, NewStatus) then
            exit;

        ChecklistItemBuffer.Status := NewStatus;
        ChecklistItemBuffer.Modify();

        OldStatus := UpdateChecklistItemUserStatus(ChecklistItemBuffer.Code, ChecklistItemBuffer.Version, CopyStr(UserName, 1, 50), NewStatus);

        GetChecklistItemStatusDimensionsInDefaultLanguage(OldStatus, NewStatus, OldStatusInDefaultLanguage, NewStatusInDefaultLanguage);
        GetCustomDimensionsForChecklistItemStatusUpdate(Dimensions, OldStatusInDefaultLanguage, NewStatusInDefaultLanguage);

        if UserPersonalization.Get(UserSecurityId()) then;
        GuidedExperienceImpl.AddRoleDimension(Dimensions, UserPersonalization);
        GuidedExperienceImpl.AddCompanyNameDimension(Dimensions);

        Session.LogMessage('0000EIT', StrSubstNo(ChecklistItemStatusUpdateLbl, OldStatusInDefaultLanguage, NewStatusInDefaultLanguage),
            Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, Dimensions);

        if GuidedExperienceItem.Get(ChecklistItemBuffer.Code, ChecklistItemBuffer.Version) then;

        GuidedExperienceImpl.AddGuidedExperienceItemDimensions(Dimensions, GuidedExperienceItem, 'Checklist');
        Session.LogMessage('0000EIR', StrSubstNo(ChecklistItemStatusUpdateLbl, OldStatusInDefaultLanguage, NewStatusInDefaultLanguage),
            Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All, Dimensions);
    end;

    procedure IsUserChecklistStatusComplete(UserName: Text): Boolean
    var
        UserChecklistStatus: Record "User Checklist Status";
        ChecklistImplementation: Codeunit "Checklist Implementation";
    begin
        if ChecklistImplementation.GetUserChecklistStatusForCurrentRole(UserChecklistStatus) then
            exit(UserChecklistStatus."Checklist Status" = UserChecklistStatus."Checklist Status"::Completed);
    end;

    procedure ExecuteChecklistItem(var ChecklistItemBuffer: Record "Checklist Item Buffer"; Tour: DotNet Tour; IsLastChecklistItem: Boolean; IsEvaluationCompany: Boolean): Boolean
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        ChecklistItemStatus: Enum "Checklist Item Status";
        IsChecklistItemComplete: Boolean;
    begin
        if not GuidedExperienceItem.Get(ChecklistItemBuffer.Code, ChecklistItemBuffer.Version) then
            exit;

        case GuidedExperienceItem."Guided Experience Type" of
            "Guided Experience Type"::"Assisted Setup", "Guided Experience Type"::"Manual Setup", "Guided Experience Type"::"Application Feature":
                IsChecklistItemComplete := RunObject(GuidedExperienceItem, ChecklistItemBuffer);
            "Guided Experience Type"::Tour:
                RunTour(ChecklistItemBuffer, Tour);
            "Guided Experience Type"::"Spotlight Tour":
                RunSpotlightTour(GuidedExperienceItem, Tour);
            "Guided Experience Type"::Learn:
                if GuidedExperienceItem.Link <> '' then begin
                    RunLink(ChecklistItemBuffer, IsLastChecklistItem);
                    IsChecklistItemComplete := not IsLastChecklistItem;
                end else
                    IsChecklistItemComplete := RunObject(GuidedExperienceItem, ChecklistItemBuffer);
            "Guided Experience Type"::Video:
                RunVideo(GuidedExperienceItem."Video Url");
        end;

        if IsEvaluationCompany then
            if not (GuidedExperienceItem."Guided Experience Type"
                in ["Guided Experience Type"::Tour, "Guided Experience Type"::"Spotlight Tour"])
            then begin
                UpdateChecklistItemUserStatus(ChecklistItemBuffer, UserId(), ChecklistItemStatus::Completed);
                exit(true);
            end;

        exit(IsChecklistItemComplete);
    end;

    procedure OnChecklistBannerOpen(var ChecklistItemBuffer: Record "Checklist Item Buffer"; var IsChecklistInProgress: Boolean; var IsChecklistDisplayed: Boolean)
    var
        UserChecklistStatus: Record "User Checklist Status";
        UserPersonalization: Record "User Personalization";
        ChecklistImplementation: Codeunit "Checklist Implementation";
        UserName: Code[50];
    begin
        UserName := CopyStr(UserId(), 1, 50);

        if not ChecklistImplementation.GetUserChecklistStatusForCurrentRole(UserChecklistStatus) then
            if not UserPersonalization.Get(UserSecurityId()) then
                exit
            else
                ChecklistImplementation.CreateNewUserChecklistStatus(UserChecklistStatus, UserName,
                    UserPersonalization."Profile ID", UserChecklistStatus."Checklist Status"::"Not Started", true);

        GetChecklistForUser(ChecklistItemBuffer, UserId(), UserChecklistStatus."Role ID");

        SetChecklistStatusOnBannerOpen(IsChecklistInProgress, IsChecklistDisplayed);
    end;

    procedure UpdateBannerLabels(IsEvaluationCompany: Boolean; var ChecklistItemBuffer: Record "Checklist Item Buffer"; var TitleTxt: Text; var TitleCollapsedTxt: Text; var HeaderTxt: Text; var HeaderCollapsedTxt: Text; var DescriptionTxt: Text; IsSetupStarted: Boolean; AreAllItemsSkippedOrCompleted: Boolean)
    begin
        TitleTxt := BannerTitleLbl;
        TitleCollapsedTxt := CollapsedBannerTitleLbl;

        if IsEvaluationCompany then
            UpdateBannerLabelsForEvaluationCompany(HeaderTxt, HeaderCollapsedTxt, DescriptionTxt,
                IsSetupStarted, AreAllItemsSkippedOrCompleted)
        else
            UpdateBannerLabelsForNonEvaluationCompany(ChecklistItemBuffer, HeaderTxt, HeaderCollapsedTxt,
                DescriptionTxt, IsSetupStarted, AreAllItemsSkippedOrCompleted);
    end;

    local procedure UpdateBannerLabelsForNonEvaluationCompany(var ChecklistItemBuffer: Record "Checklist Item Buffer"; var HeaderTxt: Text; var HeaderCollapsedTxt: Text; var DescriptionTxt: Text; IsSetupStarted: Boolean; AreAllItemsSkippedOrCompleted: Boolean)
    begin
        if not IsSetupStarted and not AreAllItemsSkippedOrCompleted then begin
            HeaderTxt := GetWelcomeHeaderText(false);
            HeaderCollapsedTxt := CollapsedBannerHeaderWelcomeLbl;
            DescriptionTxt := BannerDescriptionWelcomeLbl;
        end else
            if IsSetupStarted then begin
                GetHeaderLabelsBasedOnProgressToCompletion(HeaderTxt, HeaderCollapsedTxt, CalculateProgressToCompletion(ChecklistItemBuffer));
                DescriptionTxt := '';
            end
            else begin
                HeaderTxt := BannerHeaderCompletedLbl;
                HeaderCollapsedTxt := BannerHeaderCompletedLbl;
                DescriptionTxt := BannerDescriptionCompletedLbl;
            end;
    end;

    local procedure UpdateBannerLabelsForEvaluationCompany(var HeaderTxt: Text; var HeaderCollapsedTxt: Text; var DescriptionTxt: Text; IsSetupStarted: Boolean; AreAllItemsSkippedOrCompleted: Boolean)
    begin
        if not IsSetupStarted and not AreAllItemsSkippedOrCompleted then begin
            HeaderTxt := GetWelcomeHeaderText(true);
            HeaderCollapsedTxt := CollapsedBannerHeaderWelcomeEvaluationLbl;
            DescriptionTxt := BannerDescriptionWelcomeEvaluationLbl;
        end else
            if IsSetupStarted then begin
                if not AreAllItemsSkippedOrCompleted then begin
                    HeaderTxt := BannerHeaderInProgressEvaluationLbl;
                    HeaderCollapsedTxt := BannerHeaderInProgressEvaluationLbl;
                    DescriptionTxt := BannerDescriptionInProgressEvaluationLbl;
                end else begin
                    HeaderTxt := BannerHeaderCompletedEvaluationLbl;
                    HeaderCollapsedTxt := BannerHeaderCompletedEvaluationLbl;
                    DescriptionTxt := '';
                end;
            end else begin
                HeaderTxt := BannerHeaderCompletedEvaluationLbl;
                HeaderCollapsedTxt := BannerHeaderCompletedEvaluationLbl;
                DescriptionTxt := BannerDescriptionCompletedEvaluationLbl;
            end;
    end;

    procedure CalculateProgressToCompletion(var ChecklistItemBuffer: Record "Checklist Item Buffer"): Decimal
    var
        TotalCount: Integer;
        CompletedCount: Integer;
    begin
        TotalCount := ChecklistItemBuffer.Count;
        if TotalCount = 0 then
            exit(0);

        ChecklistItemBuffer.SetFilter(Status, '=%1|=%2',
            ChecklistItemBuffer.Status::Skipped, ChecklistItemBuffer.Status::Completed);
        CompletedCount := ChecklistItemBuffer.Count;

        ChecklistItemBuffer.Reset();
        ChecklistItemBuffer.SetCurrentKey("Order ID");

        exit(CompletedCount / TotalCount);
    end;

    local procedure AddChecklistItemToBuffer(var ChecklistItemBuffer: Record "Checklist Item Buffer"; Code: Code[300]; Version: Integer; CheckForDuplicate: Boolean; Status: Enum "Checklist Item Status"; RoleID: Code[30])
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        ChecklistItem: Record "Checklist Item";
    begin
        GuidedExperienceItem.SetCurrentKey(Code, Version);
        GuidedExperienceItem.SetRange(Code, Code);
        if Version <> 0 then
            GuidedExperienceItem.SetRange(Version, Version);

        if GuidedExperienceItem.FindLast() then begin
            if CheckForDuplicate then
                if ChecklistItemHasDuplicateInBuffer(ChecklistItemBuffer, GuidedExperienceItem, RoleID) then
                    exit;

            if not ChecklistItem.Get(Code) then
                exit;

            if Status <> Status::Completed then
                if HasTheItemBeenCompleted(GuidedExperienceItem, ChecklistItem) then
                    Status := Status::Completed;

            InsertChecklistItemInBuffer(ChecklistItemBuffer, GuidedExperienceItem, Status, ChecklistItem, RoleID);
        end;
    end;

    local procedure HasTheItemBeenCompleted(GuidedExperienceItem: Record "Guided Experience Item"; ChecklistItem: Record "Checklist Item"): Boolean
    begin
        if (GuidedExperienceItem."Guided Experience Type" = GuidedExperienceItem."Guided Experience Type"::"Assisted Setup")
            and (GuidedExperienceItem.Completed)
        then
            exit(true);

        if ChecklistItem."Completion Requirements" = ChecklistItem."Completion Requirements"::Anyone then
            exit(HasAnyoneCompletedTheChecklistItem(ChecklistItem.Code));
    end;

    local procedure HasAnyoneCompletedTheChecklistItem(Code: Code[300]): Boolean
    var
        ChecklistItemUser: Record "Checklist Item User";
    begin
        ChecklistItemUser.SetRange(Code, Code);
        ChecklistItemUser.SetRange("Checklist Item Status", ChecklistItemUser."Checklist Item Status"::Completed);
        exit(not ChecklistItemUser.IsEmpty());
    end;

    local procedure ChecklistItemHasDuplicateInBuffer(var ChecklistItemBuffer: Record "Checklist Item Buffer"; GuidedExperienceItem: Record "Guided Experience Item"; RoleID: Code[30]): Boolean
    begin
        ChecklistItemBuffer.SetRange("Guided Experience Type", GuidedExperienceItem."Guided Experience Type");
        ChecklistItemBuffer.SetRange("Object Type to Run", GuidedExperienceItem."Object Type to Run");
        ChecklistItemBuffer.SetRange(Link, GuidedExperienceItem.Link);
        ChecklistItemBuffer.SetRange("Spotlight Tour Type", GuidedExperienceItem."Spotlight Tour Type");
        ChecklistItemBuffer.SetRange("Video Url", GuidedExperienceItem."Video Url");

        if GuidedExperienceItem."Guided Experience Type" = GuidedExperienceItem."Guided Experience Type"::Tour then
            ChecklistItemBuffer.SetRange("Object ID to Run", GetPageIDForTour(RoleID, GuidedExperienceItem."Object ID to Run"))
        else
            ChecklistItemBuffer.SetRange("Object ID to Run", GuidedExperienceItem."Object ID to Run");

        exit(not ChecklistItemBuffer.IsEmpty());
    end;

    local procedure InsertChecklistItemInBuffer(var ChecklistItemBuffer: Record "Checklist Item Buffer"; GuidedExperienceItem: Record "Guided Experience Item"; Status: Enum "Checklist Item Status"; ChecklistItem: Record "Checklist Item"; RoleID: Code[30])
    begin
        ChecklistItemBuffer.ID := CreateGuid();
        ChecklistItemBuffer.Code := GuidedExperienceItem.Code;
        ChecklistItemBuffer.Version := GuidedExperienceItem.Version;

        ChecklistItemBuffer."Object Type to Run" := GuidedExperienceItem."Object Type to Run";

        if GuidedExperienceItem."Guided Experience Type" = GuidedExperienceItem."Guided Experience Type"::Tour then
            ChecklistItemBuffer."Object ID to Run" := GetPageIDForTour(RoleID, GuidedExperienceItem."Object ID to Run")
        else
            ChecklistItemBuffer."Object ID to Run" := GuidedExperienceItem."Object ID to Run";

        ChecklistItemBuffer.Link := GuidedExperienceItem.Link;
        ChecklistItemBuffer."Expected Duration" := GuidedExperienceItem."Expected Duration";
        ChecklistItemBuffer."Guided Experience Type" := GuidedExperienceItem."Guided Experience Type";
        ChecklistItemBuffer."Spotlight Tour Type" := GuidedExperienceItem."Spotlight Tour Type";
        ChecklistItemBuffer."Video Url" := GuidedExperienceItem."Video Url";

        GetTranslationsForTitlesAndDescription(ChecklistItemBuffer, GuidedExperienceItem);

        GuidedExperienceItem.CalcFields("Extension Name");
        ChecklistItemBuffer."Extension Name" := GuidedExperienceItem."Extension Name";

        ChecklistItemBuffer.Status := Status;
        ChecklistItemBuffer."Order ID" := ChecklistItem."Order ID";
        ChecklistItemBuffer."Completion Requirements" := ChecklistItem."Completion Requirements";

        SetAssignedTo(ChecklistItemBuffer);

        ChecklistItemBuffer.Insert();
    end;

    local procedure GetPageIDForTour(RoleID: Code[30]; ObjectIDToRun: Integer): Integer
    var
        AllProfile: Record "All Profile";
    begin
        // if the tour is running on the same page as the checklist we don't want to refresh the page, 
        // as the checklist will appear in a wrong state afterwards, so we need to run the tour for object ID 0

        AllProfile.SetRange("Role Center ID", ObjectIDToRun);
        AllProfile.SetRange("Profile ID", RoleID);

        if not AllProfile.IsEmpty() then
            exit(0);

        exit(ObjectIDToRun);
    end;

    local procedure GetTranslationsForTitlesAndDescription(var ChecklistItemBuffer: Record "Checklist Item Buffer"; GuidedExperienceItem: Record "Guided Experience Item")
    var
        Checklist: Codeunit Checklist;
        Title: Text[2048];
        ShortTitle: Text[50];
        Description: Text[1024];
    begin
        GetTranslationsForTitlesAndDescription(GuidedExperienceItem, Title, ShortTitle, Description);

        if (Title = '') or (ShortTitle = '') or (Description = '') then begin
            Checklist.InitializeGuidedExperienceItems();
            GetTranslationsForTitlesAndDescription(GuidedExperienceItem, Title, ShortTitle, Description);
        end;

        if Title <> '' then
            ChecklistItemBuffer.Title := Title
        else
            ChecklistItemBuffer.Title := GuidedExperienceItem.Title;

        if ShortTitle <> '' then
            ChecklistItemBuffer."Short Title" := ShortTitle
        else
            ChecklistItemBuffer."Short Title" := GuidedExperienceItem."Short Title";

        if Description <> '' then
            ChecklistItemBuffer.Description := Description
        else
            ChecklistItemBuffer.Description := GuidedExperienceItem.Description;
    end;

    local procedure GetTranslationsForTitlesAndDescription(GuidedExperienceItem: Record "Guided Experience Item"; var Title: Text[2048]; var ShortTitle: Text[50]; var Description: Text[1024])
    begin
        Title := CopyStr(GetTranslationForField(GuidedExperienceItem, GuidedExperienceItem.FieldNo(Title)),
            1, MaxStrLen(GuidedExperienceItem.Title));

        ShortTitle := CopyStr(GetTranslationForField(GuidedExperienceItem, GuidedExperienceItem.FieldNo("Short Title")),
            1, MaxStrLen(GuidedExperienceItem."Short Title"));

        Description := CopyStr(GetTranslationForField(GuidedExperienceItem, GuidedExperienceItem.FieldNo(Description)),
            1, MaxStrLen(GuidedExperienceItem.Description));
    end;

    local procedure GetTranslationForField(GuidedExperienceItem: Record "Guided Experience Item"; FieldNo: Integer): Text
    var
        GuidedExperienceImpl: Codeunit "Guided Experience Impl.";
    begin
        exit(GuidedExperienceImpl.GetTranslationForField(GuidedExperienceItem."Guided Experience Type",
            GuidedExperienceItem."Object Type to Run", GuidedExperienceItem."Object ID to Run",
            GuidedExperienceItem.Link, GuidedExperienceItem."Video Url", GuidedExperienceItem."Spotlight Tour Type", FieldNo));
    end;

    local procedure SetAssignedTo(var ChecklistItemBuffer: Record "Checklist Item Buffer")
    var
        ChecklistItemRole: Record "Checklist Item Role";
        ChecklistItemUser: Record "Checklist Item User";
        NumberOfAssignees: Integer;
        Assignee: Text[50];
    begin
        if ChecklistItemBuffer."Completion Requirements" in
            [ChecklistItemBuffer."Completion Requirements"::Anyone, ChecklistItemBuffer."Completion Requirements"::Everyone]
        then begin
            ChecklistItemRole.SetRange(Code, ChecklistItemBuffer.Code);
            NumberOfAssignees := ChecklistItemRole.Count;
            if NumberOfAssignees = 1 then
                if ChecklistItemRole.FindFirst() then
                    Assignee := ChecklistItemRole."Role ID";
        end else begin
            ChecklistItemUser.SetRange(Code, ChecklistItemBuffer.Code);
            NumberOfAssignees := ChecklistItemUser.Count;
            if NumberOfAssignees = 1 then
                if ChecklistItemUser.FindFirst() then
                    Assignee := ChecklistItemUser."User ID";
        end;

        case NumberOfAssignees of
            0:
                ChecklistItemBuffer."Assigned To" := 'No one';
            1:
                ChecklistItemBuffer."Assigned To" := Assignee;
            else
                ChecklistItemBuffer."Assigned To" := 'Multiple';
        end;
    end;

    local procedure GetExpectedDurationText(ExpectedDuration: Duration): Text
    begin
        exit(Format(ExpectedDuration));
    end;

    local procedure GetExpectedDurationInMiliseconds(ExpectedDurationInMinutes: Integer): Integer
    begin
        exit(ExpectedDurationInMinutes * 60000);
    end;

    local procedure ShouldModifyStatus(OldStatus: Enum "Checklist Item Status"; NewStatus: Enum "Checklist Item Status"): Boolean
    begin
        exit(
            (NewStatus <> OldStatus)
            and (NewStatus <> NewStatus::"Not Started")
            and (
                (NewStatus = NewStatus::Started)
                or ((OldStatus in [OldStatus::"Not Started", OldStatus::Started, OldStatus::Skipped]) and (NewStatus in [NewStatus::Skipped, NewStatus::Completed]))
                )
            );
    end;

    local procedure UpdateChecklistItemUserStatus(Code: Code[300]; Version: Integer; UserName: Text; Status: Enum "Checklist Item Status"): Enum "Checklist Item Status"
    var
        ChecklistItemUser: Record "Checklist Item User";
        OldStatus: Enum "Checklist Item Status";
        UserID: Code[50];
    begin
        UserID := CopyStr(UserName, 1, 50);

        if not ChecklistItemUser.Get(Code, UserName) then begin
            OldStatus := OldStatus::"Not Started";

            ChecklistItemUser.Code := Code;
            ChecklistItemUser.Version := Version;
            ChecklistItemUser."User ID" := UserID;
            ChecklistItemUser."Checklist Item Status" := Status;
            ChecklistItemUser."Is Visible" := true;
            ChecklistItemUser."Assigned to User" := false;
            ChecklistItemUser.Insert();
        end
        else
            if ChecklistItemUser."Checklist Item Status" <> Status then begin
                OldStatus := ChecklistItemUser."Checklist Item Status";

                ChecklistItemUser.Version := Version;
                ChecklistItemUser."Checklist Item Status" := Status;
                ChecklistItemUser.Modify();
            end;

        exit(OldStatus);
    end;

    local procedure RunObject(var GuidedExperienceItem: Record "Guided Experience Item"; var ChecklistItemBuffer: Record "Checklist Item Buffer"): Boolean
    var
        GuidedExperienceImpl: Codeunit "Guided Experience Impl.";
        ChecklistItemStatus: Enum "Checklist Item Status";
    begin
        if not GuidedExperienceImpl.IsObjectToRunValid(GuidedExperienceItem."Object Type to Run", GuidedExperienceItem."Object ID to Run") then
            exit;

        if GuidedExperienceItem."Guided Experience Type" in
            [GuidedExperienceItem."Guided Experience Type"::"Manual Setup",
            GuidedExperienceItem."Guided Experience Type"::"Application Feature"]
        then begin
            RunObject(GuidedExperienceItem);
            UpdateChecklistItemUserStatus(ChecklistItemBuffer, UserId(), ChecklistItemStatus::Started);
        end else
            if GuidedExperienceItem."Guided Experience Type" = GuidedExperienceItem."Guided Experience Type"::"Assisted Setup" then begin
                GuidedExperienceImpl.RunAndRefreshAssistedSetup(GuidedExperienceItem);
                if IsAssistedSetupComplete(GuidedExperienceItem) then
                    UpdateChecklistItemUserStatus(ChecklistItemBuffer, UserId(), ChecklistItemStatus::Completed)
                else
                    UpdateChecklistItemUserStatus(ChecklistItemBuffer, UserId(), ChecklistItemStatus::Started);
            end;

        exit(ChecklistItemBuffer.Status = ChecklistItemBuffer.Status::Completed);
    end;

    local procedure RunLink(var ChecklistItemBuffer: Record "Checklist Item Buffer"; IsLastChecklistItem: Boolean)
    var
        ChecklistItemStatus: Enum "Checklist Item Status";
    begin
        OpenLink(ChecklistItemBuffer.Link);

        if IsLastChecklistItem then
            ChecklistItemStatus := ChecklistItemStatus::Started
        else
            ChecklistItemStatus := ChecklistItemStatus::Completed;

        UpdateChecklistItemUserStatus(ChecklistItemBuffer, UserId(), ChecklistItemStatus);

        ChecklistItemBuffer.Status := ChecklistItemStatus;
        ChecklistItemBuffer.Modify();
    end;

    local procedure RunTour(ChecklistItemBuffer: Record "Checklist Item Buffer"; Tour: DotNet Tour)
    begin
        Tour.StartTour(ChecklistItemBuffer."Object ID to Run", ChecklistItemBuffer.Code);
    end;

    local procedure RunVideo(VideoUrl: Text[250])
    var
        Video: Codeunit Video;
    begin
        Video.Play(VideoUrl);
    end;

    local procedure RunObject(GuidedExperienceItem: Record "Guided Experience Item")
    var
        ObjectID: Integer;
        ObjectType: Enum "Guided Experience Object Type";
    begin
        Commit(); //needed before the RunModal
        ObjectType := GuidedExperienceItem."Object Type to Run";
        ObjectID := GuidedExperienceItem."Object ID to Run";
        case ObjectType of
            ObjectType::Page:
                If GuidedExperienceItem."Guided Experience Type" = GuidedExperienceItem."Guided Experience Type"::"Application Feature" then
                    Page.Run(ObjectID)
                else
                    Page.RunModal(ObjectID);
            ObjectType::Codeunit:
                Codeunit.Run(ObjectID);
            ObjectType::Report:
                Report.RunModal(ObjectID);
            ObjectType::XmlPort:
                Xmlport.Run(ObjectID);
        end
    end;

    local procedure RunSpotlightTour(GuidedExperienceItem: Record "Guided Experience Item"; Tour: DotNet Tour)
    var
        SpotlightTour: DotNet SpotlightTour;
        TourDictionary: DotNet GenericDictionary2;
    begin
        GetSpolightTour(SpotlightTour, GuidedExperienceItem."Spotlight Tour Type");

        GetTourDictionary(TourDictionary, GuidedExperienceItem);

        Tour.StartSpotlightTour(GuidedExperienceItem."Object ID to Run", SpotlightTour, TourDictionary, GuidedExperienceItem.Code);
    end;

    local procedure GetSpolightTour(var SpotlightTour: DotNet SpotlightTour; SpotlightTourType: Enum "Spotlight Tour Type")
    begin
        case SpotlightTourType of
            SpotlightTourType::"Open in Excel":
                SpotlightTour := SpotlightTour::OpenInExcel;
            SpotlightTourType::"Share to Teams":
                SpotlightTour := SpotlightTour::ShareToTeams;
            else
                SpotlightTour := SpotlightTour::None;
        end;
    end;

    local procedure GetTourDictionary(var TourDictionary: DotNet GenericDictionary2; GuidedExperienceItem: Record "Guided Experience Item")
    var
        SpotlightTourText: Record "Spotlight Tour Text";
    begin
        TourDictionary := TourDictionary.Dictionary();

        SpotlightTourText.SetRange("Guided Experience Item Code", GuidedExperienceItem.Code);
        SpotlightTourText.SetRange("Guided Experience Item Version", GuidedExperienceItem.Version);

        if SpotlightTourText.FindSet() then
            repeat
                TourDictionary.Add(Format(SpotlightTourText."Spotlight Tour Step"), GetTranslatedSpotlightTourText(SpotlightTourText));
            until SpotlightTourText.Next() = 0;
    end;

    local procedure GetTranslatedSpotlightTourText(SpotlightTourText: Record "Spotlight Tour Text"): Text
    var
        Translation: Codeunit Translation;
        TranslatedText: Text;
    begin
        TranslatedText := Translation.Get(SpotlightTourText, SpotlightTourText.FieldNo("Spotlight Tour Text"), GlobalLanguage);

        if TranslatedText <> '' then
            exit(TranslatedText);

        exit(SpotlightTourText."Spotlight Tour Text");
    end;

    local procedure OpenLink(Link: Text[250])
    begin
        Hyperlink(Link);
    end;

    local procedure IsAssistedSetupComplete(GuidedExperienceItem: Record "Guided Experience Item"): Boolean
    var
        GuidedExperienceImpl: Codeunit "Guided Experience Impl.";
    begin
        if GuidedExperienceItem."Guided Experience Type" = GuidedExperienceItem."Guided Experience Type"::"Assisted Setup" then
            exit(GuidedExperienceImpl.IsAssistedSetupComplete(GuidedExperienceItem."Object Type to Run", GuidedExperienceItem."Object ID to Run"));
    end;

    local procedure ShouldShowChecklist(): Boolean
    var
        UserPersonalization: Record "User Personalization";
        UserChecklistStatus: Record "User Checklist Status";
        Checklist: Codeunit Checklist;
        ChecklistImplementation: Codeunit "Checklist Implementation";
    begin
        if not UserPersonalization.Get(UserSecurityId()) then
            exit;

        ChecklistImplementation.SwitchRole(CopyStr(UserId(), 1, 50), UserPersonalization."Profile ID");

        Checklist.OnChecklistLoading();

        if ChecklistImplementation.GetUserChecklistStatusForCurrentRole(UserChecklistStatus) then
            exit(UserChecklistStatus."Is Visible");

        exit(false);
    end;

    local procedure GetChecklistForUser(var ChecklistItemBuffer: Record "Checklist Item Buffer"; UserName: Text; RoleID: Code[30])
    var
        ChecklistItemRole: Record "Checklist Item Role";
        ChecklistItemUser: Record "Checklist Item User";
    begin
        UserName := CopyStr(UserName, 1, 50);
        ChecklistItemUser.SetRange("User ID", UserName);
        ChecklistItemUser.SetRange("Is Visible", true);
        if ChecklistItemUser.FindSet() then
            repeat
                AddChecklistItemToBuffer(ChecklistItemBuffer, ChecklistItemUser.Code, ChecklistItemUser.Version, false, ChecklistItemUser."Checklist Item Status", RoleID);
            until ChecklistItemUser.Next() = 0;

        ChecklistItemRole.SetRange("Role ID", RoleID);
        if ChecklistItemRole.FindSet() then
            repeat
                AddChecklistItemToBuffer(ChecklistItemBuffer, ChecklistItemRole.Code, 0, true, ChecklistItemUser."Checklist Item Status"::"Not Started", RoleID);
            until ChecklistItemRole.Next() = 0;

        ChecklistItemBuffer.Reset();
        ChecklistItemBuffer.SetCurrentKey("Order ID");
        if ChecklistItemBuffer.FindFirst() then;
    end;

    local procedure SetChecklistStatusOnBannerOpen(var IsChecklistInProgress: Boolean; var IsChecklistDisplayed: Boolean)
    var
        UserChecklistStatus: Record "User Checklist Status";
        ChecklistImplementation: Codeunit "Checklist Implementation";
    begin
        if ChecklistImplementation.GetUserChecklistStatusForCurrentRole(UserChecklistStatus) then begin
            IsChecklistInProgress := UserChecklistStatus."Checklist Status" = UserChecklistStatus."Checklist Status"::"In progress";
            IsChecklistDisplayed := not (UserChecklistStatus."Checklist Status" in
                [UserChecklistStatus."Checklist Status"::Completed, UserChecklistStatus."Checklist Status"::"Not Started"]);
        end;
    end;

    local procedure GetWelcomeHeaderText(IsEvaluationCompany: Boolean): Text
    var
        BannerText: Text;
    begin
        if IsEvaluationCompany then
            BannerText := BannerHeaderWelcomeEvaluationLbl
        else
            BannerText := BannerHeaderWelcomeLbl;

        exit(BannerText);
    end;

    local procedure GetHeaderLabelsBasedOnProgressToCompletion(var HeaderTxt: Text; var HeaderCollapsedTxt: Text; ProgressToCompletion: Decimal)
    begin
        if ProgressToCompletion < 0.50 then begin
            HeaderTxt := BannerHeader0To50CompletedLbl;
            HeaderCollapsedTxt := CollapsedBannerHeader0To50CompletedLbl;
        end else
            if ProgressToCompletion < 0.75 then begin
                HeaderTxt := BannerHeader50To75CompletedLbl;
                HeaderCollapsedTxt := CollapsedBannerHeader50To75CompletedLbl;
            end else
                if ProgressToCompletion < 1.0 then begin
                    HeaderTxt := BannerHeader75To100CompletedLbl;
                    HeaderCollapsedTxt := CollapsedBannerHeader75To100CompletedLbl;
                end else begin
                    HeaderTxt := BannerHeaderCompletedLbl;
                    HeaderCollapsedTxt := BannerHeaderCompletedLbl;
                end;
    end;

    local procedure GetChecklistItemStatusDimensionsInDefaultLanguage(OldStatus: Enum "Checklist Item Status"; NewStatus: Enum "Checklist Item Status"; var OldStatusInDefaultLanguage: Text; var NewStatusInDefaultLanguage: Text)
    var
        Language: Codeunit Language;
        CurrentLanguageId: Integer;
    begin
        CurrentLanguageId := GlobalLanguage;
        GlobalLanguage(Language.GetDefaultApplicationLanguageId());

        OldStatusInDefaultLanguage := Format(OldStatus);
        NewStatusInDefaultLanguage := Format(NewStatus);

        GlobalLanguage(CurrentLanguageId);
    end;

    local procedure GetCustomDimensionsForChecklistItemStatusUpdate(var Dimensions: Dictionary of [Text, Text]; OldStatus: Text; NewStatus: Text)
    begin
        Dimensions.Add('OldStatus', OldStatus);
        Dimensions.Add('NewStatus', NewStatus);
    end;

    local procedure GetUserChecklistStatusDimensionsInDefaultLanguage(OldStatus: Enum "Checklist Status"; NewStatus: Enum "Checklist Status"; var OldStatusInDefaultLanguage: Text; var NewStatusInDefaultLanguage: Text)
    var
        Language: Codeunit Language;
        CurrentLanguageId: Integer;
    begin
        CurrentLanguageId := GlobalLanguage;
        GlobalLanguage(Language.GetDefaultApplicationLanguageId());

        OldStatusInDefaultLanguage := Format(OldStatus);
        NewStatusInDefaultLanguage := Format(NewStatus);

        GlobalLanguage(CurrentLanguageId);
    end;

    local procedure GetCustomDimensionsForUserChecklistStatusUpdate(var Dimensions: Dictionary of [Text, Text]; OldStatus: Text; NewStatus: Text)
    begin
        Dimensions.Add('OldStatus', OldStatus);
        Dimensions.Add('NewStatus', NewStatus);
    end;

    internal procedure GetRoleCenterBannerPartID(var PartID: Integer)
    begin
        OnGetRoleCenterBannerPartID(PartID);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Action Triggers", 'GetRoleCenterBannerPartID', '', true, true)]
    local procedure OnGetRoleCenterBannerPartID(var PartID: Integer)
    begin
        if Session.CurrentClientType() in [ClientType::Web, ClientType::Windows, ClientType::Desktop] then
            if ShouldShowChecklist() then
                PartID := Page::"Checklist Banner";
    end;
}