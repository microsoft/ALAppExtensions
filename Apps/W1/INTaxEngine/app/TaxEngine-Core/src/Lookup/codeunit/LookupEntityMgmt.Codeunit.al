codeunit 20141 "Lookup Entity Mgmt."
{
    procedure CreateTableSorting(CaseID: Guid; ScriptID: Guid; TableID: Integer): Guid;
    var
        LookupTableSorting: Record "Lookup Table Sorting";
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed(CaseID);

        LookupTableSorting.Init();
        LookupTableSorting."Case ID" := CaseID;
        LookupTableSorting."Script ID" := ScriptID;
        LookupTableSorting.ID := CreateGuid();
        LookupTableSorting."Table ID" := TableID;
        LookupTableSorting.Insert(true);
        Commit();
        exit(LookupTableSorting.ID);
    end;

    procedure DeleteTableSorting(CaseID: Guid; ScriptID: Guid; var ID: Guid): Guid;
    var
        LookupTableSorting: Record "Lookup Table Sorting";
    begin
        if IsNullGuid(ID) then
            Exit;

        LookupTableSorting.GET(CaseID, ScriptID, ID);
        LookupTableSorting.Delete(true);

        ID := EmptyGuid;
    end;

    /// Table Filters
    procedure CreateTableFilters(CaseID: Guid; ScriptID: Guid; TableID: Integer): Guid;
    var
        LookupTableFilter: Record "Lookup Table Filter";
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed(CaseID);

        LookupTableFilter.Init();
        LookupTableFilter."Case ID" := CaseID;
        LookupTableFilter."Script ID" := ScriptID;
        LookupTableFilter.ID := CreateGuid();
        LookupTableFilter."Table ID" := TableID;
        LookupTableFilter.Insert(true);
        Commit();
        exit(LookupTableFilter.ID);
    end;

    procedure DeleteTableFilters(CaseID: Guid; ScriptID: Guid; var ID: Guid): Guid;
    var
        LookupTableFilter: Record "Lookup Table Filter";
    begin
        if IsNullGuid(ID) then
            Exit;

        LookupTableFilter.GET(CaseID, ScriptID, ID);
        LookupTableFilter.Delete(true);

        ID := EmptyGuid;
    end;

    /// Lookup Functions
    procedure CreateLookup(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed(CaseID);

        ScriptSymbolLookup.Init();
        ScriptSymbolLookup."Case ID" := CaseID;
        ScriptSymbolLookup."Script ID" := ScriptID;
        ScriptSymbolLookup.ID := CreateGuid();
        ScriptSymbolLookup."Source Type" := ScriptSymbolLookup."Source Type"::Database;
        ScriptSymbolLookup.Insert(true);
        exit(ScriptSymbolLookup.ID);
    end;

    procedure DeleteLookup(CaseID: Guid; ScriptID: Guid; var ID: Guid);
    var
        ScriptSymbolLookup: Record "Script Symbol Lookup";
    begin
        if IsNullGuid(ID) then
            Exit;

        ScriptSymbolLookup.Get(CaseID, ScriptID, ID);
        ScriptSymbolLookup.Delete(true);

        ID := EmptyGuid;
    end;

    var
        EmptyGuid: Guid;
}