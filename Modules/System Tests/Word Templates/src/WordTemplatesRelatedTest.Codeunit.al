// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Integration.Word;

using System.Integration.Word;
using System.TestLibraries.Integration.Word;
using System.Text;
using System.Utilities;
using System.Reflection;
using System.TestLibraries.Utilities;
using System.TestLibraries.Security.AccessControl;

/// <summary>
/// Tests for Word Templates related tables.
/// </summary>
codeunit 130444 "Word Templates Related Test"
{
    Subtype = Test;

    var
        Assert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";
        WordTemplateCodeTok: Label 'TEST', Locked = true;
        WordTemplateRelatedCodeATok: Label 'TESTA', Locked = true;
        WordTemplateRelatedCodeBTok: Label 'TESTB', Locked = true;
        WordTemplateRelatedCodeCTok: Label 'TESTC', Locked = true;

    [Test]
    procedure TestCreateDocumentInternalsWithRelatedTables()
    var
        TempWordTemplateFields: Record "Word Template Field" temporary;
        WordTemplatesImpl: Codeunit "Word Template Impl.";
        RelatedTableIds: List of [Integer];
        RelatedTableCodes: List of [Code[5]];
        MergeFields: List of [Text];
    begin
        // [SCENARIO] Creation of document template with related tables includes merge fields for related tables
        PermissionsMock.Set('Word Templates Edit');

        // [Given] Related table IDs and codes
        RelatedTableIds.Add(Database::"Word Templates Related Table");
        RelatedTableIds.Add(Database::"Word Templates Table");
        RelatedTableCodes.Add(WordTemplateRelatedCodeATok);
        RelatedTableCodes.Add(WordTemplateRelatedCodeBTok);

        // [WHEN] Run create document with related table ids and codes and save zip to temp blob
        WordTemplatesImpl.Create(Database::"Word Template", RelatedTableIds, RelatedTableCodes, TempWordTemplateFields);

        // [THEN] Verify the Merge fields are set correctly
        WordTemplatesImpl.GetMergeFields(MergeFields);

        Assert.IsTrue(MergeFields.Contains('Code'), 'Code should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('Name'), 'Name should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('Table ID'), 'Table ID should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('Table Caption'), 'Table Caption should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('System ID'), 'System Id should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('Created At'), 'Created At should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('Created By'), 'Created By should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('Modified At'), 'Modified At should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('Modified By'), 'Modified By should have been part of the Merge Fields.');

        Assert.IsTrue(MergeFields.Contains('TESTA_Code'), 'TESTA_Code should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TESTA_Table ID'), 'TESTA_Table ID should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TESTA_Related Table ID'), 'TESTA_Related Table ID should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TESTA_Related Table Caption'), 'TESTA_Related Table Caption should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TESTA_Field No.'), 'TESTA_Field No. should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TESTA_Field Caption'), 'TESTA_Field Caption should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TESTA_Related Table Code'), 'TESTA_Related Table Code should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TESTA_System ID'), 'TESTA_System ID should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TESTA_Created At'), 'TESTA_Created At should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TESTA_Created By'), 'TESTA_Created By should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TESTA_Modified At'), 'TESTA_Modified At should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TESTA_Modified By'), 'TESTA_Modified By should have been part of the Merge Fields.');

        Assert.IsTrue(MergeFields.Contains('TESTB_Table ID'), 'TESTB_Table ID should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TESTB_Table Caption'), 'TESTB_Table Caption should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TESTB_System ID'), 'TESTB_System ID should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TESTB_Created At'), 'TESTB_Created At should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TESTB_Created By'), 'TESTB_Created By should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TESTB_Modified At'), 'TESTB_Modified At should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TESTB_Modified By'), 'TESTB_Modified By should have been part of the Merge Fields.');

        // [THEN] Verify the TableNo of the Template is set correctly
        Assert.AreEqual(Database::"Word Template", WordTemplatesImpl.GetTableId(), 'A different table ID was expected.');
    end;

    [Test]
    procedure TestCreateDocumentInternalsWithRelatedTablesAndOptionalFields()
    var
        TempWordTemplateFields: Record "Word Template Field" temporary;
        WordTemplate: Record "Word Template";
        WordTemplatesTable: Record "Word Templates Table";
        WordTemplatesImpl: Codeunit "Word Template Impl.";
        RelatedTableIds: List of [Integer];
        RelatedTableCodes: List of [Code[5]];
        MergeFields: List of [Text];
    begin
        // [SCENARIO] Creation of document template with related tables includes merge fields for related tables
        PermissionsMock.Set('Word Templates Edit');

        // [Given] Related table IDs and codes
        RelatedTableIds.Add(Database::"Word Templates Related Table");
        RelatedTableIds.Add(Database::"Word Templates Table");
        RelatedTableCodes.Add('TESTA');
        RelatedTableCodes.Add('TESTB');
        ExcludeSelectedField('', Database::"Word Template", WordTemplate.FieldNo(Name), TempWordTemplateFields);
        ExcludeSelectedField('', Database::"Word Template", WordTemplate.FieldNo("Table Caption"), TempWordTemplateFields);
        ExcludeSelectedField('', Database::"Word Template", WordTemplate.FieldNo(SystemId), TempWordTemplateFields);
        ExcludeSelectedField('', Database::"Word Template", WordTemplate.FieldNo(SystemCreatedBy), TempWordTemplateFields);
        ExcludeSelectedField('', Database::"Word Template", WordTemplate.FieldNo(SystemModifiedAt), TempWordTemplateFields);
        ExcludeSelectedField('', Database::"Word Template", WordTemplate.FieldNo(SystemModifiedBy), TempWordTemplateFields);
        ExcludeSelectedField('', Database::"Word Templates Table", WordTemplatesTable.FieldNo(SystemId), TempWordTemplateFields);
        ExcludeSelectedField('', Database::"Word Templates Table", WordTemplatesTable.FieldNo(SystemCreatedAt), TempWordTemplateFields);
        ExcludeSelectedField('', Database::"Word Templates Table", WordTemplatesTable.FieldNo(SystemCreatedBy), TempWordTemplateFields);

        // [WHEN] Run create document with related table ids and codes and save zip to temp blob
        WordTemplatesImpl.Create(Database::"Word Template", RelatedTableIds, RelatedTableCodes, TempWordTemplateFields);

        // [THEN] Verify the Merge fields are set correctly
        WordTemplatesImpl.GetMergeFields(MergeFields);

        Assert.IsTrue(MergeFields.Contains('Code'), 'Code should have been part of the Merge Fields.');
        Assert.IsFalse(MergeFields.Contains('Name'), 'Name should not have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('Table ID'), 'Table ID should have been part of the Merge Fields.');
        Assert.IsFalse(MergeFields.Contains('Table Caption'), 'Table Caption not should have been part of the Merge Fields.');
        Assert.IsFalse(MergeFields.Contains('System ID'), 'System Id should not have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('Created At'), 'Created At should have been part of the Merge Fields.');
        Assert.IsFalse(MergeFields.Contains('Created By'), 'Created By should not have been part of the Merge Fields.');
        Assert.IsFalse(MergeFields.Contains('Modified At'), 'Modified At should not have been part of the Merge Fields.');
        Assert.IsFalse(MergeFields.Contains('Modified By'), 'Modified By should not have been part of the Merge Fields.');

        Assert.IsTrue(MergeFields.Contains('TESTA_Code'), 'TESTA_Code should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TESTA_Table ID'), 'TESTA_Table ID should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TESTA_Related Table ID'), 'TESTA_Related Table ID should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TESTA_Related Table Caption'), 'TESTA_Related Table Caption should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TESTA_Field No.'), 'TESTA_Field No. should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TESTA_Field Caption'), 'TESTA_Field Caption should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TESTA_Related Table Code'), 'TESTA_Related Table Code should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TESTA_System ID'), 'TESTA_System ID should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TESTA_Created At'), 'TESTA_Created At should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TESTA_Created By'), 'TESTA_Created By should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TESTA_Modified At'), 'TESTA_Modified At should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TESTA_Modified By'), 'TESTA_Modified By should have been part of the Merge Fields.');

        Assert.IsTrue(MergeFields.Contains('TESTB_Table ID'), 'TESTB_Table ID should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TESTB_Table Caption'), 'TESTB_Table Caption should have been part of the Merge Fields.');
        Assert.IsFalse(MergeFields.Contains('TESTB_System ID'), 'TESTB_System ID should not have been part of the Merge Fields.');
        Assert.IsFalse(MergeFields.Contains('TESTB_Created At'), 'TESTB_Created At should not have been part of the Merge Fields.');
        Assert.IsFalse(MergeFields.Contains('TESTB_Created By'), 'TESTB_Created By should not have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TESTB_Modified At'), 'TESTB_Modified At should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TESTB_Modified By'), 'TESTB_Modified By should have been part of the Merge Fields.');

        // [THEN] Verify the TableNo of the Template is set correctly
        Assert.AreEqual(Database::"Word Template", WordTemplatesImpl.GetTableId(), 'A different table ID was expected.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestCreateTemplateWithIdenticalFieldCaptions()
    var
        TempWordTemplateFields: Record "Word Template Field" temporary;
        WordTemplatesImpl: Codeunit "Word Template Impl.";
        RelatedTableIds: List of [Integer];
        RelatedTableCodes: List of [Code[5]];
        MergeFields: List of [Text];
    begin
        // [SCENARIO] Creation of document template with identical field captions appends a number to identical fields.
        PermissionsMock.Set('Word Templates Edit');

        // [Given] Related table IDs and codes
        RelatedTableIds.Add(Database::"Word Templates Test Table 3");
        RelatedTableCodes.Add('TEST');

        // [WHEN] Run create document with related table ids and codes and save zip to temp blob
        WordTemplatesImpl.Create(Database::"Word Templates Test Table 2", RelatedTableIds, RelatedTableCodes, TempWordTemplateFields);

        // [THEN] Verify the Merge fields are set correctly
        WordTemplatesImpl.GetMergeFields(MergeFields);

        Assert.IsTrue(MergeFields.Contains('No.'), 'No. should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('Value'), 'Value should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('Child Id'), 'Child Id should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('Child Code'), 'Child Code should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('Test Value'), 'Test Value should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('Test Value_2'), 'Test Value_2 should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('Value_2'), 'Value_2 should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('Word Templates Test Table 2 Field'), 'TEST_Word Templates Test Table 2 Field should have been part of the Merge Fields.');

        Assert.IsTrue(MergeFields.Contains('TEST_Id'), 'No should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TEST_Value'), 'TEST_Value should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TEST_Value_2'), 'TEST_Value_2 should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TEST_Value_3'), 'TEST_Value_3 should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TEST_Test Value'), 'TEST_Test Value should have been part of the Merge Fields.');
    end;

    [Test]
    procedure TestGenerateCode()
    var
        WordTemplateImpl: Codeunit "Word Template Impl.";
        ExistingCodes: Dictionary of [Code[5], Boolean];
    begin
        // [SCENARIO] Generated code is correct 
        PermissionsMock.Set('Word Templates Edit');

        Assert.AreEqual('TESTS', WordTemplateImpl.GenerateCode('Test String', ExistingCodes), 'Generated code should be TESTS');
        Assert.AreEqual('ANOTH', WordTemplateImpl.GenerateCode('Another String', ExistingCodes), 'Generated code should be ANOTH');
        Assert.AreEqual('STRIN', WordTemplateImpl.GenerateCode('S t r i n g', ExistingCodes), 'Generated code should be STRIN');
        Assert.AreEqual('ABC', WordTemplateImpl.GenerateCode('Abc', ExistingCodes), 'Generated code should be ABC');
    end;

    [Test]
    procedure TestGenerateCodeWithNumbers()
    var
        WordTemplateImpl: Codeunit "Word Template Impl.";
        ExistingCodes: Dictionary of [Code[5], Boolean];
    begin
        // [SCENARIO] Generated code is correct when using numbers
        PermissionsMock.Set('Word Templates Edit');

        Assert.AreEqual('TESTS', WordTemplateImpl.GenerateCode('1Test String', ExistingCodes), 'Generated code should be TESTS');
        Assert.AreEqual('A5432', WordTemplateImpl.GenerateCode('12345A54321', ExistingCodes), 'Generated code should be A5432');
        Assert.AreEqual('TEST1', WordTemplateImpl.GenerateCode('Test 12345', ExistingCodes), 'Generated code should be TEST1');
    end;


    [Test]
    procedure TestGenerateCodeWithSpecialCharacters()
    var
        WordTemplateImpl: Codeunit "Word Template Impl.";
        ExistingCodes: Dictionary of [Code[5], Boolean];
    begin
        // [SCENARIO] Generated code is correct when using special characters
        PermissionsMock.Set('Word Templates Edit');

        Assert.AreEqual('TESTS', WordTemplateImpl.GenerateCode('_Test: String', ExistingCodes), 'Generated code should be TESTS');
        Assert.AreEqual('TEST', WordTemplateImpl.GenerateCode('Testæøå', ExistingCodes), 'Generated code should be TEST');
        Assert.AreEqual('ABC', WordTemplateImpl.GenerateCode('µ¶abc', ExistingCodes), 'Generated code should be ABC');
    end;

    [Test]
    procedure TestGenerateCodeWhenEmpty()
    var
        WordTemplateImpl: Codeunit "Word Template Impl.";
        ExistingCodes: Dictionary of [Code[5], Boolean];
    begin
        // [SCENARIO] Generated code is correct when the result is empty
        PermissionsMock.Set('Word Templates Edit');

        Assert.AreEqual('', WordTemplateImpl.GenerateCode('', ExistingCodes), 'Generated code should be empty');
        Assert.AreEqual('', WordTemplateImpl.GenerateCode('ÆØÅ', ExistingCodes), 'Generated code should be empty');
        Assert.AreEqual('', WordTemplateImpl.GenerateCode('123', ExistingCodes), 'Generated code should be empty');
    end;

    [Test]
    procedure TestGenerateCodeWhenExist()
    var
        WordTemplateImpl: Codeunit "Word Template Impl.";
        ExistingCodes: Dictionary of [Code[5], Boolean];
    begin
        // [SCENARIO] Generated code is correct when the result is empty
        PermissionsMock.Set('Word Templates Edit');

        ExistingCodes.Add('SALES', true);
        ExistingCodes.Add('ITEM', true);
        ExistingCodes.Add('ITEM1', true);
        ExistingCodes.Add('ITEM2', true);

        Assert.AreEqual('SALE1', WordTemplateImpl.GenerateCode('SALES', ExistingCodes), 'Generated code should be SALE1');
        Assert.AreEqual('ITEM3', WordTemplateImpl.GenerateCode('ITEM3', ExistingCodes), 'Generated code should be ITEM3');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGetByPrimaryKeyInteger()
    var
        WordTemplatesTestTable2: Record "Word Templates Test Table 2";
        WordTemplateImpl: Codeunit "Word Template Impl.";
        RecordRef: RecordRef;
        Found: Boolean;
    begin
        // [SCENARIO] GetByPrimaryKey returns true and the correct record when using an integer PK.
        PermissionsMock.Set('Word Templates Edit');

        // [GIVEN] Table with integer primary key.
        WordTemplatesTestTable2."No." := 10;
        WordTemplatesTestTable2.Value := 'VALUE';
        WordTemplatesTestTable2.Insert();

        // [WHEN] Getting record by primary key with integer.
        RecordRef.Open(Database::"Word Templates Test Table 2");
        Found := WordTemplateImpl.GetByPrimaryKey(RecordRef, 10);

        // [THEN] The correct record is found.
        Assert.IsTrue(Found, 'The record should have been found.');
        Assert.AreEqual(10, RecordRef.Field(1).Value(), 'The no of the record found shold be 10.');
        Assert.AreEqual('VALUE', RecordRef.Field(2).Value(), 'The value should be VALUE.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGetByPrimaryKeyGuid()
    var
        WordTemplatesTestTable3: Record "Word Templates Test Table 3";
        WordTemplateImpl: Codeunit "Word Template Impl.";
        RecordRef: RecordRef;
        Id: Guid;
        Found: Boolean;
        WrongIdMsg: Label 'The id should be %1.', Locked = true;
    begin
        // [SCENARIO] GetByPrimaryKey returns true and the correct record when using an guid PK.
        PermissionsMock.Set('Word Templates Edit');

        // [GIVEN] Table with guid primary key.
        Id := CreateGuid();
        WordTemplatesTestTable3.Id := Id;
        WordTemplatesTestTable3.Value := 'VALUE';
        WordTemplatesTestTable3.Insert();
        RecordRef.Open(Database::"Word Templates Test Table 3");

        // [WHEN] Getting record by primary key with guid.
        Found := WordTemplateImpl.GetByPrimaryKey(RecordRef, Id);

        // [THEN] The correct record is found.
        Assert.IsTrue(Found, 'The record should have been found.');
        Assert.AreEqual(Id, RecordRef.Field(1).Value(), StrSubstNo(WrongIdMsg, Id));
        Assert.AreEqual('VALUE', RecordRef.Field(2).Value(), 'The value should be VALUE.');
    end;


    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGetByPrimaryKeyCode()
    var
        WordTemplatesTestTable4: Record "Word Templates Test Table 4";
        WordTemplateImpl: Codeunit "Word Template Impl.";
        RecordRef: RecordRef;
        Code: Code[30];
        Found: Boolean;
    begin
        // [SCENARIO] GetByPrimaryKey returns true and the correct record when using an code PK.
        PermissionsMock.Set('Word Templates Edit');

        // [GIVEN] Table with code primary key.
        Code := 'CODE';
        WordTemplatesTestTable4.Code := Code;
        WordTemplatesTestTable4.Value := 'VALUE';
        WordTemplatesTestTable4.Insert();
        RecordRef.Open(Database::"Word Templates Test Table 4");

        // [WHEN] Getting record by primary key with code.
        Found := WordTemplateImpl.GetByPrimaryKey(RecordRef, Code);

        // [THEN] The correct record is found.
        Assert.IsTrue(Found, 'The record should have been found.');
        Assert.AreEqual('CODE', RecordRef.Field(1).Value(), 'The code should be CODE');
        Assert.AreEqual('VALUE', RecordRef.Field(2).Value(), 'The value should be VALUE.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGetByPrimaryKeyBigInteger()
    var
        WordTemplatesTestTable5: Record "Word Templates Test Table 5";
        WordTemplateImpl: Codeunit "Word Template Impl.";
        RecordRef: RecordRef;
        PrimaryKey: BigInteger;
        Found: Boolean;
    begin
        // [SCENARIO] GetByPrimaryKey returns true and the correct record when using an big integer PK.
        PermissionsMock.Set('Word Templates Edit');

        // [GIVEN] Table with big integer primary key.
        PrimaryKey := 1000L;
        WordTemplatesTestTable5.Id := PrimaryKey;
        WordTemplatesTestTable5.Value := 'VALUE';
        WordTemplatesTestTable5.Insert();
        RecordRef.Open(Database::"Word Templates Test Table 5");

        // [WHEN] Getting record by primary key with big integer.
        Found := WordTemplateImpl.GetByPrimaryKey(RecordRef, PrimaryKey);

        // [THEN] The correct record is found.
        Assert.IsTrue(Found, 'The record should have been found.');
        Assert.AreEqual(PrimaryKey, RecordRef.Field(1).Value(), 'The key should be the correct generated key.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGetByPrimaryKeyUnsupportedType()
    var
        WordTemplatesTestTable2: Record "Word Templates Test Table 2";
        WordTemplateImpl: Codeunit "Word Template Impl.";
        RecordRef: RecordRef;
        Found: Boolean;
    begin
        // [SCENARIO] GetByPrimaryKey returns false when using an unsupported (text) PK.
        PermissionsMock.Set('Word Templates Edit');

        // [GIVEN] Table with text primary key.
        WordTemplatesTestTable2."No." := 10;
        WordTemplatesTestTable2.Value := 'VALUE';
        WordTemplatesTestTable2.Insert();

        // [WHEN] Getting primary key with unsupported (text) datatype.
        RecordRef.Open(Database::"Word Templates Test Table 2");
        Found := WordTemplateImpl.GetByPrimaryKey(RecordRef, 'TEXT');

        // [THEN] The record is not found.
        Assert.IsFalse(Found, 'The record should not have been found.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestAddRelatedTable()
    var
        WordTemplateRec: Record "Word Template";
        WordTemplateRelatedRec: Record "Word Templates Related Table";
        TempWordTemplateRelatedRec: Record "Word Templates Related Table" temporary;
        Base64: Codeunit "Base64 Convert";
        Document: Codeunit "Temp Blob";
        WordTemplateImpl: Codeunit "Word Template Impl.";
        OutStream: OutStream;
        InStream: InStream;
        Added: Boolean;
    begin
        // [SCENARIO] Add a related table and verify that values are as expected

        // [GIVEN] No related tables
        WordTemplateRelatedRec.DeleteAll();

        // [GIVEN] Word templates edit permissions
        PermissionsMock.Set('Word Templates Edit');

        // [GIVEN] Document from base64 and Word template
        Document.CreateOutStream(OutStream, TextEncoding::UTF8);
        Base64.FromBase64(GetTemplateDocument(), OutStream);
        Document.CreateInStream(InStream, TextEncoding::UTF8);

        WordTemplateRec.Code := WordTemplateCodeTok;
        WordTemplateRec.Template.ImportStream(InStream, 'Template');
        WordTemplateRec.Insert();

        // [WHEN] Related table is added
        InitRelatedTable(WordTemplateRec.Code, Database::"Word Template", Database::"Word Templates Related Table", WordTemplateRelatedCodeATok, TempWordTemplateRelatedRec.FieldNo(Code), TempWordTemplateRelatedRec);
        Added := WordTemplateImpl.AddRelatedTable(WordTemplateRelatedRec, TempWordTemplateRelatedRec);

        PermissionsMock.ClearAssignments();

        // [THEN] One related table was added
        Assert.IsTrue(Added, 'The related table should have been added.');
        Assert.AreEqual(WordTemplateRelatedRec.Count(), 1, 'There should only be one related table added.');

        // [THEN] The values of the related table are as expected
        WordTemplateRelatedRec.FindFirst();
        Assert.AreEqual(WordTemplateRelatedRec.Code, WordTemplateCodeTok, 'Code should be TEST');
        Assert.AreEqual(WordTemplateRelatedRec."Table ID", Database::"Word Template", 'Table ID should be the ID of the Word Template table.');
        Assert.AreEqual(WordTemplateRelatedRec."Related Table ID", Database::"Word Templates Related Table", 'Related Table ID should be the ID of Word Templates Related Table.');
        Assert.AreEqual(WordTemplateRelatedRec."Related Table Code", WordTemplateRelatedCodeATok, 'Related Table Code should be TESTA');
        Assert.AreEqual(WordTemplateRelatedRec."Field No.", 1, 'The Field No. should be 1.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('MessageHandlerRelatedCodeExists')]
    procedure TestAddRelatedTableForExistingCode()
    var
        WordTemplateRec: Record "Word Template";
        WordTemplateRelatedRec: Record "Word Templates Related Table";
        TempWordTemplateRelatedRec: Record "Word Templates Related Table" temporary;
        Base64: Codeunit "Base64 Convert";
        Document: Codeunit "Temp Blob";
        WordTemplateImpl: Codeunit "Word Template Impl.";
        OutStream: OutStream;
        InStream: InStream;
        Added: Boolean;
    begin
        // [SCENARIO] Try to add a related table where the related table code is already used and verify that the table is not added and a message is shown instead.

        // [GIVEN] No related tables
        WordTemplateRelatedRec.DeleteAll();

        // [GIVEN] Word templates edit permissions
        PermissionsMock.Set('Word Templates Edit');

        // [GIVEN] Document from base64 and Word template
        Document.CreateOutStream(OutStream, TextEncoding::UTF8);
        Base64.FromBase64(GetTemplateDocument(), OutStream);
        Document.CreateInStream(InStream, TextEncoding::UTF8);

        WordTemplateRec.Code := WordTemplateCodeTok;
        WordTemplateRec.Template.ImportStream(InStream, 'Template');
        WordTemplateRec.Insert();

        // [GIVEN] One related table is added
        InitRelatedTable(WordTemplateCodeTok, Database::"Word Template", Database::"Word Templates Related Table", WordTemplateRelatedCodeATok, 1, TempWordTemplateRelatedRec);
        WordTemplateImpl.AddRelatedTable(WordTemplateRelatedRec, TempWordTemplateRelatedRec);

        // [WHEN] Attempting to add another related table with the same related table code
        TempWordTemplateRelatedRec.Reset();
        InitRelatedTable(WordTemplateCodeTok, Database::"Word Template", Database::"Word Templates Table", WordTemplateRelatedCodeATok, 1, TempWordTemplateRelatedRec);
        Added := WordTemplateImpl.AddRelatedTable(WordTemplateRelatedRec, TempWordTemplateRelatedRec);

        PermissionsMock.ClearAssignments();

        // [THEN] No related tables were added
        Assert.IsFalse(Added, 'The related table should not have been added.');
        Assert.AreEqual(WordTemplateRelatedRec.Count(), 1, 'There should only be one related table added.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('MessageHandlerRelatedTableExists')]
    procedure TestAddRelatedTableForExistingTable()
    var
        WordTemplateRec: Record "Word Template";
        WordTemplateRelatedRec: Record "Word Templates Related Table";
        TempWordTemplateRelatedRec: Record "Word Templates Related Table" temporary;
        Base64: Codeunit "Base64 Convert";
        Document: Codeunit "Temp Blob";
        WordTemplateImpl: Codeunit "Word Template Impl.";
        OutStream: OutStream;
        InStream: InStream;
        Added: Boolean;
    begin
        // [SCENARIO] Try to add a related table where the related table id is already used and verify that the table is not added and a message is shown instead.

        // [GIVEN] No related tables
        WordTemplateRelatedRec.DeleteAll();

        // [GIVEN] Word templates edit permissions
        PermissionsMock.Set('Word Templates Edit');

        // [GIVEN] Document from base64 and Word template
        Document.CreateOutStream(OutStream, TextEncoding::UTF8);
        Base64.FromBase64(GetTemplateDocument(), OutStream);
        Document.CreateInStream(InStream, TextEncoding::UTF8);

        WordTemplateRec.Code := WordTemplateCodeTok;
        WordTemplateRec.Template.ImportStream(InStream, 'Template');
        WordTemplateRec.Insert();

        // [GIVEN] One related table is added
        InitRelatedTable(WordTemplateCodeTok, Database::"Word Template", Database::"Word Templates Related Table", WordTemplateRelatedCodeATok, 1, TempWordTemplateRelatedRec);
        WordTemplateImpl.AddRelatedTable(WordTemplateRelatedRec, TempWordTemplateRelatedRec);

        // [WHEN] Attempting to add another related table with the same related table id
        TempWordTemplateRelatedRec.Reset();
        InitRelatedTable(WordTemplateCodeTok, Database::"Word Template", Database::"Word Templates Related Table", WordTemplateRelatedCodeBTok, 1, TempWordTemplateRelatedRec); // Related table ID is already used, should fail to insert.

        Added := WordTemplateImpl.AddRelatedTable(WordTemplateRelatedRec, TempWordTemplateRelatedRec);

        PermissionsMock.ClearAssignments();

        // [THEN] No related tables were added
        Assert.IsFalse(Added, 'The related table should not have been added.');
        Assert.AreEqual(WordTemplateRelatedRec.Count(), 1, 'There should only be one related table added.');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerFalse')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestLoadDocumentAndMergeWithRelatedTables()
    var
        WordTemplateRec: Record "Word Template";
        RelatedTable: Record "Word Templates Related Table";
        Base64: Codeunit "Base64 Convert";
        Document: Codeunit "Temp Blob";
        WordTemplate: Codeunit "Word Template";
        OutputText: Text;
        OutStream: OutStream;
        InStream: InStream;
    begin
        // [SCENARIO] Create, load and merge Word template with two related tables and verify that the output contains the data of all tables

        // [GIVEN] Document from base64 and Word template with related tables
        Document.CreateOutStream(OutStream, TextEncoding::UTF8);
        Base64.FromBase64(GetTemplateDocument(), OutStream);
        Document.CreateInStream(InStream, TextEncoding::UTF8);

        WordTemplateRec.Code := WordTemplateCodeTok;
        WordTemplateRec."Table ID" := Database::"Word Templates Test Table 2";
        WordTemplateRec.Template.ImportStream(InStream, 'Template');
        WordTemplateRec.Insert();

        // [GIVEN] Table related to source record
        InitRelatedTable(WordTemplateRec.Code, Database::"Word Templates Test Table 2", Database::"Word Templates Test Table 3", WordTemplateRelatedCodeATok, 3, RelatedTable);
        RelatedTable.Insert();

        // [GIVEN] Another table related to source record
        InitRelatedTable(WordTemplateRec.Code, Database::"Word Templates Test Table 2", Database::"Word Templates Test Table 4", WordTemplateRelatedCodeBTok, 4, RelatedTable);
        RelatedTable.Insert();

        // [GIVEN] Parent and child tables are initialized with data
        InitTestTables('Child1', 'Child2', 'Parent1', 'Child5', 'CODE1', 1, 1000L);
        InitTestTables('Child3', 'Child4', 'Parent2', 'Child6', 'CODE2', 2, 1001L);

        // [GIVEN] Word templates edit permissions
        PermissionsMock.Set('Word Templates Edit');

        // [WHEN] Load document from stream and merge
        WordTemplate.Load(WordTemplateRec.Code);
        WordTemplate.Merge(false, Enum::"Word Templates Save Format"::Text);

        // [THEN] Check document for related and parent table values
        WordTemplate.GetDocument(InStream);
        InStream.Read(OutputText);

        Assert.IsTrue(OutputText.Contains('Child1'), 'Child1 is missing from the document');
        Assert.IsTrue(OutputText.Contains('Child2'), 'Child2 is missing from the document');
        Assert.IsTrue(OutputText.Contains('Child3'), 'Child3 is missing from the document');
        Assert.IsTrue(OutputText.Contains('Child4'), 'Child4 is missing from the document');
        Assert.IsTrue(OutputText.Contains('Parent1'), 'Parent1 is missing from the document');
        Assert.IsTrue(OutputText.Contains('Parent2'), 'Parent2 is missing from the document');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerFalse')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestLoadDocumentAndMergeWithSecondLevelRelatedTables()
    var
        WordTemplateRec: Record "Word Template";
        RelatedTable: Record "Word Templates Related Table";
        Base64: Codeunit "Base64 Convert";
        Document: Codeunit "Temp Blob";
        WordTemplate: Codeunit "Word Template";
        OutputText: Text;
        OutStream: OutStream;
        InStream: InStream;
    begin
        // [SCENARIO] Create, load and merge Word template with second level related tables and verify that the output contains the data of all tables

        // [GIVEN] Document from base64 and Word template with related tables
        Document.CreateOutStream(OutStream, TextEncoding::UTF8);
        Base64.FromBase64(GetTemplateDocumentSecondLevelRelations(), OutStream);
        Document.CreateInStream(InStream, TextEncoding::UTF8);

        WordTemplateRec.Code := WordTemplateCodeTok;
        WordTemplateRec."Table ID" := Database::"Word Templates Test Table 2";
        WordTemplateRec.Template.ImportStream(InStream, 'Template');
        WordTemplateRec.Insert();

        // [GIVEN] Table related to source record
        InitRelatedTable(WordTemplateRec.Code, Database::"Word Templates Test Table 2", Database::"Word Templates Test Table 3", WordTemplateRelatedCodeATok, 3, RelatedTable);
        RelatedTable.Insert();

        // [GIVEN] Another table related to source record
        InitRelatedTable(WordTemplateRec.Code, Database::"Word Templates Test Table 2", Database::"Word Templates Test Table 4", WordTemplateRelatedCodeBTok, 4, RelatedTable);
        RelatedTable.Insert();

        // [GIVEN] A table related to a related table
        InitRelatedTable(WordTemplateRec.Code, Database::"Word Templates Test Table 4", Database::"Word Templates Test Table 5", WordTemplateRelatedCodeCTok, 3, RelatedTable);
        RelatedTable.Insert();

        // [GIVEN] Parent and child tables are initialized with data
        InitTestTables('Child1', 'Child2', 'Parent1', 'Child5', 'CODE1', 1, 1000L);
        InitTestTables('Child3', 'Child4', 'Parent2', 'Child6', 'CODE2', 2, 1001L);
        InitTestTablesWithMissingRelations1('Rainbow', 'Thunder', 3);
        InitTestTablesWithMissingRelations2('Giraffe', 'Elephant', 'CODE3', 4);

        // [GIVEN] Word templates edit permissions
        PermissionsMock.Set('Word Templates Edit');

        // [WHEN] Load document from stream and merge
        WordTemplate.Load(WordTemplateRec.Code);
        WordTemplate.Merge(false, Enum::"Word Templates Save Format"::Text);

        // [THEN] Check document for related and parent table values
        WordTemplate.GetDocument(InStream);
        InStream.Read(OutputText);

        Assert.IsTrue(OutputText.Contains('Child1'), 'Child1 is missing from the document');
        Assert.IsTrue(OutputText.Contains('Child2'), 'Child2 is missing from the document');
        Assert.IsTrue(OutputText.Contains('Child3'), 'Child3 is missing from the document');
        Assert.IsTrue(OutputText.Contains('Child4'), 'Child4 is missing from the document');
        Assert.IsTrue(OutputText.Contains('Child5'), 'Child5 is missing from the document');
        Assert.IsTrue(OutputText.Contains('Child6'), 'Child6 is missing from the document');
        Assert.IsTrue(OutputText.Contains('Parent1'), 'Parent1 is missing from the document');
        Assert.IsTrue(OutputText.Contains('Parent2'), 'Parent2 is missing from the document');
        Assert.IsTrue(OutputText.Contains('Rainbow'), 'Rainbow is missing from the document');
        Assert.IsTrue(OutputText.Contains('Thunder'), 'Thunder is missing from the document');
        Assert.IsTrue(OutputText.Contains('Giraffe'), 'Giraffe is missing from the document');
        Assert.IsTrue(OutputText.Contains('Elephant'), 'Elephant is missing from the document');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerFalse')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestLoadDocumentAndMergeWithSelectedEntity()
    var
        WordTemplateRec: Record "Word Template";
        WordTemplateTestTable2: Record "Word Templates Test Table 2";
        WordTemplateTestTable5: Record "Word Templates Test Table 5";
        RelatedTable: Record "Word Templates Related Table";
        Base64: Codeunit "Base64 Convert";
        Document: Codeunit "Temp Blob";
        WordTemplate: Codeunit "Word Template";
        OutputText: Text;
        OutStream: OutStream;
        InStream: InStream;
    begin
        // [SCENARIO] Create, load and merge Word template with an unrelated selected table and verify that the output contains the data of all tables

        // [GIVEN] Document from base64 and Word template with related tables
        Document.CreateOutStream(OutStream, TextEncoding::UTF8);
        Base64.FromBase64(GetTemplateDocumentSelectedRecord(), OutStream);
        Document.CreateInStream(InStream, TextEncoding::UTF8);

        WordTemplateRec.Code := WordTemplateCodeTok;
        WordTemplateRec."Table ID" := Database::"Word Templates Test Table 2";
        WordTemplateRec.Template.ImportStream(InStream, 'Template');
        WordTemplateRec.Insert();

        WordTemplateTestTable2."No." := 1000;
        WordTemplateTestTable2.Insert();

        WordTemplateTestTable5.Init();
        WordTemplateTestTable5.Id := 1001L;
        WordTemplateTestTable5.Insert();

        WordTemplateTestTable5.Init();
        WordTemplateTestTable5.Id := 1002L;
        WordTemplateTestTable5.Insert();

        // [GIVEN] Table unrelated to source record
        InitRelatedTable(WordTemplateRec.Code, Database::"Word Templates Test Table 2", Database::"Word Templates Test Table 5", WordTemplateRelatedCodeATok, 0, RelatedTable);
        RelatedTable."Source Record ID" := WordTemplateTestTable5.SystemId;
        RelatedTable.Insert();

        // [GIVEN] Word templates edit permissions
        PermissionsMock.Set('Word Templates Edit');

        // [WHEN] Load document from stream and merge
        WordTemplate.Load(WordTemplateRec.Code);
        WordTemplate.Merge(false, Enum::"Word Templates Save Format"::Text);

        // [THEN] Check document for related and parent table values
        WordTemplate.GetDocument(InStream);
        InStream.Read(OutputText);

        Assert.IsFalse(OutputText.Contains('1001'), '1001 is in the document');
        Assert.IsTrue(OutputText.Contains('1000'), '1000 is missing from the document');
        Assert.IsTrue(OutputText.Contains('1002'), '1002 is missing from the document');
    end;

    [ConfirmHandler]
    procedure ConfirmHandlerFalse(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := false;
    end;

    [MessageHandler]
    procedure MessageHandlerRelatedCodeExists(Message: Text[1024])
    begin
        Assert.AreEqual('The field prefix for the related entity already exists.', Message, 'Message is not as expected.');
    end;

    [MessageHandler]
    procedure MessageHandlerRelatedTableExists(Message: Text[1024])
    begin
        Assert.AreEqual('The related entity already exists.', Message, 'Message is not as expected.');
    end;

    local procedure InitRelatedTable(TemplateCode: Code[30]; TableId: Integer; RelatedTableId: Integer; RelatedTableCode: Code[5]; FieldNo: Integer; var WordTemplateRelatedTableRec: Record "Word Templates Related Table")
    begin
        WordTemplateRelatedTableRec.Init();
        WordTemplateRelatedTableRec.Code := TemplateCode;
        WordTemplateRelatedTableRec."Table ID" := TableId;
        WordTemplateRelatedTableRec."Related Table ID" := RelatedTableId;
        WordTemplateRelatedTableRec."Related Table Code" := RelatedTableCode;
        WordTemplateRelatedTableRec."Field No." := FieldNo;
    end;

    local procedure InitTestTables(Value1: Text[100]; Value2: Text[100]; Value3: Text[100]; Value4: Text[100]; Code: Code[30]; No: Integer; Id: BigInteger)
    var
        WordTemplatesTestTable2: Record "Word Templates Test Table 2";
        WordTemplatesTestTable3: Record "Word Templates Test Table 3";
        WordTemplatesTestTable4: Record "Word Templates Test Table 4";
        WordTemplatesTestTable5: Record "Word Templates Test Table 5";
    begin
        WordTemplatesTestTable5.Id := Id;
        WordTemplatesTestTable5.Value := Value4;
        WordTemplatesTestTable5.Insert();

        WordTemplatesTestTable3.Id := CreateGuid();
        WordTemplatesTestTable3.Value := Value1;
        WordTemplatesTestTable3.Insert();

        WordTemplatesTestTable4.Code := Code;
        WordTemplatesTestTable4.Value := Value2;
        WordTemplatesTestTable4."Child Id" := WordTemplatesTestTable5.Id;
        WordTemplatesTestTable4.Insert();

        WordTemplatesTestTable2."No." := No;
        WordTemplatesTestTable2."Child Code" := WordTemplatesTestTable4.Code;
        WordTemplatesTestTable2."Child Id" := WordTemplatesTestTable3.Id;
        WordTemplatesTestTable2.Value := Value3;
        WordTemplatesTestTable2.Insert();
    end;

    local procedure InitTestTablesWithMissingRelations1(Value1: Text[100]; Value2: Text[100]; No: Integer)
    var
        WordTemplatesTestTable2: Record "Word Templates Test Table 2";
        WordTemplatesTestTable3: Record "Word Templates Test Table 3";
    begin
        WordTemplatesTestTable3.Id := CreateGuid();
        WordTemplatesTestTable3.Value := Value2;
        WordTemplatesTestTable3.Insert();

        WordTemplatesTestTable2."No." := No;
        WordTemplatesTestTable2.Value := Value1;
        WordTemplatesTestTable2."Child Id" := WordTemplatesTestTable3.Id;
        WordTemplatesTestTable2.Insert();
    end;

    local procedure InitTestTablesWithMissingRelations2(Value1: Text[100]; Value2: Text[100]; Code: Code[30]; No: Integer)
    var
        WordTemplatesTestTable2: Record "Word Templates Test Table 2";
        WordTemplatesTestTable4: Record "Word Templates Test Table 4";
    begin
        WordTemplatesTestTable4.Code := Code;
        WordTemplatesTestTable4.Value := Value2;
        WordTemplatesTestTable4.Insert();

        WordTemplatesTestTable2."No." := No;
        WordTemplatesTestTable2.Value := Value1;
        WordTemplatesTestTable2."Child Code" := WordTemplatesTestTable4.Code;
        WordTemplatesTestTable2.Insert();
    end;

    local procedure ExcludeSelectedField(WordTemplateCode: Code[30]; TableId: Integer; FieldNo: Integer; var TempWordTemplateFields: Record "Word Template Field" temporary)
    var
        Field: Record Field;
    begin
        if not Field.Get(TableId, FieldNo) then
            exit;

        TempWordTemplateFields.Init();
        TempWordTemplateFields."Word Template Code" := WordTemplateCode;
        TempWordTemplateFields."Table ID" := TableId;
        TempWordTemplateFields."Field Name" := Field.FieldName;
        TempWordTemplateFields."Field No." := FieldNo;
        TempWordTemplateFields.Exclude := true;
        TempWordTemplateFields.Insert();
    end;

    local procedure GetTemplateDocument(): Text
    begin
        exit('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');
    end;

    local procedure GetTemplateDocumentSecondLevelRelations(): Text
    begin
        exit('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');
    end;

    local procedure GetTemplateDocumentSelectedRecord(): Text
    begin
        exit('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')
    end;
}