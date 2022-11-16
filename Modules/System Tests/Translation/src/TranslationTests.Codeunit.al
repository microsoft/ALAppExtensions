﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 137121 "Translation Tests"
{
    Subtype = Test;
    Permissions = tabledata Language = rimd;

    var
        Translation: Codeunit Translation;
        Assert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";
        IsInitialzied: Boolean;
        Text1Txt: Label 'Translation 1';
        Text2Txt: Label 'Translation 2';
        Text3Txt: Label 'Translation 3';
        Text4Txt: Label 'Translation 4';
        Text5Txt: Label 'Translation 5';
        CannotTranslateTempRecErr: Label 'Translations cannot be added or retrieved for temporary records.';
        DifferentTableErr: Label 'The records cannot belong to different tables.';
        NoRecordIdErr: Label 'The variant passed is not a record.';
        TranslationEditRoleTok: Label 'Translation Edit', Locked = true;

    [Test]
    [Scope('OnPrem')]
    procedure TestGettingAndSettingTranslations()
    var
        TranslationTestTable: Record "Translation Test Table";
        Translation1: Text;
        Translation2: Text;
    begin
        // [SCENARIO] Test the storage and retrieval of translations in different languages
        Initialize();

        PermissionsMock.Set(TranslationEditRoleTok);

        // [GIVEN] Create a record for which data in fields can be translated
        TranslationTestTable.Init();
        TranslationTestTable.PK := 1;
        TranslationTestTable.Insert();

        // [WHEN] Set the translations in Global and another language
        Translation.Set(TranslationTestTable, TranslationTestTable.FieldNo(TextField), Text1Txt);
        Translation.Set(TranslationTestTable, TranslationTestTable.FieldNo(TextField), 1030, Text2Txt);

        // [THEN] Two records should have been created in the translation table
        Translation1 := Translation.Get(TranslationTestTable, TranslationTestTable.FieldNo(TextField));
        Translation2 := Translation.Get(TranslationTestTable, TranslationTestTable.FieldNo(TextField), 1030);
        Assert.AreEqual(Text1Txt, Translation1, 'Incorrect translation stored for global language');
        Assert.AreEqual(Text2Txt, Translation2, 'Incorrect translation stored for language');

        // [WHEN] Try to get the translations through API
        // [THEN] these should match the ones that were set
        Assert.AreEqual(Text2Txt, Translation.Get(TranslationTestTable, TranslationTestTable.FieldNo(TextField), 1030),
          'Incorrect translation retrieved for language');
        Assert.AreEqual(Text1Txt, Translation.Get(TranslationTestTable, TranslationTestTable.FieldNo(TextField)),
          'Incorrect translation retrieved for global language');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestSetAndDeleteTranslations()
    var
        TranslationTestTable: Record "Translation Test Table";
    begin
        // [SCENARIO] Translations can be deleted
        Initialize();

        PermissionsMock.Set(TranslationEditRoleTok);

        // [GIVEN] Create a record for which data in fields can be translated
        TranslationTestTable.Init();
        TranslationTestTable.PK := 1;
        TranslationTestTable.Insert();

        // [WHEN] Set the translations in two fields
        Translation.Set(TranslationTestTable, TranslationTestTable.FieldNo(TextField), Text1Txt);
        Translation.Set(TranslationTestTable, TranslationTestTable.FieldNo(TextField), 1030, Text2Txt);
        Translation.Set(TranslationTestTable, TranslationTestTable.FieldNo(SecondTextField), Text3Txt);

        // [WHEN] Delete the the translations for one field
        Translation.Delete(TranslationTestTable, TranslationTestTable.FieldNo(TextField));

        // [THEN] The translation for the field is deleted and for the second is not
        Assert.AreEqual('', Translation.Get(TranslationTestTable, TranslationTestTable.FieldNo(TextField)),
            'The translation should have been deleted');
        Assert.AreEqual(Text3Txt, Translation.Get(TranslationTestTable, TranslationTestTable.FieldNo(SecondTextField)),
            'Incorrect translation retrieved for the second text field');

        // [WHEN] Delete the the translations for all the fields
        Translation.Delete(TranslationTestTable);

        // [THEN] The translation for the other field is deleted too
        Assert.AreEqual('', Translation.Get(TranslationTestTable, TranslationTestTable.FieldNo(SecondTextField)),
            'The translation should have been deleted');
    end;

    [Test]
    [HandlerFunctions('HandleLanguagePage')]
    [Scope('OnPrem')]
    procedure TestRetrivalAndStorageThroughUI()
    var
        TranslationTestTable: Record "Translation Test Table";
        TranslationTestPage: TestPage "Translation Test Page";
        TranslationPage: TestPage Translation;
        Translation2: Text;
        Translation3: Text;
        Translation4: Text;
    begin
        // [SCENARIO] Tests if the Translation page shows the correct values stored
        Initialize();

        PermissionsMock.Set(TranslationEditRoleTok);

        // [GIVEN] Create a record for which data in fields can be translated
        TranslationTestTable.Init();
        TranslationTestTable.PK := 1;
        TranslationTestTable.Insert();

        // [GIVEN] Set the translations in Global and another language
        Translation.Set(TranslationTestTable, TranslationTestTable.FieldNo(TextField), Text1Txt);
        Translation.Set(TranslationTestTable, TranslationTestTable.FieldNo(TextField), 1030, Text2Txt);

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
        TranslationPage.LanguageName.AssertEquals('Danish');
        TranslationPage.Value.AssertEquals(Text2Txt);
        TranslationPage.Last();
        TranslationPage.LanguageName.AssertEquals('English');
        TranslationPage.Value.AssertEquals(Text1Txt);

        // [WHEN] Edit the ENU record
        TranslationPage.Value.SetValue(Text3Txt);
        TranslationPage.Next();

        // [WHEN] Add a new translation for FRA
        TranslationPage.LanguageName.AssistEdit(); // pops out the Languages page handled by the Modal Handler
        TranslationPage.Value.SetValue(Text4Txt);
        TranslationPage.Next();

        // [THEN] Verify translation records
        Translation3 := Translation.Get(TranslationTestTable, TranslationTestTable.FieldNo(TextField));
        Translation2 := Translation.Get(TranslationTestTable, TranslationTestTable.FieldNo(TextField), 1030);
        Translation4 := Translation.Get(TranslationTestTable, TranslationTestTable.FieldNo(TextField), 1036);
        Assert.AreEqual(Text3Txt, Translation3, 'Incorrect translation stored for global language');
        Assert.AreEqual(Text2Txt, Translation2, 'Incorrect translation stored for DAN language');
        Assert.AreEqual(Text4Txt, Translation4, 'Incorrect translation stored for FRA language');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetTranslationRequestedLanguageMissing()
    var
        TranslationTestTable: Record "Translation Test Table";
    begin
        // [SCENARIO] GetTranslation returns an empty string if the translation in the requested language is not found

        Initialize();
        PermissionsMock.Set(TranslationEditRoleTok);

        // [GIVEN] Create a record in TableA
        CreateRecord(TranslationTestTable);

        // [GIVEN] Set translation for the FieldA in French language
        Translation.Set(TranslationTestTable, TranslationTestTable.FieldNo(TextField), GetFrenchLanguageId(), Text2Txt);

        // [WHEN] Get translation for the Danish language
        // [THEN] Empty string is returned
        Assert.AreEqual(
            '', Translation.Get(TranslationTestTable, TranslationTestTable.FieldNo(TextField), GetDanishLanguageId()),
            'Translation string must be empty');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure GetTranslationGlobalLanguageTextMissing()
    var
        TranslationTestTable: Record "Translation Test Table";
        Languages: List of [Integer];
    begin
        // [SCENARIO] GetTranslation returns the translation in Windows global language if the translation in the requested language is not found

        Initialize();

        // [GIVEN] Change the global language so it does not match the system language (assume system language is English, and application language is French)
        Languages := GetLanguagesListExcludingSystem();
        GlobalLanguage(GetNextAvailableLanguage(Languages));

        // Reset initialization, so that the next test restores the global language
        IsInitialzied := false;

        PermissionsMock.Set(TranslationEditRoleTok);

        // [GIVEN] Create a record in TableA
        CreateRecord(TranslationTestTable);

        // [GIVEN] Set translation for the FieldA in English language (Windows language)
        Translation.Set(TranslationTestTable, TranslationTestTable.FieldNo(TextField), WindowsLanguage(), Text1Txt);

        // [WHEN] Get translation for global app language (French)
        // [THEN] French translation is not found, so English translation is returned instead
        Assert.AreEqual(
            Text1Txt, Translation.Get(TranslationTestTable, TranslationTestTable.FieldNo(TextField)), 'Incorrect translation retrieved.');
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

        PermissionsMock.Set(TranslationEditRoleTok);

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
        TranslationPage.LanguageName.AssertEquals('Danish');
        TranslationPage.Value.AssertEquals(CalculateValue(TranslationTestTableA, Text2Txt));
        TranslationPage.Next();
        TranslationPage.LanguageName.AssertEquals('Danish');
        TranslationPage.Value.AssertEquals(CalculateValue(TranslationTestTableB, Text2Txt));
        TranslationPage.Next();
        TranslationPage.LanguageName.AssertEquals('Danish');
        TranslationPage.Value.AssertEquals(CalculateValue(TranslationTestTableC, Text2Txt));
        TranslationPage.Next();
        TranslationPage.LanguageName.AssertEquals('English');
        TranslationPage.Value.AssertEquals(CalculateValue(TranslationTestTableA, Text1Txt));
        TranslationPage.Next();
        TranslationPage.LanguageName.AssertEquals('English');
        TranslationPage.Value.AssertEquals(CalculateValue(TranslationTestTableB, Text1Txt));
        TranslationPage.Next();
        TranslationPage.LanguageName.AssertEquals('English');
        TranslationPage.Value.AssertEquals(CalculateValue(TranslationTestTableC, Text1Txt));
        TranslationPage.Next();
        TranslationPage.LanguageName.AssertEquals('Afrikaans (South Africa)');
        TranslationPage.Value.AssertEquals(CalculateValue(TranslationTestTableA, Text5Txt));
        TranslationPage.Next();
        TranslationPage.LanguageName.AssertEquals('Afrikaans (South Africa)');
        TranslationPage.Value.AssertEquals(CalculateValue(TranslationTestTableB, Text5Txt));
        TranslationPage.Next();
        TranslationPage.LanguageName.AssertEquals('Afrikaans (South Africa)');
        TranslationPage.Value.AssertEquals(CalculateValue(TranslationTestTableC, Text5Txt));
        TranslationPage.Next();
        Assert.IsFalse(TranslationPage.Next(), 'No more records should be available.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestCopyTranslations()
    var
        TranslationTestTable: Record "Translation Test Table";
        TargetTranslationTestTable: Record "Translation Test Table";
    begin
        // [SCENARIO] Translation can be copied for a specified field when the field ID matches in the source and destination tables
        Initialize();

        // [GIVEN] Create two records for which data in fields can be translated
        CreateRecord(TranslationTestTable);
        CreateRecord(TargetTranslationTestTable);

        // [WHEN] Set the translations in two fields
        Translation.Set(TranslationTestTable, TranslationTestTable.FieldNo(TextField), Text1Txt);
        Translation.Set(TranslationTestTable, TranslationTestTable.FieldNo(TextField), 1030, Text2Txt);
        Translation.Set(TranslationTestTable, TranslationTestTable.FieldNo(SecondTextField), Text3Txt);

        // [WHEN] Copy the the translations for one field
        Translation.Copy(TranslationTestTable, TargetTranslationTestTable, TranslationTestTable.FieldNo(TextField));

        // [THEN] The translation for the field is copied and for the second is not
        Assert.AreEqual(Text1Txt, Translation.Get(TargetTranslationTestTable, TargetTranslationTestTable.FieldNo(TextField)),
            'The translation should have been copied');
        Assert.AreEqual(Text2Txt, Translation.Get(TargetTranslationTestTable, TargetTranslationTestTable.FieldNo(TextField), 1030),
            'The translation should have been copied');
        Assert.AreEqual('', Translation.Get(TargetTranslationTestTable, TranslationTestTable.FieldNo(SecondTextField)),
            'The 2nd translation should not have been copied');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CopyTranslationIntoAnotherField()
    var
        TranslationRec: Record Translation;
        TranslationTestTable: Record "Translation Test Table";
    begin
        // [SCENARIO] Translation can be copied into another field

        Initialize();
        PermissionsMock.Set(TranslationEditRoleTok);

        // [GIVEN] Create a record in TableA and set a translation for the FieldA
        CreateRecord(TranslationTestTable);
        Translation.Set(TranslationTestTable, TranslationTestTable.FieldNo(TextField), Text1Txt);

        // [WHEN] Copy the translation into the tableB, field FieldB
        Translation.Copy(TranslationTestTable, TranslationTestTable.FieldNo(TextField), TranslationRec, TranslationRec.FieldNo(Value));

        // [THEN] The translation has ben copied
        Assert.AreEqual(Text1Txt, Translation.Get(TranslationRec, TranslationRec.FieldNo(Value)), 'Translation must be copied.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CopyTranslationRecordRefs()
    var
        TranslationTestTable: Record "Translation Test Table";
        SourceRecRef: RecordRef;
        DestRecRef: RecordRef;
    begin
        // [SCENARIO] Translation must be copied if the source and destination tables are sent as RecordRef

        Initialize();
        PermissionsMock.Set(TranslationEditRoleTok);

        // [GIVEN] Create a record in TableA and set a translation for the fields FieldA and FieldB
        CreateRecord(TranslationTestTable);
        Translation.Set(TranslationTestTable, TranslationTestTable.FieldNo(TextField), Text1Txt);
        Translation.Set(TranslationTestTable, TranslationTestTable.FieldNo(SecondTextField), Text2Txt);

        // [GIVEN] Get a RecordRef from the record (SourceRecRef)
        SourceRecRef.GetTable(TranslationTestTable);

        // [GIVEN] Create another record in the TableA, without translation, and get a RecordRef for this record (DestRecRef)
        CreateRecord(TranslationTestTable);
        DestRecRef.GetTable(TranslationTestTable);

        // [WHEN] Copy the translation from SourceRecRef into DestRecRef
        Translation.Copy(SourceRecRef, DestRecRef);

        // [THEN] The translation for fields FieldA and FieldB has been copied
        Assert.AreEqual(Text1Txt, Translation.Get(DestRecRef, TranslationTestTable.FieldNo(TextField)), 'Translation must be copied.');
        Assert.AreEqual(Text2Txt, Translation.Get(DestRecRef, TranslationTestTable.FieldNo(SecondTextField)), 'Translation must be copied.');
    end;

    [Test]
    [Scope('OnPrem')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestCopyTranslationForDifferentRecords()
    var
        TranslationTestTable: Record "Translation Test Table";
        TranslationTestTable2: Record Translation;
    begin
        // [SCENARIO] Checks for an error message when translation is copied from one to another table
        Initialize();

        // [GIVEN] A record on one table is created
        CreateRecord(TranslationTestTable);

        // [GIVEN] A record of another table is created
        TranslationTestTable2.Init();
        TranslationTestTable2."Language ID" := 1;
        TranslationTestTable2."System ID" := CreateGuid();
        TranslationTestTable2."Field ID" := 1;
        TranslationTestTable2.Insert();

        // [WHEN] Translation is copied
        asserterror Translation.Copy(TranslationTestTable, TranslationTestTable2);

        // [THEN] Error is raised
        Assert.ExpectedError(DifferentTableErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestCopyTranslationForNonRecord()
    var
        TranslationTestTable: Record "Translation Test Table";
        TxtValue: Text;
    begin
        // [SCENARIO] Checks for an error message when translation is copied to non-table.
        Initialize();

        // [GIVEN] A record on one table is created
        CreateRecord(TranslationTestTable);

        // [WHEN] Translation is copied
        asserterror Translation.Copy(TranslationTestTable, TxtValue);

        // [THEN] Error is raised
        Assert.ExpectedError(NoRecordIdErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestTranslateForTemporaryRecords()
    var
        TempTranslationTestTable: Record "Translation Test Table" temporary;
    begin
        // [SCENARIO] Checks for an error message when translation is set for a temporary record
        Initialize();

        PermissionsMock.Set(TranslationEditRoleTok);

        // [GIVEN] A record in a temporary table is created
        CreateRecord(TempTranslationTestTable);

        // [WHEN] Translation is set on it
        asserterror Translation.Set(TempTranslationTestTable, TempTranslationTestTable.FieldNo(TextField),
          CalculateValue(TempTranslationTestTable, Text1Txt));

        // [THEN] Error is raised
        Assert.ExpectedError(CannotTranslateTempRecErr);
    end;

    local procedure Initialize()
    var
        TranslationTestTable: Record "Translation Test Table";
        Language: Codeunit Language;
    begin
        // Set ENU to global language
        TranslationTestTable.DeleteAll(true);

        if IsInitialzied then
            exit;

        GlobalLanguage(Language.GetDefaultApplicationLanguageId());

        CreateLanguage('ENU', 'English', GetEnglishLanguageId());
        CreateLanguage('DAN', 'Danish', GetDanishLanguageId());
        CreateLanguage('FRA', 'French', GetFrenchLanguageId());

        IsInitialzied := true;
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
    begin
        CreateRecord(TranslationTestTable);
        Translation.Set(TranslationTestTable, TranslationTestTable.FieldNo(TextField),
          CalculateValue(TranslationTestTable, Text1Txt));
        Translation.Set(TranslationTestTable, TranslationTestTable.FieldNo(TextField), 1030,
          CalculateValue(TranslationTestTable, Text2Txt));
        Translation.Set(TranslationTestTable, TranslationTestTable.FieldNo(TextField), 1078,
          CalculateValue(TranslationTestTable, Text5Txt));
    end;

    local procedure CreateRecord(var TranslationTestTable: Record "Translation Test Table")
    var
        LastId: Integer;
    begin
        if TranslationTestTable.FindLast() then
            LastId := TranslationTestTable.PK;
        TranslationTestTable.Init();
        TranslationTestTable.PK := LastId + 1;
        TranslationTestTable.Insert();
    end;

    local procedure CalculateValue(TranslationTestTable: Record "Translation Test Table"; OrigValue: Text): Text[2048]
    var
        TranslationTextTxt: Label '%1-%2', Comment = '%1: Primary key value, %2: Source text for translation', Locked = true;
    begin
        exit(CopyStr(StrSubstNo(TranslationTextTxt, TranslationTestTable.PK, OrigValue), 1, 2048));
    end;

    local procedure GetDanishLanguageId(): Integer
    begin
        exit(1030);
    end;

    local procedure GetEnglishLanguageId(): Integer
    begin
        exit(1033);
    end;

    local procedure GetFrenchLanguageId(): Integer
    begin
        exit(1036);
    end;

    local procedure GetLanguagesListExcludingSystem(): List of [Integer]
    var
        Language: Record Language;
        Languages: List of [Integer];
    begin
        Language.SetFilter("Windows Language ID", '<>%1', WindowsLanguage());
        Language.FindSet();
        repeat
            Languages.Add(Language."Windows Language ID");
        until Language.Next() = 0;

        exit(Languages);
    end;

    local procedure GetNextAvailableLanguage(var Languages: List of [Integer]): Integer
    var
        LangID: Integer;
    begin
        LangID := Languages.Get(1);
        Languages.RemoveAt(1);
        exit(LangID);
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
