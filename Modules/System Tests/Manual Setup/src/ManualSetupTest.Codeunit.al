// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 134934 "Manual Setup Test"
{
    EventSubscriberInstance = Manual;
    SingleInstance = true;
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
        if BindSubscription(ManualSetupTest) then;

        // [Given] A subscriber that registers a manual setup and randomly initialized values
        Initialize();
        AppId := AddExtension();

        // [When] Invoke the event subscription by opening page
        ManualSetupPage.OpenView();

        // [Then] Verify that the first registered setup is present on the page
        ManualSetupPage.FILTER.SetFilter(Name, TestBusinessSetupNameTxt);
        ManualSetupPage.First();

        Assert.AreEqual(TestBusinessSetupNameTxt, Format(ManualSetupPage.Name), 'Page with given name is not found');
        Assert.AreEqual(TestBusinessSetupDescriptionTxt, Format(ManualSetupPage.Description), 'Page description is not correct');
        Assert.AreEqual(TestBusinessSetupKeywordsTxt, Format(ManualSetupPage.Keywords), 'Keywords are not correct');
        Assert.AreEqual(TestExtensionName, Format(ManualSetupPage.ExtensionName), 'Extension name is not correct');

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
        if BindSubscription(ManualSetupTest) then;

        // [Given] A subscriber that registers a manual setup and randomly initialized values
        Initialize();

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
    begin
        if BindSubscription(ManualSetupTest) then;

        // [Given] A subscriber that registers a manual setup and randomly initialized values
        Initialize();

        // [When] The list is fetched
        ManualSetup.GetPageIDs(PageIDs);

        // [Then] The PageID has just one entry
        Assert.AreEqual(1, PageIDs.Count(), 'The test subscriber only adds one entry.');

        // [Then] and the entry is
        Assert.IsTrue(PageIDs.Contains(Page::"My Manual Setup"), 'The added setup page is not in list.');
    end;

    local procedure Initialize()
    var
        Any: Codeunit Any;
        Keywords: array[5] of Text;
        i: Integer;
    begin
        TestExtensionName := Any.AlphabeticText(15);
        TestBusinessSetupNameTxt := Any.AlphabeticText(20);
        TestBusinessSetupDescriptionTxt := Any.AlphabeticText(20);
        TestBusinessSetupNameManualTxt := Any.AlphabeticText(20);
        TestBusinessSetupDescriptionManualTxt := Any.AlphabeticText(20);

        for i := 1 to 5 do
            Keywords[i] := Any.AlphabeticText(10);

        TestBusinessSetupKeywordsTxt := Keywords[1] + ', ' + Keywords[2] + ', ' + Keywords[3] + ', ' + Keywords[4];
        TestBusinessSetupKeywordsManualTxt := Keywords[2] + ', ' + Keywords[3] + ', ' + Keywords[4] + ', ' + Keywords[5];
    end;

    local procedure AddExtension() ExtensionID: Guid
    var
        Extension: Record "Published Application";
        TenantInformation: Codeunit "Tenant Information";
    begin
        ExtensionID := CreateGuid();

        Extension.Init();
        Extension.ID := ExtensionID;
        Extension."Package ID" := ExtensionID;
        Extension."Runtime Package ID" := ExtensionID;
        Extension."Tenant ID" := CopyStr(TenantInformation.GetTenantId(), 1, 128);
        Extension.Name := CopyStr(TestExtensionName, 1, 250);
        Extension.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Manual Setup", 'OnRegisterManualSetup', '', false, false)]
    [Scope('OnPrem')]
    procedure HandleOnRegisterManualSetup(var Sender: Codeunit "Manual Setup")
    var
        ManualSetupCategory: Enum "Manual Setup Category";
    begin
        Sender.Insert(CopyStr(TestBusinessSetupNameTxt, 1, 50), CopyStr(TestBusinessSetupDescriptionTxt, 1, 250),
          CopyStr(TestBusinessSetupKeywordsTxt, 1, 250), Page::"My Manual Setup", AppId, ManualSetupCategory::Uncategorized);
    end;

    [ModalPageHandler]
    procedure HandleManualSetup(var ManualSetup: TestPage "Manual Setup")
    begin
        ManualSetup.First();
        ManualSetup.Name.AssertEquals(CopyStr(TestBusinessSetupNameTxt, 1, 50));
    end;
}

