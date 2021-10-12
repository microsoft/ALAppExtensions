// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135036 "Field Selection Test"
{
    Subtype = Test;

    var
        Assert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";

    [Test]
    [HandlerFunctions('FieldLookupFilteredRecordPageHandler')]
    procedure FiltersOnFieldTableAreRespectedTest()
    var
        Field: Record Field;
        FieldSelection: Codeunit "Field Selection";
    begin
        // [SCENARIO] Filters set on the Field record are respected.
        PermissionsMock.Set('Field Selection Read');
        // [GIVEN] Filters have been set on the Field Record.
        Field.SetRange(TableNo, Database::"Test Table A");
        // [WHEN] Open function is called
        // [THEN] No Field from Test Table B are visible on the lookup page
        FieldSelection.Open(Field);
    end;

    [Test]
    [HandlerFunctions('FieldLookupOKPageHandler')]
    procedure FieldLookupOkTest()
    var
        Field: Record Field;
        FieldSelection: Codeunit "Field Selection";
    begin
        // [SCENARIO] A field can be selected.
        PermissionsMock.Set('Field Selection Read');
        // [GIVEN] User selects OK
        // [THEN] Open function returns true
        Assert.IsTrue(FieldSelection.Open(Field), 'A field was expected to be selected.');
        // [THEN] The Field variable holds the selected field
        Assert.RecordCount(Field, 1);
        Assert.AreEqual(Database::"Test Table B", Field.TableNo, 'A different table number was expected.');
        Assert.AreEqual(2, Field."No.", 'A different field number was expected.');
    end;

    [Test]
    [HandlerFunctions('FieldLookupOKPageHandler')]
    procedure FieldLookupOkTemporaryRecordTest()
    var
        TempField: Record Field temporary;
        FieldSelection: Codeunit "Field Selection";
    begin
        // [SCENARIO] A field can be selected.
        PermissionsMock.Set('Field Selection Read');
        // [GIVEN] User selects OK
        // [THEN] Open function returns true
        Assert.IsTrue(FieldSelection.Open(TempField), 'A field was expected to be selected.');
        // [THEN] The Field variable holds the selected field
        Assert.RecordCount(TempField, 1);
        Assert.AreEqual(Database::"Test Table B", TempField.TableNo, 'A different table number was expected.');
        Assert.AreEqual(2, TempField."No.", 'A different field number was expected.');
    end;

    [Test]
    [HandlerFunctions('FieldLookupCancelPageHandler')]
    procedure FieldLookupCancelTest()
    var
        Field: Record Field;
        FieldSelection: Codeunit "Field Selection";
    begin
        // [SCENARIO] A field can be selected.
        PermissionsMock.Set('Field Selection Read');
        // [GIVEN] User selects OK
        // [THEN] Open function returns false
        Assert.IsFalse(FieldSelection.Open(Field), 'No field was expected to be selected');
        // [THEN] No Field from Test Table B are visible on the lookup page
    end;

    [ModalPageHandler]
    procedure FieldLookupFilteredRecordPageHandler(var FieldLookup: TestPage 9806)
    var
        Field: Record Field;
    begin
        Field.SetRange(TableNo, Database::"Test Table B");
        Field.FindFirst();
        asserterror FieldLookup.GoToRecord(Field);
    end;


    [ModalPageHandler]
    procedure FieldLookupOKPageHandler(var FieldLookup: TestPage 9806)
    var
        Field: Record Field;
    begin
        Field.SetRange(TableNo, Database::"Test Table B");
        Field.SetRange("No.", 2);
        Field.FindFirst();
        FieldLookup.GoToRecord(Field);
        FieldLookup.Ok().Invoke();
    end;

    [ModalPageHandler]
    procedure FieldLookupCancelPageHandler(var FieldLookup: TestPage 9806)
    begin
        FieldLookup.Cancel().Invoke();
    end;
}