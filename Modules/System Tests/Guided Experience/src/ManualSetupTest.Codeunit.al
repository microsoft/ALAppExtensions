// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 134934 "Manual Setup Test"
{
    EventSubscriberInstance = Manual;
    Subtype = Test;

    trigger OnRun()
    begin
        // [Feature] [Manual Setup]
    end;

    var
        Assert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";
        TestBusinessSetupNameTxt: Text;
        TestBusinessSetupDescriptionTxt: Text;
        TestBusinessSetupNameManualTxt: Text;
        TestBusinessSetupKeywordsTxt: Text;
        TestBusinessSetupDescriptionManualTxt: Text;
        TestBusinessSetupKeywordsManualTxt: Text;

    [Test]
    [Scope('OnPrem')]
    procedure VerifySubscribedPageExistsOnTheList()
    var
        ManualSetupTest: Codeunit "Manual Setup Test";
        ManualSetupPage: TestPage "Manual Setup";
        MyManualSetup: TestPage "My Manual Setup";
    begin
        PermissionsMock.Set('Guided Exp Edit');
        BindSubscription(ManualSetupTest);

        // [Given] A subscriber that registers a manual setup and randomly initialized values
        // sets the global vars in this instance and in the subscriber instance of ManualSetupTest
        Initialize(ManualSetupTest);

        // [When] Invoke the event subscription by opening page
        ManualSetupPage.OpenView();

        // [Then] Verify that the first registered setup is present on the page
        ManualSetupPage.Filter.SetFilter(Title, TestBusinessSetupNameTxt);
        ManualSetupPage.First();
        //ManualSetupPage.GoToKey(TestBusinessSetupNameTxt);

        Assert.AreEqual(TestBusinessSetupNameTxt, ManualSetupPage.Name.Value(), 'Page with given name is not found');
        Assert.AreEqual(TestBusinessSetupDescriptionTxt, ManualSetupPage.Description.Value(), 'Page description is not correct');
        Assert.AreEqual(TestBusinessSetupKeywordsTxt, ManualSetupPage.Keywords.Value(), 'Keywords are not correct');

        // [When] Open the manual setup page
        // [Then] Verify that the my manual setup page is opened
        MyManualSetup.Trap();
        ManualSetupPage."Open Manual Setup".Invoke();
        MyManualSetup.Close();
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('HandleManualSetup')]
    procedure TestFilteredView()
    var
        ManualSetupTest: Codeunit "Manual Setup Test";
        GuidedExperience: Codeunit "Guided Experience";
        ManualSetupCategory: Enum "Manual Setup Category";
    begin
        PermissionsMock.Set('Guided Exp Edit');
        BindSubscription(ManualSetupTest);

        // [Given] A subscriber that registers a manual setup and randomly initialized values
        Initialize(ManualSetupTest);

        // [When] The list is fetched
        GuidedExperience.OpenManualSetupPage(ManualSetupCategory::Uncategorized);

        // [Then] Verificaton of records happens inside the modal form handler
    end;

#if not CLEAN18
    [Test]
    [Scope('OnPrem')]
    procedure VerifyListOfPageIDs()
    var
        ManualSetupTest: Codeunit "Manual Setup Test";
        ManualSetup: Codeunit "Manual Setup";
        AssistedSetupTestLibrary: Codeunit "Assisted Setup Test Library";
        PageIDs: List of [Integer];
        OldCount: Integer;
    begin
        PermissionsMock.Set('Guided Exp Edit');
        // [Given] A subscriber that registers a manual setup and randomly initialized values
        Initialize(ManualSetupTest);

        AssistedSetupTestLibrary.DeleteAll();

        // [When] The list is fetched
        ManualSetup.GetPageIDs(PageIDs);
        OldCount := PageIDs.Count();

        // [When] and a new subscriber is added
        BindSubscription(ManualSetupTest);
        ManualSetup.GetPageIDs(PageIDs);

        // [Then] The PageID has just one more entry
        Assert.AreEqual(1, PageIDs.Count() - OldCount, 'The test subscriber only adds one entry.');

        // [Then] and the new entry is found
        Assert.IsTrue(PageIDs.Contains(Page::"My Manual Setup"), 'The added setup page is not in list.');
    end;
#endif

    local procedure Initialize(var ManualSetupTest: Codeunit "Manual Setup Test")
    begin
        ManualSetupTest.Initialize(TestBusinessSetupNameTxt, TestBusinessSetupDescriptionTxt, TestBusinessSetupNameManualTxt, TestBusinessSetupKeywordsTxt, TestBusinessSetupDescriptionManualTxt, TestBusinessSetupKeywordsManualTxt);
    end;

    internal procedure Initialize(var BusinessSetupNameTxt: Text; var BusinessSetupDescriptionTxt: Text; var BusinessSetupNameManualTxt: Text; var BusinessSetupKeywordsTxt: Text; var BusinessSetupDescriptionManualTxt: Text; var BusinessSetupKeywordsManualTxt: Text)
    var
        Any: Codeunit Any;
        Keywords: array[5] of Text;
        i: Integer;
    begin
        TestBusinessSetupNameTxt := Any.AlphabeticText(20);
        BusinessSetupNameTxt := TestBusinessSetupNameTxt;
        TestBusinessSetupDescriptionTxt := 'Gert'; //Any.AlphabeticText(20);
        BusinessSetupDescriptionTxt := TestBusinessSetupDescriptionTxt;
        TestBusinessSetupNameManualTxt := Any.AlphabeticText(20);
        BusinessSetupNameManualTxt := TestBusinessSetupNameManualTxt;
        TestBusinessSetupDescriptionManualTxt := Any.AlphabeticText(20);
        BusinessSetupDescriptionManualTxt := TestBusinessSetupDescriptionManualTxt;

        for i := 1 to 5 do
            Keywords[i] := Any.AlphabeticText(10);

        TestBusinessSetupKeywordsTxt := Keywords[1] + ', ' + Keywords[2] + ', ' + Keywords[3] + ', ' + Keywords[4];
        BusinessSetupKeywordsTxt := TestBusinessSetupKeywordsTxt;
        TestBusinessSetupKeywordsManualTxt := Keywords[2] + ', ' + Keywords[3] + ', ' + Keywords[4] + ', ' + Keywords[5];
        BusinessSetupKeywordsManualTxt := TestBusinessSetupKeywordsManualTxt;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterManualSetup', '', false, false)]
    local procedure HandleOnRegisterManualSetup(var Sender: Codeunit "Guided Experience")
    var
        ManualSetupCategory: Enum "Manual Setup Category";
    begin
        Sender.InsertManualSetup(CopyStr(TestBusinessSetupNameTxt, 1, 50), CopyStr(TestBusinessSetupNameTxt, 1, 50), CopyStr(TestBusinessSetupDescriptionTxt, 1, 250), 0,
            ObjectType::Page, Page::"My Manual Setup", ManualSetupCategory::Uncategorized, CopyStr(TestBusinessSetupKeywordsTxt, 1, 250));
    end;

    [ModalPageHandler]
    procedure HandleManualSetup(var ManualSetup: TestPage "Manual Setup")
    begin
        ManualSetup.GoToKey('MANUAL SETUP_PAGE_134934__0', 0);
    end;
}

