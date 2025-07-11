codeunit 136704 "Script Symbols Store Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    trigger OnRun()
    begin
        // [FEATURE] [TaxEngine] [Symbols Store] [UT]
    end;

    var
        Assert: Codeunit Assert;

    [Test]
    procedure TestInitSymbols()
    var
        TempSymbols: Record "Script Symbol Value" temporary;
        ScriptSymbolStore: Codeunit "Script Symbol Store";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        CaseID: Guid;
        ScriptID: Guid;
    begin
        // [SCENARIO] Initilize Symbols with System Type from 5000 to 5009 

        // [GIVEN] Case ID, Script ID, Symbol Default Values
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        // [WHEN] The function InitSymbols is called.
        BindSubscription(LibraryScriptSymbolLookup);
        ScriptSymbolStore.InitSymbols(CaseID, ScriptID, TempSymbols);
        UnbindSubscription(LibraryScriptSymbolLookup);
        ScriptSymbolStore.CopySymbols(TempSymbols);

        // [THEN] It should create symbols in store from 5000 to 5009.
        TempSymbols.SetRange("Symbol ID", 5000, 5009);
        TempSymbols.SetRange(Type, TempSymbols.Type::System);
        Assert.RecordCount(TempSymbols, 10);
    end;

    [Test]
    procedure TestInitSymbolsWithTaxType()
    var
        TempSymbols: Record "Script Symbol Value" temporary;
        ScriptSymbolStore: Codeunit "Script Symbol Store";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        CaseID: Guid;
        ScriptID: Guid;
    begin
        // [SCENARIO] Initilize Symbols with System Type from 5000 to 5009 

        // [GIVEN] Case ID, Script ID, Symbol Default Values
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        // [WHEN] The function InitSymbols is called.
        BindSubscription(LibraryScriptSymbolLookup);
        ScriptSymbolStore.InitSymbolContext('VAT', CaseID);
        ScriptSymbolStore.InsertSymbolValue("Symbol Type"::System, "Symbol Data Type"::String, 5000, 'TEST SYMBOL');
        UnbindSubscription(LibraryScriptSymbolLookup);
        ScriptSymbolStore.CopySymbols(TempSymbols);

        // [THEN] It should create symbols in store from 5000 to 5009.
        TempSymbols.SetRange("Symbol ID", 5000, 5009);
        TempSymbols.SetRange(Type, TempSymbols.Type::System);
        Assert.RecordIsNotEmpty(TempSymbols);
    end;

    [Test]
    procedure TestInsertSymbolValue()
    var
        TempSymbols: Record "Script Symbol Value" temporary;
        ScriptSymbolStore: Codeunit "Script Symbol Store";
        SymbolID: Integer;
        SymbolValue: Text;
        SymbolValueRetrieved: Variant;
    begin
        // [SCENARIO] Insert a new System Symbol - 50000 with a Value into Symbol Store

        // [GIVEN] Symbol Type - System, Data Type - STRING, Symbol ID - 50000, Value - Hello
        SymbolID := 50000;
        SymbolValue := 'Hello';

        // [WHEN] The function InsertSymbolValue is called.
        ScriptSymbolStore.InsertSymbolValue(
            "Symbol Type"::System,
            "Symbol Data Type"::STRING,
            SymbolID,
            SymbolValue);

        ScriptSymbolStore.CopySymbols(TempSymbols);
        TempSymbols.FindFirst();
        ScriptSymbolStore.GetSymbolValue(TempSymbols, SymbolValueRetrieved);

        // [THEN] It should create a new Symbol in Store 
        Assert.AreEqual(SymbolValue, SymbolValueRetrieved, 'Symbol Value Hello expected.');
    end;

    [Test]
    procedure TestInsertDictionaryValue()
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";

        SymbolID: Integer;
        MemberID: Integer;
        Result: Variant;
    begin
        // [SCENARIO] Insert a new Dictionary Member with a Value, Data Type - STRING into Symbol Store

        // [GIVEN] Data Type, Symbol ID, Member ID, and Value 
        SymbolID := 50000;
        MemberID := 1;

        // [WHEN] The function InsertDictionaryValue is called.
        ScriptSymbolStore.InsertDictionaryValue(
            "Symbol Data Type"::BOOLEAN,
            SymbolID,
            MemberID,
            true);

        ScriptSymbolStore.GetSymbolMember(SymbolID, MemberID, Result);

        // [THEN] It should create a new Symbol Member in Store 
        Assert.IsTrue(Result, 'Symbol Member Value true expected.');
    end;

    [Test]
    procedure TestInsertDictionaryValueForTime()
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";
        SymbolID: Integer;
        MemberID: Integer;
        MemberValue: Time;
        Result: Variant;
    begin
        // [SCENARIO] Insert a new Dictionary Member with a Value, Data Type - STRING into Symbol Store

        // [GIVEN] Data Type, Symbol ID, Member ID, and Value 
        SymbolID := 50000;
        MemberID := 1;
        MemberValue := TIME();

        // [WHEN] The function InsertDictionaryValue is called.
        ScriptSymbolStore.InsertDictionaryValue(
            "Symbol Data Type"::TIME,
            SymbolID,
            MemberID,
            MemberValue);

        ScriptSymbolStore.GetSymbolMember(SymbolID, MemberID, Result);

        // [THEN] It should create a new Symbol Member in Store 
        Assert.AreEqual(MemberValue, Result, 'Symbol Member Value time expected.');
    end;

    [Test]
    procedure TestInsertDictionaryValueForDateTime()
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";
        SymbolID: Integer;
        MemberID: Integer;
        MemberValue: DateTime;
        Result: Variant;
    begin
        // [SCENARIO] Insert a new Dictionary Member with a Value, Data Type - STRING into Symbol Store

        // [GIVEN] Data Type, Symbol ID, Member ID, and Value 
        SymbolID := 50000;
        MemberID := 1;

        MemberValue := CurrentDateTime();

        // [WHEN] The function InsertDictionaryValue is called.
        ScriptSymbolStore.InsertDictionaryValue(
            "Symbol Data Type"::DATETIME,
            SymbolID,
            MemberID,
            MemberValue);

        ScriptSymbolStore.GetSymbolMember(SymbolID, MemberID, Result);

        // [THEN] It should create a new Symbol Member in Store 
        Assert.AreEqual(MemberValue, Result, 'Symbol Member Value DateTime expected.');
    end;

    [Test]
    procedure TestInsertDictionaryValueForGuid()
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";

        SymbolID: Integer;
        MemberID: Integer;
        MemberValue: Guid;
        Result: Variant;
    begin
        // [SCENARIO] Insert a new Dictionary Member with a Value, Data Type - STRING into Symbol Store

        // [GIVEN] Data Type, Symbol ID, Member ID, and Value 
        SymbolID := 50000;
        MemberID := 1;
        MemberValue := CreateGuid();

        // [WHEN] The function InsertDictionaryValue is called.
        ScriptSymbolStore.InsertDictionaryValue(
            "Symbol Data Type"::Guid,
            SymbolID,
            MemberID,
            MemberValue);

        ScriptSymbolStore.GetSymbolMember(SymbolID, MemberID, Result);

        // [THEN] It should create a new Symbol Member in Store 
        Assert.AreEqual(MemberValue, Result, 'Symbol Member Value Guid expected.');
    end;

    [Test]
    procedure TestInsertDictionaryValueForRecId()
    var
        AllObj: Record AllObj;
        ScriptSymbolStore: Codeunit "Script Symbol Store";
        MemberValue: RecordId;
        SymbolID, MemberID : Integer;
        Result: Variant;
    begin
        // [SCENARIO] Insert a new Dictionary Member with a Value, Data Type - STRING into Symbol Store

        // [GIVEN] Data Type, Symbol ID, Member ID, and Value 
        SymbolID := 50000;
        MemberID := 1;

        AllObj.FindFirst();
        MemberValue := AllObj.RecordId();

        // [WHEN] The function InsertDictionaryValue is called.
        ScriptSymbolStore.InsertDictionaryValue(
            "Symbol Data Type"::RECID,
            SymbolID,
            MemberID,
            MemberValue);

        ScriptSymbolStore.GetSymbolMember(SymbolID, MemberID, Result);

        // [THEN] It should create a new Symbol Member in Store 
        Assert.AreEqual(MemberValue, Result, 'Symbol Member Value RecordID expected.');
    end;

    [Test]
    procedure TestInsertDictionaryValueForLargeText()
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";
        SymbolID: Integer;
        MemberID: Integer;
        MemberValue: Text;
        Result: Variant;
    begin
        // [SCENARIO] Insert a new Dictionary Member with a Value, Data Type - STRING into Symbol Store

        // [GIVEN] Data Type, Symbol ID, Member ID, and Value 
        SymbolID := 50000;
        MemberID := 1;

        MemberValue := 'Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello ';

        // [WHEN] The function InsertDictionaryValue is called.
        ScriptSymbolStore.InsertDictionaryValue(
            "Symbol Data Type"::STRING,
            SymbolID,
            MemberID,
            MemberValue);

        ScriptSymbolStore.GetSymbolMember(SymbolID, MemberID, Result);

        // [THEN] It should create a new Symbol Member in Store
        Assert.AreEqual(MemberValue, Result, 'Symbol Member Value RecordID expected.');
    end;

    [Test]
    procedure TestInsertDictionaryValueWithNoValue()
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";
        SymbolID: Integer;
        MemberID: Integer;
        MemberValue: Text;
        MemberValueRetrieved: Variant;
    begin
        // [SCENARIO] Insert a new System Symbol - 50000 with a Value into Symbol Store

        // [GIVEN] Symbol Type - System, Data Type - STRING, Symbol ID - 50000, Value - Hello
        SymbolID := 50000;
        MemberID := 1;
        MemberValue := '';

        // [WHEN] The function InsertSymbolValue is called.
        ScriptSymbolStore.InsertDictionaryValue(
            "Symbol Data Type"::STRING,
            SymbolID,
            MemberID);

        ScriptSymbolStore.GetSymbolMember(SymbolID, MemberID, MemberValueRetrieved);

        // [THEN] It should create a new Symbol in Store 
        Assert.AreEqual(MemberValue, MemberValueRetrieved, 'Symbol Member Value Blank expected.');
    end;

    [Test]
    procedure TestGetSymbolOfType()
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";

        SymbolID: Integer;
        SymbolValue: Decimal;
        SymbolValueRetrieved: Variant;
    begin
        // [SCENARIO] Gets Symbol Value from Store

        // [GIVEN] Symbol Type, and Symbol ID
        SymbolID := 50000;
        SymbolValue := 100;
        ScriptSymbolStore.InsertSymbolValue("Symbol Type"::System, "Symbol Data Type"::NUMBER, SymbolID, SymbolValue);

        // [WHEN] The function GetSymbolOfType is called.
        ScriptSymbolStore.GetSymbolOfType("Symbol Type"::System, SymbolID, SymbolValueRetrieved);

        // [THEN] It should assign Symbol Value
        Assert.AreEqual(SymbolValue, SymbolValueRetrieved, 'Symbol Value 100 expected.');
    end;

    [Test]
    procedure TestGetSymbolMember()
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";

        SymbolID: Integer;
        MemberID: Integer;

        MemberValue: Decimal;
        MemberValueRetrieved: Variant;
    begin
        // [SCENARIO] Get Symbol Member Value from store

        // [GIVEN] Symbol ID, and Member ID
        SymbolID := 50000;
        MemberID := 1;
        MemberValue := 100;

        ScriptSymbolStore.InsertDictionaryValue("Symbol Data Type"::NUMBER, SymbolID, MemberID);

        // [WHEN] The function GetSymbolMember is called.
        ScriptSymbolStore.SetSymbolMember(SymbolID, MemberID, MemberValue);
        ScriptSymbolStore.GetSymbolMember(SymbolID, MemberID, MemberValueRetrieved);

        // [THEN] It should assign Member value to Value parameter
        Assert.AreEqual(MemberValue, MemberValueRetrieved, 'Member Value 100 expected.');
    end;

    [Test]
    procedure TestGetSymbolMemberValue()
    var
        TempSymbolMembers: Record "Script Symbol Member Value" Temporary;
        ScriptSymbolStore: Codeunit "Script Symbol Store";
        SymbolID: Integer;
        MemberID: Integer;
        MemberValue: Date;
        MemberValueRetrieved: Variant;
    begin
        // [SCENARIO] Get Symbol Member Value from Script Symbol Member Value record

        // [GIVEN] Symbol ID, and Member ID
        SymbolID := 50000;
        MemberID := 1;

        TempSymbolMembers.Init();
        TempSymbolMembers."Symbol ID" := SymbolID;
        TempSymbolMembers."Member ID" := MemberID;
        TempSymbolMembers.Datatype := "Symbol Data Type"::DATE;
        TempSymbolMembers.Insert();

        MemberValue := WorkDate();

        // [WHEN] The function GetSymbolMemberValue is called.
        ScriptSymbolStore.SetSymbolMemberValue(TempSymbolMembers, MemberValue);
        ScriptSymbolStore.GetSymbolMemberValue(TempSymbolMembers, MemberValueRetrieved);

        // [THEN] It should assign Member value to Value parameter
        Assert.AreEqual(MemberValue, MemberValueRetrieved, 'Member Value should be equals to WorkDate.');
    end;

    [Test]
    procedure TestGetSymbolValue()
    var
        TempSymbols: Record "Script Symbol Value" Temporary;
        ScriptSymbolStore: Codeunit "Script Symbol Store";

        SymbolID: Integer;
        SymbolValue: DateTime;
        SymbolValueRetrieved: Variant;
    begin
        // [SCENARIO] Get Symbol Value from Script Symbol Value record.

        // [GIVEN] Symbol Value record
        SymbolID := 50000;

        TempSymbols.Init();
        TempSymbols.Type := "Symbol Type"::System;
        TempSymbols.Datatype := "Symbol Data Type"::DATETIME;
        TempSymbols.Insert();

        SymbolValue := CurrentDateTime();

        // [WHEN] The function GetSymbolValue is called.
        ScriptSymbolStore.SetSymbolValue(TempSymbols, SymbolValue);
        ScriptSymbolStore.GetSymbolValue(TempSymbols, SymbolValueRetrieved);

        // [THEN] It should assign Symbol value to Value parameter
        Assert.AreEqual(SymbolValue, SymbolValueRetrieved, 'Symbol Value should be equals to CurrDateTime.');
    end;

    [Test]
    procedure TestGetSymbolValueForOption()
    var
        TempSymbols: Record "Script Symbol Value" Temporary;
        ScriptSymbolStore: Codeunit "Script Symbol Store";
        SymbolID: Integer;
        SymbolValue: Option;
        SymbolValueRetrieved: Variant;
    begin
        // [SCENARIO] Get Symbol Value from Script Symbol Value record.

        // [GIVEN] Symbol Value record
        SymbolID := 50000;

        TempSymbols.Init();
        TempSymbols.Type := "Symbol Type"::System;
        TempSymbols.Datatype := "Symbol Data Type"::OPTION;
        TempSymbols.Insert();

        SymbolValue := 5;

        // [WHEN] The function GetSymbolValue is called.
        ScriptSymbolStore.SetSymbolValue(TempSymbols, SymbolValue);
        ScriptSymbolStore.GetSymbolValue(TempSymbols, SymbolValueRetrieved);

        // [THEN] It should assign Symbol value to Value parameter
        Assert.AreEqual(SymbolValue, SymbolValueRetrieved, 'Symbol Value should be equals to 5.');
    end;

    [Test]
    procedure TestGetSymbolValueForDate()
    var
        TempSymbols: Record "Script Symbol Value" Temporary;
        ScriptSymbolStore: Codeunit "Script Symbol Store";

        SymbolID: Integer;
        SymbolValue: Date;
        SymbolValueRetrieved: Variant;
    begin
        // [SCENARIO] Get Symbol Value from Script Symbol Value record.

        // [GIVEN] Symbol Value record
        SymbolID := 50000;

        TempSymbols.Init();
        TempSymbols.Type := "Symbol Type"::System;
        TempSymbols.Datatype := "Symbol Data Type"::DATE;
        TempSymbols.Insert();

        SymbolValue := WorkDate();

        // [WHEN] The function GetSymbolValue is called.
        ScriptSymbolStore.SetSymbolValue(TempSymbols, SymbolValue);
        ScriptSymbolStore.GetSymbolValue(TempSymbols, SymbolValueRetrieved);

        // [THEN] It should assign Symbol value to Value parameter
        Assert.AreEqual(SymbolValue, SymbolValueRetrieved, 'Symbol Value should be equals to WorkDate.');
    end;


    [Test]
    procedure TestGetSymbolValueForTime()
    var
        TempSymbols: Record "Script Symbol Value" Temporary;
        ScriptSymbolStore: Codeunit "Script Symbol Store";
        SymbolID: Integer;
        SymbolValue: Time;
        SymbolValueRetrieved: Variant;
    begin
        // [SCENARIO] Get Symbol Value from Script Symbol Value record.

        // [GIVEN] Symbol Value record
        SymbolID := 50000;

        TempSymbols.Init();
        TempSymbols.Type := "Symbol Type"::System;
        TempSymbols.Datatype := "Symbol Data Type"::TIME;
        TempSymbols.Insert();

        SymbolValue := Time();

        // [WHEN] The function GetSymbolValue is called.
        ScriptSymbolStore.SetSymbolValue(TempSymbols, SymbolValue);
        ScriptSymbolStore.GetSymbolValue(TempSymbols, SymbolValueRetrieved);

        // [THEN] It should assign Symbol value to Value parameter
        Assert.AreEqual(SymbolValue, SymbolValueRetrieved, 'Symbol Value should be equals to Current Time.');
    end;

    [Test]
    procedure TestGetSymbolValueForGuid()
    var
        TempSymbols: Record "Script Symbol Value" Temporary;
        ScriptSymbolStore: Codeunit "Script Symbol Store";

        SymbolID: Integer;
        SymbolValue: Guid;
        SymbolValueRetrieved: Variant;
    begin
        // [SCENARIO] Get Symbol Value from Script Symbol Value record.

        // [GIVEN] Symbol Value record
        SymbolID := 50000;

        TempSymbols.Init();
        TempSymbols.Type := "Symbol Type"::System;
        TempSymbols.Datatype := "Symbol Data Type"::Guid;
        TempSymbols.Insert();

        SymbolValue := CreateGuid();

        // [WHEN] The function GetSymbolValue is called.
        ScriptSymbolStore.SetSymbolValue(TempSymbols, SymbolValue);
        ScriptSymbolStore.GetSymbolValue(TempSymbols, SymbolValueRetrieved);

        // [THEN] It should assign Symbol value to Value parameter
        Assert.AreEqual(SymbolValue, SymbolValueRetrieved, 'Symbol Value should be equals to new Guid.');
    end;

    [Test]
    procedure TestGetSymbolValueForRecID()
    var
        AllObj: Record AllObj;
        TempSymbols: Record "Script Symbol Value" Temporary;
        ScriptSymbolStore: Codeunit "Script Symbol Store";
        SymbolValue: RecordID;
        SymbolID: Integer;
        SymbolValueRetrieved: Variant;
    begin
        // [SCENARIO] Get Symbol Value from Script Symbol Value record.

        // [GIVEN] Symbol Value record
        SymbolID := 50000;

        TempSymbols.Init();
        TempSymbols.Type := "Symbol Type"::System;
        TempSymbols.Datatype := "Symbol Data Type"::RECID;
        TempSymbols.Insert();

        AllObj.FindFirst();
        SymbolValue := AllObj.RecordId();

        // [WHEN] The function GetSymbolValue is called.
        ScriptSymbolStore.SetSymbolValue(TempSymbols, SymbolValue);
        ScriptSymbolStore.GetSymbolValue(TempSymbols, SymbolValueRetrieved);

        // [THEN] It should assign Symbol value to Value parameter
        Assert.AreEqual(SymbolValue, SymbolValueRetrieved, 'Symbol Value should be equals to RecordID.');
    end;

    [Test]
    procedure TestGetSymbolValueForString()
    var
        TempSymbols: Record "Script Symbol Value" Temporary;
        ScriptSymbolStore: Codeunit "Script Symbol Store";

        SymbolID: Integer;
        SymbolValue: Text;
        SymbolValueRetrieved: Variant;
    begin
        // [SCENARIO] Get Symbol Value from Script Symbol Value record.

        // [GIVEN] Symbol Value record
        SymbolID := 50000;

        TempSymbols.Init();
        TempSymbols.Type := "Symbol Type"::System;
        TempSymbols.Datatype := "Symbol Data Type"::STRING;
        TempSymbols.Insert();

        SymbolValue := 'Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello Hello ';

        // [WHEN] The function GetSymbolValue is called.
        ScriptSymbolStore.SetSymbolValue(TempSymbols, SymbolValue);
        ScriptSymbolStore.GetSymbolValue(TempSymbols, SymbolValueRetrieved);

        // [THEN] It should assign Symbol value to Value parameter
        Assert.AreEqual(SymbolValue, SymbolValueRetrieved, 'Symbol Value should be equals to String.');
    end;

    [Test]
    procedure TestSetSymbol2()
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";

        SymbolID: Integer;
        SymbolValueRetrieved: Variant;
    begin
        // [SCENARIO] Set Symbol value a store.

        // [GIVEN] Symbol Value record
        SymbolID := 50000;

        ScriptSymbolStore.InsertSymbolValue(
            "Symbol Type"::System,
            "Symbol Data Type"::BOOLEAN,
            SymbolID,
            false);

        // [WHEN] The function GetSymbolValue is called.
        ScriptSymbolStore.SetSymbol2("Symbol Type"::System, SymbolID, true);
        ScriptSymbolStore.GetSymbolOfType("Symbol Type"::System, SymbolID, SymbolValueRetrieved);

        // [THEN] It should assign Symbol value to Value parameter
        Assert.isTrue(SymbolValueRetrieved, 'Symbol Value should be equals to true.');
    end;

    [Test]
    procedure TestGetLookupSourceType()
    var
        AllObj: Record AllObj;
        ScriptSymbolStore: Codeunit "Script Symbol Store";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        CaseID: Guid;
        ScriptID: Guid;
        LookupID: Guid;
        Result: Enum "Symbol Type";
    begin
        // [SCENARIO] Get Symbol Type from Lookup.

        // [GIVEN] Case ID, Script ID, and Lookup ID
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        LookupID := LibraryScriptSymbolLookup.CreateLookup(
            CaseID,
            ScriptID,
            Database::AllObj,
            AllObj.FieldNo("Object Name"),
            "Symbol Type"::Table);

        // [WHEN] The function GetLookupSourceType is called.
        Result := ScriptSymbolStore.GetLookupSourceType(CaseID, ScriptID, LookupID);

        // [THEN] It should return Source Type from Lookup
        Assert.AreEqual("Symbol Type"::Table, Result, 'Symbol Type should be Table.');
    end;

    [Test]
    procedure TestGetLookupValue()
    var
        AllObj: Record AllObj;
        ScriptSymbolStore: Codeunit "Script Symbol Store";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        SourceRecRef: RecordRef;
        TableMethod: Option " ",First,Last,"Sum","Average","Min","Max","Count","Exist";
        CaseID: Guid;
        ScriptID: Guid;
        LookupID: Guid;
        Result: Variant;
    begin
        // [SCENARIO] Get Value from Lookup.

        // [GIVEN] Case ID, Script ID, and Lookup ID
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        LookupID := LibraryScriptSymbolLookup.CreateLookup(
            CaseID,
            ScriptID,
            Database::AllObj,
            AllObj.FieldNo("Object ID"),
            "Symbol Type"::Table,
            TableMethod::First);

        // [WHEN] The function GetLookupValue is called.
        ScriptSymbolStore.GetLookupValue(SourceRecRef, CaseID, ScriptID, LookupID, Result);

        // [THEN] It should assign LookupValue from Value parameter
        Assert.AreEqual(Database::"Payment Terms", Result, 'Payment Terms Table ID expected.');
    end;

    [Test]
    procedure TestGetLookupValueForUserID()
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        SourceRecRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid;
        LookupID: Guid;
        Result: Variant;
    begin
        // [SCENARIO] Get Value from Lookup.

        // [GIVEN] Case ID, Script ID, and Lookup ID
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        LookupID := LibraryScriptSymbolLookup.CreateLookup(
            CaseID,
            ScriptID,
            0,
            "Database Symbol"::UserId.AsInteger(),
            "Symbol Type"::Database);

        // [WHEN] The function GetLookupValue is called.
        ScriptSymbolStore.GetLookupValue(SourceRecRef, CaseID, ScriptID, LookupID, Result);

        // [THEN] It should assign LookupValue from Value parameter
        Assert.AreEqual(UserId(), Result, 'UserID expected.');
    end;

    [Test]
    procedure TestGetLookupValueForCompanyName()
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        SourceRecRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid;
        LookupID: Guid;
        Result: Variant;
    begin
        // [SCENARIO] Get Value from Lookup.

        // [GIVEN] Case ID, Script ID, and Lookup ID
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        LookupID := LibraryScriptSymbolLookup.CreateLookup(
            CaseID,
            ScriptID,
            0,
            "Database Symbol"::COMPANYNAME.AsInteger(),
            "Symbol Type"::Database);

        // [WHEN] The function GetLookupValue is called.
        ScriptSymbolStore.GetLookupValue(SourceRecRef, CaseID, ScriptID, LookupID, Result);

        // [THEN] It should assign LookupValue from Value parameter
        Assert.AreEqual(CompanyName(), Result, 'CompanyName expected.');
    end;

    [Test]
    procedure TestGetLookupValueForSerialNumber()
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        SourceRecRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid;
        LookupID: Guid;
        Result: Variant;
    begin
        // [SCENARIO] Get Value from Lookup.

        // [GIVEN] Case ID, Script ID, and Lookup ID
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        LookupID := LibraryScriptSymbolLookup.CreateLookup(
            CaseID,
            ScriptID,
            0,
            "Database Symbol"::SERIALNUMBER.AsInteger(),
            "Symbol Type"::Database);

        // [WHEN] The function GetLookupValue is called.
        ScriptSymbolStore.GetLookupValue(SourceRecRef, CaseID, ScriptID, LookupID, Result);

        // [THEN] It should assign LookupValue from Value parameter
        Assert.AreEqual(SerialNumber(), Result, 'SerialNumber expected.');
    end;

    [Test]
    procedure TestGetLookupValueForServiceInstanceId()
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        SourceRecRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid;
        LookupID: Guid;
        Result: Variant;
    begin
        // [SCENARIO] Get Value from Lookup.

        // [GIVEN] Case ID, Script ID, and Lookup ID
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        LookupID := LibraryScriptSymbolLookup.CreateLookup(
            CaseID,
            ScriptID,
            0,
            "Database Symbol"::SERVICEINSTANCEID.AsInteger(),
            "Symbol Type"::Database);

        // [WHEN] The function GetLookupValue is called.
        ScriptSymbolStore.GetLookupValue(SourceRecRef, CaseID, ScriptID, LookupID, Result);

        // [THEN] It should assign LookupValue from Value parameter
        Assert.AreEqual(ServiceInstanceId(), Result, 'ServiceInstanceId expected.');
    end;

    [Test]
    procedure TestGetLookupValueForSessionId()
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        SourceRecRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid;
        LookupID: Guid;
        Result: Variant;
    begin
        // [SCENARIO] Get Value from Lookup.

        // [GIVEN] Case ID, Script ID, and Lookup ID
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        LookupID := LibraryScriptSymbolLookup.CreateLookup(
            CaseID,
            ScriptID,
            0,
            "Database Symbol"::SESSIONID.AsInteger(),
            "Symbol Type"::Database);

        // [WHEN] The function GetLookupValue is called.
        ScriptSymbolStore.GetLookupValue(SourceRecRef, CaseID, ScriptID, LookupID, Result);

        // [THEN] It should assign LookupValue from Value parameter
        Assert.AreEqual(SessionId(), Result, 'SessionId expected.');
    end;

    [Test]
    procedure TestGetLookupValueForTenantId()
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        SourceRecRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid;
        LookupID: Guid;
        Result: Variant;
    begin
        // [SCENARIO] Get Value from Lookup.

        // [GIVEN] Case ID, Script ID, and Lookup ID
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        LookupID := LibraryScriptSymbolLookup.CreateLookup(
            CaseID,
            ScriptID,
            0,
            "Database Symbol"::TENANTID.AsInteger(),
            "Symbol Type"::Database);

        // [WHEN] The function GetLookupValue is called.
        ScriptSymbolStore.GetLookupValue(SourceRecRef, CaseID, ScriptID, LookupID, Result);

        // [THEN] It should assign LookupValue from Value parameter
        Assert.AreEqual(TenantId(), Result, 'TenantId expected.');
    end;

    [Test]
    procedure TestGetLookupValueForTime()
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        SourceRecRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid;
        LookupID: Guid;
        Result: Variant;
    begin
        // [SCENARIO] Get Value from Lookup.

        // [GIVEN] Case ID, Script ID, and Lookup ID
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        LookupID := LibraryScriptSymbolLookup.CreateLookup(
            CaseID,
            ScriptID,
            0,
            "System Symbol"::TIME.AsInteger(),
            "Symbol Type"::System);

        // [WHEN] The function GetLookupValue is called.
        ScriptSymbolStore.GetLookupValue(SourceRecRef, CaseID, ScriptID, LookupID, Result);

        // [THEN] It should assign LookupValue from Value parameter
        Assert.AreNotEqual(0T, Result, 'Time expected.');
    end;

    [Test]
    procedure TestGetLookupValueForToday()
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        SourceRecRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid;
        LookupID: Guid;
        Result: Variant;
    begin
        // [SCENARIO] Get Value from Lookup.

        // [GIVEN] Case ID, Script ID, and Lookup ID
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        LookupID := LibraryScriptSymbolLookup.CreateLookup(
            CaseID,
            ScriptID,
            0,
            "System Symbol"::Today.AsInteger(),
            "Symbol Type"::System);

        // [WHEN] The function GetLookupValue is called.
        ScriptSymbolStore.GetLookupValue(SourceRecRef, CaseID, ScriptID, LookupID, Result);

        // [THEN] It should assign LookupValue from Value parameter
        Assert.AreEqual(Today(), Result, 'Today expected.');
    end;

    [Test]
    procedure TestGetLookupValueForWorkDate()
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        SourceRecRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid;
        LookupID: Guid;
        Result: Variant;
    begin
        // [SCENARIO] Get Value from Lookup.

        // [GIVEN] Case ID, Script ID, and Lookup ID
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        LookupID := LibraryScriptSymbolLookup.CreateLookup(
            CaseID,
            ScriptID,
            0,
            "System Symbol"::WorkDate.AsInteger(),
            "Symbol Type"::System);

        // [WHEN] The function GetLookupValue is called.
        ScriptSymbolStore.GetLookupValue(SourceRecRef, CaseID, ScriptID, LookupID, Result);

        // [THEN] It should assign LookupValue from Value parameter
        Assert.AreEqual(WorkDate(), Result, 'WorkDate expected.');
    end;

    [Test]
    procedure TestGetLookupValueForCurrDateTime()
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        SourceRecRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid;
        LookupID: Guid;
        Result: Variant;
    begin
        // [SCENARIO] Get Value from Lookup.

        // [GIVEN] Case ID, Script ID, and Lookup ID
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        LookupID := LibraryScriptSymbolLookup.CreateLookup(
            CaseID,
            ScriptID,
            0,
            "System Symbol"::CURRENTDATETIME.AsInteger(),
            "Symbol Type"::System);

        // [WHEN] The function GetLookupValue is called.
        ScriptSymbolStore.GetLookupValue(SourceRecRef, CaseID, ScriptID, LookupID, Result);

        // [THEN] It should assign LookupValue from Value parameter
        Assert.AreNotEqual(0DT, Result, 'Current Date Time expected.');
    end;

    [Test]
    procedure TestGetConstantOrLookupValue()
    var
        AllObj: Record AllObj;
        ScriptSymbolStore: Codeunit "Script Symbol Store";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        SourceRecRef: RecordRef;
        TableMethod: Option " ",First,Last,"Sum","Average","Min","Max","Count","Exist";
        ValueType: Option Constant,"Lookup";
        CaseID: Guid;
        ScriptID: Guid;
        LookupID: Guid;
        Result: Variant;
    begin
        // [SCENARIO] Get Contant or Look Value based on Value Type.

        // [GIVEN] Case ID, Script ID, Value Type, Const Value and Lookup ID
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        LookupID := LibraryScriptSymbolLookup.CreateLookup(
            CaseID,
            ScriptID,
            Database::AllObj,
            AllObj.FieldNo("Object Name"),
            "Symbol Type"::Table,
            TableMethod::First);

        // [WHEN] The function GetConstantOrLookupValue is called.
        ScriptSymbolStore.GetConstantOrLookupValue(
            SourceRecRef,
            CaseID, ScriptID,
            ValueType::Constant,
            'Hello',
            LookupID,
            Result);

        // [THEN] It should assign Constant Value from Value parameter
        Assert.AreEqual('Hello', Result, 'Payment Terms Table ID expected.');
    end;

    [Test]
    procedure TestGetConstantOrLookupValueWithLookup()
    var
        AllObj: Record AllObj;
        ScriptSymbolStore: Codeunit "Script Symbol Store";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        SourceRecRef: RecordRef;
        TableMethod: Option " ",First,Last,"Sum","Average","Min","Max","Count","Exist";
        ValueType: Option Constant,"Lookup";
        CaseID: Guid;
        ScriptID: Guid;
        LookupID: Guid;
        Result: Variant;
    begin
        // [SCENARIO] Get Contant or Look Value based on Value Type.

        // [GIVEN] Case ID, Script ID, Value Type, Const Value and Lookup ID
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        LookupID := LibraryScriptSymbolLookup.CreateLookup(
            CaseID,
            ScriptID,
            Database::AllObj,
            AllObj.FieldNo("Object ID"),
            "Symbol Type"::Table,
            TableMethod::First);

        // [WHEN] The function GetConstantOrLookupValue is called.
        ScriptSymbolStore.GetConstantOrLookupValue(
            SourceRecRef,
            CaseID, ScriptID,
            ValueType::Lookup,
            'Hello',
            LookupID,
            Result);

        // [THEN] It should assign Constant Value from Value parameter
        Assert.AreEqual(Database::"Payment Terms", Result, 'Payment Terms Table ID expected.');
    end;

    [Test]
    procedure TestGetConstantOrLookupValueOfType()
    var
        AllObj: Record AllObj;
        ScriptSymbolStore: Codeunit "Script Symbol Store";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";

        SourceRecRef: RecordRef;
        TableMethod: Option " ",First,Last,"Sum","Average","Min","Max","Count","Exist";
        ValueType: Option Constant,"Lookup";

        CaseID: Guid;
        ScriptID: Guid;
        LookupID: Guid;
        Result: Variant;
    begin
        // [SCENARIO] Get Contant or Look Value based on Value Type, and Converts to Data Type specified.

        // [GIVEN] Case ID, Script ID, Value Type, Const Value and Lookup ID
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        LookupID := LibraryScriptSymbolLookup.CreateLookup(
            CaseID,
            ScriptID,
            Database::AllObj,
            AllObj.FieldNo("Object ID"),
            "Symbol Type"::Table,
            TableMethod::First);

        // [WHEN] The function GetConstantOrLookupValue is called.
        ScriptSymbolStore.GetConstantOrLookupValueOfType(
            SourceRecRef,
            CaseID, ScriptID,
            ValueType::Lookup,
            '3',
            LookupID,
            "Symbol Data Type"::NUMBER,
            '',
            Result);

        // [THEN] It should assign Constant Value from Value parameter
        Assert.AreEqual(Database::"Payment Terms", Result, 'Payment Terms Table ID expected.');
    end;

    [Test]
    procedure TestGetConstantOrLookupValueOfTypeForConst()
    var
        AllObj: Record AllObj;
        ScriptSymbolStore: Codeunit "Script Symbol Store";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        SourceRecRef: RecordRef;
        TableMethod: Option " ",First,Last,"Sum","Average","Min","Max","Count","Exist";
        ValueType: Option Constant,"Lookup";
        CaseID: Guid;
        ScriptID: Guid;
        LookupID: Guid;
        Result: Variant;
    begin
        // [SCENARIO] Get Contant or Look Value based on Value Type, and Converts to Data Type specified.

        // [GIVEN] Case ID, Script ID, Value Type, Const Value and Lookup ID
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        LookupID := LibraryScriptSymbolLookup.CreateLookup(
            CaseID,
            ScriptID,
            Database::AllObj,
            AllObj.FieldNo("Object ID"),
            "Symbol Type"::Table,
            TableMethod::First);

        // [WHEN] The function GetConstantOrLookupValue is called.
        ScriptSymbolStore.GetConstantOrLookupValueOfType(
            SourceRecRef,
            CaseID, ScriptID,
            ValueType::Constant,
            '3',
            LookupID,
            "Symbol Data Type"::NUMBER,
            '',
            Result);

        // [THEN] It should assign Constant Value from Value parameter
        Assert.AreEqual(Database::"Payment Terms", Result, 'Payment Terms Table ID expected.');
    end;

    [Test]
    procedure TestSetDefaultSymbolValue()
    var
        TempSymbols: Record "Script Symbol Value" temporary;
        ScriptSymbolStore: Codeunit "Script Symbol Store";
        SymbolID: Integer;
        Result: Variant;
        CurrDateTime: DateTime;
    begin
        // [SCENARIO] Sets Symbol Value in Store, Create a new symbol if not created.

        // [GIVEN] Symbol Type, Symbol ID, Value, and Data Type
        SymbolID := 50000;
        CurrDateTime := CurrentDateTime();

        TempSymbols.Init();
        TempSymbols.Type := "Symbol Type"::System;
        TempSymbols."Symbol ID" := SymbolID;
        TempSymbols.Datatype := "Symbol Data Type"::DATETIME;
        TempSymbols.Insert();

        // [WHEN] The function SetDefaultSymbolValue is called.
        ScriptSymbolStore.SetDefaultSymbolValue(
            TempSymbols,
            "Symbol Type"::System,
            SymbolID,
            CurrDateTime,
            "Symbol Data Type"::DATETIME);
        ScriptSymbolStore.GetSymbolValue(TempSymbols, Result);

        // [THEN] It should assign update symbol value in store.
        Assert.AreEqual(CurrDateTime, Result, 'Curr Date Time expected.');
    end;

    [Test]
    procedure TestSetDefaultSymbolValueWithNew()
    var
        TempSymbols: Record "Script Symbol Value" temporary;
        ScriptSymbolStore: Codeunit "Script Symbol Store";
        SymbolID: Integer;
        Result: Variant;
        CurrDateTime: DateTime;
    begin
        // [SCENARIO] Sets Symbol Value in Store, Create a new symbol if not created.

        // [GIVEN] Symbol Type, Symbol ID, Value, and Data Type
        SymbolID := 50000;
        CurrDateTime := CurrentDateTime();

        // [WHEN] The function SetDefaultSymbolValue is called.
        ScriptSymbolStore.SetDefaultSymbolValue(
            TempSymbols,
            "Symbol Type"::System,
            SymbolID,
            CurrDateTime,
            "Symbol Data Type"::DATETIME);

        ScriptSymbolStore.GetSymbolValue(TempSymbols, Result);

        // [THEN] It should assign update symbol value in store.
        Assert.AreEqual(CurrDateTime, Result, 'Curr Date Time expected.');
    end;

    [Test]
    procedure TestApplyTableFilters()
    var
        AllObj: Record AllObj;
        LookupFieldFilter: Record "Lookup Field Filter";
        ScriptSymbolStore: Codeunit "Script Symbol Store";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        SourceRecRef: RecordRef;
        RecRef: RecordRef;
        FieldRef: FieldRef;
        CaseID: Guid;
        ScriptID: Guid;
        TableFilterID: Guid;
        Result: Text;
    begin
        // [SCENARIO] Apply Table Filters from Filters configured in Table Filters Table.

        // [GIVEN] Case ID, Script ID, RecRef and Table Filter ID
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        RecRef.Open(Database::AllObj);
        FieldRef := RecRef.Field(AllObj.FieldNo("Object Type"));
        TableFilterID := LibraryScriptSymbolLookup.CreateTableFilter(CaseID, ScriptID, RecRef.Number, FieldRef.Number);
        LookupFieldFilter.Get(CaseID, ScriptID, TableFilterID, FieldRef.Number);
        LookupFieldFilter."Value Type" := LookupFieldFilter."Value Type"::Constant;
        LookupFieldFilter.Value := 'Table';
        LookupFieldFilter.Modify();

        // [WHEN] The function ApplyTableFilters is called.
        ScriptSymbolStore.ApplyTableFilters(
            SourceRecRef,
            CaseID,
            ScriptID,
            RecRef,
            TableFilterID);

        Result := RecRef.Field(AllObj.FieldNo("Object Type")).GetFilter();

        // [THEN] It should table filters should be applied on RecRef
        Assert.AreEqual('Table', Result, 'Table filter should be applied');
    end;

    [Test]
    procedure TestTransferRecRefToSymbolMembers()
    var
        AllObj: Record AllObj;
        ScriptSymbolStore: Codeunit "Script Symbol Store";
        RecRef: RecordRef;
        SymbolID: Integer;
        ObjectTypeResult: Variant;
        ObjectIDResult: Variant;
        ObjectNameResult: Variant;
    begin
        // [SCENARIO] Trasfer field values from RecordRef to Dictionary Members.

        // [GIVEN] RecordRef, Symbol ID
        SymbolID := 50000;

        AllObj.FindFirst();
        RecRef.GetTable(AllObj);

        ScriptSymbolStore.InsertDictionaryValue("Symbol Data Type"::OPTION, SymbolID, AllObj.FieldNo("Object Type"));
        ScriptSymbolStore.InsertDictionaryValue("Symbol Data Type"::NUMBER, SymbolID, AllObj.FieldNo("Object ID"));
        ScriptSymbolStore.InsertDictionaryValue("Symbol Data Type"::STRING, SymbolID, AllObj.FieldNo("Object Name"));

        // [WHEN] The function TransferRecRefToSymbolMembers is called.
        ScriptSymbolStore.TransferRecRefToSymbolMembers(RecRef, SymbolID);

        ScriptSymbolStore.GetSymbolMember(SymbolID, AllObj.FieldNo("Object Type"), ObjectTypeResult);
        ScriptSymbolStore.GetSymbolMember(SymbolID, AllObj.FieldNo("Object ID"), ObjectIDResult);
        ScriptSymbolStore.GetSymbolMember(SymbolID, AllObj.FieldNo("Object Name"), ObjectNameResult);

        // [THEN] It should assign update member value in store from RecordRef.
        Assert.AreEqual(AllObj."Object Type", ObjectTypeResult, 'Object Type should be Table.');
        Assert.AreEqual(AllObj."Object ID", ObjectIDResult, 'Object ID should be 3');
        Assert.AreEqual(AllObj."Object Name", ObjectNameResult, 'Object ID should be Payment Terms.');
    end;
}