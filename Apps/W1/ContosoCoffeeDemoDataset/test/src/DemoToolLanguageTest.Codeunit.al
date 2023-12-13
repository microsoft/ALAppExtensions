codeunit 148049 "Demo Tool Language Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;

    [Test]
    procedure ContosoDemoToolLanguageInitializationTest()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ContosoDemoDataModule: Record "Contoso Demo Data Module";
        ContosoDemoTool: Codeunit "Contoso Demo Tool";
        CurrentLanguageID: Integer;
    begin
        ContosoDemoDataModule.DeleteAll();

        // [SCENARIO] Testing the "Language ID" of the Contoso Coffee Demo Data Setup record
        CurrentLanguageID := GlobalLanguage();

        // [GIVEN] Run the Contoso Demo Tool for the first time, "Language ID" should be initialized
        GetContosoTest1Module(ContosoDemoDataModule);
        ContosoDemoTool.CreateDemoData(ContosoDemoDataModule, Enum::"Contoso Demo Data Level"::"Setup Data");

        // [THEN] The "Language ID" of the Contoso Coffee Demo Data Setup record should be the same as the current language
        ContosoCoffeeDemoDataSetup.Get();
        Assert.AreEqual(CurrentLanguageID, ContosoCoffeeDemoDataSetup."Language ID", 'The "Language ID" of the Contoso Coffee Demo Data Setup record should be the same as the current language');
    end;

    [Test]
    [HandlerFunctions('DifferentLanguageDialogHandler')]
    procedure ContosoDemoToolLanguageMismatchTest()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ContosoDemoDataModule: Record "Contoso Demo Data Module";
        ContosoDemoTool: Codeunit "Contoso Demo Tool";
        CurrentLanguageID, NewLanguageID : Integer;
    begin
        ContosoDemoDataModule.DeleteAll();

        // [SCENARIO] Testing when the "Language ID" does not match the first run of the Contoso Demo Tool
        CurrentLanguageID := GlobalLanguage();

        // [GIVEN] Run the Contoso Demo Tool for the first time, "Language ID" should be initialized
        GetContosoTest1Module(ContosoDemoDataModule);
        ContosoDemoTool.CreateDemoData(ContosoDemoDataModule, Enum::"Contoso Demo Data Level"::"Setup Data");


        // [THEN] The "Language ID" of the Contoso Coffee Demo Data Setup record should be the same as the current language
        ContosoCoffeeDemoDataSetup.Get();
        Assert.AreEqual(CurrentLanguageID, ContosoCoffeeDemoDataSetup."Language ID", 'The "Language ID" of the Contoso Coffee Demo Data Setup record should be the same as the current language');

        // [WHEN] Changing the current language
        NewLanguageID := 2057; // English (United Kingdom)
        GlobalLanguage(NewLanguageID);

        // [THEN] When running of the Contoso Demo Tool again, there should be dialog pops up warning a language mismatch 
        // Checking for the dialog is done in the handler function
        ContosoDemoTool.CreateDemoData(ContosoDemoDataModule, Enum::"Contoso Demo Data Level"::All);
    end;

    [ConfirmHandler]
    procedure DifferentLanguageDialogHandler(Question: Text; var Reply: Boolean)
    begin
        // [THEN] The confirmation dialog should contain the words "different" and "language"
        // Not testing for the exact text because we do not want to be dependent on the label string
        if Question.Contains('different') and Question.Contains('language') then
            Reply := false
        else
            Error('Different language for the Contoso Demo Tool is not caught.');
    end;

    local procedure GetContosoTest1Module(var ContosoDemoDataModule: Record "Contoso Demo Data Module")
    begin
        ContosoDemoDataModule.Init();
        ContosoDemoDataModule.Validate(Name, Format(Enum::"Contoso Demo Data Module"::"Contoso Test 1"));
        ContosoDemoDataModule.Validate(Module, Enum::"Contoso Demo Data Module"::"Contoso Test 1");
        if not ContosoDemoDataModule.Get(Enum::"Contoso Demo Data Module"::"Contoso Test 1") then
            ContosoDemoDataModule.Insert();
    end;
}