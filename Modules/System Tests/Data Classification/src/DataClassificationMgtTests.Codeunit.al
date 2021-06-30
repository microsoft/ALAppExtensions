// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135150 "Data Classification Mgt. Tests"
{
    EventSubscriberInstance = Manual;
    Subtype = Test;
    Permissions = tabledata "Data Sensitivity" = md,
                  tabledata "Fields Sync Status" = ri;

    trigger OnRun()
    begin
        // [FEATURE] [Data Classification]
    end;

    var
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
        LibraryAssert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";

    [Test]
    [Scope('OnPrem')]
    procedure TestPopulateDataSensitivityTable()
    var
        DataSensitivity: Record "Data Sensitivity";
        "Field": Record "Field";
        FieldsSyncStatus: Record "Fields Sync Status";
        DataClassificationMgtImpl: Codeunit "Data Classification Mgt. Impl.";
        DataSensitivityCount: Integer;
        FieldCount: Integer;
    begin
        // [SCENARIO] The data sensitivity table can be populated as unclassified for all the data sensitive fields

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Data Class Edit');

        // [GIVEN] The data sensitivity table is empty
        DataSensitivity.DeleteAll();

        // [WHEN] The data sensitivity table is populated
        DataClassificationMgt.PopulateDataSensitivityTable();

        // [WHEN] The Field table is filtered to the potentially data sensitive entries
        DataClassificationMgtImpl.GetEnabledSensitiveFields(Field);

        DataSensitivityCount := DataSensitivity.Count();
        FieldCount := Field.Count();

        // [WHEN] There exist entries in the Field table
        if not Field.IsEmpty() then
            // [THEN] The Data Sensitivity table should not be empty
            LibraryAssert.AreNotEqual(0, DataSensitivityCount, 'The data sensitivity table should not be empty');

        // [THEN] The Data Sensitivity table and the filtered Field table should have the same amount of rows
        LibraryAssert.AreEqual(FieldCount, DataSensitivityCount,
          'There should be an entry in the data sensitivity table for each potentially data sensitive field');

        // [THEN] All the entries in the Data Sensitivity table should be unclassified
        DataSensitivity.SetRange("Data Sensitivity", DataSensitivity."Data Sensitivity"::Unclassified);
        LibraryAssert.AreEqual(DataSensitivityCount, DataSensitivity.Count(),
          'All the entries of the Data Sensitivity table should be unclassified');

        // [THEN] The Fields Sync Status table is not empty
        LibraryAssert.AreNotEqual(0, FieldsSyncStatus.Count(), 'The Fields Sync Status table cannot be empty');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertDataSensitivityForField()
    var
        DataSensitivity: Record "Data Sensitivity";
        TableNo: Integer;
        FieldNo: Integer;
        DataSensitivityOption: Option;
    begin
        // [SCENARIO] Inserting an entry in the Data Sensitivity table

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Data Class Edit');

        // [GIVEN] The data sensitivity table is empty
        DataSensitivity.DeleteAll();

        // [GIVEN] A table number, a field number and a data sensitivity
        TableNo := 18;
        FieldNo := 3;
        DataSensitivityOption := DataSensitivity."Data Sensitivity"::Sensitive;

        // [WHEN] Inserting one entry with the defined table number, field number and data sensitivity
        DataClassificationMgt.InsertDataSensitivityForField(TableNo, FieldNo, DataSensitivityOption);

        // [THEN] The Data Sensitivity table has exactly one entry
        LibraryAssert.RecordCount(DataSensitivity, 1);

        // [THEN] The Data Sensitivity entry should have the properties set above
        // and the Company Name should be set to the current company name
        if DataSensitivity.FindFirst() then;

        LibraryAssert.AreEqual(CompanyName(), DataSensitivity."Company Name",
          'The Company Name of the Data Sensitivity record is incorrect');
        LibraryAssert.AreEqual(TableNo, DataSensitivity."Table No",
          'The Table No of the Data Sensitivity record is incorrect');
        LibraryAssert.AreEqual(FieldNo, DataSensitivity."Field No",
          'The Field No of the Data Sensitivity record is incorrect');
        LibraryAssert.AreEqual(DataSensitivityOption, DataSensitivity."Data Sensitivity",
          'The Data Sensitivity field of the Data Sensitivity record is incorrect');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestSetDefaultDataSensitivity()
    var
        DataPrivacyEntities: Record "Data Privacy Entities";
        DataSensitivity: Record "Data Sensitivity";
        TableNo: Integer;
    begin
        // [SCENARIO] The Data Sensitivity and Data Privacy Entities are synched by setting the default data sensitivity
        // for the entries in the Data Privacy Entities

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Data Class Edit');

        DataPrivacyEntities.DeleteAll();
        DataSensitivity.DeleteAll();

        // [GIVEN] A fictive table number and an entry in the Data Privacy Entities corresponding to this table number
        TableNo := 50001;
        DataClassificationMgt.InsertDataPrivacyEntity(DataPrivacyEntities, TableNo, 0, 0, '', 0);

        // [GIVEN] A company confidential entry in the data sensitivity corresponding to the aforementioned table number
        DataClassificationMgt.InsertDataSensitivityForField(TableNo, 1, DataSensitivity."Data Sensitivity"::"Company Confidential");

        // [GIVEN] A normal entry in the data sensitivity corresponding to the aforementioned table number
        DataClassificationMgt.InsertDataSensitivityForField(TableNo, 2, DataSensitivity."Data Sensitivity"::Normal);

        // [WHEN] Setting the default data sensitivity for all the tables that are referenced in Data Privacy Entities
        DataClassificationMgt.SetDefaultDataSensitivity(DataPrivacyEntities);

        // [THEN] The Data Sensitivity table's entry for this table number should have a different data sensitivity value
        DataSensitivity.SetRange("Field No", 1);
        if DataPrivacyEntities.FindFirst() and DataSensitivity.FindFirst() then;
        LibraryAssert.AreEqual(DataPrivacyEntities."Default Data Sensitivity", DataSensitivity."Data Sensitivity",
          'The Data Sensitivity was not set to the default value');

        DataSensitivity.SetRange("Field No", 2);
        if DataSensitivity.FindFirst() then;
        LibraryAssert.AreEqual(DataPrivacyEntities."Default Data Sensitivity", DataSensitivity."Data Sensitivity",
          'The Data Sensitivity was not set to the default value');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestSetSensitivities()
    var
        DataSensitivity: Record "Data Sensitivity";
    begin
        // [SCENARIO] Setting the sensitivity for all the entries in a Data Sensitivity record

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Data Class Edit');

        // [GIVEN] The Data Sensitivity table contains two entries with different data sensitivities
        DataSensitivity.DeleteAll();
        DataClassificationMgt.InsertDataSensitivityForField(
          18, 4, DataSensitivity."Data Sensitivity"::"Company Confidential");
        DataClassificationMgt.InsertDataSensitivityForField(
          18, 5, DataSensitivity."Data Sensitivity"::Personal);

        // [WHEN] Setting the sensitivity for the filtered Data Sensitivity table to Normal
        DataClassificationMgt.SetSensitivities(DataSensitivity, DataSensitivity."Data Sensitivity"::Normal);

        // [THEN] There should be two entries in the Data Sensitivity table and they should both have normal sensitivity
        LibraryAssert.RecordCount(DataSensitivity, 2);
        DataSensitivity.SetRange("Data Sensitivity", DataSensitivity."Data Sensitivity"::Normal);
        LibraryAssert.RecordCount(DataSensitivity, 2);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestPopulateFieldValue()
    var
        WebService: Record "Web Service";
        TempFieldContentBuffer: Record "Field Content Buffer" temporary;
        DataClassificationMgmtImpl: Codeunit "Data Classification Mgt. Impl.";
        FieldRef: FieldRef;
        RecordRef: RecordRef;
    begin
        // [SCENARIO] User can see field values from the Data Classification Worksheet

        // [GIVEN] Some records in the Web Service table
        WebService.Init();
        WebService."Service Name" := 'Name';
        WebService.Insert();        

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Data Class Edit');

        // [WHEN] Populating the field values for the Service Name field in Web Service table
        RecordRef.GetTable(WebService);
        FieldRef := RecordRef.Field(WebService.FieldNo("Service Name"));
        DataClassificationMgmtImpl.PopulateFieldValue(FieldRef, TempFieldContentBuffer);

        // [THEN] The new name should appear
        LibraryAssert.IsTrue(TempFieldContentBuffer.Get(WebService."Service Name"),
          'The created web service name value is not found');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestAreAllFieldsClassified()
    var
        DataSensitivity: Record "Data Sensitivity";
        AreAllFieldsClassified: Boolean;
    begin
        // [SCENARIO] The system can be queried in regards to whether or not all the fields are classified

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Data Class Edit');

        // [GIVEN] A single entry in the Data Sensitivity table that is unclassified
        DataSensitivity.DeleteAll();
        DataClassificationMgt.InsertDataSensitivityForField(18, 3, DataSensitivity."Data Sensitivity"::Unclassified);

        // [WHEN] Querying whether all the fields are classified
        AreAllFieldsClassified := DataClassificationMgt.AreAllFieldsClassified();

        // [THEN] The result should be false
        LibraryAssert.IsFalse(AreAllFieldsClassified, 'Not all the fields should be classified');

        if DataSensitivity.FindFirst() then;

        // [GIVEN] The existing entry is classified
        DataSensitivity."Data Sensitivity" := DataSensitivity."Data Sensitivity"::"Company Confidential";
        DataSensitivity.Modify();

        // [WHEN] Querying whether all the fields are classified
        AreAllFieldsClassified := DataClassificationMgt.AreAllFieldsClassified();

        // [THEN] The result should be true
        LibraryAssert.IsTrue(AreAllFieldsClassified, 'All the fields are classified');

        // [GIVEN] There are two entries in the Data Sensitivity table - a classified and an unclassified one
        DataClassificationMgt.InsertDataSensitivityForField(27, 3, DataSensitivity."Data Sensitivity"::Unclassified);

        // [WHEN] Querying whether all the fields are classified
        AreAllFieldsClassified := DataClassificationMgt.AreAllFieldsClassified();

        // [THEN] The result should be false
        LibraryAssert.IsFalse(AreAllFieldsClassified, 'Not all the fields should be classified');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestSetFieldToPersonal()
    var
        DataSensitivity: Record "Data Sensitivity";
        TableNo: Integer;
        NormalFieldNo: Integer;
        CompanyConfidentialFieldNo: Integer;
        NewFieldNo: Integer;
    begin
        // [SCENARIO] A field's data sensitivity can be set to Personal

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Data Class Edit');

        // [GIVEN] The Data Sensitivity table contains two entries - one of them Normal, the other one Company Confidential
        DataSensitivity.DeleteAll();

        TableNo := 18;
        NormalFieldNo := 3;
        CompanyConfidentialFieldNo := 4;

        DataClassificationMgt.InsertDataSensitivityForField(TableNo, NormalFieldNo,
          DataSensitivity."Data Sensitivity"::Normal);
        DataClassificationMgt.InsertDataSensitivityForField(TableNo, CompanyConfidentialFieldNo,
          DataSensitivity."Data Sensitivity"::"Company Confidential");

        // [WHEN] Setting the data sensitivity of the normal field to Personal
        DataClassificationMgt.SetFieldToPersonal(TableNo, NormalFieldNo);

        DataSensitivity.SetRange("Field No", NormalFieldNo);
        if DataSensitivity.FindFirst() then;

        // [THEN] The field's sensitivity should be set to Personal
        LibraryAssert.AreEqual(DataSensitivity."Data Sensitivity"::Personal, DataSensitivity."Data Sensitivity",
          'The Data Sensitivity of the field should be Personal');

        // [WHEN] Setting the sensitivity of a field that is already Personal to Personal
        DataClassificationMgt.SetFieldToPersonal(TableNo, NormalFieldNo);

        DataSensitivity.SetRange("Field No", NormalFieldNo);
        if DataSensitivity.FindFirst() then;

        // [THEN] The sensitivity of the field should stay Personal
        LibraryAssert.AreEqual(DataSensitivity."Data Sensitivity"::Personal, DataSensitivity."Data Sensitivity",
          'The Data Sensitivity of the field should stay Personal');

        // [THEN] The company confidential field's sensitivity should stay the same
        DataSensitivity.SetRange("Field No", CompanyConfidentialFieldNo);
        if DataSensitivity.FindFirst() then;
        LibraryAssert.AreEqual(DataSensitivity."Data Sensitivity"::"Company Confidential", DataSensitivity."Data Sensitivity",
          'The Data Sensitivity of the field should have remained Company Confidential');

        // [WHEN] Setting the sensitivity of a field that is not present in the Data Sensitivity table to Personal
        NewFieldNo := 5;

        DataClassificationMgt.SetFieldToPersonal(TableNo, NewFieldNo);

        // [THEN] The sensitivity of the field should be set to Personal
        DataSensitivity.SetRange("Field No", NewFieldNo);
        if DataSensitivity.FindFirst() then;
        LibraryAssert.AreEqual(DataSensitivity."Data Sensitivity"::Personal, DataSensitivity."Data Sensitivity",
          'The Data Sensitivity of the previously unclassified field should be Personal');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestSetFieldToSensitive()
    var
        DataSensitivity: Record "Data Sensitivity";
        TableNo: Integer;
        NormalFieldNo: Integer;
        CompanyConfidentialFieldNo: Integer;
        NewFieldNo: Integer;
    begin
        // [SCENARIO] A field's data sensitivity can be set to Sensitive

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Data Class Edit');

        // [GIVEN] The Data Sensitivity table contains two entries - one of them Normal, the other one Company Confidential
        DataSensitivity.DeleteAll();

        TableNo := 18;
        NormalFieldNo := 3;
        CompanyConfidentialFieldNo := 4;

        DataClassificationMgt.InsertDataSensitivityForField(TableNo, NormalFieldNo,
          DataSensitivity."Data Sensitivity"::Normal);
        DataClassificationMgt.InsertDataSensitivityForField(TableNo, CompanyConfidentialFieldNo,
          DataSensitivity."Data Sensitivity"::"Company Confidential");

        // [WHEN] Setting the data sensitivity of the normal field to Sensitive
        DataClassificationMgt.SetFieldToSensitive(TableNo, NormalFieldNo);

        DataSensitivity.SetRange("Field No", NormalFieldNo);
        if DataSensitivity.FindFirst() then;

        // [THEN] The field's sensitivity should be set to Sensitive
        LibraryAssert.AreEqual(DataSensitivity."Data Sensitivity"::Sensitive, DataSensitivity."Data Sensitivity",
          'The Data Sensitivity of the field should be Sensitive');

        // [WHEN] Setting the sensitivity of a field that is already Sensitive to Sensitive
        DataClassificationMgt.SetFieldToSensitive(TableNo, NormalFieldNo);

        DataSensitivity.SetRange("Field No", NormalFieldNo);
        if DataSensitivity.FindFirst() then;

        // [THEN] The sensitivity of the field should stay Sensitive
        LibraryAssert.AreEqual(DataSensitivity."Data Sensitivity"::Sensitive, DataSensitivity."Data Sensitivity",
          'The Data Sensitivity of the field should have remained Sensitive');

        // [THEN] The company confidential field's sensitivity should stay the same
        DataSensitivity.SetRange("Field No", CompanyConfidentialFieldNo);
        if DataSensitivity.FindFirst() then;
        LibraryAssert.AreEqual(DataSensitivity."Data Sensitivity"::"Company Confidential", DataSensitivity."Data Sensitivity",
          'The Data Sensitivity of the field should have remained Company Confidential');

        // [WHEN] Setting the sensitivity of a field that is not present in the Data Sensitivity table to Personal
        NewFieldNo := 5;

        DataClassificationMgt.SetFieldToSensitive(TableNo, NewFieldNo);

        // [THEN] The sensitivity of the field should be set to Sensitive
        DataSensitivity.SetRange("Field No", NewFieldNo);
        if DataSensitivity.FindFirst() then;
        LibraryAssert.AreEqual(DataSensitivity."Data Sensitivity"::Sensitive, DataSensitivity."Data Sensitivity",
          'The Data Sensitivity of the previously unclassified field should be Sensitive');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestSetFieldToCompanyConfidential()
    var
        DataSensitivity: Record "Data Sensitivity";
        TableNo: Integer;
        NormalFieldNo: Integer;
        SensitiveFieldNo: Integer;
        NewFieldNo: Integer;
    begin
        // [SCENARIO] A field's data sensitivity can be set to Company Condidential

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Data Class Edit');

        // [GIVEN] The Data Sensitivity table contains two entries - one of them Normal, the other one Sensitive
        DataSensitivity.DeleteAll();

        TableNo := 18;
        NormalFieldNo := 3;
        SensitiveFieldNo := 4;

        DataClassificationMgt.InsertDataSensitivityForField(TableNo, NormalFieldNo,
          DataSensitivity."Data Sensitivity"::Normal);
        DataClassificationMgt.InsertDataSensitivityForField(TableNo, SensitiveFieldNo,
          DataSensitivity."Data Sensitivity"::Sensitive);

        // [WHEN] Setting the data sensitivity of the normal field to Company Confidential
        DataClassificationMgt.SetFieldToCompanyConfidential(TableNo, NormalFieldNo);

        DataSensitivity.SetRange("Field No", NormalFieldNo);
        if DataSensitivity.FindFirst() then;

        // [THEN] The field's sensitivity should be set to Company Confidential
        LibraryAssert.AreEqual(DataSensitivity."Data Sensitivity"::"Company Confidential", DataSensitivity."Data Sensitivity",
          'The Data Sensitivity of the field should be Company Confidential');

        // [WHEN] Setting the sensitivity of a field that is already Company Confidential to Company Confidential
        DataClassificationMgt.SetFieldToCompanyConfidential(TableNo, NormalFieldNo);

        DataSensitivity.SetRange("Field No", NormalFieldNo);
        if DataSensitivity.FindFirst() then;

        // [THEN] The sensitivity of the field should stay Company Confidential
        LibraryAssert.AreEqual(DataSensitivity."Data Sensitivity"::"Company Confidential", DataSensitivity."Data Sensitivity",
          'The Data Sensitivity of the field should stay Company Confidential');

        // [THEN] The sensitive field's sensitivity should stay the same
        DataSensitivity.SetRange("Field No", SensitiveFieldNo);
        if DataSensitivity.FindFirst() then;
        LibraryAssert.AreEqual(DataSensitivity."Data Sensitivity"::Sensitive, DataSensitivity."Data Sensitivity",
          'The Data Sensitivity of the field should be Sensitive');

        // [WHEN] Setting the sensitivity of a field that is not present in the Data Sensitivity table to Company Confidential
        NewFieldNo := 5;

        DataClassificationMgt.SetFieldToCompanyConfidential(TableNo, NewFieldNo);

        // [THEN] The sensitivity of the field should be set to Company Confidential
        DataSensitivity.SetRange("Field No", NewFieldNo);
        if DataSensitivity.FindFirst() then;
        LibraryAssert.AreEqual(DataSensitivity."Data Sensitivity"::"Company Confidential", DataSensitivity."Data Sensitivity",
          'The Data Sensitivity of the previously unclassified field should be Company Confidential');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestSetFieldToNormal()
    var
        DataSensitivity: Record "Data Sensitivity";
        TableNo: Integer;
        PersonalFieldNo: Integer;
        SensitiveFieldNo: Integer;
        NewFieldNo: Integer;
    begin
        // [SCENARIO] A field's data sensitivity can be set to Company Condidential

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Data Class Edit');

        // [GIVEN] The Data Sensitivity table contains two entries - one of them Personal, the other one Sensitive
        DataSensitivity.DeleteAll();

        TableNo := 18;
        PersonalFieldNo := 3;
        SensitiveFieldNo := 4;

        DataClassificationMgt.InsertDataSensitivityForField(TableNo, PersonalFieldNo,
          DataSensitivity."Data Sensitivity"::Personal);
        DataClassificationMgt.InsertDataSensitivityForField(TableNo, SensitiveFieldNo,
          DataSensitivity."Data Sensitivity"::Sensitive);

        // [WHEN] Setting the data sensitivity of the personal field to normal
        DataClassificationMgt.SetFieldToNormal(TableNo, PersonalFieldNo);

        DataSensitivity.SetRange("Field No", PersonalFieldNo);
        if DataSensitivity.FindFirst() then;
        // [THEN] The field's sensitivity should be set to Normal
        LibraryAssert.AreEqual(DataSensitivity."Data Sensitivity"::Normal, DataSensitivity."Data Sensitivity",
          'The Data Sensitivity of the field should be Normal');

        // [WHEN] Setting the sensitivity of a field that is already Normal to Normal
        DataClassificationMgt.SetFieldToNormal(TableNo, PersonalFieldNo);

        DataSensitivity.SetRange("Field No", PersonalFieldNo);
        if DataSensitivity.FindFirst() then;

        // [THEN] The sensitivity of the field should stay Normal
        LibraryAssert.AreEqual(DataSensitivity."Data Sensitivity"::Normal, DataSensitivity."Data Sensitivity",
          'The Data Sensitivity of the field should stay Normal');

        // [THEN] The sensitive field's sensitivity should stay the same
        DataSensitivity.SetRange("Field No", SensitiveFieldNo);
        if DataSensitivity.FindFirst() then;
        LibraryAssert.AreEqual(DataSensitivity."Data Sensitivity"::Sensitive, DataSensitivity."Data Sensitivity",
          'The Data Sensitivity of the sensitive field should have remained the same');

        // [WHEN] Setting the sensitivity of a field that is not present in the Data Sensitivity table to Normal
        NewFieldNo := 5;

        DataClassificationMgt.SetFieldToNormal(TableNo, NewFieldNo);

        // [THEN] The sensitivity of the field should be set to Normal
        DataSensitivity.SetRange("Field No", NewFieldNo);
        if DataSensitivity.FindFirst() then;
        LibraryAssert.AreEqual(DataSensitivity."Data Sensitivity"::Normal, DataSensitivity."Data Sensitivity",
          'The Data Sensitivity of the previously unclassified field should be Normal');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestSetTableFieldsToNormal()
    var
        "Field": Record "Field";
        DataSensitivity: Record "Data Sensitivity";
        DataClassificationMgtImpl: Codeunit "Data Classification Mgt. Impl.";
        TableNo: Integer;
        NumberOfSensitivieFields: Integer;
    begin
        // [SCENARIO] Setting the data sensitivity for all the fields of a table to normal

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Data Class Edit');

        // [GIVEN] The Data Sensitivity table is empty
        DataSensitivity.DeleteAll();

        // [GIVEN] A table number
        TableNo := 1180;

        // [GIVEN] The Field table is filtered to include only the enabled, sensitive fields in this table
        Field.SetRange(TableNo, TableNo);
        DataClassificationMgtImpl.GetEnabledSensitiveFields(Field);
        NumberOfSensitivieFields := Field.Count();

        // [WHEN] Setting the data sensitivity for the sensitive fields in this table to normal
        DataClassificationMgt.SetTableFieldsToNormal(TableNo);

        // [THEN] There should be as many normal entries in the Data Sensitivity table for this
        // table number as there were sensitive fields in the Field table
        DataSensitivity.SetRange("Data Sensitivity", DataSensitivity."Data Sensitivity"::Normal);
        DataSensitivity.SetFilter("Table No", Format(TableNo));

        LibraryAssert.RecordCount(DataSensitivity, NumberOfSensitivieFields);

        // [GIVEN] One of the Data Sensitivity entries for this table is modified to no longer be normal
        if DataSensitivity.FindFirst() then;
        DataSensitivity."Data Sensitivity" := DataSensitivity."Data Sensitivity"::"Company Confidential";
        DataSensitivity.Modify();

        // [WHEN] Setting the data sensitivity for the sensitive fields in this table to normal
        DataClassificationMgt.SetTableFieldsToNormal(TableNo);

        // [THEN] The newly modified entry should be set back to normal
        DataSensitivity.SetRange("Data Sensitivity", DataSensitivity."Data Sensitivity"::Normal);
        DataSensitivity.SetFilter("Table No", Format(TableNo));

        LibraryAssert.RecordCount(DataSensitivity, NumberOfSensitivieFields);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestIsDataSensitivityEmptyForCurrentCompany()
    var
        DataSensitivity: Record "Data Sensitivity";
    begin
        // [SCENARIO] The system can be queried about whether or not the Data Sensitivity table is empty

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Data Class Edit');

        // [GIVEN] The Data Sensitivity table is empty
        DataSensitivity.DeleteAll();

        // [WHEN] Querying whether it is empty
        // [THEN] The result should be true
        LibraryAssert.IsTrue(DataClassificationMgt.IsDataSensitivityEmptyForCurrentCompany(),
          'The data sensitivity table is empty');

        // [GIVEN] The Data Sensitivity table contains one entry
        DataClassificationMgt.InsertDataSensitivityForField(18, 3, DataSensitivity."Data Sensitivity"::Personal);

        // [WHEN] Querying whether it is empty
        // [THEN] The result should be false
        LibraryAssert.IsFalse(DataClassificationMgt.IsDataSensitivityEmptyForCurrentCompany(),
          'The data sensitivity table should not be empty');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestSyncAllFieldsForEmptyDataSensitivityTable()
    var
        DataSensitivity: Record "Data Sensitivity";
        FieldsSyncStatus: Record "Fields Sync Status";
        Field: Record Field;
        DataClassificationMgtImpl: Codeunit "Data Classification Mgt. Impl.";
        FieldCount: Integer;
    begin
        // [SCENARIO] Synchronizing the Field and Data Sensitivity table when the Data Sensitivity table is empty

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Data Class Edit');

        // [GIVEN] The Data Sensitivity table is empty
        DataSensitivity.DeleteAll();

        // [GIVEN] The number of enabled, sensitive fields
        DataClassificationMgtImpl.GetEnabledSensitiveFields(Field);
        FieldCount := Field.Count();

        // [WHEN] Synchronizing the Field and Data Sensitivity table
        DataClassificationMgt.SyncAllFields();

        // [THEN] The number of fields in the Data Sensitivity table should be the same as FieldCount
        LibraryAssert.RecordCount(DataSensitivity, FieldCount);

        // [THEN] All the entries in the Data Sensitivity table should be unclassified
        DataSensitivity.SetRange("Data Sensitivity", DataSensitivity."Data Sensitivity"::Unclassified);
        LibraryAssert.RecordCount(DataSensitivity, FieldCount);

        // [THEN] The Fields Sync Status table is not empty
        LibraryAssert.AreNotEqual(0, FieldsSyncStatus.Count(), 'The Fields Sync Status table cannot be empty');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestSyncAllFieldsForNonEmptyDataSensitivityTable()
    var
        DataSensitivity: Record "Data Sensitivity";
        FieldsSyncStatus: Record "Fields Sync Status";
        Field: Record Field;
        DataClassificationMgtImpl: Codeunit "Data Classification Mgt. Impl.";
        FieldCount: Integer;
        TableNo: Integer;
        SensitiveFieldNo: Integer;
        UnclassifiedFieldNo: Integer;
    begin
        // [SCENARIO] Synchronizing the Field and Data Sensitivity table when the Data Sensitivity table is not empty

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Data Class Edit');

        // [GIVEN] The Data Sensitivity table is not empty - it contains a classified and an unclassifed entry
        DataSensitivity.DeleteAll();

        TableNo := 50000;
        SensitiveFieldNo := 1;
        UnclassifiedFieldNo := 2;
        DataClassificationMgt.InsertDataSensitivityForField(TableNo, SensitiveFieldNo, DataSensitivity."Data Sensitivity"::Personal);
        DataClassificationMgt.InsertDataSensitivityForField(TableNo, UnclassifiedFieldNo, DataSensitivity."Data Sensitivity"::Unclassified);

        // [GIVEN] The number of enabled, sensitive, normal fields
        Field.SetRange(Class, Field.Class::Normal);
        DataClassificationMgtImpl.GetEnabledSensitiveFields(Field);
        FieldCount := Field.Count();

        // [WHEN] Synchronizing the Field and Data Sensitivity table
        DataClassificationMgt.SyncAllFields();

        // [THEN] The number of fields in the Data Sensitivity table should be the FieldCount + 1
        LibraryAssert.RecordCount(DataSensitivity, FieldCount + 1);

        // [THEN] FieldCount entries in the Data Sensitivity table should be unclassified
        DataSensitivity.SetRange("Data Sensitivity", DataSensitivity."Data Sensitivity"::Unclassified);
        LibraryAssert.RecordCount(DataSensitivity, FieldCount);

        // [THEN] The Data Sensitivity should still contain the initial sensitive field
        DataSensitivity.Reset();
        DataSensitivity.SetRange("Table No", TableNo);
        DataSensitivity.SetRange("Field No", SensitiveFieldNo);
        LibraryAssert.RecordCount(DataSensitivity, 1);

        // [THEN] The Data Sensitivity should not contain the initial unclassified field anymore
        DataSensitivity.SetRange("Field No", UnclassifiedFieldNo);
        LibraryAssert.RecordIsEmpty(DataSensitivity);

        // [THEN] The Fields Sync Status table is not empty
        LibraryAssert.AreNotEqual(0, FieldsSyncStatus.Count(), 'The Fields Sync Status table cannot be empty');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetDataSensitivityOptionString()
    var
        DataSensitivityOptionString: Text;
    begin
        // [SCENARIO] The options that Data Sensitivity can take are retrieved correctly

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Data Class Edit');

        // [WHEN] Calling GetDataSensitivityOptionString
        DataSensitivityOptionString := DataClassificationMgt.GetDataSensitivityOptionString();

        // [THEN] The resulting string is correct
        LibraryAssert.AreEqual('Unclassified,Sensitive,Personal,Company Confidential,Normal', DataSensitivityOptionString,
          'The Data Sensitivity Option String is incorrect');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestDataPrivacyEntitiesExist()
    var
        DataClassificationMgtTests: Codeunit "Data Classification Mgt. Tests";
        DataPrivacyEntitiesExist: Boolean;
    begin
        // [SCENARIO] Having an event subscriber that introduces a data privacy entity causes the 
        // DataPrivacyEntitiesExist function to return true

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Data Class Edit');

        BindSubscription(DataClassificationMgtTests);

        // [GIVEN] There is an event subscriber (OnGetDataPrivacyEntitiesSubscriber) that inserts a data
        // privacy entity 

        // [WHEN] Calling DataPrivacyEntitiesExist
        DataPrivacyEntitiesExist := DataClassificationMgt.DataPrivacyEntitiesExist();

        // [THEN] The result should be true
        LibraryAssert.IsTrue(DataPrivacyEntitiesExist, 'There should exist at least one data privacy entity');

        UnbindSubscription(DataClassificationMgtTests);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestInsertDataPrivacyEntity()
    var
        DataPrivacyEntities: Record "Data Privacy Entities";
        TableNo: Integer;
        PageNo: Integer;
        KeyFieldNo: Integer;
        EntityFilter: Text;
        PrivacyBlockedFieldNo: Integer;
    begin
        // [SCENARIO] A "standard" Data Privacy Entities entry can be inserted in a record

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Data Class Edit');

        // [GIVEN] The Data Privacy Entities table is empty
        DataPrivacyEntities.DeleteAll();

        // [WHEN] Inserting a Data Privacy Entities entry
        TableNo := 50000;
        PageNo := 7;
        KeyFieldNo := 13;
        EntityFilter := 'filter filter filter';
        PrivacyBlockedFieldNo := 12;
        DataClassificationMgt.InsertDataPrivacyEntity(DataPrivacyEntities, TableNo, PageNo, KeyFieldNo,
          EntityFilter, PrivacyBlockedFieldNo);

        // [THEN] The DataPrivacyEntities record contains exactly one entry
        LibraryAssert.RecordCount(DataPrivacyEntities, 1);

        // [THEN] The fields of the Data Privacy Entities entry should be set correctly
        if DataPrivacyEntities.FindFirst() then;
        LibraryAssert.AreEqual(TableNo, DataPrivacyEntities."Table No.", 'The Table No. is incorrect');
        LibraryAssert.AreEqual(PageNo, DataPrivacyEntities."Page No.", 'The Page No. is incorrect');
        LibraryAssert.AreEqual(KeyFieldNo, DataPrivacyEntities."Key Field No.", 'The Key Field No. is incorrect');
        LibraryAssert.AreEqual(PrivacyBlockedFieldNo, DataPrivacyEntities."Privacy Blocked Field No.",
          'The Privacy Blocked Field No. is incorrect');
        LibraryAssert.IsTrue(DataPrivacyEntities.Include, 'The Include flag should be set to true');
        LibraryAssert.AreEqual(DataPrivacyEntities."Default Data Sensitivity"::Personal, DataPrivacyEntities."Default Data Sensitivity",
          'The Default Data Sensitivity is incorrect');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestGetLastSyncStatusDate()
    var
        FieldsSyncStatus: Record "Fields Sync Status";
        LastSyncStatusDate: DateTime;
    begin
        // [SCENARIO] The last date when the Data Sensitivity and Field tables have been synched can be retrieved

        // [GIVEN] The Fields Sync Status table is empty
        FieldsSyncStatus.DeleteAll();

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Data Class Edit');

        // [WHEN] Getting the last sync status date
        LastSyncStatusDate := DataClassificationMgt.GetLastSyncStatusDate();

        // [THEN] LastSyncStatusDate is 0DT
        LibraryAssert.AreEqual(0DT, LastSyncStatusDate, 'The last sync status date should be 0DT');

        // [GIVEN] The Data Sensitivity and Field tables are synched
        DataClassificationMgt.SyncAllFields();

        // [WHEN] etting the last sync status date
        LastSyncStatusDate := DataClassificationMgt.GetLastSyncStatusDate();

        // [THEN] LastSyncStatusDate is not 0DT
        LibraryAssert.AreNotEqual(0DT, LastSyncStatusDate, 'The last sync status date should not be 0DT');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestRaiseOnGetDataPrivacyEntitiesWithNonTempRecord()
    var
        DataPrivacyEntities: Record "Data Privacy Entities";
    begin
        // [SCENARIO] The call to RaiseOnGetDataPrivacyEntities results in an error when the parameter is not a temporary record

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Data Class Edit');

        // [WHEN] Calling RaiseOnGetDataPrivacyEntities with a non-temporary record
        // [THEN] An error is thrown
        asserterror DataClassificationMgt.RaiseOnGetDataPrivacyEntities(DataPrivacyEntities);
        LibraryAssert.ExpectedError('Please call this function with a temporary record.');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestRaiseOnGetDataPrivacyEntitiesWithTempRecord()
    var
        TempDataPrivacyEntities: Record "Data Privacy Entities" temporary;
        DataClassificationMgtTests: Codeunit "Data Classification Mgt. Tests";
    begin
        // [SCENARIO] When calling RaiseOnGetDataPrivacyEntities, the OnGetDataPrivacyEntitiesSubscriber will 
        // successfully insert a Data Privacy Entities entry in the parameter record

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Data Class Edit');

        BindSubscription(DataClassificationMgtTests);

        // [GIVEN] The OnGetDataPrivacyEntitiesSubscriber inserts an entry in the Data Privacy Entities record

        // [WHEN] Calling RaiseOnGetDataPrivacyEntities
        DataClassificationMgt.RaiseOnGetDataPrivacyEntities(TempDataPrivacyEntities);

        // [THEN] The DataPrivacyEntities record contains exactly one entry
        LibraryAssert.RecordCount(TempDataPrivacyEntities, 1);

        UnbindSubscription(DataClassificationMgtTests);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Classification Mgt.", 'OnGetDataPrivacyEntities', '', false, false)]
    local procedure OnGetDataPrivacyEntitiesSubscriber(var DataPrivacyEntities: Record "Data Privacy Entities" temporary)
    var
        FieldsSyncStatus: Record "Fields Sync Status";
    begin
        if FieldsSyncStatus.IsEmpty() then
            FieldsSyncStatus.Insert();

        DataClassificationMgt.InsertDataPrivacyEntity(DataPrivacyEntities, Database::"Fields Sync Status",
          Page::"Field Content Buffer", 1, '', 1);
    end;
}

