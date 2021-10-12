// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135159 "Data Class. Worksheet Tests"
{
    Subtype = Test;
    Permissions = tabledata "Data Sensitivity" = d,
                  tabledata "Fields Sync Status" = r;

    var
        LibraryAssert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";
        NotificationCount: Integer;

    [Test]
    [Scope('OnPrem')]
    procedure TestEditList()
    var
        DataSensitivity: Record "Data Sensitivity";
        DataPrivacyEntities: Record "Data Privacy Entities";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
        DataClassificationWorksheet: TestPage "Data Classification Worksheet";
    begin
        // [GIVEN] The Data Sensitivity table contains a single entry

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Data Class Edit');

        DataSensitivity.DeleteAll();
        DataClassificationMgt.InsertDataSensitivityForField(Database::"Data Privacy Entities",
           DataPrivacyEntities.FieldNo("Key Field No."), DataSensitivity."Data Sensitivity"::Unclassified);

        // [GIVEN] The Data Classification Worksheet page is open for editing
        DataClassificationWorksheet.OpenEdit();

        // [WHEN] Editing the Data Sensitivity column
        DataClassificationWorksheet."Data Sensitivity".SetValue(DataSensitivity."Data Sensitivity"::"Company Confidential");

        // [THEN] The entry has the correct Data Sensitivity
        LibraryAssert.AreEqual(Format(DataSensitivity."Data Sensitivity"::"Company Confidential"),
            DataClassificationWorksheet."Data Sensitivity".Value(), 'The Data Sensitivity is incorrect');

        // [THEN] The Last Modified field is updated
        LibraryAssert.AreNotEqual(0DT, DataClassificationWorksheet."Last Modified".Value(),
            'The Last Modified field should not be empty');

        // [THEN] The Last Modified By field is updated
        LibraryAssert.AreNotEqual('', DataClassificationWorksheet.LastModifiedBy.Value(),
            'The Last Modified By value should not be empty');

        DataClassificationWorksheet.Close();
    end;

    [Test]
    [HandlerFunctions('DataClassificationWizardHandler')]
    [Scope('OnPrem')]
    procedure TestSetupDataClassifications()
    var
        DataClassificationWorksheet: TestPage "Data Classification Worksheet";
    begin
        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Data Class Edit');

        // [GIVEN] The Data Classification Worksheet page is open for editing
        DataClassificationWorksheet.OpenEdit();

        // [WHEN] Clicking Set Up Data Classifications
        // [THEN] The Data Classification Wizard is displayed
        DataClassificationWorksheet."Set Up Data Classifications".Invoke();

        DataClassificationWorksheet.Close();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestFindNewFieldsForEmptyDataSensitivityTable()
    var
        DataSensitivity: Record "Data Sensitivity";
        Field: Record Field;
        FieldsSyncStatus: Record "Fields Sync Status";
        DataClassificationMgtImpl: Codeunit "Data Classification Mgt. Impl.";
        DataClassificationWorksheet: TestPage "Data Classification Worksheet";
        FieldCount: Integer;
    begin
        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Data Class Edit');

        // [GIVEN] The number of enabled, sensitive, normal fields
        Field.SetRange(Class, Field.Class::Normal);
        DataClassificationMgtImpl.GetEnabledSensitiveFields(Field);
        FieldCount := Field.Count();

        // [GIVEN] The Data Classification Worksheet page is open for editing
        DataClassificationWorksheet.OpenEdit();

        // [GIVEN] The Data Sensitivity table is empty
        DataSensitivity.DeleteAll();

        // [WHEN] Invoking the Find New Fields action
        DataClassificationWorksheet."Find New Fields".Invoke();

        // [THEN] There should be FieldCount entries in the Data Sensitivity table
        LibraryAssert.AreEqual(FieldCount, DataSensitivity.Count(), 'The number of entries in the Data Sensitivity table is incorrect');

        // [THEN] All the entries in the Data Sensitivity table should be unclassified
        DataSensitivity.SetRange("Data Sensitivity", DataSensitivity."Data Sensitivity"::Unclassified);
        LibraryAssert.AreEqual(FieldCount, DataSensitivity.Count(), 'Not all the fields are unclassified');

        // [THEN] The Fields Sync Status table is not empty
        LibraryAssert.AreNotEqual(0, FieldsSyncStatus.Count(), 'The Fields Sync Status table cannot be empty');

        DataClassificationWorksheet.Close();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestFindNewFields()
    var
        DataSensitivity: Record "Data Sensitivity";
        FieldsSyncStatus: Record "Fields Sync Status";
        Field: Record Field;
        DataClassificationMgtImpl: Codeunit "Data Classification Mgt. Impl.";
        DataClassificationWorksheet: TestPage "Data Classification Worksheet";
        TableNo: Integer;
        UnclassifiedFieldNo: Integer;
        SensitiveFieldNo: Integer;
        FieldCount: Integer;
    begin
        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Data Class Edit');

        // [GIVEN] The Data Sensitivity table contains two entries - one that is classified and one that isn't
        DataSensitivity.DeleteAll();
        TableNo := 50000;
        SensitiveFieldNo := 1;
        UnclassifiedFieldNo := 2;
        DataClassificationMgtImpl.InsertDataSensitivityForField(TableNo, SensitiveFieldNo, DataSensitivity."Data Sensitivity"::Personal);
        DataClassificationMgtImpl.InsertDataSensitivityForField(TableNo, UnclassifiedFieldNo, DataSensitivity."Data Sensitivity"::Unclassified);

        // [GIVEN] The number of enabled, sensitive, normal fields
        Field.SetRange(Class, Field.Class::Normal);
        DataClassificationMgtImpl.GetEnabledSensitiveFields(Field);
        FieldCount := Field.Count();

        // [GIVEN] The Data Classification Worksheet page is open for editing
        DataClassificationWorksheet.OpenEdit();

        // [WHEN] Invoking the Find New Fields action
        DataClassificationWorksheet."Find New Fields".Invoke();

        // [THEN] The number of fields in the Data Sensitivity table should be the FieldCount + 1
        LibraryAssert.AreEqual(FieldCount + 1, DataSensitivity.Count(), 'The tables have not been synchronized correctly');

        // [THEN] FieldCount entries in the Data Sensitivity table should be unclassified
        DataSensitivity.SetRange("Data Sensitivity", DataSensitivity."Data Sensitivity"::Unclassified);
        LibraryAssert.AreEqual(FieldCount, DataSensitivity.Count(), 'Not all the fields are unclassified');

        // [THEN] The Data Sensitivity should still contain the initial sensitive field
        DataSensitivity.Reset();
        DataSensitivity.SetRange("Table No", TableNo);
        DataSensitivity.SetRange("Field No", SensitiveFieldNo);
        LibraryAssert.AreEqual(1, DataSensitivity.Count(),
          'The Data Sensitivity table should still contain the initial sensitive field');

        // [THEN] The Data Sensitivity should not contain the initial unclassified field anymore
        DataSensitivity.SetRange("Field No", UnclassifiedFieldNo);
        LibraryAssert.AreEqual(0, DataSensitivity.Count(),
          'The Data Sensitivity table should not contain the initial unclassified field anymore');

        // [THEN] The Fields Sync Status table is not empty
        LibraryAssert.AreNotEqual(0, FieldsSyncStatus.Count(), 'The Fields Sync Status table cannot be empty');

        DataClassificationWorksheet.Close();
    end;

    [Test]
    [HandlerFunctions('TextFieldContentBufferHandler')]
    [Scope('OnPrem')]
    procedure TestShowFieldContentForTextField()
    var
        DataSensitivity: Record "Data Sensitivity";
        DataPrivacyEntities: Record "Data Privacy Entities";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
        DataClassificationWorksheet: TestPage "Data Classification Worksheet";
    begin
        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Data Class Edit');

        // [GIVEN] The Data Sensitivity table contains an entry for a field of type Text
        DataSensitivity.DeleteAll();
        DataClassificationMgt.InsertDataSensitivityForField(Database::"Data Privacy Entities",
            DataPrivacyEntities.FieldNo("Table Caption"), DataSensitivity."Data Sensitivity"::Unclassified);

        // [GIVEN] The Data Classification Worksheet page is open for editing
        DataClassificationWorksheet.OpenEdit();

        // [THEN] The Show Field Content action should be enabled
        LibraryAssert.IsTrue(DataClassificationWorksheet."Show Field Content".Enabled(), 'The Show Field Content action should be enabled');

        // [GIVEN] Data Privacy Entities (the table that is listed in the Data Classification Worksheet) contains two entries
        DataPrivacyEntities.DeleteAll();
        InsertDataPrivacyEntitiy(Database::"Data Privacy Entities");
        InsertDataPrivacyEntitiy(Database::"Data Sensitivity");

        // [WHEN] Invoking Show Field Content
        // [THEN] The data on the Field Content Buffer page should reflect the contents of the Data Privacy Entities table
        // (the verification is in TextFieldContentBufferHandler)
        DataClassificationWorksheet."Show Field Content".Invoke();

        DataClassificationWorksheet.Close();
    end;

    [Test]
    [HandlerFunctions('CodeFieldContentBufferHandler')]
    [Scope('OnPrem')]
    procedure TestShowFieldContentForCodeField()
    var
        DataSensitivity: Record "Data Sensitivity";
        FieldSyncStatus: Record "Fields Sync Status";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
        DataClassificationWorksheet: TestPage "Data Classification Worksheet";
    begin
        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Data Class Edit');

        // [GIVEN] The Data Sensitivity table contains an entry for a field of type Code
        DataSensitivity.DeleteAll();
        DataClassificationMgt.InsertDataSensitivityForField(Database::"Fields Sync Status",
            FieldSyncStatus.FieldNo(ID), DataSensitivity."Data Sensitivity"::Unclassified);

        // [GIVEN] The Data Classification Worksheet page is open for editing
        DataClassificationWorksheet.OpenEdit();

        // [THEN] The Show Field Content action should be enabled
        LibraryAssert.IsTrue(DataClassificationWorksheet."Show Field Content".Enabled(), 'The Show Field Content action should be enabled');

        // [GIVEN] Field Sync Status (the table that is listed in the Data Classification Worksheet) contains 4 entries
        FieldSyncStatus.DeleteAll();
        InsertFieldSyncStatus('1');
        InsertFieldSyncStatus('2');
        InsertFieldSyncStatus('3');
        InsertFieldSyncStatus('4');

        // [WHEN] Invoking Show Field Content
        // [THEN] The data on the Field Content Buffer page should reflect the contents of the Field Sync Status table
        // (the verification is in CodeFieldContentBufferHandler)
        DataClassificationWorksheet."Show Field Content".Invoke();

        DataClassificationWorksheet.Close();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestShowFieldContentForOptionField()
    var
        DataSensitivity: Record "Data Sensitivity";
        DataPrivacyEntities: Record "Data Privacy Entities";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
        DataClassificationWorksheet: TestPage "Data Classification Worksheet";
    begin
        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Data Class Edit');

        // [GIVEN] The Data Sensitivity table contains an entry for a field of type Code
        DataSensitivity.DeleteAll();
        DataClassificationMgt.InsertDataSensitivityForField(Database::"Data Privacy Entities",
            DataPrivacyEntities.FieldNo(Status), DataSensitivity."Data Sensitivity"::Unclassified);

        // [GIVEN] The Data Classification Worksheet page is open for editing
        DataClassificationWorksheet.OpenEdit();

        // [THEN] The Show Field Content action should not be enabled
        LibraryAssert.IsFalse(DataClassificationWorksheet."Show Field Content".Enabled(), 'The Show Field Content action should be enabled');

        DataClassificationWorksheet.Close();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestViewUnclassifiedFields()
    var
        DataSensitivity: Record "Data Sensitivity";
        DataPrivacyEntities: Record "Data Privacy Entities";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
        DataClassificationWorksheet: TestPage "Data Classification Worksheet";
        TableNo: Integer;
        SensitiveFieldNo: Integer;
        UnclassifiedFieldNo: Integer;
    begin
        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Data Class Edit');

        TableNo := Database::"Data Privacy Entities";
        SensitiveFieldNo := DataPrivacyEntities.FieldNo("Similar Fields Label");
        UnclassifiedFieldNo := DataPrivacyEntities.FieldNo("Default Data Sensitivity");

        // [GIVEN] The Data Classification Worksheet page is open for editing
        DataClassificationWorksheet.OpenEdit();

        // [GIVEN] The Data Sensitivity table is empty
        DataSensitivity.DeleteAll();

        // [WHEN] Invoking View Unclassified
        DataClassificationWorksheet."View Unclassified".Invoke();

        // [THEN] The Data Sensitivity table is empty
        LibraryAssert.AreEqual(0, DataSensitivity.Count(), 'The Data Sensitivity table should be empty');

        // [THEN] The list is empty
        LibraryAssert.IsFalse(DataClassificationWorksheet.First(), 'The list should be empty');

        // [GIVEN] The Data Sensitivity table contains one record that is not unclassified
        DataClassificationMgt.InsertDataSensitivityForField(TableNo, SensitiveFieldNo, DataSensitivity."Data Sensitivity"::Sensitive);

        // [WHEN] Invoking the action again
        DataClassificationWorksheet."View Unclassified".Invoke();

        // [THEN] The list should remain empty
        LibraryAssert.IsFalse(DataClassificationWorksheet.First(), 'The list should be empty');

        // [GIVEN] The Data Sensitivity table contains an unclassified entry
        DataClassificationMgt.InsertDataSensitivityForField(TableNo, UnclassifiedFieldNo, DataSensitivity."Data Sensitivity"::Unclassified);

        // [WHEN] Invoking the action again
        DataClassificationWorksheet."View Unclassified".Invoke();

        // [THEN] The list should not be empty
        LibraryAssert.IsTrue(DataClassificationWorksheet.First(), 'The list should not be empty');

        // [THEN] The fields of the record are set correctly
        LibraryAssert.AreEqual(Format(DataSensitivity."Data Sensitivity"::Unclassified), DataClassificationWorksheet."Data Sensitivity".Value(),
            'The Data Sensitivity field should be unclassified');
        LibraryAssert.AreEqual(Format(TableNo), DataClassificationWorksheet."Table No".Value(), 'The Table No is incorrect');
        LibraryAssert.AreEqual(Format(UnclassifiedFieldNo), DataClassificationWorksheet."Field No".Value(), 'The Field No is incorrect');

        // [THEN] There shouldn't be any other entries on the page
        LibraryAssert.IsFalse(DataClassificationWorksheet.Next(), 'There should not be any other entries on the page');

        DataClassificationWorksheet.Close();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestViewSensitiveFields()
    var
        DataSensitivity: Record "Data Sensitivity";
        DataPrivacyEntities: Record "Data Privacy Entities";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
        DataClassificationWorksheet: TestPage "Data Classification Worksheet";
        TableNo: Integer;
        SensitiveFieldNo: Integer;
        UnclassifiedFieldNo: Integer;
    begin
        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Data Class Edit');

        TableNo := Database::"Data Privacy Entities";
        SensitiveFieldNo := DataPrivacyEntities.FieldNo("Similar Fields Label");
        UnclassifiedFieldNo := DataPrivacyEntities.FieldNo("Default Data Sensitivity");

        // [GIVEN] The Data Classification Worksheet page is open for editing
        DataClassificationWorksheet.OpenEdit();

        // [GIVEN] The Data Sensitivity table is empty
        DataSensitivity.DeleteAll();

        // [WHEN] Invoking View Sensitive
        DataClassificationWorksheet."View Sensitive".Invoke();

        // [THEN] The Data Sensitivity table is empty
        LibraryAssert.AreEqual(0, DataSensitivity.Count(), 'The Data Sensitivity table should be empty');

        // [THEN] The list is empty
        LibraryAssert.IsFalse(DataClassificationWorksheet.First(), 'The list should be empty');

        // [GIVEN] The Data Sensitivity table contains one record that is not sensitive
        DataClassificationMgt.InsertDataSensitivityForField(TableNo, UnclassifiedFieldNo, DataSensitivity."Data Sensitivity"::Unclassified);

        // [WHEN] Invoking the action again
        DataClassificationWorksheet."View Sensitive".Invoke();

        // [THEN] The list should remain empty
        LibraryAssert.IsFalse(DataClassificationWorksheet.First(), 'The list should be empty');

        // [GIVEN] The Data Sensitivity table contains a sensitive entry
        DataClassificationMgt.InsertDataSensitivityForField(TableNo, SensitiveFieldNo, DataSensitivity."Data Sensitivity"::Sensitive);

        // [WHEN] Invoking the action again
        DataClassificationWorksheet."View Sensitive".Invoke();

        // [THEN] The list should not be empty
        LibraryAssert.IsTrue(DataClassificationWorksheet.First(), 'The list should not be empty');

        // [THEN] The fields of the record are set correctly
        LibraryAssert.AreEqual(Format(DataSensitivity."Data Sensitivity"::Sensitive), DataClassificationWorksheet."Data Sensitivity".Value(),
            'The Data Sensitivity field should be sensitive');
        LibraryAssert.AreEqual(Format(TableNo), DataClassificationWorksheet."Table No".Value(), 'The Table No is incorrect');
        LibraryAssert.AreEqual(Format(SensitiveFieldNo), DataClassificationWorksheet."Field No".Value(), 'The Field No is incorrect');

        // [THEN] There shouldn't be any other entries on the page
        LibraryAssert.IsFalse(DataClassificationWorksheet.Next(), 'There should not be any other entries on the page');

        DataClassificationWorksheet.Close();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestViewPersonalFields()
    var
        DataSensitivity: Record "Data Sensitivity";
        DataPrivacyEntities: Record "Data Privacy Entities";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
        DataClassificationWorksheet: TestPage "Data Classification Worksheet";
        TableNo: Integer;
        PersonalFieldNo: Integer;
        CompanyConfidentialFieldNo: Integer;
    begin
        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Data Class Edit');

        TableNo := Database::"Data Privacy Entities";
        PersonalFieldNo := DataPrivacyEntities.FieldNo("Similar Fields Label");
        CompanyConfidentialFieldNo := DataPrivacyEntities.FieldNo("Default Data Sensitivity");

        // [GIVEN] The Data Classification Worksheet page is open for editing
        DataClassificationWorksheet.OpenEdit();

        // [GIVEN] The Data Sensitivity table is empty
        DataSensitivity.DeleteAll();

        // [WHEN] Invoking View Personal
        DataClassificationWorksheet."View Personal".Invoke();

        // [THEN] The Data Sensitivity table is empty
        LibraryAssert.AreEqual(0, DataSensitivity.Count(), 'The Data Sensitivity table should be empty');

        // [THEN] The list is empty
        LibraryAssert.IsFalse(DataClassificationWorksheet.First(), 'The list should be empty');

        // [GIVEN] The Data Sensitivity table contains one record that is not personal
        DataClassificationMgt.InsertDataSensitivityForField(TableNo,
            CompanyConfidentialFieldNo, DataSensitivity."Data Sensitivity"::"Company Confidential");

        // [WHEN] Invoking the action again
        DataClassificationWorksheet."View Personal".Invoke();

        // [THEN] The list should remain empty
        LibraryAssert.IsFalse(DataClassificationWorksheet.First(), 'The list should be empty');

        // [GIVEN] The Data Sensitivity table contains a personal entry
        DataClassificationMgt.InsertDataSensitivityForField(TableNo, PersonalFieldNo, DataSensitivity."Data Sensitivity"::Personal);

        // [WHEN] Invoking the action again
        DataClassificationWorksheet."View Personal".Invoke();

        // [THEN] The list should not be empty
        LibraryAssert.IsTrue(DataClassificationWorksheet.First(), 'The list should not be empty');

        // [THEN] The fields of the record are set correctly
        LibraryAssert.AreEqual(Format(DataSensitivity."Data Sensitivity"::Personal), DataClassificationWorksheet."Data Sensitivity".Value(),
            'The Data Sensitivity field should be personal');
        LibraryAssert.AreEqual(Format(TableNo), DataClassificationWorksheet."Table No".Value(), 'The Table No is incorrect');
        LibraryAssert.AreEqual(Format(PersonalFieldNo), DataClassificationWorksheet."Field No".Value(), 'The Field No is incorrect');

        // [THEN] There shouldn't be any other entries on the page
        LibraryAssert.IsFalse(DataClassificationWorksheet.Next(), 'There should not be any other entries on the page');

        DataClassificationWorksheet.Close();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestViewNormalFields()
    var
        DataSensitivity: Record "Data Sensitivity";
        DataPrivacyEntities: Record "Data Privacy Entities";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
        DataClassificationWorksheet: TestPage "Data Classification Worksheet";
        TableNo: Integer;
        NormalFieldNo: Integer;
        CompanyConfidentialFieldNo: Integer;
    begin
        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Data Class Edit');

        TableNo := Database::"Data Privacy Entities";
        NormalFieldNo := DataPrivacyEntities.FieldNo("Similar Fields Label");
        CompanyConfidentialFieldNo := DataPrivacyEntities.FieldNo("Default Data Sensitivity");

        // [GIVEN] The Data Classification Worksheet page is open for editing
        DataClassificationWorksheet.OpenEdit();

        // [GIVEN] The Data Sensitivity table is empty
        DataSensitivity.DeleteAll();

        // [WHEN] Invoking View Normal
        DataClassificationWorksheet."View Normal".Invoke();

        // [THEN] The Data Sensitivity table is empty
        LibraryAssert.AreEqual(0, DataSensitivity.Count(), 'The Data Sensitivity table should be empty');

        // [THEN] The list is empty
        LibraryAssert.IsFalse(DataClassificationWorksheet.First(), 'The list should be empty');

        // [GIVEN] The Data Sensitivity table contains one record that is not normal
        DataClassificationMgt.InsertDataSensitivityForField(TableNo,
            CompanyConfidentialFieldNo, DataSensitivity."Data Sensitivity"::"Company Confidential");

        // [WHEN] Invoking the action again
        DataClassificationWorksheet."View Normal".Invoke();

        // [THEN] The list should remain empty
        LibraryAssert.IsFalse(DataClassificationWorksheet.First(), 'The list should be empty');

        // [GIVEN] The Data Sensitivity table contains a normal entry
        DataClassificationMgt.InsertDataSensitivityForField(TableNo, NormalFieldNo, DataSensitivity."Data Sensitivity"::Normal);

        // [WHEN] Invoking the action again
        DataClassificationWorksheet."View Normal".Invoke();

        // [THEN] The list should not be empty
        LibraryAssert.IsTrue(DataClassificationWorksheet.First(), 'The list should not be empty');

        // [THEN] The fields of the record are set correctly
        LibraryAssert.AreEqual(Format(DataSensitivity."Data Sensitivity"::Normal), DataClassificationWorksheet."Data Sensitivity".Value(),
            'The Data Sensitivity field should be normal');
        LibraryAssert.AreEqual(Format(TableNo), DataClassificationWorksheet."Table No".Value(), 'The Table No is incorrect');
        LibraryAssert.AreEqual(Format(NormalFieldNo), DataClassificationWorksheet."Field No".Value(), 'The Field No is incorrect');

        // [THEN] There shouldn't be any other entries on the page
        LibraryAssert.IsFalse(DataClassificationWorksheet.Next(), 'There should not be any other entries on the page');

        DataClassificationWorksheet.Close();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestViewCompanyConfidentialFields()
    var
        DataSensitivity: Record "Data Sensitivity";
        DataPrivacyEntities: Record "Data Privacy Entities";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
        DataClassificationWorksheet: TestPage "Data Classification Worksheet";
        TableNo: Integer;
        PersonalFieldNo: Integer;
        CompanyConfidentialFieldNo: Integer;
    begin
        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Data Class Edit');

        TableNo := Database::"Data Privacy Entities";
        PersonalFieldNo := DataPrivacyEntities.FieldNo("Similar Fields Label");
        CompanyConfidentialFieldNo := DataPrivacyEntities.FieldNo("Default Data Sensitivity");

        // [GIVEN] The Data Classification Worksheet page is open for editing
        DataClassificationWorksheet.OpenEdit();

        // [GIVEN] The Data Sensitivity table is empty
        DataSensitivity.DeleteAll();

        // [WHEN] Invoking View Company Confidential
        DataClassificationWorksheet."View Company Confidential".Invoke();

        // [THEN] The Data Sensitivity table is empty
        LibraryAssert.AreEqual(0, DataSensitivity.Count(), 'The Data Sensitivity table should be empty');

        // [THEN] The list is empty
        LibraryAssert.IsFalse(DataClassificationWorksheet.First(), 'The list should be empty');

        // [GIVEN] The Data Sensitivity table contains one record that is not company confidential
        DataClassificationMgt.InsertDataSensitivityForField(TableNo,
            PersonalFieldNo, DataSensitivity."Data Sensitivity"::Personal);

        // [WHEN] Invoking the action again
        DataClassificationWorksheet."View Company Confidential".Invoke();

        // [THEN] The list should remain empty
        LibraryAssert.IsFalse(DataClassificationWorksheet.First(), 'The list should be empty');

        // [GIVEN] The Data Sensitivity table contains a company confidential entry
        DataClassificationMgt.InsertDataSensitivityForField(TableNo,
            CompanyConfidentialFieldNo, DataSensitivity."Data Sensitivity"::"Company Confidential");

        // [WHEN] Invoking the action again
        DataClassificationWorksheet."View Company Confidential".Invoke();

        // [THEN] The list should not be empty
        LibraryAssert.IsTrue(DataClassificationWorksheet.First(), 'The list should not be empty');

        // [THEN] The fields of the record are set correctly
        LibraryAssert.AreEqual(Format(DataSensitivity."Data Sensitivity"::"Company Confidential"),
            DataClassificationWorksheet."Data Sensitivity".Value(), 'The Data Sensitivity field should be company confidential');
        LibraryAssert.AreEqual(Format(TableNo), DataClassificationWorksheet."Table No".Value(), 'The Table No is incorrect');
        LibraryAssert.AreEqual(Format(CompanyConfidentialFieldNo), DataClassificationWorksheet."Field No".Value(), 'The Field No is incorrect');

        // [THEN] There shouldn't be any other entries on the page
        LibraryAssert.IsFalse(DataClassificationWorksheet.Next(), 'There should not be any other entries on the page');

        DataClassificationWorksheet.Close();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestViewAll()
    var
        DataSensitivity: Record "Data Sensitivity";
        DataPrivacyEntities: Record "Data Privacy Entities";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
        DataClassificationWorksheet: TestPage "Data Classification Worksheet";
        TableNo: Integer;
        UnclassifiedFieldNo: Integer;
        SensitiveFieldNo: Integer;
        NormalFieldNo1: Integer;
        NormalFieldNo2: Integer;
        PersonalFieldNo: Integer;
        CompanyConfidentialFieldNo: Integer;
    begin
        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Data Class Edit');

        // [GIVEN] 6 entries in the Data Sensitive table - one for each Data Sensitivity option 
        // and an additional one for Normal sensitivity
        TableNo := Database::"Data Privacy Entities";
        UnclassifiedFieldNo := DataPrivacyEntities.FieldNo("Table No.");
        SensitiveFieldNo := DataPrivacyEntities.FieldNo("Key Field No.");
        NormalFieldNo1 := DataPrivacyEntities.FieldNo(Include);
        NormalFieldNo2 := DataPrivacyEntities.FieldNo(Reviewed);
        PersonalFieldNo := DataPrivacyEntities.FieldNo("Similar Fields Label");
        CompanyConfidentialFieldNo := DataPrivacyEntities.FieldNo("Default Data Sensitivity");

        DataSensitivity.DeleteAll();
        DataClassificationMgt.InsertDataSensitivityForField(TableNo,
            UnclassifiedFieldNo, DataSensitivity."Data Sensitivity"::Unclassified);
        DataClassificationMgt.InsertDataSensitivityForField(TableNo,
            SensitiveFieldNo, DataSensitivity."Data Sensitivity"::Sensitive);
        DataClassificationMgt.InsertDataSensitivityForField(TableNo,
            NormalFieldNo1, DataSensitivity."Data Sensitivity"::Normal);
        DataClassificationMgt.InsertDataSensitivityForField(TableNo,
            NormalFieldNo2, DataSensitivity."Data Sensitivity"::Normal);
        DataClassificationMgt.InsertDataSensitivityForField(TableNo,
            PersonalFieldNo, DataSensitivity."Data Sensitivity"::Personal);
        DataClassificationMgt.InsertDataSensitivityForField(TableNo,
            CompanyConfidentialFieldNo, DataSensitivity."Data Sensitivity"::"Company Confidential");

        // [GIVEN] The Data Classification Worksheet page is open for editing
        DataClassificationWorksheet.OpenEdit();

        // [WHEN] Invoking View Normal
        DataClassificationWorksheet."View Normal".Invoke();

        // [THEN] All the normal rows in the Data Sensitivity table should be displayed on the page
        DataSensitivity.SetRange("Data Sensitivity", DataSensitivity."Data Sensitivity"::Normal);
        LibraryAssert.IsTrue(VerifyThatFieldsAreDisplayedOnPage(DataSensitivity, DataClassificationWorksheet),
            'Not all the Normal rows are displayed');

        // [WHEN] Invoking View All
        DataClassificationWorksheet."View All".Invoke();

        // [THEN] The list should have six rows
        DataSensitivity.Reset();
        LibraryAssert.IsTrue(VerifyThatFieldsAreDisplayedOnPage(DataSensitivity, DataClassificationWorksheet),
            'Not all the rows are displayed');

        DataClassificationWorksheet.Close();
    end;

    [Test]
    [HandlerFunctions('IncreaseNotificationCounter')]
    [Scope('OnPrem')]
    procedure TestLegalDisclaimerNotification()
    var
        DataClassificationWorksheet: TestPage "Data Classification Worksheet";
    begin
        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Data Class Edit');

        // [WHEN] The page opens
        // [THEN] Display a notification
        DataClassificationWorksheet.OpenEdit();

        LibraryAssert.AreEqual(1, NotificationCount, 'The count of sent notifications should be equal to 1');

        DataClassificationWorksheet.Close();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestSetSensitivities()
    var
        DataSensitivity: Record "Data Sensitivity";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
        DataClassificationWorksheet: TestPage "Data Classification Worksheet";
    begin
        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Data Class Edit');

        // [WHEN] A user changes a data sensitivity classification
        // [THEN] Change the value on the page
        DataClassificationMgt.InsertDataSensitivityForField(Database::"Field Content Buffer", 1, DataSensitivity."Data Sensitivity"::Unclassified);
        DataClassificationWorksheet.OpenEdit();

        DataClassificationWorksheet."Set as Sensitive".Invoke();
        LibraryAssert.AreEqual('Sensitive', DataClassificationWorksheet."Data Sensitivity".Value(), 'Data Sensitivity should be Sensitive');

        DataClassificationWorksheet."Set as Personal".Invoke();
        LibraryAssert.AreEqual('Personal', DataClassificationWorksheet."Data Sensitivity".Value(), 'Data Sensitivity should be Personal');

        DataClassificationWorksheet."Set as Normal".Invoke();
        LibraryAssert.AreEqual('Normal', DataClassificationWorksheet."Data Sensitivity".Value(), 'Data Sensitivity should be Normal');

        DataClassificationWorksheet."Set as Company Confidential".Invoke();
        LibraryAssert.AreEqual('Company Confidential', DataClassificationWorksheet."Data Sensitivity".Value(),
          'Data Sensitivity should be Company Confidential');

        DataClassificationWorksheet.Close();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestLastModifiedBy()
    var
        DataSensitivity: Record "Data Sensitivity";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
        DataClassificationWorksheet: TestPage "Data Classification Worksheet";
    begin
        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Data Class Edit');

        // [WHEN] A user changes a data sensitivity classification
        // [THEN] The last modified by value is also changed in the page
        DataClassificationMgt.InsertDataSensitivityForField(Database::"Field Content Buffer", 1, DataSensitivity."Data Sensitivity"::Unclassified);
        DataClassificationWorksheet.OpenEdit();

        DataClassificationWorksheet."Set as Sensitive".Invoke();
        LibraryAssert.AreEqual('Deleted User', DataClassificationWorksheet.LastModifiedBy.Value(),
          'Last Modified By should be Deleted User');

        DataClassificationWorksheet.Close();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestLastModified()
    var
        DataSensitivity: Record "Data Sensitivity";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
        DataClassificationWorksheet: TestPage "Data Classification Worksheet";
        BaseDate: DateTime;
    begin
        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Data Class Edit');

        // [WHEN] A user changes a data sensitivity classification
        // [THEN] The last modified value (date) also changes
        DataClassificationMgt.InsertDataSensitivityForField(Database::"Field Content Buffer", 1, DataSensitivity."Data Sensitivity"::Unclassified);
        DataClassificationWorksheet.OpenEdit();

        BaseDate := CurrentDateTime();

        DataClassificationWorksheet."Set as Sensitive".Invoke();
        LibraryAssert.AreNearlyEqual(CurrentDateTime() - BaseDate, DataClassificationWorksheet."Last Modified".AsDateTime() - BaseDate,
          1000, 'The value should be equal to the current time');

        DataClassificationWorksheet.Close();
    end;

    [PageHandler]
    [Scope('OnPrem')]
    procedure DataClassificationWizardHandler(var DataClassificationWizard: TestPage "Data Classification Wizard")
    begin
        DataClassificationWizard.Close();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure TextFieldContentBufferHandler(var FieldContentBuffer: TestPage "Field Content Buffer")
    var
        DataPrivacyEntities: Record "Data Privacy Entities";
    begin
        LibraryAssert.AreEqual(2, DataPrivacyEntities.Count(), 'The Data Privacy Entities table should contain 2 entries.');
        FieldContentBuffer.Last();

        if DataPrivacyEntities.FindSet() then;
        repeat
            DataPrivacyEntities.CalcFields("Table Caption");

            LibraryAssert.AreEqual(DataPrivacyEntities."Table Caption", FieldContentBuffer.Value.Value(),
            'The Table Caption is incorrect');

            if FieldContentBuffer.Previous() then;
        until DataPrivacyEntities.Next() = 0;
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure CodeFieldContentBufferHandler(var FieldContentBuffer: TestPage "Field Content Buffer")
    var
        FieldSyncStatus: Record "Fields Sync Status";
    begin
        LibraryAssert.AreEqual(4, FieldSyncStatus.Count(), 'The Field Sync Status table should contain 2 entries.');
        FieldContentBuffer.First();

        repeat
            LibraryAssert.IsTrue(FieldSyncStatus.Get(FieldContentBuffer.Value.Value()),
                StrSubstNo('The ID %1 cannot be found in the Field Sync Status table', FieldContentBuffer.Value.Value()));
        until not FieldContentBuffer.Next();
    end;

    [SendNotificationHandler(true)]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure IncreaseNotificationCounter(var TheNotification: Notification): Boolean
    begin
        NotificationCount += 1;
    end;

    local procedure InsertDataPrivacyEntitiy(TableNo: Integer)
    var
        DataPrivacyEntities: Record "Data Privacy Entities";
    begin
        DataPrivacyEntities.Init();
        DataPrivacyEntities."Table No." := TableNo;
        DataPrivacyEntities.Insert();
    end;

    local procedure InsertFieldSyncStatus(ID: Code[2])
    var
        FieldsSyncStatus: Record "Fields Sync Status";
    begin
        FieldsSyncStatus.Init();
        FieldsSyncStatus.ID := ID;
        FieldsSyncStatus.Insert();
    end;

    local procedure VerifyThatFieldsAreDisplayedOnPage(var DataSensitivity: Record "Data Sensitivity"; var DataClassificationWorksheet: TestPage "Data Classification Worksheet"): Boolean
    begin
        if DataSensitivity.FindSet() then;
        repeat
            if not DataClassificationWorksheet.GoToRecord(DataSensitivity) then
                exit(false);
        until DataSensitivity.Next() <> 0;

        exit(true);
    end;
}