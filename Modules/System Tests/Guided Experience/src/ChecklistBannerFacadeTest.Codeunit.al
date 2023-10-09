// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Environment.Configuration;

using System.Reflection;
using System.Environment.Configuration;
using System.Environment;
using System.Media;
using System.TestLibraries.Utilities;
using System.TestLibraries.Security.AccessControl;

codeunit 132619 "Checklist Banner Facade Test"
{
    Subtype = Test;
    EventSubscriberInstance = Manual;
    Permissions = tabledata "All Profile" = r,
                tabledata "User Personalization" = rm;

    var
        Any: Codeunit Any;
        Assert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";

    [Test]
    [HandlerFunctions('ChecklistBannerHandlerForSkippingWelcomePage')]
    procedure TestSkipChecklistBannerWelcomePage()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        TempProfileAllProfile: Record "All Profile" temporary;
        SkipWelcomePage: Codeunit "Skip Welcome Banner";
        Checklist: Codeunit Checklist;
        SystemActionTriggers: Codeunit "System Action Triggers";
        ChecklistBannerContainer: Page "Checklist Banner Container";
        GuidedExperienceType: Enum "Guided Experience Type";
        ProfileID: Code[30];
        PartID: Integer;
    begin
        BindSubscription(SkipWelcomePage);

        PermissionsMock.Start();
        PermissionsMock.Set('SUPER');

        // [GIVEN] The current company type is evaluation
        SetCompanyTypeToEvaluation(true);

        // [GIVEN] A user profile
        InsertProfile(ProfileID);
        AddRoleToList(TempProfileAllProfile, ProfileID);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] One guided experience item
        InsertGuidedExperienceItem(GuidedExperienceItem, GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"Assisted Setup Wizard", '');

        // [GIVEN] The checklist item for the guided experience item
        Checklist.Insert(GuidedExperienceItem."Guided Experience Type", GetObjectType(GuidedExperienceItem."Object Type to Run"),
            GuidedExperienceItem."Object ID to Run", 100, TempProfileAllProfile, true);

        // [GIVEN] The current profile is set to ProfileID
        SetCurrentProfile(ProfileID);

        // [WHEN] Calling GetRoleCenterBannerPartID (this will trigger the event subscriber 
        // that switches the role for the user checklist status and returns the ID of the checklist banner)
        SystemActionTriggers.GetRoleCenterBannerPartID(PartID);

        // [WHEN] The checklist banner is run
        ChecklistBannerContainer.Run();

        // [THEN] Verifications will be done via the ChecklistBannerHandlerForSkippingWelcomePage page handler

        UnbindSubscription(SkipWelcomePage);
    end;

    [Test]
    [HandlerFunctions('ChecklistBannerHandlerForCustomizingBannerLabels')]
    procedure TestCustomizeChecklistBannerLabels()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        TempProfileAllProfile: Record "All Profile" temporary;
        CustomizeBannerLabel: Codeunit "Customize Banner Label";
        Checklist: Codeunit Checklist;
        SystemActionTriggers: Codeunit "System Action Triggers";
        ChecklistBannerContainer: Page "Checklist Banner Container";
        GuidedExperienceType: Enum "Guided Experience Type";
        ProfileID: Code[30];
        PartID: Integer;
    begin
        BindSubscription(CustomizeBannerLabel);

        PermissionsMock.Start();
        PermissionsMock.Set('SUPER');

        // [GIVEN] The current company type is evaluation
        SetCompanyTypeToEvaluation(true);

        // [GIVEN] A user profile
        InsertProfile(ProfileID);
        AddRoleToList(TempProfileAllProfile, ProfileID);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] One guided experience item
        InsertGuidedExperienceItem(GuidedExperienceItem, GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"Assisted Setup Wizard", '');

        // [GIVEN] The checklist item for the guided experience item
        Checklist.Insert(GuidedExperienceItem."Guided Experience Type", GetObjectType(GuidedExperienceItem."Object Type to Run"),
            GuidedExperienceItem."Object ID to Run", 100, TempProfileAllProfile, true);

        // [GIVEN] The current profile is set to ProfileID
        SetCurrentProfile(ProfileID);

        // [WHEN] Calling GetRoleCenterBannerPartID (this will trigger the event subscriber 
        // that switches the role for the user checklist status and returns the ID of the checklist banner)
        SystemActionTriggers.GetRoleCenterBannerPartID(PartID);

        // [WHEN] The checklist banner is run
        ChecklistBannerContainer.Run();

        // [THEN] Verifications will be done via the ChecklistBannerHandlerForSkippingWelcomePage page handler

        UnbindSubscription(CustomizeBannerLabel);
    end;


    [PageHandler]
    procedure ChecklistBannerHandlerForSkippingWelcomePage(var ChecklistBannerContainer: TestPage "Checklist Banner Container")
    begin
        VerifyBannerTexts(ChecklistBannerContainer,
            'Get started',
            'Get started:',
            'Here are a few things you can try out',
            'Here are a few things you can try out',
            'The Cronus company data you are using is for demonstration, evaluation, and training purposes.');
    end;

    [PageHandler]
    procedure ChecklistBannerHandlerForCustomizingBannerLabels(var ChecklistBannerContainer: TestPage "Checklist Banner Container")
    begin
        VerifyBannerTexts(ChecklistBannerContainer,
            'Title Text',
            'Title Collap Text',
            'Header Text',
            'Header Collap Text',
            'Description Text');
    end;

    local procedure VerifyBannerTexts(ChecklistBannerContainer: TestPage "Checklist Banner Container"; Title: Text; CollapsedTitle: Text; Header: Text; CollapsedHeader: Text; Description: Text)
    begin
        Assert.AreEqual(Title, ChecklistBannerContainer.ChecklistBanner.Title.Value(), 'The title is incorrect.');
        Assert.AreEqual(CollapsedTitle, ChecklistBannerContainer.ChecklistBanner.TitleCollapsed.Value(), 'The collapsed title is incorrect.');
        Assert.AreEqual(Header, ChecklistBannerContainer.ChecklistBanner.Header.Value(), 'The header is incorrect.');
        Assert.AreEqual(CollapsedHeader, ChecklistBannerContainer.ChecklistBanner.HeaderCollapsed.Value(), 'The collapsed header is incorrect.');
        Assert.AreEqual(Description, ChecklistBannerContainer.ChecklistBanner.Description.Value(), 'The description is incorrect.');
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
}