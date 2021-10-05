// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Tests for Word Templates related tables.
/// </summary>
codeunit 130444 "Word Templates Related Test"
{
    Subtype = Test;

    var
        Assert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";

    [Test]
    procedure TestCreateDocumentInternalsWithRelatedTables()
    var
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

        // [WHEN] Run create document with related table ids and codes and save zip to temp blob
        WordTemplatesImpl.Create(Database::"Word Template", RelatedTableIds, RelatedTableCodes);

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
        Assert.IsTrue(MergeFields.Contains('TESTB_Table Caption'), 'TESTB_Table Captionshould have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TESTB_System ID'), 'TESTB_System ID should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TESTB_Created At'), 'TESTB_Created At should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TESTB_Created By'), 'TESTB_Created By should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TESTB_Modified At'), 'TESTB_Modified At should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('TESTB_Modified By'), 'TESTB_Modified By should have been part of the Merge Fields.');

        // [THEN] Verify the TableNo of the Template is set correctly
        Assert.AreEqual(Database::"Word Template", WordTemplatesImpl.GetTableId(), 'A different table ID was expected.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestCreateTemplateWithIdenticalFieldCaptions()
    var
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
        WordTemplatesImpl.Create(Database::"Word Templates Test Table 2", RelatedTableIds, RelatedTableCodes);

        // [THEN] Verify the Merge fields are set correctly
        WordTemplatesImpl.GetMergeFields(MergeFields);

        Assert.IsTrue(MergeFields.Contains('No.'), 'No. should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('Value'), 'Value should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('Child Id'), 'Child Id should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('Child Code'), 'Child Code should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('Test Value'), 'Test Value should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('Test Value_2'), 'Test Value_2 should have been part of the Merge Fields.');
        Assert.IsTrue(MergeFields.Contains('Value_2'), 'Value_2 should have been part of the Merge Fields.');

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
    begin
        // [SCENARIO] Generated code is correct 
        PermissionsMock.Set('Word Templates Edit');

        Assert.AreEqual('TESTS', WordTemplateImpl.GenerateCode('Test String'), 'Generated code should be TESTS');
        Assert.AreEqual('ANOTH', WordTemplateImpl.GenerateCode('Another String'), 'Generated code should be ANOTH');
        Assert.AreEqual('STRIN', WordTemplateImpl.GenerateCode('S t r i n g'), 'Generated code should be STRIN');
        Assert.AreEqual('ABC', WordTemplateImpl.GenerateCode('Abc'), 'Generated code should be ABC');
    end;

    [Test]
    procedure TestGenerateCodeWithNumbers()
    var
        WordTemplateImpl: Codeunit "Word Template Impl.";
    begin
        // [SCENARIO] Generated code is correct when using numbers
        PermissionsMock.Set('Word Templates Edit');

        Assert.AreEqual('TESTS', WordTemplateImpl.GenerateCode('1Test String'), 'Generated code should be TESTS');
        Assert.AreEqual('A5432', WordTemplateImpl.GenerateCode('12345A54321'), 'Generated code should be A5432');
        Assert.AreEqual('TEST1', WordTemplateImpl.GenerateCode('Test 12345'), 'Generated code should be TEST1');
    end;


    [Test]
    procedure TestGenerateCodeWithSpecialCharacters()
    var
        WordTemplateImpl: Codeunit "Word Template Impl.";
    begin
        // [SCENARIO] Generated code is correct when using special characters
        PermissionsMock.Set('Word Templates Edit');

        Assert.AreEqual('TESTS', WordTemplateImpl.GenerateCode('_Test: String'), 'Generated code should be TESTS');
        Assert.AreEqual('TEST', WordTemplateImpl.GenerateCode('Testæøå'), 'Generated code should be TEST');
        Assert.AreEqual('ABC', WordTemplateImpl.GenerateCode('µ¶abc'), 'Generated code should be ABC');
    end;

    [Test]
    procedure TestGenerateCodeWhenEmpty()
    var
        WordTemplateImpl: Codeunit "Word Template Impl.";
    begin
        // [SCENARIO] Generated code is correct when the result is empty
        PermissionsMock.Set('Word Templates Edit');

        Assert.AreEqual('', WordTemplateImpl.GenerateCode(''), 'Generated code should be empty');
        Assert.AreEqual('', WordTemplateImpl.GenerateCode('ÆØÅ'), 'Generated code should be empty');
        Assert.AreEqual('', WordTemplateImpl.GenerateCode('123'), 'Generated code should be empty');
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

        WordTemplateRec.Code := 'TEST';
        WordTemplateRec.Template.ImportStream(InStream, 'Template');
        WordTemplateRec.Insert();

        // [WHEN] Related table is added
        TempWordTemplateRelatedRec.Code := WordTemplateRec.Code;
        TempWordTemplateRelatedRec."Table ID" := Database::"Word Template";
        TempWordTemplateRelatedRec."Related Table ID" := Database::"Word Templates Related Table";
        TempWordTemplateRelatedRec."Related Table Code" := 'TESTA';
        TempWordTemplateRelatedRec."Field No." := TempWordTemplateRelatedRec.FieldNo(Code);

        Added := WordTemplateImpl.AddRelatedTable(WordTemplateRelatedRec, TempWordTemplateRelatedRec);

        PermissionsMock.ClearAssignments();

        // [THEN] One related table was added
        Assert.IsTrue(Added, 'The related table should have been added.');
        Assert.AreEqual(WordTemplateRelatedRec.Count(), 1, 'There should only be one related table added.');

        // [THEN] The values of the related table are as expected
        WordTemplateRelatedRec.FindFirst();
        Assert.AreEqual(WordTemplateRelatedRec.Code, 'TEST', 'Code should be TEST');
        Assert.AreEqual(WordTemplateRelatedRec."Table ID", Database::"Word Template", 'Table ID should be the ID of the Word Template table.');
        Assert.AreEqual(WordTemplateRelatedRec."Related Table ID", Database::"Word Templates Related Table", 'Related Table ID should be the ID of Word Templates Related Table.');
        Assert.AreEqual(WordTemplateRelatedRec."Related Table Code", 'TESTA', 'Related Table Code should be TESTA');
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

        WordTemplateRec.Code := 'TEST';
        WordTemplateRec.Template.ImportStream(InStream, 'Template');
        WordTemplateRec.Insert();

        // [GIVEN] One related table is added
        TempWordTemplateRelatedRec.Code := 'TEST';
        TempWordTemplateRelatedRec."Table ID" := Database::"Word Template";
        TempWordTemplateRelatedRec."Related Table ID" := Database::"Word Templates Related Table";
        TempWordTemplateRelatedRec."Related Table Code" := 'TESTA';
        TempWordTemplateRelatedRec."Field No." := 1;
        WordTemplateImpl.AddRelatedTable(WordTemplateRelatedRec, TempWordTemplateRelatedRec);

        // [WHEN] Attempting to add another related table with the same related table code
        TempWordTemplateRelatedRec.Reset();
        TempWordTemplateRelatedRec.Code := 'TEST';
        TempWordTemplateRelatedRec."Table ID" := Database::"Word Template";
        TempWordTemplateRelatedRec."Related Table ID" := Database::"Word Templates Table";
        TempWordTemplateRelatedRec."Related Table Code" := 'TESTA'; // Code is already used, should not insert.
        TempWordTemplateRelatedRec."Field No." := 1;

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

        WordTemplateRec.Code := 'TEST';
        WordTemplateRec.Template.ImportStream(InStream, 'Template');
        WordTemplateRec.Insert();

        // [GIVEN] One related table is added
        TempWordTemplateRelatedRec.Code := 'TEST';
        TempWordTemplateRelatedRec."Table ID" := Database::"Word Template";
        TempWordTemplateRelatedRec."Related Table ID" := Database::"Word Templates Related Table";
        TempWordTemplateRelatedRec."Related Table Code" := 'TESTA';
        TempWordTemplateRelatedRec."Field No." := 1;
        WordTemplateImpl.AddRelatedTable(WordTemplateRelatedRec, TempWordTemplateRelatedRec);

        // [WHEN] Attempting to add another related table with the same related table id
        TempWordTemplateRelatedRec.Reset();
        TempWordTemplateRelatedRec.Code := 'TEST';
        TempWordTemplateRelatedRec."Table ID" := Database::"Word Template";
        TempWordTemplateRelatedRec."Related Table ID" := Database::"Word Templates Related Table"; // Table ID is already used, should not insert.
        TempWordTemplateRelatedRec."Related Table Code" := 'TESTB';
        TempWordTemplateRelatedRec."Field No." := 1;

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

        WordTemplateRec.Code := 'TEST';
        WordTemplateRec."Table ID" := Database::"Word Templates Test Table 2";
        WordTemplateRec.Template.ImportStream(InStream, 'Template');
        WordTemplateRec.Insert();

        RelatedTable.Code := WordTemplateRec.Code;
        RelatedTable."Field No." := 3;
        RelatedTable."Related Table Code" := 'TESTA';
        RelatedTable."Related Table ID" := Database::"Word Templates Test Table 3";
        RelatedTable.Insert();

        RelatedTable.Init();
        RelatedTable.Code := WordTemplateRec.Code;
        RelatedTable."Field No." := 4;
        RelatedTable."Related Table Code" := 'TESTB';
        RelatedTable."Related Table ID" := Database::"Word Templates Test Table 4";
        RelatedTable.Insert();

        // [GIVEN] Parent and child tables are initialized with data
        InitTestTables('Child1', 'Child2', 'Parent1', 'CODE1', 1);
        InitTestTables('Child3', 'Child4', 'Parent2', 'CODE2', 2);

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

    local procedure InitTestTables(Value1: Text[100]; Value2: Text[100]; Value3: Text[100]; Code: Code[30]; No: Integer)
    var
        WordTemplatesTestTable2: Record "Word Templates Test Table 2";
        WordTemplatesTestTable3: Record "Word Templates Test Table 3";
        WordTemplatesTestTable4: Record "Word Templates Test Table 4";
    begin
        WordTemplatesTestTable3.Id := CreateGuid();
        WordTemplatesTestTable3.Value := Value1;
        WordTemplatesTestTable3.Insert();

        WordTemplatesTestTable4.Code := Code;
        WordTemplatesTestTable4.Value := Value2;
        WordTemplatesTestTable4.Insert();

        WordTemplatesTestTable2."No." := No;
        WordTemplatesTestTable2."Child Code" := WordTemplatesTestTable4.Code;
        WordTemplatesTestTable2."Child Id" := WordTemplatesTestTable3.Id;
        WordTemplatesTestTable2.Value := Value3;
        WordTemplatesTestTable2.Insert();
    end;

    local procedure GetTemplateDocument(): Text
    begin
        exit('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');
    end;


}