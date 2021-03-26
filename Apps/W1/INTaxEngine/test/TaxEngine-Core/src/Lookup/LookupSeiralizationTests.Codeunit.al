codeunit 136709 "Lookup Seiralization Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;
    trigger OnRun()
    begin
        // [FEATURE] [TaxEngine] [Lookup Serialization] [UT]
    end;

    var
        Assert: Codeunit Assert;
        LookupTextLbl: Label 'Lookup Text should be %1', Comment = '%1 = Lookup Text';
        SortingTextLbl: Label 'Sorting Text should be %1', Comment = '%1 = Sorting Text';
        FieldFromTableLbl: Label '%1 from %2 %3', Comment = '%1 - Field Name, %2 - Table Name, %3 - Table Filters';
        FieldFilterLbl: Label '%1 %2 %3', Comment = '%1 - Field Name, %2 - Filter Type, %3 - Filter Value';
        WhereLbl: Label '(where %1)', Comment = '%1 - Table Filters';
        AggregateValueFromTableLbl: Label '%1(%2) from %3 %4', Comment = '%1 - Method Name, %2 - Field Name, %3 - Table Name, %4 - Table Filters,';
        RecordsExistsInTableLbl: Label 'Records exists in %1 %2', Comment = '%1 - Table Name, %2 - Table Filters';

    [Test]
    procedure TestLookupToStringForCurrentRecord()
    var
        SalesLine: Record "Sales Line";
        LookupSerialization: Codeunit "Lookup Serialization";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        CaseID, ScriptID, LookupID : Guid;
        ExpectedText: text[30];
        ActualText: Text;
    begin
        // [SCENARIO] To get the LookupString for Lookup.

        // [GIVEN] There should be a table exist with name Sales Line 
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        LookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, Database::"Sales Line", SalesLine.fieldno(Description), "Symbol Type"::"Current Record");

        // [WHEN] The function LookupToString is called.
        ExpectedText := SalesLine.FieldName(Description);
        BindSubscription(LibraryScriptSymbolLookup);
        ActualText := LookupSerialization.LookupToString(CaseID, ScriptID, LookupID);
        UnBindSubscription(LibraryScriptSymbolLookup);

        // [THEN] if should return the lookup string.
        Assert.AreEqual(ExpectedText, ActualText, StrSubstNo(LookupTextLbl, ExpectedText));
    end;

    [Test]
    procedure TestLookupToStringForDatabase()
    var
        LookupSerialization: Codeunit "Lookup Serialization";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        ScriptID: Guid;
        CaseID, LookupID : Guid;
        ExpectedText: Text;
        ActualText: Text;
    begin
        // [SCENARIO] To get the LookupString for Lookup for source type Database.

        // [GIVEN] There should be a lookup exist with source type database.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        LookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, Database::"Sales Header", "Database Symbol"::UserId.AsInteger(), "Symbol Type"::Database);

        // [WHEN] The function LookupToString is called.
        ExpectedText := 'Database: UserId';
        BindSubscription(LibraryScriptSymbolLookup);
        ActualText := LookupSerialization.LookupToString(CaseID, ScriptID, LookupID);
        UnBindSubscription(LibraryScriptSymbolLookup);

        // [THEN] if should return the lookup string.
        Assert.AreEqual(ExpectedText, ActualText, StrSubstNo(LookupTextLbl, ExpectedText));
    end;

    [Test]
    procedure TestLookupToStringForTable()
    var
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        LookupFieldFilter: Record "Lookup Field Filter";
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        LookupSerialization: Codeunit "Lookup Serialization";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        FieldFromTableTxt, FieldFilterTxt, TableFilterTxt, ExpectedText, ActualText : Text;
        CaseID, ScriptID, LookupID, TableFilterID : Guid;
    begin
        // [SCENARIO] To get the LookupString for Lookup for source type Table.

        // [GIVEN] There should be a table exist with sales line.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        LookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, Database::"Sales Line", SalesLine.fieldno("Document No."), "Symbol Type"::Table);
        TableFilterID := LibraryScriptSymbolLookup.CreateTableFilter(CaseID, ScriptID, Database::"Sales Header", SalesHeader.FieldNo("No."));

        ScriptSymbolLookup.Get(CaseID, ScriptID, LookupID);
        ScriptSymbolLookup."Table Filter ID" := TableFilterID;
        ScriptSymbolLookup.Modify();

        LookupFieldFilter.Get(CaseID, ScriptID, TableFilterID, SalesHeader.FieldNo("No."));
        LookupFieldFilter.Value := '''''';

        FieldFilterTxt := strsubstno(FieldFilterLbl, SalesHeader.FieldName("No."), LookupFieldFilter."Filter Type", LookupFieldFilter.Value);
        TableFilterTxt := FieldFilterTxt;
        TableFilterTxt := StrSubstNo(WhereLbl, TableFilterTxt);
        FieldFromTableTxt := StrSubstNo(FieldFromTableLbl, '"' + SalesLine.FieldName("Document No.") + '"', '"' + SalesLine.TableName + '"', TableFilterTxt);

        ExpectedText := FieldFromTableTxt;

        // [WHEN] The function LookupToString is called.
        BindSubscription(LibraryScriptSymbolLookup);
        ActualText := LookupSerialization.LookupToString(CaseID, ScriptID, LookupID);
        UnBindSubscription(LibraryScriptSymbolLookup);

        // [THEN] if should return the lookup string.
        Assert.AreEqual(ExpectedText, ActualText, StrSubstNo(LookupTextLbl, ExpectedText));
    end;

    [Test]
    procedure TableSortingToStringWithKeyField()
    var
        SalesHeader: Record "Sales Header";
        LookupSerialization: Codeunit "Lookup Serialization";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        CaseID, ScriptID, TableSortingID : Guid;
        ExpectedText, ActualText : Text;
        FieldIDList: List of [Integer];
    begin
        // [SCENARIO] To get the TableSorting string.

        // [GIVEN] There should be a table exist with sales header.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        FieldIDList.Add(SalesHeader.FieldNo("Document Type"));
        FieldIDList.Add(SalesHeader.FieldNo("No."));
        TableSortingID := LibraryScriptSymbolLookup.CreateTableSorting(CaseID, ScriptID, Database::"Sales Header", FieldIDList);

        // [WHEN] The function TableSortingToString is called.
        ExpectedText := '"' + SalesHeader.FieldName("Document Type") + '","' + SalesHeader.FieldName("No.") + '"';
        BindSubscription(LibraryScriptSymbolLookup);
        ActualText := LookupSerialization.TableSortingToString(CaseID, ScriptID, TableSortingID);
        UnBindSubscription(LibraryScriptSymbolLookup);

        // [THEN] if should return the lookup string.
        Assert.AreEqual(ExpectedText, ActualText, StrSubstNo(SortingTextLbl, ExpectedText));
    end;

    [Test]
    procedure TableSortingToStringForPrimaryKey()
    var
        SalesHeader: Record "Sales Header";
        LookupSerialization: Codeunit "Lookup Serialization";
        LookupEntityMgmt: Codeunit "Lookup Entity Mgmt.";
        CaseID, ScriptID, TableSortingID : Guid;
        ExpectedText, ActualText : Text;
        FieldIDList: List of [Integer];
    begin
        // [SCENARIO] To get the TableSorting string as primary key field if no fields are passed.

        // [GIVEN] There should be a table exist with sales header.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        FieldIDList.Add(SalesHeader.FieldNo("Document Type"));
        FieldIDList.Add(SalesHeader.FieldNo("No."));
        TableSortingID := LookupEntityMgmt.CreateTableSorting(CaseID, ScriptID, Database::"Sales Header");

        // [WHEN] The function TableSortingToString is called.
        ExpectedText := '"' + SalesHeader.FieldName("Document Type") + '","' + SalesHeader.FieldName("No.") + '"';
        ActualText := LookupSerialization.TableSortingToString(CaseID, ScriptID, TableSortingID);

        // [THEN] if should return the Sorting string.
        Assert.AreEqual(ExpectedText, ActualText, StrSubstNo(SortingTextLbl, ExpectedText));
    end;

    [Test]
    procedure TestLookupTableToStringForFirst()
    var
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        LookupFieldFilter: Record "Lookup Field Filter";
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        LookupSerialization: Codeunit "Lookup Serialization";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        FieldFromTableTxt, FieldFilterTxt, TableFilterTxt, ExpectedText, ActualText : Text;
        CaseID, ScriptID, LookupID, TableFilterID : Guid;
    begin
        // [SCENARIO] To get the Lookup string for Table method first.

        // [GIVEN] There should be a table exist with sales header.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        LookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, Database::"Sales Line", SalesLine.fieldno("Document No."), "Symbol Type"::Table, ScriptSymbolLookup."Table Method"::First);
        TableFilterID := LibraryScriptSymbolLookup.CreateTableFilter(CaseID, ScriptID, Database::"Sales Header", SalesHeader.FieldNo("No."));

        ScriptSymbolLookup.Get(CaseID, ScriptID, LookupID);
        ScriptSymbolLookup."Table Filter ID" := TableFilterID;
        ScriptSymbolLookup.Modify();

        LookupFieldFilter.Get(CaseID, ScriptID, TableFilterID, SalesHeader.FieldNo("No."));
        LookupFieldFilter.Value := '''''';

        FieldFilterTxt := strsubstno(FieldFilterLbl, SalesHeader.FieldName("No."), LookupFieldFilter."Filter Type", LookupFieldFilter.Value);
        TableFilterTxt := FieldFilterTxt;
        TableFilterTxt := StrSubstNo(WhereLbl, TableFilterTxt);
        FieldFromTableTxt := StrSubstNo(FieldFromTableLbl, '"' + SalesLine.FieldName("Document No.") + '"', '"' + SalesLine.TableName + '"', TableFilterTxt);

        ExpectedText := FieldFromTableTxt;

        // [WHEN] The function LookupToString is called.
        BindSubscription(LibraryScriptSymbolLookup);
        ActualText := LookupSerialization.LookupToString(CaseID, ScriptID, LookupID);
        UnBindSubscription(LibraryScriptSymbolLookup);

        // [THEN] if should return the lookup string.
        Assert.AreEqual(ExpectedText, ActualText, StrSubstNo(LookupTextLbl, ExpectedText));
    end;

    [Test]
    procedure TestLookupTableToStringForAverage()
    var
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        LookupFieldFilter: Record "Lookup Field Filter";
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        LookupSerialization: Codeunit "Lookup Serialization";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        AggregateValueFromTableTxt, FieldFromTableTxt, FieldFilterTxt, TableFilterTxt, ExpectedText, ActualText : Text;
        CaseID, ScriptID, LookupID, TableFilterID : Guid;
    begin
        // [SCENARIO] To get the Lookup string for Table method Average.

        // [GIVEN] There should be a table exist with sales header.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        LookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, Database::"Sales Line", SalesLine.fieldno("Document No."), "Symbol Type"::Table, ScriptSymbolLookup."Table Method"::Average);
        TableFilterID := LibraryScriptSymbolLookup.CreateTableFilter(CaseID, ScriptID, Database::"Sales Header", SalesHeader.FieldNo("No."));

        ScriptSymbolLookup.Get(CaseID, ScriptID, LookupID);
        ScriptSymbolLookup."Table Filter ID" := TableFilterID;
        ScriptSymbolLookup.Modify();

        LookupFieldFilter.Get(CaseID, ScriptID, TableFilterID, SalesHeader.FieldNo("No."));
        LookupFieldFilter.Value := '''''';

        FieldFilterTxt := strsubstno(FieldFilterLbl, SalesHeader.FieldName("No."), LookupFieldFilter."Filter Type", LookupFieldFilter.Value);
        TableFilterTxt := FieldFilterTxt;
        TableFilterTxt := StrSubstNo(WhereLbl, TableFilterTxt);
        FieldFromTableTxt := StrSubstNo(FieldFromTableLbl, '"' + SalesLine.FieldName("Document No.") + '"', '"' + SalesLine.TableName + '"', TableFilterTxt);

        AggregateValueFromTableTxt := StrSubstNo(AggregateValueFromTableLbl, format(ScriptSymbolLookup."Table Method"), '"' + SalesLine.FieldName("Document No.") + '"', '"' + SalesLine.TableName + '"', TableFilterTxt);
        ExpectedText := AggregateValueFromTableTxt;

        // [WHEN] The function LookupToString is called.
        BindSubscription(LibraryScriptSymbolLookup);
        ActualText := LookupSerialization.LookupToString(CaseID, ScriptID, LookupID);
        UnBindSubscription(LibraryScriptSymbolLookup);

        // [THEN] if should return the lookup string.
        Assert.AreEqual(ExpectedText, ActualText, StrSubstNo(LookupTextLbl, ExpectedText));
    end;

    [Test]
    procedure TestLookupTableToStringForCount()
    var
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        LookupFieldFilter: Record "Lookup Field Filter";
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        LookupSerialization: Codeunit "Lookup Serialization";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        RecordsExistsInTableTxt, FieldFromTableTxt, TableFilterTxt, FieldFilterTxt, ExpectedText, ActualText : Text;
        CaseID, ScriptID, LookupID, TableFilterID : Guid;
    begin
        // [SCENARIO] To get the Lookup string for Table method Count.

        // [GIVEN] There should be a table exist with sales header.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        LookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, Database::"Sales Line", SalesLine.fieldno("Document No."), "Symbol Type"::Table, ScriptSymbolLookup."Table Method"::Exist);
        TableFilterID := LibraryScriptSymbolLookup.CreateTableFilter(CaseID, ScriptID, Database::"Sales Header", SalesHeader.FieldNo("No."));

        ScriptSymbolLookup.Get(CaseID, ScriptID, LookupID);
        ScriptSymbolLookup."Table Filter ID" := TableFilterID;
        ScriptSymbolLookup.Modify();

        LookupFieldFilter.Get(CaseID, ScriptID, TableFilterID, SalesHeader.FieldNo("No."));
        LookupFieldFilter.Value := '''''';

        FieldFilterTxt := strsubstno(FieldFilterLbl, SalesHeader.FieldName("No."), LookupFieldFilter."Filter Type", LookupFieldFilter.Value);
        TableFilterTxt := FieldFilterTxt;
        TableFilterTxt := StrSubstNo(WhereLbl, TableFilterTxt);
        FieldFromTableTxt := StrSubstNo(FieldFromTableLbl, '"' + SalesLine.FieldName("Document No.") + '"', '"' + SalesLine.TableName + '"', TableFilterTxt);
        RecordsExistsInTableTxt := StrSubstNo(RecordsExistsInTableLbl, '"' + SalesLine.TableName + '"', TableFilterTxt);
        ExpectedText := RecordsExistsInTableTxt;

        // [WHEN] The function LookupToString is called.
        BindSubscription(LibraryScriptSymbolLookup);
        ActualText := LookupSerialization.LookupToString(CaseID, ScriptID, LookupID);
        UnBindSubscription(LibraryScriptSymbolLookup);

        // [THEN] if should return the lookup string.
        Assert.AreEqual(ExpectedText, ActualText, StrSubstNo(LookupTextLbl, ExpectedText));
    end;

    [Test]
    procedure TestLookupTableToStringForExist()
    var
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        LookupFieldFilter: Record "Lookup Field Filter";
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        LookupSerialization: Codeunit "Lookup Serialization";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        RecordsExistsInTableTxt, FieldFromTableTxt, FieldFilterTxt, TableFilterTxt, ExpectedText, ActualText : Text;
        CaseID, ScriptID, LookupID, TableFilterID : Guid;
    begin
        // [SCENARIO] To get the Lookup string for Table method Exist.

        // [GIVEN] There should be a table exist with sales header.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        LookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, Database::"Sales Line", SalesLine.fieldno("Document No."), "Symbol Type"::Table, ScriptSymbolLookup."Table Method"::Exist);
        TableFilterID := LibraryScriptSymbolLookup.CreateTableFilter(CaseID, ScriptID, Database::"Sales Header", SalesHeader.FieldNo("No."));

        ScriptSymbolLookup.Get(CaseID, ScriptID, LookupID);
        ScriptSymbolLookup."Table Filter ID" := TableFilterID;
        ScriptSymbolLookup.Modify();

        LookupFieldFilter.Get(CaseID, ScriptID, TableFilterID, SalesHeader.FieldNo("No."));
        LookupFieldFilter.Value := '''''';

        FieldFilterTxt := strsubstno(FieldFilterLbl, SalesHeader.FieldName("No."), LookupFieldFilter."Filter Type", LookupFieldFilter.Value);
        TableFilterTxt := FieldFilterTxt;
        TableFilterTxt := StrSubstNo(WhereLbl, TableFilterTxt);
        FieldFromTableTxt := StrSubstNo(FieldFromTableLbl, '"' + SalesLine.FieldName("Document No.") + '"', '"' + SalesLine.TableName + '"', TableFilterTxt);
        RecordsExistsInTableTxt := StrSubstNo(RecordsExistsInTableLbl, '"' + SalesLine.TableName + '"', TableFilterTxt);
        ExpectedText := RecordsExistsInTableTxt;

        // [WHEN] The function LookupToString is called.
        BindSubscription(LibraryScriptSymbolLookup);
        ActualText := LookupSerialization.LookupToString(CaseID, ScriptID, LookupID);
        UnBindSubscription(LibraryScriptSymbolLookup);

        // [THEN] if should return the lookup string.
        Assert.AreEqual(ExpectedText, ActualText, StrSubstNo(LookupTextLbl, ExpectedText));
    end;
}