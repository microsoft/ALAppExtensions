codeunit 136700 "App Object Helper Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;
    trigger OnRun()
    begin
        // [FEATURE] [TaxEngine] [AppObjectHelper] [UT]
    end;

    var
        Assert: Codeunit Assert;
        FieldNameLbl: Label 'Field name should be %1', Comment = '%1= Field Name';
        FieldNoLbl: Label 'Field No. should be %1', Comment = '%1= Field No.';
        ObjectNameLbl: Label 'Object name should be %1', Comment = '%1 = Object name';
        ObjectIDLbl: Label 'Object ID should be %1', Comment = '%1 = Object ID';

    [Test]
    procedure TestGetObjectName()
    var
        AllObj: Record AllObj;
        AppObjHelper: Codeunit "App Object Helper";
        ObjectName: Text[30];
    begin
        // [SCENARIO] Pass object type as table and Object ID of G/L Account and get the name of the object.

        // [GIVEN] There should be a table exist with the name of G/L Account.
        AllObj.Get(AllObj."Object Type"::Table, Database::"G/L Account");

        // [WHEN] The function GetObjectName is called.
        ObjectName := AllObj."Object Name";

        // [THEN] it should return the object name of G/l Account Table.
        Assert.AreEqual(ObjectName, AppObjHelper.GetObjectName(ObjectType::Table, AllObj."Object ID"), 'Object name should be G/L Account');
    end;

    [Test]
    procedure TestGetFieldName()
    var
        Field: Record Field;
        AppObjHelper: Codeunit "App Object Helper";
        FieldName: Text[30];
    begin
        // [SCENARIO] Pass Field Id of name from G/l Account table to get the field name in return.

        // [GIVEN] There should be a table exist with the name of G/L Account with field Name.
        Field.Get(Database::"G/L Account", 2);

        // [WHEN] The function GetFieldName is called.
        FieldName := Field.FieldName;

        // [THEN] it should return the Field Name from G/l Account Table.
        Assert.AreEqual(FieldName, AppObjHelper.GetFieldName(Database::"G/L Account", Field."No."), 'Field Name should be Name');
    end;

    [Test]
    procedure TestGetFieldID()
    var
        Field: Record Field;
        AppObjHelper: Codeunit "App Object Helper";
        FieldID: Integer;
    begin
        // [SCENARIO] Pass Field name of name field from G/l Account table to get the field ID in return.   

        // [GIVEN] There should be a table exist with the name of G/L Account with field Name.
        Field.SetRange(TableNo, Database::"G/L Account");
        Field.SetFilter(FieldName, '%1', 'Name');
        Field.FindFirst();

        // [WHEN] The function GetFieldID is called.
        FieldID := Field."No.";

        // [THEN] it should return the Field ID from G/l Account Table.
        Assert.AreEqual(FieldID, AppObjHelper.GetFieldID(Database::"G/L Account", Field.FieldName), 'Field ID should be 2');
    end;

    [Test]
    procedure TestSearchTableFieldForFieldName()
    var
        Field: Record Field;
        AppObjHelper: Codeunit "App Object Helper";
        FieldName: Text[30];
        FieldID: Integer;
    begin
        // [SCENARIO] Pass Field ID of name field from G/l Account table to get the field Name as refrence.

        // [GIVEN] There should be a table exist with the name of G/L Account with field Name.
        Field.SetRange(TableNo, Database::"G/L Account");
        Field.SetFilter(FieldName, '%1', 'Name');
        Field.FindFirst();

        // [WHEN] The function SearchTableField is called.
        FieldName := format(Field."No.");
        AppObjHelper.SearchTableField(Database::"G/L Account", FieldID, FieldName);

        // [THEN] it should update FieldName with the name of the field from G/l Account Table.
        Assert.AreEqual(Field.FieldName, FieldName, 'Field Name should be Name');
        Assert.AreEqual(Field."No.", FieldID, 'Field No should be 2');
    end;

    [Test]
    procedure TestSearchTableFieldForFieldID()
    var
        Field: Record Field;
        AppObjHelper: Codeunit "App Object Helper";
        FieldName: Text[30];
        FieldID: Integer;
    begin
        // [SCENARIO] Pass Field ID of name field from G/l Account table to get the field Name as refrence.

        // [GIVEN] There should be a table exist with the name of G/L Account with field as "Name".
        Field.SetRange(TableNo, Database::"G/L Account");
        Field.SetFilter(FieldName, '%1', 'Name');
        Field.FindFirst();

        // [WHEN] The function SearchTableField is called.
        FieldName := Field.FieldName;
        AppObjHelper.SearchTableField(Database::"G/L Account", FieldID, FieldName);

        // [THEN] it should update FieldID with the ID of the field from G/l Account Table.
        Assert.AreEqual(Field."No.", FieldID, 'Field No. should be 2');
    end;

    [Test]
    procedure TestSearchTableFieldOfTypeNumber()
    var
        Field: Record Field;
        AppObjHelper: Codeunit "App Object Helper";
        FieldName: Text[30];
        FieldID: Integer;
    begin
        // [SCENARIO] Pass Field of Type Integer from G/L Account table to get the field ID.

        // [GIVEN] There should be a table exist with type Integer in G/L Account table.
        Field.SetRange(TableNo, Database::"G/L Account");
        Field.SetFilter(Type, '%1|%2|%3|%4', Field.Type::Option, Field.Type::Integer, Field.Type::Decimal, Field.Type::BigInteger);
        Field.FindFirst();

        // [WHEN] The function SearchTableFieldOfType is called.
        FieldName := format(Field."No.");
        AppObjHelper.SearchTableFieldOfType(Database::"G/L Account", FieldID, FieldName, "Symbol Data type"::NUMBER);

        // [THEN] it should update FieldName with the Field name G/l Account Table.
        Assert.AreEqual(Field.FieldName, FieldName, StrSubstNo(FieldNameLbl, Field."Field Caption"));
        Assert.AreEqual(Field."No.", FieldID, StrSubstNo(FieldNoLbl, Field."No."));
    end;

    [Test]
    procedure TestSearchTableFieldOfTypeString()
    var
        Field: Record Field;
        AppObjHelper: Codeunit "App Object Helper";
        FieldName: Text[30];
        FieldID: Integer;
    begin
        // [SCENARIO] Pass Field ID of Type Text from G/L Account table to get the field name.

        // [GIVEN] There should be a table exist with type Integer in G/L Account table.
        Field.SetRange(TableNo, Database::"G/L Account");
        Field.SetFilter(Type, '%1', Field.Type::Text);
        Field.FindFirst();

        // [WHEN] The function SearchTableFieldOfType is called.
        FieldName := format(Field."No.");
        AppObjHelper.SearchTableFieldOfType(Database::"G/L Account", FieldID, FieldName, "Symbol Data type"::STRING);

        // [THEN] it should update FieldName with the Field name G/l Account Table.
        Assert.AreEqual(Field.FieldName, FieldName, StrSubstNo(FieldNameLbl, Field.FieldName));
        Assert.AreEqual(Field."No.", FieldID, StrSubstNo(FieldNoLbl, Field."No."));
    end;

    [Test]
    procedure TestSearchTableFieldOfTypeBoolean()
    var
        Field: Record Field;
        AppObjHelper: Codeunit "App Object Helper";
        FieldName: Text[30];
        FieldID: Integer;
    begin
        // [SCENARIO] Pass Field ID of Type Boolean from G/L Account table to get the field name.

        // [GIVEN] There should be a table exist with type Boolean in G/L Account table.
        Field.SetRange(TableNo, Database::"G/L Account");
        Field.SetFilter(Type, '%1', Field.Type::Boolean);
        Field.FindFirst();

        // [WHEN] The function SearchTableFieldOfType is called.
        FieldName := format(Field."No.");
        AppObjHelper.SearchTableFieldOfType(Database::"G/L Account", FieldID, FieldName, "Symbol Data type"::BOOLEAN);

        // [THEN] it should update FieldName with the Field name G/l Account Table.
        Assert.AreEqual(Field.FieldName, FieldName, StrSubstNo(FieldNameLbl, Field.FieldName));
        Assert.AreEqual(Field."No.", FieldID, StrSubstNo(FieldNoLbl, Field."No."));
    end;

    [Test]
    procedure TestSearchTableFieldOfTypeDate()
    var
        Field: Record Field;
        AppObjHelper: Codeunit "App Object Helper";
        FieldName: Text[30];
        FieldID: Integer;
    begin
        // [SCENARIO] Pass Field ID of Type Date from G/L Account table to get the field name.

        // [GIVEN] There should be a table exist with type Date in G/L Account table.
        Field.SetRange(TableNo, Database::"G/L Account");
        Field.SetFilter(Type, '%1', Field.Type::Date);
        Field.FindFirst();

        // [WHEN] The function SearchTableFieldOfType is called.
        FieldName := format(Field."No.");
        AppObjHelper.SearchTableFieldOfType(Database::"G/L Account", FieldID, FieldName, "Symbol Data type"::DATE);

        // [THEN] it should update FieldName with the Field name G/l Account Table.
        Assert.AreEqual(Field.FieldName, FieldName, StrSubstNo(FieldNameLbl, Field.FieldName));
        Assert.AreEqual(Field."No.", FieldID, StrSubstNo(FieldNoLbl, Field."No."));
    end;

    [Test]
    procedure TestSearchTableFieldOfTypeDateTime()
    var
        Field: Record Field;
        AppObjHelper: Codeunit "App Object Helper";
        FieldName: Text[30];
        FieldID: Integer;
    begin
        // [SCENARIO] Pass Field ID of Type DateTime from G/L Account table to get the field name.

        // [GIVEN] There should be a table exist with type DateTime in G/L Account table.
        Field.SetRange(TableNo, Database::"G/L Account");
        Field.SetFilter(Type, '%1', Field.Type::DateTime);
        Field.FindFirst();

        // [WHEN] The function SearchTableFieldOfType is called.
        FieldName := format(Field."No.");
        AppObjHelper.SearchTableFieldOfType(Database::"G/L Account", FieldID, FieldName, "Symbol Data type"::DATETIME);

        // [THEN] it should update FieldName with the Field name G/l Account Table.
        Assert.AreEqual(Field.FieldName, FieldName, StrSubstNo(FieldNameLbl, Field.FieldName));
        Assert.AreEqual(Field."No.", FieldID, StrSubstNo(FieldNoLbl, Field."No."));
    end;

    [Test]
    procedure TestSearchTableFieldOfTypeGuid()
    var
        Field: Record Field;
        AppObjHelper: Codeunit "App Object Helper";
        FieldName: Text[30];
        FieldID: Integer;
    begin
        // [SCENARIO] Pass Field ID of Type Guid from G/L Account table to get the field name.

        // [GIVEN] There should be a table exist with type Guid in G/L Account table.
        Field.SetRange(TableNo, Database::"G/L Account");
        Field.SetFilter(Type, '%1', Field.Type::GUID);
        Field.FindFirst();

        // [WHEN] The function SearchTableFieldOfType is called.
        FieldName := format(Field."No.");
        AppObjHelper.SearchTableFieldOfType(Database::"G/L Account", FieldID, FieldName, "Symbol Data type"::Guid);

        // [THEN] it should update FieldName with the Field name G/l Account Table.
        Assert.AreEqual(Field.FieldName, FieldName, StrSubstNo(FieldNameLbl, Field.FieldName));
        Assert.AreEqual(Field."No.", FieldID, StrSubstNo(FieldNoLbl, Field."No."));
    end;

    [Test]
    procedure TestSearchTableFieldOfTypeOption()
    var
        Field: Record Field;
        AppObjHelper: Codeunit "App Object Helper";
        FieldName: Text[30];
        FieldID: Integer;
    begin
        // [SCENARIO] Pass Field ID of Type Guid from G/L Account table to get the field name.

        // [GIVEN] There should be a table exist with type Guid in G/L Account table.
        Field.SetRange(TableNo, Database::"G/L Account");
        Field.SetFilter(Type, '%1', Field.Type::Option);
        Field.FindFirst();

        // [WHEN] The function SearchTableFieldOfType is called.
        FieldName := format(Field."No.");
        AppObjHelper.SearchTableFieldOfType(Database::"G/L Account", FieldID, FieldName, "Symbol Data type"::OPTION);

        // [THEN] it should update FieldName with the Field name G/l Account Table.
        Assert.AreEqual(Field.FieldName, FieldName, StrSubstNo(FieldNameLbl, Field.FieldName));
        Assert.AreEqual(Field."No.", FieldID, StrSubstNo(FieldNoLbl, Field."No."));
    end;

    [Test]
    procedure TestSearchObject()
    var
        AllObj: Record AllObj;
        AppObjHelper: Codeunit "App Object Helper";
        ObjectName: Text[30];
        ObjectID: Integer;
    begin
        // [SCENARIO] Pass the type of object as table and ID as table id of G/l Account table.

        // [GIVEN] There should be a table exist with name G/L Account.
        AllObj.Get(AllObj."Object Type"::Table, Database::"G/L Account");

        // [WHEN] The function SearchObject is called.
        ObjectName := format(AllObj."Object ID");
        AppObjHelper.SearchObject(ObjectType::Table, ObjectID, ObjectName);

        // [THEN] it should update ObjectName variable with the Table name G/l Account.
        Assert.AreEqual(AllObj."Object Name", ObjectName, StrSubstNo(ObjectNameLbl, AllObj."Object Name"));
        Assert.AreEqual(AllObj."Object ID", ObjectID, StrSubstNo(ObjectIDLbl, AllObj."Object ID"));
    end;

    [Test]
    procedure TestGetTableObjectID()
    var
        AllObj: Record AllObj;
        AppObjHelper: Codeunit "App Object Helper";
        ObjectName: Text[30];
        ObjectID: Integer;
    begin
        // [SCENARIO] Pass the type of object as table and Name as table name of G/l Account table.

        // [GIVEN] There should be a table exist with name G/L Account.
        AllObj.SetRange("Object Type", AllObj."Object Type"::Table);
        AllObj.SetFilter("Object Name", '%1', 'G/L Account');
        AllObj.FindFirst();

        // [WHEN] The function GetObjectID is called.
        ObjectName := AllObj."Object Name";
        ObjectID := AppObjHelper.GetObjectID(ObjectType::Table, ObjectName);

        // [THEN] it should update ObjectID variable with the Table ID name G/l Account.
        Assert.AreEqual(AllObj."Object ID", ObjectID, StrSubstNo(ObjectIDLbl, AllObj."Object ID"));
        Assert.AreEqual(AllObj."Object Name", ObjectName, StrSubstNo(ObjectNameLbl, AllObj."Object Name"));
    end;

    [Test]
    procedure TestGetPageObjectID()
    var
        AllObj: Record AllObj;
        AppObjHelper: Codeunit "App Object Helper";
        ObjectName: Text[30];
        ObjectID: Integer;
    begin
        // [SCENARIO] Pass the type of object as page and Name as page name of G/L Account List.

        // [GIVEN] There should be a table exist with name G/L Account.
        AllObj.SetRange("Object Type", AllObj."Object Type"::Page);
        AllObj.SetFilter("Object Name", '%1', 'G/L Account List');
        AllObj.FindFirst();

        // [WHEN] The function GetObjectID is called.
        ObjectName := AllObj."Object Name";
        ObjectID := AppObjHelper.GetObjectID(ObjectType::Page, ObjectName);

        // [THEN] it should update ObjectID variable with the page Id of G/l Account List.
        Assert.AreEqual(ObjectID, AllObj."Object ID", StrSubstNo(ObjectIDLbl, AllObj."Object ID"));
        Assert.AreEqual(ObjectName, AllObj."Object Name", StrSubstNo(ObjectNameLbl, AllObj."Object Name"));
    end;

    [Test]
    [HandlerFunctions('FieldLookupPageHandler')]
    procedure TestOpenFieldLookup()
    var
        Field: Record Field;
        AppObjHelper: Codeunit "App Object Helper";
        FieldName: Text[30];
        SearchFieldName: Text[30];
        FieldID: Integer;
    begin
        // [SCENARIO] Pass the Table ID of G/l Account and Search text as first field name found from G/l account table.

        // [GIVEN] There should be a table exist with name G/L Account.
        Field.SetRange(TableNo, Database::"G/L Account");
        Field.FindFirst();

        // [WHEN] The function OpenFieldLookup is called.
        SearchFieldName := Field.FieldName;
        AppObjHelper.OpenFieldLookup(Database::"G/L Account", FieldID, FieldName, SearchFieldName);

        // [THEN] it should update FieldID variable with the Field ID of G/l Account.
        Assert.AreEqual(Field."No.", FieldID, StrSubstNo(FieldNoLbl, Field."No."));
        // [THEN] it should update FieldName variable with the Field name of G/l Account.
        Assert.AreEqual(Field.FieldName, FieldName, StrSubstNo(FieldNameLbl, Field.FieldName));
    end;

    [Test]
    [HandlerFunctions('FieldLookupPageHandler')]
    procedure TestOpenFieldLookupOfType()
    var
        Field: Record Field;
        AppObjHelper: Codeunit "App Object Helper";
        FieldName, SearchFieldName : Text[30];
        FieldID: Integer;
    begin
        // [SCENARIO] Pass the Table ID of G/l Account and Search text as first field name found from G/l account table.

        // [GIVEN] There should be a table exist with name G/L Account.
        Field.SetRange(TableNo, Database::"G/L Account");
        Field.SetFilter(Type, '%1|%2|%3|%4', Field.Type::Option, Field.Type::Integer, Field.Type::Decimal, Field.Type::BigInteger);
        Field.FindFirst();

        // [WHEN] The function OpenFieldLookup is called.
        SearchFieldName := Field.FieldName;
        AppObjHelper.OpenFieldLookupOfType(Database::"G/L Account", FieldID, FieldName, SearchFieldName, "Symbol Data Type"::NUMBER);

        // [THEN] it should update FieldID variable with the Field ID of G/l Account.
        Assert.AreEqual(Field."No.", Field."No.", StrSubstNo(FieldNoLbl, Field."No."));
        // [THEN] it should update FieldName variable with the Field name of G/l Account.
        Assert.AreEqual(Field.FieldName, FieldName, StrSubstNo(FieldNameLbl, Field.FieldName));
    end;

    [Test]
    [HandlerFunctions('AllObjPageHandler')]
    procedure TestOpenObjectLookup()
    var
        AllObj: Record AllObj;
        AppObjHelper: Codeunit "App Object Helper";
        SearchObjectName, ObjectName : Text[30];
        ObjectID: Integer;
    begin
        // [SCENARIO] Pass the type of object as table and Name as table name of G/l Account table.

        // [GIVEN] There should be a table exist with name G/L Account.
        AllObj.Get(AllObj."Object Type"::Table, Database::"G/L Account");

        // [WHEN] The function OpenObjectLookup is called.
        ObjectID := AllObj."Object ID";
        AppObjHelper.OpenObjectLookup(ObjectType::Table, SearchObjectName, ObjectID, ObjectName);

        // [THEN] it should update ObjectID variable with the Table ID of G/l Account.
        Assert.AreEqual(AllObj."Object Name", ObjectName, StrSubstNo(ObjectNameLbl, AllObj."Object Name"));
        // [THEN] it should update ObjectName variable with the Table name of G/l Account.
        Assert.AreEqual(AllObj."Object ID", ObjectID, StrSubstNo(ObjectIDLbl, AllObj."Object ID"));
    end;

    [ModalPageHandler]
    procedure FieldLookupPageHandler(var FieldLookup: TestPage "Field Lookup")
    begin
        FieldLookup.First();
        FieldLookup.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure AllObjPageHandler(var AllObjList: TestPage "All Objects")
    begin
        AllObjList.OK().Invoke();
    end;
}