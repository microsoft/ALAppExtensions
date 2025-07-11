codeunit 136752 "Condition Mgmt Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;
    trigger OnRun()
    begin
        // [FEATURE] [TaxEngine] [Condition Mgmt] [UT]
    end;

    var
        Assert: Codeunit Assert;

    [Test]
    [HandlerFunctions('ConditionDialogHndlr')]
    procedure TestOpenConditionsDialog()
    var
        ConditionMgmt: Codeunit "Condition Mgmt.";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ConditionID : Guid;
    begin
        // [SCENARIO] To check if the condition dialog is opened.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        // [WHEN] The function OpenConditionsDialog is called.
        ConditionID := ScriptEntityMgmt.CreateCondition(CaseID, ScriptID);
        ConditionMgmt.OpenConditionsDialog(CaseID, ScriptID, ConditionID);
        // [THEN] it should open Condition dialog page for CaseID and ScriptID.
    end;

    [Test]
    procedure TestCheckConditionForStringEqual()
    var
        SalesLine: Record "Sales Line";
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        ConditionMgmt: Codeunit "Condition Mgmt.";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        SymbolStore: Codeunit "Script Symbol Store";
        RecRef: RecordRef;
        CaseID, ScriptID, ConditionID, LHSLookupID, RHSLookupID : Guid;
        Result: Boolean;
    begin
        // [SCENARIO] To check if the condition dialog is opened.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        SalesLine.FindFirst();
        RecRef.GetTable(SalesLine);

        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        LHSLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, Database::"Sales Line", SalesLine.FieldNo("Document No."), "Symbol Type"::"Current Record");
        RHSLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, Database::"Sales Line", SalesLine.FieldNo("Document No."), "Symbol Type"::"Current Record", ScriptSymbolLookup."Table Method"::First);
        ConditionID := ScriptEntityMgmt.CreateCondition(CaseID, ScriptID);

        LibraryScriptTests.CreateConditionItem(CaseID, ScriptID, ConditionID, LHSLookupID, RHSLookupID, "Conditional Operator"::Equals);

        // [WHEN] The function OpenConditionsDialog is called.
        BindSubscription(LibraryScriptSymbolLookup);
        Result := ConditionMgmt.CheckCondition(SymbolStore, RecRef, CaseID, ScriptID, ConditionID);
        unBindSubscription(LibraryScriptSymbolLookup);

        // [THEN] it should Condition dialog page for CaseID and ScriptID.
        Assert.AreEqual(true, Result, 'Result should be true');
    end;

    [Test]
    procedure TestCheckConditionForStringNotEqual()
    var
        SalesLine: Record "Sales Line";
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        ConditionMgmt: Codeunit "Condition Mgmt.";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        SymbolStore: Codeunit "Script Symbol Store";
        RecRef: RecordRef;
        CaseID, ScriptID, ConditionID, LHSLookupID, RHSLookupID : Guid;
        Result: Boolean;
    begin
        // [SCENARIO] To check if the condition dialog is opened.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        SalesLine.FindFirst();
        RecRef.GetTable(SalesLine);

        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        LHSLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, Database::"Sales Line", SalesLine.FieldNo("Document No."), "Symbol Type"::"Current Record");
        RHSLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, Database::Customer, SalesLine.FieldNo("No."), "Symbol Type"::"Current Record", ScriptSymbolLookup."Table Method"::First);
        ConditionID := ScriptEntityMgmt.CreateCondition(CaseID, ScriptID);

        LibraryScriptTests.CreateConditionItem(CaseID, ScriptID, ConditionID, LHSLookupID, RHSLookupID, "Conditional Operator"::"Not Equals");

        // [WHEN] The function OpenConditionsDialog is called.
        BindSubscription(LibraryScriptSymbolLookup);
        Result := ConditionMgmt.CheckCondition(SymbolStore, RecRef, CaseID, ScriptID, ConditionID);
        unBindSubscription(LibraryScriptSymbolLookup);

        // [THEN] it should Condition dialog page for CaseID and ScriptID.
        Assert.AreEqual(true, Result, 'Result should be true');
    end;

    [Test]
    procedure TestCheckConditionForStringBeginWith()
    var
        SalesLine: Record "Sales Line";
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        ConditionMgmt: Codeunit "Condition Mgmt.";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        SymbolStore: Codeunit "Script Symbol Store";
        RecRef: RecordRef;
        CaseID, ScriptID, ConditionID, LHSLookupID, RHSLookupID : Guid;
        Result: Boolean;
    begin
        // [SCENARIO] To check if the condition dialog is opened.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        SalesLine.FindFirst();
        RecRef.GetTable(SalesLine);

        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        LHSLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, Database::"Sales Line", SalesLine.FieldNo("Document No."), "Symbol Type"::"Current Record");
        RHSLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, Database::Customer, SalesLine.FieldNo("No."), "Symbol Type"::"Current Record", ScriptSymbolLookup."Table Method"::First);
        ConditionID := ScriptEntityMgmt.CreateCondition(CaseID, ScriptID);

        LibraryScriptTests.CreateConditionItemConstant(CaseID, ScriptID, ConditionID, LHSLookupID, '1', "Conditional Operator"::"Begins With");

        // [WHEN] The function OpenConditionsDialog is called.
        BindSubscription(LibraryScriptSymbolLookup);
        Result := ConditionMgmt.CheckCondition(SymbolStore, RecRef, CaseID, ScriptID, ConditionID);
        unBindSubscription(LibraryScriptSymbolLookup);

        // [THEN] it should Condition dialog page for CaseID and ScriptID.
        Assert.AreEqual(true, Result, 'Result should be true');
    end;

    [Test]
    procedure TestCheckConditionForDecimal()
    var
        SalesLine: Record "Sales Line";
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        ConditionMgmt: Codeunit "Condition Mgmt.";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        SymbolStore: Codeunit "Script Symbol Store";
        RecRef: RecordRef;
        CaseID, ScriptID, ConditionID, LHSLookupID, RHSLookupID : Guid;
        Result: Boolean;
    begin
        // [SCENARIO] To check if the condition dialog is opened.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        SalesLine.FindFirst();
        RecRef.GetTable(SalesLine);

        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        LHSLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, Database::"Sales Line", SalesLine.FieldNo(Amount), "Symbol Type"::"Current Record");
        RHSLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, Database::"Sales Line", SalesLine.FieldNo(Amount), "Symbol Type"::"Current Record", ScriptSymbolLookup."Table Method"::First);
        ConditionID := ScriptEntityMgmt.CreateCondition(CaseID, ScriptID);

        LibraryScriptTests.CreateConditionItem(CaseID, ScriptID, ConditionID, LHSLookupID, RHSLookupID, "Conditional Operator"::Equals);

        // [WHEN] The function OpenConditionsDialog is called.
        BindSubscription(LibraryScriptSymbolLookup);
        Result := ConditionMgmt.CheckCondition(SymbolStore, RecRef, CaseID, ScriptID, ConditionID);
        unBindSubscription(LibraryScriptSymbolLookup);

        // [THEN] it should Condition dialog page for CaseID and ScriptID.
        Assert.AreEqual(true, Result, 'Result should be true');
    end;

    [Test]
    procedure TestCheckConditionForBoolean()
    var
        SalesLine: Record "Sales Line";
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        ConditionMgmt: Codeunit "Condition Mgmt.";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        SymbolStore: Codeunit "Script Symbol Store";
        RecRef: RecordRef;
        CaseID, ScriptID, ConditionID, LHSLookupID, RHSLookupID : Guid;
        Result: Boolean;
    begin
        // [SCENARIO] To check if the condition dialog is opened.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        SalesLine.FindFirst();
        RecRef.GetTable(SalesLine);

        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        LHSLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, Database::"Sales Line", SalesLine.FieldNo("Allow Invoice Disc."), "Symbol Type"::"Current Record");
        RHSLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, Database::"Sales Line", SalesLine.FieldNo("Allow Invoice Disc."), "Symbol Type"::"Current Record", ScriptSymbolLookup."Table Method"::First);
        ConditionID := ScriptEntityMgmt.CreateCondition(CaseID, ScriptID);

        LibraryScriptTests.CreateConditionItem(CaseID, ScriptID, ConditionID, LHSLookupID, RHSLookupID, "Conditional Operator"::Equals);

        // [WHEN] The function OpenConditionsDialog is called.
        BindSubscription(LibraryScriptSymbolLookup);
        Result := ConditionMgmt.CheckCondition(SymbolStore, RecRef, CaseID, ScriptID, ConditionID);
        unBindSubscription(LibraryScriptSymbolLookup);

        // [THEN] it should Condition dialog page for CaseID and ScriptID.
        Assert.AreEqual(true, Result, 'Result should be true');
    end;

    [Test]
    procedure TestCheckConditionForOption()
    var
        SalesHeader: Record "Sales Header";
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        ConditionMgmt: Codeunit "Condition Mgmt.";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        SymbolStore: Codeunit "Script Symbol Store";
        RecRef: RecordRef;
        CaseID, ScriptID, ConditionID, LHSLookupID, RHSLookupID : Guid;
        Result: Boolean;
    begin
        // [SCENARIO] To check if the condition dialog is opened.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        SalesHeader.FindFirst();
        RecRef.GetTable(SalesHeader);

        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        LHSLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, Database::"Sales Header", SalesHeader.FieldNo(Status), "Symbol Type"::"Current Record");
        RHSLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, Database::"Sales Header", SalesHeader.FieldNo(Status), "Symbol Type"::"Current Record", ScriptSymbolLookup."Table Method"::First);
        ConditionID := ScriptEntityMgmt.CreateCondition(CaseID, ScriptID);

        LibraryScriptTests.CreateConditionItem(CaseID, ScriptID, ConditionID, LHSLookupID, RHSLookupID, "Conditional Operator"::Equals);

        // [WHEN] The function OpenConditionsDialog is called.
        BindSubscription(LibraryScriptSymbolLookup);
        Result := ConditionMgmt.CheckCondition(SymbolStore, RecRef, CaseID, ScriptID, ConditionID);
        unBindSubscription(LibraryScriptSymbolLookup);

        // [THEN] it should Condition dialog page for CaseID and ScriptID.
        Assert.AreEqual(true, Result, 'Result should be true');
    end;

    [Test]
    procedure TestCheckConditionForDate()
    var
        SalesHeader: Record "Sales Header";
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        ConditionMgmt: Codeunit "Condition Mgmt.";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        SymbolStore: Codeunit "Script Symbol Store";
        RecRef: RecordRef;
        CaseID, ScriptID, ConditionID, LHSLookupID, RHSLookupID : Guid;
        Result: Boolean;
    begin
        // [SCENARIO] To check if the condition dialog is opened.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        SalesHeader.FindFirst();
        RecRef.GetTable(SalesHeader);

        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        LHSLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, Database::"Sales Header", SalesHeader.FieldNo("Posting Date"), "Symbol Type"::"Current Record");
        RHSLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, Database::"Sales Header", SalesHeader.FieldNo("Posting Date"), "Symbol Type"::"Current Record", ScriptSymbolLookup."Table Method"::First);
        ConditionID := ScriptEntityMgmt.CreateCondition(CaseID, ScriptID);

        LibraryScriptTests.CreateConditionItem(CaseID, ScriptID, ConditionID, LHSLookupID, RHSLookupID, "Conditional Operator"::Equals);

        // [WHEN] The function OpenConditionsDialog is called.
        BindSubscription(LibraryScriptSymbolLookup);
        Result := ConditionMgmt.CheckCondition(SymbolStore, RecRef, CaseID, ScriptID, ConditionID);
        unBindSubscription(LibraryScriptSymbolLookup);

        // [THEN] it should Condition dialog page for CaseID and ScriptID.
        Assert.AreEqual(true, Result, 'Result should be true');
    end;

    [Test]
    procedure TestCalculateVariantForError()
    var
        ConditionMgmt: Codeunit "Condition Mgmt.";
        LHSText, RHSText : Text;
        Output: Variant;
    begin
        // [SCENARIO] To check if system is throwing error if invalid LHS and RHS values are passed.

        // [GIVEN] There should be a 2 text variable to pass in function.
        LHSText := 'LHSText';
        RHSText := 'RHSText';

        // [WHEN] The function CalculateVariants is called.
        asserterror ConditionMgmt.CalculateVariants(LHSText, RHSText, "Arithmetic Operator"::Plus, Output);

        // [THEN] it should return error message.
        Assert.AreEqual('Invalid datatype for calculation.', GetLastErrorText, 'Error message should be : Invalid datatype for calculation.');
    end;

    [Test]
    procedure TestCalculateVariantForNumber()
    var
        ConditionMgmt: Codeunit "Condition Mgmt.";
        LHSDecimal, RHSDecimal : decimal;
        Output: Variant;
    begin
        // [SCENARIO] To check if system sum of LHS and RHS value.

        // [GIVEN] There should be a 2 decimal variable to pass in function.
        LHSDecimal := 100;
        RHSDecimal := 100;

        // [WHEN] The function CalculateVariants is called.
        ConditionMgmt.CalculateVariants(LHSDecimal, RHSDecimal, "Arithmetic Operator"::Plus, Output);

        // [THEN] it should return 200 as sum.
        Assert.AreEqual(200, Output, 'Outpur should be 200');
    end;

    [Test]
    procedure TestCalculateVariantForString()
    var
        ConditionMgmt: Codeunit "Condition Mgmt.";
        LHSDecimal, RHSDecimal : decimal;
        Output: Variant;
    begin
        // [SCENARIO] To check if system sum of LHS and RHS value.

        // [GIVEN] There should be a 2 decimal variable to pass in function.
        LHSDecimal := 100;
        RHSDecimal := 100;

        // [WHEN] The function CalculateVariants is called.
        ConditionMgmt.CalculateVariants(LHSDecimal, RHSDecimal, "Arithmetic Operator"::Plus, Output);

        // [THEN] it should return 200 as sum.
        Assert.AreEqual(200, Output, 'Outpur should be 200');
    end;

    [ModalPageHandler]
    procedure ConditionDialogHndlr(var ConditionDialog: TestPage "Conditions Dialog")
    begin
        ConditionDialog.OK().Invoke();
    end;
}