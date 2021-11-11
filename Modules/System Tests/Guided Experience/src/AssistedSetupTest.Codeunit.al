// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132586 "Assisted Setup Test"
{
    EventSubscriberInstance = Manual;
    SingleInstance = true;
    Subtype = Test;

    var
        LibraryAssert: Codeunit "Library Assert";
        AssistedSetupTest: Codeunit "Assisted Setup Test";
        PermissionsMock: Codeunit "Permissions Mock";
        LastPageIDRun: Integer;
        NonExistingPageID: Integer;

    [Test]
    [HandlerFunctions('MySetupTestPageHandler,OtherSetupTestPageHandler')]
    procedure TestAssistedSetupsAreAdded()
    var
        AssistedSetup: TestPage "Assisted Setup";
        Translation: TestPage Translation;
    begin
        PermissionsMock.Set('Guided Exp Edit');

        Initialize();

        // [GIVEN] Subscribers are registered
        if BindSubscription(AssistedSetupTest) then;

        // [WHEN] The subscribers are run by opening the assisted setup page
        AssistedSetup.OpenView();

        // [THEN] Two setups exist in 4 lines
        AssistedSetup.First(); // the first group - WithLinks
        AssistedSetup.Name.AssertEquals('WithLinks');
        AssistedSetup.Completed.AssertEquals(false);
        AssistedSetup.Help.AssertEquals('');

        AssistedSetup.Expand(true);

        AssistedSetup.Next();
        AssistedSetup.Name.AssertEquals('English translation');
        AssistedSetup.Completed.AssertEquals(false);
        AssistedSetup.Help.AssertEquals('Read');

        AssistedSetup.Next(); // the second group - WithoutLinks
        AssistedSetup.Name.AssertEquals('WithoutLinks');
        AssistedSetup.Completed.AssertEquals(false);
        AssistedSetup.Help.AssertEquals('');

        AssistedSetup.Expand(true);

        AssistedSetup.Next();
        AssistedSetup.Name.AssertEquals('Other Assisted Setup Test Page');
        AssistedSetup.Completed.AssertEquals(false);
        AssistedSetup.Help.AssertEquals('');

        // [WHEN] Start is invoked on the first wizard
        AssistedSetup.First();
        AssistedSetup.Next();
        LastPageIDRun := 0;
        AssistedSetup."Start Setup".Invoke();

        // [THEN] Check the last ID run based on the subscriber
        LibraryAssert.AreEqual(Page::"My Assisted Setup Test Page", LastPageIDRun, 'First wizard did not run.');

        // [THEN] Second wizard is not completed
        AssistedSetup.Completed.AssertEquals(false);

        // [WHEN] Translated Name clicked
        Translation.Trap();
        AssistedSetup.TranslatedName.DrillDown();

        // [THEN] Translation page opens and caught by the trap above.
        Translation.LanguageName.AssertEquals('English (United States)');
        Translation.Close();

        // [WHEN] Start is invoked on the second wizard
        AssistedSetup.Next();
        AssistedSetup.Next();
        LastPageIDRun := 0;
        AssistedSetup."Start Setup".Invoke();

        // [THEN] Check the last ID run based on the subscriber
        LibraryAssert.AreEqual(Page::"Other Assisted Setup Test Page", LastPageIDRun, 'Second wizard did not run.');
        // [THEN] First wizard is completed
        AssistedSetup.Completed.AssertEquals(true);

        // [WHEN] Completed wizard is run again
        AssistedSetup."Start Setup".Invoke();

        // [THEN] As subscriber sets Handled = true, nothing happens
    end;

    [Test]
    procedure TestAssistedSetupShowsUpOnOpenRoleBasedSetupExperience()
    var
        SystemActionTriggers: Codeunit "System Action Triggers";
        AssistedSetup: TestPage "Assisted Setup";
    begin
        PermissionsMock.Set('Guided Exp Edit');
        Initialize();

        // [GIVEN] Subscribers are not registered
        UnbindSubscription(AssistedSetupTest);

        // [WHEN] system action OpenRoleBasedSetupExperience is triggered
        AssistedSetup.Trap();
        SystemActionTriggers.OpenRoleBasedSetupExperience();

        // [THEN] Assisted setup is opened
        AssistedSetup.Close();
    end;

    [Test]
    procedure TestAssistedSetupNotShownIfHandledOnBeforeOpenRoleBasedSetupExperience()
    var
        SystemActionTriggers: Codeunit "System Action Triggers";
    begin
        Initialize();

        // [GIVEN] Subscribers are registered
        if BindSubscription(AssistedSetupTest) then;

        // [WHEN] system action OpenRoleBasedSetupExperience is triggered
        SystemActionTriggers.OpenRoleBasedSetupExperience();

        // [THEN] Assisted setup is not opened
    end;

    [Test]
    [HandlerFunctions('AssistedSetupPageHandler_ChecksCompletedHelp')]
    procedure TestAssistedSetupsShowUpOnFilteredView()
    var
        GuidedExperience: Codeunit "Guided Experience";
        AssistedSetupTestLibrary: Codeunit "Assisted Setup Test Library";
        AssistedSetupGroup: Enum "Assisted Setup Group";
    begin
        PermissionsMock.Set('Guided Exp Edit');
        Initialize();

        // [GIVEN] Subscribers are registered
        if BindSubscription(AssistedSetupTest) then;

        // [WHEN] The page is opened with filtered view
        GuidedExperience.OpenAssistedSetup(AssistedSetupGroup::WithoutLinks);

        // [THEN] Run within the modal form handler

        // [WHEN] Setup is set to be Completed 
        AssistedSetupTestLibrary.SetStatusToCompleted(Page::"Other Assisted Setup Test Page");

        // [WHEN] Reset is called
        GuidedExperience.ResetAssistedSetup(ObjectType::Page, Page::"Other Assisted Setup Test Page");

        // [THEN] Status is incomplete
        LibraryAssert.IsFalse(GuidedExperience.IsAssistedSetupComplete(ObjectType::Page, Page::"Other Assisted Setup Test Page"), 'Complete!');
    end;

    [Test]
    [HandlerFunctions('AssistedSetupPageHandler_CheckNonExisting')]
    procedure TestAssistedSetupPageDoesNotExist()
    var
        GuidedExperience: Codeunit "Guided Experience";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        GuidedExperienceType: Enum "Guided Experience Type";
    begin
        PermissionsMock.Set('Guided Exp Edit');
        Initialize();

        // [GIVEN] Subscribers are registered
        if BindSubscription(AssistedSetupTest) then;

        // [WHEN] The page is opened with filtered view
        GuidedExperience.OpenAssistedSetup(AssistedSetupGroup::ZZ);

        // [THEN] The assisted setup should be been deleted
        LibraryAssert.IsFalse(GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, NonExistingPageID), 'Assisted Setup exists!');
    end;

    local procedure Initialize();
    var
        AssistedSetupTestLibrary: Codeunit "Assisted Setup Test Library";
    begin
        SelectLatestVersion();
        AssistedSetupTestLibrary.DeleteAll();
        NonExistingPageID := 34636;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterAssistedSetup', '', true, true)]
    [Normal]
    local procedure OnRegister()
    var
        GuidedExperience: Codeunit "Guided Experience";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        GuidedExperienceType: Enum "Guided Experience Type";
        Info: ModuleInfo;
    begin
        PermissionsMock.Set('Guided Exp Edit');
        Initialize();
        NavApp.GetCurrentModuleInfo(Info);
        GuidedExperience.InsertAssistedSetup('My Assisted Setup Test Page', 'My Assisted Setup Test Page', 'Description of Setup Page', 0, ObjectType::Page,
            Page::"My Assisted Setup Test Page", AssistedSetupGroup::WithLinks, 'http://youtube.com', "Video Category"::Uncategorized, 'https://docs.microsoft.com/');

        GuidedExperience.AddTranslationForSetupObjectTitle(GuidedExperienceType::"Assisted Setup", ObjectType::Page,
            Page::"My Assisted Setup Test Page", 1033, 'English translation');

        GuidedExperience.InsertAssistedSetup('Other Assisted Setup Test Page', 'Other Assisted Setup Test Page', '', 0, ObjectType::Page,
            Page::"Other Assisted Setup Test Page", AssistedSetupGroup::WithoutLinks, '', "Video Category"::Uncategorized, '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnAfterRunAssistedSetup', '', true, true)]
    [Normal]
    local procedure OnAfterRun(ExtensionID: Guid; ObjectType: ObjectType; ObjectID: Integer)
    begin
        LastPageIDRun := ObjectID;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnReRunOfCompletedAssistedSetup', '', true, true)]
    [Normal]
    local procedure OnReRunOfCompletedSetup(ExtensionID: Guid; ObjectType: ObjectType; ObjectID: Integer; var Handled: Boolean)
    begin
        if ObjectID = Page::"Other Assisted Setup Test Page" then
            Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnBeforeOpenRoleBasedAssistedSetupExperience', '', true, true)]
    [Normal]
    local procedure OnBeforeOpenRoleBasedSetupExperience(var PageID: Integer; var Handled: Boolean)
    begin
        Handled := true;
    end;

    [ModalPageHandler]
    procedure MySetupTestPageHandler(var MyAssistedSetupTestPage: TestPage "My Assisted Setup Test Page")
    begin
    end;

    [ModalPageHandler]
    procedure OtherSetupTestPageHandler(var OtherAssistedSetupTestPage: TestPage "Other Assisted Setup Test Page")
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"Other Assisted Setup Test Page");
    end;

    [ModalPageHandler]
    procedure AssistedSetupPageHandler_ChecksCompletedHelp(var AssistedSetup: TestPage "Assisted Setup")
    begin
        AssistedSetup.First(); // the group - WithoutLinks
        AssistedSetup.Name.AssertEquals('WithoutLinks');
        AssistedSetup.Completed.AssertEquals(false);
        AssistedSetup.Help.AssertEquals('');

        AssistedSetup.Expand(true);

        AssistedSetup.Next();
        AssistedSetup.Name.AssertEquals('Other Assisted Setup Test Page');
        AssistedSetup.Completed.AssertEquals(false);
        AssistedSetup.Help.AssertEquals('');
    end;


    [ModalPageHandler]
    procedure AssistedSetupPageHandler_CheckNonExisting(var AssistedSetup: TestPage "Assisted Setup")
    begin
        AssistedSetup.First(); // the group - ZZ
        AssistedSetup.Name.AssertEquals('');
    end;
}