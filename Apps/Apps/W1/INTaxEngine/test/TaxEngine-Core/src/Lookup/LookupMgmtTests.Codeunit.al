codeunit 136708 "Lookup Mgmt Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;
    trigger OnRun()
    begin
        // [FEATURE] [TaxEngine] [Lookup Mgmt] [UT]
    end;

    var
        Assert: Codeunit Assert;
        ErrorMsg: Label 'Error message should be %1', Comment = '%1 = Error message';
        ValueLbl: Label 'Value should be %1', Comment = '%1 = Expected Value';

    [Test]
    procedure TestGetSourceTable()
    var
        LookupMgmt: Codeunit "Lookup Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        CaseID: Guid;
        SetupTableID, TableID : Integer;
    begin
        // [SCENARIO] To get the table ID attached to the Use Case.

        // [GIVEN] There should be a table exist with name Sales Line 
        CaseID := CreateGuid();
        SetupTableID := Database::"Sales Line";

        // [WHEN] The function GetSourceTable is called.
        BindSubscription(LibraryScriptSymbolLookup);
        TableID := LookupMgmt.GetSourceTable(CaseID);
        UnBindSubscription(LibraryScriptSymbolLookup);

        // [THEN] TableID should be equal to tableid of Sales Line.
        Assert.AreEqual(SetupTableID, TableID, 'Table ID should be Table Id of G/L Account table.');
    end;

    [Test]
    procedure TestGetSourceTableForUnHandledErr()
    var
        LookupMgmt: Codeunit "Lookup Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        InvalidGetLookupSourceTableIDErr: Label 'GetLookupSourceTableID is Not Implemented';
        CaseID: Guid;
        TableID: Integer;
    begin
        // [SCENARIO] To get the un hanlded case ID error when case ID is blank.

        // [GIVEN] CaseID should the empty
        // [WHEN] The function GetSourceTable is called.
        BindSubscription(LibraryScriptSymbolLookup);
        asserterror TableID := LookupMgmt.GetSourceTable(CaseID);
        UnBindSubscription(LibraryScriptSymbolLookup);

        // [THEN] It should throw and error.
        Assert.AreEqual(GetLastErrorText, InvalidGetLookupSourceTableIDErr, StrSubstNo(ErrorMsg, InvalidGetLookupSourceTableIDErr));
    end;

    [Test]
    procedure TestGetSourceTableForBlankTableErr()
    var
        LookupMgmt: Codeunit "Lookup Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        InvalidTableIDErr: Label 'TableID is not defined for Case ID %1', Comment = '%1 = Use Case ID';
        CaseID: Guid;
        TableID: Integer;
    begin
        // [SCENARIO] To get the un hanlded case ID error when case ID is blank.

        // [GIVEN] CaseID should the empty
        CaseID := '3089bc6c-c971-4ee9-a96a-3df5ebb63571';

        // [WHEN] The function GetSourceTable is called.
        BindSubscription(LibraryScriptSymbolLookup);
        asserterror TableID := LookupMgmt.GetSourceTable(CaseID);
        UnBindSubscription(LibraryScriptSymbolLookup);

        // [THEN] It should throw and error.
        Assert.AreEqual(GetLastErrorText, strsubstno(InvalidTableIDErr, CaseID), StrSubstNo(ErrorMsg, strsubstno(InvalidTableIDErr, CaseID)));
    end;

    [Test]
    procedure TestGetLookupDatatypeForNumber()
    var
        SalesLine: Record "Sales Line";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        CaseID, ScriptID, LookupID : Guid;
        DataType: Enum "Symbol Data Type";
    begin
        // [SCENARIO] To get the NUMBER datatype of from a Script Symbol Lookup.

        // [GIVEN] A Script Symbol Lookup is created with Source Type Table for Sales Line and Field ID Amount.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        RecRef.Open(Database::"Sales Line");
        FieldRef := RecRef.Field(SalesLine.FieldNo(Amount));
        LookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, RecRef.Number, FieldRef.Number, "Symbol Type"::Table);

        // [WHEN] The function GetLookupDatatype is called.
        BindSubscription(LibraryScriptSymbolLookup);
        DataType := LookupMgmt.GetLookupDatatype(CaseID, ScriptID, LookupID);
        UnBindSubscription(LibraryScriptSymbolLookup);

        // [THEN] It should return NUMBER datatype.
        Assert.AreEqual("Symbol Data Type"::NUMBER, DataType, 'Datatype should be NUMBER');
    end;

    [Test]
    procedure TestGetLookupDatatypeForNumberForSum()
    var
        SalesLine: Record "Sales Line";
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        CaseID: Guid;
        ScriptID: Guid;
        LookupID: Guid;
        DataType: Enum "Symbol Data Type";
    begin
        // [SCENARIO] To get the NUMBER datatype of from a Script Symbol Lookup.

        // [GIVEN] A Script Symbol Lookup is created with Source Type Table for Sales Line and Field ID Amount.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        RecRef.Open(Database::"Sales Line");
        FieldRef := RecRef.Field(SalesLine.FieldNo(Amount));
        LookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, RecRef.Number, FieldRef.Number, "Symbol Type"::Table, ScriptSymbolLookup."Table Method"::Sum);

        // [WHEN] The function GetLookupDatatype is called.
        BindSubscription(LibraryScriptSymbolLookup);
        DataType := LookupMgmt.GetLookupDatatype(CaseID, ScriptID, LookupID);
        UnBindSubscription(LibraryScriptSymbolLookup);

        // [THEN] It should return NUMBER datatype.
        Assert.AreEqual("Symbol Data Type"::NUMBER, DataType, 'Datatype should be NUMBER');
    end;

    [Test]
    procedure TestGetLookupDatatypeForNumberForAvg()
    var
        SalesLine: Record "Sales Line";
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        CaseID: Guid;
        ScriptID: Guid;
        LookupID: Guid;
        DataType: Enum "Symbol Data Type";
    begin
        // [SCENARIO] To get the NUMBER datatype of from a Script Symbol Lookup.

        // [GIVEN] A Script Symbol Lookup is created with Source Type Table for Sales Line and Field ID Amount.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        RecRef.Open(Database::"Sales Line");
        FieldRef := RecRef.Field(SalesLine.FieldNo(Amount));
        LookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, RecRef.Number, FieldRef.Number, "Symbol Type"::Table, ScriptSymbolLookup."Table Method"::Average);

        // [WHEN] The function GetLookupDatatype is called.
        BindSubscription(LibraryScriptSymbolLookup);
        DataType := LookupMgmt.GetLookupDatatype(CaseID, ScriptID, LookupID);
        UnBindSubscription(LibraryScriptSymbolLookup);

        // [THEN] It should return NUMBER datatype.
        Assert.AreEqual("Symbol Data Type"::NUMBER, DataType, 'Datatype should be NUMBER');
    end;

    [Test]
    procedure TestGetLookupDatatypeForNumberForMin()
    var
        SalesLine: Record "Sales Line";
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        CaseID: Guid;
        ScriptID: Guid;
        LookupID: Guid;
        DataType: Enum "Symbol Data Type";
    begin
        // [SCENARIO] To get the NUMBER datatype of from a Script Symbol Lookup.

        // [GIVEN] A Script Symbol Lookup is created with Source Type Table for Sales Line and Field ID Amount.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        RecRef.Open(Database::"Sales Line");
        FieldRef := RecRef.Field(SalesLine.FieldNo(Amount));
        LookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, RecRef.Number, FieldRef.Number, "Symbol Type"::Table, ScriptSymbolLookup."Table Method"::Min);

        // [WHEN] The function GetLookupDatatype is called.
        BindSubscription(LibraryScriptSymbolLookup);
        DataType := LookupMgmt.GetLookupDatatype(CaseID, ScriptID, LookupID);
        UnBindSubscription(LibraryScriptSymbolLookup);

        // [THEN] It should return NUMBER datatype.
        Assert.AreEqual("Symbol Data Type"::NUMBER, DataType, 'Datatype should be NUMBER');
    end;

    [Test]
    procedure TestGetLookupDatatypeForNumberForMax()
    var
        SalesLine: Record "Sales Line";
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        CaseID: Guid;
        ScriptID: Guid;
        LookupID: Guid;
        DataType: Enum "Symbol Data Type";
    begin
        // [SCENARIO] To get the NUMBER datatype of from a Script Symbol Lookup.

        // [GIVEN] A Script Symbol Lookup is created with Source Type Table for Sales Line and Field ID Amount.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        RecRef.Open(Database::"Sales Line");
        FieldRef := RecRef.Field(SalesLine.FieldNo(Amount));
        LookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, RecRef.Number, FieldRef.Number, "Symbol Type"::Table, ScriptSymbolLookup."Table Method"::Max);

        // [WHEN] The function GetLookupDatatype is called.
        BindSubscription(LibraryScriptSymbolLookup);
        DataType := LookupMgmt.GetLookupDatatype(CaseID, ScriptID, LookupID);
        UnBindSubscription(LibraryScriptSymbolLookup);

        // [THEN] It should return NUMBER datatype.
        Assert.AreEqual("Symbol Data Type"::NUMBER, DataType, 'Datatype should be NUMBER');
    end;

    [Test]
    procedure TestGetLookupDatatypeForString()
    var
        SalesLine: Record "Sales Line";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        CaseID: Guid;
        ScriptID: Guid;
        LookupID: Guid;
        DataType: Enum "Symbol Data Type";
    begin
        // [SCENARIO] To get the STRING datatype of from a Script Symbol Lookup.

        // [GIVEN] A Script Symbol Lookup is created with Source Type Current Record for Sales Line and Field ID Description.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        RecRef.Open(Database::"Sales Line");
        FieldRef := RecRef.Field(SalesLine.FieldNo(Description));
        LookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, RecRef.Number, FieldRef.Number, "Symbol Type"::"Current Record");

        // [WHEN] The function GetLookupDatatype is called.
        BindSubscription(LibraryScriptSymbolLookup);
        DataType := LookupMgmt.GetLookupDatatype(CaseID, ScriptID, LookupID);
        UnBindSubscription(LibraryScriptSymbolLookup);

        // [THEN] It should return STRING datatype.
        Assert.AreEqual("Symbol Data Type"::STRING, DataType, 'Datatype should be STRING');
    end;

    [Test]
    procedure TestGetLookupDatatypeForStringWithBlankFieldID()
    var
        LookupMgmt: Codeunit "Lookup Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        RecRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid;
        LookupID: Guid;
        DataType: Enum "Symbol Data Type";
    begin
        // [SCENARIO] To get the STRING datatype of from a Script Symbol Lookup.

        // [GIVEN] A Script Symbol Lookup is created with Source Type Current Record for Sales Line and Field ID as blank.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        RecRef.Open(Database::"Sales Line");
        LookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, RecRef.Number, 0, "Symbol Type"::"Current Record");

        // [WHEN] The function GetLookupDatatype is called.
        BindSubscription(LibraryScriptSymbolLookup);
        DataType := LookupMgmt.GetLookupDatatype(CaseID, ScriptID, LookupID);
        UnBindSubscription(LibraryScriptSymbolLookup);

        // [THEN] It should return STRING datatype.
        Assert.AreEqual("Symbol Data Type"::STRING, DataType, 'Datatype should be STRING');
    end;

    [Test]
    procedure TestGetLookupDatatypeForDate()
    var
        SalesLine: Record "Sales Line";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        CaseID: Guid;
        ScriptID: Guid;
        LookupID: Guid;
        DataType: Enum "Symbol Data Type";
    begin
        // [SCENARIO] To get the Date datatype of from a Script Symbol Lookup.

        // [GIVEN] A Script Symbol Lookup is created with Source Type Current Record for Sales Line and Field ID Description.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        RecRef.Open(Database::"Sales Line");
        FieldRef := RecRef.Field(SalesLine.FieldNo("Posting Date"));
        LookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, RecRef.Number, FieldRef.Number, "Symbol Type"::"Current Record");

        // [WHEN] The function GetLookupDatatype is called.
        BindSubscription(LibraryScriptSymbolLookup);
        DataType := LookupMgmt.GetLookupDatatype(CaseID, ScriptID, LookupID);
        UnBindSubscription(LibraryScriptSymbolLookup);

        // [THEN] It should return Date datatype.
        Assert.AreEqual("Symbol Data Type"::DATE, DataType, 'Datatype should be DATE');
    end;

    [Test]
    procedure TestGetLookupDatatypeForBoolean()
    var
        SalesLine: Record "Sales Line";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        CaseID: Guid;
        ScriptID: Guid;
        LookupID: Guid;
        DataType: Enum "Symbol Data Type";
    begin
        // [SCENARIO] To get the Date datatype of from a Script Symbol Lookup.

        // [GIVEN] A Script Symbol Lookup is created with Source Type Current Record for Sales Line and Field ID Description.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        RecRef.Open(Database::"Sales Line");
        FieldRef := RecRef.Field(SalesLine.FieldNo("Drop Shipment"));
        LookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, RecRef.Number, FieldRef.Number, "Symbol Type"::"Current Record");

        // [WHEN] The function GetLookupDatatype is called.
        BindSubscription(LibraryScriptSymbolLookup);
        DataType := LookupMgmt.GetLookupDatatype(CaseID, ScriptID, LookupID);
        UnBindSubscription(LibraryScriptSymbolLookup);

        // [THEN] It should return Date datatype.
        Assert.AreEqual("Symbol Data Type"::BOOLEAN, DataType, 'Datatype should be BOOLEAN');
    end;

    [Test]
    [HandlerFunctions('LookupToConstantHandlerForYes')]
    procedure TestConvertLookupToConstantConfirmYesForSTRING()
    var
        SalesLine: Record "Sales Line";
        SalesHeadr: Record "Sales Header";
        LookupFieldFilter: Record "Lookup Field Filter";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        CaseID, ScriptID, LookupID, EmptyGuid, TableFilterID : Guid;
        Dataype: Enum "Symbol Data Type";
        Value: Text;
        Converted: Boolean;
    begin
        // [SCENARIO] To convert a Lookup value to a constant value.

        // [GIVEN] Table filter Sales header table for field no. is created and a lookup is created for Sales Lines Document No. field and va.
        //1. Create a Table Filter record.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        RecRef.Open(Database::"Sales Header");
        FieldRef := RecRef.Field(SalesHeadr.FieldNo("No."));
        TableFilterID := LibraryScriptSymbolLookup.CreateTableFilter(CaseID, ScriptID, RecRef.Number, FieldRef.Number);
        LookupFieldFilter.Get(CaseID, ScriptID, TableFilterID, FieldRef.Number);

        Clear(RecRef);
        Clear(FieldRef);
        //2. Create a Lookup record and assign Lookup to Field Filter.
        RecRef.Open(Database::"Sales Line");
        FieldRef := RecRef.Field(SalesLine.FieldNo("Document No."));
        LookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, RecRef.Number, FieldRef.Number, "Symbol Type"::"Current Record");
        LookupFieldFilter."Value Type" := LookupFieldFilter."Value Type"::Lookup;
        LookupFieldFilter."Lookup ID" := LookupID;
        LookupFieldFilter.Modify();

        BindSubscription(LibraryScriptSymbolLookup);
        Dataype := LookupMgmt.GetLookupDatatype(CaseID, ScriptID, LookupID);
        UnBindSubscription(LibraryScriptSymbolLookup);

        // [WHEN] The function ConvertConstantToLookup is called.
        Value := 'SO-0001';
        Converted := LookupMgmt.ConvertLookupToConstant(CaseID, ScriptID, LookupFieldFilter."Value Type", LookupFieldFilter.Value, LookupID, Value, Dataype);

        if not Converted then
            Error('Lookup not converted to constant');

        // [THEN] Value type of field filter will be converted to constant and LookupID will be cleared.
        Assert.AreEqual(EmptyGuid, LookupID, 'Lookup ID should be Empty');
        Assert.AreEqual(LookupFieldFilter."Value Type"::Constant, LookupFieldFilter."Value Type", 'Lookup ID should be Empty');
        Assert.AreEqual('SO-0001', Value, 'Value should be SO-0001');
    end;

    [Test]
    [HandlerFunctions('LookupToConstantHandlerForYes')]
    procedure TestConvertLookupToConstantConfirmYesForNUMBER()
    var
        SalesLine: Record "Sales Line";
        SalesHeadr: Record "Sales Header";
        LookupFieldFilter: Record "Lookup Field Filter";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        CaseID, ScriptID, LookupID, EmptyGuid, TableFilterID : Guid;
        Dataype: Enum "Symbol Data Type";
        Value: Text[250];
        FormattedValue: Text;
        Converted: Boolean;
    begin
        // [SCENARIO] To convert a Lookup value to a constant value.

        // [GIVEN] Table filter Sales header table for field no. is created and a lookup is created for Sales Lines Document No. field and va.
        //1. Create a Table Filter record.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        RecRef.Open(Database::"Sales Header");
        FieldRef := RecRef.Field(SalesHeadr.FieldNo(Amount));
        TableFilterID := LibraryScriptSymbolLookup.CreateTableFilter(CaseID, ScriptID, RecRef.Number, FieldRef.Number);
        LookupFieldFilter.Get(CaseID, ScriptID, TableFilterID, FieldRef.Number);

        Clear(RecRef);
        Clear(FieldRef);
        //2. Create a Lookup record and assign Lookup to Field Filter.
        RecRef.Open(Database::"Sales Line");
        FieldRef := RecRef.Field(SalesLine.FieldNo(Amount));
        LookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, RecRef.Number, FieldRef.Number, "Symbol Type"::"Current Record");
        LookupFieldFilter."Value Type" := LookupFieldFilter."Value Type"::Lookup;
        LookupFieldFilter."Lookup ID" := LookupID;
        LookupFieldFilter.Modify();

        BindSubscription(LibraryScriptSymbolLookup);
        Dataype := LookupMgmt.GetLookupDatatype(CaseID, ScriptID, LookupID);
        UnBindSubscription(LibraryScriptSymbolLookup);

        // [WHEN] The function ConvertConstantToLookup is called.
        FormattedValue := '100';
        Converted := LookupMgmt.ConvertLookupToConstant(CaseID, ScriptID, LookupFieldFilter."Value Type", Value, LookupID, FormattedValue, Dataype);

        // [THEN] Value type of field filter will be converted to constant and LookupID will be cleared.
        if not Converted then
            Error('Lookup not converted to constant');

        Assert.AreEqual(EmptyGuid, LookupID, 'Lookup ID should be Empty');
        Assert.AreEqual(LookupFieldFilter."Value Type"::Constant, LookupFieldFilter."Value Type", 'Lookup ID should be Empty');
        Assert.AreEqual('100', Value, 'Value should be 100');
    end;

    [Test]
    [HandlerFunctions('LookupToConstantHandlerForYes')]
    procedure TestConvertLookupToConstantConfirmYesForBOOLEAN()
    var
        SalesLine: Record "Sales Line";
        SalesHeadr: Record "Sales Header";
        LookupFieldFilter: Record "Lookup Field Filter";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        CaseID, ScriptID, LookupID, EmptyGuid, TableFilterID : Guid;
        Dataype: Enum "Symbol Data Type";
        Value: Text[250];
        FormattedValue: Text;
        Converted: Boolean;
    begin
        // [SCENARIO] To convert a Lookup value to a constant value.

        // [GIVEN] Table filter Sales header table for field no. is created and a lookup is created for Sales Lines Document No. field and va.
        //1. Create a Table Filter record.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        RecRef.Open(Database::"Sales Header");
        FieldRef := RecRef.Field(SalesHeadr.FieldNo("Prices Including VAT"));
        TableFilterID := LibraryScriptSymbolLookup.CreateTableFilter(CaseID, ScriptID, RecRef.Number, FieldRef.Number);
        LookupFieldFilter.Get(CaseID, ScriptID, TableFilterID, FieldRef.Number);

        Clear(RecRef);
        Clear(FieldRef);
        //2. Create a Lookup record and assign Lookup to Field Filter.
        RecRef.Open(Database::"Sales Line");
        FieldRef := RecRef.Field(SalesLine.FieldNo("Drop Shipment"));
        LookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, RecRef.Number, FieldRef.Number, "Symbol Type"::"Current Record");
        LookupFieldFilter."Value Type" := LookupFieldFilter."Value Type"::Lookup;
        LookupFieldFilter."Lookup ID" := LookupID;
        LookupFieldFilter.Modify();

        BindSubscription(LibraryScriptSymbolLookup);
        Dataype := LookupMgmt.GetLookupDatatype(CaseID, ScriptID, LookupID);
        UnBindSubscription(LibraryScriptSymbolLookup);

        // [WHEN] The function ConvertConstantToLookup is called.
        FormattedValue := 'true';
        Converted := LookupMgmt.ConvertLookupToConstant(CaseID, ScriptID, LookupFieldFilter."Value Type", Value, LookupID, FormattedValue, Dataype);

        if not Converted then
            Error('Lookup not converted to constant');

        // [THEN] Value type of field filter will be converted to constant and LookupID will be cleared.
        Assert.AreEqual(EmptyGuid, LookupID, 'Lookup ID should be Empty');
        Assert.AreEqual(LookupFieldFilter."Value Type"::Constant, LookupFieldFilter."Value Type", 'Lookup ID should be Empty');
        Assert.AreEqual('true', Value, 'Value should be true');
    end;

    [Test]
    [HandlerFunctions('LookupToConstantHandlerForYes')]
    procedure TestConvertLookupToConstantConfirmYesForDATE()
    var
        SalesLine: Record "Sales Line";
        SalesHeadr: Record "Sales Header";
        LookupFieldFilter: Record "Lookup Field Filter";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        CaseID, ScriptID, LookupID, EmptyGuid, TableFilterID : Guid;
        Dataype: Enum "Symbol Data Type";
        Value: Text[250];
        FormattedValue: Text;
        Converted: Boolean;
    begin
        // [SCENARIO] To convert a Lookup value to a constant value.

        // [GIVEN] Table filter Sales header table for field no. is created and a lookup is created for Sales Lines Document No. field and va.
        //1. Create a Table Filter record.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        RecRef.Open(Database::"Sales Header");
        FieldRef := RecRef.Field(SalesHeadr.FieldNo("Posting Date"));
        TableFilterID := LibraryScriptSymbolLookup.CreateTableFilter(CaseID, ScriptID, RecRef.Number, FieldRef.Number);
        LookupFieldFilter.Get(CaseID, ScriptID, TableFilterID, FieldRef.Number);

        Clear(RecRef);
        Clear(FieldRef);
        //2. Create a Lookup record and assign Lookup to Field Filter.
        RecRef.Open(Database::"Sales Line");
        FieldRef := RecRef.Field(SalesLine.FieldNo("Posting Date"));
        LookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, RecRef.Number, FieldRef.Number, "Symbol Type"::"Current Record");
        LookupFieldFilter."Value Type" := LookupFieldFilter."Value Type"::Lookup;
        LookupFieldFilter."Lookup ID" := LookupID;
        LookupFieldFilter.Modify();

        BindSubscription(LibraryScriptSymbolLookup);
        Dataype := LookupMgmt.GetLookupDatatype(CaseID, ScriptID, LookupID);
        UnBindSubscription(LibraryScriptSymbolLookup);

        // [WHEN] The function ConvertConstantToLookup is called.
        FormattedValue := '2020-01-01';
        Converted := LookupMgmt.ConvertLookupToConstant(CaseID, ScriptID, LookupFieldFilter."Value Type", Value, LookupID, FormattedValue, Dataype);

        if not Converted then
            Error('Lookup not converted to constant');

        // [THEN] Value type of field filter will be converted to constant and LookupID will be cleared.
        Assert.AreEqual(EmptyGuid, LookupID, 'Lookup ID should be Empty');
        Assert.AreEqual(LookupFieldFilter."Value Type"::Constant, LookupFieldFilter."Value Type", 'Lookup ID should be Empty');
        Assert.AreEqual('2020-01-01', Value, 'Value should be 2020-01-01');
    end;

    [Test]
    [HandlerFunctions('LookupToConstantHandlerForYes')]
    procedure TestConvertLookupToConstantConfirmYesForGUID()
    var
        JobQueueEntry: Record "Job Queue Entry";
        SalesHeadr: Record "Sales Header";
        LookupFieldFilter: Record "Lookup Field Filter";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        CaseID, ScriptID, LookupID, EmptyGuid, TableFilterID : Guid;
        ExpectedGuid: Text;
        Dataype: Enum "Symbol Data Type";
        Value: Text[250];
        FormattedValue: Text;
        Converted: Boolean;
    begin
        // [SCENARIO] To convert a Lookup value to a constant value.

        // [GIVEN] Table filter Sales header table for field no. is created and a lookup is created for Sales Lines Document No. field and va.
        //1. Create a Table Filter record.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        RecRef.Open(Database::"Sales Header");
        FieldRef := RecRef.Field(SalesHeadr.FieldNo("Job Queue Entry ID"));
        TableFilterID := LibraryScriptSymbolLookup.CreateTableFilter(CaseID, ScriptID, RecRef.Number, FieldRef.Number);
        LookupFieldFilter.Get(CaseID, ScriptID, TableFilterID, FieldRef.Number);

        Clear(RecRef);
        Clear(FieldRef);
        //2. Create a Lookup record and assign Lookup to Field Filter.
        RecRef.Open(Database::"Job Queue Entry");
        FieldRef := RecRef.Field(JobQueueEntry.FieldNo(ID));
        LookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, RecRef.Number, FieldRef.Number, "Symbol Type"::"Current Record");
        LookupFieldFilter."Value Type" := LookupFieldFilter."Value Type"::Lookup;
        LookupFieldFilter."Lookup ID" := LookupID;
        LookupFieldFilter.Modify();

        BindSubscription(LibraryScriptSymbolLookup);
        Dataype := LookupMgmt.GetLookupDatatype(CaseID, ScriptID, LookupID);
        UnBindSubscription(LibraryScriptSymbolLookup);

        // [WHEN] The function ConvertConstantToLookup is called.
        ExpectedGuid := Format(CreateGuid());
        FormattedValue := ExpectedGuid;
        Converted := LookupMgmt.ConvertLookupToConstant(CaseID, ScriptID, LookupFieldFilter."Value Type", Value, LookupID, FormattedValue, Dataype);
        Value := Format(Value);

        if not Converted then
            Error('Lookup not converted to constant');

        // [THEN] Value type of field filter will be converted to constant and LookupID will be cleared.
        Assert.AreEqual(EmptyGuid, LookupID, 'Lookup ID should be Empty');
        Assert.AreEqual(LookupFieldFilter."Value Type"::Constant, LookupFieldFilter."Value Type", 'Lookup ID should be Empty');
        Assert.AreEqual(ExpectedGuid, Value, StrSubstNo(ValueLbl, ExpectedGuid));
    end;

    [Test]
    [HandlerFunctions('LookupToConstantHandlerForYes')]
    procedure TestConvertLookupToConstantConfirmYesForTIME()
    var
        ChangeLogEntry: Record "Change Log Entry";
        JobQueueEntry: Record "Job Queue Entry";
        LookupFieldFilter: Record "Lookup Field Filter";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        ExpectedTime: Text[250];
        CaseID, ScriptID, LookupID, EmptyGuid, TableFilterID : Guid;
        Dataype: Enum "Symbol Data Type";
        Value: Text[250];
        FormattedValue: Text;
        Converted: Boolean;
    begin
        // [SCENARIO] To convert a Lookup value to a constant value.

        // [GIVEN] Table filter Sales header table for field no. is created and a lookup is created for Sales Lines Document No. field and va.
        //1. Create a Table Filter record.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        RecRef.Open(Database::"Job Queue Entry");
        FieldRef := RecRef.Field(JobQueueEntry.FieldNo("Starting Time"));
        TableFilterID := LibraryScriptSymbolLookup.CreateTableFilter(CaseID, ScriptID, RecRef.Number, FieldRef.Number);
        LookupFieldFilter.Get(CaseID, ScriptID, TableFilterID, FieldRef.Number);

        Clear(RecRef);
        Clear(FieldRef);
        //2. Create a Lookup record and assign Lookup to Field Filter.
        RecRef.Open(Database::"Change Log Entry");
        FieldRef := RecRef.Field(ChangeLogEntry.FieldNo(Time));
        LookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, RecRef.Number, FieldRef.Number, "Symbol Type"::"Current Record");
        LookupFieldFilter."Value Type" := LookupFieldFilter."Value Type"::Lookup;
        LookupFieldFilter."Lookup ID" := LookupID;
        LookupFieldFilter.Modify();

        BindSubscription(LibraryScriptSymbolLookup);
        Dataype := LookupMgmt.GetLookupDatatype(CaseID, ScriptID, LookupID);
        UnBindSubscription(LibraryScriptSymbolLookup);

        // [WHEN] The function ConvertConstantToLookup is called.
        ExpectedTime := format(Time, 0, 9);
        FormattedValue := ExpectedTime;
        Converted := LookupMgmt.ConvertLookupToConstant(CaseID, ScriptID, LookupFieldFilter."Value Type", Value, LookupID, FormattedValue, Dataype);

        // [THEN] Value type of field filter will be converted to constant and LookupID will be cleared.
        if not Converted then
            Error('Lookup not converted to constant');

        Assert.AreEqual(EmptyGuid, LookupID, 'Lookup ID should be Empty');
        Assert.AreEqual(LookupFieldFilter."Value Type"::Constant, LookupFieldFilter."Value Type", 'Lookup ID should be Empty');
        Assert.AreEqual(ExpectedTime, Value, StrSubstNo(ValueLbl, ExpectedTime));
    end;

    [Test]
    [HandlerFunctions('LookupToConstantHandlerForYes')]
    procedure TestConvertLookupToConstantConfirmYesForDATETIME()
    var
        ChangeLogEntry: Record "Change Log Entry";
        JobQueueEntry: Record "Job Queue Entry";
        LookupFieldFilter: Record "Lookup Field Filter";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        ExpectedDateTime: Text[250];
        CaseID, ScriptID, LookupID, TableFilterID, EmptyGuid : Guid;
        Dataype: Enum "Symbol Data Type";
        CurrDateTime: DateTime;
        Value: Text[250];
        FormattedValue: Text;
        Converted: Boolean;
    begin
        // [SCENARIO] To convert a Lookup value to a constant value.

        // [GIVEN] Table filter Sales header table for field no. is created and a lookup is created for Sales Lines Document No. field and va.
        //1. Create a Table Filter record.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        RecRef.Open(Database::"Job Queue Entry");
        FieldRef := RecRef.Field(JobQueueEntry.FieldNo("Last Ready State"));
        TableFilterID := LibraryScriptSymbolLookup.CreateTableFilter(CaseID, ScriptID, RecRef.Number, FieldRef.Number);
        LookupFieldFilter.Get(CaseID, ScriptID, TableFilterID, FieldRef.Number);

        Clear(RecRef);
        Clear(FieldRef);
        //2. Create a Lookup record and assign Lookup to Field Filter.
        RecRef.Open(Database::"Change Log Entry");
        FieldRef := RecRef.Field(ChangeLogEntry.FieldNo("Date and Time"));
        LookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, RecRef.Number, FieldRef.Number, "Symbol Type"::"Current Record");
        LookupFieldFilter."Value Type" := LookupFieldFilter."Value Type"::Lookup;
        LookupFieldFilter."Lookup ID" := LookupID;
        LookupFieldFilter.Modify();

        BindSubscription(LibraryScriptSymbolLookup);
        Dataype := LookupMgmt.GetLookupDatatype(CaseID, ScriptID, LookupID);
        UnBindSubscription(LibraryScriptSymbolLookup);

        // [WHEN] The function ConvertConstantToLookup is called.
        evaluate(CurrDateTime, '2020-06-25T04:53:00Z', 9);
        ExpectedDateTime := format(CurrDateTime, 0, 9);
        FormattedValue := format(CurrDateTime);
        Converted := LookupMgmt.ConvertLookupToConstant(CaseID, ScriptID, LookupFieldFilter."Value Type", Value, LookupID, FormattedValue, Dataype);

        // [THEN] Value type of field filter will be converted to constant and LookupID will be cleared.
        Assert.IsTrue(Converted, 'Lookup not converted to constant');
        Assert.AreEqual(EmptyGuid, LookupID, 'Lookup ID should be Empty');
        Assert.AreEqual(LookupFieldFilter."Value Type"::Constant, LookupFieldFilter."Value Type", 'Lookup ID should be Empty');
        Assert.AreEqual(ExpectedDateTime, Value, StrSubstNo(ValueLbl, ExpectedDateTime));
    end;

    [Test]
    [HandlerFunctions('LookupToConstantHandlerForNo')]
    procedure TestConvertLookupToConstantConfirmNo()
    var
        SalesLine: Record "Sales Line";
        SalesHeadr: Record "Sales Header";
        LookupFieldFilter: Record "Lookup Field Filter";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        CaseID, ScriptID, LookupID, TableFilterID, EmptyGuid : Guid;
        Dataype: Enum "Symbol Data Type";
        FormattedValue: Text;
        Converted: Boolean;
    begin
        // [SCENARIO] To convert a Lookup value to a constant value.

        // [GIVEN] Table filter Sales header table for field no. is created and a lookup is created for Sales Lines Document No. field and va.
        //1. Create a Table Filter record.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        RecRef.Open(Database::"Sales Header");
        FieldRef := RecRef.Field(SalesHeadr.FieldNo("No."));
        TableFilterID := LibraryScriptSymbolLookup.CreateTableFilter(CaseID, ScriptID, RecRef.Number, FieldRef.Number);
        LookupFieldFilter.Get(CaseID, ScriptID, TableFilterID, FieldRef.Number);

        Clear(RecRef);
        Clear(FieldRef);


        //2. Create a Lookup record and assign Lookup to Field Filter.
        RecRef.Open(Database::"Sales Line");
        FieldRef := RecRef.Field(SalesLine.FieldNo("Document No."));
        LookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, RecRef.Number, FieldRef.Number, "Symbol Type"::"Current Record");
        LookupFieldFilter."Value Type" := LookupFieldFilter."Value Type"::Lookup;
        LookupFieldFilter."Lookup ID" := LookupID;
        LookupFieldFilter.Modify();

        BindSubscription(LibraryScriptSymbolLookup);
        Dataype := LookupMgmt.GetLookupDatatype(CaseID, ScriptID, LookupID);
        UnBindSubscription(LibraryScriptSymbolLookup);

        // [WHEN] The function ConvertConstantToLookup is called.
        Converted := LookupMgmt.ConvertLookupToConstant(CaseID, ScriptID, LookupFieldFilter."Value Type", LookupFieldFilter.Value, LookupID, FormattedValue, Dataype);

        // [THEN] Value type of field filter will be converted to constant and LookupID will be cleared.
        Assert.AreNotEqual(EmptyGuid, LookupID, 'Lookup ID should not be Empty');
        Assert.AreEqual(LookupFieldFilter."Value Type"::Lookup, LookupFieldFilter."Value Type", 'Value type should be Lookup');
    end;

    [Test]
    [HandlerFunctions('LookupToConstantHandlerForYes')]
    procedure TestConvertConstantToLookupConfirmYes()
    var
        SalesHeadr: Record "Sales Header";
        LookupFieldFilter: Record "Lookup Field Filter";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        CaseID, ScriptID, LookupID, TableFilterID, EmptyGuid : Guid;
    begin
        // [SCENARIO] To convert a constant value to a Lookup value.

        // [GIVEN] Table filter Sales header table for field no. is created and filter is assigned for 'SO-0001'.
        //1. Create a Table Filter record.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        RecRef.Open(Database::"Sales Header");
        FieldRef := RecRef.Field(SalesHeadr.FieldNo("No."));
        TableFilterID := LibraryScriptSymbolLookup.CreateTableFilter(CaseID, ScriptID, RecRef.Number, FieldRef.Number);
        LookupFieldFilter.Get(CaseID, ScriptID, TableFilterID, FieldRef.Number);
        LookupFieldFilter."Value Type" := LookupFieldFilter."Value Type"::Constant;
        LookupFieldFilter.Value := 'SO-0001';
        LookupFieldFilter.Modify();

        // [WHEN] The function ConvertConstantToLookup is called.
        LookupMgmt.ConvertConstantToLookup(CaseID, ScriptID, LookupFieldFilter."Value Type", LookupFieldFilter.Value, LookupID);

        // [THEN] Value type of field filter will be converted to Lookup and Value will be cleared.
        Assert.AreNotEqual(EmptyGuid, LookupID, 'Lookup ID should not be Empty');
        Assert.AreEqual(LookupFieldFilter."Value Type"::Lookup, LookupFieldFilter."Value Type", 'Lookup ID should be Empty');
        Assert.AreEqual('', LookupFieldFilter.Value, 'Value should be blank');
    end;

    [Test]
    [HandlerFunctions('LookupToConstantHandlerForNo')]
    procedure TestConvertConstantToLookupConfirmNo()
    var
        SalesHeadr: Record "Sales Header";
        LookupFieldFilter: Record "Lookup Field Filter";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        CaseID, ScriptID, TableFilterID, EmptyGuid : Guid;
    begin
        // [SCENARIO] To convert a constant value to a Lookup value.

        // [GIVEN] Table filter Sales header table for field no. is created and filter is assigned for 'SO-0001'.
        //1. Create a Table Filter record.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        RecRef.Open(Database::"Sales Header");
        FieldRef := RecRef.Field(SalesHeadr.FieldNo("No."));
        TableFilterID := LibraryScriptSymbolLookup.CreateTableFilter(CaseID, ScriptID, RecRef.Number, FieldRef.Number);
        LookupFieldFilter.Get(CaseID, ScriptID, TableFilterID, FieldRef.Number);
        LookupFieldFilter."Value Type" := LookupFieldFilter."Value Type"::Constant;
        LookupFieldFilter.Value := 'SO-0001';
        LookupFieldFilter.Modify();

        // [WHEN] The function ConvertConstantToLookup is called.
        LookupMgmt.ConvertConstantToLookup(CaseID, ScriptID, LookupFieldFilter."Value Type", LookupFieldFilter.Value, LookupFieldFilter."Lookup ID");

        // [THEN] Value type of field filter will be converted to Lookup and Value will be cleared.
        Assert.AreEqual(EmptyGuid, LookupFieldFilter."Lookup ID", 'Lookup ID should be Empty');
        Assert.AreEqual(LookupFieldFilter."Value Type"::Constant, LookupFieldFilter."Value Type", 'Value type should be constant');
        Assert.AreEqual('SO-0001', LookupFieldFilter.Value, 'Value should be SO-0001');
    end;

    [Test]
    [HandlerFunctions('LookupDialogPageHandler')]
    procedure TestOpenLookupDialogOfType()
    var
        SalesHeadr: Record "Sales Header";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        CaseID: Guid;
        ScriptID: Guid;
        LookupID: Guid;
    begin
        // [SCENARIO] To check if Lookup dialog is opened for datatype STRING.

        // [GIVEN] Lookup for source type "Current Record" with table Sales Header is created.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        RecRef.Open(Database::"Sales Header");
        FieldRef := RecRef.Field(SalesHeadr.FieldNo("No."));
        LookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, RecRef.Number, FieldRef.Number, "Symbol Type"::"Current Record");

        // [WHEN] The function OpenLookupDialogOfType is called.
        BindSubscription(LibraryScriptSymbolLookup);
        LookupMgmt.OpenLookupDialogOfType(CaseID, ScriptID, LookupID, "Symbol Data type"::STRING);
        UnBindSubscription(LibraryScriptSymbolLookup);
        // [THEN] Lookup dialog will be opened.
    end;

    [Test]
    [HandlerFunctions('LookupDialogPageHandler')]
    procedure TestOpenLookupDialog()
    var
        SalesHeadr: Record "Sales Header";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        CaseID, ScriptID, LookupID : Guid;
    begin
        // [SCENARIO] To check if Lookup dialog is opened.

        // [GIVEN] Lookup for source type "Current Record" with table Sales line is created.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        RecRef.Open(Database::"Sales Header");
        FieldRef := RecRef.Field(SalesHeadr.FieldNo("No."));
        LookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, RecRef.Number, FieldRef.Number, "Symbol Type"::"Current Record");

        // [WHEN] The function OpenLookupDialog is called.
        BindSubscription(LibraryScriptSymbolLookup);
        LookupMgmt.OpenLookupDialog(CaseID, ScriptID, LookupID);
        UnBindSubscription(LibraryScriptSymbolLookup);
        // [THEN] Lookup dialog will be opened.
    end;

    [ConfirmHandler]
    procedure LookupToConstantHandlerForYes(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [ConfirmHandler]
    procedure LookupToConstantHandlerForNo(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := false;
    end;

    [ModalPageHandler]
    procedure LookupDialogPageHandler(var ScriptSymbolLookupDialog: TestPage "Script Symbol Lookup Dialog")
    begin
        ScriptSymbolLookupDialog.OK().Invoke();
    end;
}