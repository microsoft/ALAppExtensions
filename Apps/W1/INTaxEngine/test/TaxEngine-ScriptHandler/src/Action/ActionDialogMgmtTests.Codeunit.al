codeunit 136751 "Action Dialog Mgmt. Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    trigger OnRun()
    begin
        // [FEATURE] [TaxEngine] [Action Dialog Mgmt] [UT]
    end;

    var
        Assert: Codeunit Assert;

    [Test]
    [HandlerFunctions('ActionSetVariableDialogHandler')]
    procedure TestOpenSetVariableDialog()
    var
        ActionSetVariable: Record "Action Set Variable";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        ActionDialogMgmt: Codeunit "Action Dialog Mgmt.";
        VariableID: Integer;
        CaseID, ScriptID, ActionID : Guid;
    begin
        // [SCENARIO] Open Set Variable Dialog via OpenActionAssistEdit function.

        // [GIVEN] Case ID, Script ID, Action Type - SetVariable, ActionID - ActionSetVariable's ID
        VariableID := 1;
        BindSubscription(LibraryScriptTests);
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, VariableID, 'Message', "Symbol Data Type"::STRING);
        LibraryScriptTests.CreateSetVariable(CaseID, ScriptID, ActionID);

        // [WHEN] The function OpenActionAssistEdit is called.
        ActionDialogMgmt.OpenActionAssistEdit(CaseID, ScriptID, "Action Type"::SETVARIABLE, ActionID, "Action Group Type"::" ");
        UnBindSubscription(LibraryScriptTests);

        // [THEN] it should open Set Variable Dialog, and select Variable ID - i, Value - Hello
        ActionSetVariable.Get(CaseID, ScriptID, ActionID);
        Assert.AreEqual(ActionSetVariable."Variable ID", VariableID, 'Variable ID 1 expected');
        Assert.AreEqual(ActionSetVariable.Value, 'Hello', 'Value Hello expected.');
    end;

    [Test]
    [HandlerFunctions('ConditionDialogHandler')]
    procedure TestOpenIfConditionDialog()
    var
        ActionIfStatement: Record "Action If Statement";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        ActionDialogMgmt: Codeunit "Action Dialog Mgmt.";
        VariableID: Integer;
        CaseID, ScriptID, ActionID : Guid;
        EmptyGuid: Guid;
    begin
        // [SCENARIO] Open If Condition Dialog via OpenActionAssistEdit function.

        // [GIVEN] Case ID, Script ID, Action Type - IfCondition, ActionID - ActionIfCondition's ID
        VariableID := 1;
        BindSubscription(LibraryScriptTests);
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, VariableID, 'Message', "Symbol Data Type"::STRING);
        LibraryScriptTests.CreateIfCondition(CaseID, ScriptID, ActionID);

        // [WHEN] The function OpenActionAssistEdit is called.
        ActionDialogMgmt.OpenActionAssistEdit(CaseID, ScriptID, "Action Type"::IFSTATEMENT, ActionID, "Action Group Type"::" ");
        UnBindSubscription(LibraryScriptTests);

        // [THEN] it should open If Condition Dialog
        ActionIfStatement.Get(CaseID, ScriptID, ActionID);
        Assert.AreNotEqual(EmptyGuid, ActionIfStatement."Condition ID", 'Condition ID should not be empty');
    end;

    [Test]
    [HandlerFunctions('ActionLoopNTimesDialogHandler')]
    procedure TestOpenLoopNTimesDialog()
    var
        ActionLoopNTimes: Record "Action Loop N Times";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        ActionDialogMgmt: Codeunit "Action Dialog Mgmt.";
        CaseID, ScriptID, ActionID : Guid;
    begin
        // [SCENARIO] Open Loop N Times Dialog via OpenActionAssistEdit function.

        // [GIVEN] Case ID, Script ID, Action Type - LoopNTimes, ActionID - ActionLookNTime's ID
        BindSubscription(LibraryScriptTests);
        LibraryScriptTests.CreateLoopNTimes(CaseID, ScriptID, ActionID);

        // [WHEN] The function OpenActionAssistEdit is called.
        ActionDialogMgmt.OpenActionAssistEdit(CaseID, ScriptID, "Action Type"::LOOPNTIMES, ActionID, "Action Group Type"::"Loop N Times");
        UnBindSubscription(LibraryScriptTests);

        // [THEN] it should open Loop N Time Dialog
        ActionLoopNTimes.Get(CaseID, ScriptID, ActionID);
        Assert.AreEqual('5', ActionLoopNTimes.Value, 'Value should be 5');
    end;

    [Test]
    [HandlerFunctions('ConditionDialogHandler')]
    procedure TestOpenLoopWithConditionDialog()
    var
        ActionLoopWithCondition: Record "Action Loop With Condition";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        ActionDialogMgmt: Codeunit "Action Dialog Mgmt.";
        CaseID, ScriptID, ActionID : Guid;
        EmptyGuid: Guid;
    begin
        // [SCENARIO] Open Loop With Condition Dialog via OpenActionAssistEdit function.

        // [GIVEN] Case ID, Script ID, Action Type - LoopWithCondtion, ActionID - ActionLookWithCondition's ID
        BindSubscription(LibraryScriptTests);
        LibraryScriptTests.CreateLoopWithCondition(CaseID, ScriptID, ActionID);

        // [WHEN] The function OpenActionAssistEdit is called.
        ActionDialogMgmt.OpenActionAssistEdit(CaseID, ScriptID, "Action Type"::LOOPWITHCONDITION, ActionID, "Action Group Type"::"Loop with Condition");
        UnBindSubscription(LibraryScriptTests);

        // [THEN] it should open Loop With Condtion Dialog
        ActionLoopWithCondition.Get(CaseID, ScriptID, ActionID);
        Assert.AreNotEqual(EmptyGuid, ActionLoopWithCondition."Condition ID", 'Condtion ID should not be empty');
    end;

    [Test]
    [HandlerFunctions('ActionNumberCalcDialogHandler')]
    procedure TestOpenNumberCalculationDialog()
    var
        ActionNumberCalculation: Record "Action Number Calculation";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        ActionDialogMgmt: Codeunit "Action Dialog Mgmt.";
        VariableID: Integer;
        CaseID, ScriptID, ActionID : Guid;
    begin
        // [SCENARIO] Open Loop With Condition Dialog via OpenActionAssistEdit function.

        // [GIVEN] Case ID, Script ID, Action Type - Number Calculation, ActionID - ActionNumberCalculation's ID
        BindSubscription(LibraryScriptTests);
        VariableID := 1;
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, VariableID, 'Output Variable', "Symbol Data Type"::NUMBER);
        LibraryScriptTests.CreateNumberCalculation(CaseID, ScriptID, ActionID);

        // [WHEN] The function OpenActionAssistEdit is called.
        ActionDialogMgmt.OpenActionAssistEdit(CaseID, ScriptID, "Action Type"::NUMBERCALCULATION, ActionID, "Action Group Type"::" ");
        UnBindSubscription(LibraryScriptTests);

        // [THEN] it should open Action Number Calculation Dialog
        ActionNumberCalculation.Get(CaseID, ScriptID, ActionID);
        Assert.AreEqual(VariableID, ActionNumberCalculation."Variable ID", 'Variable ID should be 1');
    end;

    [Test]
    [HandlerFunctions('ActionConcatenateDialogHandler')]
    procedure TestOpenConcatenateDialog()
    var
        ActionConcatenate: Record "Action Concatenate";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        ActionDialogMgmt: Codeunit "Action Dialog Mgmt.";
        VariableID: Integer;
        CaseID, ScriptID, ActionID : Guid;
    begin
        // [SCENARIO] Open Concatenate Dialog via OpenActionAssistEdit function.

        // [GIVEN] Case ID, Script ID, Action Type - Concatenate, ActionID - ActionConcatenate's ID
        BindSubscription(LibraryScriptTests);
        VariableID := 1;
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, VariableID, 'Output Variable', "Symbol Data Type"::STRING);
        LibraryScriptTests.CreateConcatenate(CaseID, ScriptID, ActionID);

        // [WHEN] The function OpenActionAssistEdit is called.
        ActionDialogMgmt.OpenActionAssistEdit(CaseID, ScriptID, "Action Type"::CONCATENATE, ActionID, "Action Group Type"::" ");
        UnBindSubscription(LibraryScriptTests);

        // [THEN] it should open Concatenate Dialog
        ActionConcatenate.Get(CaseID, ScriptID, ActionID);
        Assert.AreEqual(VariableID, ActionConcatenate."Variable ID", 'Variable ID should be 1');
    end;

    [Test]
    [HandlerFunctions('ActionFindSubstringDialogHandler')]
    procedure TestOpenFindSubstrInStringDialog()
    var
        ActionFindSubstring: Record "Action Find Substring";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        ActionDialogMgmt: Codeunit "Action Dialog Mgmt.";
        VariableID: Integer;
        CaseID, ScriptID, ActionID : Guid;
    begin
        // [SCENARIO] Open Find Substr In String Dialog via OpenActionAssistEdit function.

        // [GIVEN] Case ID, Script ID, Action Type - FindSubstrInString, ActionID - ActionFindSubstring's ID
        BindSubscription(LibraryScriptTests);
        VariableID := 1;
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, VariableID, 'Output Variable', "Symbol Data Type"::String);
        LibraryScriptTests.CreateFindSubstrInString(CaseID, ScriptID, ActionID);

        // [WHEN] The function OpenActionAssistEdit is called.
        ActionDialogMgmt.OpenActionAssistEdit(CaseID, ScriptID, "Action Type"::FINDSUBSTRINGINSTRING, ActionID, "Action Group Type"::" ");
        UnBindSubscription(LibraryScriptTests);

        // [THEN] it should open Find SubString Dialog
        ActionFindSubstring.Get(CaseID, ScriptID, ActionID);
        Assert.AreEqual(VariableID, ActionFindSubstring."Variable ID", 'Variable ID should be 1');
    end;

    [Test]
    [HandlerFunctions('ActionReplaceSubstringDlgHandler')]
    procedure TestOpenReplaceSubstringDialog()
    var
        ActionReplaceSubstring: Record "Action Replace Substring";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        ActionDialogMgmt: Codeunit "Action Dialog Mgmt.";
        VariableID: Integer;
        CaseID, ScriptID, ActionID : Guid;
    begin
        // [SCENARIO] Open Replace Substring Dialog via OpenActionAssistEdit function.

        // [GIVEN] Case ID, Script ID, Action Type - Replace Substring, ActionID - ActionReplaceSubstring's ID
        BindSubscription(LibraryScriptTests);
        VariableID := 1;
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, VariableID, 'Output Variable', "Symbol Data Type"::STRING);
        LibraryScriptTests.CreateReplaceSubstring(CaseID, ScriptID, ActionID);

        // [WHEN] The function OpenActionAssistEdit is called.
        ActionDialogMgmt.OpenActionAssistEdit(CaseID, ScriptID, "Action Type"::REPLACESUBSTRINGINSTRING, ActionID, "Action Group Type"::" ");
        UnBindSubscription(LibraryScriptTests);

        // [THEN] it should open Replace SubString Dialog
        ActionReplaceSubstring.Get(CaseID, ScriptID, ActionID);
        Assert.AreEqual(VariableID, ActionReplaceSubstring."Variable ID", 'Variable ID should be 1');
    end;

    [Test]
    [HandlerFunctions('ActionExtSubstrFromIndexHandler')]
    procedure TestOpenExtractSubstringFromIndexDialog()
    var
        ActionExtSubstrFromIndex: Record "Action Ext. Substr. From Index";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        ActionDialogMgmt: Codeunit "Action Dialog Mgmt.";
        VariableID: Integer;
        CaseID, ScriptID, ActionID : Guid;
    begin
        // [SCENARIO] Open Extract Substring From Index Dialog via OpenActionAssistEdit function.

        // [GIVEN] Case ID, Script ID, Action Type - Replace Substring, ActionID - Action Ext. Substr. From Index's ID
        BindSubscription(LibraryScriptTests);
        VariableID := 1;
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, VariableID, 'Output Variable', "Symbol Data Type"::STRING);
        LibraryScriptTests.CreateExtSubstrFromIndex(CaseID, ScriptID, ActionID);

        // [WHEN] The function OpenActionAssistEdit is called.
        ActionDialogMgmt.OpenActionAssistEdit(CaseID, ScriptID, "Action Type"::EXTRACTSUBSTRINGFROMINDEXOFSTRING, ActionID, "Action Group Type"::" ");
        UnBindSubscription(LibraryScriptTests);

        // [THEN] it should open Extract Substring From Index Dialog
        ActionExtSubstrFromIndex.Get(CaseID, ScriptID, ActionID);
        Assert.AreEqual(VariableID, ActionExtSubstrFromIndex."Variable ID", 'Variable ID should be 1');
    end;

    [Test]
    [HandlerFunctions('ActionExtSubstrFromPosHandler')]
    procedure TestOpenExtractSubstringFromPositionDialog()
    var
        ActionExtSubstrFromPos: Record "Action Ext. Substr. From Pos.";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        ActionDialogMgmt: Codeunit "Action Dialog Mgmt.";
        VariableID: Integer;
        CaseID, ScriptID, ActionID : Guid;
    begin
        // [SCENARIO] Open Extract Substring From Pos Dialog via OpenActionAssistEdit function.

        // [GIVEN] Case ID, Script ID, Action Type - Extract Substring, ActionID - Action Ext. Substr. From Pos.'s ID
        BindSubscription(LibraryScriptTests);
        VariableID := 1;
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, VariableID, 'Output Variable', "Symbol Data Type"::STRING);
        LibraryScriptTests.CreateExtSubstrFromPos(CaseID, ScriptID, ActionID);

        // [WHEN] The function OpenActionAssistEdit is called.
        ActionDialogMgmt.OpenActionAssistEdit(CaseID, ScriptID, "Action Type"::EXTRACTSUBSTRINGFROMPOSITION, ActionID, "Action Group Type"::" ");
        UnBindSubscription(LibraryScriptTests);

        // [THEN] it should open Extract Substring From Pos Dialog
        ActionExtSubstrFromPos.Get(CaseID, ScriptID, ActionID);
        Assert.AreEqual(VariableID, ActionExtSubstrFromPos."Variable ID", 'Variable ID should be 1');
    end;

    [Test]
    [HandlerFunctions('ActionFindDateIntervalDlgHandler')]
    procedure TestOpenActionFindDateIntervalDialog()
    var
        ActionFindDateInterval: Record "Action Find Date Interval";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        ActionDialogMgmt: Codeunit "Action Dialog Mgmt.";
        VariableID: Integer;
        CaseID, ScriptID, ActionID : Guid;
    begin
        // [SCENARIO] Open Action Find Date Interval Dialog via OpenActionAssistEdit function.

        // [GIVEN] Case ID, Script ID, Action Type - Find Date Interval, ActionID - Action Find Date Interval's ID
        BindSubscription(LibraryScriptTests);
        VariableID := 1;
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, VariableID, 'Output Variable', "Symbol Data Type"::NUMBER);
        LibraryScriptTests.CreateFindDateInterval(CaseID, ScriptID, ActionID);

        // [WHEN] The function OpenActionAssistEdit is called.
        ActionDialogMgmt.OpenActionAssistEdit(CaseID, ScriptID, "Action Type"::FINDINTERVALBETWEENDATES, ActionID, "Action Group Type"::" ");
        UnBindSubscription(LibraryScriptTests);

        // [THEN] it should open Action Find Date Interval Dlg
        ActionFindDateInterval.Get(CaseID, ScriptID, ActionID);
        Assert.AreEqual(VariableID, ActionFindDateInterval."Variable ID", 'Variable ID should be 1');
    end;

    [Test]
    [HandlerFunctions('ActionDateCalculationDialogDlgHandler')]
    procedure TestOpenDateCalculationDialog()
    var
        ActionDateCalculation: Record "Action Date Calculation";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        ActionDialogMgmt: Codeunit "Action Dialog Mgmt.";
        VariableID: Integer;
        CaseID, ScriptID, ActionID : Guid;
    begin
        // [SCENARIO] Open Action Date Calculation Dialog via OpenActionAssistEdit function.

        // [GIVEN] Case ID, Script ID, Action Type - Date Calculation, ActionID - Action Date Calculation's ID
        BindSubscription(LibraryScriptTests);
        VariableID := 1;
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, VariableID, 'Output Variable', "Symbol Data Type"::DATE);
        LibraryScriptTests.CreateDateCalculation(CaseID, ScriptID, ActionID);

        // [WHEN] The function OpenActionAssistEdit is called.
        ActionDialogMgmt.OpenActionAssistEdit(CaseID, ScriptID, "Action Type"::DATECALCULATION, ActionID, "Action Group Type"::" ");
        UnBindSubscription(LibraryScriptTests);

        // [THEN] it should open Action Date Calculation Dialog
        ActionDateCalculation.Get(CaseID, ScriptID, ActionID);
        Assert.AreEqual(VariableID, ActionDateCalculation."Variable ID", 'Variable ID should be 1');
    end;

    [Test]
    [HandlerFunctions('ActionDateToDateTimeDialogHandler')]
    procedure TestOpenDateToDateTimeDialog()
    var
        ActionDateToDateTime: Record "Action Date To DateTime";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        ActionDialogMgmt: Codeunit "Action Dialog Mgmt.";
        VariableID: Integer;
        CaseID, ScriptID, ActionID : Guid;
    begin
        // [SCENARIO] Open Action Date To DateTime Dialog via OpenActionAssistEdit function.

        // [GIVEN] Case ID, Script ID, Action Type - Date To DateTime, ActionID - Action Date To DateTime's ID
        BindSubscription(LibraryScriptTests);
        VariableID := 1;
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, VariableID, 'Output Variable', "Symbol Data Type"::DATETIME);
        LibraryScriptTests.CreateDateToDateTime(CaseID, ScriptID, ActionID);

        // [WHEN] The function OpenActionAssistEdit is called.
        ActionDialogMgmt.OpenActionAssistEdit(CaseID, ScriptID, "Action Type"::DATETODATETIME, ActionID, "Action Group Type"::" ");
        UnBindSubscription(LibraryScriptTests);

        // [THEN] it should open Action Date To DateTime Dialog
        ActionDateToDateTime.Get(CaseID, ScriptID, ActionID);
        Assert.AreEqual(VariableID, ActionDateToDateTime."Variable ID", 'Variable ID should be 1');
    end;

    [Test]
    [HandlerFunctions('ActionMessageDialogHandler')]
    procedure TestOpenAlertMessageDialog()
    var
        ActionMessage: Record "Action Message";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        ActionDialogMgmt: Codeunit "Action Dialog Mgmt.";
        CaseID, ScriptID, ActionID : Guid;
    begin
        // [SCENARIO] Open Action Message Dialog via OpenActionAssistEdit function.

        // [GIVEN] Case ID, Script ID, Action Type - Alert Message, ActionID - Action Message's ID
        BindSubscription(LibraryScriptTests);
        LibraryScriptTests.CreateAlertMessage(CaseID, ScriptID, ActionID);

        // [WHEN] The function OpenActionAssistEdit is called.
        ActionDialogMgmt.OpenActionAssistEdit(CaseID, ScriptID, "Action Type"::ALERTMESSAGE, ActionID, "Action Group Type"::" ");
        UnBindSubscription(LibraryScriptTests);

        // [THEN] it should open Action Message Dialog
        ActionMessage.Get(CaseID, ScriptID, ActionID);
        Assert.AreEqual('Hello', ActionMessage.Value, 'Value should be Hello.');
    end;

    [Test]
    [HandlerFunctions('ActionLoopThroughRecDlgHandler')]
    procedure TestOpenLoopThroughRecordsDialog()
    var
        ActionLoopThroughRecords: Record "Action Loop Through Records";
        ScriptVariable: Record "Script Variable";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        ActionDialogMgmt: Codeunit "Action Dialog Mgmt.";
        VariableID: Integer;
        CaseID, ScriptID, ActionID : Guid;
    begin
        // [SCENARIO] Open Action Loop Through Records Dialog via OpenActionAssistEdit function.

        // [GIVEN] Case ID, Script ID, Action Type - Loop Through Records, ActionID - Action Loop Through Records's ID
        BindSubscription(LibraryScriptTests);
        VariableID := 1;
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, VariableID, 'Record Variable', "Symbol Data Type"::RECORD);
        ScriptVariable.Get(CaseID, ScriptID, VariableID);
        ScriptVariable."Table ID" := Database::AllObj;
        ScriptVariable.Modify();

        LibraryScriptTests.CreateLoopThroughRecords(CaseID, ScriptID, ActionID);

        // [WHEN] The function OpenActionAssistEdit is called.
        ActionDialogMgmt.OpenActionAssistEdit(CaseID, ScriptID, "Action Type"::LOOPTHROUGHRECORDS, ActionID, "Action Group Type"::" ");
        UnBindSubscription(LibraryScriptTests);

        // [THEN] it should open Action Loop Through Records Dialog
        ActionLoopThroughRecords.Get(CaseID, ScriptID, ActionID);
        Assert.AreEqual(Database::AllObj, ActionLoopThroughRecords."Table ID", 'Variable ID should be 1');
    end;

    [Test]
    [HandlerFunctions('ActionExtractDatePartDlgHandler')]
    procedure TestOpenExtractDatePartDialog()
    var
        ActionExtractDatePart: Record "Action Extract Date Part";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        ActionDialogMgmt: Codeunit "Action Dialog Mgmt.";
        VariableID: Integer;
        CaseID, ScriptID, ActionID : Guid;
    begin
        // [SCENARIO] Open Action Extract Date Part Dialog via OpenActionAssistEdit function.

        // [GIVEN] Case ID, Script ID, Action Type - Extract Date Part, ActionID - Action Extract Date Part's ID
        BindSubscription(LibraryScriptTests);
        VariableID := 1;
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, VariableID, 'Output Variable', "Symbol Data Type"::NUMBER);
        LibraryScriptTests.CreateExtractDatePart(CaseID, ScriptID, ActionID);

        // [WHEN] The function OpenActionAssistEdit is called.
        ActionDialogMgmt.OpenActionAssistEdit(CaseID, ScriptID, "Action Type"::EXTRACTDATEPART, ActionID, "Action Group Type"::" ");
        UnBindSubscription(LibraryScriptTests);

        // [THEN] It should open Action Extract Date Part Dialog
        ActionExtractDatePart.Get(CaseID, ScriptID, ActionID);
        Assert.AreEqual(VariableID, ActionExtractDatePart."Variable ID", 'Variable ID should be 1');
    end;

    [Test]
    [HandlerFunctions('ActionExtractDateTimeDialogHandler')]
    procedure TestOpenExtractDateTimePartDialog()
    var
        ActionExtractDateTimePart: Record "Action Extract DateTime Part";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        ActionDialogMgmt: Codeunit "Action Dialog Mgmt.";
        VariableID: Integer;
        CaseID, ScriptID, ActionID : Guid;
    begin
        // [SCENARIO] Open Action Extract DateTime Part Dialog via OpenActionAssistEdit function.

        // [GIVEN] Case ID, Script ID, Action Type - Extract DateTime Part, ActionID - Action Extract DateTime Part's ID
        BindSubscription(LibraryScriptTests);
        VariableID := 1;
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, VariableID, 'Output Variable', "Symbol Data Type"::DATE);
        LibraryScriptTests.CreateExtractDateTimePart(CaseID, ScriptID, ActionID);

        // [WHEN] The function OpenActionAssistEdit is called.
        ActionDialogMgmt.OpenActionAssistEdit(CaseID, ScriptID, "Action Type"::EXTRACTDATETIMEPART, ActionID, "Action Group Type"::" ");
        UnBindSubscription(LibraryScriptTests);

        // [THEN] It should open Action Extract DateTime Part Dialog
        ActionExtractDateTimePart.Get(CaseID, ScriptID, ActionID);
        Assert.AreEqual(VariableID, ActionExtractDateTimePart."Variable ID", 'Variable ID should be 1');
    end;

    [Test]
    [HandlerFunctions('ActionLengthOfStringDialogHandler')]
    procedure TestOpenLengthOfStringDialog()
    var
        ActionLengthOfString: Record "Action Length Of String";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        ActionDialogMgmt: Codeunit "Action Dialog Mgmt.";
        VariableID: Integer;
        CaseID, ScriptID, ActionID : Guid;
    begin
        // [SCENARIO] Open Action Length Of String Dialog via OpenActionAssistEdit function.

        // [GIVEN] Case ID, Script ID, Action Type - Length Of String, ActionID - Action Length Of String's ID
        BindSubscription(LibraryScriptTests);
        VariableID := 1;
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, VariableID, 'Output Variable', "Symbol Data Type"::NUMBER);
        LibraryScriptTests.CreateLengthOfString(CaseID, ScriptID, ActionID);

        // [WHEN] The function OpenActionAssistEdit is called.
        ActionDialogMgmt.OpenActionAssistEdit(CaseID, ScriptID, "Action Type"::LENGTHOFSTRING, ActionID, "Action Group Type"::" ");
        UnBindSubscription(LibraryScriptTests);

        // [THEN] It should open Action Length Of String Dialog
        ActionLengthOfString.Get(CaseID, ScriptID, ActionID);
        Assert.AreEqual(VariableID, ActionLengthOfString."Variable ID", 'Variable ID should be 1');
    end;

    [Test]
    [HandlerFunctions('ActionConvertCaseDialogHandler')]
    procedure TestOpenConvertCaseOfStringDialog()
    var
        ActionConvertCase: Record "Action Convert Case";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        ActionDialogMgmt: Codeunit "Action Dialog Mgmt.";
        VariableID: Integer;
        CaseID, ScriptID, ActionID : Guid;
    begin
        // [SCENARIO] Open Action Convert Case Of String Dialog via OpenActionAssistEdit function.

        // [GIVEN] Case ID, Script ID, Action Type - Convert Case Of String, ActionID - Action Convert Case's ID
        BindSubscription(LibraryScriptTests);
        VariableID := 1;
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, VariableID, 'Output Variable', "Symbol Data Type"::STRING);
        LibraryScriptTests.CreateConvertCaseOfString(CaseID, ScriptID, ActionID);

        // [WHEN] The function OpenActionAssistEdit is called.
        ActionDialogMgmt.OpenActionAssistEdit(CaseID, ScriptID, "Action Type"::CONVERTCASEOFSTRING, ActionID, "Action Group Type"::" ");
        UnBindSubscription(LibraryScriptTests);

        // [THEN] It should open Action Convert Case Of String Dialog
        ActionConvertCase.Get(CaseID, ScriptID, ActionID);
        Assert.AreEqual(VariableID, ActionConvertCase."Variable ID", 'Variable ID should be 1');
    end;


    [Test]
    [HandlerFunctions('ActionRoundNumberDialogHandler')]
    procedure TestOpenRoundNumberDialog()
    var
        ActionRoundNumber: Record "Action Round Number";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        ActionDialogMgmt: Codeunit "Action Dialog Mgmt.";
        VariableID: Integer;
        CaseID, ScriptID, ActionID : Guid;
    begin
        // [SCENARIO] Open Action Round Number Dialog via OpenActionAssistEdit function.

        // [GIVEN] Case ID, Script ID, Action Type - Round Number, ActionID - Action Round Number's ID
        BindSubscription(LibraryScriptTests);
        VariableID := 1;
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, VariableID, 'Output Variable', "Symbol Data Type"::NUMBER);
        LibraryScriptTests.CreateRoundNumber(CaseID, ScriptID, ActionID);

        // [WHEN] The function OpenActionAssistEdit is called.
        ActionDialogMgmt.OpenActionAssistEdit(CaseID, ScriptID, "Action Type"::ROUNDNUMBER, ActionID, "Action Group Type"::" ");
        UnBindSubscription(LibraryScriptTests);

        // [THEN] It should open Action Round Number Dialog
        ActionRoundNumber.Get(CaseID, ScriptID, ActionID);
        Assert.AreEqual(VariableID, ActionRoundNumber."Variable ID", 'Variable ID should be 1');
    end;

    [Test]
    [HandlerFunctions('ActionNumberExprDialogHandler')]
    procedure TestOpenNumericExprDialog()
    var
        ActionNumberExpression: Record "Action Number Expression";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        ActionDialogMgmt: Codeunit "Action Dialog Mgmt.";
        VariableID: Integer;
        CaseID, ScriptID, ActionID : Guid;
    begin
        // [SCENARIO] Open Action Number Expression Dialog via OpenActionAssistEdit function.

        // [GIVEN] Case ID, Script ID, Action Type - Number Expression, ActionID - Action Number Expression's ID
        BindSubscription(LibraryScriptTests);
        VariableID := 1;
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, VariableID, 'Output Variable', "Symbol Data Type"::NUMBER);
        LibraryScriptTests.CreateNumericExpression(CaseID, ScriptID, ActionID);

        // [WHEN] The function OpenActionAssistEdit is called.
        ActionDialogMgmt.OpenActionAssistEdit(CaseID, ScriptID, "Action Type"::NUMERICEXPRESSION, ActionID, "Action Group Type"::" ");
        UnBindSubscription(LibraryScriptTests);

        // [THEN] It should open Action Number Expression Dialog
        ActionNumberExpression.Get(CaseID, ScriptID, ActionID);
        Assert.AreEqual(VariableID, ActionNumberExpression."Variable ID", 'Variable ID should be 1');
    end;

    [Test]
    [HandlerFunctions('ActionStringExprDialogHandler')]
    procedure TestOpenStringExprDialog()
    var
        ActionStringExpression: Record "Action String Expression";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        ActionDialogMgmt: Codeunit "Action Dialog Mgmt.";
        VariableID: Integer;
        CaseID, ScriptID, ActionID : Guid;
    begin
        // [SCENARIO] Open String Expression Dialog via OpenActionAssistEdit function.

        // [GIVEN] Case ID, Script ID, Action Type - String Expression, ActionID - Action String Expression's ID
        BindSubscription(LibraryScriptTests);
        VariableID := 1;
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, VariableID, 'Output Variable', "Symbol Data Type"::STRING);
        LibraryScriptTests.CreateStringExpression(CaseID, ScriptID, ActionID);

        // [WHEN] The function OpenActionAssistEdit is called.
        ActionDialogMgmt.OpenActionAssistEdit(CaseID, ScriptID, "Action Type"::STRINGEXPRESSION, ActionID, "Action Group Type"::" ");
        UnBindSubscription(LibraryScriptTests);

        // [THEN] It should open Action String Expression Dialog
        ActionStringExpression.Get(CaseID, ScriptID, ActionID);
        Assert.AreEqual(VariableID, ActionStringExpression."Variable ID", 'Variable ID should be 1');
    end;

    [ModalPageHandler]
    procedure ActionSetVariableDialogHandler(var ActionSetVariableDialog: TestPage "Action Set Variable Dialog")
    begin
        ActionSetVariableDialog.VariableName.Value('Message');
        ActionSetVariableDialog.LookupVariable.Value('Hello');
        ActionSetVariableDialog.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ConditionDialogHandler(var ConditionsDialog: TestPage "Conditions Dialog")
    begin
        ConditionsDialog.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ActionLoopNTimesDialogHandler(var ActionLoopNTimesDialog: TestPage "Action Loop N Times Dialog")
    begin
        ActionLoopNTimesDialog.NValue.Value('5');
        ActionLoopNTimesDialog.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ActionNumberCalcDialogHandler(var ActionNumberCalcDialog: TestPage "Action Number Calc. Dialog")
    begin
        ActionNumberCalcDialog.OutputToVariableName.Value('Output Variable');
        ActionNumberCalcDialog.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ActionConcatenateDialogHandler(var ActionConcatenateDialog: TestPage "Action Concatenate Dialog")
    begin
        ActionConcatenateDialog.VariableName.Value('Output Variable');
        ActionConcatenateDialog.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ActionFindSubstringDialogHandler(var ActionFindSubstringDialog: TestPage "Action Find Substring Dialog")
    begin
        ActionFindSubstringDialog.VariableName.Value('Output Variable');
        ActionFindSubstringDialog.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ActionReplaceSubstringDlgHandler(var ActionReplaceSubstringDlg: TestPage "Action Replace Substring Dlg")
    begin
        ActionReplaceSubstringDlg.VariableName.Value('Output Variable');
        ActionReplaceSubstringDlg.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ActionExtSubstrFromIndexHandler(var ActionExtSubstrFromIndex: TestPage "Action Ext. Substr. From Index")
    begin
        ActionExtSubstrFromIndex.VariableName.Value('Output Variable');
        ActionExtSubstrFromIndex.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ActionExtSubstrFromPosHandler(var ActionExtSubstrFromPos: TestPage "Action Ext. Substr. From Pos.")
    begin
        ActionExtSubstrFromPos.VariableName.Value('Output Variable');
        ActionExtSubstrFromPos.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ActionFindDateIntervalDlgHandler(var ActionFindDateIntervalDlg: TestPage "Action Find Date Interval Dlg")
    begin
        ActionFindDateIntervalDlg.VariableName.Value('Output Variable');
        ActionFindDateIntervalDlg.OK().Invoke();
    end;


    [ModalPageHandler]
    procedure ActionDateCalculationDialogDlgHandler(var ActionDateCalculationDialog: TestPage "Action Date Calculation Dialog")
    begin
        ActionDateCalculationDialog.VariableName.Value('Output Variable');
        ActionDateCalculationDialog.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ActionDateToDateTimeDialogHandler(var ActionDateToDateTimeDialog: TestPage "Action Date To DateTime Dialog")
    begin
        ActionDateToDateTimeDialog.VariableName.Value('Output Variable');
        ActionDateToDateTimeDialog.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ActionMessageDialogHandler(var ActionMessageDialog: TestPage "Action Message Dialog")
    begin
        ActionMessageDialog.Message.Value('Hello');
        ActionMessageDialog.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ActionLoopThroughRecDlgHandler(var ActionLoopThroughRecDlg: TestPage "Action Loop Through Rec. Dlg")
    begin
        ActionLoopThroughRecDlg.GetRecordFromTableName.Value('AllObj');
        ActionLoopThroughRecDlg.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ActionExtractDatePartDlgHandler(var ActionExtractDatePartDlg: TestPage "Action Extract Date Part Dlg")
    begin
        ActionExtractDatePartDlg.VariableName.Value('Output Variable');
        ActionExtractDatePartDlg.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ActionExtractDateTimeDialogHandler(var ActionExtractDateTimeDialog: TestPage "Action Extract DateTime Dialog")
    begin
        ActionExtractDateTimeDialog.VariableName.Value('Output Variable');
        ActionExtractDateTimeDialog.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ActionLengthOfStringDialogHandler(var ActionLengthOfStringDialog: TestPage "Action Length Of String Dialog")
    begin
        ActionLengthOfStringDialog.VariableName.Value('Output Variable');
        ActionLengthOfStringDialog.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ActionConvertCaseDialogHandler(var ActionConvertCaseDialog: TestPage "Action Convert Case Dialog")
    begin
        ActionConvertCaseDialog.VariableName.Value('Output Variable');
        ActionConvertCaseDialog.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ActionRoundNumberDialogHandler(var ActionRoundNumberDialog: TestPage "Action Round Number Dialog")
    begin
        ActionRoundNumberDialog.VariableName.Value('Output Variable');
        ActionRoundNumberDialog.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ActionNumberExprDialogHandler(var ActionNumberExprDialog: TestPage "Action Number Expr. Dialog")
    begin
        ActionNumberExprDialog.VariableName.Value('Output Variable');
        ActionNumberExprDialog.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ActionStringExprDialogHandler(var ActionStringExprDialog: TestPage "Action String Expr. Dialog")
    begin
        ActionStringExprDialog.VariableName.Value('Output Variable');
        ActionStringExprDialog.OK().Invoke();
    end;
}
