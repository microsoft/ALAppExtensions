// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1993 "Checklist Implementation"
{
    Access = Internal;
    Permissions = tabledata "Guided Experience Item" = r,
                    tabledata "Checklist Item" = rimd,
                    tabledata "Checklist Item User" = rimd,
                    tabledata "Checklist Item Role" = rimd,
                    tabledata "User Checklist Status" = rim,
                    tabledata "Checklist Setup" = rimd,
                    tabledata "User Personalization" = r,
                    tabledata Company = r;

    var
        ChecklistItemInsertedLbl: Label 'Checklist item inserted.', Locked = true;
        ChecklistItemDeletedLbl: Label 'Checklist item deleted.', Locked = true;
        ChangeBannerVisibilityLbl: Label 'Looking for your checklist to set up Business Central?';
        UserResurfacedBannerLbl: Label 'Checklist banner resurfaced.', Locked = true;
        UserResurfacedBannerNewSessionLbl: Label 'Checklist banner resurfaced, new session requested.', Locked = true;
        ChecklistInitializedLbl: Label 'Checklist banner initialized.', Locked = true;
        MicrosoftLearnLongTitleLbl: Label 'Find training on Microsoft Learn', MaxLength = 53, Comment = '*Onboarding Checklist*';
        MicrosoftLearnShortTitleLbl: Label 'Microsoft Learn', MaxLength = 34, Comment = '*Onboarding Checklist*';
        MicrosoftLearnDescriptionLbl: Label 'Explore the free e-learning material for Business Central on the Microsoft Learn site in a new browser tab.', MaxLength = 180, Comment = '*Onboarding Checklist*';
        ShowChecklistLbl: Label 'Show checklist on the role center';

    procedure Insert(GuidedExperienceType: Enum "Guided Experience Type"; ObjectTypeToRun: ObjectType; ObjectIDToRun: Integer; Link: Text[250]; SpotlightTourType: Enum "Spotlight Tour Type"; ShouldEveryoneComplete: Boolean; OrderID: Integer; var TempAllProfile: Record "All Profile" temporary; var TempUsers: Record User temporary)
    var
        CompletionRequirements: Enum "Checklist Completion Requirements";
    begin
        if ShouldEveryoneComplete then
            CompletionRequirements := CompletionRequirements::Everyone
        else
            CompletionRequirements := CompletionRequirements::Anyone;

        Insert(GuidedExperienceType, ObjectTypeToRun, ObjectIDToRun, Link, SpotlightTourType, CompletionRequirements, OrderID, TempAllProfile, TempUsers);
    end;

    procedure Insert(GuidedExperienceType: Enum "Guided Experience Type"; ObjectTypeToRun: ObjectType; ObjectIDToRun: Integer; Link: Text[250]; SpotlightTourType: Enum "Spotlight Tour Type"; CompletionRequirements: Enum "Checklist Completion Requirements"; OrderID: Integer; var TempAllProfile: Record "All Profile" temporary; var TempUsers: Record User temporary)
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        ChecklistItem: Record "Checklist Item";
        GuidedExperienceImpl: Codeunit "Guided Experience Impl.";
        VideoUrl: Text[250];
    begin
        GetLinkAndVideoUrl(Link, VideoUrl, GuidedExperienceType);

        GuidedExperienceImpl.FilterGuidedExperienceItem(GuidedExperienceItem, GuidedExperienceType, ObjectTypeToRun, ObjectIDToRun, Link, VideoUrl, SpotlightTourType);

        if not GuidedExperienceItem.FindLast() then
            exit;

        if not ChecklistItem.Get(GuidedExperienceItem.Code) then begin
            InsertChecklistItem(GuidedExperienceItem.Code, CompletionRequirements, OrderID);

            if TempUsers.Count > 0 then
                InsertChecklistItemUsers(TempUsers, GuidedExperienceItem.Code);

            if TempAllProfile.Count > 0 then
                InsertChecklistItemRoles(TempAllProfile, GuidedExperienceItem.Code);
        end
        else begin
            if (ChecklistItem."Completion Requirements" <> CompletionRequirements) or (ChecklistItem."Order ID" <> OrderID) then
                UpdateChecklistItem(ChecklistItem, CompletionRequirements, OrderID);

            UpdateChecklistItemRoles(GuidedExperienceItem.Code, TempAllProfile);
            UpdateChecklistItemUsers(GuidedExperienceItem.Code, TempUsers, TempAllProfile);
        end;
    end;

    procedure InsertChecklistItem(Code: Code[300]; CompletionRequirements: Enum "Checklist Completion Requirements"; OrderID: Integer)
    var
        ChecklistItem: Record "Checklist Item";
    begin
        ChecklistItem.Code := Code;
        ChecklistItem."Completion Requirements" := CompletionRequirements;
        ChecklistItem."Order ID" := OrderID;
        ChecklistItem.Insert();
    end;

    procedure InsertChecklistItemRole(Code: Code[300]; RoleID: Code[30])
    var
        ChecklistItem: Record "Checklist Item";
        ChecklistItemRole: Record "Checklist Item Role";
    begin
        if ChecklistItem.Get(Code) then
            if not ChecklistItemRole.Get(Code, RoleID) then begin
                ChecklistItemRole.Code := Code;
                ChecklistItemRole."Role ID" := RoleID;
                ChecklistItemRole.Insert();
            end;
    end;

    procedure InsertChecklistItemUser(Code: Code[300]; UserID: Code[50])
    var
        ChecklistItem: Record "Checklist Item";
        ChecklistItemUser: Record "Checklist Item User";
    begin
        if ChecklistItem.Get(Code) then
            if not ChecklistItemUser.Get(Code, UserID) then begin
                ChecklistItemUser.Code := Code;
                ChecklistItemUser."User ID" := UserID;
                ChecklistItemUser."Assigned to User" := true;
                ChecklistItemUser."Is Visible" := true;
                ChecklistItemUser.Insert();
            end;
    end;

    procedure Delete(GuidedExperienceType: Enum "Guided Experience Type"; ObjectTypeToRun: ObjectType; ObjectIDToRun: Integer; Link: Text[250]; SpotlightTourType: Enum "Spotlight Tour Type")
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        ChecklistItem: Record "Checklist Item";
        GuidedExperienceImpl: Codeunit "Guided Experience Impl.";
        VideoUrl: Text[250];
    begin
        GetLinkAndVideoUrl(link, VideoUrl, GuidedExperienceType);

        GuidedExperienceImpl.FilterGuidedExperienceItem(GuidedExperienceItem, GuidedExperienceType, ObjectTypeToRun, ObjectIDToRun, Link, VideoUrl, SpotlightTourType);

        if not GuidedExperienceItem.FindLast() then
            exit;

        if ChecklistItem.Get(GuidedExperienceItem.Code) then
            Delete(ChecklistItem.Code);
    end;

    procedure Delete(Code: Code[300])
    var
        ChecklistItem: Record "Checklist Item";
        ChecklistItemRole: Record "Checklist Item Role";
        ChecklistItemUser: Record "Checklist Item User";
    begin
        if ChecklistItem.Get(Code) then
            ChecklistItem.Delete();

        ChecklistItemRole.SetRange(Code, Code);
        if not ChecklistItemRole.IsEmpty() then
            ChecklistItemRole.DeleteAll();

        ChecklistItemUser.SetRange(Code, Code);
        if not ChecklistItemUser.IsEmpty() then
            ChecklistItemUser.DeleteAll();
    end;

    procedure ShouldInitializeChecklist(ShouldSkipForEvaluationCompany: Boolean): Boolean
    var
        Company: Record Company;
        ChecklistSetup: Record "Checklist Setup";
        CurrentDateTimeUTC: DateTime;
    begin
        if not (Session.CurrentClientType() in [ClientType::Web, ClientType::Windows, ClientType::Desktop]) then
            exit(false);

        if not Company.Get(CompanyName()) then
            exit(false);

        if ShouldSkipForEvaluationCompany then
            if Company."Evaluation Company" then
                exit(false);

        if ChecklistSetup.IsEmpty() then
            exit(true);

        if ChecklistSetup.FindFirst() then begin
            if ChecklistSetup."Is Setup Done" then
                exit(false);

            if ChecklistSetup."Is Setup in Progress" then begin
                CurrentDateTimeUTC := GetCurrentDateTimeInUTC();

                // if the setup started more than 1 hour ago, but was not finished, we should restart it
                if CurrentDateTimeUTC - ChecklistSetup."DateTime when Setup Started" > 3600000 then
                    exit(true)
                else
                    exit(false);
            end;

            exit(true);
        end;
    end;

    procedure MarkChecklistSetupInProgress(CallerModuleInfo: ModuleInfo)
    var
        ChecklistSetup: Record "Checklist Setup";
    begin
        if ChecklistSetup.FindFirst() then begin
            if ChecklistSetup."Is Setup Done" then
                exit;

            if ChecklistSetup."Is Setup in Progress" then
                exit;

            ChecklistSetup.Delete();
        end;

        ChecklistSetup."Is Setup in Progress" := true;
        ChecklistSetup."DateTime when Setup Started" := GetCurrentDateTimeInUTC();
        ChecklistSetup."Is Setup Done" := false;
        ChecklistSetup.Insert();
    end;

    procedure MarkChecklistSetupAsDone(CallerModuleInfo: ModuleInfo)
    var
        ChecklistSetup: Record "Checklist Setup";
        GuidedExperienceImpl: Codeunit "Guided Experience Impl.";
        Dimensions: Dictionary of [Text, Text];
    begin
        GuidedExperienceImpl.AddCompanyNameDimension(Dimensions);
        Session.LogMessage('0000E9U', ChecklistInitializedLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, Dimensions);

        if ChecklistSetup.FindFirst() then begin
            if ChecklistSetup."Is Setup Done" then
                exit;

            ChecklistSetup.Delete();
        end;

        ChecklistSetup."Is Setup Done" := true;
        ChecklistSetup.Insert();
    end;

    procedure InitializeGuidedExperienceItems(CallerModuleInfo: ModuleInfo)
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.OnRegisterAssistedSetup();
        GuidedExperience.OnRegisterManualSetup();
        GuidedExperience.OnRegisterGuidedExperienceItem();

        GuidedExperience.InsertLearnLink(MicrosoftLearnLongTitleLbl, MicrosoftLearnShortTitleLbl, MicrosoftLearnDescriptionLbl,
            10, 'https://go.microsoft.com/fwlink/?linkid=2152979');
    end;

    procedure ShowChecklistBannerVisibilityNotification()
    var
        ChangeBannerVisibilityNotification: Notification;
    begin
        if IsChecklistVisible() then
            exit;

        if not DoesUserHaveChecklistItemsAssigned(CopyStr(UserId(), 1, 50)) then
            exit;

        ChangeBannerVisibilityNotification.Message(ChangeBannerVisibilityLbl);
        ChangeBannerVisibilityNotification.Scope := NotificationScope::LocalScope;
        ChangeBannerVisibilityNotification.AddAction(ShowChecklistLbl, Codeunit::"Checklist Implementation", 'SetChecklistVisibility');
        ChangeBannerVisibilityNotification.Send();
    end;

    procedure SetChecklistVisibility(ChangeVisibilityNotification: Notification)
    begin
        SetChecklistVisibility(UserId(), true);
    end;

    procedure SetChecklistVisibility(UserName: Text; Visible: Boolean)
    begin
        SetChecklistVisibility(UserName, Visible, false);
    end;

    procedure SetChecklistVisibility(UserName: Text; Visible: Boolean; SessionUpdateRequired: Boolean)
    var
        UserPersonalization: Record "User Personalization";
        GuidedExperienceImpl: Codeunit "Guided Experience Impl.";
        Dimensions: Dictionary of [Text, Text];
        SessionSettings: SessionSettings;
    begin
        if SetChecklistVisibility(UserName, Visible, UserPersonalization) then begin
            if UserPersonalization."Profile ID" = '' then
                if UserPersonalization.Get(UserSecurityId()) then;

            GuidedExperienceImpl.AddCompanyNameDimension(Dimensions);
            GuidedExperienceImpl.AddRoleDimension(Dimensions, UserPersonalization);

            If SessionUpdateRequired then begin
                SessionSettings.RequestSessionUpdate(false);
                Session.LogMessage('0000EIU', UserResurfacedBannerNewSessionLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, Dimensions);
            end else
                Session.LogMessage('0000EIS', UserResurfacedBannerLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, Dimensions);
        end;
    end;

    local procedure SetChecklistVisibility(UserName: Text; Visible: Boolean; var UserPersonalization: Record "User Personalization"): Boolean
    var
        UserChecklistStatus: Record "User Checklist Status";
        UserNameCode: Code[50];
    begin
        UserNameCode := CopyStr(UserName, 1, 50);

        if GetUserChecklistStatusForCurrentRole(UserChecklistStatus) then begin
            if UserChecklistStatus."Is Visible" = Visible then
                exit(false);

            UserChecklistStatus."Is Visible" := Visible;

            if UserChecklistStatus."Checklist Status" = UserChecklistStatus."Checklist Status"::Skipped then
                UserChecklistStatus."Checklist Status" := UserChecklistStatus."Checklist Status"::"In progress";

            UserChecklistStatus.Modify();

            exit(true);
        end else
            if UserPersonalization.Get(UserSecurityId()) then begin
                CreateNewUserChecklistStatus(UserChecklistStatus, UserNameCode, UserPersonalization."Profile ID",
                    UserChecklistStatus."Checklist Status"::"Not Started", Visible);

                exit(true);
            end;

        exit(false);
    end;

    procedure UpdateUserName(var RecordRef: RecordRef; Company: Text[30]; UserName: Text[50]; TableID: Integer)
    begin
        case TableID of
            Database::"Checklist Item User":
                ChangeUserForChecklistItemUser(RecordRef, Company, UserName);
            Database::"User Checklist Status":
                ChangeUserForUserChecklistStatus(RecordRef, Company, UserName);
        end;
    end;

    local procedure GetLinkAndVideoUrl(var Link: Text[250]; var VideoUrl: Text[250]; GuidedExperienceType: Enum "Guided Experience Type")
    begin
        if Link = '' then
            VideoUrl := ''
        else
            if GuidedExperienceType = GuidedExperienceType::Learn then
                VideoUrl := ''
            else begin
                VideoUrl := Link;
                Link := '';
            end;
    end;

    local procedure ChangeUserForChecklistItemUser(var RecordRef: RecordRef; Company: Text[30]; UserName: Text[50])
    var
        ChecklistItemUser: Record "Checklist Item User";
    begin
        ChecklistItemUser.ChangeCompany(Company);
        RecordRef.SetTable(ChecklistItemUser);
        ChecklistItemUser.Rename(ChecklistItemUser.Code, UserName);
    end;

    local procedure ChangeUserForUserChecklistStatus(var RecordRef: RecordRef; Company: Text[30]; UserName: Text[50])
    var
        UserChecklistStatus: Record "User Checklist Status";
    begin
        UserChecklistStatus.ChangeCompany(Company);
        RecordRef.SetTable(UserChecklistStatus);
        UserChecklistStatus.Rename(UserName, UserChecklistStatus."Role ID");
    end;

    procedure IsUsersFirstLogin(): Boolean
    var
        UserLoginTimeTracker: Codeunit "User Login Time Tracker";
    begin
        // We want to know whether this is the first time the user is logging in, but because our event is fired after system initialization, 
        // the user will already have a record in the User Login Times table, but no penultimate login date time.
        exit((not UserLoginTimeTracker.IsFirstLogin(UserSecurityId())) and (UserLoginTimeTracker.GetPenultimateLoginDateTime() = 0DT));
    end;

    procedure DoesUserHaveChecklistItemsAssigned(UserName: Code[50]): Boolean
    var
        UserPersonalization: Record "User Personalization";
    begin
        if not UserPersonalization.Get(UserSecurityId()) then
            exit(false);

        exit(DoesUserHaveChecklistItemsAssigned(UserName, UserPersonalization."Profile ID"));
    end;

    procedure DoesUserHaveChecklistItemsAssigned(UserName: Code[50]; RoleID: Code[30]): Boolean
    var
        ChecklistItemUser: Record "Checklist Item User";
        ChecklistItemRole: Record "Checklist Item Role";
    begin
        ChecklistItemUser.SetRange("User ID", UserName);
        ChecklistItemUser.SetRange("Assigned to User", true);
        if not ChecklistItemUser.IsEmpty() then
            exit(true);

        ChecklistItemRole.SetRange("Role ID", RoleID);
        exit(not ChecklistItemRole.IsEmpty());
    end;

    procedure SwitchRole(UserName: Code[50]; NewRoleID: Code[30])
    var
        UserChecklistStatus: Record "User Checklist Status";
    begin
        if GetUserChecklistStatusForCurrentRole(UserChecklistStatus) then
            if UserChecklistStatus."Role ID" = NewRoleID then
                exit;

        SwitchVisibilityForChecklistItemUsers(UserName, NewRoleID);
        SwitchRoleOnUserChecklistStatus(UserChecklistStatus, UserName, NewRoleID);
    end;

    local procedure SwitchVisibilityForChecklistItemUsers(UserName: Code[50]; NewRoleID: Code[30])
    var
        ChecklistItemUser: Record "Checklist Item User";
        ChecklistItemRole: Record "Checklist Item Role";
    begin
        ChecklistItemUser.SetRange("User ID", UserName);
        ChecklistItemUser.SetRange("Assigned to User", false);
        ChecklistItemUser.SetRange("Is Visible", true);
        if not ChecklistItemUser.IsEmpty() then
            ChecklistItemUser.ModifyAll("Is Visible", false);

        ChecklistItemRole.SetRange("Role ID", NewRoleID);
        if ChecklistItemRole.FindSet() then
            repeat
                if ChecklistItemUser.Get(ChecklistItemRole.Code, UserName) then begin
                    ChecklistItemUser."Is Visible" := true;
                    ChecklistItemUser.Modify();
                end;
            until ChecklistItemRole.Next() = 0;
    end;

    procedure GetUserChecklistStatusForCurrentRole(var UserChecklistStatus: Record "User Checklist Status"): Boolean
    begin
        UserChecklistStatus.SetRange("User ID", UserId());
        UserChecklistStatus.SetRange("Is Current Role Center", true);
        exit(UserChecklistStatus.FindFirst());
    end;

    local procedure SwitchRoleOnUserChecklistStatus(var UserChecklistStatus: Record "User Checklist Status"; UserName: Code[50]; NewRoleID: Code[30])
    var
        IsVisible: Boolean;
    begin
        if GetUserChecklistStatusForCurrentRole(UserChecklistStatus) then begin
            UserChecklistStatus."Is Current Role Center" := false;
            UserChecklistStatus.Modify();
        end;

        if UserChecklistStatus.Get(UserName, NewRoleID) then begin
            UserChecklistStatus."Is Current Role Center" := true;
            UserChecklistStatus.Modify();
        end else begin
            if not DoesUserHaveChecklistItemsAssigned(UserName, NewRoleID) then
                IsVisible := false
            else
                if IsUsersFirstLogin() then
                    IsVisible := true
                else begin
                    UserChecklistStatus.Reset();
                    UserChecklistStatus.SetRange("User ID", UserName);
                    UserChecklistStatus.SetFilter("Checklist Status", '=%1', "Checklist Status"::Skipped);

                    IsVisible := UserChecklistStatus.IsEmpty();
                end;

            CreateNewUserChecklistStatus(UserChecklistStatus, UserName, NewRoleID,
                UserChecklistStatus."Checklist Status"::"Not Started", IsVisible);
        end;
    end;

    procedure UpdateCode(OldCode: Code[300]; NewCode: Code[300])
    var
        ChecklistItem: Record "Checklist Item";
        NewChecklistItem: Record "Checklist Item";
    begin
        if not ChecklistItem.Get(OldCode) then
            exit;

        NewChecklistItem.TransferFields(ChecklistItem);
        NewChecklistItem.Code := NewCode;
        NewChecklistItem.Insert();

        UpdateChecklistItemRoleCode(OldCode, NewCode);
        UpdateChecklistItemUserCode(OldCode, NewCode);

        ChecklistItem.Delete();
    end;

    procedure UpdateChecklistItem(Code: Code[300]; CompletionRequirements: Enum "Checklist Completion Requirements"; OrderID: Integer)
    var
        ChecklistItem: Record "Checklist Item";
    begin
        if ChecklistItem.Get(Code) then
            UpdateChecklistItem(ChecklistItem, CompletionRequirements, OrderID);
    end;

    procedure UpdateVersionForSkippedChecklistItems(Code: Code[300]; NewVersion: Integer)
    var
        ChecklistItemUser: Record "Checklist Item User";
    begin
        ChecklistItemUser.SetRange(Code, Code);
        ChecklistItemUser.SetRange("Checklist Item Status", ChecklistItemUser."Checklist Item Status"::Skipped);
        if not ChecklistItemUser.IsEmpty() then
            ChecklistItemUser.ModifyAll(Version, NewVersion);
    end;

    procedure CreateNewUserChecklistStatus(var UserChecklistStatus: Record "User Checklist Status"; UserName: Code[50]; RoleID: Code[30]; ChecklistStatus: Enum "Checklist Status"; IsVisible: Boolean)
    begin
        if GetUserChecklistStatusForCurrentRole(UserChecklistStatus) then
            exit;

        UserChecklistStatus."User ID" := UserName;
        UserChecklistStatus."Is Current Role Center" := true;
        UserChecklistStatus."Checklist Status" := ChecklistStatus;
        UserChecklistStatus."Is Visible" := IsVisible;
        UserChecklistStatus."Role ID" := RoleID;
        UserChecklistStatus.Insert();
    end;

    procedure IsChecklistVisible(): Boolean
    var
        UserChecklistStatus: Record "User Checklist Status";
    begin
        if not GetUserChecklistStatusForCurrentRole(UserChecklistStatus) then
            exit(false);

        exit(UserChecklistStatus."Is Visible");
    end;

    local procedure InsertChecklistItemUsers(var TempUsers: Record User temporary; Code: Code[300])
    begin
        if TempUsers.FindSet() then
            repeat
                InsertChecklistItemUser(Code, TempUsers."User Name");
            until TempUsers.Next() = 0;
    end;

    local procedure InsertChecklistItemRoles(var TempAllProfile: Record "All Profile" temporary; Code: Code[300])
    begin
        if TempAllProfile.FindSet() then
            repeat
                InsertChecklistItemRole(Code, TempAllProfile."Profile ID");
            until TempAllProfile.Next() = 0;
    end;

    local procedure UpdateChecklistItem(ChecklistItem: Record "Checklist Item"; CompletionRequirements: Enum "Checklist Completion Requirements"; OrderID: Integer)
    begin
        ChecklistItem."Completion Requirements" := CompletionRequirements;
        ChecklistItem."Order ID" := OrderID;
        ChecklistItem.Modify();
    end;

    local procedure UpdateChecklistItemRoles(Code: Code[300]; var TempAllProfile: Record "All Profile" temporary)
    var
        ChecklistItemRole: Record "Checklist Item Role";
        TempAllProfileToInsert: Record "All Profile" temporary;
    begin
        GetRolesListCopy(TempAllProfile, TempAllProfileToInsert);

        ChecklistItemRole.SetRange(Code, Code);
        if ChecklistItemRole.FindSet() then
            repeat
                TempAllProfileToInsert.SetRange("Profile ID", ChecklistItemRole."Role ID");
                if TempAllProfileToInsert.FindFirst() then
                    TempAllProfileToInsert.Delete()
                else
                    ChecklistItemRole.Delete();
            until ChecklistItemRole.Next() = 0;

        TempAllProfileToInsert.Reset();
        if not TempAllProfileToInsert.IsEmpty() then
            InsertChecklistItemRoles(TempAllProfileToInsert, Code);
    end;

    local procedure UpdateChecklistItemUsers(Code: Code[300]; var TempUsers: Record User temporary; var TempAllProfile: Record "All Profile" temporary)
    var
        ChecklistItemUser: Record "Checklist Item User";
        TempUsersToInsert: Record User temporary;
        RoleID: Code[30];
    begin
        GetUsersListCopy(TempUsers, TempUsersToInsert);

        ChecklistItemUser.SetRange(Code, Code);
        if ChecklistItemUser.FindSet() then
            repeat
                TempUsersToInsert.SetRange("User Name", ChecklistItemUser."User ID");
                if TempUsersToInsert.FindFirst() then
                    TempUsersToInsert.Delete()
                else
                    if ChecklistItemUser."Checklist Item Status" = ChecklistItemUser."Checklist Item Status"::"Not Started" then
                        ChecklistItemUser.Delete()
                    else begin
                        RoleID := GetUserRole(ChecklistItemUser."User ID");
                        TempAllProfile.SetRange("Profile ID", RoleID);
                        if TempAllProfile.IsEmpty() then
                            ChecklistItemUser."Is Visible" := false;

                        ChecklistItemUser."Assigned to User" := false;
                        ChecklistItemUser.Modify();
                    end;
            until ChecklistItemUser.Next() = 0;

        TempUsersToInsert.Reset();
        if not TempUsersToInsert.IsEmpty() then
            InsertChecklistItemUsers(TempUsersToInsert, Code);
    end;

    local procedure GetRolesListCopy(var TempAllProfile: Record "All Profile" temporary; var TempAllProfileCopy: Record "All Profile" temporary)
    begin
        TempAllProfileCopy.DeleteAll();

        TempAllProfile.Reset();
        if TempAllProfile.FindSet() then
            repeat
                TempAllProfileCopy.TransferFields(TempAllProfile);
                TempAllProfileCopy.Insert();
            until TempAllProfile.Next() = 0;
    end;

    local procedure GetUsersListCopy(var TempUsers: Record User temporary; var UsersCopyTemp: Record User temporary)
    begin
        UsersCopyTemp.DeleteAll();

        TempUsers.Reset();
        if TempUsers.FindSet() then
            repeat
                UsersCopyTemp.TransferFields(TempUsers);
                UsersCopyTemp.Insert();
            until TempUsers.Next() = 0;
    end;

    local procedure GetUserRole(UserID: Code[50]): Code[30]
    var
        UserPersonalization: Record "User Personalization";
    begin
        UserPersonalization.SetRange("User ID", UserID);
        if UserPersonalization.FindFirst() then
            exit(UserPersonalization."Profile ID");
    end;

    local procedure UpdateChecklistItemRoleCode(OldCode: Code[300]; NewCode: Code[300])
    var
        OldChecklistItemRole: Record "Checklist Item Role";
        NewChecklistItemRole: Record "Checklist Item Role";
    begin
        OldChecklistItemRole.SetRange(Code, OldCode);
        if not OldChecklistItemRole.FindSet() then
            exit;

        repeat
            NewChecklistItemRole.TransferFields(OldChecklistItemRole);
            NewChecklistItemRole.Code := NewCode;
            NewChecklistItemRole.Insert();
        until OldChecklistItemRole.Next() = 0;

        OldChecklistItemRole.SetRange(Code, OldCode);
        OldChecklistItemRole.DeleteAll();
    end;

    local procedure UpdateChecklistItemUserCode(OldCode: Code[300]; NewCode: Code[300])
    var
        OldChecklistItemUser: Record "Checklist Item User";
        NewChecklistItemUser: Record "Checklist Item User";
    begin
        OldChecklistItemUser.SetRange(Code, OldCode);
        if not OldChecklistItemUser.FindSet() then
            exit;

        repeat
            NewChecklistItemUser.TransferFields(OldChecklistItemUser);
            NewChecklistItemUser.Code := NewCode;
            NewChecklistItemUser.Insert();
        until OldChecklistItemUser.Next() = 0;

        OldChecklistItemUser.SetRange(Code, OldCode);
        OldChecklistItemUser.DeleteAll();
    end;

    procedure GetCurrentDateTimeInUTC(): DateTime
    var
        CurrentDateTimeUTC: DateTime;
    begin
        Evaluate(CurrentDateTimeUTC, Format(CurrentDateTime(), 0, 9));

        exit(CurrentDateTimeUTC);
    end;

    local procedure LogMessageOnDatabaseEvent(Code: Code[300]; Tag: Text; Message: Text)
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        GuidedExperienceImpl: Codeunit "Guided Experience Impl.";
        Dimensions: Dictionary of [Text, Text];
    begin
        GuidedExperienceItem.SetRange(Code, Code);
        if not GuidedExperienceItem.FindLast() then
            exit;

        GuidedExperienceImpl.AddGuidedExperienceItemDimensions(Dimensions, GuidedExperienceItem, 'Checklist');
        GuidedExperienceImpl.AddCompanyNameDimension(Dimensions);
        Session.LogMessage(Tag, Message, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation,
            TelemetryScope::ExtensionPublisher, Dimensions);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Checklist Item", 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterChecklistItemInsert(var Rec: Record "Checklist Item")
    begin
        if Rec.IsTemporary() then
            exit;

        LogMessageOnDatabaseEvent(Rec.Code, '0000EIO', ChecklistItemInsertedLbl);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Checklist Item", 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnAfterChecklistItemDelete(var Rec: Record "Checklist Item")
    begin
        if Rec.IsTemporary() then
            exit;

        LogMessageOnDatabaseEvent(Rec.Code, '0000EIP', ChecklistItemDeletedLbl);
    end;
}