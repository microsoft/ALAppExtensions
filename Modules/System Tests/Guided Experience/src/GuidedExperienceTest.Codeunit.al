// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132594 "Guided Experience Test"
{
    Subtype = Test;

    Permissions = tabledata "Guided Experience Item" = rimd,
                    tabledata "Spotlight Tour Text" = rimd;

    var
        Assert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";
        Any: Codeunit Any;
        GuidedExperienceTestLibrary: Codeunit "Guided Experience Test Library";

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertAssistedSetup()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        ObjectTypeToRun: Enum "Guided Experience Object Type";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        ManualSetupCategory: Enum "Manual Setup Category";
        SpotlightTourType: Enum "Spotlight Tour Type";
        SpotlightTourTexts: Dictionary of [Enum "Spotlight Tour Text", Text];
        Title: Text[2048];
        ShortTitle: Text[50];
        Description: Text[1024];
        ExpectedDuration: Integer;
        ObjectIDToRun: Integer;
        Code: Code[300];
        VideoUrl: Text[250];
        HelpUrl: Text[250];
    begin
        // [GIVEN] The Guided Experience Item table is empty
        GuidedExperienceItem.DeleteAll();

        PermissionsMock.Set('Guided Exp Edit');

        // [WHEN] Inserting a new assisted setup
        ObjectIDToRun := Page::"Assisted Setup Wizard";
        AssistedSetupGroup := AssistedSetupGroup::Uncategorized;
        VideoCategory := VideoCategory::Uncategorized;
        GuidedExperienceTestLibrary.InsertAssistedSetup(true, Title, ShortTitle, Description, ExpectedDuration,
            ObjectType::Page, ObjectIDToRun, AssistedSetupGroup, VideoUrl, VideoCategory, HelpUrl);

        // [THEN] There is exactly one record in the Guided Experience Item table
        Assert.AreEqual(1, GuidedExperienceItem.Count, 'The Guided Experience Item should contain exactly one record');

        // [THEN] The fields of the Guided Experience Item are set correctly
        GuidedExperienceItem.FindFirst();
        Code := 'ASSISTED SETUP_PAGE_132610__0';
        VerifyGuidedExperienceItemFields(GuidedExperienceItem, Code, 0, ObjectTypeToRun::Page, ObjectIDToRun, '', Title, ShortTitle, Description,
            ExpectedDuration, false, GuidedExperienceType::"Assisted Setup", AssistedSetupGroup,
            HelpUrl, VideoUrl, VideoCategory, ManualSetupCategory::Uncategorized, '', SpotlightTourType::None, SpotlightTourTexts);

        // [WHEN] Inserting a new version of the assisted setup page
        GuidedExperienceTestLibrary.InsertAssistedSetup(true, Title, ShortTitle, Description, ExpectedDuration,
            ObjectType::Page, ObjectIDToRun, AssistedSetupGroup, VideoUrl, VideoCategory, HelpUrl);

        VerifyAfterNonIdenticalInsertion(Code);

        // [THEN] The fields of the second version of the Guided Experience Item are set correctly
        if GuidedExperienceItem.Get(Code, 1) then;
        VerifyGuidedExperienceItemFields(GuidedExperienceItem, Code, 1, ObjectTypeToRun::Page, ObjectIDToRun, '', Title, ShortTitle, Description,
            ExpectedDuration, false, GuidedExperienceType::"Assisted Setup", AssistedSetupGroup,
            HelpUrl, VideoUrl, VideoCategory, ManualSetupCategory::Uncategorized, '', SpotlightTourType::None, SpotlightTourTexts);

        // [WHEN] Trying to insert an assisted setup page with the same fields as the last version that was inserted
        GuidedExperienceTestLibrary.InsertAssistedSetup(false, Title, ShortTitle, Description, ExpectedDuration,
            ObjectType::Page, ObjectIDToRun, AssistedSetupGroup, VideoUrl, VideoCategory, HelpUrl);

        VerifyAfterIdenticalInsertion(Code);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertManualSetup()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        ObjectTypeToRun: Enum "Guided Experience Object Type";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        ManualSetupCategory: Enum "Manual Setup Category";
        SpotlightTourType: Enum "Spotlight Tour Type";
        SpotlightTourTexts: Dictionary of [Enum "Spotlight Tour Text", Text];
        Title: Text[2048];
        ShortTitle: Text[50];
        Description: Text[1024];
        ExpectedDuration: Integer;
        ObjectIDToRun: Integer;
        Code: Code[300];
        Keywords: Text[250];
    begin
        // [GIVEN] The Guided Experience Item table is empty
        GuidedExperienceItem.DeleteAll();

        PermissionsMock.Set('Guided Exp Edit');

        // [WHEN] Inserting a new manual setup
        ObjectIDToRun := Codeunit::"Checklist Test Codeunit";
        ManualSetupCategory := ManualSetupCategory::Uncategorized;
        GuidedExperienceTestLibrary.InsertManualSetup(true, Title, ShortTitle, Description, ExpectedDuration,
            ObjectType::Codeunit, ObjectIDToRun, ManualSetupCategory, Keywords);

        // [THEN] There is exactly one record in the Guided Experience Item table
        Assert.AreEqual(1, GuidedExperienceItem.Count, 'The Guided Experience Item should contain exactly one record');

        // [THEN] The fields of the Guided Experience Item are set correctly
        GuidedExperienceItem.FindFirst();
        Code := 'MANUAL SETUP_CODEUNIT_132610__0';
        VerifyGuidedExperienceItemFields(GuidedExperienceItem, Code, 0, ObjectTypeToRun::Codeunit, ObjectIDToRun, '', Title, ShortTitle, Description,
            ExpectedDuration, false, GuidedExperienceType::"Manual Setup", AssistedSetupGroup::Uncategorized,
            '', '', VideoCategory::Uncategorized, ManualSetupCategory, Keywords, SpotlightTourType::None, SpotlightTourTexts);

        // [WHEN] Inserting a new version of the manual setup
        GuidedExperienceTestLibrary.InsertManualSetup(true, Title, ShortTitle, Description, ExpectedDuration,
            ObjectType::Codeunit, ObjectIDToRun, ManualSetupCategory, Keywords);

        VerifyAfterNonIdenticalInsertion(Code);

        // [THEN] The fields of the second version of the Guided Experience Item are set correctly
        if GuidedExperienceItem.Get(Code, 1) then;
        VerifyGuidedExperienceItemFields(GuidedExperienceItem, Code, 1, ObjectTypeToRun::Codeunit, ObjectIDToRun, '', Title, ShortTitle, Description,
            ExpectedDuration, false, GuidedExperienceType::"Manual Setup", AssistedSetupGroup::Uncategorized,
            '', '', VideoCategory::Uncategorized, ManualSetupCategory, Keywords, SpotlightTourType::None, SpotlightTourTexts);

        // [WHEN] Trying to insert a manual setup with the same fields as the last version that was inserted
        GuidedExperienceTestLibrary.InsertManualSetup(false, Title, ShortTitle, Description, ExpectedDuration,
            ObjectType::Codeunit, ObjectIDToRun, ManualSetupCategory, Keywords);

        VerifyAfterIdenticalInsertion(Code);
    end;

#if not CLEAN19
    [Test]
    [Scope('OnPrem')]
    procedure TestInsertLearnPage()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        GuidedExperience: Codeunit "Guided Experience";
        ObjectTypeToRun: Enum "Guided Experience Object Type";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        ManualSetupCategory: Enum "Manual Setup Category";
        SpotlightTourType: Enum "Spotlight Tour Type";
        SpotlightTourTexts: Dictionary of [Enum "Spotlight Tour Text", Text];
        Title: Text[2048];
        ShortTitle: Text[30];
        Description: Text[1024];
        ExpectedDuration: Integer;
        PageID: Integer;
        Code: Code[300];
    begin
        // [GIVEN] The Guided Experience Item table is empty
        GuidedExperienceItem.DeleteAll();

        PermissionsMock.Set('Guided Exp Edit');

        // [WHEN] Inserting a new learn page
        Title := 'This is the title of the guided experience item';
        ShortTitle := 'Short title';
        Description := 'Description blah blah';
        ExpectedDuration := 5;
        PageID := 1801;
        GuidedExperience.InsertLearnPage(Title, ShortTitle, Description, ExpectedDuration, PageID);

        // [THEN] There is exactly one record in the Guided Experience Item table
        Assert.AreEqual(1, GuidedExperienceItem.Count, 'The Guided Experience Item should contain exactly one record');

        // [THEN] The fields of the Guided Experience Item are set correctly
        if GuidedExperienceItem.FindFirst() then;
        Code := 'LEARN_PAGE_1801__0';
        VerifyGuidedExperienceItemFields(GuidedExperienceItem, Code, 0, ObjectTypeToRun::Page, PageID, '', Title, ShortTitle, Description,
            ExpectedDuration, false, GuidedExperienceType::Learn, AssistedSetupGroup::Uncategorized,
            '', '', VideoCategory::Uncategorized, ManualSetupCategory::Uncategorized, '', SpotlightTourType::None, SpotlightTourTexts);

        // [WHEN] Inserting a new version of the learn page
        Title := 'Title different version';
        ShortTitle := 'Another short title';
        Description := 'Description version 2';
        ExpectedDuration := 10;
        GuidedExperience.InsertLearnPage(Title, ShortTitle, Description, ExpectedDuration, PageID);

        VerifyAfterNonIdenticalInsertion(Code);

        // [THEN] The fields of the second version of the Guided Experience Item are set correctly
        if GuidedExperienceItem.Get(Code, 1) then;
        VerifyGuidedExperienceItemFields(GuidedExperienceItem, Code, 1, ObjectTypeToRun::Page, PageID, '', Title, ShortTitle, Description,
            ExpectedDuration, false, GuidedExperienceType::Learn, AssistedSetupGroup::Uncategorized,
            '', '', VideoCategory::Uncategorized, ManualSetupCategory::Uncategorized, '', SpotlightTourType::None, SpotlightTourTexts);

        // [WHEN] Trying to insert a learn page with the same fields as the last version that was inserted
        GuidedExperience.InsertLearnPage(Title, ShortTitle, Description, ExpectedDuration, PageID);

        VerifyAfterIdenticalInsertion(Code);
    end;
#endif

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertLearnLink()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        ObjectTypeToRun: Enum "Guided Experience Object Type";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        ManualSetupCategory: Enum "Manual Setup Category";
        SpotlightTourType: Enum "Spotlight Tour Type";
        SpotlightTourTexts: Dictionary of [Enum "Spotlight Tour Text", Text];
        Title: Text[2048];
        ShortTitle: Text[50];
        Description: Text[1024];
        ExpectedDuration: Integer;
        Link: Text[250];
        Code: Code[300];
    begin
        // [GIVEN] The Guided Experience Item table is empty
        GuidedExperienceItem.DeleteAll();

        PermissionsMock.Set('Guided Exp Edit');

        // [WHEN] Inserting a new learn link
        Link := CopyStr(Any.AlphanumericText(MaxStrLen(Link)), 1, MaxStrLen(Link));
        GuidedExperienceTestLibrary.InsertLearnLink(true, Title, ShortTitle, Description, ExpectedDuration, Link);

        // [THEN] There is exactly one record in the Guided Experience Item table
        Assert.AreEqual(1, GuidedExperienceItem.Count, 'The Guided Experience Item should contain exactly one record');

        // [THEN] The fields of the Guided Experience Item are set correctly
        GuidedExperienceItem.FindFirst();
        Code := 'LEARN_UNINITIALIZED_0_' + Link + '_0';
        VerifyGuidedExperienceItemFields(GuidedExperienceItem, Code, 0, ObjectTypeToRun::Uninitialized, 0, Link, Title, ShortTitle, Description,
            ExpectedDuration, false, GuidedExperienceType::Learn, AssistedSetupGroup::Uncategorized,
            '', '', VideoCategory::Uncategorized, ManualSetupCategory::Uncategorized, '', SpotlightTourType::None, SpotlightTourTexts);

        // [WHEN] Inserting a new version of the learn link
        GuidedExperienceTestLibrary.InsertLearnLink(true, Title, ShortTitle, Description, ExpectedDuration, Link);

        VerifyAfterNonIdenticalInsertion(Code);

        // [THEN] The fields of the second version of the Guided Experience Item are set correctly
        if GuidedExperienceItem.Get(Code, 1) then;
        VerifyGuidedExperienceItemFields(GuidedExperienceItem, Code, 1, ObjectTypeToRun::Uninitialized, 0, Link, Title, ShortTitle, Description,
            ExpectedDuration, false, GuidedExperienceType::Learn, AssistedSetupGroup::Uncategorized,
            '', '', VideoCategory::Uncategorized, ManualSetupCategory::Uncategorized, '', SpotlightTourType::None, SpotlightTourTexts);

        // [WHEN] Trying to insert a learn link with the same fields as the last version that was inserted
        GuidedExperienceTestLibrary.InsertLearnLink(false, Title, ShortTitle, Description, ExpectedDuration, Link);

        VerifyAfterIdenticalInsertion(Code);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertApplicationFeature()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        ObjectTypeToRun: Enum "Guided Experience Object Type";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        ManualSetupCategory: Enum "Manual Setup Category";
        SpotlightTourType: Enum "Spotlight Tour Type";
        SpotlightTourTexts: Dictionary of [Enum "Spotlight Tour Text", Text];
        Title: Text[2048];
        ShortTitle: Text[50];
        Description: Text[1024];
        ExpectedDuration: Integer;
        ObjectIDToRun: Integer;
        Code: Code[300];
        Keywords: Text[250];
    begin
        // [GIVEN] The Guided Experience Item table is empty
        GuidedExperienceItem.DeleteAll();

        PermissionsMock.Set('Guided Exp Edit');

        // [WHEN] Inserting a new application feature
        ObjectIDToRun := Codeunit::"Checklist Test Codeunit";
        GuidedExperienceTestLibrary.InsertApplicationFeature(true, Title, ShortTitle,
            Description, ExpectedDuration, ObjectType::Codeunit, ObjectIDToRun);

        // [THEN] There is exactly one record in the Guided Experience Item table
        Assert.AreEqual(1, GuidedExperienceItem.Count, 'The Guided Experience Item should contain exactly one record');

        // [THEN] The fields of the Guided Experience Item are set correctly
        GuidedExperienceItem.FindFirst();
        Code := 'APPLICATION FEATURE_CODEUNIT_132610__0';
        VerifyGuidedExperienceItemFields(GuidedExperienceItem, Code, 0, ObjectTypeToRun::Codeunit, ObjectIDToRun, '', Title, ShortTitle, Description,
            ExpectedDuration, false, GuidedExperienceType::"Application Feature", AssistedSetupGroup::Uncategorized,
            '', '', VideoCategory::Uncategorized, ManualSetupCategory::Uncategorized, Keywords, SpotlightTourType::None, SpotlightTourTexts);

        // [WHEN] Inserting a new version of the application feature
        GuidedExperienceTestLibrary.InsertApplicationFeature(true, Title, ShortTitle,
             Description, ExpectedDuration, ObjectType::Codeunit, ObjectIDToRun);

        VerifyAfterNonIdenticalInsertion(Code);

        // [THEN] The fields of the second version of the Guided Experience Item are set correctly
        if GuidedExperienceItem.Get(Code, 1) then;
        VerifyGuidedExperienceItemFields(GuidedExperienceItem, Code, 1, ObjectTypeToRun::Codeunit, ObjectIDToRun, '', Title, ShortTitle, Description,
            ExpectedDuration, false, GuidedExperienceType::"Application Feature", AssistedSetupGroup::Uncategorized,
            '', '', VideoCategory::Uncategorized, ManualSetupCategory::Uncategorized, Keywords, SpotlightTourType::None, SpotlightTourTexts);

        // [WHEN] Trying to insert an application feature with the same fields as the last version that was inserted
        GuidedExperienceTestLibrary.InsertApplicationFeature(false, Title, ShortTitle,
            Description, ExpectedDuration, ObjectType::Codeunit, ObjectIDToRun);

        VerifyAfterIdenticalInsertion(Code);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertVideo()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        ObjectTypeToRun: Enum "Guided Experience Object Type";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        ManualSetupCategory: Enum "Manual Setup Category";
        SpotlightTourType: Enum "Spotlight Tour Type";
        SpotlightTourTexts: Dictionary of [Enum "Spotlight Tour Text", Text];
        Title: Text[2048];
        ShortTitle: Text[50];
        Description: Text[1024];
        ExpectedDuration: Integer;
        VideoUrl: Text[250];
        Code: Code[300];
    begin
        // [GIVEN] The Guided Experience Item table is empty
        GuidedExperienceItem.DeleteAll();

        PermissionsMock.Set('Guided Exp Edit');

        // [WHEN] Inserting a new video 
        VideoUrl := CopyStr(Any.AlphanumericText(MaxStrLen(VideoUrl)), 1, MaxStrLen(VideoUrl));
        VideoCategory := VideoCategory::Uncategorized;
        GuidedExperienceTestLibrary.InsertVideo(true, Title, ShortTitle, Description,
            ExpectedDuration, VideoUrl, VideoCategory);

        // [THEN] There is exactly one record in the Guided Experience Item table
        Assert.AreEqual(1, GuidedExperienceItem.Count, 'The Guided Experience Item should contain exactly one record');

        // [THEN] The fields of the Guided Experience Item are set correctly
        GuidedExperienceItem.FindFirst();
        Code := 'VIDEO_UNINITIALIZED_0_' + VideoUrl + '_0';
        VerifyGuidedExperienceItemFields(GuidedExperienceItem, Code, 0, ObjectTypeToRun::Uninitialized, 0, '', Title, ShortTitle, Description,
            ExpectedDuration, false, GuidedExperienceType::Video, AssistedSetupGroup::Uncategorized,
            '', VideoUrl, VideoCategory, ManualSetupCategory::Uncategorized, '', SpotlightTourType::None, SpotlightTourTexts);

        // [WHEN] Inserting a new version of the video
        GuidedExperienceTestLibrary.InsertVideo(true, Title, ShortTitle, Description,
            ExpectedDuration, VideoUrl, VideoCategory);

        VerifyAfterNonIdenticalInsertion(Code);

        // [THEN] The fields of the second version of the Guided Experience Item are set correctly
        if GuidedExperienceItem.Get(Code, 1) then;
        VerifyGuidedExperienceItemFields(GuidedExperienceItem, Code, 1, ObjectTypeToRun::Uninitialized, 0, '', Title, ShortTitle, Description,
            ExpectedDuration, false, GuidedExperienceType::Video, AssistedSetupGroup::Uncategorized,
            '', VideoUrl, VideoCategory, ManualSetupCategory::Uncategorized, '', SpotlightTourType::None, SpotlightTourTexts);

        // [WHEN] Trying to insert a video with the same fields as the last version that was inserted
        GuidedExperienceTestLibrary.InsertVideo(false, Title, ShortTitle, Description,
            ExpectedDuration, VideoUrl, VideoCategory);

        VerifyAfterIdenticalInsertion(Code);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertTour()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        ObjectTypeToRun: Enum "Guided Experience Object Type";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        ManualSetupCategory: Enum "Manual Setup Category";
        SpotlightTourType: Enum "Spotlight Tour Type";
        SpotlightTourTexts: Dictionary of [Enum "Spotlight Tour Text", Text];
        Title: Text[2048];
        ShortTitle: Text[50];
        Description: Text[1024];
        ExpectedDuration: Integer;
        ObjectIDToRun: Integer;
        Code: Code[300];
        Keywords: Text[250];
    begin
        // [GIVEN] The Guided Experience Item table is empty
        GuidedExperienceItem.DeleteAll();

        PermissionsMock.Set('Guided Exp Edit');

        // [WHEN] Inserting a new tour
        ObjectIDToRun := Page::"Assisted Setup Wizard";
        GuidedExperienceTestLibrary.InsertTour(true, Title, ShortTitle, Description, ExpectedDuration, ObjectIDToRun);

        // [THEN] There is exactly one record in the Guided Experience Item table
        Assert.AreEqual(1, GuidedExperienceItem.Count, 'The Guided Experience Item should contain exactly one record');

        // [THEN] The fields of the Guided Experience Item are set correctly
        GuidedExperienceItem.FindFirst();
        Code := 'TOUR_PAGE_132610__0';
        VerifyGuidedExperienceItemFields(GuidedExperienceItem, Code, 0, ObjectTypeToRun::Page, ObjectIDToRun, '', Title, ShortTitle, Description,
            ExpectedDuration, false, GuidedExperienceType::Tour, AssistedSetupGroup::Uncategorized,
            '', '', VideoCategory::Uncategorized, ManualSetupCategory::Uncategorized, Keywords, SpotlightTourType::None, SpotlightTourTexts);

        // [WHEN] Inserting a new version of the tour
        GuidedExperienceTestLibrary.InsertTour(true, Title, ShortTitle, Description, ExpectedDuration, ObjectIDToRun);

        VerifyAfterNonIdenticalInsertion(Code);

        // [THEN] The fields of the second version of the Guided Experience Item are set correctly
        if GuidedExperienceItem.Get(Code, 1) then;
        VerifyGuidedExperienceItemFields(GuidedExperienceItem, Code, 1, ObjectTypeToRun::Page, ObjectIDToRun, '', Title, ShortTitle, Description,
            ExpectedDuration, false, GuidedExperienceType::Tour, AssistedSetupGroup::Uncategorized,
            '', '', VideoCategory::Uncategorized, ManualSetupCategory::Uncategorized, Keywords, SpotlightTourType::None, SpotlightTourTexts);

        // [WHEN] Trying to insert a tour with the same fields as the last version that was inserted        
        GuidedExperienceTestLibrary.InsertTour(false, Title, ShortTitle, Description, ExpectedDuration, ObjectIDToRun);

        VerifyAfterIdenticalInsertion(Code);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertSpotlightTour()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        ObjectTypeToRun: Enum "Guided Experience Object Type";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        ManualSetupCategory: Enum "Manual Setup Category";
        SpotlightTourType: Enum "Spotlight Tour Type";
        SpotlightTourTexts: Dictionary of [Enum "Spotlight Tour Text", Text];
        Title: Text[2048];
        ShortTitle: Text[50];
        Description: Text[1024];
        ExpectedDuration: Integer;
        ObjectIDToRun: Integer;
        Code: Code[300];
        Keywords: Text[250];
    begin
        // [GIVEN] The Guided Experience Item table is empty
        GuidedExperienceItem.DeleteAll();

        PermissionsMock.Set('Guided Exp Edit');

        // [WHEN] Inserting a new spotlight tour
        ObjectIDToRun := Page::"Assisted Setup Wizard";
        SpotlightTourType := SpotlightTourType::"Open in Excel";
        GuidedExperienceTestLibrary.InsertSpotlightTour(true, Title, ShortTitle, Description,
            ExpectedDuration, ObjectIDToRun, SpotlightTourType, SpotlightTourTexts);

        // [THEN] There is exactly one record in the Guided Experience Item table
        Assert.AreEqual(1, GuidedExperienceItem.Count, 'The Guided Experience Item should contain exactly one record');

        // [THEN] The fields of the Guided Experience Item are set correctly
        GuidedExperienceItem.FindFirst();
        Code := 'SPOTLIGHT TOUR_PAGE_132610__' + Format(SpotlightTourType.AsInteger());
        VerifyGuidedExperienceItemFields(GuidedExperienceItem, Code, 0, ObjectTypeToRun::Page, ObjectIDToRun, '', Title, ShortTitle, Description,
            ExpectedDuration, false, GuidedExperienceType::"Spotlight Tour", AssistedSetupGroup::Uncategorized,
            '', '', VideoCategory::Uncategorized, ManualSetupCategory::Uncategorized, Keywords, SpotlightTourType, SpotlightTourTexts);

        // [WHEN] Inserting a new version of the spotlight tour
        GuidedExperienceTestLibrary.InsertSpotlightTour(true, Title, ShortTitle, Description,
            ExpectedDuration, ObjectIDToRun, SpotlightTourType, SpotlightTourTexts);

        VerifyAfterNonIdenticalInsertion(Code);

        // [THEN] The fields of the second version of the Guided Experience Item are set correctly
        if GuidedExperienceItem.Get(Code, 1) then;
        VerifyGuidedExperienceItemFields(GuidedExperienceItem, Code, 1, ObjectTypeToRun::Page, ObjectIDToRun, '', Title, ShortTitle, Description,
            ExpectedDuration, false, GuidedExperienceType::"Spotlight Tour", AssistedSetupGroup::Uncategorized,
            '', '', VideoCategory::Uncategorized, ManualSetupCategory::Uncategorized, Keywords, SpotlightTourType, SpotlightTourTexts);

        // [WHEN] Trying to insert a spotlight tour with the same fields as the last version that was inserted       
        GuidedExperienceTestLibrary.InsertSpotlightTour(false, Title, ShortTitle, Description,
            ExpectedDuration, ObjectIDToRun, SpotlightTourType, SpotlightTourTexts);

        VerifyAfterIdenticalInsertion(Code);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestRemoveAssistedSetup()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        ObjectTypeToRun1: ObjectType;
        ObjectTypeToRun2: ObjectType;
        ObjectIDToRun1: Integer;
        ObjectIDToRun2: Integer;
        Title1: Text[2048];
        Title2: Text[2048];
        ShortTitle1: Text[50];
        ShortTitle2: Text[50];
        Description1: Text[1024];
        Description2: Text[1024];
        ExpectedDuration: Integer;
        VideoUrl: Text[250];
        HelpUrl: Text[250];
    begin
        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] The Guided Experience Item table contains 2 assisted setups
        GuidedExperienceItem.DeleteAll();

        ObjectTypeToRun1 := ObjectType::Page;
        ObjectIDToRun1 := Page::"Assisted Setup Wizard";
        AssistedSetupGroup := AssistedSetupGroup::Uncategorized;
        VideoCategory := VideoCategory::Uncategorized;
        GuidedExperienceTestLibrary.InsertAssistedSetup(true, Title1, ShortTitle1, Description1, ExpectedDuration,
            ObjectTypeToRun1, ObjectIDToRun1, AssistedSetupGroup, VideoUrl, VideoCategory, HelpUrl);

        ObjectTypeToRun2 := ObjectType::Page;
        ObjectIDToRun2 := Page::Checklist;
        GuidedExperienceTestLibrary.InsertAssistedSetup(true, Title2, ShortTitle2, Description2, ExpectedDuration,
            ObjectTypeToRun2, ObjectIDToRun2, AssistedSetupGroup, VideoUrl, VideoCategory, HelpUrl);

        // [WHEN] Trying to remove a guided experience item that does not exist
        GuidedExperience.Remove(GuidedExperienceType::"Assisted Setup", ObjectTypeToRun1, Page::"Manual Setup");

        // [THEN] The Guided Experience Item table contains exactly 2 records
        Assert.AreEqual(2, GuidedExperienceItem.Count, 'None of the records should have been deleted.');

        // [WHEN] Removing one of the existing assisted setups
        GuidedExperience.Remove(GuidedExperienceType::"Assisted Setup", ObjectTypeToRun1, ObjectIDToRun1);

        // [THEN] The Guided Experience Item table contains exactly 1 record
        Assert.AreEqual(1, GuidedExperienceItem.Count, 'The Guided Experience Item table should contain exactly 1 record.');

        // [THEN] The fields of the existing record are correct
        GuidedExperienceItem.FindFirst();
        Assert.AreEqual(Title2, GuidedExperienceItem.Title, 'The title is incorrect.');
        Assert.AreEqual(ShortTitle2, GuidedExperienceItem."Short Title", 'The short title is incorrect.');
        Assert.AreEqual(Description2, GuidedExperienceItem.Description, 'The description is incorrect.');
        Assert.AreEqual(ObjectIDToRun2, GuidedExperienceItem."Object ID to Run", 'The object ID is incorrect.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestRemoveManualSetup()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        ManualSetupCategory: Enum "Manual Setup Category";
        ObjectTypeToRun1: ObjectType;
        ObjectTypeToRun2: ObjectType;
        ObjectIDToRun1: Integer;
        ObjectIDToRun2: Integer;
        Title1: Text[2048];
        Title2: Text[2048];
        ShortTitle1: Text[50];
        ShortTitle2: Text[50];
        Description1: Text[1024];
        Description2: Text[1024];
        Keywords: Text[250];
        ExpectedDuration: Integer;
    begin
        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] The Guided Experience Item table contains 2 manual setups
        GuidedExperienceItem.DeleteAll();

        ObjectTypeToRun1 := ObjectType::Codeunit;
        ObjectIDToRun1 := Codeunit::"Checklist Test Codeunit";
        ManualSetupCategory := ManualSetupCategory::Uncategorized;
        GuidedExperienceTestLibrary.InsertManualSetup(true, Title1, ShortTitle1, Description1, ExpectedDuration,
            ObjectTypeToRun1, ObjectIDToRun1, ManualSetupCategory, Keywords);

        ObjectTypeToRun2 := ObjectType::Report;
        ObjectIDToRun2 := Report::"Checklist Test Report";
        GuidedExperienceTestLibrary.InsertManualSetup(true, Title2, ShortTitle2, Description2, ExpectedDuration,
            ObjectTypeToRun2, ObjectIDToRun2, ManualSetupCategory, Keywords);

        // [WHEN] Trying to remove a guided experience item that does not exist
        GuidedExperience.Remove(GuidedExperienceType::"Assisted Setup", ObjectTypeToRun1, ObjectIDToRun1);

        // [THEN] The Guided Experience Item table contains exactly 2 records
        Assert.AreEqual(2, GuidedExperienceItem.Count, 'None of the records should have been deleted.');

        // [WHEN] Removing one of the manual setups
        GuidedExperience.Remove(GuidedExperienceType::"Manual Setup", ObjectTypeToRun1, ObjectIDToRun1);

        // [THEN] The Guided Experience Item table contains exactly 1 record
        Assert.AreEqual(1, GuidedExperienceItem.Count, 'The Guided Experience Item table should contain exactly 1 record.');

        // [THEN] The fields of the existing record are correct
        GuidedExperienceItem.FindFirst();
        Assert.AreEqual(Title2, GuidedExperienceItem.Title, 'The title is incorrect.');
        Assert.AreEqual(ShortTitle2, GuidedExperienceItem."Short Title", 'The short title is incorrect.');
        Assert.AreEqual(Description2, GuidedExperienceItem.Description, 'The description is incorrect.');
        Assert.AreEqual(ObjectIDToRun2, GuidedExperienceItem."Object ID to Run", 'The object ID is incorrect.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestRemoveLink()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        Title1: Text[2048];
        Title2: Text[2048];
        ShortTitle1: Text[50];
        ShortTitle2: Text[50];
        Description1: Text[1024];
        Description2: Text[1024];
        Link1: Text[250];
        Link2: Text[250];
        ExpectedDuration: Integer;
    begin
        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] The Guided Experience Item table contains 2 learn links
        GuidedExperienceItem.DeleteAll();

        Link1 := CopyStr(Any.AlphanumericText(MaxStrLen(Link1)), 1, MaxStrLen(Link1));
        GuidedExperienceTestLibrary.InsertLearnLink(true, Title1, ShortTitle1, Description1, ExpectedDuration, Link1);

        Link2 := CopyStr(Any.AlphanumericText(MaxStrLen(Link2)), 1, MaxStrLen(Link2));
        GuidedExperienceTestLibrary.InsertLearnLink(true, Title2, ShortTitle2, Description2, ExpectedDuration, Link2);

        // [WHEN] Trying to remove a guided experience item that does not exist
        GuidedExperience.Remove(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"Checklist Item Roles");

        // [THEN] The Guided Experience Item table contains exactly 2 records
        Assert.AreEqual(2, GuidedExperienceItem.Count, 'None of the records should have been deleted.');

        // [WHEN] Removing one of the links
        GuidedExperience.Remove(GuidedExperienceType::Learn, Link2);

        // [THEN] The Guided Experience Item table contains exactly 1 record
        Assert.AreEqual(1, GuidedExperienceItem.Count, 'The Guided Experience Item table should contain exactly 1 record.');

        // [THEN] The fields of the existing record are correct
        GuidedExperienceItem.FindFirst();
        Assert.AreEqual(Title1, GuidedExperienceItem.Title, 'The title is incorrect.');
        Assert.AreEqual(ShortTitle1, GuidedExperienceItem."Short Title", 'The short title is incorrect.');
        Assert.AreEqual(Description1, GuidedExperienceItem.Description, 'The description is incorrect.');
        Assert.AreEqual(Link1, GuidedExperienceItem.Link, 'The link is incorrect.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestRemoveApplicationFeature()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        ObjectTypeToRun1: ObjectType;
        ObjectTypeToRun2: ObjectType;
        ObjectIDToRun1: Integer;
        ObjectIDToRun2: Integer;
        Title1: Text[2048];
        Title2: Text[2048];
        ShortTitle1: Text[50];
        ShortTitle2: Text[50];
        Description1: Text[1024];
        Description2: Text[1024];
        ExpectedDuration: Integer;
    begin
        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] The Guided Experience Item table contains 2 application features
        GuidedExperienceItem.DeleteAll();

        ObjectTypeToRun1 := ObjectType::Page;
        ObjectIDToRun1 := Page::"Checklist Administration";
        GuidedExperienceTestLibrary.InsertApplicationFeature(true, Title1, ShortTitle1, Description1,
            ExpectedDuration, ObjectTypeToRun1, ObjectIDToRun1);

        ObjectTypeToRun2 := ObjectType::Report;
        ObjectIDToRun2 := Report::"Checklist Test Report";
        GuidedExperienceTestLibrary.InsertApplicationFeature(true, Title2, ShortTitle2, Description2,
            ExpectedDuration, ObjectTypeToRun2, ObjectIDToRun2);

        // [WHEN] Trying to remove a guided experience item that does not exist
        GuidedExperience.Remove(GuidedExperienceType::"Manual Setup", ObjectTypeToRun1, ObjectIDToRun1);

        // [THEN] The Guided Experience Item table contains exactly 2 records
        Assert.AreEqual(2, GuidedExperienceItem.Count, 'None of the records should have been deleted.');

        // [WHEN] Removing one of the application features
        GuidedExperience.Remove(GuidedExperienceType::"Application Feature", ObjectTypeToRun2, ObjectIDToRun2);

        // [THEN] The Guided Experience Item table contains exactly 1 record
        Assert.AreEqual(1, GuidedExperienceItem.Count, 'The Guided Experience Item table should contain exactly 1 record.');

        // [THEN] The fields of the existing record are correct
        GuidedExperienceItem.FindFirst();
        Assert.AreEqual(Title1, GuidedExperienceItem.Title, 'The title is incorrect.');
        Assert.AreEqual(ShortTitle1, GuidedExperienceItem."Short Title", 'The short title is incorrect.');
        Assert.AreEqual(Description1, GuidedExperienceItem.Description, 'The description is incorrect.');
        Assert.AreEqual(ObjectIDToRun1, GuidedExperienceItem."Object ID to Run", 'The object ID is incorrect.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestRemoveVideo()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        VideoCategory: Enum "Video Category";
        Title1: Text[2048];
        Title2: Text[2048];
        ShortTitle1: Text[50];
        ShortTitle2: Text[50];
        Description1: Text[1024];
        Description2: Text[1024];
        VideoUrl1: Text[250];
        VideoUrl2: Text[250];
        ExpectedDuration: Integer;
    begin
        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] The Guided Experience Item table contains 2 video urls
        GuidedExperienceItem.DeleteAll();

        VideoCategory := VideoCategory::Uncategorized;
        VideoUrl1 := CopyStr(Any.AlphanumericText(MaxStrLen(VideoUrl1)), 1, MaxStrLen(VideoUrl1));
        GuidedExperienceTestLibrary.InsertVideo(true, Title1, ShortTitle1,
            Description1, ExpectedDuration, VideoUrl1, VideoCategory);

        VideoUrl2 := CopyStr(Any.AlphanumericText(MaxStrLen(VideoUrl2)), 1, MaxStrLen(VideoUrl2));
        GuidedExperienceTestLibrary.InsertVideo(true, Title2, ShortTitle2,
            Description2, ExpectedDuration, VideoUrl2, VideoCategory);

        // [WHEN] Trying to remove a guided experience item that does not exist
        GuidedExperience.Remove(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"Assisted Setup");

        // [THEN] The Guided Experience Item table contains exactly 2 records
        Assert.AreEqual(2, GuidedExperienceItem.Count, 'None of the records should have been deleted.');

        // [WHEN] Removing one of the video urls
        GuidedExperience.Remove(GuidedExperienceType::Video, VideoUrl2);

        // [THEN] The Guided Experience Item table contains exactly 1 record
        Assert.AreEqual(1, GuidedExperienceItem.Count, 'The Guided Experience Item table should contain exactly 1 record.');

        // [THEN] The fields of the existing record are correct
        GuidedExperienceItem.FindFirst();
        Assert.AreEqual(Title1, GuidedExperienceItem.Title, 'The title is incorrect.');
        Assert.AreEqual(ShortTitle1, GuidedExperienceItem."Short Title", 'The short title is incorrect.');
        Assert.AreEqual(Description1, GuidedExperienceItem.Description, 'The description is incorrect.');
        Assert.AreEqual(VideoUrl1, GuidedExperienceItem."Video Url", 'The video URL is incorrect.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestRemoveTour()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        ObjectIDToRun1: Integer;
        ObjectIDToRun2: Integer;
        Title1: Text[2048];
        Title2: Text[2048];
        ShortTitle1: Text[50];
        ShortTitle2: Text[50];
        Description1: Text[1024];
        Description2: Text[1024];
        ExpectedDuration: Integer;
    begin
        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] The Guided Experience Item table contains 2 tours
        GuidedExperienceItem.DeleteAll();

        ObjectIDToRun1 := Page::"Checklist Administration";
        GuidedExperienceTestLibrary.InsertTour(true, Title1, ShortTitle1, Description1, ExpectedDuration, ObjectIDToRun1);

        ObjectIDToRun2 := Page::"Assisted Setup Wizard";
        GuidedExperienceTestLibrary.InsertTour(true, Title2, ShortTitle2, Description2, ExpectedDuration, ObjectIDToRun2);

        // [WHEN] Trying to remove a guided experience item that does not exist
        GuidedExperience.Remove(GuidedExperienceType::Tour, ObjectType::Codeunit, ObjectIDToRun1);

        // [THEN] The Guided Experience Item table contains exactly 2 records
        Assert.AreEqual(2, GuidedExperienceItem.Count, 'None of the records should have been deleted.');

        // [WHEN] Removing one of the tours
        GuidedExperience.Remove(GuidedExperienceType::Tour, ObjectType::Page, ObjectIDToRun2);

        // [THEN] The Guided Experience Item table contains exactly 1 record
        Assert.AreEqual(1, GuidedExperienceItem.Count, 'The Guided Experience Item table should contain exactly 1 record.');

        // [THEN] The fields of the existing record are correct
        GuidedExperienceItem.FindFirst();
        Assert.AreEqual(Title1, GuidedExperienceItem.Title, 'The title is incorrect.');
        Assert.AreEqual(ShortTitle1, GuidedExperienceItem."Short Title", 'The short title is incorrect.');
        Assert.AreEqual(Description1, GuidedExperienceItem.Description, 'The description is incorrect.');
        Assert.AreEqual(ObjectIDToRun1, GuidedExperienceItem."Object ID to Run", 'The object ID is incorrect.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestRemoveSpotlightTour()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        SpotlightTourText: Record "Spotlight Tour Text";
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        SpotlightTourType: Enum "Spotlight Tour Type";
        SpotlightTourTexts: Dictionary of [Enum "Spotlight Tour Text", Text];
        ObjectIDToRun1: Integer;
        ObjectIDToRun2: Integer;
        Title1: Text[2048];
        Title2: Text[2048];
        ShortTitle1: Text[50];
        ShortTitle2: Text[50];
        Description1: Text[1024];
        Description2: Text[1024];
        ExpectedDuration: Integer;
    begin
        PermissionsMock.Set('Guided Exp Edit');

        // [GIVEN] The Guided Experience Item table contains 2 spotlight tours
        GuidedExperienceItem.DeleteAll();
        SpotlightTourText.DeleteAll();

        ObjectIDToRun1 := Page::"Checklist Administration";
        SpotlightTourType := SpotlightTourType::"Share to Teams";
        GuidedExperienceTestLibrary.InsertSpotlightTour(true, Title1, ShortTitle1, Description1,
            ExpectedDuration, ObjectIDToRun1, SpotlightTourType, SpotlightTourTexts);

        ObjectIDToRun2 := Page::"Assisted Setup Wizard";
        GuidedExperienceTestLibrary.InsertSpotlightTour(true, Title2, ShortTitle2, Description2,
            ExpectedDuration, ObjectIDToRun2, SpotlightTourType, SpotlightTourTexts);

        // [WHEN] Trying to remove a guided experience item that does not exist
        GuidedExperience.Remove(GuidedExperienceType::"Spotlight Tour", ObjectType::Report, ObjectIDToRun1, SpotlightTourType);

        // [THEN] The Guided Experience Item table contains exactly 2 records and the spotlight tour texts 8
        Assert.AreEqual(2, GuidedExperienceItem.Count, 'None of the records should have been deleted.');
        Assert.AreEqual(8, SpotlightTourText.Count, 'None of the spotlight tour texts should have been deleted.');

        // [WHEN] Removing one of the spotlight tours
        GuidedExperience.Remove(GuidedExperienceType::"Spotlight Tour", ObjectType::Page, ObjectIDToRun1, SpotlightTourType);

        // [THEN] The Guided Experience Item table contains exactly 1 record
        Assert.AreEqual(1, GuidedExperienceItem.Count, 'The Guided Experience Item table should contain exactly 1 record.');

        // [THEN] The fields of the existing record are correct
        GuidedExperienceItem.FindFirst();
        Assert.AreEqual(Title2, GuidedExperienceItem.Title, 'The title is incorrect.');
        Assert.AreEqual(ShortTitle2, GuidedExperienceItem."Short Title", 'The short title is incorrect.');
        Assert.AreEqual(Description2, GuidedExperienceItem.Description, 'The description is incorrect.');
        Assert.AreEqual(ObjectIDToRun2, GuidedExperienceItem."Object ID to Run", 'The object ID is incorrect.');
        Assert.AreEqual(SpotlightTourType, GuidedExperienceItem."Spotlight Tour Type", 'The spotlight tour type is incorrect.');

        // [THEN] The spotlight tours for the correct item have been deleted
        Assert.AreEqual(4, SpotlightTourText.Count, 'The number of spotlight tour texts is incorrect.');
        SpotlightTourText.SetRange("Guided Experience Item Code", 'SPOTLIGHT TOUR_PAGE_132610__' + Format(SpotlightTourType.AsInteger()));
        SpotlightTourText.SetRange("Guided Experience Item Version", 0);
        Assert.AreEqual(4, SpotlightTourText.Count, 'The spotlight tour texts have incorrect keys.');
    end;

    local procedure VerifyGuidedExperienceItemFields(GuidedExperienceItem: Record "Guided Experience Item"; Code: Code[300]; Version: Integer; ObjectTypeToRun: Enum "Guided Experience Object Type"; ObjectID: Integer; Link: Text[250]; Title: Text[2048]; ShortTitle: Text[2048]; Description: Text[1024]; ExpectedDuration: Integer; Completed: Boolean; GuidedExperienceType: Enum "Guided Experience Type"; AssistedSetupGroup: Enum "Assisted Setup Group"; HelpUrl: Text[250]; VideoUrl: Text[250]; VideoCategory: Enum "Video Category"; ManualSetupCategory: Enum "Manual Setup Category"; Keywords: Text[250]; SpotlightTourType: Enum "Spotlight Tour Type"; SpotlightTourTexts: Dictionary of [Enum "Spotlight Tour Text", Text])
    begin
        Assert.AreEqual(Code, GuidedExperienceItem.Code, 'The Code field of the Guided Experience Item is incorrect.');
        Assert.AreEqual(Version, GuidedExperienceItem.Version, 'The Version field of the Guided Experience Item is incorrect.');
        Assert.AreEqual(ObjectTypeToRun, GuidedExperienceItem."Object Type to Run", 'The Object Type to Run field of the Guided Experience Item is incorrect.');
        Assert.AreEqual(ObjectID, GuidedExperienceItem."Object ID to Run", 'The Object ID to Run field of the Guided Experience Item is incorrect.');
        Assert.AreEqual(Link, GuidedExperienceItem.Link, 'The Link field of the Guided Experience Item is incorrect.');
        Assert.AreEqual(Title, GuidedExperienceItem.Title, 'The Title field of the Guided Experience Item is incorrect.');
        Assert.AreEqual(ShortTitle, GuidedExperienceItem."Short Title", 'The Short Title field of the Guided Experience Item is incorrect.');
        Assert.AreEqual(Description, GuidedExperienceItem.Description, 'The Description field of the Guided Experience Item is incorrect.');
        Assert.AreEqual(ExpectedDuration, GuidedExperienceItem."Expected Duration", 'The Expected Duration field of the Guided Experience Item is incorrect.');
        Assert.AreEqual(Completed, GuidedExperienceItem.Completed, 'The Completed field of the Guided Experience Item is incorrect.');
        Assert.AreEqual(GuidedExperienceType, GuidedExperienceItem."Guided Experience Type", 'The Guided Experience Type field of the Guided Experience Item is incorrect.');
        Assert.AreEqual(AssistedSetupGroup, GuidedExperienceItem."Assisted Setup Group", 'The Assisted Setup Group field of the Guided Experience Item is incorrect.');
        Assert.AreEqual(HelpUrl, GuidedExperienceItem."Help Url", 'The Help Url field of the Guided Experience Item is incorrect.');
        Assert.AreEqual(VideoUrl, GuidedExperienceItem."Video Url", 'The Video Url field of the Guided Experience Item is incorrect.');
        Assert.AreEqual(VideoCategory, GuidedExperienceItem."Video Category", 'The Video Category field of the Guided Experience Item is incorrect.');
        Assert.AreEqual(ManualSetupCategory, GuidedExperienceItem."Manual Setup Category", 'The Manual Setup Category field of the Guided Experience Item is incorrect.');
        Assert.AreEqual(Keywords, GuidedExperienceItem.Keywords, 'The Keywords field of the Guided Experience Item is incorrect.');
        Assert.AreEqual(SpotlightTourType, GuidedExperienceItem."Spotlight Tour Type", 'The Spotlight Tour Type of the Guided Experience Item is incorrect.');

        VerifySpotlightTourTexts(SpotlightTourTexts, GuidedExperienceItem.Code, GuidedExperienceItem.Version);
    end;

    local procedure VerifySpotlightTourTexts(SpotlightTourTexts: Dictionary of [Enum "Spotlight Tour Text", Text]; Code: Code[300]; Version: Integer)
    var
        SpotlightTourText: Record "Spotlight Tour Text";
        SpotlightTourTextEnum: Enum "Spotlight Tour Text";
    begin
        SpotlightTourText.SetRange("Guided Experience Item Code", Code);
        SpotlightTourText.SetRange("Guided Experience Item Version", Version);
        foreach SpotlightTourTextEnum in SpotlightTourTexts.Keys() do begin
            SpotlightTourText.SetRange("Spotlight Tour Step", SpotlightTourTextEnum);
            Assert.IsTrue(SpotlightTourText.FindFirst(), 'The record for the key ' + Format(SpotlightTourTextEnum) + ' could not be found in the database');
            Assert.AreEqual(SpotlightTourTexts.Get(SpotlightTourTextEnum), SpotlightTourText."Spotlight Tour Text",
                'The text for the ' + Format(SpotlightTourTextEnum) + 'is incorrect.');
        end;
    end;

    local procedure VerifyAfterNonIdenticalInsertion(Code: Code[300])
    var
        GuidedExperienceItem: Record "Guided Experience Item";
    begin
        // [THEN] There are 2 records in the Guided Experience Item table
        Assert.AreEqual(2, GuidedExperienceItem.Count, 'The Guided Experience Item should contain two records');

        // [THEN] Both of the records should have the same code
        GuidedExperienceItem.SetRange(Code, Code);
        Assert.AreEqual(2, GuidedExperienceItem.Count, 'The Guided Experience Item should contain two records with the same Code');
    end;

    local procedure VerifyAfterIdenticalInsertion(Code: Code[300])
    var
        GuidedExperienceItem: Record "Guided Experience Item";
    begin
        // [THEN] The Guided Experience Item table does not contain a new record
        Assert.AreEqual(2, GuidedExperienceItem.Count, 'The Guided Experience Item should not contain a new version of the object.');

        // [THEN] There shouln't be a record with version 2 in the Guided Experience Item table
        Assert.IsFalse(GuidedExperienceItem.Get(Code, 2), 'The Guided Experience Item should not contain a new version of the object.');
    end;
}