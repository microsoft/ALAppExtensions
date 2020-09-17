// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 134934 "Manual Setup Test"
{
    EventSubscriberInstance = Manual;
    Subtype = Test;
    TestPermissions = NonRestrictive;

    trigger OnRun()
    begin
        // [Feature] [Manual Setup]
    end;

    var
        Assert: Codeunit "Library Assert";
        TestExtensionName: Text;
        TestBusinessSetupNameTxt: Text;
        TestBusinessSetupDescriptionTxt: Text;
        TestBusinessSetupNameManualTxt: Text;
        TestBusinessSetupKeywordsTxt: Text;
        TestBusinessSetupDescriptionManualTxt: Text;
        TestBusinessSetupKeywordsManualTxt: Text;
        AppId: Guid;

    [Test]
    [Scope('OnPrem')]
    procedure VerifySubscribedPageExistsOnTheList()
    var
        ManualSetupTest: Codeunit "Manual Setup Test";
        ManualSetupPage: TestPage "Manual Setup";
        MyManualSetup: TestPage "My Manual Setup";
    begin
        BindSubscription(ManualSetupTest);

        // [Given] A subscriber that registers a manual setup and randomly initialized values
        // sets the global vars in this instance and in the subscriber instance of ManualSetupTest
        Initialize(ManualSetupTest);
        AppId := ManualSetupTest.AddExtension();

        // [When] Invoke the event subscription by opening page
        ManualSetupPage.OpenView();

        // [Then] Verify that the first registered setup is present on the page
        ManualSetupPage.Filter.SetFilter(Name, TestBusinessSetupNameTxt);
        ManualSetupPage.First();
        //ManualSetupPage.GoToKey(TestBusinessSetupNameTxt);

        Assert.AreEqual(TestBusinessSetupNameTxt, ManualSetupPage.Name.Value(), 'Page with given name is not found');
        Assert.AreEqual(TestBusinessSetupDescriptionTxt, ManualSetupPage.Description.Value(), 'Page description is not correct');
        Assert.AreEqual(TestBusinessSetupKeywordsTxt, ManualSetupPage.Keywords.Value(), 'Keywords are not correct');
        Assert.AreEqual(TestExtensionName, ManualSetupPage.ExtensionName.Value(), 'Extension name is not correct');

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
        ManualSetup: Codeunit "Manual Setup";
        ManualSetupCategory: Enum "Manual Setup Category";
    begin
        BindSubscription(ManualSetupTest);

        // [Given] A subscriber that registers a manual setup and randomly initialized values
        Initialize(ManualSetupTest);

        // [When] The list is fetched
        ManualSetup.Open(ManualSetupCategory::Uncategorized);

        // [Then] Verificaton of records happens inside the modal form handler
    end;

    [Test]
    [Scope('OnPrem')]
    procedure VerifyListOfPageIDs()
    var
        ManualSetupTest: Codeunit "Manual Setup Test";
        ManualSetup: Codeunit "Manual Setup";
        PageIDs: List of [Integer];
        OldCount: Integer;
    begin
        // [Given] A subscriber that registers a manual setup and randomly initialized values
        Initialize(ManualSetupTest);

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

    local procedure Initialize(var ManualSetupTest: Codeunit "Manual Setup Test")
    begin
        ManualSetupTest.Initialize(TestExtensionName, TestBusinessSetupNameTxt, TestBusinessSetupDescriptionTxt, TestBusinessSetupNameManualTxt, TestBusinessSetupKeywordsTxt, TestBusinessSetupDescriptionManualTxt, TestBusinessSetupKeywordsManualTxt);
    end;

    internal procedure Initialize(var ExtensionName: Text; var BusinessSetupNameTxt: Text; var BusinessSetupDescriptionTxt: Text; var BusinessSetupNameManualTxt: Text; var BusinessSetupKeywordsTxt: Text; var BusinessSetupDescriptionManualTxt: Text; var BusinessSetupKeywordsManualTxt: Text)
    var
        Any: Codeunit Any;
        Keywords: array[5] of Text;
        i: Integer;
    begin
        TestExtensionName := Any.AlphabeticText(15);
        ExtensionName := TestExtensionName;
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

    procedure AddExtension(): Guid
    var
        PublishedApplication: Record "Published Application";
        Extension: Record "Published Application";
        TenantInformation: Codeunit "Tenant Information";
    begin
        PublishedApplication.FindFirst();
        
        AppId := CreateGuid();

        Extension.Init();
        Extension.ID := AppId;
        Extension."Package ID" := AppId;
        Extension."Runtime Package ID" := AppId;
        Extension."Tenant ID" := CopyStr(TenantInformation.GetTenantId(), 1, 128);
        Extension.Name := CopyStr(TestExtensionName, 1, 250);

        // these fields needs to be filled in, just add the hash and any blob.
        Extension."Package Hash" := PublishedApplication."Package Hash";
        Extension.Blob := PublishedApplication.Blob;
        Extension.Insert();
        exit(AppId)
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Manual Setup", 'OnRegisterManualSetup', '', false, false)]
    [Scope('OnPrem')]
    local procedure HandleOnRegisterManualSetup(var Sender: Codeunit "Manual Setup")
    var
        ManualSetupCategory: Enum "Manual Setup Category";
    begin
        Sender.Insert(CopyStr(TestBusinessSetupNameTxt, 1, 50), CopyStr(TestBusinessSetupDescriptionTxt, 1, 250),
          CopyStr(TestBusinessSetupKeywordsTxt, 1, 250), Page::"My Manual Setup", AppId, ManualSetupCategory::Uncategorized);
    end;

    [ModalPageHandler]
    procedure HandleManualSetup(var ManualSetup: TestPage "Manual Setup")
    begin
        ManualSetup.GoToKey(CopyStr(TestBusinessSetupNameTxt, 1, 50));
    end;
}

