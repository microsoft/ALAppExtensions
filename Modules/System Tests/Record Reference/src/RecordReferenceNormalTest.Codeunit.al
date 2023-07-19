// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// These test must match the tests in 138707 "Record Reference Interf. Test"
/// </summary>
#pragma warning disable AA0217
codeunit 138706 "Record Reference Normal Test"
{
    Subtype = test;
    TestPermissions = Restrictive;
    Permissions = tabledata "Record Reference Test" = rimd,
                  tabledata "Record Link" = rimd;

    var
        LibraryAssert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";
        IsInitialized: Boolean;

    [Test]
    procedure TestIndirectPermissionFail()
    var
        RecordReferenceTest: Record "Record Reference Test";
    begin
        // Init
        Initialize();

        // Setup
        PermissionsMock.Set('RecRefTest-Object'); // resets to only X

        // Exercise
        asserterror RecordReferenceTest.Get(1); // no read access
        asserterror RecordReferenceTest.Insert(); // no insert access
#pragma warning disable AA0214
        asserterror RecordReferenceTest.Modify(); // no modify access
#pragma warning restore AA0214
        asserterror RecordReferenceTest.Delete(); // no read access

        // Verify
    end;

    [Test]
    procedure TestRecordRefNoPermissions()
    var
        RecordRef: RecordRef;
    begin
        // Init
        Initialize();

        // Setup
        PermissionsMock.Set('RecRefTest-Object'); // resets to only X
        RecordRef.Open(Database::"Record Reference Test");

        // Exercise
        LibraryAssert.IsFalse(RecordRef.ReadPermission(), 'read permission');
        LibraryAssert.IsFalse(RecordRef.WritePermission(), 'write permission');

        // Verify
    end;

    [Test]
    procedure TestRecordRefPermissions()
    var
        RecordRef: RecordRef;
    begin
        // Init
        Initialize();

        // Setup
        PermissionsMock.Set('RecRefTest-Object'); // resets to only X

        // Exercise
        RecordRef.Open(Database::"Record Reference Test");

        //permissions
        LibraryAssert.IsFalse(RecordRef.ReadPermission(), 'read permission');
        PermissionsMock.Assign('RecRefTest-Read'); // grants r
        LibraryAssert.IsTrue(RecordRef.ReadPermission(), 'no read permission');

        PermissionsMock.Assign('RecRefTest-Insert'); // grants i
        LibraryAssert.IsFalse(RecordRef.WritePermission(), 'write permission');
        PermissionsMock.Assign('RecRefTest-Modify'); // grants m
        LibraryAssert.IsFalse(RecordRef.WritePermission(), 'write permission');
        PermissionsMock.Assign('RecRefTest-Delete'); // grants d
        LibraryAssert.IsTrue(RecordRef.WritePermission(), 'no write permission');

        // Verify
    end;

    [Test]
    procedure TestRecordRefReadPermission()
    var
        RecordReferenceTest: Record "Record Reference Test";
        RecordReferenceTest2: Record "Record Reference Test";
        RecordRef: RecordRef;
    begin
        // Init
        Initialize();

        // Setup
        RecordReferenceTest.Get(1);
        RecordReferenceTest2.Get(2);
        PermissionsMock.Set('RecRefTest-Object'); // grants only an irrelevant X
        PermissionsMock.Assign('RecRefTest-Read'); // grants r
        RecordRef.Open(Database::"Record Reference Test");

        // Exercise
        LibraryAssert.IsFalse(RecordRef.IsEmpty(), 'record is empty');
        LibraryAssert.AreEqual(2, RecordRef.Count(), 'wrong count');
        LibraryAssert.AreEqual(2, RecordRef.CountApprox(), 'wrong count approx');
#pragma warning disable AA0181
        LibraryAssert.IsTrue(RecordRef.Find('-'), 'record was not found');
#pragma warning restore AA0181
        LibraryAssert.IsTrue(RecordRef.FindLast(), 'last record was not found');
        LibraryAssert.IsTrue(RecordRef.FindFirst(), 'first record was not found');
        LibraryAssert.IsTrue(RecordRef.FindSet(), 'record set was not found');
        LibraryAssert.AreEqual(1, RecordRef.Next(), 'next record was not found');
        LibraryAssert.IsTrue(RecordRef.Get(RecordReferenceTest.RecordId()), 'could not get record');
        LibraryAssert.IsTrue(RecordRef.GetBySystemId(RecordReferenceTest2.SystemId), 'could not get record by systemid');

        // Verify
    end;

    [Test]
    procedure TestRecordRefInsertPermission()
    var
        RecordReferenceTest: Record "Record Reference Test";
        RecordRef: RecordRef;
        EntryNo: Integer;
    begin
        // Init
        Initialize();
        PermissionsMock.Set('RecRefTest-Object'); // grants only an irrelevant X
        PermissionsMock.Assign('RecRefTest-Read'); // grants r
        RecordRef.Open(Database::"Record Reference Test");
        LibraryAssert.IsTrue(RecordRef.FindLast(), 'last record was not found');

        // Setup
        PermissionsMock.Set('RecRefTest-Object'); // grants only an irrelevant X
        PermissionsMock.Assign('RecRefTest-Insert'); // grants i

        // Exercise
        // insert 
        EntryNo := RecordRef.Field(RecordReferenceTest.FieldNo("Entry No.")).Value();
        RecordRef.Field(RecordReferenceTest.FieldNo("Entry No.")).Value(EntryNo + 1);
        LibraryAssert.IsTrue(RecordRef.Insert(), 'record was not inserted');

        // Verify
        ClearLastError();
        PermissionsMock.Assign('RecRefTest-Read'); // grants r
        LibraryAssert.IsFalse(RecordRef.Insert(), 'record was inserted');
        RecordRef.FindLast(); // flush insert cache to trigger error

        ClearLastError();
        asserterror
        begin
            RecordRef.Insert();
            RecordRef.FindLast() // flush insert cache to trigger error
        end;
        LibraryAssert.ExpectedError('The record in table Record Reference Test Caption already exists');
    end;

    [Test]
    procedure TestRecordRefModifyPermission()
    var
        RecordReferenceTest: Record "Record Reference Test";
        RecordRef: RecordRef;
    begin
        // Init
        Initialize();

        // Setup
        RecordReferenceTest.Get(1);
        PermissionsMock.Set('RecRefTest-Object'); // grants only an irrelevant X
        PermissionsMock.Assign('RecRefTest-Modify'); // grants m
        RecordRef.GetTable(RecordReferenceTest);

        // Exercise
        RecordRef.Field(RecordReferenceTest.FieldNo("Description 2")).Value('New Description');
        LibraryAssert.IsTrue(RecordRef.Modify(), 'record was not modified');

        // Verify
        PermissionsMock.Assign('RecRefTest-Read'); // grants r
        RecordRef.Get(RecordRef.RecordId);
        LibraryAssert.AreEqual('New Description', RecordRef.Field(RecordReferenceTest.FieldNo("Description 2")).Value(), 'value is not correct');

        PermissionsMock.Assign('RecRefTest-Delete'); // grants d
        RecordRef.Delete();
        LibraryAssert.IsFalse(RecordRef.Modify(), 'record was modified');

        ClearLastError();
        asserterror
        begin
            RecordRef.Modify();
            RecordRef.FindLast() // flush insert cache to trigger error
        end;
        LibraryAssert.ExpectedError('The Record Reference Test Caption does not exist');
    end;

    [Test]
    procedure TestRecordRefDeletePermission()
    var
        RecordRef: RecordRef;
    begin
        // Init
        Initialize();
        PermissionsMock.Set('RecRefTest-Object'); // grants only an irrelevant X
        PermissionsMock.Assign('RecRefTest-Read'); // grants r
        RecordRef.Open(Database::"Record Reference Test");
        LibraryAssert.IsTrue(RecordRef.FindFirst(), 'first record was not found');
        LibraryAssert.AreEqual(2, RecordRef.Count(), 'there should be 2 records');

        // Setup
        PermissionsMock.Set('RecRefTest-Object'); // grants only an irrelevant X
        PermissionsMock.Assign('RecRefTest-Delete'); // grants d

        // Exercise
        RecordRef.Delete();
        PermissionsMock.Set('RecRefTest-Object'); // grants only an irrelevant X
        PermissionsMock.Assign('RecRefTest-Read'); // grants r
        LibraryAssert.AreEqual(1, RecordRef.Count(), 'there should be 1 record');
        LibraryAssert.IsTrue(RecordRef.FindFirst(), 'first record was not found');
        PermissionsMock.Set('RecRefTest-Object'); // grants only an irrelevant X
        PermissionsMock.Assign('RecRefTest-Delete'); // grants d
        LibraryAssert.IsTrue(RecordRef.Delete(), 'the record was not deleted');
        PermissionsMock.Set('RecRefTest-Object'); // grants only an irrelevant X
        PermissionsMock.Assign('RecRefTest-Read'); // grants r
        LibraryAssert.IsTrue(RecordRef.IsEmpty(), 'record is not empty');

        // Verify
        ClearLastError();
        PermissionsMock.Set('RecRefTest-Object'); // grants only an irrelevant X
        PermissionsMock.Assign('RecRefTest-Read'); // grants r
        PermissionsMock.Assign('RecRefTest-Delete'); // grants d
        asserterror
        begin
            RecordRef.Delete();
            RecordRef.FindLast() // flush insert cache to trigger error
        end;
        LibraryAssert.ExpectedError('The Record Reference Test Caption does not exist');
    end;

    [Test]
    procedure TestRecordRefDeleteAllPermission()
    var
        RecordRef: RecordRef;
    begin
        // Init
        Initialize();
        PermissionsMock.Set('RecRefTest-Object'); // grants only an irrelevant X
        PermissionsMock.Assign('RecRefTest-Read'); // grants r
        RecordRef.Open(Database::"Record Reference Test");
        LibraryAssert.AreEqual(2, RecordRef.Count(), 'there should be 2 records');

        // Setup
        PermissionsMock.Set('RecRefTest-Object'); // grants only an irrelevant X
        PermissionsMock.Assign('RecRefTest-Delete'); // grants d

        // Exercise
        RecordRef.DeleteAll(true);

        //Verify
        PermissionsMock.Set('RecRefTest-Object'); // grants only an irrelevant X
        PermissionsMock.Assign('RecRefTest-Read'); // grants r
        LibraryAssert.IsTrue(RecordRef.IsEmpty(), 'record is not empty');
    end;

    [Test]
    procedure TestRecordRefActions()
    var
        RecordReferenceTest: Record "Record Reference Test";
        RecordReferenceTest2: Record "Record Reference Test";
        RecordRef: RecordRef;
        RecordRefDuplicate: RecordRef;
    begin
        // Init
        Initialize();

        // Setup
        RecordReferenceTest.Get(1);
        RecordReferenceTest2.Get(2);
        PermissionsMock.Set('RecRefTest-Object'); // resets to only X
        RecordRef.Open(Database::"Record Reference Test");

        // Exercise
        //RecordRef.ChangeCompany(); // ? can we test this easily?
        RecordRef.GetTable(RecordReferenceTest);
        RecordRefDuplicate := RecordRef.Duplicate();
        RecordRef.Copy(RecordReferenceTest2);
        RecordRef.SetTable(RecordReferenceTest2);
        RecordRef.Close();

        // Verify
    end;

    [Test]
    procedure TestRecordRefLoadFields()
    var
        RecordReferenceTest: Record "Record Reference Test";
        RecordRef: RecordRef;
    begin
        // Init
        Initialize();

        // Setup
        RecordReferenceTest.Get(1);
        PermissionsMock.Set('RecRefTest-Object'); // resets to only X
        RecordRef.Open(Database::"Record Reference Test");

        // Exercise
        RecordRef.SetLoadFields(RecordReferenceTest.FieldNo("Description"));
        RecordRef.AddLoadFields(RecordReferenceTest.FieldNo("Description 2"));
        RecordRef.GetTable(RecordReferenceTest);
        RecordRef.LoadFields(RecordReferenceTest.FieldNo("Description 3"));
        LibraryAssert.IsTrue(RecordRef.AreFieldsLoaded(RecordReferenceTest.FieldNo("Description 2")), 'Description 2 was not loaded');

        // Verify
    end;

    [Test]
    procedure TestRecordRefMetadata()
    var
        RecordReferenceTest: Record "Record Reference Test";
        RecordRef: RecordRef;
    begin
        // Init
        Initialize();

        // Setup
        RecordReferenceTest.Get(1);
        PermissionsMock.Set('RecRefTest-Object'); // resets to only X
        RecordRef.GetTable(RecordReferenceTest);

        // Exercise
        LibraryAssert.AreEqual(Database::"Record Reference Test", RecordRef.Number(), 'not the right number');
        LibraryAssert.AreEqual('Record Reference Test', RecordRef.Name(), 'not the right name');
        LibraryAssert.AreEqual('Record Reference Test Caption', RecordRef.Caption(), 'not the right caption');
        LibraryAssert.AreEqual(CompanyName(), RecordRef.CurrentCompany(), 'company is not the same');
        RecordRef.LockTable();
        LibraryAssert.IsFalse(RecordRef.IsDirty(), 'record is dirty');
        LibraryAssert.IsFalse(RecordRef.IsTemporary(), 'record is temporary');
        LibraryAssert.IsFalse(RecordRef.ReadConsistency(), 'ReadConsistency is enabled');
        LibraryAssert.IsTrue(RecordRef.RecordLevelLocking(), 'RecordLevelLocking is not enabled');

        // Verify
    end;

    [Test]
    procedure TestRecordRefMarks()
    var
        RecordReferenceTest: Record "Record Reference Test";
        RecordRef: RecordRef;

    begin
        // Init
        Initialize();

        // Setup
        RecordReferenceTest.Get(1);
        PermissionsMock.Set('RecRefTest-Object'); // resets to only X
        RecordRef.GetTable(RecordReferenceTest);

        // Exercise
        RecordRef.Mark(true);
        RecordRef.MarkedOnly(true);
        RecordRef.ClearMarks();

        // Verify
    end;

    [Test]
    procedure TestRecordRefKeys()
    var
        RecordReferenceTest: Record "Record Reference Test";
        RecordRef: RecordRef;
        KeyRef: KeyRef;
    begin
        // Init
        Initialize();

        // Setup
        RecordReferenceTest.Get(1);
        PermissionsMock.Set('RecRefTest-Object'); // resets to only X
        RecordRef.GetTable(RecordReferenceTest);

        // Exercise
        LibraryAssert.AreEqual('Entry No.', RecordRef.CurrentKey(), 'not the right key');
        LibraryAssert.AreEqual(1, RecordRef.CurrentKeyIndex(), 'not the right keyindex');
        KeyRef := RecordRef.KeyIndex(RecordRef.CurrentKeyIndex());
        LibraryAssert.IsTrue(RecordRef.Ascending, 'order is not ascending');
        LibraryAssert.IsFalse(RecordRef.Ascending(false), 'order is not descending');

        // Verify
    end;

    [Test]
    procedure TestRecordRefFields()
    var
        RecordReferenceTest: Record "Record Reference Test";
        RecordId: RecordId;
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        FieldNo: Integer;
    begin
        // Init
        Initialize();

        // Setup
        RecordReferenceTest.Get(1);
        PermissionsMock.Set('RecRefTest-Object'); // resets to only X
        RecordRef.GetTable(RecordReferenceTest);

        // Exercise
        // fields
#pragma warning disable AA0206
        FieldNo := RecordRef.SystemCreatedAtNo;
        FieldNo := RecordRef.SystemCreatedByNo;
        FieldNo := RecordRef.SystemIdNo;
        FieldNo := RecordRef.SystemModifiedAtNo;
        FieldNo := RecordRef.SystemModifiedByNo;
#pragma warning restore AA0206

        FieldRef := RecordRef.Field(RecordReferenceTest.FieldNo("Entry No."));
        LibraryAssert.AreEqual(RecordReferenceTest."Entry No.", FieldRef.Value, 'not the right value');
        LibraryAssert.AreEqual(4, RecordRef.FieldCount(), 'wrong number of fields');
        LibraryAssert.IsTrue(RecordRef.FieldExist(RecordReferenceTest.FieldNo(Description)), 'field does not exist');
        LibraryAssert.AreEqual(RecordReferenceTest.FieldName(Description), RecordRef.FieldIndex(RecordReferenceTest.FieldNo(Description)).Value, 'wrong field value');
        RecordId := RecordRef.RecordId;
        RecordRef.Init();
        LibraryAssert.AreEqual('', RecordRef.FieldIndex(RecordReferenceTest.FieldNo(Description)).Value, 'wrong field value');

        // Verify
    end;

    [Test]
    procedure TestRecordRefFilters()
    var
        RecordReferenceTest: Record "Record Reference Test";
        RecordReferenceTest2: Record "Record Reference Test";
        RecordRef: RecordRef;
        SecurityFilter: SecurityFilter;
    begin
        // Init
        Initialize();

        // Setup
        RecordReferenceTest.Get(1);
        RecordReferenceTest2.Get(2);
        PermissionsMock.Set('RecRefTest-Object'); // resets to only X
        RecordRef.GetTable(RecordReferenceTest);

        // Exercise
        RecordRef.FilterGroup(5);
        LibraryAssert.AreEqual(10, RecordRef.FilterGroup(10), 'wrong filtergroup');
        RecordRef.FilterGroup(0);
        RecordRef.SetRecFilter();
        LibraryAssert.IsTrue(RecordRef.HasFilter(), 'no filter is set');
        LibraryAssert.AreEqual(StrSubstNo('%1: %2', RecordReferenceTest.FieldCaption("Entry No."), RecordReferenceTest."Entry No."), RecordRef.GetFilters(), 'wrong filter');
        LibraryAssert.AreEqual(StrSubstNo('VERSION(1) SORTING(Field%1) WHERE(Field%1=1(%2))', RecordReferenceTest.FieldNo("Entry No."), RecordReferenceTest."Entry No."), RecordRef.GetView(false), 'wrong view');
        RecordRef.SetPermissionFilter();
        SecurityFilter := RecordRef.SecurityFiltering();
        RecordRef.SetView(RecordReferenceTest2.GetView(false));
        RecordRef.SetPosition(RecordReferenceTest2.GetPosition(false));
        LibraryAssert.AreEqual(StrSubstNo('Field%1=0(%2)', RecordReferenceTest2.FieldNo("Entry No."), RecordReferenceTest2."Entry No."), RecordRef.GetPosition(false), 'wrong position');
        RecordRef.Reset();

        // Verify
    end;

    [Test]
    procedure TestRecordRefLinks()
    var
        RecordReferenceTest: Record "Record Reference Test";
        RecordRef: RecordRef;
        LinkId: Integer;
    begin
        // Init
        Initialize();

        // Setup
        RecordReferenceTest.Get(1);
        PermissionsMock.Set('RecRefTest-Object'); // resets to only X
        RecordRef.GetTable(RecordReferenceTest);

        // Exercise
        LinkId := RecordRef.AddLink('url', 'description');
        LibraryAssert.IsTrue(RecordRef.HasLinks(), 'record has no links');
        RecordRef.DeleteLink(LinkId);
        RecordReferenceTest.AddLink('url2', 'description');
        RecordRef.CopyLinks(RecordReferenceTest);
        RecordRef.DeleteLinks();

        // Verify
    end;

    local procedure Initialize()
    var
        RecordReferenceTest: Record "Record Reference Test";
        RecordReferenceTest2: Record "Record Reference Test";
    begin
        RecordReferenceTest.DeleteAll();
        RecordReferenceTest.Description := CopyStr(RecordReferenceTest.FieldName(Description), 1, MaxStrLen(RecordReferenceTest.Description));
        RecordReferenceTest."Entry No." := 1;
        RecordReferenceTest.Insert();
        RecordReferenceTest2."Entry No." := RecordReferenceTest."Entry No." + 1;
        RecordReferenceTest2.Insert();

        if IsInitialized then
            exit;

        Commit();
    end;
}