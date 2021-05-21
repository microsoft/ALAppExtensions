codeunit 136755 "Script Serialization Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    trigger OnRun()
    begin
        // [FEATURE] [TaxEngine] [Script Serialization] [UT]
    end;

    var
        Assert: Codeunit Assert;

    [Test]
    procedure TestIfConditionToText()
    var
        AllObj: Record AllObj;
        ActionIfStatement: Record "Action If Statement";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        ScriptSerialization: Codeunit "Script Serialization";
        CaseID, ScriptID, ActionID, LookupID : Guid;
        Text: Text;
        ObjectID: Decimal;
        MessageTxt: Label 'If "%1" %2 ''%3''', Comment = '%1 = Field Name, %2 = Conditional Operator, %3 = Value';
        ExpectedText: Text;
    begin
        // [SCENARIO] Serialize 'Action If Statement' to String

        // [GIVEN] If Condition with a condition
        ObjectID := 3;

        BindSubscription(LibraryScriptSymbolLookup);
        LibraryScriptTests.CreateIfCondition(CaseID, ScriptID, ActionID);
        ActionIfStatement.Get(CaseID, ScriptID, ActionID);
        LookupID := LibraryScriptSymbolLookup.CreateLookup(
            CaseID,
            ScriptID,
            Database::AllObj,
            AllObj.FieldNo("Object ID"),
            "Symbol Type"::"Current Record");

        LibraryScriptTests.CreateConditionItem(
            CaseID,
            ScriptID,
            ActionIfStatement."Condition ID",
            LookupID,
            Format(ObjectID),
            "Conditional Operator"::Equals);

        ExpectedText := StrSubstNo(
            MessageTxt,
            AllObj.FieldName("Object ID"),
            "Conditional Operator"::Equals,
            Format(ObjectID, 0, '<Precision,2:3><Standard Format,0>'));

        // [WHEN] The function IfConditionToText is called
        Text := ScriptSerialization.RuleActionToText(CaseID, ScriptID, "Action Type"::IFSTATEMENT, ActionID, "Action Group Type"::"If Statement");
        UnbindSubscription(LibraryScriptSymbolLookup);

        // [THEN] It should return If Condition as text
        Assert.AreEqual(ExpectedText, Text, StrSubstNo('%1 - expected', ExpectedText));
    end;

    [Test]
    procedure TestLoopNTimesToString()
    var
        ActionLoopNTimes: Record "Action Loop N Times";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        ScriptSerialization: Codeunit "Script Serialization";
        CaseID, ScriptID, ActionID : Guid;
        Text: Text;
        NValue: Decimal;
        MessageTxt: Label 'Loop: (''%1'') times', Comment = '%1 = NValue';
        ExpectedText: Text;
    begin
        // [SCENARIO] Serialize 'Action Loop N Times' to String

        // [GIVEN] Action ID of 'Action Loop N Times' Record
        NValue := 5;

        BindSubscription(LibraryScriptSymbolLookup);
        LibraryScriptTests.CreateLoopNTimes(CaseID, ScriptID, ActionID);
        ActionLoopNTimes.Get(CaseID, ScriptID, ActionID);
        ActionLoopNTimes."Value Type" := ActionLoopNTimes."Value Type"::Constant;
        ActionLoopNTimes.Value := Format(NValue);
        ActionLoopNTimes.Modify();

        ExpectedText := StrSubstNo(
            MessageTxt,
            Format(NValue, 0, '<Precision,2:3><Standard Format,0>'));

        // [WHEN] The function LoopNTimesToString is called
        Text := ScriptSerialization.RuleActionToText(CaseID, ScriptID, "Action Type"::LOOPNTIMES, ActionID, "Action Group Type"::" ");
        UnbindSubscription(LibraryScriptSymbolLookup);

        // [THEN] It should return Loop N Times as text
        Assert.AreEqual(ExpectedText, Text, StrSubstNo('%1 - expected', ExpectedText));
    end;

    [Test]
    procedure TestLoopWithConditionToString()
    var
        AllObj: Record AllObj;
        ActionLoopWithCondition: Record "Action Loop With Condition";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        ScriptSerialization: Codeunit "Script Serialization";
        CaseID, ScriptID, ActionID, LookupID : Guid;
        Text: Text;
        ObjectID: Decimal;
        MessageTxt: Label 'Loop: unitl "%1" %2 ''%3''', Comment = '%1 = Field Name, %2 = Conditional Operator, %3 = Value';
        ExpectedText: Text;
    begin
        // [SCENARIO] Serialize 'Action Loop With Condition' to String

        // [GIVEN] Action ID of 'Action Loop With Condition' Record
        ObjectID := 3;

        BindSubscription(LibraryScriptSymbolLookup);
        LibraryScriptTests.CreateLoopWithCondition(CaseID, ScriptID, ActionID);
        ActionLoopWithCondition.Get(CaseID, ScriptID, ActionID);
        LookupID := LibraryScriptSymbolLookup.CreateLookup(
            CaseID,
            ScriptID,
            Database::AllObj,
            AllObj.FieldNo("Object ID"),
            "Symbol Type"::"Current Record");

        LibraryScriptTests.CreateConditionItem(
            CaseID,
            ScriptID,
            ActionLoopWithCondition."Condition ID",
            LookupID,
            Format(ObjectID),
            "Conditional Operator"::Equals);

        ExpectedText := StrSubstNo(
            MessageTxt,
            AllObj.FieldName("Object ID"),
            "Conditional Operator"::Equals,
            Format(ObjectID, 0, '<Precision,2:3><Standard Format,0>'));

        // [WHEN] The function LoopWithConditionToString is called
        Text := ScriptSerialization.RuleActionToText(CaseID, ScriptID, "Action Type"::LOOPWITHCONDITION, ActionID, "Action Group Type"::" ");
        UnbindSubscription(LibraryScriptSymbolLookup);

        // [THEN] It should return Loop With Condition as text
        Assert.AreEqual(ExpectedText, Text, StrSubstNo('%1 - expected', ExpectedText));
    end;

    [Test]
    procedure TestLoopThroughRecordsToString()
    var
        AllObj: Record AllObj;
        ActionLoopThroughRecords: Record "Action Loop Through Records";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        ScriptSerialization: Codeunit "Script Serialization";
        CaseID, ScriptID, ActionID : Guid;
        Text: Text;
        ObjectID: Decimal;
        MessageTxt: Label 'Loop through %1 ', Comment = '%1 = Table Name';
        ExpectedText: Text;
    begin
        // [SCENARIO] Serialize 'Action Loop Through Records' to String

        // [GIVEN] Action ID of 'Action Loop Through Records' Record
        ObjectID := Database::AllObj;

        BindSubscription(LibraryScriptSymbolLookup);
        LibraryScriptTests.CreateLoopThroughRecords(CaseID, ScriptID, ActionID);
        ActionLoopThroughRecords.Get(CaseID, ScriptID, ActionID);
        ActionLoopThroughRecords."Table ID" := ObjectID;
        ActionLoopThroughRecords.Modify();

        ExpectedText := StrSubstNo(MessageTxt, AllObj.TableName);

        // [WHEN] The function LoopThroughRecordsToString is called
        Text := ScriptSerialization.RuleActionToText(CaseID, ScriptID, "Action Type"::LOOPTHROUGHRECORDS, ActionID, "Action Group Type"::" ");
        UnbindSubscription(LibraryScriptSymbolLookup);

        // [THEN] It should return Loop Through Records as text
        Assert.AreEqual(ExpectedText, Text, StrSubstNo('%1 - expected', ExpectedText));
    end;

    [Test]
    procedure TestCommentToString()
    var
        LibraryScriptTests: Codeunit "Library - Script Tests";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        ScriptSerialization: Codeunit "Script Serialization";
        CaseID, ScriptID, ActionID : Guid;
        Text: Text;
        ExpectedText: Text[250];
    begin
        // [SCENARIO] Serialize 'Action Comment' to String

        // [GIVEN] Action ID of 'Action Comment' Record
        ExpectedText := 'Hello';

        BindSubscription(LibraryScriptSymbolLookup);
        LibraryScriptTests.CreateComment(CaseID, ScriptID, ActionID, ExpectedText);

        // [WHEN] The function CommentToString is called
        Text := ScriptSerialization.RuleActionToText(CaseID, ScriptID, "Action Type"::COMMENT, ActionID, "Action Group Type"::" ");
        UnbindSubscription(LibraryScriptSymbolLookup);

        // [THEN] It should return Comment as text
        Assert.AreEqual(ExpectedText, Text, StrSubstNo('%1 - expected', ExpectedText));
    end;

    [Test]
    procedure TestNumberCalculationToString()
    var
        ActionNumberCalculation: Record "Action Number Calculation";
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        ScriptSerialization: Codeunit "Script Serialization";
        CaseID, ScriptID, ActionID, LHSLookupID, RHSLookupID : Guid;
        A_ID, B_ID, Output_ID : Integer;
        Text: Text;
        ExpectedText: Text;
    begin
        // [SCENARIO] Serialize 'Action Number Calculation' to String

        // [GIVEN] Action ID of 'Action Number Calculation' Record
        BindSubscription(LibraryScriptSymbolLookup);
        LibraryScriptTests.CreateNumberCalculation(CaseID, ScriptID, ActionID);
        A_ID := 1000;
        B_ID := 1001;
        Output_ID := 1002;

        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, A_ID, 'a', "Symbol Data Type"::NUMBER);
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, B_ID, 'b', "Symbol Data Type"::NUMBER);
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, Output_ID, 'x', "Symbol Data Type"::NUMBER);

        LHSLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, 0, 0, "Symbol Type"::Variable);
        ScriptSymbolLookup.Get(CaseID, ScriptID, LHSLookupID);
        ScriptSymbolLookup."Source Type" := ScriptSymbolLookup."Source Type"::Variable;
        ScriptSymbolLookup."Source Field ID" := A_ID;
        ScriptSymbolLookup.Modify();

        RHSLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, 0, 0, "Symbol Type"::Variable);
        ScriptSymbolLookup.Get(CaseID, ScriptID, RHSLookupID);
        ScriptSymbolLookup."Source Type" := ScriptSymbolLookup."Source Type"::Variable;
        ScriptSymbolLookup."Source Field ID" := B_ID;
        ScriptSymbolLookup.Modify();

        ActionNumberCalculation.Get(CaseID, ScriptID, ActionID);
        ActionNumberCalculation."LHS Type" := ActionNumberCalculation."LHS Type"::Lookup;
        ActionNumberCalculation."LHS Lookup ID" := LHSLookupID;
        ActionNumberCalculation."RHS Type" := ActionNumberCalculation."RHS Type"::Lookup;
        ActionNumberCalculation."RHS Lookup ID" := RHSLookupID;
        ActionNumberCalculation."Arithmetic Operator" := ActionNumberCalculation."Arithmetic Operator"::Plus;
        ActionNumberCalculation."Variable ID" := Output_ID;
        ActionNumberCalculation.Modify();

        ExpectedText := 'Calculate Variable: a Plus Variable: b (Output to Variable: x)';
        // [WHEN] The function NumberCalculationToString is called
        Text := ScriptSerialization.RuleActionToText(CaseID, ScriptID, "Action Type"::NUMBERCALCULATION, ActionID, "Action Group Type"::" ");
        UnbindSubscription(LibraryScriptSymbolLookup);

        // [THEN] It should return Number Calculation as text
        Assert.AreEqual(ExpectedText, Text, StrSubstNo('%1 - expected', ExpectedText));
    end;

    [Test]
    procedure TestExtractSubstringFromPositionToString()
    var
        ActionExtSubstrFromPos: Record "Action Ext. Substr. From Pos.";
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        ScriptSerialization: Codeunit "Script Serialization";
        CaseID, ScriptID, ActionID, StringLookupID, LengthLookupID : Guid;
        String_ID, Length_ID, Output_ID : Integer;
        Text: Text;
        ExpectedText: Text;
    begin
        // [SCENARIO] Serialize 'Action Ext. Substr. From Pos.' to String

        // [GIVEN] Action ID of 'Action Ext. Substr. From Pos.' Record
        BindSubscription(LibraryScriptSymbolLookup);
        LibraryScriptTests.CreateExtSubstrFromPos(CaseID, ScriptID, ActionID);
        String_ID := 1000;
        Length_ID := 1001;
        Output_ID := 1002;

        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, String_ID, 'a', "Symbol Data Type"::STRING);
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, Length_ID, 'b', "Symbol Data Type"::NUMBER);
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, Output_ID, 'x', "Symbol Data Type"::STRING);

        StringLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, 0, 0, "Symbol Type"::Variable);
        ScriptSymbolLookup.Get(CaseID, ScriptID, StringLookupID);
        ScriptSymbolLookup."Source Type" := ScriptSymbolLookup."Source Type"::Variable;
        ScriptSymbolLookup."Source Field ID" := String_ID;
        ScriptSymbolLookup.Modify();

        LengthLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, 0, 0, "Symbol Type"::Variable);
        ScriptSymbolLookup.Get(CaseID, ScriptID, LengthLookupID);
        ScriptSymbolLookup."Source Type" := ScriptSymbolLookup."Source Type"::Variable;
        ScriptSymbolLookup."Source Field ID" := Length_ID;
        ScriptSymbolLookup.Modify();

        ActionExtSubstrFromPos.Get(CaseID, ScriptID, ActionID);
        ActionExtSubstrFromPos."String Value Type" := ActionExtSubstrFromPos."String Value Type"::Lookup;
        ActionExtSubstrFromPos."String Lookup ID" := StringLookupID;
        ActionExtSubstrFromPos.Position := ActionExtSubstrFromPos.Position::start;
        ActionExtSubstrFromPos."Length Value Type" := ActionExtSubstrFromPos."Length Value Type"::Lookup;
        ActionExtSubstrFromPos."Length Lookup ID" := LengthLookupID;
        ActionExtSubstrFromPos."Variable ID" := Output_ID;
        ActionExtSubstrFromPos.Modify();

        ExpectedText := 'Copy Variable: b characters from start of Variable: a (Output to Variable: x)';

        // [WHEN] The function ExtractSubStringFromPositionToString is called
        Text := ScriptSerialization.RuleActionToText(CaseID, ScriptID, "Action Type"::EXTRACTSUBSTRINGFROMPOSITION, ActionID, "Action Group Type"::" ");
        UnbindSubscription(LibraryScriptSymbolLookup);

        // [THEN] It should return Extract Substring from Position as text
        Assert.AreEqual(ExpectedText, Text, StrSubstNo('%1 - expected', ExpectedText));
    end;

    [Test]
    procedure TestFindDateIntervalToString()
    var
        ActionFindDateInterval: Record "Action Find Date Interval";
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        ScriptSerialization: Codeunit "Script Serialization";
        CaseID, ScriptID, ActionID, Date1LookupID, Date2LookupID : Guid;
        Date1_ID, Date2_ID, Output_ID : Integer;
        Text: Text;
        ExpectedText: Text;
    begin
        // [SCENARIO] Serialize 'Action Find Date Interval' to String

        // [GIVEN] Action ID of 'Action Find Date Interval' Record
        BindSubscription(LibraryScriptSymbolLookup);
        LibraryScriptTests.CreateFindDateInterval(CaseID, ScriptID, ActionID);
        Date1_ID := 1000;
        Date2_ID := 1001;
        Output_ID := 1002;

        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, Date1_ID, 'a', "Symbol Data Type"::DATE);
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, Date2_ID, 'b', "Symbol Data Type"::DATE);
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, Output_ID, 'x', "Symbol Data Type"::NUMBER);

        Date1LookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, 0, 0, "Symbol Type"::Variable);
        ScriptSymbolLookup.Get(CaseID, ScriptID, Date1LookupID);
        ScriptSymbolLookup."Source Type" := ScriptSymbolLookup."Source Type"::Variable;
        ScriptSymbolLookup."Source Field ID" := Date1_ID;
        ScriptSymbolLookup.Modify();

        Date2LookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, 0, 0, "Symbol Type"::Variable);
        ScriptSymbolLookup.Get(CaseID, ScriptID, Date2LookupID);
        ScriptSymbolLookup."Source Type" := ScriptSymbolLookup."Source Type"::Variable;
        ScriptSymbolLookup."Source Field ID" := Date2_ID;
        ScriptSymbolLookup.Modify();

        ActionFindDateInterval.Get(CaseID, ScriptID, ActionID);
        ActionFindDateInterval."Date1 Value Type" := ActionFindDateInterval."Date1 Value Type"::Lookup;
        ActionFindDateInterval."Date1 Lookup ID" := Date1LookupID;
        ActionFindDateInterval."Date2 Value Type" := ActionFindDateInterval."Date2 Value Type"::Lookup;
        ActionFindDateInterval."Date2 Lookup ID" := Date2LookupID;
        ActionFindDateInterval.Inverval := ActionFindDateInterval.Inverval::Days;
        ActionFindDateInterval."Variable ID" := Output_ID;
        ActionFindDateInterval.Modify();

        ExpectedText := 'Find days between Variable: a and Variable: b (Output to Variable: x)';

        // [WHEN] The function FindDateIntervalToString is called
        Text := ScriptSerialization.RuleActionToText(CaseID, ScriptID, "Action Type"::FINDINTERVALBETWEENDATES, ActionID, "Action Group Type"::" ");
        UnbindSubscription(LibraryScriptSymbolLookup);

        // [THEN] It should return Find Date Interval as text
        Assert.AreEqual(ExpectedText, Text, StrSubstNo('%1 - expected', ExpectedText));
    end;

    [Test]
    procedure TestSetVariableToString()
    var
        ActionSetVariable: Record "Action Set Variable";
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        ScriptSerialization: Codeunit "Script Serialization";
        CaseID, ScriptID, ActionID, Date1LookupID : Guid;
        Date1_ID, Output_ID : Integer;
        Text: Text;
        ExpectedText: Text;
    begin
        // [SCENARIO] Serialize 'Action Set Variable' to String

        // [GIVEN] Action ID of 'Action Set Variable' Record
        BindSubscription(LibraryScriptSymbolLookup);
        LibraryScriptTests.CreateSetVariable(CaseID, ScriptID, ActionID);
        Date1_ID := 1000;
        Output_ID := 1002;

        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, Date1_ID, 'a', "Symbol Data Type"::DATE);
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, Output_ID, 'x', "Symbol Data Type"::STRING);

        Date1LookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, 0, 0, "Symbol Type"::Variable);
        ScriptSymbolLookup.Get(CaseID, ScriptID, Date1LookupID);
        ScriptSymbolLookup."Source Type" := ScriptSymbolLookup."Source Type"::Variable;
        ScriptSymbolLookup."Source Field ID" := Date1_ID;
        ScriptSymbolLookup.Modify();

        ActionSetVariable.Get(CaseID, ScriptID, ActionID);
        ActionSetVariable."Value Type" := ActionSetVariable."Value Type"::Lookup;
        ActionSetVariable."Lookup ID" := Date1LookupID;
        ActionSetVariable."Variable ID" := Output_ID;
        ActionSetVariable.Modify();

        ExpectedText := 'Set Variable: x to Variable: a';

        // [WHEN] The function SetVariableToString is called
        Text := ScriptSerialization.RuleActionToText(CaseID, ScriptID, "Action Type"::SETVARIABLE, ActionID, "Action Group Type"::" ");
        UnbindSubscription(LibraryScriptSymbolLookup);

        // [THEN] It should return Set Variable as text
        Assert.AreEqual(ExpectedText, Text, StrSubstNo('%1 - expected', ExpectedText));
    end;

    [Test]
    procedure TestConcatenateToString()
    var
        ActionConcatenate: Record "Action Concatenate";
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        ScriptSerialization: Codeunit "Script Serialization";
        CaseID, ScriptID, ActionID, String1LookupID, String2LookupID : Guid;
        String1_ID, String2_ID, Output_ID : Integer;
        Text: Text;
        ExpectedText: Text;
    begin
        // [SCENARIO] Serialize 'Action Concatenate' to String

        // [GIVEN] Action ID of 'Action Concatenate' Record
        BindSubscription(LibraryScriptSymbolLookup);
        LibraryScriptTests.CreateConcatenate(CaseID, ScriptID, ActionID);
        String1_ID := 1000;
        String2_ID := 1001;
        Output_ID := 1002;

        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, String1_ID, 'a', "Symbol Data Type"::STRING);
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, String2_ID, 'b', "Symbol Data Type"::STRING);
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, Output_ID, 'x', "Symbol Data Type"::STRING);

        String1LookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, 0, 0, "Symbol Type"::Variable);
        ScriptSymbolLookup.Get(CaseID, ScriptID, String1LookupID);
        ScriptSymbolLookup."Source Type" := ScriptSymbolLookup."Source Type"::Variable;
        ScriptSymbolLookup."Source Field ID" := String1_ID;
        ScriptSymbolLookup.Modify();

        String2LookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, 0, 0, "Symbol Type"::Variable);
        ScriptSymbolLookup.Get(CaseID, ScriptID, String2LookupID);
        ScriptSymbolLookup."Source Type" := ScriptSymbolLookup."Source Type"::Variable;
        ScriptSymbolLookup."Source Field ID" := String2_ID;
        ScriptSymbolLookup.Modify();

        ActionConcatenate.Get(CaseID, ScriptID, ActionID);
        ActionConcatenate."Variable ID" := Output_ID;
        ActionConcatenate.Modify();

        LibraryScriptTests.AddConcatenateLine(CaseID, ScriptID, ActionID, String1LookupID);
        LibraryScriptTests.AddConcatenateLine(CaseID, ScriptID, ActionID, String2LookupID);

        ExpectedText := 'Concatenate: Variable: a,Variable: b (Output to Variable: x)';

        // [WHEN] The function ConcatenateToString is called
        Text := ScriptSerialization.RuleActionToText(CaseID, ScriptID, "Action Type"::CONCATENATE, ActionID, "Action Group Type"::" ");
        UnbindSubscription(LibraryScriptSymbolLookup);

        // [THEN] It should return Concatenate String as text
        Assert.AreEqual(ExpectedText, Text, StrSubstNo('%1 - expected', ExpectedText));
    end;

    [Test]
    procedure TestFindSubstringToString()
    var
        ActionFindSubstring: Record "Action Find Substring";
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        ScriptSerialization: Codeunit "Script Serialization";
        CaseID, ScriptID, ActionID, StringLookupID, String2LookupID : Guid;
        String_ID, String2_ID, Output_ID : Integer;
        Text: Text;
        ExpectedText: Text;
    begin
        // [SCENARIO] Serialize 'Action Find Substring' to String

        // [GIVEN] Action ID of 'Action Find Substring' Record
        BindSubscription(LibraryScriptSymbolLookup);
        LibraryScriptTests.CreateFindSubstrInString(CaseID, ScriptID, ActionID);
        String_ID := 1000;
        String2_ID := 1001;
        Output_ID := 1002;

        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, String_ID, 'a', "Symbol Data Type"::STRING);
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, String2_ID, 'b', "Symbol Data Type"::STRING);
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, Output_ID, 'x', "Symbol Data Type"::NUMBER);

        StringLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, 0, 0, "Symbol Type"::Variable);
        ScriptSymbolLookup.Get(CaseID, ScriptID, StringLookupID);
        ScriptSymbolLookup."Source Type" := ScriptSymbolLookup."Source Type"::Variable;
        ScriptSymbolLookup."Source Field ID" := String_ID;
        ScriptSymbolLookup.Modify();

        String2LookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, 0, 0, "Symbol Type"::Variable);
        ScriptSymbolLookup.Get(CaseID, ScriptID, String2LookupID);
        ScriptSymbolLookup."Source Type" := ScriptSymbolLookup."Source Type"::Variable;
        ScriptSymbolLookup."Source Field ID" := String2_ID;
        ScriptSymbolLookup.Modify();

        ActionFindSubstring.Get(CaseID, ScriptID, ActionID);
        ActionFindSubstring."String Value Type" := ActionFindSubstring."String Value Type"::Lookup;
        ActionFindSubstring."String Lookup ID" := StringLookupID;
        ActionFindSubstring."Substring Value Type" := ActionFindSubstring."Substring Value Type"::Lookup;
        ActionFindSubstring."Substring Lookup ID" := String2LookupID;
        ActionFindSubstring."Variable ID" := Output_ID;
        ActionFindSubstring.Modify();

        ExpectedText := 'Find Variable: b in Variable: a (Output to Variable: x)';

        // [WHEN] The function FindSubstringToString is called
        Text := ScriptSerialization.RuleActionToText(CaseID, ScriptID, "Action Type"::FINDSUBSTRINGINSTRING, ActionID, "Action Group Type"::" ");
        UnbindSubscription(LibraryScriptSymbolLookup);

        // [THEN] It should return Find Substring as text
        Assert.AreEqual(ExpectedText, Text, StrSubstNo('%1 - expected', ExpectedText));
    end;

    [Test]
    procedure TestReplaceSubstringInStringToString()
    var
        ActionReplaceSubstring: Record "Action Replace Substring";
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        ScriptSerialization: Codeunit "Script Serialization";
        CaseID, ScriptID, ActionID, StringLookupID, String2LookupID, NewStringLookupID : Guid;
        String_ID, String2_ID, NewString_ID, Output_ID : Integer;
        Text: Text;
        ExpectedText: Text;
    begin
        // [SCENARIO] Serialize 'Action Replace Substring' to String

        // [GIVEN] Action ID of 'Action Replace Substring' Record
        BindSubscription(LibraryScriptSymbolLookup);
        LibraryScriptTests.CreateReplaceSubstring(CaseID, ScriptID, ActionID);
        String_ID := 1000;
        String2_ID := 1001;
        NewString_ID := 1003;
        Output_ID := 1002;

        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, String_ID, 'a', "Symbol Data Type"::STRING);
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, String2_ID, 'b', "Symbol Data Type"::STRING);
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, NewString_ID, 'c', "Symbol Data Type"::STRING);
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, Output_ID, 'x', "Symbol Data Type"::STRING);

        StringLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, 0, 0, "Symbol Type"::Variable);
        ScriptSymbolLookup.Get(CaseID, ScriptID, StringLookupID);
        ScriptSymbolLookup."Source Type" := ScriptSymbolLookup."Source Type"::Variable;
        ScriptSymbolLookup."Source Field ID" := String_ID;
        ScriptSymbolLookup.Modify();

        String2LookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, 0, 0, "Symbol Type"::Variable);
        ScriptSymbolLookup.Get(CaseID, ScriptID, String2LookupID);
        ScriptSymbolLookup."Source Type" := ScriptSymbolLookup."Source Type"::Variable;
        ScriptSymbolLookup."Source Field ID" := String2_ID;
        ScriptSymbolLookup.Modify();

        NewStringLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, 0, 0, "Symbol Type"::Variable);
        ScriptSymbolLookup.Get(CaseID, ScriptID, NewStringLookupID);
        ScriptSymbolLookup."Source Type" := ScriptSymbolLookup."Source Type"::Variable;
        ScriptSymbolLookup."Source Field ID" := NewString_ID;
        ScriptSymbolLookup.Modify();

        ActionReplaceSubstring.Get(CaseID, ScriptID, ActionID);
        ActionReplaceSubstring."String Value Type" := ActionReplaceSubstring."String Value Type"::Lookup;
        ActionReplaceSubstring."String Lookup ID" := StringLookupID;
        ActionReplaceSubstring."Substring Value Type" := ActionReplaceSubstring."Substring Value Type"::Lookup;
        ActionReplaceSubstring."Substring Lookup ID" := String2LookupID;
        ActionReplaceSubstring."New String Value Type" := ActionReplaceSubstring."New String Value Type"::Lookup;
        ActionReplaceSubstring."New String Lookup ID" := NewStringLookupID;
        ActionReplaceSubstring."Variable ID" := Output_ID;
        ActionReplaceSubstring.Modify();

        ExpectedText := 'Replace Variable: b with Variable: c in Variable: a (Output to Variable: x)';

        // [WHEN] The function ReplaceSubStringInString is called
        Text := ScriptSerialization.RuleActionToText(CaseID, ScriptID, "Action Type"::REPLACESUBSTRINGINSTRING, ActionID, "Action Group Type"::" ");
        UnbindSubscription(LibraryScriptSymbolLookup);

        // [THEN] It should return Replace Substring In String as text
        Assert.AreEqual(ExpectedText, Text, StrSubstNo('%1 - expected', ExpectedText));
    end;

    [Test]
    procedure TestExtractSubstringFromIndexToString()
    var
        ActionExtSubstrFromIndex: Record "Action Ext. Substr. From Index";
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        ScriptSerialization: Codeunit "Script Serialization";
        CaseID, ScriptID, ActionID, StringLookupID, LengthLookupID, IndexLookupID : Guid;
        String_ID, Index_ID, Length_ID, Output_ID : Integer;
        Text: Text;
        ExpectedText: Text;
    begin
        // [SCENARIO] Serialize 'Action Ext. Substr. From Index' to String

        // [GIVEN] Action ID of 'Action Ext. Substr. From Index' Record
        BindSubscription(LibraryScriptSymbolLookup);
        LibraryScriptTests.CreateExtSubstrFromIndex(CaseID, ScriptID, ActionID);
        String_ID := 1000;
        Length_ID := 1001;
        Index_ID := 1003;
        Output_ID := 1002;

        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, String_ID, 'a', "Symbol Data Type"::STRING);
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, Index_ID, 'b', "Symbol Data Type"::NUMBER);
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, Length_ID, 'c', "Symbol Data Type"::NUMBER);
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, Output_ID, 'x', "Symbol Data Type"::STRING);

        StringLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, 0, 0, "Symbol Type"::Variable);
        ScriptSymbolLookup.Get(CaseID, ScriptID, StringLookupID);
        ScriptSymbolLookup."Source Type" := ScriptSymbolLookup."Source Type"::Variable;
        ScriptSymbolLookup."Source Field ID" := String_ID;
        ScriptSymbolLookup.Modify();

        IndexLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, 0, 0, "Symbol Type"::Variable);
        ScriptSymbolLookup.Get(CaseID, ScriptID, IndexLookupID);
        ScriptSymbolLookup."Source Type" := ScriptSymbolLookup."Source Type"::Variable;
        ScriptSymbolLookup."Source Field ID" := Index_ID;
        ScriptSymbolLookup.Modify();

        LengthLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, 0, 0, "Symbol Type"::Variable);
        ScriptSymbolLookup.Get(CaseID, ScriptID, LengthLookupID);
        ScriptSymbolLookup."Source Type" := ScriptSymbolLookup."Source Type"::Variable;
        ScriptSymbolLookup."Source Field ID" := Length_ID;
        ScriptSymbolLookup.Modify();

        ActionExtSubstrFromIndex.Get(CaseID, ScriptID, ActionID);
        ActionExtSubstrFromIndex."String Value Type" := ActionExtSubstrFromIndex."String Value Type"::Lookup;
        ActionExtSubstrFromIndex."String Lookup ID" := StringLookupID;
        ActionExtSubstrFromIndex."Index Value Type" := ActionExtSubstrFromIndex."Index Value Type"::Lookup;
        ActionExtSubstrFromIndex."Index Lookup ID" := IndexLookupID;
        ActionExtSubstrFromIndex."Length Value Type" := ActionExtSubstrFromIndex."Length Value Type"::Lookup;
        ActionExtSubstrFromIndex."Length Lookup ID" := LengthLookupID;
        ActionExtSubstrFromIndex."Variable ID" := Output_ID;
        ActionExtSubstrFromIndex.Modify();

        ExpectedText := 'Copy from Variable: a, starting at Variable: b for Variable: c characters (Output to Variable: x)';

        // [WHEN] The function ExtractSubstringFromIndexToString is called
        Text := ScriptSerialization.RuleActionToText(CaseID, ScriptID, "Action Type"::EXTRACTSUBSTRINGFROMINDEXOFSTRING, ActionID, "Action Group Type"::" ");
        UnbindSubscription(LibraryScriptSymbolLookup);

        // [THEN] It should return Extract Substring From Index as text
        Assert.AreEqual(ExpectedText, Text, StrSubstNo('%1 - expected', ExpectedText));
    end;

    [Test]
    procedure TestDateCalculationToString()
    var
        ActionDateCalculation: Record "Action Date Calculation";
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        ScriptSerialization: Codeunit "Script Serialization";
        CaseID, ScriptID, ActionID, DateLookupID, NumberLookupID : Guid;
        Date_ID, Number_ID, Output_ID : Integer;
        Text: Text;
        ExpectedText: Text;
    begin
        // [SCENARIO] Serialize 'Action Date Calculation' to String

        // [GIVEN] Action ID of 'Action Date Calculation' Record
        BindSubscription(LibraryScriptSymbolLookup);
        LibraryScriptTests.CreateDateCalculation(CaseID, ScriptID, ActionID);
        Date_ID := 1000;
        Number_ID := 1003;
        Output_ID := 1002;

        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, Date_ID, 'a', "Symbol Data Type"::DATE);
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, Number_ID, 'b', "Symbol Data Type"::NUMBER);
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, Output_ID, 'x', "Symbol Data Type"::STRING);

        DateLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, 0, 0, "Symbol Type"::Variable);
        ScriptSymbolLookup.Get(CaseID, ScriptID, DateLookupID);
        ScriptSymbolLookup."Source Type" := ScriptSymbolLookup."Source Type"::Variable;
        ScriptSymbolLookup."Source Field ID" := Date_ID;
        ScriptSymbolLookup.Modify();

        NumberLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, 0, 0, "Symbol Type"::Variable);
        ScriptSymbolLookup.Get(CaseID, ScriptID, NumberLookupID);
        ScriptSymbolLookup."Source Type" := ScriptSymbolLookup."Source Type"::Variable;
        ScriptSymbolLookup."Source Field ID" := Number_ID;
        ScriptSymbolLookup.Modify();

        ActionDateCalculation.Get(CaseID, ScriptID, ActionID);
        ActionDateCalculation."Date Value Type" := ActionDateCalculation."Date Value Type"::Lookup;
        ActionDateCalculation."Date Lookup ID" := DateLookupID;
        ActionDateCalculation."Number Value Type" := ActionDateCalculation."Number Value Type"::Lookup;
        ActionDateCalculation."Number Lookup ID" := NumberLookupID;
        ActionDateCalculation.Duration := ActionDateCalculation.Duration::Days;
        ActionDateCalculation."Variable ID" := Output_ID;
        ActionDateCalculation.Modify();

        ExpectedText := 'Calculate Variable: a plus Variable: b days (Output to Variable: x)';

        // [WHEN] The function DateCalculationToString is called
        Text := ScriptSerialization.RuleActionToText(CaseID, ScriptID, "Action Type"::DATECALCULATION, ActionID, "Action Group Type"::" ");
        UnbindSubscription(LibraryScriptSymbolLookup);

        // [THEN] It should return Date Calculation as text
        Assert.AreEqual(ExpectedText, Text, StrSubstNo('%1 - expected', ExpectedText));
    end;

    [Test]
    procedure TestDateToDateTimeToString()
    var
        ActionDateToDateTime: Record "Action Date To DateTime";
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        ScriptSerialization: Codeunit "Script Serialization";
        CaseID, ScriptID, ActionID, DateLookupID, TimeLookupID : Guid;
        Date_ID, Time_ID, Output_ID : Integer;
        Text: Text;
        ExpectedText: Text;
    begin
        // [SCENARIO] Serialize 'Action Date To DateTime' to String

        // [GIVEN] Action ID of 'Action Date To DateTime' Record
        BindSubscription(LibraryScriptSymbolLookup);
        LibraryScriptTests.CreateDateToDateTime(CaseID, ScriptID, ActionID);
        Date_ID := 1000;
        Time_ID := 1003;
        Output_ID := 1002;

        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, Date_ID, 'a', "Symbol Data Type"::DATE);
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, Time_ID, 'b', "Symbol Data Type"::TIME);
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, Output_ID, 'x', "Symbol Data Type"::DATETIME);

        DateLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, 0, 0, "Symbol Type"::Variable);
        ScriptSymbolLookup.Get(CaseID, ScriptID, DateLookupID);
        ScriptSymbolLookup."Source Type" := ScriptSymbolLookup."Source Type"::Variable;
        ScriptSymbolLookup."Source Field ID" := Date_ID;
        ScriptSymbolLookup.Modify();

        TimeLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, 0, 0, "Symbol Type"::Variable);
        ScriptSymbolLookup.Get(CaseID, ScriptID, TimeLookupID);
        ScriptSymbolLookup."Source Type" := ScriptSymbolLookup."Source Type"::Variable;
        ScriptSymbolLookup."Source Field ID" := Time_ID;
        ScriptSymbolLookup.Modify();

        ActionDateToDateTime.Get(CaseID, ScriptID, ActionID);
        ActionDateToDateTime."Date Value Type" := ActionDateToDateTime."Date Value Type"::Lookup;
        ActionDateToDateTime."Date Lookup ID" := DateLookupID;
        ActionDateToDateTime."Time Value Type" := ActionDateToDateTime."Time Value Type"::Lookup;
        ActionDateToDateTime."Time Lookup ID" := TimeLookupID;
        ActionDateToDateTime."Variable ID" := Output_ID;
        ActionDateToDateTime.Modify();

        ExpectedText := 'Calculate DateTime from Date Variable: a, Time Variable: b (Output to Variable: x)';

        // [WHEN] The function DateToDateTimeToString is called
        Text := ScriptSerialization.RuleActionToText(CaseID, ScriptID, "Action Type"::DATETODATETIME, ActionID, "Action Group Type"::" ");
        UnbindSubscription(LibraryScriptSymbolLookup);

        // [THEN] It should return Date To DateTime as text
        Assert.AreEqual(ExpectedText, Text, StrSubstNo('%1 - expected', ExpectedText));
    end;

    [Test]
    procedure TestAlertMessageToString()
    var
        ActionMessage: Record "Action Message";
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        ScriptSerialization: Codeunit "Script Serialization";
        CaseID, ScriptID, ActionID, StringLookupID : Guid;
        String_ID: Integer;
        Text: Text;
        ExpectedText: Text;
    begin
        // [SCENARIO] Serialize 'Action Message' to String

        // [GIVEN] Action ID of 'Action Message' Record
        BindSubscription(LibraryScriptSymbolLookup);
        LibraryScriptTests.CreateAlertMessage(CaseID, ScriptID, ActionID);
        String_ID := 1000;

        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, String_ID, 'a', "Symbol Data Type"::STRING);

        StringLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, 0, 0, "Symbol Type"::Variable);
        ScriptSymbolLookup.Get(CaseID, ScriptID, StringLookupID);
        ScriptSymbolLookup."Source Type" := ScriptSymbolLookup."Source Type"::Variable;
        ScriptSymbolLookup."Source Field ID" := String_ID;
        ScriptSymbolLookup.Modify();

        ActionMessage.Get(CaseID, ScriptID, ActionID);
        ActionMessage."Value Type" := ActionMessage."Value Type"::Lookup;
        ActionMessage."Lookup ID" := StringLookupID;
        ActionMessage."Throw Error" := true;
        ActionMessage.Modify();

        ExpectedText := 'Throw Error Message: Variable: a';

        // [WHEN] The function AlertMessageToString is called
        Text := ScriptSerialization.RuleActionToText(CaseID, ScriptID, "Action Type"::ALERTMESSAGE, ActionID, "Action Group Type"::" ");
        UnbindSubscription(LibraryScriptSymbolLookup);

        // [THEN] It should return Alert Message as text
        Assert.AreEqual(ExpectedText, Text, StrSubstNo('%1 - expected', ExpectedText));
    end;

    [Test]
    procedure TestExtractDatePartToString()
    var
        ActionExtractDatePart: Record "Action Extract Date Part";
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        ScriptSerialization: Codeunit "Script Serialization";
        CaseID, ScriptID, ActionID, DateLookupID : Guid;
        Date_ID, Output_ID : Integer;
        Text: Text;
        ExpectedText: Text;
    begin
        // [SCENARIO] Serialize 'Action Extract Date Part' to String

        // [GIVEN] Action ID of 'Action Extract Date Part' Record
        BindSubscription(LibraryScriptSymbolLookup);
        LibraryScriptTests.CreateExtractDatePart(CaseID, ScriptID, ActionID);
        Date_ID := 1000;
        Output_ID := 1002;

        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, Date_ID, 'a', "Symbol Data Type"::DATE);
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, Output_ID, 'x', "Symbol Data Type"::NUMBER);

        DateLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, 0, 0, "Symbol Type"::Variable);
        ScriptSymbolLookup.Get(CaseID, ScriptID, DateLookupID);
        ScriptSymbolLookup."Source Type" := ScriptSymbolLookup."Source Type"::Variable;
        ScriptSymbolLookup."Source Field ID" := Date_ID;
        ScriptSymbolLookup.Modify();

        ActionExtractDatePart.Get(CaseID, ScriptID, ActionID);
        ActionExtractDatePart."Value Type" := ActionExtractDatePart."Value Type"::Lookup;
        ActionExtractDatePart."Lookup ID" := DateLookupID;
        ActionExtractDatePart."Date Part" := ActionExtractDatePart."Date Part"::Day;
        ActionExtractDatePart."Variable ID" := Output_ID;
        ActionExtractDatePart.Modify();

        ExpectedText := 'Extract day from Variable: a (Output to Variable: x)';

        // [WHEN] The function ExtractDatePartToString is called
        Text := ScriptSerialization.RuleActionToText(CaseID, ScriptID, "Action Type"::EXTRACTDATEPART, ActionID, "Action Group Type"::" ");
        UnbindSubscription(LibraryScriptSymbolLookup);

        // [THEN] It should return Extract Date Part as text
        Assert.AreEqual(ExpectedText, Text, StrSubstNo('%1 - expected', ExpectedText));
    end;

    [Test]
    procedure TestExtractDateTimePartToString()
    var
        ActionExtractDateTimePart: Record "Action Extract DateTime Part";
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        ScriptSerialization: Codeunit "Script Serialization";
        CaseID, ScriptID, ActionID, DateTimeLookupID : Guid;
        DateTime_ID, Output_ID : Integer;
        Text: Text;
        ExpectedText: Text;
    begin
        // [SCENARIO] Serialize 'Action Extract DateTime Part' to String

        // [GIVEN] Action ID of 'Action Extract DateTime Part' Record
        BindSubscription(LibraryScriptSymbolLookup);
        LibraryScriptTests.CreateExtractDateTimePart(CaseID, ScriptID, ActionID);
        DateTime_ID := 1000;
        Output_ID := 1002;

        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, DateTime_ID, 'a', "Symbol Data Type"::DATETIME);
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, Output_ID, 'x', "Symbol Data Type"::TIME);

        DateTimeLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, 0, 0, "Symbol Type"::Variable);
        ScriptSymbolLookup.Get(CaseID, ScriptID, DateTimeLookupID);
        ScriptSymbolLookup."Source Type" := ScriptSymbolLookup."Source Type"::Variable;
        ScriptSymbolLookup."Source Field ID" := DateTime_ID;
        ScriptSymbolLookup.Modify();

        ActionExtractDateTimePart.Get(CaseID, ScriptID, ActionID);
        ActionExtractDateTimePart."Value Type" := ActionExtractDateTimePart."Value Type"::Lookup;
        ActionExtractDateTimePart."Lookup ID" := DateTimeLookupID;
        ActionExtractDateTimePart."Part Type" := ActionExtractDateTimePart."Part Type"::Time;
        ActionExtractDateTimePart."Variable ID" := Output_ID;
        ActionExtractDateTimePart.Modify();

        ExpectedText := 'Extract time from Variable: a (Output to Variable: x)';

        // [WHEN] The function ExtractDateTimePartToString is called
        Text := ScriptSerialization.RuleActionToText(CaseID, ScriptID, "Action Type"::EXTRACTDATETIMEPART, ActionID, "Action Group Type"::" ");
        UnbindSubscription(LibraryScriptSymbolLookup);

        // [THEN] It should return Extract DateTime Part as text
        Assert.AreEqual(ExpectedText, Text, StrSubstNo('%1 - expected', ExpectedText));
    end;

    [Test]
    procedure TestLengthOfStringToString()
    var
        ActionLengthOfString: Record "Action Length Of String";
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        ScriptSerialization: Codeunit "Script Serialization";
        CaseID, ScriptID, ActionID, StringLookupID : Guid;
        String_ID, Output_ID : Integer;
        Text: Text;
        ExpectedText: Text;
    begin
        // [SCENARIO] Serialize 'Action Length Of String' to String

        // [GIVEN] Action ID of 'Action Length Of String' Record
        BindSubscription(LibraryScriptSymbolLookup);
        LibraryScriptTests.CreateLengthOfString(CaseID, ScriptID, ActionID);
        String_ID := 1000;
        Output_ID := 1002;

        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, String_ID, 'a', "Symbol Data Type"::STRING);
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, Output_ID, 'x', "Symbol Data Type"::NUMBER);

        StringLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, 0, 0, "Symbol Type"::Variable);
        ScriptSymbolLookup.Get(CaseID, ScriptID, StringLookupID);
        ScriptSymbolLookup."Source Type" := ScriptSymbolLookup."Source Type"::Variable;
        ScriptSymbolLookup."Source Field ID" := String_ID;
        ScriptSymbolLookup.Modify();

        ActionLengthOfString.Get(CaseID, ScriptID, ActionID);
        ActionLengthOfString."Value Type" := ActionLengthOfString."Value Type"::Lookup;
        ActionLengthOfString."Lookup ID" := StringLookupID;
        ActionLengthOfString."Variable ID" := Output_ID;
        ActionLengthOfString.Modify();

        ExpectedText := 'Extract length of Variable: a (Output to Variable: x)';

        // [WHEN] The function LengthOfStringToString is called
        Text := ScriptSerialization.RuleActionToText(CaseID, ScriptID, "Action Type"::LENGTHOFSTRING, ActionID, "Action Group Type"::" ");
        UnbindSubscription(LibraryScriptSymbolLookup);

        // [THEN] It should return Length of String as text
        Assert.AreEqual(ExpectedText, Text, StrSubstNo('%1 - expected', ExpectedText));
    end;

    [Test]
    procedure TestConvertCaseToString()
    var
        ActionConvertCase: Record "Action Convert Case";
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        ScriptSerialization: Codeunit "Script Serialization";
        CaseID, ScriptID, ActionID, StringLookupID : Guid;
        String_ID, Output_ID : Integer;
        Text: Text;
        ExpectedText: Text;
    begin
        // [SCENARIO] Serialize 'Action Convert Case' to String

        // [GIVEN] Action ID of 'Action Convert Case' Record
        BindSubscription(LibraryScriptSymbolLookup);
        LibraryScriptTests.CreateConvertCaseOfString(CaseID, ScriptID, ActionID);
        String_ID := 1000;
        Output_ID := 1002;

        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, String_ID, 'a', "Symbol Data Type"::STRING);
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, Output_ID, 'x', "Symbol Data Type"::STRING);

        StringLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, 0, 0, "Symbol Type"::Variable);
        ScriptSymbolLookup.Get(CaseID, ScriptID, StringLookupID);
        ScriptSymbolLookup."Source Type" := ScriptSymbolLookup."Source Type"::Variable;
        ScriptSymbolLookup."Source Field ID" := String_ID;
        ScriptSymbolLookup.Modify();

        ActionConvertCase.Get(CaseID, ScriptID, ActionID);
        ActionConvertCase."Value Type" := ActionConvertCase."Value Type"::Lookup;
        ActionConvertCase."Lookup ID" := StringLookupID;
        ActionConvertCase."Variable ID" := Output_ID;
        ActionConvertCase.Modify();

        ExpectedText := 'Convert Variable: a to upper case (Output to Variable: x)';

        // [WHEN] The function ConvertCaseToString is called
        Text := ScriptSerialization.RuleActionToText(CaseID, ScriptID, "Action Type"::CONVERTCASEOFSTRING, ActionID, "Action Group Type"::" ");
        UnbindSubscription(LibraryScriptSymbolLookup);

        // [THEN] It should return Convert Case as text
        Assert.AreEqual(ExpectedText, Text, StrSubstNo('%1 - expected', ExpectedText));
    end;

    [Test]
    procedure TestRoundNumberToString()
    var
        ActionRoundNumber: Record "Action Round Number";
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        ScriptSerialization: Codeunit "Script Serialization";
        CaseID, ScriptID, ActionID, NumberLookupID, PrecisionLookupID : Guid;
        Number_ID, Precision_ID, Output_ID : Integer;
        Text: Text;
        ExpectedText: Text;
    begin
        // [SCENARIO] Serialize 'Action Round Number' to String

        // [GIVEN] Action ID of 'Action Round Number' Record
        BindSubscription(LibraryScriptSymbolLookup);
        LibraryScriptTests.CreateRoundNumber(CaseID, ScriptID, ActionID);
        Number_ID := 1000;
        Precision_ID := 1001;
        Output_ID := 1002;

        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, Number_ID, 'a', "Symbol Data Type"::NUMBER);
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, Precision_ID, 'b', "Symbol Data Type"::NUMBER);
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, Output_ID, 'x', "Symbol Data Type"::NUMBER);

        NumberLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, 0, 0, "Symbol Type"::Variable);
        ScriptSymbolLookup.Get(CaseID, ScriptID, NumberLookupID);
        ScriptSymbolLookup."Source Type" := ScriptSymbolLookup."Source Type"::Variable;
        ScriptSymbolLookup."Source Field ID" := Number_ID;
        ScriptSymbolLookup.Modify();

        PrecisionLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, 0, 0, "Symbol Type"::Variable);
        ScriptSymbolLookup.Get(CaseID, ScriptID, PrecisionLookupID);
        ScriptSymbolLookup."Source Type" := ScriptSymbolLookup."Source Type"::Variable;
        ScriptSymbolLookup."Source Field ID" := Precision_ID;
        ScriptSymbolLookup.Modify();

        ActionRoundNumber.Get(CaseID, ScriptID, ActionID);
        ActionRoundNumber."Number Value Type" := ActionRoundNumber."Number Value Type"::Lookup;
        ActionRoundNumber."Number Lookup ID" := NumberLookupID;
        ActionRoundNumber."Variable ID" := Output_ID;
        ActionRoundNumber."Precision Value Type" := ActionRoundNumber."Precision Value Type"::Lookup;
        ActionRoundNumber."Precision Lookup ID" := PrecisionLookupID;
        ActionRoundNumber.Direction := ActionRoundNumber.Direction::Nearest;
        ActionRoundNumber.Modify();

        ExpectedText := 'Round Variable: a to nearest with precision Variable: b (Output to Variable: x)';

        // [WHEN] The function RoundNumberToString is called
        Text := ScriptSerialization.RuleActionToText(CaseID, ScriptID, "Action Type"::ROUNDNUMBER, ActionID, "Action Group Type"::" ");
        UnbindSubscription(LibraryScriptSymbolLookup);

        // [THEN] It should return Round Number as text
        Assert.AreEqual(ExpectedText, Text, StrSubstNo('%1 - expected', ExpectedText));
    end;

    [Test]
    procedure TestNumberExpressionToString()
    var
        ActionNumberExpression: Record "Action Number Expression";
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        ScriptSerialization: Codeunit "Script Serialization";
        CaseID, ScriptID, ActionID, NumberLookupID, Number2LookupID : Guid;
        Output_ID, Number_ID, Number2_ID : Integer;
        Text: Text;
        ExpectedText: Text;
    begin
        // [SCENARIO] Serialize 'Action Number Expression' to String

        // [GIVEN] Action ID of 'Action Number Expression' Record
        BindSubscription(LibraryScriptSymbolLookup);
        LibraryScriptTests.CreateNumericExpression(CaseID, ScriptID, ActionID);
        Number_ID := 1000;
        Number2_ID := 1001;
        Output_ID := 1002;

        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, Number_ID, 'a', "Symbol Data Type"::NUMBER);
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, Number2_ID, 'b', "Symbol Data Type"::NUMBER);
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, Output_ID, 'x', "Symbol Data Type"::NUMBER);

        NumberLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, 0, 0, "Symbol Type"::Variable);
        ScriptSymbolLookup.Get(CaseID, ScriptID, NumberLookupID);
        ScriptSymbolLookup."Source Type" := ScriptSymbolLookup."Source Type"::Variable;
        ScriptSymbolLookup."Source Field ID" := Number_ID;
        ScriptSymbolLookup.Modify();
        LibraryScriptTests.AddNumericExpression(CaseID, ScriptID, ActionID, 'a', NumberLookupID);

        Number2LookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, 0, 0, "Symbol Type"::Variable);
        ScriptSymbolLookup.Get(CaseID, ScriptID, Number2LookupID);
        ScriptSymbolLookup."Source Type" := ScriptSymbolLookup."Source Type"::Variable;
        ScriptSymbolLookup."Source Field ID" := Number2_ID;
        ScriptSymbolLookup.Modify();
        LibraryScriptTests.AddNumericExpression(CaseID, ScriptID, ActionID, 'b', Number2LookupID);

        ActionNumberExpression.Get(CaseID, ScriptID, ActionID);
        ActionNumberExpression.Expression := 'a + b';
        ActionNumberExpression."Variable ID" := Output_ID;
        ActionNumberExpression.Modify();

        ExpectedText := 'Evaluate "a + b", a equals Variable: a, b equals Variable: b (Output to Variable: x)';

        // [WHEN] The function NumberExpression is called
        Text := ScriptSerialization.RuleActionToText(CaseID, ScriptID, "Action Type"::NUMERICEXPRESSION, ActionID, "Action Group Type"::" ");
        UnbindSubscription(LibraryScriptSymbolLookup);

        // [THEN] It should return Number Expression as text
        Assert.AreEqual(ExpectedText, Text, StrSubstNo('%1 - expected', ExpectedText));
    end;

    [Test]
    procedure TestStringExpressionToString()
    var
        ActionStringExpression: Record "Action String Expression";
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        ScriptSerialization: Codeunit "Script Serialization";
        CaseID, ScriptID, ActionID, StringLookupID, String2LookupID : Guid;
        Output_ID, String_ID, String2_ID : Integer;
        Text: Text;
        ExpectedText: Text;
    begin
        // [SCENARIO] Serialize 'Action String Expression' to String

        // [GIVEN] Action ID of 'Action String Expression' Record
        BindSubscription(LibraryScriptSymbolLookup);
        LibraryScriptTests.CreateStringExpression(CaseID, ScriptID, ActionID);
        String_ID := 1000;
        String2_ID := 1001;
        Output_ID := 1002;

        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, String_ID, 'a', "Symbol Data Type"::STRING);
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, String2_ID, 'b', "Symbol Data Type"::STRING);
        LibraryScriptTests.CreateScriptVariable(CaseID, ScriptID, Output_ID, 'x', "Symbol Data Type"::STRING);

        StringLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, 0, 0, "Symbol Type"::Variable);
        ScriptSymbolLookup.Get(CaseID, ScriptID, StringLookupID);
        ScriptSymbolLookup."Source Type" := ScriptSymbolLookup."Source Type"::Variable;
        ScriptSymbolLookup."Source Field ID" := String_ID;
        ScriptSymbolLookup.Modify();
        LibraryScriptTests.AddStringExpression(CaseID, ScriptID, ActionID, 'a', StringLookupID);

        String2LookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, 0, 0, "Symbol Type"::Variable);
        ScriptSymbolLookup.Get(CaseID, ScriptID, String2LookupID);
        ScriptSymbolLookup."Source Type" := ScriptSymbolLookup."Source Type"::Variable;
        ScriptSymbolLookup."Source Field ID" := String2_ID;
        ScriptSymbolLookup.Modify();
        LibraryScriptTests.AddStringExpression(CaseID, ScriptID, ActionID, 'b', String2LookupID);

        ActionStringExpression.Get(CaseID, ScriptID, ActionID);
        ActionStringExpression.Expression := '{a} + {b}';
        ActionStringExpression."Variable ID" := Output_ID;
        ActionStringExpression.Modify();

        ExpectedText := 'Evaluate "{a} + {b}",  (Output to Variable: x)';

        // [WHEN] The function StringExpression is called
        Text := ScriptSerialization.RuleActionToText(CaseID, ScriptID, "Action Type"::STRINGEXPRESSION, ActionID, "Action Group Type"::" ");
        UnbindSubscription(LibraryScriptSymbolLookup);

        // [THEN] It should return String Expression as text
        Assert.AreEqual(ExpectedText, Text, StrSubstNo('%1 - expected', ExpectedText));
    end;

    [Test]
    procedure TestLookupTableToString()
    var
        AllObj: Record AllObj;
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        ScriptSerialization: Codeunit "Script Serialization";
        CaseID, ScriptID, TableFilterID, StringLookupID : Guid;
        Text: Text;
        ExpectedText: Text;
    begin
        // [SCENARIO] Serialize 'Lookup Table Filter' to String

        // [GIVEN] ID of 'Lookup Table Filter' Record
        BindSubscription(LibraryScriptSymbolLookup);

        LibraryScriptTests.CreateLookupTableFilter(CaseID, ScriptID, TableFilterID, Database::AllObj);
        LibraryScriptTests.AddFieldFilter(CaseID, ScriptID, TableFilterID, Database::AllObj, AllObj.FieldNo("Object Type"), 'Table');
        LibraryScriptTests.AddFieldFilter(CaseID, ScriptID, TableFilterID, Database::AllObj, AllObj.FieldNo("Object ID"), '3');

        StringLookupID := LibraryScriptSymbolLookup.CreateLookup(
            CaseID, ScriptID, Database::AllObj, AllObj.FieldNo("Object Name"), "Symbol Type"::Table);

        ScriptSymbolLookup.Get(CaseID, ScriptID, StringLookupID);
        ScriptSymbolLookup."Table Method" := ScriptSymbolLookup."Table Method"::Last;
        ScriptSymbolLookup."Table Filter ID" := TableFilterID;
        ScriptSymbolLookup.Modify();

        ExpectedText := 'last of "Object Name" from AllObj (where Object Type Equals ''Table'',Object ID Equals ''3.00'')';

        Text := ScriptSerialization.LookupTableToString(ScriptSymbolLookup);
        UnbindSubscription(LibraryScriptSymbolLookup);
        // [THEN] It should return Lookup Table as text
        Assert.AreEqual(ExpectedText, Text, StrSubstNo('%1 - expected', ExpectedText));
    end;

    [Test]
    procedure TestTableSortingToString()
    var
        AllObj: Record AllObj;
        LibraryScriptTests: Codeunit "Library - Script Tests";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        ScriptSerialization: Codeunit "Script Serialization";
        CaseID, ScriptID, TableSortingID : Guid;
        Text: Text;
        ExpectedText: Text;
    begin
        // [SCENARIO] Serialize 'Lookup Table Sorting' to String

        // [GIVEN] ID of 'Lookup Table Sorting' Record
        BindSubscription(LibraryScriptSymbolLookup);

        LibraryScriptTests.CreateLookupTableSorting(CaseID, ScriptID, TableSortingID, Database::AllObj);
        LibraryScriptTests.AddFieldSorting(CaseID, ScriptID, TableSortingID, Database::AllObj, AllObj.FieldNo("Object Type"));
        LibraryScriptTests.AddFieldSorting(CaseID, ScriptID, TableSortingID, Database::AllObj, AllObj.FieldNo("Object ID"));

        ExpectedText := '"Object Type","Object ID"';

        // [WHEN] The function TableSortingToString is called
        Text := ScriptSerialization.TableSortingToString(CaseID, ScriptID, TableSortingID);
        UnbindSubscription(LibraryScriptSymbolLookup);

        // [THEN] It should return Table Sorting as text
        Assert.AreEqual(ExpectedText, Text, StrSubstNo('%1 - expected', ExpectedText));
    end;
}