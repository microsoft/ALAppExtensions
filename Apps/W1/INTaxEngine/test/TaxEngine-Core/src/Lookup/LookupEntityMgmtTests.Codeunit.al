codeunit 136707 "Lookup Entity Mgmt Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;
    trigger OnRun()
    begin
        // [FEATURE] [TaxEngine] [Lookup Entity Mgmt] [UT]
    end;

    var
        Assert: Codeunit Assert;

    [Test]
    procedure TestCreateTableSorting()
    var
        LookupTableSorting: Record "Lookup Table Sorting";
        LookupEntityMgmt: Codeunit "Lookup Entity Mgmt.";
        CaseID, ScriptID, TableSortingID : Guid;
    begin
        // [SCENARIO] To check if the Table Sorting is created for G/l Account table.

        // [GIVEN] There should be a table exist with the name of G/L Account.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        // [WHEN] The function CreateTableSorting is called.
        TableSortingID := LookupEntityMgmt.CreateTableSorting(CaseID, ScriptID, Database::"G/L Account");

        // [THEN] it should open create record in Lookup Table Sorting table for CaseID and ScriptID.
        LookupTableSorting.SetRange("Case ID", CaseID);
        LookupTableSorting.SetRange("Script ID", ScriptID);
        LookupTableSorting.SetRange("ID", TableSortingID);
        LookupTableSorting.SetRange("Table ID", Database::"G/L Account");

        Assert.RecordIsNotEmpty(LookupTableSorting);
    end;

    [Test]
    procedure TestDeleteTableSorting()
    var
        LookupTableSorting: Record "Lookup Table Sorting";
        LookupEntityMgmt: Codeunit "Lookup Entity Mgmt.";
        CaseID, ScriptID, TableSortingID : Guid;
    begin
        // [SCENARIO] To check if the Table Sorting is Deleted for G/l Account table.

        // [GIVEN] There should be a table exist with the name of G/L Account.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        TableSortingID := LookupEntityMgmt.CreateTableSorting(CaseID, ScriptID, Database::"G/L Account");

        // [WHEN] The function DeleteTableSorting is called.
        LookupEntityMgmt.DeleteTableSorting(CaseID, ScriptID, TableSortingID);

        // [THEN] it should delete the record in Lookup Table Sorting table for CaseID and ScriptID.
        LookupTableSorting.SetRange("Case ID", CaseID);
        LookupTableSorting.SetRange("Script ID", ScriptID);
        LookupTableSorting.SetRange("ID", TableSortingID);
        LookupTableSorting.SetRange("Table ID", Database::"G/L Account");

        Assert.RecordIsEmpty(LookupTableSorting);
    end;

    [Test]
    procedure TestDeleteTableSortingWithEmptyGuid()
    var
        LookupTableSorting: Record "Lookup Table Sorting";
        LookupEntityMgmt: Codeunit "Lookup Entity Mgmt.";
        CaseID: Guid;
        ScriptID: Guid;
        TableSortingID: Guid;
        EmptyGuid: Guid;
    begin
        // [SCENARIO] To check if the Table Sorting is not Deleted for if ID if blank.

        // [GIVEN] TableSortingID should be blank.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        TableSortingID := LookupEntityMgmt.CreateTableSorting(CaseID, ScriptID, Database::"G/L Account");

        // [WHEN] The function DeleteTableSorting is called.
        LookupEntityMgmt.DeleteTableSorting(CaseID, ScriptID, EmptyGuid);

        // [THEN] it should not delete the record in Lookup Table Sorting table for CaseID and ScriptID.
        LookupTableSorting.SetRange("Case ID", CaseID);
        LookupTableSorting.SetRange("Script ID", ScriptID);
        LookupTableSorting.SetRange("ID", TableSortingID);
        LookupTableSorting.SetRange("Table ID", Database::"G/L Account");

        Assert.RecordIsNotEmpty(LookupTableSorting);
    end;

    [Test]
    procedure TestCreateTableFilters()
    var
        LookupTableFilter: Record "Lookup Table Filter";
        LookupEntityMgmt: Codeunit "Lookup Entity Mgmt.";
        CaseID: Guid;
        ScriptID: Guid;
        TableFilterID: Guid;
    begin
        // [SCENARIO] To check if the Table Filter is created for G/l Account table.

        // [GIVEN] There should be a table exist with the name of G/L Account.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        // [WHEN] The function CreateTableFilters is called.
        TableFilterID := LookupEntityMgmt.CreateTableFilters(CaseID, ScriptID, Database::"G/L Account");

        // [THEN] it should create record in Lookup Table Filter table for CaseID and ScriptID.
        LookupTableFilter.SetRange("Case ID", CaseID);
        LookupTableFilter.SetRange("Script ID", ScriptID);
        LookupTableFilter.SetRange("ID", TableFilterID);
        LookupTableFilter.SetRange("Table ID", Database::"G/L Account");

        Assert.RecordIsNotEmpty(LookupTableFilter);
    end;

    [Test]
    procedure TestDeleteTableFilters()
    var
        LookupTableFilter: Record "Lookup Table Filter";
        LookupEntityMgmt: Codeunit "Lookup Entity Mgmt.";
        CaseID, ScriptID, TableFilterID : Guid;
    begin
        // [SCENARIO] To check if the Table Filters are Deleted for G/l Account table.

        // [GIVEN] There should be a table exist with the name of G/L Account.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        TableFilterID := LookupEntityMgmt.CreateTableFilters(CaseID, ScriptID, Database::"G/L Account");

        // [WHEN] The function DeleteTableFilters is called.
        LookupEntityMgmt.DeleteTableFilters(CaseID, ScriptID, TableFilterID);

        // [THEN] it should delete the record in Lookup Table Filters table for CaseID and ScriptID.
        LookupTableFilter.SetRange("Case ID", CaseID);
        LookupTableFilter.SetRange("Script ID", ScriptID);
        LookupTableFilter.SetRange("ID", TableFilterID);
        LookupTableFilter.SetRange("Table ID", Database::"G/L Account");

        Assert.RecordIsEmpty(LookupTableFilter);
    end;

    [Test]
    procedure TestDeleteTableFilterWithEmptyGuid()
    var
        LookupTableFilter: Record "Lookup Table Filter";
        LookupEntityMgmt: Codeunit "Lookup Entity Mgmt.";
        CaseID, ScriptID, TableFilterID, EmptyGuid : Guid;
    begin
        // [SCENARIO] To check if the Table Filter is not Deleted for if ID if blank.

        // [GIVEN] TableFilterID should be blank.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        TableFilterID := LookupEntityMgmt.CreateTableFilters(CaseID, ScriptID, Database::"G/L Account");

        // [WHEN] The function DeleteTableFilters is called.
        LookupEntityMgmt.DeleteTableFilters(CaseID, ScriptID, EmptyGuid);

        // [THEN] it should not delete the record in Lookup Table Filter table for CaseID and ScriptID.
        LookupTableFilter.SetRange("Case ID", CaseID);
        LookupTableFilter.SetRange("Script ID", ScriptID);
        LookupTableFilter.SetRange("ID", TableFilterID);
        LookupTableFilter.SetRange("Table ID", Database::"G/L Account");

        Assert.RecordIsNotEmpty(LookupTableFilter);
    end;

    [Test]
    procedure TestCreateLookup()
    var
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        LookupEntityMgmt: Codeunit "Lookup Entity Mgmt.";
        CaseID: Guid;
        ScriptID: Guid;
        LookupID: Guid;
    begin
        // [SCENARIO] To check if the Table Lookup is created.

        // [GIVEN] There should be a CaseID and ScriptID .
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        // [WHEN] The function CreateLookup is called.
        LookupID := LookupEntityMgmt.CreateLookup(CaseID, ScriptID);

        // [THEN] it should create record in Lookup Table for CaseID and ScriptID.
        ScriptSymbolLookup.SetRange("Case ID", CaseID);
        ScriptSymbolLookup.SetRange("Script ID", ScriptID);
        ScriptSymbolLookup.SetRange("ID", LookupID);

        Assert.RecordIsNotEmpty(ScriptSymbolLookup);
    end;

    [Test]
    procedure TestDeleteLookup()
    var
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        LookupEntityMgmt: Codeunit "Lookup Entity Mgmt.";
        CaseID: Guid;
        ScriptID: Guid;
        LookupID: Guid;
    begin
        // [SCENARIO] To check if the Symbol Lookup are Deleted.

        // [GIVEN] There should be a CaseID and ScriptID .
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        LookupID := LookupEntityMgmt.CreateLookup(CaseID, ScriptID);

        // [WHEN] The function DeleteLookup is called.
        LookupEntityMgmt.DeleteLookup(CaseID, ScriptID, LookupID);

        // [THEN] it should delete the record in Lookup Table for CaseID and ScriptID.
        ScriptSymbolLookup.SetRange("Case ID", CaseID);
        ScriptSymbolLookup.SetRange("Script ID", ScriptID);
        ScriptSymbolLookup.SetRange("ID", LookupID);

        Assert.RecordIsEmpty(ScriptSymbolLookup);
    end;

    [Test]
    procedure TestDeleteTableLookupWithEmptyGuid()
    var
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        LookupEntityMgmt: Codeunit "Lookup Entity Mgmt.";
        CaseID, ScriptID, LookupID, EmptyGuid : Guid;
    begin
        // [SCENARIO] To check if the Table Lookup is not Deleted for if ID if blank.

        // [GIVEN] TableFilterID should be blank.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        LookupID := LookupEntityMgmt.CreateLookup(CaseID, ScriptID);

        // [WHEN] The function DeleteLookup is called.
        LookupEntityMgmt.DeleteLookup(CaseID, ScriptID, EmptyGuid);

        // [THEN] it should not delete the record in Table Lookup table for CaseID and ScriptID.
        ScriptSymbolLookup.SetRange("Case ID", CaseID);
        ScriptSymbolLookup.SetRange("Script ID", ScriptID);
        ScriptSymbolLookup.SetRange("ID", LookupID);

        Assert.RecordIsNotEmpty(ScriptSymbolLookup);
    end;
}