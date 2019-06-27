codeunit 134934 "Manual Setup Test"
{
    EventSubscriberInstance = Manual;
    SingleInstance = true;
    Subtype = Test;
    TestPermissions = NonRestrictive;

    trigger OnRun()
    begin
        // [FEATURE] [Manual Setup]
    end;

    var
        Assert: Codeunit "Library Assert";
        TestBusinessSetupNameTxt: Label 'TEST Name';
        TestBusinessSetupDescriptionTxt: Label 'TEST Description';
        TestBusinessSetupKeywordsTxt: Label 'Test1, Test2, Test3';
        TestBusinessSetupNameManualTxt: Label 'TEST Name Manual';
        TestBusinessSetupDescriptionManualTxt: Label 'TEST Description Manual';
        TestBusinessSetupKeywordsManualTxt: Label 'Test1, Test2, Test3, Manual';
        IsInitialized: Boolean;

    [Test]
    [Scope('OnPrem')]
    procedure VerifySubscribedPageExistsOnTheList()
    var
        ManualSetupPage: TestPage "Manual Setup";
        MyManualSetup: TestPage "My Manual Setup";
        BusinessSetupTest: Codeunit "Manual Setup Test";
    begin
        BindSubscription(BusinessSetupTest);

        // [GIVEN, WHEN] Invoke the event subscription by opening page
        ManualSetupPage.OpenView();

        // [THEN] Verify that the setup shows up
        ManualSetupPage.FILTER.SetFilter(Name, TestBusinessSetupNameTxt);
        ManualSetupPage.First();
        Assert.AreEqual(Format(ManualSetupPage.Name), TestBusinessSetupNameTxt, 'Page with given name not found');

        // [WHEN] Open the manual setup page
        // [THEN] Verify that the my manual setup page is opened
        MyManualSetup.Trap();
        ManualSetupPage."Open Manual Setup".Invoke();
        MyManualSetup.Close();

        // [THEN] Verify that the manual setup shows up
        ManualSetupPage.FILTER.SetFilter(Name, TestBusinessSetupNameManualTxt);
        ManualSetupPage.First();
        Assert.AreEqual(Format(ManualSetupPage.Name), TestBusinessSetupDescriptionManualTxt, 'Page with manual setup not found');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Manual Setup", 'OnRegisterManualSetup', '', false, false)]
    [Scope('OnPrem')]
    procedure HandleOnRegisterManualSetup(var Sender: Codeunit "Manual Setup")
    var
        EmptyGuid: Guid;
    begin
        // [GIVEN] Add the icon to be used
        Sender.ClearAllIcons();
        Sender.AddIcon('SomeIcon', '');

        Sender.Insert(TestBusinessSetupNameTxt, TestBusinessSetupDescriptionTxt,
          TestBusinessSetupKeywordsTxt, page::"My Manual Setup", EmptyGuid);

        Sender.InsertWithIconSharedInMedia(TestBusinessSetupNameManualTxt, TestBusinessSetupDescriptionManualTxt,
          TestBusinessSetupKeywordsManualTxt, page::"My Manual Setup", 'SomeIcon');
    end;
}

