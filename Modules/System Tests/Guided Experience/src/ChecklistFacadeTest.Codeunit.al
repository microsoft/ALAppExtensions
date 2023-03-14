// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132604 "Checklist Facade Test"
{
    Subtype = Test;
    EventSubscriberInstance = Manual;
    Permissions = tabledata "Guided Experience Item" = rimd,
                    tabledata "Checklist Item" = rimd,
                    tabledata "Checklist Item Role" = rimd,
                    tabledata "Checklist Item User" = rimd,
                    tabledata "Checklist Setup" = rimd,
                    tabledata "Spotlight Tour Text" = rimd,
                    tabledata "All Profile" = ri,
                    tabledata User = ri,
                    tabledata Company = rm;

    var
        Assert: Codeunit "Library Assert";
        Any: Codeunit Any;
        PermissionsMock: Codeunit "Permissions Mock";
        ProfileID1: Code[30];
        ProfileID2: Code[30];
        ProfileID3: Code[30];
        ProfileID4: Code[30];

    trigger OnRun()
    begin
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertAssistedSetupChecklistItemWithNoGuidedExperienceItemAndProfiles()
    var
        ChecklistItem: Record "Checklist Item";
        TempAllProfile: Record "All Profile" temporary;
        Checklist: Codeunit Checklist;
        GuidedExperienceType: Enum "Guided Experience Type";
        ObjectTypeToRun: ObjectType;
        ObjectIdToRun: Integer;
        OrderId: Integer;
    begin
        // [GIVEN] The guided experience item table is empty
        Initialize(true);

        AddRoleToList(TempAllProfile, ProfileID1);

        PermissionsMock.Set('Guided Exp Edit');

        // [WHEN] Inserting a new checklist item for an inexistent assisted setup guided experience item and a list of profiles
        ObjectTypeToRun := ObjectType::Page;
        ObjectIdToRun := Page::Checklist;
        OrderId := 1573;

        Checklist.Insert(GuidedExperienceType::"Assisted Setup", ObjectTypeToRun, ObjectIdToRun, OrderId, TempAllProfile, true);

        // [THEN] The checklist item table is empty
        ChecklistItem.Reset();
        Assert.AreEqual(0, ChecklistItem.Count(), 'The checklist item table should be empty');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertAssistedSetupChecklistItemWithWrongGuidedExperienceItemAndProfiles()
    var
        ChecklistItem: Record "Checklist Item";
        TempAllProfile: Record "All Profile" temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        ObjectTypeToRun1: ObjectType;
        ObjectTypeToRun2: ObjectType;
        ObjectIdToRun1: Integer;
        ObjectIdToRun2: Integer;
    begin
        Initialize(false);

        AddRoleToList(TempAllProfile, ProfileID1);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type assisted setup
        ObjectTypeToRun1 := ObjectType::Page;
        ObjectIdToRun1 := Page::Checklist;
        GuidedExperience.InsertAssistedSetup('Title', 'Short Title', 'Description', 10, ObjectTypeToRun1,
            ObjectIdToRun1, AssistedSetupGroup::Uncategorized, '', VideoCategory::Uncategorized, '');

        // [WHEN] Inserting a new checklist item for a different assisted setup (that doesn't exist in the guided 
        // experience item table) and a list of profiles
        ObjectTypeToRun2 := ObjectType::Codeunit;
        ObjectIdToRun2 := Codeunit::"Guided Experience";

        Checklist.Insert(GuidedExperienceType::"Assisted Setup", ObjectTypeToRun2, ObjectIdToRun2, 14, TempAllProfile, true);

        // [THEN] The checklist item table is empty
        ChecklistItem.Reset();
        Assert.AreEqual(0, ChecklistItem.Count(), 'The checklist item table should be empty');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertAssistedSetupChecklistItemWithWrongGuidedExperienceTypeAndProfiles()
    var
        ChecklistItem: Record "Checklist Item";
        TempAllProfile: Record "All Profile" temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        ObjectTypeToRun: ObjectType;
        ObjectIdToRun: Integer;
    begin
        Initialize(false);

        AddRoleToList(TempAllProfile, ProfileID1);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type assisted setup
        ObjectTypeToRun := ObjectType::Page;
        ObjectIdToRun := Page::Checklist;
        GuidedExperience.InsertAssistedSetup('Title', 'Short Title', 'Description', 10, ObjectTypeToRun,
            ObjectIdToRun, AssistedSetupGroup::Uncategorized, '', VideoCategory::Uncategorized, '');

        // [WHEN] Inserting a new checklist item for the same object, but a different guided experience 
        // type and a list of profiles
        Checklist.Insert(GuidedExperienceType::"Manual Setup", ObjectTypeToRun, ObjectIdToRun, 20, TempAllProfile, true);

        // [THEN] The checklist item table is empty
        ChecklistItem.Reset();
        Assert.AreEqual(0, ChecklistItem.Count(), 'The checklist item table should be empty');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertAssistedSetupChecklistItemWithProfiles()
    var
        ChecklistItem: Record "Checklist Item";
        ChecklistItemRole: Record "Checklist Item Role";
        GuidedExperienceItem: Record "Guided Experience Item";
        TempAllProfile: Record "All Profile" temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        CompletionRequirements: Enum "Checklist Completion Requirements";
        ObjectTypeToRun: ObjectType;
        ObjectIdToRun: Integer;
        OrderID: Integer;
    begin
        Initialize(false);

        AddRoleToList(TempAllProfile, ProfileID1);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type assisted setup
        ObjectTypeToRun := ObjectType::Page;
        ObjectIdToRun := Page::Checklist;
        GuidedExperience.InsertAssistedSetup('Title', 'Short Title', 'Description', 10, ObjectTypeToRun,
            ObjectIdToRun, AssistedSetupGroup::Uncategorized, '', VideoCategory::Uncategorized, '');

        // [WHEN] Inserting a new checklist item for the same object and a list of profiles
        OrderID := 23;
        Checklist.Insert(GuidedExperienceType::"Assisted Setup", ObjectTypeToRun, ObjectIdToRun, OrderID, TempAllProfile, true);

        // [THEN] The checklist item table contains exactly one record
        ChecklistItem.Reset();
        Assert.AreEqual(1, ChecklistItem.Count(), 'The checklist item table should contain exactly one record.');

        // [THEN] The checklist item's fields are set correctly
        GuidedExperienceItem.FindFirst();
        ChecklistItem.FindFirst();
        VerifyChecklistItemFields(ChecklistItem, GuidedExperienceItem.Code, CompletionRequirements::Everyone, OrderID);

        // [THEN] The checklist item role table contains exactly one record
        ChecklistItem.Reset();
        Assert.AreEqual(1, ChecklistItemRole.Count(), 'The checklist item table should contain exactly one record.');

        // [THEN] The checklist item role's fields are set correctly
        ChecklistItemRole.FindFirst();
        VerifyChecklistItemRoleFields(ChecklistItemRole, GuidedExperienceItem.Code, TempAllProfile."Profile ID");

        // [WHEN] Inserting an identical checklist item 
        Checklist.Insert(GuidedExperienceType::"Assisted Setup", ObjectTypeToRun, ObjectIdToRun, OrderID, TempAllProfile, true);

        // [THEN] The checklist item and checklist item role tables still contain only one record
        Assert.AreEqual(1, ChecklistItem.Count, 'The checklist item table should not contain a new record.');
        Assert.AreEqual(1, ChecklistItemRole.Count, 'The checklist item role table should not contain a new record.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertDuplicateAssistedSetupChecklistItemWithProfiles()
    var
        ChecklistItem: Record "Checklist Item";
        ChecklistItemRole: Record "Checklist Item Role";
        TempAllProfile: Record "All Profile" temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        ObjectTypeToRun: ObjectType;
        ObjectIdToRun: Integer;
        OrderID1: Integer;
    begin
        Initialize(false);

        AddRoleToList(TempAllProfile, ProfileID1);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type assisted setup
        ObjectTypeToRun := ObjectType::Page;
        ObjectIdToRun := Page::Checklist;
        GuidedExperience.InsertAssistedSetup('Title', 'Short Title', 'Description', 10, ObjectTypeToRun,
            ObjectIdToRun, AssistedSetupGroup::Uncategorized, '', VideoCategory::Uncategorized, '');

        // [WHEN] Inserting a new checklist item for the same object and a list of profiles
        OrderID1 := 23;
        Checklist.Insert(GuidedExperienceType::"Assisted Setup", ObjectTypeToRun, ObjectIdToRun, OrderID1, TempAllProfile, true);

        // [THEN] The checklist item and checklist item role tables contain exactly one record
        Assert.AreEqual(1, ChecklistItem.Count(), 'The checklist item table should contain exactly one record.');
        Assert.AreEqual(1, ChecklistItemRole.Count(), 'The checklist item table should contain exactly one record.');

        // [WHEN] Inserting an identical checklist item 
        Checklist.Insert(GuidedExperienceType::"Assisted Setup", ObjectTypeToRun, ObjectIdToRun, OrderID1, TempAllProfile, true);

        // [THEN] The checklist item and checklist item role tables still contain only one record
        Assert.AreEqual(1, ChecklistItem.Count, 'The checklist item table should not contain a new record.');
        Assert.AreEqual(1, ChecklistItemRole.Count, 'The checklist item role table should not contain a new record.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestUpdateAssistedSetupChecklistItemWithProfiles()
    var
        ChecklistItem: Record "Checklist Item";
        ChecklistItemRole: Record "Checklist Item Role";
        GuidedExperienceItem: Record "Guided Experience Item";
        TempAllProfile: Record "All Profile" temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        CompletionRequirements: Enum "Checklist Completion Requirements";
        ObjectTypeToRun: ObjectType;
        ObjectIdToRun: Integer;
        OrderID1: Integer;
        OrderID2: Integer;
    begin
        Initialize(false);

        AddRoleToList(TempAllProfile, ProfileID1);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type assisted setup
        ObjectTypeToRun := ObjectType::Page;
        ObjectIdToRun := Page::Checklist;
        GuidedExperience.InsertAssistedSetup('Title', 'Short Title', 'Description', 10, ObjectTypeToRun,
            ObjectIdToRun, AssistedSetupGroup::Uncategorized, '', VideoCategory::Uncategorized, '');

        // [WHEN] Inserting a new checklist item for the same object and a list of profiles
        OrderID1 := 23;
        Checklist.Insert(GuidedExperienceType::"Assisted Setup", ObjectTypeToRun, ObjectIdToRun, OrderID1, TempAllProfile, true);

        // [THEN] The checklist item and checklist item role tables contain exactly one record
        Assert.AreEqual(1, ChecklistItem.Count(), 'The checklist item table should contain exactly one record.');
        Assert.AreEqual(1, ChecklistItemRole.Count(), 'The checklist item table should contain exactly one record.');

        // [WHEN] Inserting a checklist item for the same guided experience item, but with a different order ID and completion requirements
        OrderID2 := 36;
        Checklist.Insert(GuidedExperienceType::"Assisted Setup", ObjectTypeToRun, ObjectIdToRun, OrderID2, TempAllProfile, false);

        // [THEN] The Checklist item table still contains only one record, but the order id and completion requirements have changed
        GuidedExperienceItem.FindFirst();
        ChecklistItem.FindFirst();
        VerifyChecklistItemFields(ChecklistItem, GuidedExperienceItem.Code, CompletionRequirements::Anyone, OrderID2);

        // [THEN] The checklist item role table still contains only one record
        Assert.AreEqual(1, ChecklistItemRole.Count, 'The checklist item role table should not contain a new record.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestUpdateProfilesForAssistedSetupChecklistItem()
    var
        ChecklistItem: Record "Checklist Item";
        ChecklistItemRole: Record "Checklist Item Role";
        TempAllProfile: Record "All Profile" temporary;
        TempAllProfile2: Record "All Profile" temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        ObjectTypeToRun: ObjectType;
        ObjectIdToRun: Integer;
        OrderID: Integer;
    begin
        Initialize(false);

        AddRoleToList(TempAllProfile, ProfileID1);
        AddRoleToList(TempAllProfile, ProfileID2);

        AddRoleToList(TempAllProfile2, ProfileID1);
        AddRoleToList(TempAllProfile2, ProfileID3);
        AddRoleToList(TempAllProfile2, ProfileID4);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type assisted setup
        ObjectTypeToRun := ObjectType::Page;
        ObjectIdToRun := Page::Checklist;
        GuidedExperience.InsertAssistedSetup('Title', 'Short Title', 'Description', 10, ObjectTypeToRun,
            ObjectIdToRun, AssistedSetupGroup::Uncategorized, '', VideoCategory::Uncategorized, '');

        // [WHEN] Inserting a new checklist item for the same object and a list of profiles  
        OrderID := 23;
        Checklist.Insert(GuidedExperienceType::"Assisted Setup", ObjectTypeToRun, ObjectIdToRun, OrderID, TempAllProfile, true);

        // [THEN] The checklist item table contains one record 
        Assert.AreEqual(1, ChecklistItem.Count(), 'The checklist item table should contain exactly one record.');

        // [THEN] The checklist item role table contains two records
        Assert.AreEqual(2, ChecklistItemRole.Count(), 'The checklist item role table should contain two records.');

        // [WHEN] Inserting a checklist item for the same guided experience item, but with a different profile list
        Checklist.Insert(GuidedExperienceType::"Assisted Setup", ObjectTypeToRun, ObjectIdToRun, OrderID, TempAllProfile2, true);

        // [THEN] The checklist item role table contains three records
        Assert.AreEqual(3, ChecklistItemRole.Count, 'The checklist item role table should contain 3 records.');

        // [THEN] The checklist item roles have the correct profiles and codes
        ChecklistItem.FindFirst();

        Assert.IsTrue(ChecklistItemRole.Get(ChecklistItem.Code, ProfileID1), 'The checklist item role with profile ID 1 should exist.');
        Assert.IsTrue(ChecklistItemRole.Get(ChecklistItem.Code, ProfileID3), 'The checklist item role with profile ID 3 should exist.');
        Assert.IsTrue(ChecklistItemRole.Get(ChecklistItem.Code, ProfileID4), 'The checklist item role with profile ID 4 should exist.');
        Assert.IsFalse(ChecklistItemRole.Get(ChecklistItem.Code, ProfileID2), 'The checklist item role with profile ID 2 should NOT exist.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertAssistedSetupChecklistItemWithNoGuidedExperienceItemAndUsers()
    var
        ChecklistItem: Record "Checklist Item";
        TempAllUser: Record User temporary;
        Checklist: Codeunit Checklist;
        GuidedExperienceType: Enum "Guided Experience Type";
        ObjectTypeToRun: ObjectType;
        ObjectIdToRun: Integer;
        OrderId: Integer;
    begin
        // [GIVEN] The guided experience item table is empty
        Initialize(false);

        AddUserToList(TempAllUser, UserSecurityId());

        PermissionsMock.Set('Guided Exp Edit');

        // [WHEN] Inserting a new checklist item for an inexistent assisted setup guided experience item and a list of users
        ObjectTypeToRun := ObjectType::Page;
        ObjectIdToRun := Page::"Guided Experience Item List";
        OrderId := 1573;

        Checklist.Insert(GuidedExperienceType::"Assisted Setup", ObjectTypeToRun, ObjectIdToRun, OrderId, TempAllUser);

        // [THEN] The checklist item table is empty
        ChecklistItem.Reset();
        Assert.AreEqual(0, ChecklistItem.Count(), 'The checklist item table should be empty');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertAssistedSetupChecklistItemWithWrongGuidedExperienceItemAndUsers()
    var
        ChecklistItem: Record "Checklist Item";
        TempAllUser: Record User temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        ObjectTypeToRun1: ObjectType;
        ObjectTypeToRun2: ObjectType;
        ObjectIdToRun1: Integer;
        ObjectIdToRun2: Integer;
    begin
        Initialize(false);

        AddUserToList(TempAllUser, UserSecurityId());

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type assisted setup
        ObjectTypeToRun1 := ObjectType::Page;
        ObjectIdToRun1 := Page::Checklist;
        GuidedExperience.InsertAssistedSetup('Title', 'Short Title', 'Description', 10, ObjectTypeToRun1,
            ObjectIdToRun1, AssistedSetupGroup::Uncategorized, '', VideoCategory::Uncategorized, '');

        // [WHEN] Inserting a new checklist item for a different assisted setup (that doesn't exist in the guided 
        // experience item table) and a list of users
        ObjectTypeToRun2 := ObjectType::Codeunit;
        ObjectIdToRun2 := Codeunit::"Guided Experience";

        Checklist.Insert(GuidedExperienceType::"Assisted Setup", ObjectTypeToRun2, ObjectIdToRun2, 14, TempAllUser);

        // [THEN] The checklist item table is empty
        ChecklistItem.Reset();
        Assert.AreEqual(0, ChecklistItem.Count(), 'The checklist item table should be empty');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertAssistedSetupChecklistItemWithWrongGuidedExperienceTypeAndUsers()
    var
        ChecklistItem: Record "Checklist Item";
        TempAllUser: Record User temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        ObjectTypeToRun: ObjectType;
        ObjectIdToRun: Integer;
    begin
        Initialize(false);

        AddUserToList(TempAllUser, UserSecurityId());

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type assisted setup
        ObjectTypeToRun := ObjectType::Page;
        ObjectIdToRun := Page::Checklist;
        GuidedExperience.InsertAssistedSetup('Title', 'Short Title', 'Description', 10, ObjectTypeToRun,
            ObjectIdToRun, AssistedSetupGroup::Uncategorized, '', VideoCategory::Uncategorized, '');

        // [WHEN] Inserting a new checklist item for the same object, but a different guided experience 
        // type and a list of users
        Checklist.Insert(GuidedExperienceType::"Manual Setup", ObjectTypeToRun, ObjectIdToRun, 20, TempAllUser);

        // [THEN] The checklist item table is empty
        ChecklistItem.Reset();
        Assert.AreEqual(0, ChecklistItem.Count(), 'The checklist item table should be empty');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertAssistedSetupChecklistItemWithUsers()
    var
        ChecklistItem: Record "Checklist Item";
        ChecklistItemUser: Record "Checklist Item User";
        GuidedExperienceItem: Record "Guided Experience Item";
        TempAllUser: Record User temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        CompletionRequirements: Enum "Checklist Completion Requirements";
        ChecklistItemStatus: Enum "Checklist Item Status";
        ObjectTypeToRun: ObjectType;
        ObjectIdToRun: Integer;
        OrderID: Integer;
        UserSecurityId: Guid;
        UserName: Code[50];
    begin
        Initialize(false);

        InsertUser(UserSecurityId, UserName);
        AddUserToList(TempAllUser, UserSecurityId);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type assisted setup
        ObjectTypeToRun := ObjectType::Page;
        ObjectIdToRun := Page::Checklist;
        GuidedExperience.InsertAssistedSetup('Title', 'Short Title', 'Description', 10, ObjectTypeToRun,
            ObjectIdToRun, AssistedSetupGroup::Uncategorized, '', VideoCategory::Uncategorized, '');

        // [WHEN] Inserting a new checklist item for the same object and a list of users
        OrderID := 23;
        Checklist.Insert(GuidedExperienceType::"Assisted Setup", ObjectTypeToRun, ObjectIdToRun, OrderID, TempAllUser);

        // [THEN] The checklist item table contains exactly one record
        ChecklistItem.Reset();
        Assert.AreEqual(1, ChecklistItem.Count(), 'The checklist item table should contain exactly one record.');

        // [THEN] The checklist item's fields are set correctly
        GuidedExperienceItem.FindFirst();
        ChecklistItem.FindFirst();
        VerifyChecklistItemFields(ChecklistItem, GuidedExperienceItem.Code, CompletionRequirements::"Specific users", OrderID);

        // [THEN] The checklist item user table contains exactly one record
        Assert.AreEqual(1, ChecklistItemUser.Count(), 'The checklist item user table should contain exactly one record.');

        // [THEN] The checklist item user's fields are set correctly
        ChecklistItemUser.FindFirst();
        VerifyChecklistItemUserFields(ChecklistItemUser, GuidedExperienceItem.Code, UserName, ChecklistItemStatus::"Not Started", true, true);

        // [WHEN] Inserting an identical checklist item 
        Checklist.Insert(GuidedExperienceType::"Assisted Setup", ObjectTypeToRun, ObjectIdToRun, OrderID, TempAllUser);

        // [THEN] The checklist item and checklist item user tables still contain only one record
        Assert.AreEqual(1, ChecklistItem.Count, 'The checklist item table should not contain a new record.');
        Assert.AreEqual(1, ChecklistItemUser.Count, 'The checklist item user table should not contain a new record.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertDuplicateAssistedSetupChecklistItemWithUsers()
    var
        ChecklistItem: Record "Checklist Item";
        ChecklistItemUser: Record "Checklist Item User";
        TempAllUser: Record User temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        ObjectTypeToRun: ObjectType;
        ObjectIdToRun: Integer;
        OrderID1: Integer;
        UserSecurityId: Guid;
        UserName: Code[50];
    begin
        Initialize(false);

        InsertUser(UserSecurityId, UserName);
        AddUserToList(TempAllUser, UserSecurityId);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type assisted setup
        ObjectTypeToRun := ObjectType::Page;
        ObjectIdToRun := Page::Checklist;
        GuidedExperience.InsertAssistedSetup('Title', 'Short Title', 'Description', 10, ObjectTypeToRun,
            ObjectIdToRun, AssistedSetupGroup::Uncategorized, '', VideoCategory::Uncategorized, '');

        // [WHEN] Inserting a new checklist item for the same object and a list of users
        OrderID1 := 23;
        Checklist.Insert(GuidedExperienceType::"Assisted Setup", ObjectTypeToRun, ObjectIdToRun, OrderID1, TempAllUser);

        // [THEN] The checklist item and checklist item user tables contain exactly one record
        Assert.AreEqual(1, ChecklistItem.Count(), 'The checklist item table should contain exactly one record.');
        Assert.AreEqual(1, ChecklistItemUser.Count(), 'The checklist item user table should contain exactly one record.');

        // [WHEN] Inserting an identical checklist item 
        Checklist.Insert(GuidedExperienceType::"Assisted Setup", ObjectTypeToRun, ObjectIdToRun, OrderID1, TempAllUser);

        // [THEN] The checklist item and checklist item user tables still contain only one record
        Assert.AreEqual(1, ChecklistItem.Count, 'The checklist item table should not contain a new record.');
        Assert.AreEqual(1, ChecklistItemUser.Count, 'The checklist item user table should not contain a new record.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestUpdateAssistedSetupChecklistItemWithUsers()
    var
        ChecklistItem: Record "Checklist Item";
        ChecklistItemUser: Record "Checklist Item User";
        GuidedExperienceItem: Record "Guided Experience Item";
        TempAllUser: Record User temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        CompletionRequirements: Enum "Checklist Completion Requirements";
        ObjectTypeToRun: ObjectType;
        ObjectIdToRun: Integer;
        OrderID1: Integer;
        OrderID2: Integer;
        UserSecurityId: Guid;
        UserName: Code[50];
    begin
        Initialize(false);

        InsertUser(UserSecurityId, UserName);
        AddUserToList(TempAllUser, UserSecurityId);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type assisted setup
        ObjectTypeToRun := ObjectType::Page;
        ObjectIdToRun := Page::Checklist;
        GuidedExperience.InsertAssistedSetup('Title', 'Short Title', 'Description', 10, ObjectTypeToRun,
            ObjectIdToRun, AssistedSetupGroup::Uncategorized, '', VideoCategory::Uncategorized, '');

        // [WHEN] Inserting a new checklist item for the same object and a list of profiles
        OrderID1 := 23;
        Checklist.Insert(GuidedExperienceType::"Assisted Setup", ObjectTypeToRun, ObjectIdToRun, OrderID1, TempAllUser);

        // [THEN] The checklist item and checklist item user tables contain exactly one record
        Assert.AreEqual(1, ChecklistItem.Count(), 'The checklist item table should contain exactly one record.');
        Assert.AreEqual(1, ChecklistItemUser.Count(), 'The checklist item user table should contain exactly one record.');

        // [WHEN] Inserting a checklist item for the same guided experience item, but with a different order ID
        OrderID2 := 36;
        Checklist.Insert(GuidedExperienceType::"Assisted Setup", ObjectTypeToRun, ObjectIdToRun, OrderID2, TempAllUser);

        // [THEN] The Checklist item table still contains only one record, but the order id should have changed
        GuidedExperienceItem.FindFirst();
        ChecklistItem.FindFirst();
        VerifyChecklistItemFields(ChecklistItem, GuidedExperienceItem.Code, CompletionRequirements::"Specific users", OrderID2);

        // [THEN] The checklist item user table still contains only one record
        Assert.AreEqual(1, ChecklistItemUser.Count, 'The checklist item user table should not contain a new record.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestUpdateUsersForAssistedSetupChecklistItem()
    var
        ChecklistItem: Record "Checklist Item";
        ChecklistItemUser: Record "Checklist Item User";
        TempAllUser: Record User temporary;
        TempAllUser2: Record User temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        ChecklistItemStatus: Enum "Checklist Item Status";
        ObjectTypeToRun: ObjectType;
        ObjectIdToRun: Integer;
        OrderID: Integer;
        UserSecurityID1: Guid;
        UserSecurityID2: Guid;
        UserSecurityID3: Guid;
        UserSecurityID4: Guid;
        UserName1: Code[50];
        UserName2: Code[50];
        UserName3: Code[50];
        UserName4: Code[50];
    begin
        Initialize(false);

        InsertUser(UserSecurityID1, UserName1);
        InsertUser(UserSecurityID2, UserName2);

        AddUserToList(TempAllUser, UserSecurityID1);
        AddUserToList(TempAllUser, UserSecurityID2);

        InsertUser(UserSecurityID3, UserName3);
        InsertUser(UserSecurityID4, UserName4);

        AddUserToList(TempAllUser2, UserSecurityID2);
        AddUserToList(TempAllUser2, UserSecurityID3);
        AddUserToList(TempAllUser2, UserSecurityID4);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type assisted setup
        ObjectTypeToRun := ObjectType::Page;
        ObjectIdToRun := Page::Checklist;
        GuidedExperience.InsertAssistedSetup('Title', 'Short Title', 'Description', 10, ObjectTypeToRun,
            ObjectIdToRun, AssistedSetupGroup::Uncategorized, '', VideoCategory::Uncategorized, '');

        // [WHEN] Inserting a new checklist item for the same object and a list of users
        OrderID := 23;
        Checklist.Insert(GuidedExperienceType::"Assisted Setup", ObjectTypeToRun, ObjectIdToRun, OrderID, TempAllUser);

        // [THEN] The checklist item table contains exactly one record
        Assert.AreEqual(1, ChecklistItem.Count(), 'The checklist item table should contain exactly one record.');

        // [THEN] The checklist item user table contains two records
        Assert.AreEqual(2, ChecklistItemUser.Count(), 'The checklist item user table should contain two records.');

        // [WHEN] Inserting a checklist item for the same guided experience item, but with a different user list
        Checklist.Insert(GuidedExperienceType::"Assisted Setup", ObjectTypeToRun, ObjectIdToRun, OrderID, TempAllUser2);

        // [THEN] The checklist item user table contains three records
        Assert.AreEqual(3, ChecklistItemUser.Count, 'The checklist item user table should contain 3 records.');

        // [THEN] The checklist item user records should be set correctly
        ChecklistItem.FindFirst();

        Assert.IsTrue(ChecklistItemUser.Get(ChecklistItem.Code, UserName2), 'The checklist item user with user security ID 2 should exist.');
        VerifyChecklistItemUserFields(ChecklistItemUser, ChecklistItem.Code, UserName2, ChecklistItemStatus::"Not Started", true, true);

        Assert.IsTrue(ChecklistItemUser.Get(ChecklistItem.Code, UserName3), 'The checklist item user with user security ID 3 should exist.');
        VerifyChecklistItemUserFields(ChecklistItemUser, ChecklistItem.Code, UserName3, ChecklistItemStatus::"Not Started", true, true);

        Assert.IsTrue(ChecklistItemUser.Get(ChecklistItem.Code, UserName4), 'The checklist item user with user security ID 4 should exist.');
        VerifyChecklistItemUserFields(ChecklistItemUser, ChecklistItem.Code, UserName4, ChecklistItemStatus::"Not Started", true, true);
    end;


    [Test]
    [Scope('OnPrem')]
    procedure TestInsertManualSetupChecklistItemWithNoGuidedExperienceItemAndProfiles()
    var
        ChecklistItem: Record "Checklist Item";
        TempAllProfile: Record "All Profile" temporary;
        Checklist: Codeunit Checklist;
        GuidedExperienceType: Enum "Guided Experience Type";
        ObjectTypeToRun: ObjectType;
        ObjectIdToRun: Integer;
        OrderId: Integer;
    begin
        // [GIVEN] The guided experience item table is empty
        Initialize(false);

        AddRoleToList(TempAllProfile, ProfileID1);

        PermissionsMock.Set('Guided Exp Edit');

        // [WHEN] Inserting a new checklist item for an inexistent manual setup guided experience item and a list of profiles
        ObjectTypeToRun := ObjectType::Page;
        ObjectIdToRun := Page::"Checklist Administration";
        OrderId := 1573;

        Checklist.Insert(GuidedExperienceType::"Manual Setup", ObjectTypeToRun, ObjectIdToRun, OrderId, TempAllProfile, true);

        // [THEN] The checklist item table is empty
        ChecklistItem.Reset();
        Assert.AreEqual(0, ChecklistItem.Count(), 'The checklist item table should be empty');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertManualSetupChecklistItemWithWrongGuidedExperienceItemAndProfiles()
    var
        ChecklistItem: Record "Checklist Item";
        TempAllProfile: Record "All Profile" temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        ManualSetupCategory: Enum "Manual Setup Category";
        ObjectTypeToRun1: ObjectType;
        ObjectTypeToRun2: ObjectType;
        ObjectIdToRun1: Integer;
        ObjectIdToRun2: Integer;
    begin
        Initialize(false);

        AddRoleToList(TempAllProfile, ProfileID1);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type assisted setup
        ObjectTypeToRun1 := ObjectType::Page;
        ObjectIdToRun1 := Page::Checklist;
        GuidedExperience.InsertManualSetup('Title', 'Short Title', 'Description', 10, ObjectTypeToRun1,
            ObjectIdToRun1, ManualSetupCategory::Uncategorized, '');

        // [WHEN] Inserting a new checklist item for a different manual setup (that doesn't exist in the guided 
        // experience item table) and a list of profiles
        ObjectTypeToRun2 := ObjectType::Codeunit;
        ObjectIdToRun2 := Codeunit::"Guided Experience";

        Checklist.Insert(GuidedExperienceType::"Manual Setup", ObjectTypeToRun2, ObjectIdToRun2, 14, TempAllProfile, true);

        // [THEN] The checklist item table is empty
        ChecklistItem.Reset();
        Assert.AreEqual(0, ChecklistItem.Count(), 'The checklist item table should be empty');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertManualSetupChecklistItemWithWrongGuidedExperienceTypeAndProfiles()
    var
        ChecklistItem: Record "Checklist Item";
        TempAllProfile: Record "All Profile" temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        ManualSetupCategory: Enum "Manual Setup Category";
        ObjectTypeToRun: ObjectType;
        ObjectIdToRun: Integer;
    begin
        Initialize(false);

        AddRoleToList(TempAllProfile, ProfileID1);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type assisted setup
        ObjectTypeToRun := ObjectType::Page;
        ObjectIdToRun := Page::Checklist;
        GuidedExperience.InsertManualSetup('Title', 'Short Title', 'Description', 10, ObjectTypeToRun,
            ObjectIdToRun, ManualSetupCategory::Uncategorized, '');

        // [WHEN] Inserting a new checklist item for the same object, but a different guided experience 
        // type and a list of profiles
        Checklist.Insert(GuidedExperienceType::Learn, ObjectTypeToRun, ObjectIdToRun, 20, TempAllProfile, true);

        // [THEN] The checklist item table is empty
        ChecklistItem.Reset();
        Assert.AreEqual(0, ChecklistItem.Count(), 'The checklist item table should be empty');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertManualSetupChecklistItemWithProfiles()
    var
        ChecklistItem: Record "Checklist Item";
        ChecklistItemRole: Record "Checklist Item Role";
        GuidedExperienceItem: Record "Guided Experience Item";
        TempAllProfile: Record "All Profile" temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        ManualSetupCategory: Enum "Manual Setup Category";
        CompletionRequirements: Enum "Checklist Completion Requirements";
        ObjectTypeToRun: ObjectType;
        ObjectIdToRun: Integer;
        OrderID: Integer;
    begin
        Initialize(false);

        AddRoleToList(TempAllProfile, ProfileID1);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type manual setup
        ObjectTypeToRun := ObjectType::Page;
        ObjectIdToRun := Page::Checklist;
        GuidedExperience.InsertManualSetup('Title', 'Short Title', 'Description', 10, ObjectTypeToRun,
            ObjectIdToRun, ManualSetupCategory::Uncategorized, '');

        // [WHEN] Inserting a new checklist item for the same object and a list of profiles
        OrderID := 23;
        Checklist.Insert(GuidedExperienceType::"Manual Setup", ObjectTypeToRun, ObjectIdToRun, OrderID, TempAllProfile, true);

        // [THEN] The checklist item table contains exactly one record
        ChecklistItem.Reset();
        Assert.AreEqual(1, ChecklistItem.Count(), 'The checklist item table should contain exactly one record.');

        // [THEN] The checklist item's fields are set correctly
        GuidedExperienceItem.FindFirst();
        ChecklistItem.FindFirst();
        VerifyChecklistItemFields(ChecklistItem, GuidedExperienceItem.Code, CompletionRequirements::Everyone, OrderID);

        // [THEN] The checklist item role table contains exactly one record
        ChecklistItem.Reset();
        Assert.AreEqual(1, ChecklistItemRole.Count(), 'The checklist item table should contain exactly one record.');

        // [THEN] The checklist item role's fields are set correctly
        ChecklistItemRole.FindFirst();
        VerifyChecklistItemRoleFields(ChecklistItemRole, GuidedExperienceItem.Code, TempAllProfile."Profile ID");

        // [WHEN] Inserting an identical checklist item 
        Checklist.Insert(GuidedExperienceType::"Manual Setup", ObjectTypeToRun, ObjectIdToRun, OrderID, TempAllProfile, true);

        // [THEN] The checklist item and checklist item role tables still contain only one record
        Assert.AreEqual(1, ChecklistItem.Count, 'The checklist item table should not contain a new record.');
        Assert.AreEqual(1, ChecklistItemRole.Count, 'The checklist item role table should not contain a new record.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertDuplicateManualSetupChecklistItemWithProfiles()
    var
        ChecklistItem: Record "Checklist Item";
        ChecklistItemRole: Record "Checklist Item Role";
        TempAllProfile: Record "All Profile" temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        ManualSetupCategory: Enum "Manual Setup Category";
        ObjectTypeToRun: ObjectType;
        ObjectIdToRun: Integer;
        OrderID1: Integer;
    begin
        Initialize(false);

        AddRoleToList(TempAllProfile, ProfileID1);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type manual setup
        ObjectTypeToRun := ObjectType::Page;
        ObjectIdToRun := Page::Checklist;
        GuidedExperience.InsertManualSetup('Title', 'Short Title', 'Description', 10, ObjectTypeToRun,
            ObjectIdToRun, ManualSetupCategory::Uncategorized, '');

        // [WHEN] Inserting a new checklist item for the same object and a list of profiles
        OrderID1 := 23;
        Checklist.Insert(GuidedExperienceType::"Manual Setup", ObjectTypeToRun, ObjectIdToRun, OrderID1, TempAllProfile, true);

        // [THEN] The checklist item and checklist item role tables contain exactly one record
        Assert.AreEqual(1, ChecklistItem.Count(), 'The checklist item table should contain exactly one record.');
        Assert.AreEqual(1, ChecklistItemRole.Count(), 'The checklist item role table should contain exactly one record.');

        // [WHEN] Inserting an identical checklist item 
        Checklist.Insert(GuidedExperienceType::"Manual Setup", ObjectTypeToRun, ObjectIdToRun, OrderID1, TempAllProfile, true);

        // [THEN] The checklist item and checklist item role tables still contain only one record
        Assert.AreEqual(1, ChecklistItem.Count, 'The checklist item table should not contain a new record.');
        Assert.AreEqual(1, ChecklistItemRole.Count, 'The checklist item role table should not contain a new record.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestUpdateManualSetupChecklistItemWithProfiles()
    var
        ChecklistItem: Record "Checklist Item";
        ChecklistItemRole: Record "Checklist Item Role";
        GuidedExperienceItem: Record "Guided Experience Item";
        TempAllProfile: Record "All Profile" temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        ManualSetupCategory: Enum "Manual Setup Category";
        CompletionRequirements: Enum "Checklist Completion Requirements";
        ObjectTypeToRun: ObjectType;
        ObjectIdToRun: Integer;
        OrderID1: Integer;
        OrderID2: Integer;
    begin
        Initialize(false);

        AddRoleToList(TempAllProfile, ProfileID1);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type manual setup
        ObjectTypeToRun := ObjectType::Page;
        ObjectIdToRun := Page::Checklist;
        GuidedExperience.InsertManualSetup('Title', 'Short Title', 'Description', 10, ObjectTypeToRun,
            ObjectIdToRun, ManualSetupCategory::Uncategorized, '');

        // [WHEN] Inserting a new checklist item for the same object and a list of profiles
        OrderID1 := 23;
        Checklist.Insert(GuidedExperienceType::"Manual Setup", ObjectTypeToRun, ObjectIdToRun, OrderID1, TempAllProfile, true);

        // [THEN] The checklist item and checklist item role tables contain exactly one record
        Assert.AreEqual(1, ChecklistItem.Count(), 'The checklist item table should contain exactly one record.');
        Assert.AreEqual(1, ChecklistItemRole.Count(), 'The checklist item role table should contain exactly one record.');

        // [WHEN] Inserting a checklist item for the same guided experience item, but with a different order ID and completion requirements
        OrderID2 := 36;
        Checklist.Insert(GuidedExperienceType::"Manual Setup", ObjectTypeToRun, ObjectIdToRun, OrderID2, TempAllProfile, false);

        // [THEN] The Checklist item table still contains only one record, but the order id and completion requirements have changed
        GuidedExperienceItem.FindFirst();
        ChecklistItem.FindFirst();
        VerifyChecklistItemFields(ChecklistItem, GuidedExperienceItem.Code, CompletionRequirements::Anyone, OrderID2);

        // [THEN] The checklist item role table still contains only one record
        Assert.AreEqual(1, ChecklistItemRole.Count, 'The checklist item role table should not contain a new record.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestUpdateProfilesForManualSetupChecklistItem()
    var
        ChecklistItem: Record "Checklist Item";
        ChecklistItemRole: Record "Checklist Item Role";
        TempAllProfile: Record "All Profile" temporary;
        TempAllProfile2: Record "All Profile" temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        ManualSetupCategory: Enum "Manual Setup Category";
        ObjectTypeToRun: ObjectType;
        ObjectIdToRun: Integer;
        OrderID: Integer;
    begin
        Initialize(false);

        AddRoleToList(TempAllProfile, ProfileID1);
        AddRoleToList(TempAllProfile, ProfileID2);

        AddRoleToList(TempAllProfile2, ProfileID1);
        AddRoleToList(TempAllProfile2, ProfileID3);
        AddRoleToList(TempAllProfile2, ProfileID4);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type manual setup
        ObjectTypeToRun := ObjectType::Page;
        ObjectIdToRun := Page::Checklist;
        GuidedExperience.InsertManualSetup('Title', 'Short Title', 'Description', 10, ObjectTypeToRun,
            ObjectIdToRun, ManualSetupCategory::Uncategorized, '');

        // [WHEN] Inserting a new checklist item for the same object and a list of profiles 
        OrderID := 23;
        Checklist.Insert(GuidedExperienceType::"Manual Setup", ObjectTypeToRun, ObjectIdToRun, OrderID, TempAllProfile, true);

        // [THEN] The checklist item table contains one record 
        Assert.AreEqual(1, ChecklistItem.Count(), 'The checklist item table should contain exactly one record.');

        // [THEN] The checklist item role table contains two records
        Assert.AreEqual(2, ChecklistItemRole.Count(), 'The checklist item role table should contain two records.');

        // [WHEN] Inserting a checklist item for the same guided experience item, but with a different profile list
        Checklist.Insert(GuidedExperienceType::"Manual Setup", ObjectTypeToRun, ObjectIdToRun, OrderID, TempAllProfile2, true);

        // [THEN] The checklist item role table contains three records
        Assert.AreEqual(3, ChecklistItemRole.Count, 'The checklist item role table should contain 3 records.');

        // [THEN] The checklist item roles have the correct profiles and codes
        ChecklistItem.FindFirst();

        Assert.IsTrue(ChecklistItemRole.Get(ChecklistItem.Code, ProfileID1), 'The checklist item role with profile ID 1 should exist.');
        Assert.IsTrue(ChecklistItemRole.Get(ChecklistItem.Code, ProfileID3), 'The checklist item role with profile ID 3 should exist.');
        Assert.IsTrue(ChecklistItemRole.Get(ChecklistItem.Code, ProfileID4), 'The checklist item role with profile ID 4 should exist.');
        Assert.IsFalse(ChecklistItemRole.Get(ChecklistItem.Code, ProfileID2), 'The checklist item role with profile ID 2 should NOT exist.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertManualSetupChecklistItemWithNoGuidedExperienceItemAndUsers()
    var
        ChecklistItem: Record "Checklist Item";
        TempAllUser: Record User temporary;
        Checklist: Codeunit Checklist;
        GuidedExperienceType: Enum "Guided Experience Type";
        ObjectTypeToRun: ObjectType;
        ObjectIdToRun: Integer;
        OrderId: Integer;
    begin
        // [GIVEN] The guided experience item table is empty
        Initialize(false);

        AddUserToList(TempAllUser, UserSecurityId());

        PermissionsMock.Set('Guided Exp Edit');

        // [WHEN] Inserting a new checklist item for an inexistent manual setup guided experience item and a list of users
        ObjectTypeToRun := ObjectType::Page;
        ObjectIdToRun := Page::"Checklist Banner";
        OrderId := 1573;

        Checklist.Insert(GuidedExperienceType::"Manual Setup", ObjectTypeToRun, ObjectIdToRun, OrderId, TempAllUser);

        // [THEN] The checklist item table is empty
        ChecklistItem.Reset();
        Assert.AreEqual(0, ChecklistItem.Count(), 'The checklist item table should be empty');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertManualSetupChecklistItemWithWrongGuidedExperienceItemAndUsers()
    var
        ChecklistItem: Record "Checklist Item";
        TempAllUser: Record User temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        ManualSetupCategory: Enum "Manual Setup Category";
        ObjectTypeToRun1: ObjectType;
        ObjectTypeToRun2: ObjectType;
        ObjectIdToRun1: Integer;
        ObjectIdToRun2: Integer;
    begin
        Initialize(false);

        AddUserToList(TempAllUser, UserSecurityId());

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type manual setup
        ObjectTypeToRun1 := ObjectType::Page;
        ObjectIdToRun1 := Page::Checklist;
        GuidedExperience.InsertManualSetup('Title', 'Short Title', 'Description', 10, ObjectTypeToRun1,
            ObjectIdToRun1, ManualSetupCategory::Uncategorized, '');

        // [WHEN] Inserting a new checklist item for a different manual setup (that doesn't exist in the guided 
        // experience item table) and a list of users
        ObjectTypeToRun2 := ObjectType::Codeunit;
        ObjectIdToRun2 := Codeunit::"Guided Experience";

        Checklist.Insert(GuidedExperienceType::"Manual Setup", ObjectTypeToRun2, ObjectIdToRun2, 14, TempAllUser);

        // [THEN] The checklist item table is empty
        ChecklistItem.Reset();
        Assert.AreEqual(0, ChecklistItem.Count(), 'The checklist item table should be empty');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertManualSetupChecklistItemWithWrongGuidedExperienceTypeAndUsers()
    var
        ChecklistItem: Record "Checklist Item";
        TempAllUser: Record User temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        ManualSetupCategory: Enum "Manual Setup Category";
        ObjectTypeToRun: ObjectType;
        ObjectIdToRun: Integer;
    begin
        Initialize(false);

        AddUserToList(TempAllUser, UserSecurityId());

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type manual setup
        ObjectTypeToRun := ObjectType::Page;
        ObjectIdToRun := Page::Checklist;
        GuidedExperience.InsertManualSetup('Title', 'Short Title', 'Description', 10, ObjectTypeToRun,
            ObjectIdToRun, ManualSetupCategory::Uncategorized, '');

        // [WHEN] Inserting a new checklist item for the same object, but a different guided experience 
        // type and a list of users
        Checklist.Insert(GuidedExperienceType::"Assisted Setup", ObjectTypeToRun, ObjectIdToRun, 20, TempAllUser);

        // [THEN] The checklist item table is empty
        ChecklistItem.Reset();
        Assert.AreEqual(0, ChecklistItem.Count(), 'The checklist item table should be empty');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertManualSetupChecklistItemWithUsers()
    var
        ChecklistItem: Record "Checklist Item";
        ChecklistItemUser: Record "Checklist Item User";
        GuidedExperienceItem: Record "Guided Experience Item";
        TempAllUser: Record User temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        ManualSetupCategory: Enum "Manual Setup Category";
        CompletionRequirements: Enum "Checklist Completion Requirements";
        ChecklistItemStatus: Enum "Checklist Item Status";
        ObjectTypeToRun: ObjectType;
        ObjectIdToRun: Integer;
        OrderID: Integer;
        UserSecurityId: Guid;
        UserName: Code[50];
    begin
        Initialize(false);

        InsertUser(UserSecurityId, UserName);
        AddUserToList(TempAllUser, UserSecurityId);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type manual setup
        ObjectTypeToRun := ObjectType::Page;
        ObjectIdToRun := Page::Checklist;
        GuidedExperience.InsertManualSetup('Title', 'Short Title', 'Description', 10, ObjectTypeToRun,
            ObjectIdToRun, ManualSetupCategory::Uncategorized, '');

        // [WHEN] Inserting a new checklist item for the same object and a list of users
        OrderID := 23;
        Checklist.Insert(GuidedExperienceType::"Manual Setup", ObjectTypeToRun, ObjectIdToRun, OrderID, TempAllUser);

        // [THEN] The checklist item table contains exactly one record
        ChecklistItem.Reset();
        Assert.AreEqual(1, ChecklistItem.Count(), 'The checklist item table should contain exactly one record.');

        // [THEN] The checklist item's fields are set correctly
        GuidedExperienceItem.FindFirst();
        ChecklistItem.FindFirst();
        VerifyChecklistItemFields(ChecklistItem, GuidedExperienceItem.Code, CompletionRequirements::"Specific users", OrderID);

        // [THEN] The checklist item user table contains exactly one record
        Assert.AreEqual(1, ChecklistItemUser.Count(), 'The checklist item user table should contain exactly one record.');

        // [THEN] The checklist item user's fields are set correctly
        ChecklistItemUser.FindFirst();
        VerifyChecklistItemUserFields(ChecklistItemUser, GuidedExperienceItem.Code, UserName, ChecklistItemStatus::"Not Started", true, true);

        // [WHEN] Inserting an identical checklist item 
        Checklist.Insert(GuidedExperienceType::"Manual Setup", ObjectTypeToRun, ObjectIdToRun, OrderID, TempAllUser);

        // [THEN] The checklist item and checklist item user tables still contain only one record
        Assert.AreEqual(1, ChecklistItem.Count, 'The checklist item table should not contain a new record.');
        Assert.AreEqual(1, ChecklistItemUser.Count, 'The checklist item user table should not contain a new record.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertDuplicateManualSetupChecklistItemWithUsers()
    var
        ChecklistItem: Record "Checklist Item";
        ChecklistItemUser: Record "Checklist Item User";
        TempAllUser: Record User temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        ManualSetupCategory: Enum "Manual Setup Category";
        ObjectTypeToRun: ObjectType;
        ObjectIdToRun: Integer;
        OrderID1: Integer;
        UserSecurityId: Guid;
        UserName: Code[50];
    begin
        Initialize(false);

        InsertUser(UserSecurityId, UserName);
        AddUserToList(TempAllUser, UserSecurityId);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type manual setup
        ObjectTypeToRun := ObjectType::Page;
        ObjectIdToRun := Page::Checklist;
        GuidedExperience.InsertManualSetup('Title', 'Short Title', 'Description', 10, ObjectTypeToRun,
            ObjectIdToRun, ManualSetupCategory::Uncategorized, '');

        // [WHEN] Inserting a new checklist item for the same object and a list of users
        OrderID1 := 23;
        Checklist.Insert(GuidedExperienceType::"Manual Setup", ObjectTypeToRun, ObjectIdToRun, OrderID1, TempAllUser);

        // [THEN] The checklist item and checklist item user tables contain exactly one record
        Assert.AreEqual(1, ChecklistItem.Count(), 'The checklist item table should contain exactly one record.');
        Assert.AreEqual(1, ChecklistItemUser.Count(), 'The checklist item user table should contain exactly one record.');

        // [WHEN] Inserting an identical checklist item 
        Checklist.Insert(GuidedExperienceType::"Manual Setup", ObjectTypeToRun, ObjectIdToRun, OrderID1, TempAllUser);

        // [THEN] The checklist item and checklist item user tables still contain only one record
        Assert.AreEqual(1, ChecklistItem.Count, 'The checklist item table should not contain a new record.');
        Assert.AreEqual(1, ChecklistItemUser.Count, 'The checklist item user table should not contain a new record.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestUpdateManualSetupChecklistItemWithUsers()
    var
        ChecklistItem: Record "Checklist Item";
        ChecklistItemUser: Record "Checklist Item User";
        GuidedExperienceItem: Record "Guided Experience Item";
        TempAllUser: Record User temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        ManualSetupCategory: Enum "Manual Setup Category";
        CompletionRequirements: Enum "Checklist Completion Requirements";
        ObjectTypeToRun: ObjectType;
        ObjectIdToRun: Integer;
        OrderID1: Integer;
        OrderID2: Integer;
        UserSecurityId: Guid;
        UserName: Code[50];
    begin
        Initialize(false);

        InsertUser(UserSecurityId, UserName);
        AddUserToList(TempAllUser, UserSecurityId);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type manual setup
        ObjectTypeToRun := ObjectType::Page;
        ObjectIdToRun := Page::Checklist;
        GuidedExperience.InsertManualSetup('Title', 'Short Title', 'Description', 10, ObjectTypeToRun,
            ObjectIdToRun, ManualSetupCategory::Uncategorized, '');

        // [WHEN] Inserting a new checklist item for the same object and a list of profiles
        OrderID1 := 23;
        Checklist.Insert(GuidedExperienceType::"Manual Setup", ObjectTypeToRun, ObjectIdToRun, OrderID1, TempAllUser);

        // [THEN] The checklist item and checklist item user tables contain exactly one record
        Assert.AreEqual(1, ChecklistItem.Count(), 'The checklist item table should contain exactly one record.');
        Assert.AreEqual(1, ChecklistItemUser.Count(), 'The checklist item user table should contain exactly one record.');

        // [WHEN] Inserting a checklist item for the same guided experience item, but with a different order ID
        OrderID2 := 36;
        Checklist.Insert(GuidedExperienceType::"Manual Setup", ObjectTypeToRun, ObjectIdToRun, OrderID2, TempAllUser);

        // [THEN] The Checklist item table still contains only one record, but the order id should have changed
        GuidedExperienceItem.FindFirst();
        ChecklistItem.FindFirst();
        VerifyChecklistItemFields(ChecklistItem, GuidedExperienceItem.Code, CompletionRequirements::"Specific users", OrderID2);

        // [THEN] The checklist item user table still contains only one record
        Assert.AreEqual(1, ChecklistItemUser.Count, 'The checklist item user table should not contain a new record.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestUpdateUsersForManualSetupChecklistItem()
    var
        ChecklistItem: Record "Checklist Item";
        ChecklistItemUser: Record "Checklist Item User";
        TempAllUser: Record User temporary;
        TempAllUser2: Record User temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        ManualSetupCategory: Enum "Manual Setup Category";
        ChecklistItemStatus: Enum "Checklist Item Status";
        ObjectTypeToRun: ObjectType;
        ObjectIdToRun: Integer;
        OrderID: Integer;
        UserSecurityID1: Guid;
        UserSecurityID2: Guid;
        UserSecurityID3: Guid;
        UserSecurityID4: Guid;
        UserName1: Code[50];
        UserName2: Code[50];
        UserName3: Code[50];
        UserName4: Code[50];
    begin
        Initialize(false);

        InsertUser(UserSecurityID1, UserName1);
        InsertUser(UserSecurityID2, UserName2);

        AddUserToList(TempAllUser, UserSecurityID1);
        AddUserToList(TempAllUser, UserSecurityID2);

        InsertUser(UserSecurityID3, UserName3);
        InsertUser(UserSecurityID4, UserName4);

        AddUserToList(TempAllUser2, UserSecurityID2);
        AddUserToList(TempAllUser2, UserSecurityID3);
        AddUserToList(TempAllUser2, UserSecurityID4);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type learn
        ObjectTypeToRun := ObjectType::Page;
        ObjectIdToRun := Page::Checklist;
        GuidedExperience.InsertManualSetup('Title', 'Short Title', 'Description', 10, ObjectTypeToRun,
            ObjectIdToRun, ManualSetupCategory::Uncategorized, '');

        // [WHEN] Inserting a new checklist item for the same object and a list of users
        OrderID := 23;
        Checklist.Insert(GuidedExperienceType::"Manual Setup", ObjectTypeToRun, ObjectIdToRun, OrderID, TempAllUser);

        // [THEN] The checklist item table contains exactly one record
        Assert.AreEqual(1, ChecklistItem.Count(), 'The checklist item table should contain exactly one record.');

        // [THEN] The checklist item user table contains two records
        Assert.AreEqual(2, ChecklistItemUser.Count(), 'The checklist item user table should contain two records.');

        // [WHEN] Inserting a checklist item for the same guided experience item, but with a different user list
        Checklist.Insert(GuidedExperienceType::"Manual Setup", ObjectTypeToRun, ObjectIdToRun, OrderID, TempAllUser2);

        // [THEN] The checklist item user table contains three records
        Assert.AreEqual(3, ChecklistItemUser.Count, 'The checklist item user table should contain 3 records.');

        // [THEN] The checklist item user records should be set correctly
        ChecklistItem.FindFirst();

        Assert.IsTrue(ChecklistItemUser.Get(ChecklistItem.Code, UserName2), 'The checklist item user with user security ID 2 should exist.');
        VerifyChecklistItemUserFields(ChecklistItemUser, ChecklistItem.Code, UserName2, ChecklistItemStatus::"Not Started", true, true);

        Assert.IsTrue(ChecklistItemUser.Get(ChecklistItem.Code, UserName3), 'The checklist item user with user security ID 3 should exist.');
        VerifyChecklistItemUserFields(ChecklistItemUser, ChecklistItem.Code, UserName3, ChecklistItemStatus::"Not Started", true, true);

        Assert.IsTrue(ChecklistItemUser.Get(ChecklistItem.Code, UserName4), 'The checklist item user with user security ID 4 should exist.');
        VerifyChecklistItemUserFields(ChecklistItemUser, ChecklistItem.Code, UserName4, ChecklistItemStatus::"Not Started", true, true);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertLearnChecklistItemWithNoGuidedExperienceItemAndProfiles()
    var
        ChecklistItem: Record "Checklist Item";
        TempAllProfile: Record "All Profile" temporary;
        Checklist: Codeunit Checklist;
        GuidedExperienceType: Enum "Guided Experience Type";
        LinkToRun: Text[250];
    begin
        // [GIVEN] The guided experience item table is empty
        Initialize(false);

        AddRoleToList(TempAllProfile, ProfileID1);

        PermissionsMock.Set('Guided Exp Edit');

        // [WHEN] Inserting a new checklist item for an inexistent learn guided experience item and a list of profiles
        LinkToRun := GetNewLink();

        Checklist.Insert(GuidedExperienceType::Learn, LinkToRun, 15, TempAllProfile, true);

        // [THEN] The checklist item table is empty
        ChecklistItem.Reset();
        Assert.AreEqual(0, ChecklistItem.Count(), 'The checklist item table should be empty');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertLearnChecklistItemWithWrongGuidedExperienceItemAndProfiles()
    var
        ChecklistItem: Record "Checklist Item";
        TempAllProfile: Record "All Profile" temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        LinkToRun1: Text[250];
        LinkToRun2: Text[250];
    begin
        Initialize(false);

        AddRoleToList(TempAllProfile, ProfileID1);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type learn
        LinkToRun1 := GetNewLink();
        GuidedExperience.InsertLearnLink('Title', 'Short Title', 'Description', 10, LinkToRun1);

        // [WHEN] Inserting a new checklist item for a different learn item (that doesn't exist in the guided 
        // experience item table) and a list of profiles
        LinkToRun2 := GetNewLink();

        Checklist.Insert(GuidedExperienceType::Learn, LinkToRun2, 14, TempAllProfile, true);

        // [THEN] The checklist item table is empty
        ChecklistItem.Reset();
        Assert.AreEqual(0, ChecklistItem.Count(), 'The checklist item table should be empty');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertLearnChecklistItemWithWrongGuidedExperienceTypeAndProfiles()
    var
        ChecklistItem: Record "Checklist Item";
        TempAllProfile: Record "All Profile" temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        LinkToRun: Text[250];
    begin
        Initialize(false);

        AddRoleToList(TempAllProfile, ProfileID1);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type learn
        LinkToRun := GetNewLink();
        GuidedExperience.InsertLearnLink('Title', 'Short Title', 'Description', 10, LinkToRun);

        // [WHEN] Inserting a new checklist item for the same link, but a different guided experience 
        // type and a list of profiles
        Checklist.Insert(GuidedExperienceType::"Assisted Setup", LinkToRun, 20, TempAllProfile, true);

        // [THEN] The checklist item table is empty
        ChecklistItem.Reset();
        Assert.AreEqual(0, ChecklistItem.Count(), 'The checklist item table should be empty');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertLearnChecklistItemWithProfiles()
    var
        ChecklistItem: Record "Checklist Item";
        ChecklistItemRole: Record "Checklist Item Role";
        GuidedExperienceItem: Record "Guided Experience Item";
        TempAllProfile: Record "All Profile" temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        CompletionRequirements: Enum "Checklist Completion Requirements";
        LinkToRun: Text[250];
        OrderID: Integer;
    begin
        Initialize(false);

        AddRoleToList(TempAllProfile, ProfileID1);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type learn
        LinkToRun := GetNewLink();
        GuidedExperience.InsertLearnLink('Title', 'Short Title', 'Description', 10, LinkToRun);

        // [WHEN] Inserting a new checklist item for the same link and a list of profiles
        OrderID := 23;
        Checklist.Insert(GuidedExperienceType::Learn, LinkToRun, OrderID, TempAllProfile, true);

        // [THEN] The checklist item table contains exactly one record
        ChecklistItem.Reset();
        Assert.AreEqual(1, ChecklistItem.Count(), 'The checklist item table should contain exactly one record.');

        // [THEN] The checklist item's fields are set correctly
        GuidedExperienceItem.FindFirst();
        ChecklistItem.FindFirst();
        VerifyChecklistItemFields(ChecklistItem, GuidedExperienceItem.Code, CompletionRequirements::Everyone, OrderID);

        // [THEN] The checklist item role table contains exactly one record
        ChecklistItem.Reset();
        Assert.AreEqual(1, ChecklistItemRole.Count(), 'The checklist item table should contain exactly one record.');

        // [THEN] The checklist item role's fields are set correctly
        ChecklistItemRole.FindFirst();
        VerifyChecklistItemRoleFields(ChecklistItemRole, GuidedExperienceItem.Code, TempAllProfile."Profile ID");

        // [WHEN] Inserting an identical checklist item 
        Checklist.Insert(GuidedExperienceType::Learn, LinkToRun, OrderID, TempAllProfile, true);

        // [THEN] The checklist item and checklist item role tables still contain only one record
        Assert.AreEqual(1, ChecklistItem.Count, 'The checklist item table should not contain a new record.');
        Assert.AreEqual(1, ChecklistItemRole.Count, 'The checklist item role table should not contain a new record.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertDuplicateLearnChecklistItemWithProfiles()
    var
        ChecklistItem: Record "Checklist Item";
        ChecklistItemRole: Record "Checklist Item Role";
        TempAllProfile: Record "All Profile" temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        LinkToRun: Text[250];
        OrderID: Integer;
    begin
        Initialize(false);

        AddRoleToList(TempAllProfile, ProfileID1);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type learn
        LinkToRun := GetNewLink();
        GuidedExperience.InsertLearnLink('Title', 'Short Title', 'Description', 10, LinkToRun);

        // [WHEN] Inserting a new checklist item for the same link and a list of profiles
        OrderID := 23;
        Checklist.Insert(GuidedExperienceType::Learn, LinkToRun, OrderID, TempAllProfile, true);

        // [THEN] The checklist item and checklist item role tables contain exactly one record
        Assert.AreEqual(1, ChecklistItem.Count(), 'The checklist item table should contain exactly one record.');
        Assert.AreEqual(1, ChecklistItemRole.Count(), 'The checklist item role table should contain exactly one record.');

        // [WHEN] Inserting an identical checklist item 
        Checklist.Insert(GuidedExperienceType::Learn, LinkToRun, OrderID, TempAllProfile, true);

        // [THEN] The checklist item and checklist item role tables still contain only one record
        Assert.AreEqual(1, ChecklistItem.Count, 'The checklist item table should not contain a new record.');
        Assert.AreEqual(1, ChecklistItemRole.Count, 'The checklist item role table should not contain a new record.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestUpdateLearnSetupChecklistItemWithProfiles()
    var
        ChecklistItem: Record "Checklist Item";
        ChecklistItemRole: Record "Checklist Item Role";
        GuidedExperienceItem: Record "Guided Experience Item";
        TempAllProfile: Record "All Profile" temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        CompletionRequirements: Enum "Checklist Completion Requirements";
        LinkToRun: Text[250];
        OrderID1: Integer;
        OrderID2: Integer;
    begin
        Initialize(false);

        AddRoleToList(TempAllProfile, ProfileID1);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type learn
        LinkToRun := GetNewLink();
        GuidedExperience.InsertLearnLink('Title', 'Short Title', 'Description', 10, LinkToRun);

        // [WHEN] Inserting a new checklist item for the same link and a list of profiles
        OrderID1 := 23;
        Checklist.Insert(GuidedExperienceType::Learn, LinkToRun, OrderID1, TempAllProfile, true);

        // [THEN] The checklist item and checklist item role tables contain exactly one record
        Assert.AreEqual(1, ChecklistItem.Count(), 'The checklist item table should contain exactly one record.');
        Assert.AreEqual(1, ChecklistItemRole.Count(), 'The checklist item role table should contain exactly one record.');

        // [WHEN] Inserting a checklist item for the same guided experience item, but with a different order ID and completion requirements
        OrderID2 := 36;
        Checklist.Insert(GuidedExperienceType::Learn, LinkToRun, OrderID2, TempAllProfile, false);

        // [THEN] The Checklist item table still contains only one record, but the order id and completion requirements have changed
        GuidedExperienceItem.FindFirst();
        ChecklistItem.FindFirst();
        VerifyChecklistItemFields(ChecklistItem, GuidedExperienceItem.Code, CompletionRequirements::Anyone, OrderID2);

        // [THEN] The checklist item role table still contains only one record
        Assert.AreEqual(1, ChecklistItemRole.Count, 'The checklist item role table should not contain a new record.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestUpdateProfilesForLearnChecklistItem()
    var
        ChecklistItem: Record "Checklist Item";
        ChecklistItemRole: Record "Checklist Item Role";
        TempAllProfile: Record "All Profile" temporary;
        TempAllProfile2: Record "All Profile" temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        LinkToRun: Text[250];
        OrderID: Integer;
    begin
        Initialize(false);

        AddRoleToList(TempAllProfile, ProfileID1);
        AddRoleToList(TempAllProfile, ProfileID2);

        AddRoleToList(TempAllProfile2, ProfileID1);
        AddRoleToList(TempAllProfile2, ProfileID3);
        AddRoleToList(TempAllProfile2, ProfileID4);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type manual setup
        LinkToRun := GetNewLink();
        GuidedExperience.InsertLearnLink('Title', 'Short Title', 'Description', 10, LinkToRun);

        // [WHEN] Inserting a new checklist item for the same object and a list of profiles   
        OrderID := 23;
        Checklist.Insert(GuidedExperienceType::Learn, LinkToRun, OrderID, TempAllProfile, true);

        // [THEN] The checklist item table contains one record 
        Assert.AreEqual(1, ChecklistItem.Count(), 'The checklist item table should contain exactly one record.');

        // [THEN] The checklist item role table contains two records
        Assert.AreEqual(2, ChecklistItemRole.Count(), 'The checklist item role table should contain two records.');

        // [WHEN] Inserting a checklist item for the same guided experience item, but with a different profile list
        Checklist.Insert(GuidedExperienceType::Learn, LinkToRun, OrderID, TempAllProfile2, true);

        // [THEN] The checklist item role table contains three records
        Assert.AreEqual(3, ChecklistItemRole.Count, 'The checklist item role table should contain 3 records.');

        // [THEN] The checklist item roles have the correct profiles and codes
        ChecklistItem.FindFirst();

        Assert.IsTrue(ChecklistItemRole.Get(ChecklistItem.Code, ProfileID1), 'The checklist item role with profile ID 1 should exist.');
        Assert.IsTrue(ChecklistItemRole.Get(ChecklistItem.Code, ProfileID3), 'The checklist item role with profile ID 3 should exist.');
        Assert.IsTrue(ChecklistItemRole.Get(ChecklistItem.Code, ProfileID4), 'The checklist item role with profile ID 4 should exist.');
        Assert.IsFalse(ChecklistItemRole.Get(ChecklistItem.Code, ProfileID2), 'The checklist item role with profile ID 2 should NOT exist.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertLearnChecklistItemWithNoGuidedExperienceItemAndUsers()
    var
        ChecklistItem: Record "Checklist Item";
        TempAllUser: Record User temporary;
        Checklist: Codeunit Checklist;
        GuidedExperienceType: Enum "Guided Experience Type";
        LinkToRun: Text[250];
        OrderId: Integer;
    begin
        // [GIVEN] The guided experience item table is empty
        Initialize(false);

        AddUserToList(TempAllUser, UserSecurityId());

        PermissionsMock.Set('Guided Exp Edit');

        // [WHEN] Inserting a new checklist item for an inexistent learn guided experience item and a list of users
        LinkToRun := GetNewLink();
        OrderId := 1573;

        Checklist.Insert(GuidedExperienceType::Learn, LinkToRun, OrderId, TempAllUser);

        // [THEN] The checklist item table is empty
        ChecklistItem.Reset();
        Assert.AreEqual(0, ChecklistItem.Count(), 'The checklist item table should be empty');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertLearnChecklistItemWithWrongGuidedExperienceItemAndUsers()
    var
        ChecklistItem: Record "Checklist Item";
        TempAllUser: Record User temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        LinkToRun1: Text[250];
        LinkToRun2: Text[250];
    begin
        Initialize(false);

        AddUserToList(TempAllUser, UserSecurityId());

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type learn 
        LinkToRun1 := GetNewLink();
        GuidedExperience.InsertLearnLink('Title', 'Short Title', 'Description', 10, LinkToRun1);

        // [WHEN] Inserting a new checklist item for a different learn link (that doesn't exist in the guided 
        // experience item table) and a list of users
        LinkToRun2 := GetNewLink();

        Checklist.Insert(GuidedExperienceType::Learn, LinkToRun2, 14, TempAllUser);

        // [THEN] The checklist item table is empty
        ChecklistItem.Reset();
        Assert.AreEqual(0, ChecklistItem.Count(), 'The checklist item table should be empty');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertLearnChecklistItemWithWrongGuidedExperienceTypeAndUsers()
    var
        ChecklistItem: Record "Checklist Item";
        TempAllUser: Record User temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        LinkToRun: Text[250];
    begin
        Initialize(false);

        AddUserToList(TempAllUser, UserSecurityId());

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type learn
        LinkToRun := GetNewLink();
        GuidedExperience.InsertLearnLink('Title', 'Short Title', 'Description', 10, LinkToRun);

        // [WHEN] Inserting a new checklist item for the same link, but a different guided experience 
        // type and a list of users
        Checklist.Insert(GuidedExperienceType::"Manual Setup", LinkToRun, 20, TempAllUser);

        // [THEN] The checklist item table is empty
        ChecklistItem.Reset();
        Assert.AreEqual(0, ChecklistItem.Count(), 'The checklist item table should be empty');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertLearnChecklistItemWithUsers()
    var
        ChecklistItem: Record "Checklist Item";
        ChecklistItemUser: Record "Checklist Item User";
        GuidedExperienceItem: Record "Guided Experience Item";
        TempAllUser: Record User temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        CompletionRequirements: Enum "Checklist Completion Requirements";
        ChecklistItemStatus: Enum "Checklist Item Status";
        LinkToRun: Text[250];
        OrderID: Integer;
        UserSecurityId: Guid;
        UserName: Code[50];
    begin
        Initialize(false);

        InsertUser(UserSecurityId, UserName);
        AddUserToList(TempAllUser, UserSecurityId);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type learn
        LinkToRun := GetNewLink();
        GuidedExperience.InsertLearnLink('Title', 'Short Title', 'Description', 10, LinkToRun);

        // [WHEN] Inserting a new checklist item for the same link and a list of users
        OrderID := 23;
        Checklist.Insert(GuidedExperienceType::Learn, LinkToRun, OrderID, TempAllUser);

        // [THEN] The checklist item table contains exactly one record
        ChecklistItem.Reset();
        Assert.AreEqual(1, ChecklistItem.Count(), 'The checklist item table should contain exactly one record.');

        // [THEN] The checklist item's fields are set correctly
        GuidedExperienceItem.FindFirst();
        ChecklistItem.FindFirst();
        VerifyChecklistItemFields(ChecklistItem, GuidedExperienceItem.Code, CompletionRequirements::"Specific users", OrderID);

        // [THEN] The checklist item user table contains exactly one record
        Assert.AreEqual(1, ChecklistItemUser.Count(), 'The checklist item user table should contain exactly one record.');

        // [THEN] The checklist item user's fields are set correctly
        ChecklistItemUser.FindFirst();
        VerifyChecklistItemUserFields(ChecklistItemUser, GuidedExperienceItem.Code, UserName, ChecklistItemStatus::"Not Started", true, true);

        // [WHEN] Inserting an identical checklist item 
        Checklist.Insert(GuidedExperienceType::Learn, LinkToRun, OrderID, TempAllUser);

        // [THEN] The checklist item and checklist item user tables still contain only one record
        Assert.AreEqual(1, ChecklistItem.Count, 'The checklist item table should not contain a new record.');
        Assert.AreEqual(1, ChecklistItemUser.Count, 'The checklist item user table should not contain a new record.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertDuplicateLearnChecklistItemWithUsers()
    var
        ChecklistItem: Record "Checklist Item";
        ChecklistItemUser: Record "Checklist Item User";
        TempAllUser: Record User temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        LinkToRun: Text[250];
        OrderID: Integer;
        UserSecurityId: Guid;
        UserName: Code[50];
    begin
        Initialize(false);

        InsertUser(UserSecurityId, UserName);
        AddUserToList(TempAllUser, UserSecurityId);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type learn
        LinkToRun := GetNewLink();
        GuidedExperience.InsertLearnLink('Title', 'Short Title', 'Description', 10, LinkToRun);

        // [WHEN] Inserting a new checklist item for the same link and a list of users
        OrderID := 23;
        Checklist.Insert(GuidedExperienceType::Learn, LinkToRun, OrderID, TempAllUser);

        // [THEN] The checklist item and checklist item user tables contain exactly one record
        Assert.AreEqual(1, ChecklistItem.Count(), 'The checklist item table should contain exactly one record.');
        Assert.AreEqual(1, ChecklistItemUser.Count(), 'The checklist item user table should contain exactly one record.');

        // [WHEN] Inserting an identical checklist item 
        Checklist.Insert(GuidedExperienceType::Learn, LinkToRun, OrderID, TempAllUser);

        // [THEN] The checklist item and checklist item user tables still contain only one record
        Assert.AreEqual(1, ChecklistItem.Count, 'The checklist item table should not contain a new record.');
        Assert.AreEqual(1, ChecklistItemUser.Count, 'The checklist item user table should not contain a new record.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestUpdateLearnChecklistItemWithUsers()
    var
        ChecklistItem: Record "Checklist Item";
        ChecklistItemUser: Record "Checklist Item User";
        GuidedExperienceItem: Record "Guided Experience Item";
        TempAllUser: Record User temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        CompletionRequirements: Enum "Checklist Completion Requirements";
        LinkToRun: Text[250];
        OrderID1: Integer;
        OrderID2: Integer;
        UserSecurityId: Guid;
        UserName: Code[50];
    begin
        Initialize(false);

        InsertUser(UserSecurityId, UserName);
        AddUserToList(TempAllUser, UserSecurityId);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type learn
        LinkToRun := GetNewLink();
        GuidedExperience.InsertLearnLink('Title', 'Short Title', 'Description', 10, LinkToRun);

        // [WHEN] Inserting a new checklist item for the same object and a list of profiles
        OrderID1 := 23;
        Checklist.Insert(GuidedExperienceType::Learn, LinkToRun, OrderID1, TempAllUser);

        // [THEN] The checklist item and checklist item user tables contain exactly one record
        Assert.AreEqual(1, ChecklistItem.Count(), 'The checklist item table should contain exactly one record.');
        Assert.AreEqual(1, ChecklistItemUser.Count(), 'The checklist item user table should contain exactly one record.');

        // [WHEN] Inserting a checklist item for the same guided experience item, but with a different order ID
        OrderID2 := 36;
        Checklist.Insert(GuidedExperienceType::Learn, LinkToRun, OrderID2, TempAllUser);

        // [THEN] The Checklist item table still contains only one record, but the order id should have changed
        GuidedExperienceItem.FindFirst();
        ChecklistItem.FindFirst();
        VerifyChecklistItemFields(ChecklistItem, GuidedExperienceItem.Code, CompletionRequirements::"Specific users", OrderID2);

        // [THEN] The checklist item user table still contains only one record
        Assert.AreEqual(1, ChecklistItemUser.Count, 'The checklist item user table should not contain a new record.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestUpdateUsersForLearnChecklistItem()
    var
        ChecklistItem: Record "Checklist Item";
        ChecklistItemUser: Record "Checklist Item User";
        TempAllUser: Record User temporary;
        TempAllUser2: Record User temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        ChecklistItemStatus: Enum "Checklist Item Status";
        LinkToRun: Text[250];
        OrderID: Integer;
        UserSecurityID1: Guid;
        UserSecurityID2: Guid;
        UserSecurityID3: Guid;
        UserSecurityID4: Guid;
        UserName1: Code[50];
        UserName2: Code[50];
        UserName3: Code[50];
        UserName4: Code[50];
    begin
        Initialize(false);

        InsertUser(UserSecurityID1, UserName1);
        InsertUser(UserSecurityID2, UserName2);

        AddUserToList(TempAllUser, UserSecurityID1);
        AddUserToList(TempAllUser, UserSecurityID2);

        InsertUser(UserSecurityID3, UserName3);
        InsertUser(UserSecurityID4, UserName4);

        AddUserToList(TempAllUser2, UserSecurityID2);
        AddUserToList(TempAllUser2, UserSecurityID3);
        AddUserToList(TempAllUser2, UserSecurityID4);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type learn
        LinkToRun := GetNewLink();
        GuidedExperience.InsertLearnLink('Title', 'Short Title', 'Description', 10, LinkToRun);

        // [WHEN] Inserting a new checklist item for the same object and a list of users
        OrderID := 23;
        Checklist.Insert(GuidedExperienceType::Learn, LinkToRun, OrderID, TempAllUser);

        // [THEN] The checklist item table contains exactly one record
        Assert.AreEqual(1, ChecklistItem.Count(), 'The checklist item table should contain exactly one record.');

        // [THEN] The checklist item user table contains two records
        Assert.AreEqual(2, ChecklistItemUser.Count(), 'The checklist item user table should contain two records.');

        // [WHEN] Inserting a checklist item for the same guided experience item, but with a different user list
        Checklist.Insert(GuidedExperienceType::Learn, LinkToRun, OrderID, TempAllUser2);

        // [THEN] The checklist item user table contains three records
        Assert.AreEqual(3, ChecklistItemUser.Count, 'The checklist item user table should contain 3 records.');

        // [THEN] The checklist item user records should be set correctly
        ChecklistItem.FindFirst();

        Assert.IsTrue(ChecklistItemUser.Get(ChecklistItem.Code, UserName2), 'The checklist item user with user security ID 2 should exist.');
        VerifyChecklistItemUserFields(ChecklistItemUser, ChecklistItem.Code, UserName2, ChecklistItemStatus::"Not Started", true, true);

        Assert.IsTrue(ChecklistItemUser.Get(ChecklistItem.Code, UserName3), 'The checklist item user with user security ID 3 should exist.');
        VerifyChecklistItemUserFields(ChecklistItemUser, ChecklistItem.Code, UserName3, ChecklistItemStatus::"Not Started", true, true);

        Assert.IsTrue(ChecklistItemUser.Get(ChecklistItem.Code, UserName4), 'The checklist item user with user security ID 4 should exist.');
        VerifyChecklistItemUserFields(ChecklistItemUser, ChecklistItem.Code, UserName4, ChecklistItemStatus::"Not Started", true, true);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertApplicationFeatureChecklistItemWithProfiles()
    var
        ChecklistItem: Record "Checklist Item";
        ChecklistItemRole: Record "Checklist Item Role";
        GuidedExperienceItem: Record "Guided Experience Item";
        TempAllProfile: Record "All Profile" temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        CompletionRequirements: Enum "Checklist Completion Requirements";
        ObjectTypeToRun: ObjectType;
        ObjectIdToRun: Integer;
        OrderID: Integer;
    begin
        Initialize(false);

        AddRoleToList(TempAllProfile, ProfileID1);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type application feature
        ObjectTypeToRun := ObjectType::Page;
        ObjectIdToRun := Page::Checklist;
        GuidedExperience.InsertApplicationFeature('Title', 'Short Title', 'Description', 10, ObjectTypeToRun, ObjectIdToRun);

        // [WHEN] Inserting a new checklist item for the same object and a list of profiles
        OrderID := 23;
        Checklist.Insert(GuidedExperienceType::"Application Feature", ObjectTypeToRun,
            ObjectIdToRun, OrderID, TempAllProfile, true);

        // [THEN] The checklist item table contains exactly one record
        ChecklistItem.Reset();
        Assert.AreEqual(1, ChecklistItem.Count(), 'The checklist item table should contain exactly one record.');

        // [THEN] The checklist item's fields are set correctly
        GuidedExperienceItem.FindFirst();
        ChecklistItem.FindFirst();
        VerifyChecklistItemFields(ChecklistItem, GuidedExperienceItem.Code, CompletionRequirements::Everyone, OrderID);

        // [THEN] The checklist item role table contains exactly one record
        ChecklistItem.Reset();
        Assert.AreEqual(1, ChecklistItemRole.Count(), 'The checklist item table should contain exactly one record.');

        // [THEN] The checklist item role's fields are set correctly
        ChecklistItemRole.FindFirst();
        VerifyChecklistItemRoleFields(ChecklistItemRole, GuidedExperienceItem.Code, TempAllProfile."Profile ID");

        // [WHEN] Inserting an identical checklist item 
        Checklist.Insert(GuidedExperienceType::"Application Feature", ObjectTypeToRun, ObjectIdToRun, OrderID, TempAllProfile, true);

        // [THEN] The checklist item and checklist item role tables still contain only one record
        Assert.AreEqual(1, ChecklistItem.Count, 'The checklist item table should not contain a new record.');
        Assert.AreEqual(1, ChecklistItemRole.Count, 'The checklist item role table should not contain a new record.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertVideoChecklistItemWithUsers()
    var
        ChecklistItem: Record "Checklist Item";
        ChecklistItemUser: Record "Checklist Item User";
        GuidedExperienceItem: Record "Guided Experience Item";
        TempAllUser: Record User temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        CompletionRequirements: Enum "Checklist Completion Requirements";
        ChecklistItemStatus: Enum "Checklist Item Status";
        VideoCategory: Enum "Video Category";
        VideoUrl: Text[250];
        OrderID: Integer;
        UserSecurityId: Guid;
        UserName: Code[50];
    begin
        Initialize(false);

        InsertUser(UserSecurityId, UserName);
        AddUserToList(TempAllUser, UserSecurityId);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type video
        VideoUrl := GetNewLink();
        GuidedExperience.InsertVideo('Title', 'Short Title', 'Description', 10, VideoUrl, VideoCategory::Uncategorized);

        // [WHEN] Inserting a new checklist item for the same video url and a list of users
        OrderID := 23;
        Checklist.Insert(GuidedExperienceType::Video, VideoUrl, OrderID, TempAllUser);

        // [THEN] The checklist item table contains exactly one record
        ChecklistItem.Reset();
        Assert.AreEqual(1, ChecklistItem.Count(), 'The checklist item table should contain exactly one record.');

        // [THEN] The checklist item's fields are set correctly
        GuidedExperienceItem.FindFirst();
        ChecklistItem.FindFirst();
        VerifyChecklistItemFields(ChecklistItem, GuidedExperienceItem.Code, CompletionRequirements::"Specific users", OrderID);

        // [THEN] The checklist item user table contains exactly one record
        Assert.AreEqual(1, ChecklistItemUser.Count(), 'The checklist item user table should contain exactly one record.');

        // [THEN] The checklist item user's fields are set correctly
        ChecklistItemUser.FindFirst();
        VerifyChecklistItemUserFields(ChecklistItemUser, GuidedExperienceItem.Code, UserName, ChecklistItemStatus::"Not Started", true, true);

        // [WHEN] Inserting an identical checklist item 
        Checklist.Insert(GuidedExperienceType::Video, VideoUrl, OrderID, TempAllUser);

        // [THEN] The checklist item and checklist item user tables still contain only one record
        Assert.AreEqual(1, ChecklistItem.Count, 'The checklist item table should not contain a new record.');
        Assert.AreEqual(1, ChecklistItemUser.Count, 'The checklist item user table should not contain a new record.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertTourChecklistItemWithProfiles()
    var
        ChecklistItem: Record "Checklist Item";
        ChecklistItemRole: Record "Checklist Item Role";
        GuidedExperienceItem: Record "Guided Experience Item";
        TempAllProfile: Record "All Profile" temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        CompletionRequirements: Enum "Checklist Completion Requirements";
        ObjectTypeToRun: ObjectType;
        ObjectIdToRun: Integer;
        OrderID: Integer;
    begin
        Initialize(false);

        AddRoleToList(TempAllProfile, ProfileID1);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type tour
        ObjectTypeToRun := ObjectType::Page;
        ObjectIdToRun := Page::Checklist;
        GuidedExperience.InsertTour('Title', 'Short Title', 'Description', 10, ObjectIdToRun);

        // [WHEN] Inserting a new checklist item for the same object and a list of profiles
        OrderID := 23;
        Checklist.Insert(GuidedExperienceType::Tour, ObjectTypeToRun,
            ObjectIdToRun, OrderID, TempAllProfile, true);

        // [THEN] The checklist item table contains exactly one record
        ChecklistItem.Reset();
        Assert.AreEqual(1, ChecklistItem.Count(), 'The checklist item table should contain exactly one record.');

        // [THEN] The checklist item's fields are set correctly
        GuidedExperienceItem.FindFirst();
        ChecklistItem.FindFirst();
        VerifyChecklistItemFields(ChecklistItem, GuidedExperienceItem.Code, CompletionRequirements::Everyone, OrderID);

        // [THEN] The checklist item role table contains exactly one record
        ChecklistItem.Reset();
        Assert.AreEqual(1, ChecklistItemRole.Count(), 'The checklist item table should contain exactly one record.');

        // [THEN] The checklist item role's fields are set correctly
        ChecklistItemRole.FindFirst();
        VerifyChecklistItemRoleFields(ChecklistItemRole, GuidedExperienceItem.Code, TempAllProfile."Profile ID");

        // [WHEN] Inserting an identical checklist item 
        Checklist.Insert(GuidedExperienceType::Tour, ObjectTypeToRun, ObjectIdToRun, OrderID, TempAllProfile, true);

        // [THEN] The checklist item and checklist item role tables still contain only one record
        Assert.AreEqual(1, ChecklistItem.Count, 'The checklist item table should not contain a new record.');
        Assert.AreEqual(1, ChecklistItemRole.Count, 'The checklist item role table should not contain a new record.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertSpotlightTourChecklistItemWithUsers()
    var
        ChecklistItem: Record "Checklist Item";
        ChecklistItemUser: Record "Checklist Item User";
        GuidedExperienceItem: Record "Guided Experience Item";
        SpotlightTourText: Record "Spotlight Tour Text";
        TempAllUser: Record User temporary;
        Checklist: Codeunit Checklist;
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        CompletionRequirements: Enum "Checklist Completion Requirements";
        ChecklistItemStatus: Enum "Checklist Item Status";
        SpotlightTourType: Enum "Spotlight Tour Type";
        SpotlightDictionary: Dictionary of [Enum "Spotlight Tour Text", Text];
        Step1Title: Text;
        Step1Text: Text;
        Step2Title: Text;
        Step2Text: Text;
        ObjectTypeToRun: ObjectType;
        ObjectIdToRun: Integer;
        OrderID: Integer;
        UserSecurityId: Guid;
        UserName: Code[50];
    begin
        Initialize(false);

        InsertUser(UserSecurityId, UserName);
        AddUserToList(TempAllUser, UserSecurityId);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A new guided experience item of type spotlight tour
        ObjectTypeToRun := ObjectType::Page;
        ObjectIdToRun := Page::Checklist;
        SpotlightTourType := SpotlightTourType::"Open in Excel";
        GetSpotlightDictionary(SpotlightDictionary, Step1Title, Step1Text, Step2Title, Step2Text);
        GuidedExperience.InsertSpotlightTour('Title', 'Short Title', 'Description', 10,
            ObjectIdToRun, SpotlightTourType, SpotlightDictionary);

        // [WHEN] Inserting a new checklist item for the same object and a list of users
        OrderID := 23;
        Checklist.Insert(ObjectIdToRun, SpotlightTourType, OrderID, TempAllUser);

        // [THEN] The checklist item table contains exactly one record
        ChecklistItem.Reset();
        Assert.AreEqual(1, ChecklistItem.Count(), 'The checklist item table should contain exactly one record.');

        // [THEN] The checklist item's fields are set correctly
        GuidedExperienceItem.FindFirst();
        ChecklistItem.FindFirst();
        VerifyChecklistItemFields(ChecklistItem, GuidedExperienceItem.Code, CompletionRequirements::"Specific users", OrderID);

        // [THEN] The checklist item user table contains exactly one record
        Assert.AreEqual(1, ChecklistItemUser.Count(), 'The checklist item user table should contain exactly one record.');

        // [THEN] The checklist item user's fields are set correctly
        ChecklistItemUser.FindFirst();
        VerifyChecklistItemUserFields(ChecklistItemUser, GuidedExperienceItem.Code, UserName, ChecklistItemStatus::"Not Started", true, true);

        // [THEN] The spotlight tour text table contains 4 entries for the 
        // checklist item and the entries are set correctly 
        SpotlightTourText.SetRange("Guided Experience Item Code", GuidedExperienceItem.Code);
        SpotlightTourText.SetRange("Guided Experience Item Version", GuidedExperienceItem.Version);
        Assert.AreEqual(4, SpotlightTourText.Count,
            'The Spotlight Tour Text table should contain 4 entries for this checklist item.');

        // [WHEN] Inserting an identical checklist item 
        Checklist.Insert(GuidedExperienceType::"Spotlight Tour", ObjectTypeToRun, ObjectIdToRun, OrderID, TempAllUser);

        // [THEN] The checklist item and checklist item user tables still contain only one record
        Assert.AreEqual(1, ChecklistItem.Count, 'The checklist item table should not contain a new record.');
        Assert.AreEqual(1, ChecklistItemUser.Count, 'The checklist item user table should not contain a new record.');

        // [THEN] The spotlight tour text table still contains 4 entries
        Assert.AreEqual(4, SpotlightTourText.Count,
            'The Spotlight Tour Text table should contain 4 entries for this checklist item.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestDeleteAssistedSetupChecklistItemWithProfiles()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        ChecklistItem: Record "Checklist Item";
        ChecklistItemRole: Record "Checklist Item Role";
        TempAllProfile: Record "All Profile" temporary;
        GuidedExperience: Codeunit "Guided Experience";
        Checklist: Codeunit Checklist;
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        ManualSetupCategory: Enum "Manual Setup Category";
        GuidedExperienceType: Enum "Guided Experience Type";
        ObjectTypeToRun1: ObjectType;
        ObjectTypeToRun2: ObjectType;
        ObjectIDToRun1: Integer;
        ObjectIDToRun2: Integer;
        LinkToRun: Text[250];
    begin
        Initialize(false);

        AddRoleToList(TempAllProfile, ProfileID1);
        AddRoleToList(TempAllProfile, ProfileID2);
        AddRoleToList(TempAllProfile, ProfileID3);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] Two assisted setup guided experience items for two different objects
        ObjectTypeToRun1 := ObjectType::Page;
        ObjectIDToRun1 := Page::"Checklist Item Roles";
        GuidedExperience.InsertAssistedSetup('Title', 'Short Title', 'Description', 9, ObjectTypeToRun1, ObjectIDToRun1,
AssistedSetupGroup::Uncategorized, '', VideoCategory::Uncategorized, '');

        ObjectTypeToRun2 := ObjectType::Codeunit;
        ObjectIDToRun2 := Codeunit::"Guided Experience";
        GuidedExperience.InsertAssistedSetup('Title', 'Short Title', 'Description', 9, ObjectTypeToRun2, ObjectIDToRun2,
AssistedSetupGroup::Uncategorized, '', VideoCategory::Uncategorized, '');

        // [GIVEN] A manual setup guided experience item for the same object as one of the assisted setups
        GuidedExperience.InsertManualSetup('Title', 'Short Title', 'Description', 7, ObjectTypeToRun2,
ObjectIDToRun2, ManualSetupCategory::Uncategorized, '');

        // [GIVEN] A link guided experience item
        LinkToRun := GetNewLink();
        GuidedExperience.InsertLearnLink('Title', 'Short Title', 'Description', 10, LinkToRun);

        // [GIVEN] Checklist items for the 4 guided experience items
        Checklist.Insert(GuidedExperienceType::"Assisted Setup", ObjectTypeToRun1, ObjectIDToRun1, 1, TempAllProfile, true);
        Checklist.Insert(GuidedExperienceType::"Assisted Setup", ObjectTypeToRun2, ObjectIDToRun2, 2, TempAllProfile, false);
        Checklist.Insert(GuidedExperienceType::"Manual Setup", ObjectTypeToRun2, ObjectIDToRun2, 3, TempAllProfile, true);
        Checklist.Insert(GuidedExperienceType::Learn, LinkToRun, 4, TempAllProfile, false);

        // [THEN] The checklist item table should contain 4 entries
        Assert.AreEqual(4, ChecklistItem.Count, 'The checklist item table should contain 4 entries.');

        // [WHEN] Deleting the first assisted setup checklist item
        Checklist.Delete(GuidedExperienceType::"Assisted Setup", ObjectTypeToRun1, ObjectIDToRun1);

        // [THEN] The checklist item table should contain 3 entries
        Assert.AreEqual(3, ChecklistItem.Count, 'The checklist item table should contain 3 entries.');

        // [THEN] The checklist item table should no longer contain the deleted assisted setup
        GuidedExperienceItem.SetRange("Guided Experience Type", "Guided Experience Type"::"Assisted Setup");
        GuidedExperienceItem.SetRange("Object ID to Run", ObjectIDToRun1);
        GuidedExperienceItem.FindFirst();

        ChecklistItem.SetRange(Code, GuidedExperienceItem.Code);
        Assert.AreEqual(0, ChecklistItem.Count, 'The checklist item table should no longer contain the deleted assisted setup.');

        // [THEN] The checklist item role table should not contain any entries associated with the deleted assisted setup
        ChecklistItemRole.SetRange(Code, GuidedExperienceItem.Code);
        Assert.AreEqual(0, ChecklistItemRole.Count,
'The checklist item role table should no longer contain any entries associated with the deleted assisted setup.');

        // [WHEN] Deleting the second assisted setup, which is associated to the same object as the manual setup
        Checklist.Delete(GuidedExperienceType::"Assisted Setup", ObjectTypeToRun2, ObjectIDToRun2);

        // [THEN] The checklist item table should contain 2 entries (the manual setup and the learn item)
        ChecklistItem.Reset();
        Assert.AreEqual(2, ChecklistItem.Count, 'The checklist item table should contain 2 entries.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestDeleteAssistedSetupChecklistItemWithUsers()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        ChecklistItem: Record "Checklist Item";
        ChecklistItemUser: Record "Checklist Item Role";
        TempUser: Record User temporary;
        GuidedExperience: Codeunit "Guided Experience";
        Checklist: Codeunit Checklist;
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        ManualSetupCategory: Enum "Manual Setup Category";
        GuidedExperienceType: Enum "Guided Experience Type";
        ObjectTypeToRun1: ObjectType;
        ObjectTypeToRun2: ObjectType;
        ObjectIDToRun1: Integer;
        ObjectIDToRun2: Integer;
        LinkToRun: Text[250];
        UserSecurityID1: Guid;
        Username1: Code[50];
        UserSecurityID2: Guid;
        Username2: Code[50];
    begin
        Initialize(false);

        InsertUser(UserSecurityID1, Username1);
        InsertUser(UserSecurityID2, Username2);
        AddUserToList(TempUser, UserSecurityID1);
        AddUserToList(TempUser, UserSecurityID2);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] Two assisted setup guided experience items for two different objects
        ObjectTypeToRun1 := ObjectType::Page;
        ObjectIDToRun1 := Page::"Checklist Item Roles";
        GuidedExperience.InsertAssistedSetup('Title', 'Short Title', 'Description', 9, ObjectTypeToRun1, ObjectIDToRun1,
AssistedSetupGroup::Uncategorized, '', VideoCategory::Uncategorized, '');

        ObjectTypeToRun2 := ObjectType::Codeunit;
        ObjectIDToRun2 := Codeunit::"Guided Experience";
        GuidedExperience.InsertAssistedSetup('Title', 'Short Title', 'Description', 9, ObjectTypeToRun2, ObjectIDToRun2,
AssistedSetupGroup::Uncategorized, '', VideoCategory::Uncategorized, '');

        // [GIVEN] A manual setup guided experience item for the same object as one of the assisted setups
        GuidedExperience.InsertManualSetup('Title', 'Short Title', 'Description', 7, ObjectTypeToRun2,
ObjectIDToRun2, ManualSetupCategory::Uncategorized, '');

        // [GIVEN] A link guided experience item
        LinkToRun := GetNewLink();
        GuidedExperience.InsertLearnLink('Title', 'Short Title', 'Description', 10, LinkToRun);

        // [GIVEN] Checklist items for the 4 guided experience items
        Checklist.Insert(GuidedExperienceType::"Assisted Setup", ObjectTypeToRun1, ObjectIDToRun1, 1, TempUser);
        Checklist.Insert(GuidedExperienceType::"Assisted Setup", ObjectTypeToRun2, ObjectIDToRun2, 2, TempUser);
        Checklist.Insert(GuidedExperienceType::"Manual Setup", ObjectTypeToRun2, ObjectIDToRun2, 3, TempUser);
        Checklist.Insert(GuidedExperienceType::Learn, LinkToRun, 4, TempUser);

        // [THEN] The checklist item table should contain 4 entries
        Assert.AreEqual(4, ChecklistItem.Count, 'The checklist item table should contain 4 entries.');

        // [WHEN] Deleting the first assisted setup checklist item
        Checklist.Delete(GuidedExperienceType::"Assisted Setup", ObjectTypeToRun1, ObjectIDToRun1);

        // [THEN] The checklist item table should contain 3 entries
        Assert.AreEqual(3, ChecklistItem.Count, 'The checklist item table should contain 3 entries.');

        // [THEN] The checklist item table should no longer contain the deleted assisted setup
        GuidedExperienceItem.SetRange("Guided Experience Type", "Guided Experience Type"::"Assisted Setup");
        GuidedExperienceItem.SetRange("Object ID to Run", ObjectIDToRun1);
        GuidedExperienceItem.FindFirst();

        ChecklistItem.SetRange(Code, GuidedExperienceItem.Code);
        Assert.AreEqual(0, ChecklistItem.Count, 'The checklist item table should no longer contain the deleted assisted setup.');

        // [THEN] The checklist item user table should not contain any entries associated with the deleted assisted setup
        ChecklistItemUser.SetRange(Code, GuidedExperienceItem.Code);
        Assert.AreEqual(0, ChecklistItemUser.Count,
'The checklist item user table should no longer contain any entries associated with the deleted assisted setup.');

        // [WHEN] Deleting the second assisted setup, which is associated to the same object as the manual setup
        Checklist.Delete(GuidedExperienceType::"Assisted Setup", ObjectTypeToRun2, ObjectIDToRun2);

        // [THEN] The checklist item table should contain 2 entries (the manual setup and the learn item)
        ChecklistItem.Reset();
        Assert.AreEqual(2, ChecklistItem.Count, 'The checklist item table should contain 2 entries.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestDeleteManualSetupChecklistItemWithProfiles()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        ChecklistItem: Record "Checklist Item";
        ChecklistItemRole: Record "Checklist Item Role";
        TempAllProfile: Record "All Profile" temporary;
        GuidedExperience: Codeunit "Guided Experience";
        Checklist: Codeunit Checklist;
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        ManualSetupCategory: Enum "Manual Setup Category";
        GuidedExperienceType: Enum "Guided Experience Type";
        ObjectTypeToRun1: ObjectType;
        ObjectTypeToRun2: ObjectType;
        ObjectIDToRun1: Integer;
        ObjectIDToRun2: Integer;
        LinkToRun: Text[250];
    begin
        Initialize(false);

        AddRoleToList(TempAllProfile, ProfileID1);
        AddRoleToList(TempAllProfile, ProfileID2);
        AddRoleToList(TempAllProfile, ProfileID3);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] Two manual setup guided experience items for two different objects
        ObjectTypeToRun1 := ObjectType::Page;
        ObjectIDToRun1 := Page::"Checklist Item Roles";
        GuidedExperience.InsertManualSetup('Title', 'Short Title', 'Description', 15, ObjectTypeToRun1,
ObjectIDToRun1, ManualSetupCategory::Uncategorized, '');

        ObjectTypeToRun2 := ObjectType::Codeunit;
        ObjectIDToRun2 := Codeunit::"Guided Experience";
        GuidedExperience.InsertManualSetup('Title', 'Short Title', 'Description', 10, ObjectTypeToRun2,
ObjectIDToRun2, ManualSetupCategory::Uncategorized, '');

        // [GIVEN] An assisted setup guided experience item for the same object as one of the manual setups
        GuidedExperience.InsertAssistedSetup('Title', 'Short Title', 'Description', 9, ObjectTypeToRun2, ObjectIDToRun2,
AssistedSetupGroup::Uncategorized, '', VideoCategory::Uncategorized, '');

        // [GIVEN] A link guided experience item
        LinkToRun := GetNewLink();
        GuidedExperience.InsertLearnLink('Title', 'Short Title', 'Description', 10, LinkToRun);

        // [GIVEN] Checklist items for the 4 guided experience items
        Checklist.Insert(GuidedExperienceType::"Manual Setup", ObjectTypeToRun1, ObjectIDToRun1, 1, TempAllProfile, true);
        Checklist.Insert(GuidedExperienceType::"Manual Setup", ObjectTypeToRun2, ObjectIDToRun2, 2, TempAllProfile, false);
        Checklist.Insert(GuidedExperienceType::"Assisted Setup", ObjectTypeToRun2, ObjectIDToRun2, 3, TempAllProfile, true);
        Checklist.Insert(GuidedExperienceType::Learn, LinkToRun, 4, TempAllProfile, false);

        // [THEN] The checklist item table should contain 4 entries
        Assert.AreEqual(4, ChecklistItem.Count, 'The checklist item table should contain 4 entries.');

        // [WHEN] Deleting the first manual setup checklist item
        Checklist.Delete(GuidedExperienceType::"Manual Setup", ObjectTypeToRun1, ObjectIDToRun1);

        // [THEN] The checklist item table should contain 3 entries
        Assert.AreEqual(3, ChecklistItem.Count, 'The checklist item table should contain 3 entries.');

        // [THEN] The checklist item table should no longer contain the deleted manual setup
        GuidedExperienceItem.SetRange("Guided Experience Type", "Guided Experience Type"::"Manual Setup");
        GuidedExperienceItem.SetRange("Object ID to Run", ObjectIDToRun1);
        GuidedExperienceItem.FindFirst();

        ChecklistItem.SetRange(Code, GuidedExperienceItem.Code);
        Assert.AreEqual(0, ChecklistItem.Count, 'The checklist item table should no longer contain the deleted manual setup.');

        // [THEN] The checklist item role table should not contain any entries associated with the deleted manual setup
        ChecklistItemRole.SetRange(Code, GuidedExperienceItem.Code);
        Assert.AreEqual(0, ChecklistItemRole.Count,
'The checklist item role table should no longer contain any entries associated with the deleted manual setup.');

        // [WHEN] Deleting the second manual setup, which is associated to the same object as the assisted setup
        Checklist.Delete(GuidedExperienceType::"Manual Setup", ObjectTypeToRun2, ObjectIDToRun2);

        // [THEN] The checklist item table should contain 2 entries (the assisted setup and the learn item)
        ChecklistItem.Reset();
        Assert.AreEqual(2, ChecklistItem.Count, 'The checklist item table should contain 2 entries.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestDeleteManualSetupChecklistItemWithUsers()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        ChecklistItem: Record "Checklist Item";
        ChecklistItemUser: Record "Checklist Item Role";
        TempUser: Record User temporary;
        GuidedExperience: Codeunit "Guided Experience";
        Checklist: Codeunit Checklist;
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        ManualSetupCategory: Enum "Manual Setup Category";
        GuidedExperienceType: Enum "Guided Experience Type";
        ObjectTypeToRun1: ObjectType;
        ObjectTypeToRun2: ObjectType;
        ObjectIDToRun1: Integer;
        ObjectIDToRun2: Integer;
        LinkToRun: Text[250];
        UserSecurityID1: Guid;
        Username1: Code[50];
        UserSecurityID2: Guid;
        Username2: Code[50];
    begin
        Initialize(false);

        InsertUser(UserSecurityID1, Username1);
        InsertUser(UserSecurityID2, Username2);
        AddUserToList(TempUser, UserSecurityID1);
        AddUserToList(TempUser, UserSecurityID2);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] Two manual setup guided experience items for two different objects
        ObjectTypeToRun1 := ObjectType::Page;
        ObjectIDToRun1 := Page::"Checklist Item Roles";
        GuidedExperience.InsertManualSetup('Title', 'Short Title', 'Description', 15, ObjectTypeToRun1,
ObjectIDToRun1, ManualSetupCategory::Uncategorized, '');

        ObjectTypeToRun2 := ObjectType::Codeunit;
        ObjectIDToRun2 := Codeunit::"Guided Experience";
        GuidedExperience.InsertManualSetup('Title', 'Short Title', 'Description', 10, ObjectTypeToRun2,
ObjectIDToRun2, ManualSetupCategory::Uncategorized, '');

        // [GIVEN] An assisted setup guided experience item for the same object as one of the manual setups
        GuidedExperience.InsertAssistedSetup('Title', 'Short Title', 'Description', 9, ObjectTypeToRun2, ObjectIDToRun2,
AssistedSetupGroup::Uncategorized, '', VideoCategory::Uncategorized, '');

        // [GIVEN] A link guided experience item
        LinkToRun := GetNewLink();
        GuidedExperience.InsertLearnLink('Title', 'Short Title', 'Description', 10, LinkToRun);

        // [GIVEN] Checklist items for the 4 guided experience items
        Checklist.Insert(GuidedExperienceType::"Manual Setup", ObjectTypeToRun1, ObjectIDToRun1, 1, TempUser);
        Checklist.Insert(GuidedExperienceType::"Manual Setup", ObjectTypeToRun2, ObjectIDToRun2, 2, TempUser);
        Checklist.Insert(GuidedExperienceType::"Assisted Setup", ObjectTypeToRun2, ObjectIDToRun2, 3, TempUser);
        Checklist.Insert(GuidedExperienceType::Learn, LinkToRun, 4, TempUser);

        // [THEN] The checklist item table should contain 4 entries
        Assert.AreEqual(4, ChecklistItem.Count, 'The checklist item table should contain 4 entries.');

        // [WHEN] Deleting the first manual setup checklist item
        Checklist.Delete(GuidedExperienceType::"Manual Setup", ObjectTypeToRun1, ObjectIDToRun1);

        // [THEN] The checklist item table should contain 3 entries
        Assert.AreEqual(3, ChecklistItem.Count, 'The checklist item table should contain 3 entries.');

        // [THEN] The checklist item table should no longer contain the deleted manual setup
        GuidedExperienceItem.SetRange("Guided Experience Type", "Guided Experience Type"::"Manual Setup");
        GuidedExperienceItem.SetRange("Object ID to Run", ObjectIDToRun1);
        GuidedExperienceItem.FindFirst();

        ChecklistItem.SetRange(Code, GuidedExperienceItem.Code);
        Assert.AreEqual(0, ChecklistItem.Count, 'The checklist item table should no longer contain the deleted manual setup.');

        // [THEN] The checklist item user table should not contain any entries associated with the deleted manual setup
        ChecklistItemUser.SetRange(Code, GuidedExperienceItem.Code);
        Assert.AreEqual(0, ChecklistItemUser.Count,
'The checklist item user table should no longer contain any entries associated with the deleted manual setup.');

        // [WHEN] Deleting the second manual setup, which is associated to the same object as the assisted setup
        Checklist.Delete(GuidedExperienceType::"Manual Setup", ObjectTypeToRun2, ObjectIDToRun2);

        // [THEN] The checklist item table should contain 2 entries (the assisted setup and the learn item)
        ChecklistItem.Reset();
        Assert.AreEqual(2, ChecklistItem.Count, 'The checklist item table should contain 2 entries.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestDeleteLearnChecklistItemWithProfiles()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        ChecklistItem: Record "Checklist Item";
        ChecklistItemRole: Record "Checklist Item Role";
        TempAllProfile: Record "All Profile" temporary;
        GuidedExperience: Codeunit "Guided Experience";
        Checklist: Codeunit Checklist;
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        ManualSetupCategory: Enum "Manual Setup Category";
        GuidedExperienceType: Enum "Guided Experience Type";
        LinkToRun1: Text[250];
        LinkToRun2: Text[250];
        ObjectTypeToRun1: ObjectType;
        ObjectTypeToRun2: ObjectType;
        ObjectIDToRun1: Integer;
        ObjectIDToRun2: Integer;
    begin
        Initialize(false);

        AddRoleToList(TempAllProfile, ProfileID1);
        AddRoleToList(TempAllProfile, ProfileID2);
        AddRoleToList(TempAllProfile, ProfileID3);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] Two learn experience items for two different links
        LinkToRun1 := GetNewLink();
        GuidedExperience.InsertLearnLink('Title', 'Short Title', 'Description', 10, LinkToRun1);

        LinkToRun2 := GetNewLink();
        GuidedExperience.InsertLearnLink('Title', 'Short Title', 'Description', 15, LinkToRun2);

        // [GIVEN] An assisted setup guided experience item 
        ObjectTypeToRun1 := ObjectType::Page;
        ObjectIDToRun1 := Page::"Assisted Setup";
        GuidedExperience.InsertAssistedSetup('Title', 'Short Title', 'Description', 9, ObjectTypeToRun1, ObjectIDToRun1,
AssistedSetupGroup::Uncategorized, '', VideoCategory::Uncategorized, '');

        // [GIVEN] A manual setup guided experience item
        ObjectTypeToRun2 := ObjectType::Codeunit;
        ObjectIDToRun2 := Codeunit::"Checklist Administration";
        GuidedExperience.InsertManualSetup('Title', 'Short Title', 'Description', 15, ObjectTypeToRun2,
ObjectIDToRun2, ManualSetupCategory::Uncategorized, '');

        // [GIVEN] Checklist items for the 4 guided experience items
        Checklist.Insert(GuidedExperienceType::Learn, LinkToRun1, 1, TempAllProfile, false);
        Checklist.Insert(GuidedExperienceType::Learn, LinkToRun2, 2, TempAllProfile, true);
        Checklist.Insert(GuidedExperienceType::"Assisted Setup", ObjectTypeToRun1, ObjectIDToRun1, 3, TempAllProfile, true);
        Checklist.Insert(GuidedExperienceType::"Manual Setup", ObjectTypeToRun2, ObjectIDToRun2, 4, TempAllProfile, false);

        // [THEN] The checklist item table should contain 4 entries
        Assert.AreEqual(4, ChecklistItem.Count, 'The checklist item table should contain 4 entries.');

        // [WHEN] Deleting the first learn checklist item
        Checklist.Delete(GuidedExperienceType::Learn, LinkToRun1);

        // [THEN] The checklist item table should contain 3 entries
        Assert.AreEqual(3, ChecklistItem.Count, 'The checklist item table should contain 3 entries.');

        // [THEN] The checklist item table should no longer contain the deleted learn link
        GuidedExperienceItem.SetRange("Guided Experience Type", "Guided Experience Type"::Learn);
        GuidedExperienceItem.SetRange(Link, LinkToRun1);
        GuidedExperienceItem.FindFirst();

        ChecklistItem.SetRange(Code, GuidedExperienceItem.Code);
        Assert.AreEqual(0, ChecklistItem.Count, 'The checklist item table should no longer contain the deleted learn link.');

        // [THEN] The checklist item role table should not contain any entries associated with the deleted learn
        ChecklistItemRole.SetRange(Code, GuidedExperienceItem.Code);
        Assert.AreEqual(0, ChecklistItemRole.Count,
'The checklist item role table should no longer contain any entries associated with the deleted learn link.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestDeleteLearnChecklistItemWithUsers()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        ChecklistItem: Record "Checklist Item";
        ChecklistItemUser: Record "Checklist Item User";
        TempUser: Record User temporary;
        GuidedExperience: Codeunit "Guided Experience";
        Checklist: Codeunit Checklist;
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        ManualSetupCategory: Enum "Manual Setup Category";
        GuidedExperienceType: Enum "Guided Experience Type";
        LinkToRun1: Text[250];
        LinkToRun2: Text[250];
        ObjectTypeToRun1: ObjectType;
        ObjectTypeToRun2: ObjectType;
        ObjectIDToRun1: Integer;
        ObjectIDToRun2: Integer;
        UserSecurityID1: Guid;
        Username1: Code[50];
        UserSecurityID2: Guid;
        Username2: Code[50];
    begin
        Initialize(false);

        InsertUser(UserSecurityID1, Username1);
        InsertUser(UserSecurityID2, Username2);
        AddUserToList(TempUser, UserSecurityID1);
        AddUserToList(TempUser, UserSecurityID2);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] Two learn experience items for two different links
        LinkToRun1 := GetNewLink();
        GuidedExperience.InsertLearnLink('Title', 'Short Title', 'Description', 10, LinkToRun1);

        LinkToRun2 := GetNewLink();
        GuidedExperience.InsertLearnLink('Title', 'Short Title', 'Description', 15, LinkToRun2);

        // [GIVEN] An assisted setup guided experience item 
        ObjectTypeToRun1 := ObjectType::Page;
        ObjectIDToRun1 := Page::"Assisted Setup";
        GuidedExperience.InsertAssistedSetup('Title', 'Short Title', 'Description', 9, ObjectTypeToRun1, ObjectIDToRun1,
AssistedSetupGroup::Uncategorized, '', VideoCategory::Uncategorized, '');

        // [GIVEN] A manual setup guided experience item
        ObjectTypeToRun2 := ObjectType::Codeunit;
        ObjectIDToRun2 := Codeunit::"Checklist Administration";
        GuidedExperience.InsertManualSetup('Title', 'Short Title', 'Description', 15, ObjectTypeToRun2,
ObjectIDToRun2, ManualSetupCategory::Uncategorized, '');

        // [GIVEN] Checklist items for the 4 guided experience items
        Checklist.Insert(GuidedExperienceType::Learn, LinkToRun1, 1, TempUser);
        Checklist.Insert(GuidedExperienceType::Learn, LinkToRun2, 2, TempUser);
        Checklist.Insert(GuidedExperienceType::"Assisted Setup", ObjectTypeToRun1, ObjectIDToRun1, 3, TempUser);
        Checklist.Insert(GuidedExperienceType::"Manual Setup", ObjectTypeToRun2, ObjectIDToRun2, 4, TempUser);

        // [THEN] The checklist item table should contain 4 entries
        Assert.AreEqual(4, ChecklistItem.Count, 'The checklist item table should contain 4 entries.');

        // [WHEN] Deleting the first learn checklist item
        Checklist.Delete(GuidedExperienceType::Learn, LinkToRun1);

        // [THEN] The checklist item table should contain 3 entries
        Assert.AreEqual(3, ChecklistItem.Count, 'The checklist item table should contain 3 entries.');

        // [THEN] The checklist item table should no longer contain the deleted learn link
        GuidedExperienceItem.SetRange("Guided Experience Type", "Guided Experience Type"::Learn);
        GuidedExperienceItem.SetRange(Link, LinkToRun1);
        GuidedExperienceItem.FindFirst();

        ChecklistItem.SetRange(Code, GuidedExperienceItem.Code);
        Assert.AreEqual(0, ChecklistItem.Count, 'The checklist item table should no longer contain the deleted learn link.');

        // [THEN] The checklist item user table should not contain any entries associated with the deleted learn
        ChecklistItemUser.SetRange(Code, GuidedExperienceItem.Code);
        Assert.AreEqual(0, ChecklistItemUser.Count,
'The checklist item user table should no longer contain any entries associated with the deleted learn link.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestDeleteVideoChecklistItemWithProfiles()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        ChecklistItem: Record "Checklist Item";
        ChecklistItemRole: Record "Checklist Item Role";
        TempAllProfile: Record "All Profile" temporary;
        GuidedExperience: Codeunit "Guided Experience";
        Checklist: Codeunit Checklist;
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        ManualSetupCategory: Enum "Manual Setup Category";
        GuidedExperienceType: Enum "Guided Experience Type";
        VideoUrl1: Text[250];
        VideoUrl2: Text[250];
        ObjectTypeToRun1: ObjectType;
        ObjectTypeToRun2: ObjectType;
        ObjectIDToRun1: Integer;
        ObjectIDToRun2: Integer;
    begin
        Initialize(false);

        AddRoleToList(TempAllProfile, ProfileID1);
        AddRoleToList(TempAllProfile, ProfileID2);
        AddRoleToList(TempAllProfile, ProfileID3);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] Two learn experience items for two different videos
        VideoUrl1 := GetNewLink();
        GuidedExperience.InsertVideo('Title', 'Short Title', 'Description', 10, VideoUrl1, VideoCategory::Uncategorized);

        VideoUrl2 := GetNewLink();
        GuidedExperience.InsertVideo('Title', 'Short Title', 'Description', 15, VideoUrl2, VideoCategory::Uncategorized);

        // [GIVEN] An assisted setup guided experience item 
        ObjectTypeToRun1 := ObjectType::Page;
        ObjectIDToRun1 := Page::"Assisted Setup";
        GuidedExperience.InsertAssistedSetup('Title', 'Short Title', 'Description', 9, ObjectTypeToRun1, ObjectIDToRun1,
AssistedSetupGroup::Uncategorized, '', VideoCategory::Uncategorized, '');

        // [GIVEN] A manual setup guided experience item
        ObjectTypeToRun2 := ObjectType::Codeunit;
        ObjectIDToRun2 := Codeunit::"Checklist Administration";
        GuidedExperience.InsertManualSetup('Title', 'Short Title', 'Description', 15, ObjectTypeToRun2,
ObjectIDToRun2, ManualSetupCategory::Uncategorized, '');

        // [GIVEN] Checklist items for the 4 guided experience items
        Checklist.Insert(GuidedExperienceType::Video, VideoUrl1, 1, TempAllProfile, false);
        Checklist.Insert(GuidedExperienceType::Video, VideoUrl2, 2, TempAllProfile, true);
        Checklist.Insert(GuidedExperienceType::"Assisted Setup", ObjectTypeToRun1, ObjectIDToRun1, 3, TempAllProfile, true);
        Checklist.Insert(GuidedExperienceType::"Manual Setup", ObjectTypeToRun2, ObjectIDToRun2, 4, TempAllProfile, false);

        // [THEN] The checklist item table should contain 4 entries
        Assert.AreEqual(4, ChecklistItem.Count, 'The checklist item table should contain 4 entries.');

        // [WHEN] Deleting the first video checklist item
        Checklist.Delete(GuidedExperienceType::Video, VideoUrl1);

        // [THEN] The checklist item table should contain 3 entries
        Assert.AreEqual(3, ChecklistItem.Count, 'The checklist item table should contain 3 entries.');

        // [THEN] The checklist item table should no longer contain the deleted video
        GuidedExperienceItem.SetRange("Guided Experience Type", "Guided Experience Type"::Video);
        GuidedExperienceItem.SetRange("Video Url", VideoUrl1);
        GuidedExperienceItem.FindFirst();

        ChecklistItem.SetRange(Code, GuidedExperienceItem.Code);
        Assert.AreEqual(0, ChecklistItem.Count, 'The checklist item table should no longer contain the deleted video.');

        // [THEN] The checklist item role table should not contain any entries associated with the deleted video
        ChecklistItemRole.SetRange(Code, GuidedExperienceItem.Code);
        Assert.AreEqual(0, ChecklistItemRole.Count,
'The checklist item role table should no longer contain any entries associated with the deleted video.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestShouldInitializeChecklistWithEvaluationCompany()
    var
        Checklist: Codeunit Checklist;
    begin
        // [GIVEN] The current company is an evaluation company
        SetCompanyEvaluationStatus(true);

        PermissionsMock.Set('Guided Exp Edit');

        // [WHEN] Calling ShouldInitializeChecklist
        // [THEN] The result is false
        Assert.IsFalse(Checklist.ShouldInitializeChecklist(true),
            'The checklist should not be initialized for evaluation companies.');
#if not CLEAN19
        Assert.IsFalse(Checklist.ShouldInitializeChecklist(), 'The checklist should not be initialized for evaluation companies.');
#endif
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestShouldInitializeChecklistWithEmptyChecklistSetupTable()
    var
        ChecklistSetup: Record "Checklist Setup";
        Checklist: Codeunit Checklist;
    begin
        // [GIVEN] The current company is NOT an evaluation company
        SetCompanyEvaluationStatus(false);

        // [GIVEN] The Checklist Setup table is empty
        ChecklistSetup.DeleteAll();

        PermissionsMock.Set('Guided Exp Edit');

        // [WHEN] Calling ShouldInitializeChecklist
        // [THEN] The result is true
        Assert.IsTrue(Checklist.ShouldInitializeChecklist(true),
            'The checklist should be initialized when the Checklist Setup table is empty.');
#if not CLEAN19
        Assert.IsTrue(Checklist.ShouldInitializeChecklist(), 'The checklist should be initialized when the Checklist Setup table is empty.');
#endif
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestShouldInitializeChecklistWithChecklistSetupNotDone()
    var
        ChecklistSetup: Record "Checklist Setup";
        Checklist: Codeunit Checklist;
    begin
        // [GIVEN] The current company is NOT an evaluation company
        SetCompanyEvaluationStatus(false);

        // [GIVEN] The Checklist Setup table has a record with "Is Setup Done" false
        ChecklistSetup.DeleteAll();
        ChecklistSetup."Is Setup Done" := false;
        ChecklistSetup.Insert();

        PermissionsMock.Set('Guided Exp Edit');

        // [WHEN] Calling ShouldInitializeChecklist
        // [THEN] The result is true
        Assert.IsTrue(Checklist.ShouldInitializeChecklist(true),
            'The checklist should be initialized when the setup is not done.');
#if not CLEAN19
        Assert.IsTrue(Checklist.ShouldInitializeChecklist(), 'The checklist should be initialized when the setup is not done.');
#endif
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestShouldInitializeChecklistWithChecklistSetupDone()
    var
        ChecklistSetup: Record "Checklist Setup";
        Checklist: Codeunit Checklist;
    begin
        // [GIVEN] The current company is NOT an evaluation company
        SetCompanyEvaluationStatus(false);

        // [GIVEN] The Checklist Setup table has a record with "Is Setup Done" false
        ChecklistSetup.DeleteAll();
        ChecklistSetup."Is Setup Done" := true;
        ChecklistSetup.Insert();

        PermissionsMock.Set('Guided Exp Edit');

        // [WHEN] Calling ShouldInitializeChecklist
        // [THEN] The result is true
        Assert.IsFalse(Checklist.ShouldInitializeChecklist(true),
            'The checklist should not be initialized when the setup is done.');
#if not CLEAN19
        Assert.IsFalse(Checklist.ShouldInitializeChecklist(), 'The checklist should not be initialized when the setup is done.');
#endif
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestShouldInitializeChecklistWithChecklistSetupNotInProgress()
    var
        ChecklistSetup: Record "Checklist Setup";
        Checklist: Codeunit Checklist;
    begin
        // [GIVEN] The Checklist Setup table has a record with the "Is Setup in Progress" flag set to true
        ChecklistSetup.DeleteAll();
        ChecklistSetup."Is Setup in Progress" := false;
        ChecklistSetup."Is Setup Done" := false;
        ChecklistSetup.Insert();

        PermissionsMock.Set('Guided Exp Edit');

        // [WHEN] Calling ShouldInitializeChecklist
        // [THEN] The result is true
        Assert.IsTrue(Checklist.ShouldInitializeChecklist(true),
            'The checklist should be initialized when the setup is not in progress.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestShouldInitializeChecklistWithChecklistSetupInProgressForLessThanAnHour()
    var
        ChecklistSetup: Record "Checklist Setup";
        Checklist: Codeunit Checklist;
    begin
        // [GIVEN] The Checklist Setup table has a record with the "Is Setup in Progress" flag set to true
        ChecklistSetup.DeleteAll();
        ChecklistSetup."Is Setup in Progress" := true;
        ChecklistSetup."DateTime when Setup Started" := CurrentDateTime();
        ChecklistSetup."Is Setup Done" := false;
        ChecklistSetup.Insert();

        PermissionsMock.Set('Guided Exp Edit');

        // [WHEN] Calling ShouldInitializeChecklist
        // [THEN] The result is false
        Assert.IsFalse(Checklist.ShouldInitializeChecklist(true),
            'The checklist should not be initialized when the setup has been in progress for less than an hour.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestShouldInitializeChecklistWithChecklistSetupInProgressForMoreThanAnHour()
    var
        ChecklistSetup: Record "Checklist Setup";
        Checklist: Codeunit Checklist;
        ChecklistImplementation: Codeunit "Checklist Implementation";
    begin
        // [GIVEN] The Checklist Setup table has a record with the "Is Setup in Progress" flag set to true
        ChecklistSetup.DeleteAll();
        ChecklistSetup."Is Setup in Progress" := true;
        ChecklistSetup."DateTime when Setup Started" := ChecklistImplementation.GetCurrentDateTimeInUTC() - 3601000;
        ChecklistSetup."Is Setup Done" := false;
        ChecklistSetup.Insert();

        PermissionsMock.Set('Guided Exp Edit');

        // [WHEN] Calling ShouldInitializeChecklist
        // [THEN] The result is true
        Assert.IsTrue(Checklist.ShouldInitializeChecklist(false),
            'The checklist should be initialized when the setup has been in progress for more than an hour.');
    end;


    [Test]
    [Scope('OnPrem')]
    procedure TestMarkChecklistSetupAsDoneWithEmptySetupTable()
    var
        ChecklistSetup: Record "Checklist Setup";
        Checklist: Codeunit Checklist;
        ChecklistFacadeTest: Codeunit "Checklist Facade Test";
    begin
        BindSubscription(ChecklistFacadeTest);

        // [GIVEN] The Checklist Setup table is empty
        ChecklistSetup.DeleteAll();

        PermissionsMock.Set('Guided Exp Edit');

        // [WHEN] Marking the checklist setup as done
        Checklist.MarkChecklistSetupAsDone();

        // [THEN] There is an entry in the Checklist Setup table
        Assert.AreEqual(1, ChecklistSetup.Count, 'The Checklist Setup table should contain an entry.');

        // [THEN] The checklist is marked as done
        ChecklistSetup.FindFirst();
        Assert.IsTrue(ChecklistSetup."Is Setup Done", 'The checklist setup should be done.');

        UnbindSubscription(ChecklistFacadeTest);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestMarkChecklistSetupAsDoneWithIsSetupDoneFalse()
    var
        ChecklistSetup: Record "Checklist Setup";
        Checklist: Codeunit Checklist;
        ChecklistFacadeTest: Codeunit "Checklist Facade Test";
    begin
        BindSubscription(ChecklistFacadeTest);

        // [GIVEN] The Checklist Setup table contains an entry with "Is Setup Done" marked as false
        ChecklistSetup.DeleteAll();

        PermissionsMock.Set('Guided Exp Edit');

        ChecklistSetup."Is Setup Done" := false;
        ChecklistSetup.Insert();

        // [WHEN] Marking the checklist setup as done
        Checklist.MarkChecklistSetupAsDone();

        // [THEN] There is an entry in the Checklist Setup table
        ChecklistSetup.Reset();
        Assert.AreEqual(1, ChecklistSetup.Count, 'The Checklist Setup table should contain an entry.');

        // [THEN] The checklist is marked as done
        Assert.IsTrue(ChecklistSetup.Get(true), 'The checklist setup should be done.');

        UnbindSubscription(ChecklistFacadeTest);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestMarkChecklistSetupAsDoneWithIsSetupDoneTrue()
    var
        ChecklistSetup: Record "Checklist Setup";
        Checklist: Codeunit Checklist;
        ChecklistFacadeTest: Codeunit "Checklist Facade Test";
    begin
        BindSubscription(ChecklistFacadeTest);

        // [GIVEN] The Checklist Setup table contains an entry with "Is Setup Done" marked as true
        ChecklistSetup.DeleteAll();

        PermissionsMock.Set('Guided Exp Edit');

        ChecklistSetup."Is Setup Done" := true;
        ChecklistSetup.Insert();

        // [WHEN] Marking the checklist setup as done
        Checklist.MarkChecklistSetupAsDone();

        // [THEN] There is an entry in the Checklist Setup table
        Assert.AreEqual(1, ChecklistSetup.Count, 'The Checklist Setup table should contain an entry.');

        // [THEN] The checklist is marked as done
        ChecklistSetup.FindFirst();
        Assert.IsTrue(ChecklistSetup."Is Setup Done", 'The checklist setup should be done.');

        UnbindSubscription(ChecklistFacadeTest);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInitializeGuidedExperienceItems()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        Checklist: Codeunit Checklist;
        ChecklistFacadeTest: Codeunit "Checklist Facade Test";
    begin
        BindSubscription(ChecklistFacadeTest);

        // [GIVEN] The Guided Experience table is empty
        GuidedExperienceItem.DeleteAll();

        PermissionsMock.Set('Guided Exp Edit');

        // [WHEN] Initializing guided experience items
        Checklist.InitializeGuidedExperienceItems();

        // [THEN] The Guided Experience Item table is not empty anymore
        Assert.AreNotEqual(0, GuidedExperienceItem.Count, 'The Guided Experience Item table should not be empty.');

        // [THEN] The Guided Experience Item table should contain a link item for Microsoft Learn
        GuidedExperienceItem.SetRange("Guided Experience Type", GuidedExperienceItem."Guided Experience Type"::Learn);
        GuidedExperienceItem.SetRange(Link, 'https://go.microsoft.com/fwlink/?linkid=2152979');
        Assert.AreEqual(1, GuidedExperienceItem.Count(), 'The Guided Experience Item table should contain a link item for Microsoft Learn.');

        UnbindSubscription(ChecklistFacadeTest);
    end;

    local procedure Initialize(ShouldInsertProfiles: Boolean)
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        ChecklistItem: Record "Checklist Item";
        ChecklistItemRole: Record "Checklist Item Role";
        ChecklistItemUser: Record "Checklist Item User";
        SpotlightTourText: Record "Spotlight Tour Text";
    begin
        if ShouldInsertProfiles then begin
            InsertProfile(ProfileID1);
            InsertProfile(ProfileID2);
            InsertProfile(ProfileID3);
            InsertProfile(ProfileID4);
        end;

        GuidedExperienceItem.DeleteAll();
        ChecklistItem.DeleteAll();
        ChecklistItemRole.DeleteAll();
        ChecklistItemUser.DeleteAll();
        SpotlightTourText.DeleteAll();
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

    local procedure AddUserToList(var TempUser: Record User temporary; UserSecurityId: Guid)
    var
        User: Record User;
    begin
        User.SetRange("User Security ID", UserSecurityId);
        if User.FindFirst() then begin
            TempUser.TransferFields(User);
            TempUser.Insert();
        end;
    end;

    local procedure VerifyChecklistItemFields(ChecklistItem: Record "Checklist Item"; Code: Code[300]; CompletionRequirements: Enum "Checklist Completion Requirements"; OrderID: Integer)
    begin
        Assert.AreEqual(Code, ChecklistItem.Code, 'The Code field is incorrect.');
        Assert.AreEqual(CompletionRequirements, ChecklistItem."Completion Requirements", 'The Completion Requirements field is incorrect.');
        Assert.AreEqual(OrderID, ChecklistItem."Order ID", 'The Order ID field is incorrect.');
    end;

    local procedure VerifyChecklistItemRoleFields(ChecklistItemRole: Record "Checklist Item Role"; Code: Code[300]; RoleID: Code[30])
    begin
        Assert.AreEqual(Code, ChecklistItemRole.Code, 'The Code field is incorrect.');
        Assert.AreEqual(RoleID, ChecklistItemRole."Role ID", 'The Role ID field is incorrect.');
    end;

    local procedure VerifyChecklistItemUserFields(ChecklistItemUser: Record "Checklist Item User"; Code: Code[300]; UserName: Code[50]; ChecklistItemStatus: Enum "Checklist Item Status"; IsVisible: Boolean;
                                                                                                                                                                 AssignedToUser: Boolean)
    begin
        Assert.AreEqual(Code, ChecklistItemUser.Code, 'The Code field is incorrect.');
        Assert.AreEqual(UserName, ChecklistItemUser."User ID", 'The User ID field is incorrect.');
        Assert.AreEqual(ChecklistItemStatus, ChecklistItemUser."Checklist Item Status", 'The Checklist Item Status field is incorrect.');
        Assert.AreEqual(IsVisible, ChecklistItemUser."Is Visible", 'The Is Visible field is incorrect.');
        Assert.AreEqual(AssignedToUser, ChecklistItemUser."Assigned to User", 'The Assigned to User field is incorrect.');
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

    local procedure InsertUser(var UserSecurityID: Guid; var UserName: Code[50])
    var
        User: Record User;
    begin
        UserSecurityID := CreateGuid();
        UserName := CopyStr(Any.AlphanumericText(50), 1, MaxStrLen(UserName));

        User."User Security ID" := UserSecurityID;
        User."User Name" := UserName;
        User.Insert();
    end;

    local procedure GetNewLink(): Text[250]
    begin
        exit(CopyStr(Any.AlphanumericText(250), 1, 250));
    end;

    local procedure SetCompanyEvaluationStatus(IsEvaluationCompany: Boolean)
    var
        Company: Record Company;
    begin
        Company.SetRange(Name, CompanyName());
        Company.FindFirst();

        Company."Evaluation Company" := IsEvaluationCompany;
        Company.Modify();
    end;

    local procedure GetSpotlightDictionary(var SpotlightDictionary: Dictionary of [Enum "Spotlight Tour Text", Text]; var Step1Title: Text; var Step1Text: Text; var Step2Title: Text; var Step2Text: Text)
    var
        SpotlightTourText: Enum "Spotlight Tour Text";
    begin
        Step1Title := Any.AlphanumericText(250);
        Step1Text := Any.AlphanumericText(250);
        Step2Title := Any.AlphanumericText(250);
        Step2Text := Any.AlphanumericText(250);

        SpotlightDictionary.Add(SpotlightTourText::Step1Title, Step1Title);
        SpotlightDictionary.Add(SpotlightTourText::Step1Text, Step1Text);

        SpotlightDictionary.Add(SpotlightTourText::Step2Title, Step2Title);
        SpotlightDictionary.Add(SpotlightTourText::Step2Text, Step2Text);
    end;
}