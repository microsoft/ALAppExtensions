// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 137121 "Translation Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Translation: Codeunit Translation;
        Assert: Codeunit "Library Assert";
        Text1Txt: Label 'Translation 1';
        Text2Txt: Label 'Translation 2';
        Text3Txt: Label 'Translation 3';
        Text4Txt: Label 'Translation 4';

    [Test]
    [Scope('OnPrem')]
    procedure TestGettingAndSettingTranslations()
    var
        TranslationTestTable: Record "Translation Test Table";
        TranslationRec: Record Translation;
    begin
        // [SCENARIO] Test the storage and retrieval of translations in different languages

        Initialize();

        // [GIVEN] Create a record for which data in fields can be translated
        TranslationTestTable.Init();
        TranslationTestTable.PK := 1;
        TranslationTestTable.Insert();

        // [WHEN] Set the translations in Global and another language
        Translation.Set(TranslationTestTable, TranslationTestTable.FieldNo(TextField), Text1Txt);
        Translation.SetForLanguage(TranslationTestTable, TranslationTestTable.FieldNo(TextField), 1030, Text2Txt);

        // [THEN] Two records should have been created in the translation table
        TranslationRec.SetRange("Record ID", TranslationTestTable.RecordId());
        TranslationRec.SetRange("Field ID", TranslationTestTable.FieldNo(TextField));
        Assert.AreEqual(2, TranslationRec.Count(), 'Incorrect number of translations stored');
        TranslationRec.SetRange("Language ID", GlobalLanguage());
        TranslationRec.FindFirst();
        Assert.AreEqual(Text1Txt, TranslationRec.Value, 'Incorrect translation stored for global language');
        TranslationRec.SetRange("Language ID", 1030);
        TranslationRec.FindFirst();
        Assert.AreEqual(Text2Txt, TranslationRec.Value, 'Incorrect translation stored for language');

        // [WHEN] Try to get the translations through API
        // [THEN] these should match the ones that were set
        Assert.AreEqual(Text2Txt, Translation.GetForLanguage(TranslationTestTable, TranslationTestTable.FieldNo(TextField), 1030),
          'Incorrect translation retrieved for language');
        Assert.AreEqual(Text1Txt, Translation.Get(TranslationTestTable, TranslationTestTable.FieldNo(TextField)),
          'Incorrect translation retrieved for global language');
    end;

    [Test]
    [HandlerFunctions('HandleLanguagePage')]
    [Scope('OnPrem')]
    procedure TestRetrivalAndStorageThroughUI()
    var
        TranslationTestTable: Record "Translation Test Table";
        TranslationRec: Record Translation;
        TranslationTestPage: TestPage "Translation Test Page";
        TranslationPage: TestPage Translation;
    begin
        // [SCENARIO] Tests if the Translation page shows the correct values stored

        Initialize();

        // [GIVEN] Create a record for which data in fields can be translated
        TranslationTestTable.Init();
        TranslationTestTable.PK := 1;
        TranslationTestTable.Insert();

        // [GIVEN] Set the translations in Global and another language
        Translation.Set(TranslationTestTable, TranslationTestTable.FieldNo(TextField), Text1Txt);
        Translation.SetForLanguage(TranslationTestTable, TranslationTestTable.FieldNo(TextField), 1030, Text2Txt);

        // [WHEN] Record page is opened
        TranslationTestPage.Trap();
        PAGE.Run(PAGE::"Translation Test Page", TranslationTestTable);

        // [THEN] The global language translation is shown on the field
        TranslationTestPage.TextField.AssertEquals(Text1Txt);

        // [WHEN] Assist edit triggers the Translation page
        TranslationPage.Trap();
        TranslationTestPage.TextField.AssistEdit();

        // [THEN] Page caption is set to Record ID
        Assert.AreEqual('Edit - Translation - ' + Format(TranslationTestTable.RecordId()), TranslationPage.Caption(), 'Custom caption is to be shown');

        // [THEN] Two records show up
        TranslationPage.First();
        TranslationPage."Language Name".AssertEquals('Danish');
        TranslationPage.Value.AssertEquals(Text2Txt);
        TranslationPage.Last();
        TranslationPage."Language Name".AssertEquals('English');
        TranslationPage.Value.AssertEquals(Text1Txt);

        // [WHEN] Edit the ENU record
        TranslationPage.Value.SetValue(Text3Txt);
        TranslationPage.Next();

        // [WHEN] Add a new translation for FRA
        TranslationPage."Language Name".AssistEdit(); // pops out the Languages page handled by the Modal Handler
        TranslationPage.Value.SetValue(Text4Txt);
        TranslationPage.Next();

        // [THEN] Verify translation records
        TranslationRec.SetRange("Record ID", TranslationTestTable.RecordId());
        TranslationRec.SetRange("Field ID", TranslationTestTable.FieldNo(TextField));
        Assert.AreEqual(3, TranslationRec.Count(), 'Incorrect number of translations stored');
        TranslationRec.SetRange("Language ID", GlobalLanguage());
        TranslationRec.FindFirst();
        Assert.AreEqual(Text3Txt, TranslationRec.Value, 'Incorrect translation stored for global language');
        TranslationRec.SetRange("Language ID", 1030);
        TranslationRec.FindFirst();
        Assert.AreEqual(Text2Txt, TranslationRec.Value, 'Incorrect translation stored for DAN language');
        TranslationRec.SetRange("Language ID", 1036);
        TranslationRec.FindFirst();
        Assert.AreEqual(Text4Txt, TranslationRec.Value, 'Incorrect translation stored for FRA language');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestShowForAllRecords()
    var
        TranslationTestTableA: Record "Translation Test Table";
        TranslationTestTableB: Record "Translation Test Table";
        TranslationTestTableC: Record "Translation Test Table";
        TranslationPage: TestPage Translation;
    begin
        // [SCENARIO] Tests if the ShowForAllRecords shows translations for all records in a table

        Initialize();

        // [GIVEN] Create 3 records for which data in fields can be translated
        CreateRecordWithTranslation(TranslationTestTableA);
        CreateRecordWithTranslation(TranslationTestTableB);
        CreateRecordWithTranslation(TranslationTestTableC);

        // [WHEN] Call ShowForAllRecords
        TranslationPage.Trap();
        Translation.ShowForAllRecords(TranslationTestTableA.RecordId().TableNo(), TranslationTestTableA.FieldNo(TextField));

        // [THEN] No custom caption
        if TranslationPage.Caption() <> 'Edit - Translation' then
            Error('Custom caption is not to be shown');

        // [THEN] Verify the content of the page as all the translations for the 3 records
        TranslationPage.First();
        TranslationPage."Language Name".AssertEquals('Danish');
        TranslationPage.Value.AssertEquals(CalculateValue(TranslationTestTableA, Text2Txt));
        TranslationPage.Next();
        TranslationPage."Language Name".AssertEquals('Danish');
        TranslationPage.Value.AssertEquals(CalculateValue(TranslationTestTableB, Text2Txt));
        TranslationPage.Next();
        TranslationPage."Language Name".AssertEquals('Danish');
        TranslationPage.Value.AssertEquals(CalculateValue(TranslationTestTableC, Text2Txt));
        TranslationPage.Next();
        TranslationPage."Language Name".AssertEquals('English');
        TranslationPage.Value.AssertEquals(CalculateValue(TranslationTestTableA, Text1Txt));
        TranslationPage.Next();
        TranslationPage."Language Name".AssertEquals('English');
        TranslationPage.Value.AssertEquals(CalculateValue(TranslationTestTableB, Text1Txt));
        TranslationPage.Next();
        TranslationPage."Language Name".AssertEquals('English');
        TranslationPage.Value.AssertEquals(CalculateValue(TranslationTestTableC, Text1Txt));
        TranslationPage.Next();
        Assert.IsFalse(TranslationPage.Next(), 'No more records should be available.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestRenameRecord()
    var
        TranslationTestTable: Record "Translation Test Table";
        TranslationRec: Record Translation;
        OldRecordID: RecordId;
    begin
        // [SCENARIO] Tests if the translations records are updated with the new key once a record is renamed

        Initialize();

        // [GIVEN] Create a record for which data in fields can be translated
        CreateRecordWithTranslation(TranslationTestTable);

        // [WHEN] Rename the record
        OldRecordID := TranslationTestTable.RecordId();
        TranslationTestTable.Rename(9999);

        // [THEN] No translation records with old record ID
        TranslationRec.SetRange("Record ID", OldRecordID);
        Assert.IsTrue(TranslationRec.IsEmpty(), 'No records with the old record ID should exist.');

        // [THEN] 2 Translation records with new record ID exist
        TranslationRec.SetRange("Record ID", TranslationTestTable.RecordId());
        Assert.AreEqual(2, TranslationRec.Count(), '2 records with the new record ID should exist.');
    end;

    local procedure Initialize()
    var
        TranslationTestTable: Record "Translation Test Table";
    begin
        CreateLanguage('ENU', 'English', 1033);
        CreateLanguage('DAN', 'Danish', 1030);
        CreateLanguage('FRA', 'French', 1036);

        // Set ENU to global language
        GlobalLanguage(1033);
        TranslationTestTable.DeleteAll(true);
    end;

    local procedure CreateLanguage(LanguageCode: Code[10]; LanguageName: Text[50]; LanguageID: Integer)
    var
        Language: Record Language;
    begin
        if not Language.Get(LanguageCode) then begin
            Language.Init();
            Language.Code := LanguageCode;
            Language.Name := LanguageName;
            Language."Windows Language ID" := LanguageID;
            Language.Insert(true);
        end;
    end;

    local procedure CreateRecordWithTranslation(var TranslationTestTable: Record "Translation Test Table")
    var
        LastId: Integer;
    begin
        if TranslationTestTable.FindLast() then
            LastId := TranslationTestTable.PK;
        TranslationTestTable.Init();
        TranslationTestTable.PK := LastId + 1;
        TranslationTestTable.Insert();
        Translation.Set(TranslationTestTable, TranslationTestTable.FieldNo(TextField),
          CalculateValue(TranslationTestTable, Text1Txt));
        Translation.SetForLanguage(TranslationTestTable, TranslationTestTable.FieldNo(TextField), 1030,
          CalculateValue(TranslationTestTable, Text2Txt));
    end;

    local procedure CalculateValue(TranslationTestTable: Record "Translation Test Table"; OrigValue: Text): Text[2048]
    begin
        exit(CopyStr(StrSubstNo('%1-%2', TranslationTestTable.PK, OrigValue), 1, 2048));
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure HandleLanguagePage(var WindowsLanguages: Page "Windows Languages"; var Response: Action)
    var
        WindowsLanguage: Record "Windows Language";
    begin
        // select the French language record
        WindowsLanguage.Get(1036);
        WindowsLanguages.SetRecord(WindowsLanguage);
        Response := Action::LookupOK;
    end;
}

