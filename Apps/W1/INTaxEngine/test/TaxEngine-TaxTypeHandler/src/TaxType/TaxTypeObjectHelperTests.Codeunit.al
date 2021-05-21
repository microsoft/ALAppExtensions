codeunit 136801 "Tax Type Object Helper Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    trigger OnRun()
    begin
        // [FEATURE] [TaxEngine] [Tax Type Object Helper] [UT]
    end;

    var
        Assert: Codeunit Assert;

    [Test]
    procedure TestSearchTaxTypeTableByID()
    var
        TaxTypeObjectHelper: Codeunit "Tax Type Object Helper";
        LibraryTaxTypeTests: Codeunit "Library - Tax Type Tests";
        TableID: Integer;
        TableName: Text[30];
    begin
        // [SCENARIO] To check function is returning the correct table name from tax entitiy table.

        // [GIVEN] There should be a record in tax entity table
        LibraryTaxTypeTests.CreateTaxType('VAT', 'VAT');
        LibraryTaxTypeTests.CreateTaxEntntiy('VAT', Database::Customer, 'Customer', false);

        // [WHEN] The function SearchTaxTypeTable is called by using table id
        TableName := '18';
        TaxTypeObjectHelper.SearchTaxTypeTable(TableID, TableName, 'VAT', false);

        // [THEN] Table ID should be udpated with 18 and table name should be updated with Customer
        Assert.AreEqual(Database::Customer, TableID, 'Table ID should be 18');
        Assert.AreEqual('Customer', TableName, 'Table Name should be Customer');
    end;

    [Test]
    procedure TestSearchTaxTypeTableByName()
    var
        TaxTypeObjectHelper: Codeunit "Tax Type Object Helper";
        LibraryTaxTypeTests: Codeunit "Library - Tax Type Tests";
        TableID: Integer;
        TableName: Text[30];
    begin
        // [SCENARIO] To check function is returning the correct table name from tax entitiy table.

        // [GIVEN] There should be a record in tax entity table
        LibraryTaxTypeTests.CreateTaxType('VAT', 'VAT');
        LibraryTaxTypeTests.CreateTaxEntntiy('VAT', Database::Customer, 'Customer', false);

        // [WHEN] The function SearchTaxTypeTable is called by using table name
        TableName := 'Customer';
        TaxTypeObjectHelper.SearchTaxTypeTable(TableID, TableName, 'VAT', false);

        // [THEN] Table ID should be udpated with 18 and table name should be updated with Customer
        Assert.AreEqual(Database::Customer, TableID, 'Table ID should be 18');
        Assert.AreEqual('Customer', TableName, 'Table Name should be Customer');
    end;

    [Test]
    procedure TestSearchTaxTypeTableByNameForTransaction()
    var
        TaxTypeObjectHelper: Codeunit "Tax Type Object Helper";
        LibraryTaxTypeTests: Codeunit "Library - Tax Type Tests";
        TableID: Integer;
        TableName: Text[30];
    begin
        // [SCENARIO] To check function is returning the correct table name from tax entitiy table.

        // [GIVEN] There should be a record in tax entity table
        LibraryTaxTypeTests.CreateTaxType('VAT', 'VAT');
        LibraryTaxTypeTests.CreateTaxEntntiy('VAT', Database::"Sales Line", 'Sales Line', false);

        // [WHEN] The function SearchTaxTypeTable is called by using table name
        TableName := 'Sales Line';
        TaxTypeObjectHelper.SearchTaxTypeTable(TableID, TableName, 'VAT', false);

        // [THEN] Table ID should be udpated with 18 and table name should be updated with Customer
        Assert.AreEqual(Database::"Sales Line", TableID, 'Table ID should be 37');
        Assert.AreEqual('Sales Line', TableName, 'Table Name should be Customer');
    end;

    [Test]
    procedure TestSearchTaxTypeTableByNameForError()
    var
        TaxTypeObjectHelper: Codeunit "Tax Type Object Helper";
        LibraryTaxTypeTests: Codeunit "Library - Tax Type Tests";
        TableID: Integer;
        TableName: Text[30];
        InvalidTableNoErr: Label 'You cannot enter ''%1'' in TableNo.', Comment = '%1, Table No. or Table Name';
    begin
        // [SCENARIO] To check function is throwing error is invalid table name passed for a tax entitiy table.

        // [GIVEN] There should be a record in tax entity table
        LibraryTaxTypeTests.CreateTaxType('VAT', 'VAT');
        LibraryTaxTypeTests.CreateTaxEntntiy('VAT', Database::"Sales Line", 'Sales Line', false);

        // [WHEN] The function SearchTaxTypeTable is called by using table name
        TableName := 'Sales Linex';
        asserterror TaxTypeObjectHelper.SearchTaxTypeTable(TableID, TableName, 'VAT', false);

        // [THEN] function should throw an error
        Assert.AreEqual(StrSubstNo(InvalidTableNoErr, TableName), GetLastErrorText, 'worng error message');
    end;

    [Test]
    procedure TestSearchTaxOptionAttribute()
    var
        SalesHeader: Record "Sales Header";
        TaxTypeObjectHelper: Codeunit "Tax Type Object Helper";
        LibraryTaxTypeTests: Codeunit "Library - Tax Type Tests";
        Type: Option Option,Text,Integer,Decimal,Boolean,Date;
        AttributeID: Integer;
        AttributOption: Text[80];
    begin
        // [SCENARIO] To check if function is returns the attribute option value.

        // [GIVEN] There should be a tax attribute create with type as option
        LibraryTaxTypeTests.CreateTaxType('VAT', 'VAT');
        AttributeID := LibraryTaxTypeTests.CreateTaxAttribute('VAT', 'OrderStatus', Type::Option, Database::"Sales Header", SalesHeader.FieldNo(Status), 0, false);

        // [WHEN] The function SearchTaxOptionAttribute is called by passing option text
        AttributOption := 'Released';
        TaxTypeObjectHelper.SearchTaxOptionAttribute('VAT', AttributeID, AttributOption);

        // [THEN] it should return the same in the variable.
        Assert.AreEqual('Released', AttributOption, 'AttributeOption should be released');
    end;

    [Test]
    procedure TestSearchTaxOptionAttributeForError()
    var
        SalesHeader: Record "Sales Header";
        TaxTypeObjectHelper: Codeunit "Tax Type Object Helper";
        LibraryTaxTypeTests: Codeunit "Library - Tax Type Tests";
        Type: Option Option,Text,Integer,Decimal,Boolean,Date;
        AttributeID: Integer;
        AttributOption: Text[80];
        InvalidAttributeValueErr: Label 'You cannot enter ''%1'' in Attribute Value.', Comment = '%1 = Attribute Value';
    begin
        // [SCENARIO] To check function is throwing error is invalid option value is passed

        // [GIVEN] There should be a record in tax Attribute with type option
        LibraryTaxTypeTests.CreateTaxType('VAT', 'VAT');
        AttributeID := LibraryTaxTypeTests.CreateTaxAttribute('VAT', 'OrderStatus', Type::Option, Database::"Sales Header", SalesHeader.FieldNo(Status), 0, false);

        // [WHEN] The function SearchTaxOptionAttribute is called by using invalid option text
        AttributOption := 'Releasedx';
        asserterror TaxTypeObjectHelper.SearchTaxOptionAttribute('VAT', AttributeID, AttributOption);

        // [THEN] function should throw an error
        Assert.AreEqual(GetLastErrorText, StrSubstNo(InvalidAttributeValueErr, AttributOption), 'invalid error message');
    end;

    [Test]
    [HandlerFunctions('TaxEntitiesPageHandler')]
    procedure TestOpenTaxTypeTableLookupByName()
    var
        TaxTypeObjectHelper: Codeunit "Tax Type Object Helper";
        LibraryTaxTypeTests: Codeunit "Library - Tax Type Tests";
        TableID: Integer;
        TableName, SearchText : Text[30];
    begin
        // [SCENARIO] To check function is opening the lookup page of Tax entities page and returns the correct table name.

        // [GIVEN] There should be a record in tax entity table
        LibraryTaxTypeTests.CreateTaxType('VAT', 'VAT');
        LibraryTaxTypeTests.CreateTaxEntntiy('VAT', Database::Customer, 'Customer', false);

        // [WHEN] The function OpenTaxTypeTableLookup is called
        SearchText := 'Customer';
        TaxTypeObjectHelper.OpenTaxTypeTableLookup(TableID, TableName, SearchText, 'VAT');

        // [THEN] TableID and TableName should be updated with Customer table name and Id
        Assert.AreEqual(Database::Customer, TableID, 'Table ID should be 18');
        Assert.AreEqual('Customer', TableName, 'Table Name should be Customer');
    end;

    [Test]
    [HandlerFunctions('TaxEntitiesPageHandler')]
    procedure TestOpenTaxTypeTableLookupByID()
    var
        TaxTypeObjectHelper: Codeunit "Tax Type Object Helper";
        LibraryTaxTypeTests: Codeunit "Library - Tax Type Tests";
        TableID: Integer;
        TableName, SearchText : Text[30];
    begin
        // [SCENARIO] To check function is opening the lookup page of Tax entities page and returns the correct table name.

        // [GIVEN] There should be a record in tax entity table
        LibraryTaxTypeTests.CreateTaxType('VAT', 'VAT');
        LibraryTaxTypeTests.CreateTaxEntntiy('VAT', Database::Customer, 'Customer', false);

        // [WHEN] The function OpenTaxTypeTableLookup is called
        SearchText := '18';
        TaxTypeObjectHelper.OpenTaxTypeTableLookup(TableID, TableName, SearchText, 'VAT');

        // [THEN] TableID and TableName should be updated with Customer table name and Id
        Assert.AreEqual(Database::Customer, TableID, 'Table ID should be 18');
        Assert.AreEqual('Customer', TableName, 'Table Name should be Customer');
    end;

    [Test]
    [HandlerFunctions('TaxEntitiesPageHandler')]
    procedure TestOpenTaxTypeTransactionTableLookupByID()
    var
        TaxTypeObjectHelper: Codeunit "Tax Type Object Helper";
        LibraryTaxTypeTests: Codeunit "Library - Tax Type Tests";
        TableID: Integer;
        TableName, SearchText : Text[30];
    begin
        // [SCENARIO] To check function is opening the lookup page of Tax entities page and returns the correct table name.

        // [GIVEN] There should be a record in tax entity table
        LibraryTaxTypeTests.CreateTaxType('VAT', 'VAT');
        LibraryTaxTypeTests.CreateTaxEntntiy('VAT', Database::"Sales Header", 'Sales Header', true);

        // [WHEN] The function OpenTaxTypeTransactionTableLookup is called
        SearchText := '36';
        TaxTypeObjectHelper.OpenTaxTypeTransactionTableLookup(TableID, TableName, SearchText, 'VAT');

        // [THEN] TableID and TableName should be updated with Customer table name and Id
        Assert.AreEqual(Database::"Sales Header", TableID, 'Table ID should be 36');
        Assert.AreEqual('Sales Header', TableName, 'Table Name should be Sales Header');
    end;

    [Test]
    [HandlerFunctions('TaxEntitiesPageHandler')]
    procedure TestOpenTaxTypeTransactionTableLookupByName()
    var
        TaxTypeObjectHelper: Codeunit "Tax Type Object Helper";
        LibraryTaxTypeTests: Codeunit "Library - Tax Type Tests";
        TableID: Integer;
        TableName, SearchText : Text[30];
    begin
        // [SCENARIO] To check function is opening the lookup page of Tax entities page and returns the correct table name.

        // [GIVEN] There should be a record in tax entity table
        LibraryTaxTypeTests.CreateTaxType('VAT', 'VAT');
        LibraryTaxTypeTests.CreateTaxEntntiy('VAT', Database::"Sales Header", 'Sales Header', true);

        // [WHEN] The function OpenTaxTypeTransactionTableLookup is called
        SearchText := 'Salses Header';
        TaxTypeObjectHelper.OpenTaxTypeTransactionTableLookup(TableID, TableName, SearchText, 'VAT');

        // [THEN] TableID and TableName should be updated with Customer table name and Id
        Assert.AreEqual(Database::"Sales Header", TableID, 'Table ID should be 36');
        Assert.AreEqual('Sales Header', TableName, 'Table Name should be Sales Header');
    end;

    [Test]
    procedure TestEnableSelectedTaxTypes()
    var
        TaxType: Record "Tax Type";
        TaxTypeObjHelper: Codeunit "Tax Type Object Helper";
        LibraryTaxTypeTests: Codeunit "Library - Tax Type Tests";
    begin
        // [SCENARIO] To check if all tax types are enabled when EnableSelectedTaxTypes function is called

        // [GIVEN] There should be a tax type
        LibraryTaxTypeTests.CreateTaxType('VAT', 'Value added tax');

        // [WHEN] function EnableSelectedTaxTypes is called 
        TaxTypeObjHelper.EnableSelectedTaxTypes(TaxType);

        // [THEN] no record should exist with disabled tax type
        TaxType.Reset();
        TaxType.SetRange(Enabled, false);
        Assert.RecordIsEmpty(TaxType);
    end;

    [Test]
    procedure TestDisableSelectedTaxTypes()
    var
        TaxType: Record "Tax Type";
        TaxTypeObjHelper: Codeunit "Tax Type Object Helper";
        LibraryTaxTypeTests: Codeunit "Library - Tax Type Tests";
    begin
        // [SCENARIO] To check if all tax types are disabled when DisableSelectedTaxTypes function is called

        // [GIVEN] There should be a tax type with enable as true
        LibraryTaxTypeTests.CreateTaxType('VAT', 'Value added tax');
        TaxTypeObjHelper.EnableSelectedTaxTypes(TaxType);

        // [WHEN] function DisableSelectedTaxTypes is called 
        TaxType.Reset();
        TaxTypeObjHelper.DisableSelectedTaxTypes(TaxType);

        // [THEN] no record should exist with enabled tax type
        TaxType.Reset();
        TaxType.SetRange(Enabled, true);
        Assert.RecordIsEmpty(TaxType);
    end;

    [ModalPageHandler]
    procedure TaxEntitiesPageHandler(var TaxEntities: TestPage "Tax Entities")
    begin
        TaxEntities.OK().Invoke();
    end;
}