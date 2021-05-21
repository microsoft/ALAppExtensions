codeunit 132594 "Guided Experience Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertAssistedSetup()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        GuidedExperience: Codeunit "Guided Experience";
        ObjectTypeToRun: Enum "Guided Experience Object Type";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        ManualSetupCategory: Enum "Manual Setup Category";
        ModuleInfo: ModuleInfo;
        Title: Text[2048];
        ShortTitle: Text[30];
        Description: Text[1024];
        ExpectedDuration: Integer;
        PageID: Integer;
        Code: Code[300];
        VideoUrl: Text[250];
        HelpUrl: Text[250];
    begin
        // [GIVEN] The Guided Experience Item table is empty
        GuidedExperienceItem.DeleteAll();

        // [WHEN] Inserting a new assisted setup
        Title := 'This is the title of the guided experience item';
        ShortTitle := 'Short title';
        Description := 'Description blah blah';
        ExpectedDuration := 5;
        PageID := 1801;
        AssistedSetupGroup := AssistedSetupGroup::Uncategorized;
        VideoUrl := 'Video Url ...';
        HelpUrl := 'Help';
        GuidedExperience.InsertAssistedSetup(Title, ShortTitle, Description, ExpectedDuration, ObjectType::Page,
            PageID, AssistedSetupGroup, VideoUrl, VideoCategory::Uncategorized, HelpUrl);

        // [THEN] There is exactly one record in the Guided Experience Item table
        Assert.AreEqual(1, GuidedExperienceItem.Count, 'The Guided Experience Item should contain exactly one record');

        // [THEN] The fields of the Guided Experience Item are set correctly
        if GuidedExperienceItem.FindFirst() then;
        NavApp.GetCurrentModuleInfo(ModuleInfo);
        Code := 'ASSISTED SETUP_PAGE_1801_';
        VerifyGuidedExperienceItemFields(GuidedExperienceItem, Code, 0, ObjectTypeToRun::Page, PageID, '', Title, ShortTitle, Description,
            ExpectedDuration, ModuleInfo.Id, CopyStr(ModuleInfo.Name, 1, 250), false, GuidedExperienceType::"Assisted Setup", AssistedSetupGroup,
            HelpUrl, VideoUrl, VideoCategory::Uncategorized, ManualSetupCategory::Uncategorized, '');

        // [WHEN] Inserting a new version of the assisted setup page
        Title := 'Title different version';
        ShortTitle := 'Another short title';
        Description := 'Description version 2';
        ExpectedDuration := 10;
        AssistedSetupGroup := AssistedSetupGroup::Uncategorized;
        VideoUrl := 'Video Url ... 2';
        HelpUrl := 'Help 2';
        GuidedExperience.InsertAssistedSetup(Title, ShortTitle, Description, ExpectedDuration, ObjectType::Page,
            PageID, AssistedSetupGroup, VideoUrl, VideoCategory::Uncategorized, HelpUrl);

        // [THEN] There are 2 records in the Guided Experience Item table
        Assert.AreEqual(2, GuidedExperienceItem.Count, 'The Guided Experience Item should contain two records');

        // [THEN] Both of the records should have the same code
        GuidedExperienceItem.SetRange(Code, Code);
        Assert.AreEqual(2, GuidedExperienceItem.Count, 'The Guided Experience Item should contain two records with the same Code');

        // [THEN] The fields of the second version of the Guided Experience Item are set correctly
        if GuidedExperienceItem.Get(Code, 1) then;
        VerifyGuidedExperienceItemFields(GuidedExperienceItem, Code, 1, ObjectTypeToRun::Page, PageID, '', Title, ShortTitle, Description,
            ExpectedDuration, ModuleInfo.Id, CopyStr(ModuleInfo.Name, 1, 250), false, GuidedExperienceType::"Assisted Setup", AssistedSetupGroup,
            HelpUrl, VideoUrl, VideoCategory::Uncategorized, ManualSetupCategory::Uncategorized, '');

        // [WHEN] Trying to insert an assisted setup page with the same fields as the last version that was inserted
        GuidedExperience.InsertAssistedSetup(Title, ShortTitle, Description, ExpectedDuration, ObjectType::Page,
            PageID, AssistedSetupGroup, VideoUrl, VideoCategory::Uncategorized, HelpUrl);

        // [THEN] The Guided Experience Item table does not contain a new record
        Assert.AreEqual(2, GuidedExperienceItem.Count, 'The Guided Experience Item should not contain a new version of the assisted setup page');

        // [THEN] There shouln't be a record with version 2 in the Guided Experience Item table
        Assert.IsFalse(GuidedExperienceItem.Get(Code, 2), 'The Guided Experience Item should not contain a new version of the assisted setup page');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertManualSetup()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        GuidedExperience: Codeunit "Guided Experience";
        ObjectTypeToRun: Enum "Guided Experience Object Type";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        ManualSetupCategory: Enum "Manual Setup Category";
        ModuleInfo: ModuleInfo;
        Title: Text[2048];
        ShortTitle: Text[30];
        Description: Text[1024];
        ExpectedDuration: Integer;
        PageID: Integer;
        Code: Code[300];
        Keywords: Text[250];
    begin
        // [GIVEN] The Guided Experience Item table is empty
        GuidedExperienceItem.DeleteAll();

        // [WHEN] Inserting a new manual setup
        Title := 'This is the title of the guided experience item';
        ShortTitle := 'Short title';
        Description := 'Description blah blah';
        ExpectedDuration := 5;
        PageID := 1801;
        Keywords := 'Manual Setup';
        GuidedExperience.InsertManualSetup(Title, ShortTitle, Description, ExpectedDuration, ObjectType::Page, PageID, ManualSetupCategory::Uncategorized, Keywords);

        // [THEN] There is exactly one record in the Guided Experience Item table
        Assert.AreEqual(1, GuidedExperienceItem.Count, 'The Guided Experience Item should contain exactly one record');

        // [THEN] The fields of the Guided Experience Item are set correctly
        if GuidedExperienceItem.FindFirst() then;
        NavApp.GetCurrentModuleInfo(ModuleInfo);
        Code := 'MANUAL SETUP_PAGE_1801_';
        VerifyGuidedExperienceItemFields(GuidedExperienceItem, Code, 0, ObjectTypeToRun::Page, PageID, '', Title, ShortTitle, Description,
            ExpectedDuration, ModuleInfo.Id, CopyStr(ModuleInfo.Name, 1, 250), false, GuidedExperienceType::"Manual Setup", AssistedSetupGroup::Uncategorized,
            '', '', VideoCategory::Uncategorized, ManualSetupCategory::Uncategorized, Keywords);

        // [WHEN] Inserting a new version of the manual setup page
        Title := 'Title different version';
        ShortTitle := 'Another short title';
        Description := 'Description version 2';
        ExpectedDuration := 10;
        Keywords := 'Manual Setup, Manual Setup 2';
        GuidedExperience.InsertManualSetup(Title, ShortTitle, Description, ExpectedDuration, ObjectType::Page, PageID, ManualSetupCategory::Uncategorized, Keywords);

        // [THEN] There are 2 records in the Guided Experience Item table
        Assert.AreEqual(2, GuidedExperienceItem.Count, 'The Guided Experience Item should contain two records');

        // [THEN] Both of the records should have the same code
        GuidedExperienceItem.SetRange(Code, Code);
        Assert.AreEqual(2, GuidedExperienceItem.Count, 'The Guided Experience Item should contain two records with the same Code');

        // [THEN] The fields of the second version of the Guided Experience Item are set correctly
        if GuidedExperienceItem.Get(Code, 1) then;
        VerifyGuidedExperienceItemFields(GuidedExperienceItem, Code, 1, ObjectTypeToRun::Page, PageID, '', Title, ShortTitle, Description,
            ExpectedDuration, ModuleInfo.Id, CopyStr(ModuleInfo.Name, 1, 250), false, GuidedExperienceType::"Manual Setup", AssistedSetupGroup::Uncategorized,
            '', '', VideoCategory::Uncategorized, ManualSetupCategory::Uncategorized, Keywords);

        // [WHEN] Trying to insert a manual setup page with the same fields as the last version that was inserted
        GuidedExperience.InsertManualSetup(Title, ShortTitle, Description, ExpectedDuration, ObjectType::Page, PageID, ManualSetupCategory::Uncategorized, Keywords);

        // [THEN] The Guided Experience Item table does not contain a new record
        Assert.AreEqual(2, GuidedExperienceItem.Count, 'The Guided Experience Item should not contain a new version of the manual setup page');

        // [THEN] There shouln't be a record with version 2 in the Guided Experience Item table
        Assert.IsFalse(GuidedExperienceItem.Get(Code, 2), 'The Guided Experience Item should not contain a new version of the manual setup page');
    end;

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
        ModuleInfo: ModuleInfo;
        Title: Text[2048];
        ShortTitle: Text[30];
        Description: Text[1024];
        ExpectedDuration: Integer;
        PageID: Integer;
        Code: Code[300];
    begin
        // [GIVEN] The Guided Experience Item table is empty
        GuidedExperienceItem.DeleteAll();

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
        NavApp.GetCurrentModuleInfo(ModuleInfo);
        Code := 'LEARN_PAGE_1801_';
        VerifyGuidedExperienceItemFields(GuidedExperienceItem, Code, 0, ObjectTypeToRun::Page, PageID, '', Title, ShortTitle, Description,
            ExpectedDuration, ModuleInfo.Id, CopyStr(ModuleInfo.Name, 1, 250), false, GuidedExperienceType::Learn, AssistedSetupGroup::Uncategorized,
            '', '', VideoCategory::Uncategorized, ManualSetupCategory::Uncategorized, '');

        // [WHEN] Inserting a new version of the learn page
        Title := 'Title different version';
        ShortTitle := 'Another short title';
        Description := 'Description version 2';
        ExpectedDuration := 10;
        GuidedExperience.InsertLearnPage(Title, ShortTitle, Description, ExpectedDuration, PageID);

        // [THEN] There are 2 records in the Guided Experience Item table
        Assert.AreEqual(2, GuidedExperienceItem.Count, 'The Guided Experience Item should contain two records');

        // [THEN] Both of the records should have the same code
        GuidedExperienceItem.SetRange(Code, Code);
        Assert.AreEqual(2, GuidedExperienceItem.Count, 'The Guided Experience Item should contain two records with the same Code');

        // [THEN] The fields of the second version of the Guided Experience Item are set correctly
        if GuidedExperienceItem.Get(Code, 1) then;
        VerifyGuidedExperienceItemFields(GuidedExperienceItem, Code, 1, ObjectTypeToRun::Page, PageID, '', Title, ShortTitle, Description,
            ExpectedDuration, ModuleInfo.Id, CopyStr(ModuleInfo.Name, 1, 250), false, GuidedExperienceType::Learn, AssistedSetupGroup::Uncategorized,
            '', '', VideoCategory::Uncategorized, ManualSetupCategory::Uncategorized, '');

        // [WHEN] Trying to insert a learn page with the same fields as the last version that was inserted
        GuidedExperience.InsertLearnPage(Title, ShortTitle, Description, ExpectedDuration, PageID);

        // [THEN] The Guided Experience Item table does not contain a new record
        Assert.AreEqual(2, GuidedExperienceItem.Count, 'The Guided Experience Item should not contain a new version of the learn page');

        // [THEN] There shouln't be a record with version 2 in the Guided Experience Item table
        Assert.IsFalse(GuidedExperienceItem.Get(Code, 2), 'The Guided Experience Item should not contain a new version of the learn page');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertLearnLink()
    var
        GuidedExperienceItem: Record "Guided Experience Item";
        GuidedExperience: Codeunit "Guided Experience";
        ObjectTypeToRun: Enum "Guided Experience Object Type";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        ManualSetupCategory: Enum "Manual Setup Category";
        ModuleInfo: ModuleInfo;
        Title: Text[2048];
        ShortTitle: Text[30];
        Description: Text[1024];
        ExpectedDuration: Integer;
        Link: Text[250];
        Code: Code[300];
    begin
        // [GIVEN] The Guided Experience Item table is empty
        GuidedExperienceItem.DeleteAll();

        // [WHEN] Inserting a new learn link
        Title := 'This is the title of the guided experience item';
        ShortTitle := 'Short title';
        Description := 'Description blah blah';
        ExpectedDuration := 5;
        Link := 'Some random link';
        GuidedExperience.InsertLearnLink(Title, ShortTitle, Description, ExpectedDuration, Link);

        // [THEN] There is exactly one record in the Guided Experience Item table
        Assert.AreEqual(1, GuidedExperienceItem.Count, 'The Guided Experience Item should contain exactly one record');

        // [THEN] The fields of the Guided Experience Item are set correctly
        if GuidedExperienceItem.FindFirst() then;
        NavApp.GetCurrentModuleInfo(ModuleInfo);
        Code := 'LEARN_UNINITIALIZED_0_' + Link;
        VerifyGuidedExperienceItemFields(GuidedExperienceItem, Code, 0, ObjectTypeToRun::Uninitialized, 0, Link, Title, ShortTitle, Description,
            ExpectedDuration, ModuleInfo.Id, CopyStr(ModuleInfo.Name, 1, 250), false, GuidedExperienceType::Learn, AssistedSetupGroup::Uncategorized,
            '', '', VideoCategory::Uncategorized, ManualSetupCategory::Uncategorized, '');

        // [WHEN] Inserting a new version of the learn link
        Title := 'Title different version';
        ShortTitle := 'Another short title';
        Description := 'Description version 2';
        ExpectedDuration := 10;
        GuidedExperience.InsertLearnLink(Title, ShortTitle, Description, ExpectedDuration, Link);

        // [THEN] There are 2 records in the Guided Experience Item table
        Assert.AreEqual(2, GuidedExperienceItem.Count, 'The Guided Experience Item should contain two records');

        // [THEN] Both of the records should have the same code
        GuidedExperienceItem.SetRange(Code, Code);
        Assert.AreEqual(2, GuidedExperienceItem.Count, 'The Guided Experience Item should contain two records with the same Code');

        // [THEN] The fields of the second version of the Guided Experience Item are set correctly
        if GuidedExperienceItem.Get(Code, 1) then;
        VerifyGuidedExperienceItemFields(GuidedExperienceItem, Code, 1, ObjectTypeToRun::Uninitialized, 0, Link, Title, ShortTitle, Description,
            ExpectedDuration, ModuleInfo.Id, CopyStr(ModuleInfo.Name, 1, 250), false, GuidedExperienceType::Learn, AssistedSetupGroup::Uncategorized,
            '', '', VideoCategory::Uncategorized, ManualSetupCategory::Uncategorized, '');

        // [WHEN] Trying to insert a learn link with the same fields as the last version that was inserted
        GuidedExperience.InsertLearnLink(Title, ShortTitle, Description, ExpectedDuration, Link);

        // [THEN] The Guided Experience Item table does not contain a new record
        Assert.AreEqual(2, GuidedExperienceItem.Count, 'The Guided Experience Item should not contain a new version of the learn link');

        // [THEN] There shouln't be a record with version 2 in the Guided Experience Item table
        Assert.IsFalse(GuidedExperienceItem.Get(Code, 2), 'The Guided Experience Item should not contain a new version of the learn link');
    end;

    local procedure VerifyGuidedExperienceItemFields(GuidedExperienceItem: Record "Guided Experience Item"; Code: Code[300]; Version: Integer; ObjectTypeToRun: Enum "Guided Experience Object Type"; ObjectID: Integer; Link: Text[250]; Title: Text[2048]; ShortTitle: Text[2048]; Description: Text[1024]; ExpectedDuration: Integer; Extension: Guid; ExtensionName: Text[250]; Completed: Boolean; GuidedExperienceType: Enum "Guided Experience Type"; AssistedSetupGroup: Enum "Assisted Setup Group"; HelpUrl: Text[250]; VideoUrl: Text[250]; VideoCategory: Enum "Video Category"; ManualSetupCategory: Enum "Manual Setup Category"; Keywords: Text[250])
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
        Assert.AreEqual(Extension, GuidedExperienceItem."Extension ID", 'The Extension field of the Guided Experience Item is incorrect.');
        Assert.AreEqual(Completed, GuidedExperienceItem.Completed, 'The Completed field of the Guided Experience Item is incorrect.');
        Assert.AreEqual(GuidedExperienceType, GuidedExperienceItem."Guided Experience Type", 'The Guided Experience Type field of the Guided Experience Item is incorrect.');
        Assert.AreEqual(AssistedSetupGroup, GuidedExperienceItem."Assisted Setup Group", 'The Assisted Setup Group field of the Guided Experience Item is incorrect.');
        Assert.AreEqual(HelpUrl, GuidedExperienceItem."Help Url", 'The Help Url field of the Guided Experience Item is incorrect.');
        Assert.AreEqual(VideoUrl, GuidedExperienceItem."Video Url", 'The Video Url field of the Guided Experience Item is incorrect.');
        Assert.AreEqual(VideoCategory, GuidedExperienceItem."Video Category", 'The Video Category field of the Guided Experience Item is incorrect.');
        Assert.AreEqual(ManualSetupCategory, GuidedExperienceItem."Manual Setup Category", 'The Manual Setup Category field of the Guided Experience Item is incorrect.');
        Assert.AreEqual(Keywords, GuidedExperienceItem.Keywords, 'The Keywords field of the Guided Experience Item is incorrect.');

        GuidedExperienceItem.CalcFields("Extension Name");
        Assert.AreEqual(ExtensionName, GuidedExperienceItem."Extension Name", 'The Extension Name field of the Guided Experience Item is incorrect.');
    end;
}