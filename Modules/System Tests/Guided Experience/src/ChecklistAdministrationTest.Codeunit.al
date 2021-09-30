// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132602 "Checklist Administration Test"
{
    Subtype = Test;
    Permissions = tabledata "Guided Experience Item" = rimd,
                    tabledata "Checklist Item" = rimd,
                    tabledata "Checklist Item Role" = rimd,
                    tabledata "Checklist Item User" = rimd,
                    tabledata "All Profile" = ri,
                    tabledata User = ri,
                    tabledata "User Personalization" = rm;

    var
        Any: Codeunit Any;
        Assert: Codeunit "Library Assert";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        PermissionsMock: Codeunit "Permissions Mock";
        ProfileID1: Code[30];
        ProfileID2: Code[30];
        ProfileID3: Code[30];

    trigger OnRun()
    begin
    end;

    // [Test]
    [HandlerFunctions('ChecklistPageHandler')]
    [Scope('OnPrem')]
    procedure TestChecklistPage()
    var
        TempAllProfile: Record "All Profile" temporary;
        ChecklistAPI: Codeunit Checklist;
        Checklist: Page Checklist;
        GuidedExperienceType: Enum "Guided Experience Type";
        ChecklistCompletionRequirements: Enum "Checklist Completion Requirements";
        SpotlightTourType: Enum "Spotlight Tour Type";
        Title1: Text[2048];
        ExpectedDuration1: Integer;
        OrderID1: Integer;
        ObjectType1: ObjectType;
        ObjectID1: Integer;
        Title2: Text[2048];
        ExpectedDuration2: Integer;
        OrderID2: Integer;
        ObjectType2: ObjectType;
        ObjectID2: Integer;
        Link: Text[250];
    begin
        Initialize(true);

        // [GIVEN] A list of profiles
        AddRoleToList(TempAllProfile, ProfileID1);
        AddRoleToList(TempAllProfile, ProfileID2);
        AddRoleToList(TempAllProfile, ProfileID3);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] 8 checklist items for different types of guided experience items
        ObjectType1 := ObjectType::Page;
        ObjectID1 := Page::"Checklist Item Roles";
        InsertAssistedSetup(Title1, ExpectedDuration1, ObjectType1, ObjectID1, OrderID1);
        OrderID1 := 0;
        ChecklistAPI.Insert(GuidedExperienceType::"Assisted Setup", ObjectType1, ObjectID1, OrderID1, TempAllProfile, true);

        ObjectType2 := ObjectType::Codeunit;
        ObjectID2 := Codeunit::"Checklist Banner";
        InsertManualSetup(Title2, ExpectedDuration2, ObjectType2, ObjectID2, OrderID2);
        ChecklistAPI.Insert(GuidedExperienceType::"Manual Setup", ObjectType2, ObjectID2, OrderID2, TempAllProfile, true);

        ObjectType2 := ObjectType::Page;
        ObjectID2 := Page::"Checklist Administration";
        InsertAssistedSetup(Title2, ExpectedDuration2, ObjectType2, ObjectID2, OrderID2);
        ChecklistAPI.Insert(GuidedExperienceType::"Assisted Setup", ObjectType2, ObjectID2, OrderID2, TempAllProfile, true);

        ObjectType2 := ObjectType::Report;
        ObjectID2 := Report::"Checklist Test Report";
        InsertApplicationFeature(Title2, ExpectedDuration2, ObjectType2, ObjectID2, OrderID2);
        ChecklistAPI.Insert(GuidedExperienceType::"Application Feature", ObjectType2, ObjectID2, OrderID2, TempAllProfile, true);

        InsertLink(GuidedExperienceType::Learn, Title2, ExpectedDuration2, Link, OrderID2);
        ChecklistAPI.Insert(GuidedExperienceType::Learn, Link, OrderID2, TempAllProfile, true);

        ObjectType2 := ObjectType::Page;
        ObjectID2 := Page::"Assisted Setup Wizard";
        InsertTour(Title2, ExpectedDuration2, ObjectID2, OrderID2);
        ChecklistAPI.Insert(GuidedExperienceType::Tour, ObjectType2, ObjectID2, OrderID2, TempAllProfile, true);

        InsertLink(GuidedExperienceType::Video, Title2, ExpectedDuration2, Link, OrderID2);
        ChecklistAPI.Insert(GuidedExperienceType::Video, Link, OrderID2, TempAllProfile, true);

        ObjectID2 := Page::"Checklist Banner Container";
        InsertSpotlightTour(SpotlightTourType::"Share to Teams", Title2, ExpectedDuration2, ObjectID2, OrderID2);
        ChecklistAPI.Insert(ObjectID2, SpotlightTourType::"Share to Teams", OrderID2, TempAllProfile, true);

        // [GIVEN] The values of the fields of the first checklist item and the total number of 
        // checklist items is enqueued in the variable storage
        LibraryVariableStorage.Enqueue(Title1);
        LibraryVariableStorage.Enqueue(ExpectedDuration1);
        LibraryVariableStorage.Enqueue(OrderID1);
        LibraryVariableStorage.Enqueue(ChecklistCompletionRequirements::Everyone);
        LibraryVariableStorage.Enqueue(8);

        // [WHEN] Opening the checklist administration page
        Checklist.Run();

        // [THEN] The verification that the items are listed on the page and are in the correct order 
        // is done in the page handler
    end;

    // [Test]
    [HandlerFunctions('ChecklistPageHandlerForSingleRole')]
    [Scope('OnPrem')]
    procedure TestChecklistPageAssignedToWithSingleRole()
    var
        TempAllProfile: Record "All Profile" temporary;
        ChecklistAPI: Codeunit Checklist;
        Checklist: Page Checklist;
        GuidedExperienceType: Enum "Guided Experience Type";
        Title: Text[2048];
        ExpectedDuration: Integer;
        OrderID: Integer;
        ObjectType: ObjectType;
        ObjectID: Integer;
    begin
        Initialize(false);

        // [GIVEN] A list with a single profile
        AddRoleToList(TempAllProfile, ProfileID1);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A checklist item
        ObjectType := ObjectType::Page;
        ObjectID := Page::"Checklist Item Roles";
        InsertAssistedSetup(Title, ExpectedDuration, ObjectType, ObjectID, OrderID);
        OrderID := 0;
        ChecklistAPI.Insert(GuidedExperienceType::"Assisted Setup", ObjectType, ObjectID, OrderID, TempAllProfile, true);

        // [GIVEN] The profile ID is enqueued in the variable storage
        LibraryVariableStorage.Enqueue(ProfileID1);

        // [WHEN] Opening the checklist administration page
        Checklist.Run();

        // [THEN] The verification that the profile name is listed in the 'Assigned To' field
        // is done in the page handler
    end;

    // [Test]
    [HandlerFunctions('ChecklistPageHandlerForMultipleRolesOrUsers')]
    [Scope('OnPrem')]
    procedure TestChecklistPageAssignedToWithMultipleRoles()
    var
        TempAllProfile: Record "All Profile" temporary;
        ChecklistAPI: Codeunit Checklist;
        Checklist: Page Checklist;
        GuidedExperienceType: Enum "Guided Experience Type";
        Title: Text[2048];
        ExpectedDuration: Integer;
        OrderID: Integer;
        ObjectType: ObjectType;
        ObjectID: Integer;
    begin
        Initialize(false);

        // [GIVEN] A list of profiles
        AddRoleToList(TempAllProfile, ProfileID1);
        AddRoleToList(TempAllProfile, ProfileID2);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A checklist item
        ObjectType := ObjectType::Page;
        ObjectID := Page::"Checklist Item Roles";
        InsertAssistedSetup(Title, ExpectedDuration, ObjectType, ObjectID, OrderID);
        OrderID := 0;
        ChecklistAPI.Insert(GuidedExperienceType::"Assisted Setup", ObjectType, ObjectID, OrderID, TempAllProfile, true);

        // [GIVEN] The correct value of the "Assigned To" field is enqueued in the variable storage
        LibraryVariableStorage.Enqueue('Multiple');

        // [WHEN] Opening the checklist administration page
        Checklist.Run();

        // [THEN] The verification that the 'Assigned To' field has the correct value 
        // is done in the page handler
    end;

    [Test]
    [HandlerFunctions('ChecklistPageHandlerForSingleUser')]
    [Scope('OnPrem')]
    procedure TestChecklistPageAssignedToWithSingleUser()
    var
        TempUser: Record User temporary;
        ChecklistAPI: Codeunit Checklist;
        Checklist: Page Checklist;
        GuidedExperienceType: Enum "Guided Experience Type";
        UserName: Code[50];
        UserSecurityId: Guid;
        Title: Text[2048];
        ExpectedDuration: Integer;
        OrderID: Integer;
        ObjectType: ObjectType;
        ObjectID: Integer;
    begin
        Initialize(false);

        // [GIVEN] A list with a single user
        AddUserToList(TempUser, UserSecurityId, UserName);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A checklist item
        ObjectType := ObjectType::Page;
        ObjectID := Page::"Checklist Item Roles";
        InsertAssistedSetup(Title, ExpectedDuration, ObjectType, ObjectID, OrderID);
        OrderID := 0;
        ChecklistAPI.Insert(GuidedExperienceType::"Assisted Setup", ObjectType, ObjectID, OrderID, TempUser);

        // [GIVEN] The user name is enqueued in the variable storage
        LibraryVariableStorage.Enqueue(UserName);

        // [WHEN] Opening the checklist administration page
        Checklist.Run();

        // [THEN] The verification that the username is listed in the 'Assigned To' field 
        // is done in the page handler
    end;

    [Test]
    [HandlerFunctions('ChecklistPageHandlerForMultipleRolesOrUsers')]
    [Scope('OnPrem')]
    procedure TestChecklistPageAssignedToWithMultipleUsers()
    var
        TempUser: Record User temporary;
        ChecklistAPI: Codeunit Checklist;
        Checklist: Page Checklist;
        GuidedExperienceType: Enum "Guided Experience Type";
        UserSecurityId1: Guid;
        UserName1: Code[50];
        UserSecurityId2: Guid;
        UserName2: Code[50];
        Title: Text[2048];
        ExpectedDuration: Integer;
        OrderID: Integer;
        ObjectType: ObjectType;
        ObjectID: Integer;
    begin
        Initialize(false);

        // [GIVEN] A list with multiple users
        AddUserToList(TempUser, UserSecurityId1, UserName1);
        AddUserToList(TempUser, UserSecurityId2, UserName2);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A checklist item
        ObjectType := ObjectType::Page;
        ObjectID := Page::"Checklist Item Roles";
        InsertAssistedSetup(Title, ExpectedDuration, ObjectType, ObjectID, OrderID);
        OrderID := 0;
        ChecklistAPI.Insert(GuidedExperienceType::"Assisted Setup", ObjectType, ObjectID, OrderID, TempUser);

        // [GIVEN] The correct value of the "Assigned To" field is enqueued in the variable storage
        LibraryVariableStorage.Enqueue('Multiple');

        // [WHEN] Opening the checklist administration page
        Checklist.Run();

        // [THEN] The verification that the 'Assigned To' field is correct 
        // is done in the page handler
    end;

    // [Test]
    [HandlerFunctions('CreateChecklistItemPageHandler,ChecklistAdministrationPageHandlerForAssistedSetup,GuidedExperienceItemListModalPageHandler')]
    [Scope('OnPrem')]
    procedure TestCreateAssistedSetupChecklistItem()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        ChecklistItem: Record "Checklist Item";
        ChecklistItemRole: Record "Checklist Item Role";
        Checklist: Page Checklist;
        ChecklistCompletionRequirements: Enum "Checklist Completion Requirements";
        GuidedExperienceType: Enum "Guided Experience Type";
        SpotightTourType: Enum "Spotlight Tour Type";
        Title: Text[2048];
        ExpectedDuration: Integer;
        OrderID: Integer;
        ObjectType: ObjectType;
        ObjectID: Integer;
    begin
        Initialize(false);

        // [GIVEN] An assisted setup guided expericence item 
        ObjectType := ObjectType::Page;
        ObjectID := Page::"Checklist Item Roles";
        InsertAssistedSetup(Title, ExpectedDuration, ObjectType, ObjectID, OrderID);

        GetGuidedExperienceItem(GuidedExperienceItem, GuidedExperienceType::"Assisted Setup", ObjectType, ObjectID, '', '', SpotightTourType::None);

        // [GIVEN] The title of the assisted setup is enqueued in the variable storage
        LibraryVariableStorage.Enqueue(Title);

        // [GIVEN] Two profiles for which the IDs are enqueued in the variable storage
        LibraryVariableStorage.Enqueue(ProfileID1);
        LibraryVariableStorage.Enqueue(ProfileID2);

        // [GIVEN] The checklist page is open and from there the "Create New" action is 
        // invoked - see the checklist page handler
        Checklist.Run();

        // [WHEN] The title lookup is opened for guided experience items of type assisted 
        // setup - see the checklist administration page handler
        // [THEN] The newly created assisted setup is present on the lookup page
        Assert.IsTrue(LibraryVariableStorage.DequeueBoolean(), 'The assisted setup is not displayed on the page.');

        // [WHEN] The assisted setup is selected in the lookup - see page handler
        // [THEN] The fields are populated correctly on the checklist administration page 
        VerifyFieldsOnPage(Title, ExpectedDuration, 'Page Checklist Item Roles', '', '', SpotightTourType::None, ChecklistCompletionRequirements::Anyone);

        // [THEN] A new checklist item is created for the selected guided experience item
        Assert.IsTrue(ChecklistItem.Get(GuidedExperienceItem.Code), 'A new checklist item should have been created.');

        // [WHEN] Two profiles are inserted in the Roles part of the Checklist Administration page
        // see the checklist administration page handler
        // [THEN] Two new checklist item roles are created for the profiles 
        Assert.IsTrue(ChecklistItemRole.Get(GuidedExperienceItem.Code, ProfileID1),
            'A checklist item role should have been inserted for the first profile.');
        Assert.IsTrue(ChecklistItemRole.Get(GuidedExperienceItem.Code, ProfileID2),
            'A checklist item role should have been inserted for the second profile.');
    end;

    [Test]
    [HandlerFunctions('CreateChecklistItemPageHandler,ChecklistAdministrationPageHandlerForManualSetup,GuidedExperienceItemListModalPageHandler')]
    [Scope('OnPrem')]
    procedure TestCreateManualSetupChecklistItem()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        ChecklistItem: Record "Checklist Item";
        Checklist: Page Checklist;
        ChecklistCompletionRequirements: Enum "Checklist Completion Requirements";
        GuidedExperienceType: Enum "Guided Experience Type";
        SpotightTourType: Enum "Spotlight Tour Type";
        Title: Text[2048];
        UserSecurityId1: Guid;
        UserName1: Code[50];
        UserSecurityId2: Guid;
        UserName2: Code[50];
        ExpectedDuration: Integer;
        OrderID: Integer;
        ObjectType: ObjectType;
        ObjectID: Integer;
    begin
        Initialize(false);

        InsertUser(UserSecurityId1, UserName1);
        InsertUser(UserSecurityId2, UserName2);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A manual setup guided expericence item 
        ObjectType := ObjectType::Page;
        ObjectID := Page::"Checklist Item Users";
        InsertManualSetup(Title, ExpectedDuration, ObjectType, ObjectID, OrderID);

        GetGuidedExperienceItem(GuidedExperienceItem, GuidedExperienceType::"Manual Setup", ObjectType, ObjectID, '', '', SpotightTourType::None);

        // [GIVEN] The title of the manual setup is enqueued in the variable storage
        LibraryVariableStorage.Enqueue(Title);

        // [GIVEN] Two users whose usernames are enqueued in the variable storage
        LibraryVariableStorage.Enqueue(UserName1);
        LibraryVariableStorage.Enqueue(UserName2);

        // [GIVEN] The checklist page is open and from there the "Create New" action is 
        // invoked - see the checklist page handler
        Checklist.Run();

        // [WHEN] The title lookup is opened for guided experience items of type manual 
        // setup - see the checklist administration page handler
        // [THEN] The newly created manual setup is present on the lookup page
        Assert.IsTrue(LibraryVariableStorage.DequeueBoolean(), 'The manual setup is not displayed on the page.');

        // [WHEN] The manual setup is selected in the lookup - see page handler
        // [THEN] The fields are populated correctly on the checklist administration page 
        VerifyFieldsOnPage(Title, ExpectedDuration, 'Page Checklist Users', '', '', SpotightTourType::None, ChecklistCompletionRequirements::Anyone);

        // [THEN] A new checklist item is created for the selected guided experience item
        Assert.IsTrue(ChecklistItem.Get(GuidedExperienceItem.Code), 'A new checklist item should have been created.');

        // [WHEN] Two users are inserted in the Users part of the Checklist Administration page
        // see the checklist administration page handler
        // [THEN] Two new checklist item users are created for the users 
        VerifyChecklistItemUser(GuidedExperienceItem.Code, UserName1);
        VerifyChecklistItemUser(GuidedExperienceItem.Code, UserName2);
    end;

    [Test]
    [HandlerFunctions('CreateChecklistItemPageHandler,ChecklistAdministrationPageHandlerForLearnLink,GuidedExperienceItemListModalPageHandler')]
    [Scope('OnPrem')]
    procedure TestCreateLearnChecklistItem()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        ChecklistItem: Record "Checklist Item";
        Checklist: Page Checklist;
        ChecklistCompletionRequirements: Enum "Checklist Completion Requirements";
        GuidedExperienceType: Enum "Guided Experience Type";
        SpotightTourType: Enum "Spotlight Tour Type";
        Title: Text[2048];
        UserSecurityId1: Guid;
        UserName1: Code[50];
        UserSecurityId2: Guid;
        UserName2: Code[50];
        ExpectedDuration: Integer;
        OrderID: Integer;
        LinkToRun: Text[250];
    begin
        Initialize(false);

        InsertUser(UserSecurityId1, UserName1);
        InsertUser(UserSecurityId2, UserName2);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A learn guided expericence item 
        InsertLink(GuidedExperienceType::Learn, Title, ExpectedDuration, LinkToRun, OrderID);

        GetGuidedExperienceItem(GuidedExperienceItem, GuidedExperienceType::Learn, ObjectType::Query, 0, LinkToRun, '', SpotightTourType::None);

        // [GIVEN] The title of the learn link is enqueued in the variable storage
        LibraryVariableStorage.Enqueue(Title);

        // [GIVEN] Two users whose usernames are enqueued in the variable storage
        LibraryVariableStorage.Enqueue(UserName1);
        LibraryVariableStorage.Enqueue(UserName2);

        // [GIVEN] The checklist page is open and from there the "Create New" action is 
        // invoked - see the checklist page handler
        Checklist.Run();

        // [WHEN] The title lookup is opened for guided experience items of type learn 
        // link - see the checklist administration page handler
        // [THEN] The newly created learn link is present on the lookup page
        Assert.IsTrue(LibraryVariableStorage.DequeueBoolean(), 'The learn link is not displayed on the page.');

        // [WHEN] The learn link is selected in the lookup - see page handler
        // [THEN] The fields are populated correctly on the checklist administration page 
        VerifyFieldsOnPage(Title, ExpectedDuration, '', LinkToRun, '', SpotightTourType::None, ChecklistCompletionRequirements::Anyone);

        // [THEN] A new checklist item is created for the selected guided experience item
        Assert.IsTrue(ChecklistItem.Get(GuidedExperienceItem.Code), 'A new checklist item should have been created.');

        // [WHEN] Two users are inserted in the Users part of the Checklist Administration page
        // see the checklist administration page handler
        // [THEN] Two new checklist item users are created for the users 
        VerifyChecklistItemUser(GuidedExperienceItem.Code, UserName1);
        VerifyChecklistItemUser(GuidedExperienceItem.Code, UserName2);
    end;

    [Test]
    [HandlerFunctions('CreateChecklistItemPageHandler,ChecklistAdministrationPageHandlerForApplicationFeature,GuidedExperienceItemListModalPageHandler')]
    [Scope('OnPrem')]
    procedure TestCreateApplicationFeatureChecklistItem()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        ChecklistItem: Record "Checklist Item";
        Checklist: Page Checklist;
        ChecklistCompletionRequirements: Enum "Checklist Completion Requirements";
        GuidedExperienceType: Enum "Guided Experience Type";
        SpotightTourType: Enum "Spotlight Tour Type";
        Title: Text[2048];
        UserSecurityId1: Guid;
        UserName1: Code[50];
        UserSecurityId2: Guid;
        UserName2: Code[50];
        ExpectedDuration: Integer;
        OrderID: Integer;
        ObjectType: ObjectType;
        ObjectID: Integer;
    begin
        Initialize(false);

        InsertUser(UserSecurityId1, UserName1);
        InsertUser(UserSecurityId2, UserName2);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] An application feature guided expericence item 
        ObjectType := ObjectType::Page;
        ObjectID := Page::"Checklist Item Users";
        InsertApplicationFeature(Title, ExpectedDuration, ObjectType, ObjectID, OrderID);

        GetGuidedExperienceItem(GuidedExperienceItem, GuidedExperienceType::"Application Feature", ObjectType, ObjectID, '', '', SpotightTourType::None);

        // [GIVEN] The title of the application feature is enqueued in the variable storage
        LibraryVariableStorage.Enqueue(Title);

        // [GIVEN] Two users whose usernames are enqueued in the variable storage
        LibraryVariableStorage.Enqueue(UserName1);
        LibraryVariableStorage.Enqueue(UserName2);

        // [GIVEN] The checklist page is open and from there the "Create New" action is 
        // invoked - see the checklist page handler
        Checklist.Run();

        // [WHEN] The title lookup is opened for guided experience items of 
        // type application feature - see the checklist administration page handler
        // [THEN] The newly created application feature is present on the lookup page
        Assert.IsTrue(LibraryVariableStorage.DequeueBoolean(), 'The application feature is not displayed on the page.');

        // [WHEN] The application feature is selected in the lookup - see page handler
        // [THEN] The fields are populated correctly on the checklist administration page 
        VerifyFieldsOnPage(Title, ExpectedDuration, 'Page Checklist Users', '', '', SpotightTourType::None, ChecklistCompletionRequirements::Anyone);

        // [THEN] A new checklist item is created for the selected guided experience item
        Assert.IsTrue(ChecklistItem.Get(GuidedExperienceItem.Code), 'A new checklist item should have been created.');

        // [WHEN] Two users are inserted in the Users part of the Checklist Administration page
        // see the checklist administration page handler
        // [THEN] Two new checklist item users are created for the users 
        VerifyChecklistItemUser(GuidedExperienceItem.Code, UserName1);
        VerifyChecklistItemUser(GuidedExperienceItem.Code, UserName2);
    end;

    [Test]
    [HandlerFunctions('CreateChecklistItemPageHandler,ChecklistAdministrationPageHandlerForVideoUrl,GuidedExperienceItemListModalPageHandler')]
    [Scope('OnPrem')]
    procedure TestCreateVideoChecklistItem()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        ChecklistItem: Record "Checklist Item";
        Checklist: Page Checklist;
        ChecklistCompletionRequirements: Enum "Checklist Completion Requirements";
        GuidedExperienceType: Enum "Guided Experience Type";
        SpotightTourType: Enum "Spotlight Tour Type";
        Title: Text[2048];
        UserSecurityId1: Guid;
        UserName1: Code[50];
        UserSecurityId2: Guid;
        UserName2: Code[50];
        ExpectedDuration: Integer;
        OrderID: Integer;
        VideoUrl: Text[250];
    begin
        Initialize(false);

        InsertUser(UserSecurityId1, UserName1);
        InsertUser(UserSecurityId2, UserName2);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A video guided expericence item 
        InsertLink(GuidedExperienceType::Video, Title, ExpectedDuration, VideoUrl, OrderID);

        GetGuidedExperienceItem(GuidedExperienceItem, GuidedExperienceType::Video, ObjectType::Query, 0, '', VideoUrl, SpotightTourType::None);

        // [GIVEN] The title of the video item is enqueued in the variable storage
        LibraryVariableStorage.Enqueue(Title);

        // [GIVEN] Two users whose usernames are enqueued in the variable storage
        LibraryVariableStorage.Enqueue(UserName1);
        LibraryVariableStorage.Enqueue(UserName2);

        // [GIVEN] The checklist page is open and from there the "Create New" action is 
        // invoked - see the checklist page handler
        Checklist.Run();

        // [WHEN] The title lookup is opened for guided experience items of type video; 
        // see the checklist administration page handler
        // [THEN] The newly created video item is present on the lookup page
        Assert.IsTrue(LibraryVariableStorage.DequeueBoolean(), 'The video item is not displayed on the page.');

        // [WHEN] The video item is selected in the lookup - see page handler
        // [THEN] The fields are populated correctly on the checklist administration page 
        VerifyFieldsOnPage(Title, ExpectedDuration, '', '', VideoUrl, SpotightTourType::None, ChecklistCompletionRequirements::Anyone);

        // [THEN] A new checklist item is created for the selected guided experience item
        Assert.IsTrue(ChecklistItem.Get(GuidedExperienceItem.Code), 'A new checklist item should have been created.');

        // [WHEN] Two users are inserted in the Users part of the Checklist Administration page
        // see the checklist administration page handler
        // [THEN] Two new checklist item users are created for the users 
        VerifyChecklistItemUser(GuidedExperienceItem.Code, UserName1);
        VerifyChecklistItemUser(GuidedExperienceItem.Code, UserName2);
    end;

    // [Test]
    [HandlerFunctions('CreateChecklistItemPageHandler,ChecklistAdministrationPageHandlerForTour,GuidedExperienceItemListModalPageHandler')]
    [Scope('OnPrem')]
    procedure TestCreateTourChecklistItem()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        ChecklistItem: Record "Checklist Item";
        Checklist: Page Checklist;
        ChecklistCompletionRequirements: Enum "Checklist Completion Requirements";
        GuidedExperienceType: Enum "Guided Experience Type";
        SpotightTourType: Enum "Spotlight Tour Type";
        Title: Text[2048];
        UserSecurityId1: Guid;
        UserName1: Code[50];
        UserSecurityId2: Guid;
        UserName2: Code[50];
        ExpectedDuration: Integer;
        OrderID: Integer;
        ObjectType: ObjectType;
        ObjectID: Integer;
    begin
        Initialize(false);

        InsertUser(UserSecurityId1, UserName1);
        InsertUser(UserSecurityId2, UserName2);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A tour guided expericence item 
        ObjectType := ObjectType::Page;
        ObjectID := Page::"Checklist Item Users";
        InsertTour(Title, ExpectedDuration, ObjectID, OrderID);

        GetGuidedExperienceItem(GuidedExperienceItem, GuidedExperienceType::Tour, ObjectType, ObjectID, '', '', SpotightTourType::None);

        // [GIVEN] The title of the tour is enqueued in the variable storage
        LibraryVariableStorage.Enqueue(Title);

        // [GIVEN] Two users whose usernames are enqueued in the variable storage
        LibraryVariableStorage.Enqueue(UserName1);
        LibraryVariableStorage.Enqueue(UserName2);

        // [GIVEN] The checklist page is open and from there the "Create New" action is 
        // invoked - see the checklist page handler
        Checklist.Run();

        // [WHEN] The title lookup is opened for guided experience items of 
        // type tour - see the checklist administration page handler
        // [THEN] The newly created tour is present on the lookup page
        Assert.IsTrue(LibraryVariableStorage.DequeueBoolean(), 'The tour is not displayed on the page.');

        // [WHEN] The tour is selected in the lookup - see page handler
        // [THEN] The fields are populated correctly on the checklist administration page 
        VerifyFieldsOnPage(Title, ExpectedDuration, 'Page Checklist Users', '', '', SpotightTourType::None, ChecklistCompletionRequirements::Anyone);

        // [THEN] A new checklist item is created for the selected guided experience item
        Assert.IsTrue(ChecklistItem.Get(GuidedExperienceItem.Code), 'A new checklist item should have been created.');

        // [WHEN] Two users are inserted in the Users part of the Checklist Administration page
        // see the checklist administration page handler
        // [THEN] Two new checklist item users are created for the users 
        VerifyChecklistItemUser(GuidedExperienceItem.Code, UserName1);
        VerifyChecklistItemUser(GuidedExperienceItem.Code, UserName2);
    end;

    [Test]
    [HandlerFunctions('CreateChecklistItemPageHandler,ChecklistAdministrationPageHandlerForSpotlightTour,GuidedExperienceItemListModalPageHandler')]
    [Scope('OnPrem')]
    procedure TestCreateSpotlightTourChecklistItem()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        ChecklistItem: Record "Checklist Item";
        Checklist: Page Checklist;
        ChecklistCompletionRequirements: Enum "Checklist Completion Requirements";
        GuidedExperienceType: Enum "Guided Experience Type";
        SpotightTourType: Enum "Spotlight Tour Type";
        Title: Text[2048];
        UserSecurityId1: Guid;
        UserName1: Code[50];
        UserSecurityId2: Guid;
        UserName2: Code[50];
        ExpectedDuration: Integer;
        OrderID: Integer;
        ObjectType: ObjectType;
        ObjectID: Integer;
    begin
        Initialize(false);

        InsertUser(UserSecurityId1, UserName1);
        InsertUser(UserSecurityId2, UserName2);

        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] A spotlight tour guided expericence item 
        ObjectType := ObjectType::Page;
        ObjectID := Page::"Checklist Item Users";
        SpotightTourType := SpotightTourType::"Open in Excel";
        InsertSpotlightTour(SpotightTourType, Title, ExpectedDuration, ObjectID, OrderID);

        GetGuidedExperienceItem(GuidedExperienceItem, GuidedExperienceType::"Spotlight Tour", ObjectType, ObjectID, '', '', SpotightTourType);

        // [GIVEN] The title of the spotlight tour is enqueued in the variable storage
        LibraryVariableStorage.Enqueue(Title);

        // [GIVEN] Two users whose usernames are enqueued in the variable storage
        LibraryVariableStorage.Enqueue(UserName1);
        LibraryVariableStorage.Enqueue(UserName2);

        // [GIVEN] The checklist page is open and from there the "Create New" action is 
        // invoked - see the checklist page handler
        Checklist.Run();

        // [WHEN] The title lookup is opened for guided experience items of 
        // type spotlight tour - see the checklist administration page handler
        // [THEN] The newly created spotlight tour is present on the lookup page
        Assert.IsTrue(LibraryVariableStorage.DequeueBoolean(), 'The spotlight tour is not displayed on the page.');

        // [WHEN] The spotlight tour is selected in the lookup - see page handler
        // [THEN] The fields are populated correctly on the checklist administration page 
        VerifyFieldsOnPage(Title, ExpectedDuration, 'Page Checklist Users', '', '', SpotightTourType, ChecklistCompletionRequirements::Anyone);

        // [THEN] A new checklist item is created for the selected guided experience item
        Assert.IsTrue(ChecklistItem.Get(GuidedExperienceItem.Code), 'A new checklist item should have been created.');

        // [WHEN] Two users are inserted in the Users part of the Checklist Administration page
        // see the checklist administration page handler
        // [THEN] Two new checklist item users are created for the users 
        VerifyChecklistItemUser(GuidedExperienceItem.Code, UserName1);
        VerifyChecklistItemUser(GuidedExperienceItem.Code, UserName2);
    end;


    local procedure VerifyFieldsOnPage(Title: Text[2048]; ExpectedDuration: Integer; ObjectCaption: Text; Link: Text[250]; VideoUrl: Text[250]; SpotlightTourType: Enum "Spotlight Tour Type"; ChecklistCompletionRequirements: Enum "Checklist Completion Requirements")
    begin
        Assert.AreEqual(Title, LibraryVariableStorage.DequeueText(), 'The title is incorrect.');
        Assert.AreEqual(Format(ExpectedDuration), LibraryVariableStorage.DequeueText(),
            'The expected duration is incorrect.');
        Assert.AreEqual(ObjectCaption, LibraryVariableStorage.DequeueText(), 'The object caption is incorrect.');
        Assert.AreEqual(Link, LibraryVariableStorage.DequeueText(), 'The link is incorrect.');
        Assert.AreEqual(VideoUrl, LibraryVariableStorage.DequeueText(), 'The video URL is incorrect.');
        Assert.AreEqual(Format(SpotlightTourType), LibraryVariableStorage.DequeueText(), 'The spotlight tour type is incorrect.');
        Assert.AreEqual(Format(ChecklistCompletionRequirements), LibraryVariableStorage.DequeueText(),
            'The completion requirements are incorrect.');
        Assert.AreEqual('1', LibraryVariableStorage.DequeueText(), 'The order ID is incorrect.');
    end;

    // [Test]
    [HandlerFunctions('ChecklistEditPageHandler,EditChecklistAdministrationModalPageHandler')]
    [Scope('OnPrem')]
    procedure TestChangeCompletionRequirementTypeFromEveryoneToEveryone()
    var
        ChecklistCompletionRequirements: Enum "Checklist Completion Requirements";
    begin
        Initialize(false);

        TestChangeCompletionRequirementsForRoles(true, ChecklistCompletionRequirements::Everyone, true);
    end;

    // [Test]
    [HandlerFunctions('ChecklistEditPageHandler,EditChecklistAdministrationModalPageHandler')]
    [Scope('OnPrem')]
    procedure TestChangeCompletionRequirementTypeFromAnyoneToAnyone()
    var
        ChecklistCompletionRequirements: Enum "Checklist Completion Requirements";
    begin
        Initialize(false);

        TestChangeCompletionRequirementsForRoles(false, ChecklistCompletionRequirements::Anyone, true);
    end;

    // [Test]
    [HandlerFunctions('ChecklistEditPageHandler,EditChecklistAdministrationModalPageHandler')]
    [Scope('OnPrem')]
    procedure TestChangeCompletionRequirementTypeFromEveryoneToAnyone()
    var
        ChecklistCompletionRequirements: Enum "Checklist Completion Requirements";
    begin
        Initialize(false);

        TestChangeCompletionRequirementsForRoles(true, ChecklistCompletionRequirements::Anyone, true);
    end;

    // [Test]
    [HandlerFunctions('ChecklistEditPageHandler,EditChecklistAdministrationModalPageHandler')]
    [Scope('OnPrem')]
    procedure TestChangeCompletionRequirementTypeFromAnyoneToEveryone()
    var
        ChecklistCompletionRequirements: Enum "Checklist Completion Requirements";
    begin
        Initialize(false);

        TestChangeCompletionRequirementsForRoles(false, ChecklistCompletionRequirements::Everyone, true);
    end;

    // [Test]
    [HandlerFunctions('ChecklistEditPageHandler,EditChecklistAdministrationModalPageHandler,CompletionRequirementsChangeConfirmHandler')]
    [Scope('OnPrem')]
    procedure TestChangeCompletionRequirementTypeFromAnyoneToSpecificUsers()
    var
        ChecklistCompletionRequirements: Enum "Checklist Completion Requirements";
    begin
        Initialize(false);

        TestChangeCompletionRequirementsForRoles(false, ChecklistCompletionRequirements::"Specific users", false);
    end;

    // [Test]
    [HandlerFunctions('ChecklistEditPageHandler,EditChecklistAdministrationModalPageHandler,CompletionRequirementsChangeConfirmHandler')]
    [Scope('OnPrem')]
    procedure TestChangeCompletionRequirementTypeFromEveryoneToSpecificUsers()
    var
        ChecklistCompletionRequirements: Enum "Checklist Completion Requirements";
    begin
        Initialize(false);

        TestChangeCompletionRequirementsForRoles(true, ChecklistCompletionRequirements::"Specific users", false);
    end;

    [Test]
    [HandlerFunctions('ChecklistEditPageHandler,EditChecklistAdministrationModalPageHandler')]
    [Scope('OnPrem')]
    procedure TestChangeCompletionRequirementTypeFromSpecificUsersToSpecificUsers()
    var
        ChecklistCompletionRequirements: Enum "Checklist Completion Requirements";
    begin
        Initialize(false);

        TestChangeCompletionRequirementsForUsers(ChecklistCompletionRequirements::"Specific users", true);
    end;

    [Test]
    [HandlerFunctions('ChecklistEditPageHandler,EditChecklistAdministrationModalPageHandler,CompletionRequirementsChangeConfirmHandler')]
    [Scope('OnPrem')]
    procedure TestChangeCompletionRequirementTypeFromSpecificUsersToAnyone()
    var
        ChecklistCompletionRequirements: Enum "Checklist Completion Requirements";
    begin
        Initialize(false);

        TestChangeCompletionRequirementsForUsers(ChecklistCompletionRequirements::Anyone, false);
    end;

    [Test]
    [HandlerFunctions('ChecklistEditPageHandler,EditChecklistAdministrationModalPageHandler,CompletionRequirementsChangeConfirmHandler')]
    [Scope('OnPrem')]
    procedure TestChangeCompletionRequirementTypeFromSpecificUsersToEveryone()
    var
        ChecklistCompletionRequirements: Enum "Checklist Completion Requirements";
    begin
        Initialize(false);

        TestChangeCompletionRequirementsForUsers(ChecklistCompletionRequirements::Everyone, false);
    end;

    local procedure TestChangeCompletionRequirementsForRoles(ShouldEveryoneComplete: Boolean; NewCompletionRequirement: Enum "Checklist Completion Requirements"; ShouldRolesStillExist: Boolean)
    var
        TempAllProfile: Record "All Profile" temporary;
        GuidedExperienceItem: Record "Guided Experience Item";
        ChecklistItem: Record "Checklist Item";
        ChecklistItemRole: Record "Checklist Item Role";
        ChecklistAPI: Codeunit Checklist;
        Checklist: Page Checklist;
        GuidedExperienceType: Enum "Guided Experience Type";
        SpotightTourType: Enum "Spotlight Tour Type";
        Title: Text[2048];
        ExpectedDuration: Integer;
        OrderID: Integer;
        ObjectType: ObjectType;
        ObjectID: Integer;
        NewOrderID: Integer;
    begin
        // [GIVEN] A checklist item with 2 checklist item roles
        ObjectType := ObjectType::Page;
        ObjectID := Page::"Checklist Item Roles";

        AddRoleToList(TempAllProfile, ProfileID1);
        AddRoleToList(TempAllProfile, ProfileID2);

        PermissionsMock.Set('Guided Exp Edit');

        InsertAssistedSetup(Title, ExpectedDuration, ObjectType, ObjectID, OrderID);
        ChecklistAPI.Insert(GuidedExperienceType::"Assisted Setup", ObjectType, ObjectID, OrderID, TempAllProfile, ShouldEveryoneComplete);

        GetGuidedExperienceItem(GuidedExperienceItem, GuidedExperienceType::"Assisted Setup", ObjectType, ObjectID, '', '', SpotightTourType::None);

        // [GIVEN] The title of the checklist item is enqueued in the variable storage
        LibraryVariableStorage.Enqueue(Title);

        // [GIVEN] New values for completion requirements and order id are enqueued in the variable storage 
        LibraryVariableStorage.Enqueue(NewCompletionRequirement);

        NewOrderID := OrderID + Random(10);
        LibraryVariableStorage.Enqueue(NewOrderID);

        // [GIVEN] The Checklist page is run and the newly created checklist item is opened 
        // on the Checklist Administration page - see the checklist page handler
        Checklist.Run();

        // [WHEN] The completion requirements are changed to the new value - see the checklist 
        // administration page handler
        // [THEN] The checklist item's completion requirements have changed
        ChecklistItem.Get(GuidedExperienceItem.Code);
        Assert.AreEqual(NewCompletionRequirement, ChecklistItem."Completion Requirements",
            'The completion requirements should have been updated.');

        // [THEN] The order ID of the checklist item has been updated correctly
        Assert.AreEqual(NewOrderID, ChecklistItem."Order ID", 'The order ID should have been updated.');

        // [THEN] Verify the existance of the two checklist item roles  
        Assert.AreEqual(ShouldRolesStillExist, ChecklistItemRole.Get(ChecklistItem.Code, ProfileID1),
            'The first checklist item role''s Get return value is wrong (it either still exists when it shouldn''t or it was deleted when it shouldn''t have been).');
        Assert.AreEqual(ShouldRolesStillExist, ChecklistItemRole.Get(ChecklistItem.Code, ProfileID2),
            'The second checklist item role''s Get return value is wrong (it either still exists when it shouldn''t or it was deleted when it shouldn''t have been).');
    end;

    local procedure TestChangeCompletionRequirementsForUsers(NewCompletionRequirement: Enum "Checklist Completion Requirements"; ShouldChecklistItemsBeAssignedToUsers: Boolean)
    var
        TempUser: Record User temporary;
        GuidedExperienceItem: Record "Guided Experience Item";
        ChecklistItem: Record "Checklist Item";
        ChecklistItemUser: Record "Checklist Item User";
        ChecklistAPI: Codeunit Checklist;
        Checklist: Page Checklist;
        GuidedExperienceType: Enum "Guided Experience Type";
        SpotightTourType: Enum "Spotlight Tour Type";
        Title: Text[2048];
        ExpectedDuration: Integer;
        OrderID: Integer;
        ObjectType: ObjectType;
        ObjectID: Integer;
        UserName1: Code[50];
        UserId1: Guid;
        UserName2: Code[50];
        UserId2: Guid;
        NewOrderID: Integer;
    begin
        // [GIVEN] A checklist item with 2 checklist item users
        ObjectType := ObjectType::Page;
        ObjectID := Page::"Checklist Item Roles";

        AddUserToList(TempUser, UserId1, UserName1);
        AddUserToList(TempUser, UserId2, UserName2);

        PermissionsMock.Set('Guided Exp Edit');

        InsertAssistedSetup(Title, ExpectedDuration, ObjectType, ObjectID, OrderID);
        ChecklistAPI.Insert(GuidedExperienceType::"Assisted Setup", ObjectType, ObjectID, OrderID, TempUser);

        GetGuidedExperienceItem(GuidedExperienceItem, GuidedExperienceType::"Assisted Setup", ObjectType, ObjectID, '', '', SpotightTourType::None);

        // [GIVEN] The title of the checklist item is enqueued in the variable storage
        LibraryVariableStorage.Enqueue(Title);

        // [GIVEN] New values for completion requirements and order id are enqueued in the variable storage 
        LibraryVariableStorage.Enqueue(NewCompletionRequirement);

        NewOrderID := OrderID + Random(10);
        LibraryVariableStorage.Enqueue(NewOrderID);

        // [GIVEN] The Checklist page is run and the newly created checklist item is opened 
        // on the Checklist Administration page - see the checklist page handler
        Checklist.Run();

        // [WHEN] The completion requirements are changed to the new value - see the checklist 
        // administration page handler
        // [THEN] The checklist item's completion requirements have changed
        ChecklistItem.Get(GuidedExperienceItem.Code);
        Assert.AreEqual(NewCompletionRequirement, ChecklistItem."Completion Requirements",
            'The completion requirements should have been updated.');

        // [THEN] The order ID of the checklist item has been updated correctly
        Assert.AreEqual(NewOrderID, ChecklistItem."Order ID", 'The order ID should have been updated.');

        // [THEN] Verify the checklist item users still exist and that the "Assigned to User" values are correct
        Assert.IsTrue(ChecklistItemUser.Get(ChecklistItem.Code, UserName1),
            'The first checklist item user should stil exist.');
        Assert.AreEqual(ShouldChecklistItemsBeAssignedToUsers, ChecklistItemUser."Assigned to User",
            'The Assigned to User value for the first checklist item user is incorrect.');

        Assert.IsTrue(ChecklistItemUser.Get(ChecklistItem.Code, UserName2),
            'The second checklist item user should stil exist.');
        Assert.AreEqual(ShouldChecklistItemsBeAssignedToUsers, ChecklistItemUser."Assigned to User",
            'The Assigned to User value for the second checklist item user is incorrect.');
    end;

    local procedure Initialize(ShouldInitializeProfiles: Boolean)
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        ChecklistItem: Record "Checklist Item";
        ChecklistItemRole: Record "Checklist Item Role";
        ChecklistItemUser: Record "Checklist Item User";
    begin
        if ShouldInitializeProfiles then begin
            InsertProfile(ProfileID1);
            InsertProfile(ProfileID2);
            InsertProfile(ProfileID3);
        end;

        GuidedExperienceItem.DeleteAll();
        ChecklistItem.DeleteAll();
        ChecklistItemRole.DeleteAll();
        ChecklistItemUser.DeleteAll();

        LibraryVariableStorage.Clear();
    end;

    local procedure InsertAssistedSetup(var Title: Text[2048]; var ExpectedDuration: Integer; ObjectTypeToRun: ObjectType; ObjectIDToRun: Integer; var OrderID: Integer)
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        GuidedExperience: Codeunit "Guided Experience";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
    begin
        PopulateSetupFields(Title, ExpectedDuration, OrderID);

        GuidedExperience.InsertAssistedSetup(Title, CopyStr(Any.AlphabeticText(50), 1, MaxStrLen(GuidedExperienceItem."Short Title")),
            CopyStr(Any.AlphanumericText(1024), 1, MaxStrLen(GuidedExperienceItem.Description)), ExpectedDuration, ObjectTypeToRun,
            ObjectIDToRun, AssistedSetupGroup::Uncategorized, '', VideoCategory::Uncategorized, '');
    end;

    local procedure InsertManualSetup(var Title: Text[2048]; var ExpectedDuration: Integer; ObjectTypeToRun: ObjectType; ObjectIDToRun: Integer; var OrderID: Integer)
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        GuidedExperience: Codeunit "Guided Experience";
        ManualSetupCategory: Enum "Manual Setup Category";
    begin
        PopulateSetupFields(Title, ExpectedDuration, OrderID);

        GuidedExperience.InsertManualSetup(Title, CopyStr(Any.AlphabeticText(50), 1, MaxStrLen(GuidedExperienceItem."Short Title")),
            CopyStr(Any.AlphanumericText(1024), 1, MaxStrLen(GuidedExperienceItem.Description)), ExpectedDuration, ObjectTypeToRun,
            ObjectIDToRun, ManualSetupCategory::Uncategorized, '');
    end;

    local procedure InsertApplicationFeature(var Title: Text[2048]; var ExpectedDuration: Integer; ObjectTypeToRun: ObjectType; ObjectIDToRun: Integer; var OrderID: Integer)
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        GuidedExperience: Codeunit "Guided Experience";
    begin
        PopulateSetupFields(Title, ExpectedDuration, OrderID);

        GuidedExperience.InsertApplicationFeature(Title, CopyStr(Any.AlphabeticText(50), 1, MaxStrLen(GuidedExperienceItem."Short Title")),
            CopyStr(Any.AlphanumericText(1024), 1, MaxStrLen(GuidedExperienceItem.Description)), ExpectedDuration, ObjectTypeToRun, ObjectIDToRun);
    end;

    local procedure InsertLink(GuidedExperienceType: Enum "Guided Experience Type"; var Title: Text[2048]; var ExpectedDuration: Integer; var LinkToRun: Text[250]; var OrderID: Integer)
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        GuidedExperience: Codeunit "Guided Experience";
        VideoCategory: Enum "Video Category";
    begin
        PopulateSetupFields(Title, ExpectedDuration, OrderID);

        LinkToRun := GetNewLink();

        case GuidedExperienceType of
            GuidedExperienceType::Learn:
                GuidedExperience.InsertLearnLink(Title, CopyStr(Any.AlphabeticText(50), 1, MaxStrLen(GuidedExperienceItem."Short Title")),
                    CopyStr(Any.AlphanumericText(1024), 1, MaxStrLen(GuidedExperienceItem.Description)), ExpectedDuration, LinkToRun);
            GuidedExperienceType::Video:
                GuidedExperience.InsertVideo(Title, CopyStr(Any.AlphabeticText(50), 1, MaxStrLen(GuidedExperienceItem."Short Title")),
                    CopyStr(Any.AlphanumericText(1024), 1, MaxStrLen(GuidedExperienceItem.Description)),
                    ExpectedDuration, LinkToRun, VideoCategory::Uncategorized);
        end;
    end;

    local procedure InsertTour(var Title: Text[2048]; var ExpectedDuration: Integer; ObjectIDToRun: Integer; var OrderID: Integer)
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        GuidedExperience: Codeunit "Guided Experience";
    begin
        PopulateSetupFields(Title, ExpectedDuration, OrderID);

        GuidedExperience.InsertTour(Title, CopyStr(Any.AlphabeticText(50), 1, MaxStrLen(GuidedExperienceItem."Short Title")),
            CopyStr(Any.AlphanumericText(1024), 1, MaxStrLen(GuidedExperienceItem.Description)), ExpectedDuration, ObjectIDToRun);
    end;

    local procedure InsertSpotlightTour(SpotlightTourType: Enum "Spotlight Tour Type"; var Title: Text[2048]; var ExpectedDuration: Integer; ObjectIDToRun: Integer; var OrderID: Integer)
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        GuidedExperience: Codeunit "Guided Experience";
        SpotlightTourTexts: Dictionary of [Enum "Spotlight Tour Text", Text];
    begin
        PopulateSetupFields(Title, ExpectedDuration, OrderID);

        GetSpotlightTourTexts(SpotlightTourTexts);

        GuidedExperience.InsertSpotlightTour(Title, CopyStr(Any.AlphabeticText(50), 1, MaxStrLen(GuidedExperienceItem."Short Title")),
            CopyStr(Any.AlphanumericText(1024), 1, MaxStrLen(GuidedExperienceItem.Description)), ExpectedDuration,
            ObjectIDToRun, SpotlightTourType, SpotlightTourTexts);
    end;

    local procedure PopulateSetupFields(var Title: Text[2048]; var ExpectedDuration: Integer; var OrderID: Integer)
    begin
        Title := CopyStr(Any.AlphanumericText(MaxStrLen(Title)), 1, MaxStrLen(Title));
        ExpectedDuration := Any.IntegerInRange(50000);
        OrderID := any.IntegerInRange(100000);
    end;

    local procedure GetNewLink(): Text[250]
    begin
        exit(CopyStr(Any.AlphanumericText(250), 1, 250));
    end;

    local procedure GetSpotlightTourTexts(var SpotlightTourTexts: Dictionary of [Enum "Spotlight Tour Text", Text])
    var
        SpotlightTourText: Enum "Spotlight Tour Text";
    begin
        SpotlightTourTexts.Add(SpotlightTourText::Step1Title, Any.AlphanumericText(250));
        SpotlightTourTexts.Add(SpotlightTourText::Step1Text, Any.AlphanumericText(250));

        SpotlightTourTexts.Add(SpotlightTourText::Step2Title, Any.AlphanumericText(250));
        SpotlightTourTexts.Add(SpotlightTourText::Step2Text, Any.AlphanumericText(250));
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

    local procedure AddUserToList(var TempUser: Record User temporary; var UserSecurityId: Guid; var UserName: Code[50])
    var
        User: Record User;
    begin
        InsertUser(UserSecurityId, UserName);

        User.SetRange("User Security ID", UserSecurityId);
        if User.FindFirst() then begin
            TempUser.TransferFields(User);
            TempUser.Insert();
        end;
    end;

    local procedure GetGuidedExperienceItem(var GuidedExperienceItem: Record "Guided Experience Item"; GuidedExperienceType: Enum "Guided Experience Type"; ObjectType: ObjectType; ObjectId: Integer; Link: Text[250]; VideoUrl: Text[250]; SpotlightTourType: Enum "Spotlight Tour Type")
    var
        GuidedExperienceImpl: Codeunit "Guided Experience Impl.";
    begin
        GuidedExperienceImpl.FilterGuidedExperienceItem(GuidedExperienceItem, GuidedExperienceType, ObjectType, ObjectId, Link, VideoUrl, SpotlightTourType);
        if GuidedExperienceItem.FindFirst() then;
    end;

    local procedure OpenLookupForGuidedExperienceType(var ChecklistAdministration: TestPage "Checklist Administration"; GuidedExperienceType: Enum "Guided Experience Type")
    begin
        ChecklistAdministration.Type.SetValue(GuidedExperienceType);
        ChecklistAdministration.Title.Lookup();
    end;

    local procedure EnqueueFieldValues(var ChecklistAdministration: TestPage "Checklist Administration")
    begin
        LibraryVariableStorage.Enqueue(ChecklistAdministration.Title.Value);
        LibraryVariableStorage.Enqueue(ChecklistAdministration."Expected Duration".Value);
        LibraryVariableStorage.Enqueue(ChecklistAdministration.ObjectCaption.Value);
        LibraryVariableStorage.Enqueue(ChecklistAdministration.Link.Value);
        LibraryVariableStorage.Enqueue(ChecklistAdministration."Video Url".Value);
        LibraryVariableStorage.Enqueue(ChecklistAdministration."Spotlight Tour Type".Value);
        LibraryVariableStorage.Enqueue(ChecklistAdministration."Completion Requirements".Value);
        LibraryVariableStorage.Enqueue(ChecklistAdministration."Order ID".Value);
    end;

    local procedure AddRoles(var ChecklistAdministration: TestPage "Checklist Administration"; NumberOfRoles: Integer)
    var
        i: Integer;
    begin
        for i := 1 to NumberOfRoles do begin
            ChecklistAdministration.Roles.New();
            ChecklistAdministration.Roles."Role ID".SetValue(LibraryVariableStorage.DequeueText());
        end;
    end;

    local procedure AddUsers(var ChecklistAdministration: TestPage "Checklist Administration"; NumberOfUsers: Integer)
    var
        i: Integer;
    begin
        for i := 1 to NumberOfUsers do begin
            ChecklistAdministration.Users.New();
            ChecklistAdministration.Users."User Name".SetValue(LibraryVariableStorage.DequeueText());
        end;
    end;

    local procedure VerifyChecklistItemUser(Code: Code[300]; UserName: Code[50])
    var
        ChecklistItemUser: Record "Checklist Item User";
    begin
        Assert.IsTrue(ChecklistItemUser.Get(Code, UserName),
            'A checklist item user should have been inserted for the user.');
        Assert.IsTrue(ChecklistItemUser."Assigned to User",
            'The user should have the Assigned to User flag set to true.');
    end;

    [PageHandler]
    [Scope('OnPrem')]
    procedure ChecklistPageHandler(var Checklist: TestPage Checklist)
    var
        Index: Integer;
    begin
        if Checklist.First() then begin
            Index := 1;

            Assert.AreEqual(LibraryVariableStorage.DequeueText(), Checklist.Title.Value, 'The title is incorrect.');
            Assert.AreEqual(LibraryVariableStorage.DequeueText(), Checklist."Expected Duration".Value, 'The expected duration is incorrect.');
            Assert.AreEqual(LibraryVariableStorage.DequeueText(), Checklist."Order ID".Value, 'The order ID is incorrect.');
            Assert.AreEqual(LibraryVariableStorage.DequeueText(), Checklist."Completition Requirements".Value, 'The completion requirements are incorrect.');

            while Checklist.Next() do
                Index += 1;
        end;

        Assert.AreEqual(LibraryVariableStorage.DequeueInteger(), Index, 'The Checklist page should display 4 records.');
    end;

    [PageHandler]
    [Scope('OnPrem')]
    procedure ChecklistPageHandlerForSingleRole(var Checklist: TestPage Checklist)
    begin
        Checklist.First();

        Assert.AreEqual(LibraryVariableStorage.DequeueText(), Checklist."Assigned To".Value, 'The Assigned To field is not set correctly.');
    end;

    [PageHandler]
    [Scope('OnPrem')]
    procedure ChecklistPageHandlerForSingleUser(var Checklist: TestPage Checklist)
    begin
        Checklist.First();

        Assert.AreEqual(LibraryVariableStorage.DequeueText(), Checklist."Assigned To".Value, 'The Assigned To field is not set correctly.');
    end;

    [PageHandler]
    [Scope('OnPrem')]
    procedure ChecklistPageHandlerForMultipleRolesOrUsers(var Checklist: TestPage Checklist)
    begin
        Checklist.First();

        Assert.AreEqual(LibraryVariableStorage.DequeueText(), Checklist."Assigned To".Value, 'The Assigned To field is not set correctly.');
    end;

    [PageHandler]
    [Scope('OnPrem')]
    procedure ChecklistEditPageHandler(var Checklist: TestPage Checklist)
    begin
        Checklist.FILTER.SetFilter(Title, LibraryVariableStorage.DequeueText());
        Checklist.Title.Drilldown();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure EditChecklistAdministrationModalPageHandler(var ChecklistAdministration: TestPage "Checklist Administration")
    begin
        ChecklistAdministration."Completion Requirements".SetValue(LibraryVariableStorage.DequeueText());
        ChecklistAdministration."Order ID".SetValue(LibraryVariableStorage.DequeueInteger());
    end;

    [PageHandler]
    [Scope('OnPrem')]
    procedure CreateChecklistItemPageHandler(var Checklist: TestPage Checklist)
    var
        ChecklistItem: Record "Checklist Item";
    begin
        ChecklistItem.Code := '0';
        ChecklistItem.Insert();

        Checklist."Create checklist item".Invoke();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure ChecklistAdministrationPageHandlerForAssistedSetup(var ChecklistAdministration: TestPage "Checklist Administration")
    var
        GuidedExperienceType: Enum "Guided Experience Type";
    begin
        OpenLookupForGuidedExperienceType(ChecklistAdministration, GuidedExperienceType::"Assisted Setup");

        EnqueueFieldValues(ChecklistAdministration);

        AddRoles(ChecklistAdministration, 2);
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure ChecklistAdministrationPageHandlerForManualSetup(var ChecklistAdministration: TestPage "Checklist Administration")
    var
        GuidedExperienceType: Enum "Guided Experience Type";
    begin
        OpenLookupForGuidedExperienceType(ChecklistAdministration, GuidedExperienceType::"Manual Setup");

        EnqueueFieldValues(ChecklistAdministration);

        AddUsers(ChecklistAdministration, 2);
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure ChecklistAdministrationPageHandlerForLearnLink(var ChecklistAdministration: TestPage "Checklist Administration")
    var
        GuidedExperienceType: Enum "Guided Experience Type";
    begin
        OpenLookupForGuidedExperienceType(ChecklistAdministration, GuidedExperienceType::Learn);

        EnqueueFieldValues(ChecklistAdministration);

        AddUsers(ChecklistAdministration, 2);
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure ChecklistAdministrationPageHandlerForApplicationFeature(var ChecklistAdministration: TestPage "Checklist Administration")
    var
        GuidedExperienceType: Enum "Guided Experience Type";
    begin
        OpenLookupForGuidedExperienceType(ChecklistAdministration, GuidedExperienceType::"Application Feature");

        EnqueueFieldValues(ChecklistAdministration);

        AddUsers(ChecklistAdministration, 2);
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure ChecklistAdministrationPageHandlerForVideoUrl(var ChecklistAdministration: TestPage "Checklist Administration")
    var
        GuidedExperienceType: Enum "Guided Experience Type";
    begin
        OpenLookupForGuidedExperienceType(ChecklistAdministration, GuidedExperienceType::Video);

        EnqueueFieldValues(ChecklistAdministration);

        AddUsers(ChecklistAdministration, 2);
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure ChecklistAdministrationPageHandlerForTour(var ChecklistAdministration: TestPage "Checklist Administration")
    var
        GuidedExperienceType: Enum "Guided Experience Type";
    begin
        OpenLookupForGuidedExperienceType(ChecklistAdministration, GuidedExperienceType::Tour);

        EnqueueFieldValues(ChecklistAdministration);

        AddUsers(ChecklistAdministration, 2);
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure ChecklistAdministrationPageHandlerForSpotlightTour(var ChecklistAdministration: TestPage "Checklist Administration")
    var
        GuidedExperienceType: Enum "Guided Experience Type";
    begin
        OpenLookupForGuidedExperienceType(ChecklistAdministration, GuidedExperienceType::"Spotlight Tour");

        EnqueueFieldValues(ChecklistAdministration);

        AddUsers(ChecklistAdministration, 2);
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure GuidedExperienceItemListModalPageHandler(var GuidedExperienceItemList: TestPage "Guided Experience Item List")
    begin
        GuidedExperienceItemList.FILTER.SetFilter(Title, LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.Enqueue(GuidedExperienceItemList.First());

        GuidedExperienceItemList.OK().Invoke();
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure CompletionRequirementsChangeConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;
}