// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132586 "Assisted Setup Test"
{
    EventSubscriberInstance = Manual;
    SingleInstance = true;
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        LibraryAssert: Codeunit "Library Assert";
        AssistedSetupTest: Codeunit "Assisted Setup Test";
        LastPageIDRun: Integer;
        NonExistingPageID: Integer;
        DeleteRecordQst: Label 'The page does not exist. Do you want to remove this assisted setup?';

    [Test]
    [HandlerFunctions('VideoLinkPageHandler,MySetupTestPageHandler,OtherSetupTestPageHandler')]
    procedure TestAssistedSetupsAreAdded()
    var
        AssistedSetup: TestPage "Assisted Setup";
        Translation: TestPage Translation;
    begin
        Initialize();

        // [GIVEN] Subscribers are registered
        if BindSubscription(AssistedSetupTest) then;

        // [WHEN] The subscribers are run by opening the assisted setup page
        AssistedSetup.Trap();
        Page.Run(Page::"Assisted Setup");

        // [THEN] Two setups exist in 4 lines
        AssistedSetup.First(); // the first group - WithLinks
        AssistedSetup.Name.AssertEquals('WithLinks');
        AssistedSetup.Completed.AssertEquals(false);
        AssistedSetup.Help.AssertEquals('');
        AssistedSetup.Video.AssertEquals('');

        AssistedSetup.Next();
        AssistedSetup.Name.AssertEquals('Other Assisted Setup Test Page');
        AssistedSetup.Completed.AssertEquals(false);
        AssistedSetup.Help.AssertEquals('');
        AssistedSetup.Video.AssertEquals('');

        AssistedSetup.Next(); // the second group - WithoutLinks
        AssistedSetup.Name.AssertEquals('WithoutLinks');
        AssistedSetup.Completed.AssertEquals(false);
        AssistedSetup.Help.AssertEquals('');
        AssistedSetup.Video.AssertEquals('');

        AssistedSetup.Next();
        AssistedSetup.Name.AssertEquals('My Assisted Setup Test Page');
        AssistedSetup.Completed.AssertEquals(false);
        AssistedSetup.Help.AssertEquals('Read');
        AssistedSetup.Video.AssertEquals('Watch');

        // [WHEN] Start is invoked on the first wizard
        AssistedSetup.First();
        AssistedSetup.Next();
        LastPageIDRun := 0;
        AssistedSetup."Start Setup".Invoke();

        // [THEN] Check the last ID run based on the subscriber
        LibraryAssert.AreEqual(Page::"Other Assisted Setup Test Page", LastPageIDRun, 'First wizard did not run.');

        // [THEN] First wizard is completed
        AssistedSetup.Completed.AssertEquals(true);

        // [WHEN] Completed wizard is run again
        AssistedSetup."Start Setup".Invoke();

        // [THEN] As subscriber sets Handled = true, nothing happens

        // [WHEN] Start is invoked on the second wizard
        AssistedSetup.Next();
        AssistedSetup.Next();
        LastPageIDRun := 0;
        AssistedSetup."Start Setup".Invoke();

        // [THEN] Check the last ID run based on the subscriber
        LibraryAssert.AreEqual(Page::"My Assisted Setup Test Page", LastPageIDRun, 'Second wizard did not run.');

        // [THEN] Second wizard is not completed
        AssistedSetup.Completed.AssertEquals(false);

        // [WHEN] Click Watch on Video field
        AssistedSetup.Video.Drilldown();

        // [THEN] Video Link opens, and caught by modal page handler

        // [WHEN] Translated Name clicked
        Translation.Trap();
        AssistedSetup.TranslatedName.DrillDown();

        // [THEN] Translation page opens and caught by the trap above.
        Translation.LanguageName.AssertEquals('English (United States)');
        Translation.Close();

        // [WHEN] The assisted setup is refreshed
        AssistedSetup."Reset Setup".Invoke();

        // [THEN] Assisted Setup does not have Completed status anymore
        AssistedSetup.Completed.AssertEquals(false);
    end;

    [Test]
    [HandlerFunctions('AssistedSetupPageHandler_ChecksCompletedHelpAndVideo')]
    procedure TestAssistedSetupsShowUpOnFilteredView()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        AssistedSetupTestLibrary: Codeunit "Assisted Setup Test Library";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        Info: ModuleInfo;
    begin
        Initialize();

        // [GIVEN] Subscribers are registered
        if BindSubscription(AssistedSetupTest) then;

        // [WHEN] The page is opened with filtered view
        AssistedSetup.Open(AssistedSetupGroup::WithoutLinks);

        // [THEN] Run within the modal form handler

        // [WHEN] Setup is set to be Completed 
        AssistedSetupTestLibrary.SetStatusToCompleted(Page::"Other Assisted Setup Test Page");

        // [WHEN] Reset is called
        AssistedSetup.Reset(Page::"Other Assisted Setup Test Page");

        // [THEN] Status is incomplete
        NavApp.GetCurrentModuleInfo(Info);
        LibraryAssert.IsFalse(AssistedSetup.IsComplete(Info.Id(), Page::"Other Assisted Setup Test Page"), 'Complete!');
    end;

    [Test]
    [HandlerFunctions('AssistedSetupPageHandler_OpenNonExisting,ConfirmRemovalOfNonExistingPage')]
    procedure TestAssistedSetupPageDoesNotExist()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        AssistedSetupGroup: Enum "Assisted Setup Group";
    begin
        Initialize();

        // [GIVEN] Subscribers are registered
        if BindSubscription(AssistedSetupTest) then;

        // [WHEN] The page is opened with filtered view
        AssistedSetup.Open(AssistedSetupGroup::ZZ);

        // [THEN] The assisted setup should habe been deleted
        LibraryAssert.IsFalse(AssistedSetup.Exists(NonExistingPageID), 'Assisted Setup not removed!');
    end;

    local procedure Initialize();
    var
        AssistedSetupTestLibrary: Codeunit "Assisted Setup Test Library";
    begin
        AssistedSetupTestLibrary.DeleteAll();
        NonExistingPageID := 34636;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assisted Setup", 'OnRegister', '', true, true)]
    [Normal]
    procedure OnRegister()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        Info: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(Info);
        AssistedSetup.Add(Info.Id(), Page::"My Assisted Setup Test Page", 'My Assisted Setup Test Page', AssistedSetupGroup::WithoutLinks, 'http://youtube.com', "Video Category"::Uncategorized, 'http://yahoo.com');
        AssistedSetup.AddTranslation(Page::"My Assisted Setup Test Page", 1033, 'English translation');
        AssistedSetup.Add(Info.Id(), Page::"Other Assisted Setup Test Page", 'Other Assisted Setup Test Page', AssistedSetupGroup::WithLinks);
        AssistedSetup.Add(Info.Id(), NonExistingPageID, 'Non existing page', AssistedSetupGroup::ZZ);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assisted Setup", 'OnAfterRun', '', true, true)]
    [Normal]
    procedure OnAfterRun(ExtensionID: Guid; PageID: Integer)
    begin
        LastPageIDRun := PageID;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assisted Setup", 'OnReRunOfCompletedSetup', '', true, true)]
    [Normal]
    procedure OnReRunOfCompletedSetup(ExtensionID: Guid; PageID: Integer; var Handled: Boolean)
    begin
        if PageID = Page::"Other Assisted Setup Test Page" then
            Handled := true;
    end;

    [ModalPageHandler]
    procedure VideoLinkPageHandler(var VideoLink: TestPage "Video Link")
    begin
    end;

    [ModalPageHandler]
    procedure MySetupTestPageHandler(var MyAssistedSetupTestPage: TestPage "My Assisted Setup Test Page")
    begin
    end;

    [ModalPageHandler]
    procedure OtherSetupTestPageHandler(var OtherAssistedSetupTestPage: TestPage "Other Assisted Setup Test Page")
    var
        AssistedSetupApi: Codeunit "Assisted Setup";
        Info: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(Info);
        AssistedSetupApi.Complete(Info.Id(), Page::"Other Assisted Setup Test Page");
    end;

    [ModalPageHandler]
    procedure AssistedSetupPageHandler_ChecksCompletedHelpAndVideo(var AssistedSetup: TestPage "Assisted Setup")
    begin
        AssistedSetup.First(); // the group - WithoutLinks
        AssistedSetup.Name.AssertEquals('WithoutLinks');
        AssistedSetup.Completed.AssertEquals(false);
        AssistedSetup.Help.AssertEquals('');
        AssistedSetup.Video.AssertEquals('');

        AssistedSetup.Next();
        AssistedSetup.Name.AssertEquals('My Assisted Setup Test Page');
        AssistedSetup.Completed.AssertEquals(false);
        AssistedSetup.Help.AssertEquals('Read');
        AssistedSetup.Video.AssertEquals('Watch');
    end;


    [ModalPageHandler]
    procedure AssistedSetupPageHandler_OpenNonExisting(var AssistedSetup: TestPage "Assisted Setup")
    begin
        AssistedSetup.First(); // the group - ZZ
        AssistedSetup.Next();
        AssistedSetup.Name.AssertEquals('Non existing page');

        AssistedSetup."Start Setup".Invoke(); // should raise a confirm dialog
    end;

    [ConfirmHandler]
    procedure ConfirmRemovalOfNonExistingPage(ConfirmMessage: Text[1024]; var Reply: Boolean)
    begin
        LibraryAssert.AreEqual(DeleteRecordQst, ConfirmMessage, 'Unexpected confirm!');
        Reply := true;
    end;
}