// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135150 "Data Classification Mgt. Tests"
{
    EventSubscriberInstance = Manual;
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Data Classification]
    end;

    var
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
        DataClassificationMgtTests: Codeunit "Data Classification Mgt. Tests";
        LibraryAssert: Codeunit "Library Assert";

    [Test]
    [Scope('OnPrem')]
    procedure TestFillDataSensitivityTable()
    var
        DataSensitivity: Record "Data Sensitivity";
        "Field": Record "Field";
        FieldsSyncStatus: Record "Fields Sync Status";
        DataSensitivityCount: Integer;
        FieldCount: Integer;
    begin
        // [SCENARIO] The data sensitivity table can be populated as unclassified for all the data sensitive fields

        // [GIVEN] The data sensitivity table is empty
        DataSensitivity.DeleteAll();

        // [WHEN] The data sensitivity table is populated
        DataClassificationMgt.PopulateDataSensitivityTable();

        // [WHEN] The Field table is filtered to the potentially data sensitive entries
        DataClassificationMgt.GetEnabledSensitiveFields(Field);

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

        // [GIVEN] The data sensitivity table is empty
        DataSensitivity.DeleteAll();

        // [GIVEN] A table number, a field number and a data sensitivity
        TableNo := 18;
        FieldNo := 3;
        DataSensitivityOption := DataSensitivity."Data Sensitivity"::Sensitive;

        // [WHEN] Inserting one entry with the defined table number, field number and data sensitivity
        DataClassificationMgt.InsertDataSensitivityForField(TableNo, FieldNo, DataSensitivityOption);

        // [THEN] The Data Sensitivity table has exactly one entry
        LibraryAssert.AreEqual(1, DataSensitivity.Count(), 'The Data Sensitivity table should contain exactly one entry');

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

        // [GIVEN] The Data Sensitivity table contains two entries with different data sensitivities
        DataSensitivity.DeleteAll();
        DataClassificationMgt.InsertDataSensitivityForField(
          18, 4, DataSensitivity."Data Sensitivity"::"Company Confidential");
        DataClassificationMgt.InsertDataSensitivityForField(
          18, 5, DataSensitivity."Data Sensitivity"::Personal);

        // [WHEN] Setting the sensitivity for the filtered Data Sensitivity table to Normal
        DataClassificationMgt.SetSensitivities(DataSensitivity, DataSensitivity."Data Sensitivity"::Normal);

        // [THEN] There should be two entries in the Data Sensitivity table and they should both have normal sensitivity
        LibraryAssert.AreEqual(2, DataSensitivity.Count(), 'There should be 2 entries in the Data Sensitivity table');
        DataSensitivity.SetRange("Data Sensitivity", DataSensitivity."Data Sensitivity"::Normal);
        LibraryAssert.AreEqual(2, DataSensitivity.Count(),
          'Both entries in the Data Sensitiviy table should have Normal sensitivity');
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
        TableNo: Integer;
        NumberOfSensitivieFields: Integer;
    begin
        // [SCENARIO] Setting the data sensitivity for all the fields of a table to normal

        // [GIVEN] The Data Sensitivity table is empty
        DataSensitivity.DeleteAll();

        // [GIVEN] A table number
        TableNo := 1180;

        // [GIVEN] The Field table is filtered to include only the enabled, sensitive fields in this table
        Field.SetRange(TableNo, TableNo);
        DataClassificationMgt.GetEnabledSensitiveFields(Field);
        NumberOfSensitivieFields := Field.Count();

        // [WHEN] Setting the data sensitivity for the sensitive fields in this table to normal
        DataClassificationMgt.SetTableFieldsToNormal(TableNo);

        // [THEN] There should be as many normal entries in the Data Sensitivity table for this
        // table number as there were sensitive fields in the Field table
        DataSensitivity.SetRange("Data Sensitivity", DataSensitivity."Data Sensitivity"::Normal);
        DataSensitivity.SetFilter("Table No", Format(TableNo));

        LibraryAssert.AreEqual(NumberOfSensitivieFields, DataSensitivity.Count(), 'The number of Normal fields is incorrect');

        // [GIVEN] One of the Data Sensitivity entries for this table is modified to no longer be normal
        if DataSensitivity.FindFirst() then;
        DataSensitivity."Data Sensitivity" := DataSensitivity."Data Sensitivity"::"Company Confidential";
        DataSensitivity.Modify();

        // [WHEN] Setting the data sensitivity for the sensitive fields in this table to normal
        DataClassificationMgt.SetTableFieldsToNormal(TableNo);

        // [THEN] The newly modified entry should be set back to normal
        DataSensitivity.SetRange("Data Sensitivity", DataSensitivity."Data Sensitivity"::Normal);
        DataSensitivity.SetFilter("Table No", Format(TableNo));

        LibraryAssert.AreEqual(DataSensitivity.Count(), NumberOfSensitivieFields, 'The number of Normal fields is incorrect');
    end;


    [Test]
    [Scope('OnPrem')]
    procedure TestIsDataSensitivityEmptyForCurrentCompany()
    var
        DataSensitivity: Record "Data Sensitivity";
    begin
        // [SCENARIO] The system can be queried about whether or not the Data Sensitivity table is empty

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
}

