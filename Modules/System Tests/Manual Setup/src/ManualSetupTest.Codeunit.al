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
        Id: Guid;

    [Test]
    [Scope('OnPrem')]
    procedure VerifySubscribedPageExistsOnTheList()
    var
        ManualSetupTest: Codeunit "Manual Setup Test";
        ManualSetupPage: TestPage "Manual Setup";
        MyManualSetup: TestPage "My Manual Setup";

    begin
        if BindSubscription(ManualSetupTest) then;

        // [Given] Two sunscribers that register a manual setup and randomly initialized values
        Initialize();
        Id := AddExtenstion();

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

        // [Then] Verify that the second manual setup is present on the page
        ManualSetupPage.FILTER.SetFilter(Name, TestBusinessSetupNameManualTxt);
        ManualSetupPage.First();

        Assert.AreEqual(TestBusinessSetupNameManualTxt, Format(ManualSetupPage.Name), 'Manual page setup not found');
        Assert.AreEqual(TestBusinessSetupDescriptionManualTxt, Format(ManualSetupPage.Description), 'Manual Setup page description is not correct');
        Assert.AreEqual(TestBusinessSetupKeywordsManualTxt, Format(ManualSetupPage.Keywords), 'Manual Setup page keywords are not correct');
        Assert.AreEqual('', Format(ManualSetupPage.ExtensionName), 'Extension name should be empty in Manual Setup page');

        if UnbindSubscription(ManualSetupTest) then;
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

    local procedure AddExtenstion() ExtenstionID: Guid
    var
        Extension: Record "NAV App";
    begin
        ExtenstionID := CreateGuid();

        Extension.Init();
        Extension.ID := ExtenstionID;
        Extension.Name := TestExtensionName;
        Extension.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Manual Setup", 'OnRegisterManualSetup', '', false, false)]
    [Scope('OnPrem')]
    procedure HandleOnRegisterManualSetup(var Sender: Codeunit "Manual Setup")
    begin
        // [Given] Add the icon to be used
        Sender.ClearAllIcons();
        Sender.AddIcon('SomeIcon', '');

        Sender.InsertForExtension(TestBusinessSetupNameTxt, TestBusinessSetupDescriptionTxt,
          TestBusinessSetupKeywordsTxt, Page::"My Manual Setup", Id);

        Sender.Insert(TestBusinessSetupNameManualTxt, TestBusinessSetupDescriptionManualTxt,
          TestBusinessSetupKeywordsManualTxt, Page::"My Manual Setup", 'SomeIcon');
    end;
}

