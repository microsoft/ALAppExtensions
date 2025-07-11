codeunit 136703 "Script Symbols Mgmt. Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    trigger OnRun()
    begin
        // [FEATURE] [TaxEngine] [Symbols Mgmt] [UT]
    end;

    var
        Asset: Codeunit Assert;

    [Test]
    procedure TestSearchSymbolWithEmptyName()
    var
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        SymbolID: Integer;
        SymbolName: Text[30];
    begin
        // [SCENARIO] SearchSymbol called with Symbol Name Empty

        // [GIVEN] Empty Symbol Name
        SymbolID := -1;
        SymbolName := '';
        BindSubscription(LibraryScriptSymbolLookup);
        LibraryScriptSymbolLookup.SetContext(ScriptSymbolsMgmt);
        UnbindSubscription(LibraryScriptSymbolLookup);

        // [WHEN] The function SearchSymbol is called.
        ScriptSymbolsMgmt.SearchSymbol("Symbol Type"::Database, SymbolID, SymbolName);

        // [THEN] It should assign Symbol ID with 0.
        Asset.AreEqual(0, SymbolID, 'Symbol ID should be 0.');
    end;

    [Test]
    procedure TestSearchSymbolWithValidName()
    var
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        SymbolID: Integer;
        SymbolName: Text[30];
    begin
        // [SCENARIO] SearchSymbol called for a valid Symbol Name

        // [GIVEN] Valid Symbol Name
        SymbolName := 'UserId';
        BindSubscription(LibraryScriptSymbolLookup);
        LibraryScriptSymbolLookup.SetContext(ScriptSymbolsMgmt);
        UnbindSubscription(LibraryScriptSymbolLookup);

        // [WHEN] The function SearchSymbol is called.
        ScriptSymbolsMgmt.SearchSymbol("Symbol Type"::Database, SymbolID, SymbolName);

        // [THEN] it should assign Symbol ID and Name.
        Asset.AreEqual("Database Symbol"::UserId, SymbolID, 'Symbol ID should be User ID.');
    end;

    [Test]
    procedure TestSearchSymbolWithInValidName()
    var
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        SymbolID: Integer;
        SymbolName: Text[30];
        ExpectedResult: Text;
        InvalidSymbolValueMsg: Label 'You cannot enter ''%1'' in %2.', Comment = '%1 = Symbol Name, %2 = Symbol Type';
    begin
        // [SCENARIO] SearchSymbol called for a invalid Symbol Name

        // [GIVEN] Invalid Symbol Name
        SymbolName := 'Invalid Symbol';
        BindSubscription(LibraryScriptSymbolLookup);
        LibraryScriptSymbolLookup.SetContext(ScriptSymbolsMgmt);
        UnbindSubscription(LibraryScriptSymbolLookup);
        ExpectedResult := StrSubstNo(InvalidSymbolValueMsg, SymbolName, "Symbol Type"::Database);

        // [WHEN] The function SearchSymbol is called.
        asserterror ScriptSymbolsMgmt.SearchSymbol("Symbol Type"::Database, SymbolID, SymbolName);

        // [THEN] it should throw error
        Asset.AreEqual(ExpectedResult, GetLastErrorText, 'Should throw error message.');
    end;


    [Test]
    procedure TestGetSymbolInfo()
    var
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        SymbolID: Integer;
        SymbolName: Text[30];
        ExpectedResult: Text;
        DataType: Enum "Symbol Data Type";
    begin
        // [SCENARIO] Get Symbol Infor for User ID

        // [GIVEN] Symbol ID for UserID
        SymbolName := 'Invalid Symbol';
        SymbolID := "Database Symbol"::UserId.AsInteger();
        BindSubscription(LibraryScriptSymbolLookup);
        LibraryScriptSymbolLookup.SetContext(ScriptSymbolsMgmt);
        UnbindSubscription(LibraryScriptSymbolLookup);
        ExpectedResult := Format("Database Symbol"::UserId);

        // [WHEN] The function GetSymbolInfo is called.
        ScriptSymbolsMgmt.GetSymbolInfo("Symbol Type"::Database, SymbolID, SymbolName, DataType);

        // [THEN] it should populate SymbolName, and DataType
        Asset.AreEqual(ExpectedResult, SymbolName, 'UseId expected.');
        Asset.AreEqual("Symbol Data Type"::STRING, DataType, 'String datatype expected.');
    end;

    [Test]
    procedure TestGetSymbolDataType()
    var
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        SymbolID: Integer;
        DataType: Enum "Symbol Data Type";
    begin
        // [SCENARIO] Get DataType of UserID

        // [GIVEN] Symbol ID - UserID
        SymbolID := "Database Symbol"::UserId.AsInteger();
        BindSubscription(LibraryScriptSymbolLookup);
        LibraryScriptSymbolLookup.SetContext(ScriptSymbolsMgmt);
        UnbindSubscription(LibraryScriptSymbolLookup);

        // [WHEN] The function SearchSymbol is called.
        DataType := ScriptSymbolsMgmt.GetSymbolDataType("Symbol Type"::Database, SymbolID);

        // [THEN] it should return String Data Type
        Asset.AreEqual("Symbol Data Type"::STRING, DataType, 'String datatype expected.');
    end;

    [Test]
    procedure TestGetSymbolName()
    var
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        SymbolID: Integer;
        SymbolName: Text;
    begin
        // [SCENARIO] Get DataType of UserID

        // [GIVEN] Symbol ID - 5000
        SymbolID := 5000;
        BindSubscription(LibraryScriptSymbolLookup);
        LibraryScriptSymbolLookup.SetContext(ScriptSymbolsMgmt);
        UnbindSubscription(LibraryScriptSymbolLookup);

        // [WHEN] The function GetSymbolName is called.
        SymbolName := ScriptSymbolsMgmt.GetSymbolName("Symbol Type"::System, SymbolID);

        // [THEN] it should return Symbol Name
        Asset.AreEqual('TEST SYMBOL', SymbolName, 'Symbol Name TEST SYMBOL expected.');
    end;

    [Test]
    procedure TestGetSymbolID()
    var
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        SymbolID: Integer;
        SymbolName: Text[30];
    begin
        // [SCENARIO] Get Symbol ID from Symbol Name

        // [GIVEN] Symbol Name
        SymbolID := 5000;
        SymbolName := 'TEST SYMBOL';
        BindSubscription(LibraryScriptSymbolLookup);
        LibraryScriptSymbolLookup.SetContext(ScriptSymbolsMgmt);
        UnbindSubscription(LibraryScriptSymbolLookup);

        // [WHEN] The function GetSymbolID is called.
        SymbolID := ScriptSymbolsMgmt.GetSymbolID("Symbol Type"::System, SymbolName);

        // [THEN] It should return Symbol ID
        Asset.AreEqual(5000, SymbolID, 'Symbol ID 5000 expected.');
    end;

    [Test]
    procedure TestSearchSymbolOfType()
    var
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        SymbolID: Integer;
        SymbolName: Text[30];
    begin
        // [SCENARIO] Search Symbol based on Data Type and Name

        // [GIVEN] Data Type, and Symbol Name
        SymbolName := 'TEST';
        BindSubscription(LibraryScriptSymbolLookup);
        LibraryScriptSymbolLookup.SetContextWithoutTaxType(ScriptSymbolsMgmt);
        UnbindSubscription(LibraryScriptSymbolLookup);

        // [WHEN] The function SearchSymbolOfType is called.
        ScriptSymbolsMgmt.SearchSymbolOfType("Symbol Type"::System, "Symbol Data Type"::STRING, SymbolID, SymbolName);

        // [THEN] It should return Symbol ID
        Asset.AreEqual(5000, SymbolID, 'Symbol ID 5000 expected.');
    end;

    [Test]
    [HandlerFunctions('SymbolsLookupPageHandler')]
    procedure TestOpenSymbolsLookup()
    var
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        SymbolID: Integer;
        SymbolName: Text[30];
    begin
        // [SCENARIO] Open Symbol Lookup Dialog for Type System

        // [GIVEN] Search Text - TEST
        SymbolName := 'TEST';
        BindSubscription(LibraryScriptSymbolLookup);
        LibraryScriptSymbolLookup.SetContextWithoutTaxType(ScriptSymbolsMgmt);
        UnbindSubscription(LibraryScriptSymbolLookup);

        // [WHEN] The function OpenSymbolsLookup is called.
        ScriptSymbolsMgmt.OpenSymbolsLookup("Symbol Type"::System, 'TEST', SymbolID, SymbolName);

        // [THEN] It should return Symbol ID
        Asset.AreEqual(5000, SymbolID, 'Symbol ID 5000 expected.');
    end;

    [Test]
    [HandlerFunctions('SymbolsLookupPageHandler')]
    procedure TestOpenSymbolsLookupWithSymbolID()
    var
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        SymbolID: Integer;
        SymbolName: Text[30];
    begin
        // [SCENARIO] Open Symbol Lookup Dialog for Type System

        // [GIVEN] Symbol ID - 5000
        SymbolID := 5000;
        SymbolName := 'TEST';
        BindSubscription(LibraryScriptSymbolLookup);
        LibraryScriptSymbolLookup.SetContextWithoutTaxType(ScriptSymbolsMgmt);
        UnbindSubscription(LibraryScriptSymbolLookup);

        // [WHEN] The function OpenSymbolsLookup is called.
        ScriptSymbolsMgmt.OpenSymbolsLookup("Symbol Type"::System, 'TEST', SymbolID, SymbolName);

        // [THEN] It should return Symbol ID
        Asset.AreEqual('TEST SYMBOL', SymbolName, 'Symbol Name TEST SYMBOL expected.');
    end;

    [Test]
    [HandlerFunctions('SymbolsLookupPageHandler')]
    procedure TestOpenSymbolsLookupOfType()
    var
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        SymbolID: Integer;
        SymbolName: Text[30];
    begin
        // [SCENARIO] Open Symbol Lookup Dialog for Symbol Type System, Data Type String

        // [GIVEN] Search Text - TEST
        SymbolName := 'TEST';
        BindSubscription(LibraryScriptSymbolLookup);
        LibraryScriptSymbolLookup.SetContextWithoutTaxType(ScriptSymbolsMgmt);
        UnbindSubscription(LibraryScriptSymbolLookup);

        // [WHEN] The function OpenSymbolsLookup is called.
        ScriptSymbolsMgmt.OpenSymbolsLookupOfType("Symbol Type"::System, 'TEST', "Symbol Data Type"::STRING, SymbolID, SymbolName);

        // [THEN] It should return Symbol ID
        Asset.AreEqual(5000, SymbolID, 'Symbol ID 5000 expected.');
    end;

    [ModalPageHandler]
    procedure SymbolsLookupPageHandler(var ScriptSymbols: TestPage "Script Symbols")
    begin
        ScriptSymbols.OK().Invoke();
    end;
}