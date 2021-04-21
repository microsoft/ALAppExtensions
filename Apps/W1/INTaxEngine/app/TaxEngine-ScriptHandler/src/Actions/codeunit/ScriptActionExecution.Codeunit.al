codeunit 20157 "Script Action Execution"
{
    procedure ExecuteScript(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid);
    begin
        ExecuteContainerItem(
            SymbolStore,
            SourceRecRef,
            CaseID,
            ScriptID,
            "Container Action Type"::USECASE,
            CaseID);
    end;

    local procedure ExecuteContainerItem(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid;
        ContainerType: Enum "Container Action Type";
        ContainerID: Guid);
    var
        ActionContainer: Record "Action Container";
    begin
        ActionContainer.Reset();
        ActionContainer.SetRange("Case ID", CaseID);
        ActionContainer.SetRange("Script ID", ScriptID);
        ActionContainer.SetRange("Container Type", ContainerType);
        ActionContainer.SetRange("Container Action ID", ContainerID);
        if ActionContainer.FindSet() then
            repeat
                ExecuteItem(
                    SymbolStore,
                    SourceRecRef,
                    CaseID,
                    ScriptID,
                    ActionContainer."Action Type",
                    ActionContainer."Action ID");
            until (ActionContainer.Next() = 0) or (ExitLoop) or (ContinueLoop);
    end;

    local procedure ExecuteItem(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid;
        ActionType: Enum "Action Type";
        ActionID: Guid);
    var
        ActionNotImplementedErr: Label 'Action Type %1 not implemented', Comment = '%1 = ActionType';
    begin
        if ExitLoop or ContinueLoop then
            exit;

        case ActionType of
            ActionType::COMMENT:
                ;
            ActionType::IFSTATEMENT:
                ExecuteIfCondition(SymbolStore, SourceRecRef, CaseID, ScriptID, ActionID);
            ActionType::LOOPNTIMES:
                ExecuteLoopNTimes(SymbolStore, SourceRecRef, CaseID, ScriptID, ActionID);
            ActionType::LOOPWITHCONDITION:
                ExecuteLoopWithCondition(SymbolStore, SourceRecRef, CaseID, ScriptID, ActionID);
            ActionType::LOOPTHROUGHRECORDS:
                ExecuteLoopThroughRecords(SymbolStore, SourceRecRef, CaseID, ScriptID, ActionID);
            ActionType::NUMBERCALCULATION:
                ExecuteNumberCalculation(SymbolStore, SourceRecRef, CaseID, ScriptID, ActionID);
            ActionType::CONCATENATE:
                ExecuteConcatenate(SymbolStore, SourceRecRef, CaseID, ScriptID, ActionID);
            ActionType::SETVARIABLE:
                ExecuteSetVariable(SymbolStore, SourceRecRef, CaseID, ScriptID, ActionID);
            ActionType::ALERTMESSAGE:
                ExecuteAlertMessage(SymbolStore, SourceRecRef, CaseID, ScriptID, ActionID);
            ActionType::FINDSUBSTRINGINSTRING:
                ExecuteFindSubstringInString(SymbolStore, SourceRecRef, CaseID, ScriptID, ActionID);
            ActionType::REPLACESUBSTRINGINSTRING:
                ExecuteReplaceSubstringInString(SymbolStore, SourceRecRef, CaseID, ScriptID, ActionID);
            ActionType::CONVERTCASEOFSTRING:
                ExecuteConvertCaseOfString(SymbolStore, SourceRecRef, CaseID, ScriptID, ActionID);
            ActionType::LENGTHOFSTRING:
                ExecuteLengthOfString(SymbolStore, SourceRecRef, CaseID, ScriptID, ActionID);
            ActionType::EXTRACTSUBSTRINGFROMINDEXOFSTRING:
                ExecuteExtractSubstringFromIndexOfString(SymbolStore, SourceRecRef, CaseID, ScriptID, ActionID);
            ActionType::EXTRACTSUBSTRINGFROMPOSITION:
                ExecuteExtractSubstringFromPosition(SymbolStore, SourceRecRef, CaseID, ScriptID, ActionID);
            ActionType::EXTRACTDATEPART:
                ExecuteExtractDatePart(SymbolStore, SourceRecRef, CaseID, ScriptID, ActionID);
            ActionType::EXTRACTDATETIMEPART:
                ExecuteExtractDateTimePart(SymbolStore, SourceRecRef, CaseID, ScriptID, ActionID);
            ActionType::DATECALCULATION:
                ExecuteDateCalculation(SymbolStore, SourceRecRef, CaseID, ScriptID, ActionID);
            ActionType::DATETODATETIME:
                ExecuteDateToDateTime(SymbolStore, SourceRecRef, CaseID, ScriptID, ActionID);
            ActionType::FINDINTERVALBETWEENDATES:
                ExecuteFindIntervalBetweenDates(SymbolStore, SourceRecRef, CaseID, ScriptID, ActionID);
            ActionType::ROUNDNUMBER:
                ExecuteRoundNumber(SymbolStore, SourceRecRef, CaseID, ScriptID, ActionID);
            ActionType::NUMERICEXPRESSION:
                ExecuteNumberExpression(SymbolStore, SourceRecRef, CaseID, ScriptID, ActionID);
            ActionType::STRINGEXPRESSION:
                ExecuteStringExpression(SymbolStore, SourceRecRef, CaseID, ScriptID, ActionID);
            ActionType::EXITLOOP:
                ExitLoop := true;
            ActionType::CONTINUE:
                ContinueLoop := true;
            else
                Error(ActionNotImplementedErr, ActionType);
        end;
    end;

    local procedure ExecuteIfCondition(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid;
        ActionID: Guid);
    var
        IfStatement: Record "Action If Statement";
        ConditionOk: Boolean;
    begin
        IfStatement.GET(CaseID, ScriptID, ActionID);

        if SkipItemID = ActionID then begin
            SkipItemID := IfStatement."Else If Block ID";
            exit;
        end;

        if not IsNullGuid(IfStatement."Condition ID") then
            ConditionOk := ConditionMgmt.CheckCondition(
                SymbolStore,
                SourceRecRef,
                CaseID,
                ScriptID,
                IfStatement."Condition ID")
        else
            ConditionOk := true;

        if ConditionOk then
            ExecuteContainerItem(
                SymbolStore,
                SourceRecRef,
                IfStatement."Case ID",
                IfStatement."Script ID",
                "Container Action Type"::IFSTATEMENT,
                ActionID)
        else
            if not IsNullGuid(IfStatement."Else If Block ID") then
                ExecuteIfCondition(SymbolStore, SourceRecRef, CaseID, ScriptID, IfStatement."Else If Block ID");

        SkipItemID := IfStatement."Else If Block ID";

    end;

    local procedure ExecuteLoopNTimes(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid;
        ActionID: Guid);
    var
        ActionLoopNTimes: Record "Action Loop N Times";
        Counter: Integer;
        NumberOfTimesVar: Variant;
        NumberOfTimes: Integer;
        Index: Integer;
    begin
        ActionLoopNTimes.GET(CaseID, ScriptID, ActionID);
        Counter := 0;
        SymbolStore.GetConstantOrLookupValue(
            SourceRecRef,
            ActionLoopNTimes."Case ID",
            ActionLoopNTimes."Script ID",
            ActionLoopNTimes."Value Type",
            ActionLoopNTimes.Value,
            ActionLoopNTimes."Lookup ID",
            NumberOfTimesVar);

        NumberOfTimes := NumberOfTimesVar;
        if NumberOfTimes < 1 then
            exit;

        Index := 1;
        repeat
            if ActionLoopNTimes."Index Variable" <> 0 then
                SymbolStore.SetSymbol2("Symbol Type"::Variable, ActionLoopNTimes."Index Variable", Index);

            ExecuteContainerItem(
                SymbolStore,
                SourceRecRef,
                ActionLoopNTimes."Case ID",
                ActionLoopNTimes."Script ID",
                "Container Action Type"::LOOPNTIMES,
                ActionID);
            Counter += 1;

            ContinueLoop := false;
            Index += 1;
        until (Counter = NumberOfTimes) or (ExitLoop);

        ExitLoop := false;

    end;

    local procedure ExecuteLoopWithCondition(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid;
        ActionID: Guid);
    var
        ActionLoopWithCondition: Record "Action Loop With Condition";
        ConditionOk: Boolean;
    begin
        ActionLoopWithCondition.GET(CaseID, ScriptID, ActionID);
        ConditionOk := ConditionMgmt.CheckCondition(
            SymbolStore,
            SourceRecRef,
            ActionLoopWithCondition."Case ID",
            ActionLoopWithCondition."Script ID",
            ActionLoopWithCondition."Condition ID");
        if not ConditionOk then
            exit;

        while (ConditionOk) and (not ExitLoop) do begin
            ExecuteContainerItem(
                SymbolStore,
                SourceRecRef,
                ActionLoopWithCondition."Case ID",
                ActionLoopWithCondition."Script ID",
                "Container Action Type"::LOOPWITHCONDITION,
                ActionID);
            ConditionOk := ConditionMgmt.CheckCondition(
                SymbolStore,
                SourceRecRef,
                ActionLoopWithCondition."Case ID",
                ActionLoopWithCondition."Script ID",
                ActionLoopWithCondition."Condition ID");
            ContinueLoop := false;
        end;
        ExitLoop := false;

    end;

    local procedure ExecuteLoopThroughRecords(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid;
        ActionID: Guid);
    var
        ActionLoopThroughRecords: Record "Action Loop Through Records";
        RecordRef: RecordRef;
        ConditionOk: Boolean;
        Index: Integer;
    begin
        ActionLoopThroughRecords.GET(CaseID, ScriptID, ActionID);
        RecordRef.OPEN(ActionLoopThroughRecords."Table ID");

        if not IsNullGuid(ActionLoopThroughRecords."Table Sorting ID") then
            RecordRef.SETVIEW(
                StrSubstNo(
                    SortingTxt,
                    LookupSerialization.TableSortingToString(
                        ActionLoopThroughRecords."Case ID",
                        ActionLoopThroughRecords."Script ID",
                        ActionLoopThroughRecords."Table Sorting ID"),
                        ActionLoopThroughRecords.Order));

        if not IsNullGuid(ActionLoopThroughRecords."Table Filter ID") then
            SymbolStore.ApplyTableFilters(SourceRecRef, ActionLoopThroughRecords."Case ID", ActionLoopThroughRecords."Script ID", RecordRef, ActionLoopThroughRecords."Table Filter ID");

        ConditionOk := RecordRef.FindSet();
        if not ConditionOk then
            exit;

        if ActionLoopThroughRecords."Count Variable" <> 0 then
            SymbolStore.SetSymbol2("Symbol Type"::Variable, ActionLoopThroughRecords."Count Variable", RecordRef.Count());

        Index := 1;
        while (ConditionOk) and (not ExitLoop) do begin
            if ActionLoopThroughRecords."Index Variable" <> 0 then
                SymbolStore.SetSymbol2("Symbol Type"::Variable, ActionLoopThroughRecords."Index Variable", Index);

            SetLoopThroughRecordFields(SymbolStore, CaseID, ScriptID, ActionID, RecordRef);
            ExecuteContainerItem(
                SymbolStore,
                SourceRecRef,
                ActionLoopThroughRecords."Case ID",
                ActionLoopThroughRecords."Script ID",
                "Container Action Type"::LOOPTHROUGHRECORDS,
                ActionID);

            if ActionLoopThroughRecords.Distinct then
                MoveToLastRecord(ActionLoopThroughRecords."Case ID", ActionLoopThroughRecords."Script ID", RecordRef, ActionLoopThroughRecords."Table Sorting ID");

            ConditionOk := RecordRef.Next() <> 0;

            Index += 1;
            ContinueLoop := false;
        end;

        ExitLoop := false;
        RecordRef.Close();

    end;

    local procedure MoveToLastRecord(CaseID: Guid; ScriptID: Guid; var RecordRef: RecordRef; SortingID: Guid);
    var
        LookupTableSorting: Record "Lookup Table Sorting";
        LookupFieldSorting: Record "Lookup Field Sorting";
        FieldRef: FieldRef;
    begin
        if IsNullGuid(SortingID) then
            exit;

        RecordRef.FilterGroup := 4;
        LookupTableSorting.GET(CaseID, ScriptID, SortingID);
        LookupFieldSorting.Reset();
        LookupFieldSorting.SetRange("Case ID", CaseID);
        LookupFieldSorting.SetRange("Script ID", ScriptID);
        LookupFieldSorting.SetRange("Table Sorting ID", SortingID);
        if LookupFieldSorting.FindSet() then
            repeat
                FieldRef := RecordRef.Field(LookupFieldSorting."Field ID");
                FieldRef.SetRange(FieldRef.Value());
            until LookupFieldSorting.Next() = 0;

        RecordRef.FindLast();
        if LookupFieldSorting.FindSet() then
            repeat
                FieldRef := RecordRef.Field(LookupFieldSorting."Field ID");
                FieldRef.SetRange();
            until LookupFieldSorting.Next() = 0;

        RecordRef.FilterGroup := 0;
    end;

    local procedure SetLoopThroughRecordFields(
        var SymbolStore: Codeunit "Script Symbol Store";
        CaseID: Guid;
        ScriptID: Guid;
        ActionID: Guid;
        var RecordRef: RecordRef);
    var
        ActionLoopThroughRecField: Record "Action Loop Through Rec. Field";
        FieldRef: FieldRef;
    begin
        ActionLoopThroughRecField.Reset();
        ActionLoopThroughRecField.SetRange("Case ID", CaseID);
        ActionLoopThroughRecField.SetRange("Script ID", ScriptID);
        ActionLoopThroughRecField.SetRange("Loop ID", ActionID);
        if ActionLoopThroughRecField.FindSet() then
            repeat
                FieldRef := RecordRef.Field(ActionLoopThroughRecField."Field ID");
                if ActionLoopThroughRecField."Calculate Sum" then
                    FieldRef.CalcSum();

                if Format(FieldRef.Class()) = 'FlowField' then
                    FieldRef.CalcField();

                SymbolStore.SetSymbol2(
                    "Symbol Type"::Variable,
                    ActionLoopThroughRecField."Variable ID",
                    FieldRef.Value());
            until ActionLoopThroughRecField.Next() = 0;
    end;

    local procedure ExecuteNumberCalculation(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid;
        ActionID: Guid);
    var
        ActionNumberCalculation: Record "Action Number Calculation";
        LHSValue: Variant;
        RHSValue: Variant;
        OutputValue: Variant;
    begin
        ActionNumberCalculation.GET(CaseID, ScriptID, ActionID);
        SymbolStore.GetConstantOrLookupValueOfType(
            SourceRecRef,
            ActionNumberCalculation."Case ID",
            ActionNumberCalculation."Script ID",
            ActionNumberCalculation."LHS Type",
            ActionNumberCalculation."LHS Value",
            ActionNumberCalculation."LHS Lookup ID",
            "Symbol Data type"::NUMBER,
            '',
            LHSValue);

        SymbolStore.GetConstantOrLookupValueOfType(
            SourceRecRef,
            ActionNumberCalculation."Case ID",
            ActionNumberCalculation."Script ID",
            ActionNumberCalculation."RHS Type",
            ActionNumberCalculation."RHS Value",
            ActionNumberCalculation."RHS Lookup ID",
            "Symbol Data type"::NUMBER,
            '',
            RHSValue);

        ConditionMgmt.CalculateVariants(
            LHSValue,
            RHSValue,
            ActionNumberCalculation."Arithmetic Operator",
            OutputValue);

        SymbolStore.SetSymbol2(
            "Symbol Type"::Variable,
            ActionNumberCalculation."Variable ID",
            OutputValue);
    end;

    local procedure ExecuteConcatenate(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid;
        ActionID: Guid);
    var
        ActionConcatenate: Record "Action Concatenate";
        ActionConcatenateLine: Record "Action Concatenate Line";
        OutputText: Text;
        LookupValue: Variant;
    begin
        ActionConcatenate.GET(CaseID, ScriptID, ActionID);
        ActionConcatenateLine.Reset();
        ActionConcatenateLine.SetRange("Script ID", ActionConcatenate."Script ID");
        ActionConcatenateLine.SetRange("Concatenate ID", ActionConcatenate.ID);
        if ActionConcatenateLine.FindSet() then
            repeat
                SymbolStore.GetConstantOrLookupValue(
                    SourceRecRef,
                    ActionConcatenateLine."Case ID",
                    ActionConcatenateLine."Script ID",
                    ActionConcatenateLine."Value Type",
                    ActionConcatenateLine.Value,
                    ActionConcatenateLine."Lookup ID",
                    LookupValue);

                OutputText += Format(LookupValue);
            until ActionConcatenateLine.Next() = 0;

        SymbolStore.SetSymbol2("Symbol Type"::Variable, ActionConcatenate."Variable ID", OutputText);
    end;

    local procedure ExecuteSetVariable(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid;
        ActionID: Guid);
    var
        ActionSetVariable: Record "Action Set Variable";
        OutputValue: Variant;
    begin
        ActionSetVariable.GET(CaseID, ScriptID, ActionID);
        SymbolStore.GetConstantOrLookupValue(
            SourceRecRef,
            ActionSetVariable."Case ID",
            ActionSetVariable."Script ID",
            ActionSetVariable."Value Type",
            ActionSetVariable.Value,
            ActionSetVariable."Lookup ID",
            OutputValue);

        SymbolStore.SetSymbol2("Symbol Type"::Variable, ActionSetVariable."Variable ID", OutputValue);
    end;

    local procedure ExecuteAlertMessage(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid;
        ActionID: Guid);
    var
        ActionMessage: Record "Action Message";
        OutputValue: Variant;
        MessageText: Text;
    begin
        ActionMessage.GET(CaseID, ScriptID, ActionID);
        SymbolStore.GetConstantOrLookupValue(
            SourceRecRef,
            ActionMessage."Case ID",
            ActionMessage."Script ID",
            ActionMessage."Value Type",
            ActionMessage.Value,
            ActionMessage."Lookup ID",
            OutputValue);

        MessageText := ScriptDataTypeMgmt.Variant2Text(OutputValue, '');
        if ActionMessage."Throw Error" then
            Error(MessageText)
        else
            if GuiAllowed() then
                Message(MessageText);

    end;

    local procedure ExecuteFindSubstringInString(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid;
        ActionID: Guid);
    var
        ActionFindSubstring: Record "Action Find Substring";
        OutputValue: Variant;
        Substring: Text;
        String: Text;
        SubstringVariant: Variant;
        StringVariant: Variant;
    begin
        ActionFindSubstring.GET(CaseID, ScriptID, ActionID);
        SymbolStore.GetConstantOrLookupValue(
            SourceRecRef,
            ActionFindSubstring."Case ID",
            ActionFindSubstring."Script ID",
            ActionFindSubstring."Substring Value Type",
            ActionFindSubstring."Substring Value",
            ActionFindSubstring."Substring Lookup ID",
            SubstringVariant);

        SymbolStore.GetConstantOrLookupValue(SourceRecRef, ActionFindSubstring."Case ID", ActionFindSubstring."Script ID", ActionFindSubstring."String Value Type", ActionFindSubstring."String Value", ActionFindSubstring."String Lookup ID", StringVariant);

        String := StringVariant;
        Substring := SubstringVariant;

        OutputValue := StrPos(String, Substring);
        SymbolStore.SetSymbol2("Symbol Type"::Variable, ActionFindSubstring."Variable ID", OutputValue);
    end;

    local procedure ExecuteReplaceSubstringInString(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid;
        ActionID: Guid);
    var
        ActionReplaceSubstring: Record "Action Replace Substring";
        OutputValue: Variant;
        Substring: Text;
        String: Text;
        NewString: Text;
        SubstringVariant: Variant;
        StringVariant: Variant;
        NewStringVariant: Variant;
    begin
        ActionReplaceSubstring.GET(CaseID, ScriptID, ActionID);
        SymbolStore.GetConstantOrLookupValue(
            SourceRecRef,
            ActionReplaceSubstring."Case ID",
            ActionReplaceSubstring."Script ID",
            ActionReplaceSubstring."Substring Value Type",
            ActionReplaceSubstring."Substring Value",
            ActionReplaceSubstring."Substring Lookup ID",
            SubstringVariant);

        SymbolStore.GetConstantOrLookupValue(
            SourceRecRef,
            ActionReplaceSubstring."Case ID",
            ActionReplaceSubstring."Script ID",
            ActionReplaceSubstring."String Value Type",
            ActionReplaceSubstring."String Value",
            ActionReplaceSubstring."String Lookup ID",
            StringVariant);

        SymbolStore.GetConstantOrLookupValue(
            SourceRecRef,
            ActionReplaceSubstring."Case ID",
            ActionReplaceSubstring."Script ID",
            ActionReplaceSubstring."New String Value Type",
            ActionReplaceSubstring."New String Value",
            ActionReplaceSubstring."New String Lookup ID",
            NewStringVariant);

        Substring := SubstringVariant;
        String := StringVariant;
        NewString := NewStringVariant;

        OutputValue := ReplaceString(String, Substring, NewString);
        SymbolStore.SetSymbol2("Symbol Type"::Variable, ActionReplaceSubstring."Variable ID", OutputValue);

    end;

    local procedure ReplaceString(String: Text; SubString: Text; WithString: Text): Text;
    var
        Position: Integer;
        LeftString: Text;
        RightString: Text;
    begin
        Position := StrPos(String, SubString);
        if Position = 0 then
            exit(String);

        LeftString := CopyStr(String, 1, Position - 1);
        RightString := CopyStr(String, Position + StrLen(SubString));
        exit(LeftString + WithString + ReplaceString(RightString, SubString, WithString));
    end;

    local procedure ExecuteConvertCaseOfString(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid;
        ActionID: Guid);
    var
        ActionConvertCase: Record "Action Convert Case";
        String: Text;
        StringVariant: Variant;
        OutputValue: Variant;
    begin
        ActionConvertCase.GET(CaseID, ScriptID, ActionID);
        SymbolStore.GetConstantOrLookupValue(
            SourceRecRef,
            ActionConvertCase."Case ID",
            ActionConvertCase."Script ID",
            ActionConvertCase."Value Type",
            ActionConvertCase.Value,
            ActionConvertCase."Lookup ID",
            StringVariant);

        String := StringVariant;

        case ActionConvertCase."Convert To Case" of
            ActionConvertCase."Convert To Case"::"Lower Case":
                OutputValue := LOWERCASE(String);
            ActionConvertCase."Convert To Case"::"Upper Case":
                OutputValue := UpperCase(String);
        end;

        SymbolStore.SetSymbol2("Symbol Type"::Variable, ActionConvertCase."Variable ID", OutputValue);

    end;

    local procedure ExecuteLengthOfString(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid;
        ActionID: Guid);
    var
        ActionLengthOfString: Record "Action Length Of String";
        String: Text;
        StringVariant: Variant;
        OutputValue: Variant;
    begin
        ActionLengthOfString.GET(CaseID, ScriptID, ActionID);
        SymbolStore.GetConstantOrLookupValue(
            SourceRecRef,
            ActionLengthOfString."Case ID",
            ActionLengthOfString."Script ID",
            ActionLengthOfString."Value Type",
            ActionLengthOfString.Value,
            ActionLengthOfString."Lookup ID",
            StringVariant);

        String := StringVariant;

        OutputValue := StrLen(String);
        SymbolStore.SetSymbol2("Symbol Type"::Variable, ActionLengthOfString."Variable ID", OutputValue);

    end;

    local procedure ExecuteExtractSubstringFromIndexOfString(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid;
        ActionID: Guid);
    var
        ActionExtSubstrFromIndex: Record "Action Ext. Substr. From Index";
        OutputValue: Variant;
        Index: Integer;
        IndexVariant: Variant;
        String: Text;
        StringVariant: Variant;
        Length: Integer;
        LengthVariant: Variant;
    begin
        ActionExtSubstrFromIndex.GET(CaseID, ScriptID, ActionID);
        SymbolStore.GetConstantOrLookupValue(
            SourceRecRef,
            ActionExtSubstrFromIndex."Case ID",
            ActionExtSubstrFromIndex."Script ID",
            ActionExtSubstrFromIndex."String Value Type",
            ActionExtSubstrFromIndex."String Value",
            ActionExtSubstrFromIndex."String Lookup ID",
            StringVariant);

        SymbolStore.GetConstantOrLookupValue(
            SourceRecRef,
            ActionExtSubstrFromIndex."Case ID",
            ActionExtSubstrFromIndex."Script ID",
            ActionExtSubstrFromIndex."Index Value Type",
            ActionExtSubstrFromIndex."Index Value",
            ActionExtSubstrFromIndex."Index Lookup ID",
            IndexVariant);

        SymbolStore.GetConstantOrLookupValue(
            SourceRecRef,
            ActionExtSubstrFromIndex."Case ID",
            ActionExtSubstrFromIndex."Script ID",
            ActionExtSubstrFromIndex."Length Value Type",
            ActionExtSubstrFromIndex."Length Value",
            ActionExtSubstrFromIndex."Length Lookup ID",
            LengthVariant);

        String := StringVariant;
        Index := IndexVariant;
        Length := LengthVariant;

        if Length = 0 then
            OutputValue := CopyStr(String, Index)
        else
            OutputValue := CopyStr(String, Index, Length);

        SymbolStore.SetSymbol2("Symbol Type"::Variable, ActionExtSubstrFromIndex."Variable ID", OutputValue);

    end;

    local procedure ExecuteExtractSubstringFromPosition(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid;
        ActionID: Guid);
    var
        ActionExtSubstrFromPos: Record "Action Ext. Substr. From Pos.";
        OutputValue: Variant;
        String: Text;
        StringVariant: Variant;
        Length: Integer;
        LengthVariant: Variant;
    begin
        ActionExtSubstrFromPos.GET(CaseID, ScriptID, ActionID);
        SymbolStore.GetConstantOrLookupValue(
            SourceRecRef,
            ActionExtSubstrFromPos."Case ID",
            ActionExtSubstrFromPos."Script ID",
            ActionExtSubstrFromPos."String Value Type",
            ActionExtSubstrFromPos."String Value",
            ActionExtSubstrFromPos."String Lookup ID",
            StringVariant);

        SymbolStore.GetConstantOrLookupValue(
            SourceRecRef,
            ActionExtSubstrFromPos."Case ID",
            ActionExtSubstrFromPos."Script ID",
            ActionExtSubstrFromPos."Length Value Type",
            ActionExtSubstrFromPos."Length Value",
            ActionExtSubstrFromPos."Length Lookup ID",
            LengthVariant);

        String := StringVariant;
        Length := LengthVariant;

        case ActionExtSubstrFromPos.Position of
            ActionExtSubstrFromPos.Position::start:
                OutputValue := CopyStr(String, 1, Length);
            ActionExtSubstrFromPos.Position::"end":
                if StrLen(String) - Length > 0 then
                    OutputValue := CopyStr(String, StrLen(String) - Length + 1, Length)
                else
                    OutputValue := String;
        end;

        SymbolStore.SetSymbol2("Symbol Type"::Variable, ActionExtSubstrFromPos."Variable ID", OutputValue);

    end;

    local procedure ExecuteExtractDatePart(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid;
        ActionID: Guid);
    var
        ActionExtractDatePart: Record "Action Extract Date Part";
        OutputValue: Variant;
        DateValue: Date;
        DateVariant: Variant;
    begin
        ActionExtractDatePart.GET(CaseID, ScriptID, ActionID);
        SymbolStore.GetConstantOrLookupValueOfType(
            SourceRecRef,
            ActionExtractDatePart."Case ID",
            ActionExtractDatePart."Script ID",
            ActionExtractDatePart."Value Type",
            ActionExtractDatePart.Value,
            ActionExtractDatePart."Lookup ID",
            "Symbol Data Type"::DATE,
            '',
            DateVariant);

        DateValue := DateVariant;

        case ActionExtractDatePart."Date Part" of
            ActionExtractDatePart."Date Part"::Day:
                OutputValue := DATE2DMY(DateValue, 1);
            ActionExtractDatePart."Date Part"::Month:
                OutputValue := DATE2DMY(DateValue, 2);
            ActionExtractDatePart."Date Part"::Year:
                OutputValue := DATE2DMY(DateValue, 3);
        end;

        SymbolStore.SetSymbol2("Symbol Type"::Variable, ActionExtractDatePart."Variable ID", OutputValue);

    end;

    local procedure ExecuteExtractDateTimePart(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid;
        ActionID: Guid);
    var
        ExtractDateTimePart: Record "Action Extract DateTime Part";
        OutputValue: Variant;
        DateTimeValue: DateTime;
        DateTimeVariant: Variant;
    begin
        ExtractDateTimePart.GET(CaseID, ScriptID, ActionID);
        SymbolStore.GetConstantOrLookupValue(
            SourceRecRef,
            ExtractDateTimePart."Case ID",
            ExtractDateTimePart."Script ID",
            ExtractDateTimePart."Value Type",
            ExtractDateTimePart.Value,
            ExtractDateTimePart."Lookup ID",
            DateTimeVariant);

        DateTimeValue := DateTimeVariant;

        case ExtractDateTimePart."Part Type" of
            ExtractDateTimePart."Part Type"::Date:
                OutputValue := DT2DATE(DateTimeValue);
            ExtractDateTimePart."Part Type"::Time:
                OutputValue := DT2TIME(DateTimeValue);
        end;

        SymbolStore.SetSymbol2("Symbol Type"::Variable, ExtractDateTimePart."Variable ID", OutputValue);

    end;

    local procedure ExecuteDateCalculation(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid;
        ActionID: Guid);
    var
        ActionDateCalculation: Record "Action Date Calculation";
        OutputValue: Variant;
        DateValue: Date;
        DateVariant: Variant;
        NumberValue: Integer;
        NumberVariant: Variant;
        Sign: Text;
        DateExpression: Text;
    begin
        ActionDateCalculation.GET(CaseID, ScriptID, ActionID);
        SymbolStore.GetConstantOrLookupValueOfType(
            SourceRecRef,
            ActionDateCalculation."Case ID",
            ActionDateCalculation."Script ID",
            ActionDateCalculation."Date Value Type",
            ActionDateCalculation."Date Value",
            ActionDateCalculation."Date Lookup ID",
            "Symbol Data Type"::DATE,
            '',
            DateVariant);

        SymbolStore.GetConstantOrLookupValue(
            SourceRecRef, ActionDateCalculation."Case ID",
            ActionDateCalculation."Script ID",
            ActionDateCalculation."Number Value Type",
            ActionDateCalculation."Number Value",
            ActionDateCalculation."Number Lookup ID",
            NumberVariant);

        DateValue := DateVariant;
        NumberValue := NumberVariant;

        case ActionDateCalculation."Arithmetic operators" of
            ActionDateCalculation."Arithmetic operators"::plus:
                Sign := '+';
            ActionDateCalculation."Arithmetic operators"::minus:
                Sign := '-';
        end;

        case ActionDateCalculation.Duration of
            ActionDateCalculation.Duration::Days:
                DateExpression := Sign + Format(NumberValue, 0, 2) + 'D';
            ActionDateCalculation.Duration::Months:
                DateExpression := Sign + Format(NumberValue, 0, 2) + 'M';
            ActionDateCalculation.Duration::Years:
                DateExpression := Sign + Format(NumberValue, 0, 2) + 'Y';
            ActionDateCalculation.Duration::Weeks:
                DateExpression := Sign + Format(NumberValue, 0, 2) + 'W';
        end;

        OutputValue := CALCDATE(DateExpression, DateValue);

        SymbolStore.SetSymbol2("Symbol Type"::Variable, ActionDateCalculation."Variable ID", OutputValue);

    end;

    local procedure ExecuteDateToDateTime(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid;
        ActionID: Guid);
    var
        ActionDateToDateTime: Record "Action Date To DateTime";
        OutputValue: Variant;
        DateValue: Date;
        DateVariant: Variant;
        TimeValue: Time;
        TimeVariant: Variant;
    begin
        ActionDateToDateTime.GET(CaseID, ScriptID, ActionID);
        SymbolStore.GetConstantOrLookupValue(
            SourceRecRef,
            ActionDateToDateTime."Case ID",
            ActionDateToDateTime."Script ID",
            ActionDateToDateTime."Date Value Type",
            ActionDateToDateTime."Date Value",
            ActionDateToDateTime."Date Lookup ID",
            DateVariant);

        SymbolStore.GetConstantOrLookupValue(
            SourceRecRef,
            ActionDateToDateTime."Case ID",
            ActionDateToDateTime."Script ID",
            ActionDateToDateTime."Time Value Type",
            ActionDateToDateTime."Time Value",
            ActionDateToDateTime."Time Lookup ID",
            TimeVariant);

        DateValue := DateVariant;
        TimeValue := TimeVariant;

        OutputValue := CREATEDATETIME(DateValue, TimeValue);

        SymbolStore.SetSymbol2("Symbol Type"::Variable, ActionDateToDateTime."Variable ID", OutputValue);

    end;

    local procedure ExecuteFindIntervalBetweenDates(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid;
        ActionID: Guid);
    var
        ActionFindDateInterval: Record "Action Find Date Interval";
        OutputValue: Variant;
        Date1Value: Date;
        Date1Variant: Variant;
        Date2Value: Date;
        Date2Variant: Variant;
    begin
        ActionFindDateInterval.GET(CaseID, ScriptID, ActionID);
        SymbolStore.GetConstantOrLookupValueOfType(
            SourceRecRef,
            ActionFindDateInterval."Case ID",
            ActionFindDateInterval."Script ID",
            ActionFindDateInterval."Date1 Value Type",
            ActionFindDateInterval."Date1 Value",
            ActionFindDateInterval."Date1 Lookup ID",
            "Symbol Data Type"::DATE,
            '',
            Date1Variant);

        SymbolStore.GetConstantOrLookupValueOfType(
            SourceRecRef,
            ActionFindDateInterval."Case ID",
            ActionFindDateInterval."Script ID",
            ActionFindDateInterval."Date2 Value Type",
            ActionFindDateInterval."Date2 Value",
            ActionFindDateInterval."Date2 Lookup ID",
            "Symbol Data Type"::DATE,
            '',
            Date2Variant);

        Date1Value := Date1Variant;
        Date2Value := Date2Variant;

        OutputValue := Date2Value - Date1Value;
        SymbolStore.SetSymbol2("Symbol Type"::Variable, ActionFindDateInterval."Variable ID", OutputValue);

    end;

    local procedure ExecuteRoundNumber(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid;
        ActionID: Guid);
    var
        ActionRoundNumber: Record "Action Round Number";
        NumberValue: Variant;
        PrecisionValue: Variant;
        NumberDecimalValue: Decimal;
        PrecisionDecimalValue: Decimal;
        OutputValue: Variant;
    begin
        ActionRoundNumber.GET(CaseID, ScriptID, ActionID);
        SymbolStore.GetConstantOrLookupValue(
            SourceRecRef,
            ActionRoundNumber."Case ID",
            ActionRoundNumber."Script ID",
            ActionRoundNumber."Number Value Type",
            ActionRoundNumber."Number Value",
            ActionRoundNumber."Number Lookup ID",
            NumberValue);

        SymbolStore.GetConstantOrLookupValue(SourceRecRef, ActionRoundNumber."Case ID", ActionRoundNumber."Script ID",
            ActionRoundNumber."Precision Value Type",
            ActionRoundNumber."Precision Value",
            ActionRoundNumber."Precision Lookup ID",
            PrecisionValue);

        NumberDecimalValue := NumberValue;
        PrecisionDecimalValue := PrecisionValue;

        case ActionRoundNumber.Direction of
            ActionRoundNumber.Direction::Down:
                OutputValue := ROUND(NumberDecimalValue, PrecisionDecimalValue, '<');
            ActionRoundNumber.Direction::Up:
                OutputValue := ROUND(NumberDecimalValue, PrecisionDecimalValue, '>');
            ActionRoundNumber.Direction::Nearest:
                OutputValue := ROUND(NumberDecimalValue, PrecisionDecimalValue, '=');
        end;

        SymbolStore.SetSymbol2("Symbol Type"::Variable, ActionRoundNumber."Variable ID", OutputValue);

    end;

    local procedure ExecuteNumberExpression(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid;
        ActionID: Guid);
    var
        ActionNumberExpression: Record "Action Number Expression";
        ActionNumberExprToken: Record "Action Number Expr. Token";
        Values: Dictionary of [Text, Decimal];
        ValueVariant: Variant;
        OutputValue: Variant;
    begin
        ActionNumberExpression.GET(CaseID, ScriptID, ActionID);
        ActionNumberExprToken.Reset();
        ActionNumberExprToken.SetRange("Case ID", CaseID);
        ActionNumberExprToken.SetRange("Numeric Expr. ID", ActionID);
        if ActionNumberExprToken.FindSet() then
            repeat
                SymbolStore.GetConstantOrLookupValue(SourceRecRef, ActionNumberExprToken."Case ID", ActionNumberExprToken."Script ID", ActionNumberExprToken."Value Type", ActionNumberExprToken.Value, ActionNumberExprToken."Lookup ID", ValueVariant);
                Values.Add(ActionNumberExprToken.Token, ValueVariant);
            until ActionNumberExprToken.Next() = 0;

        OutputValue := ScriptDataTypeMgmt.EvaluateExpression(ActionNumberExpression.Expression, Values);
        SymbolStore.SetSymbol2("Symbol Type"::Variable, ActionNumberExpression."Variable ID", OutputValue);

    end;

    local procedure ExecuteStringExpression(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid;
        ActionID: Guid);
    var
        ActionStringExpression: Record "Action String Expression";
        ActionStringExprToken: Record "Action String Expr. Token";
        Values: Dictionary of [Text, Text];
        ValueVariant: Variant;
        OutputValue: Variant;
    begin
        ActionStringExpression.GET(CaseID, ScriptID, ActionID);
        ActionStringExprToken.Reset();
        ActionStringExprToken.SetRange("Case ID", CaseID);
        ActionStringExprToken.SetRange("Script ID", ScriptID);
        ActionStringExprToken.SetRange("String Expr. ID", ActionID);
        if ActionStringExprToken.FindSet() then
            repeat
                SymbolStore.GetConstantOrLookupValue(
                    SourceRecRef,
                    ActionStringExprToken."Case ID",
                    ActionStringExprToken."Script ID",
                    ActionStringExprToken."Value Type",
                    ActionStringExprToken.Value,
                    ActionStringExprToken."Lookup ID",
                    ValueVariant);

                if ActionStringExprToken."Format String" = '' then
                    Values.Add(ActionStringExprToken.Token, Format(ValueVariant))
                else
                    Values.Add(ActionStringExprToken.Token, Format(ValueVariant, 0, ActionStringExprToken."Format String"));
            until ActionStringExprToken.Next() = 0;

        OutputValue := ScriptDataTypeMgmt.EvaluateStringExpression(ActionStringExpression.Expression, Values);
        SymbolStore.SetSymbol2("Symbol Type"::Variable, ActionStringExpression."Variable ID", OutputValue);

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Lookup Mgmt.", 'OnGetSymbolDataType', '', false, false)]
    local procedure OnGetSymbolDataType(ScriptSymbolLookup: Record "Script Symbol Lookup"; var Datatype: Enum "Symbol Data Type")
    var
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
    begin
        ScriptSymbolsMgmt.SetContext(ScriptSymbolLookup."Case ID", ScriptSymbolLookup."Script ID");
        case ScriptSymbolLookup."Source Type" of
            ScriptSymbolLookup."Source Type"::Variable:
                Datatype := ScriptSymbolsMgmt.GetSymbolDataType(
                    ScriptSymbolLookup."Source Type",
                    ScriptSymbolLookup."Source Field ID");
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Script Symbol Lookup Dialog", 'OnIsSourceTypeSymbolType', '', false, false)]
    local procedure OnIsSourceTypeSymbolType(SymbolType: Enum "Symbol Type"; var IsHandled: Boolean; var IsSymbol: Boolean)
    begin
        case SymbolType of
            SymbolType::"Variable":
                begin
                    IsHandled := true;
                    IsSymbol := true;
                end;
        end;
    end;

    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        ConditionMgmt: Codeunit "Condition Mgmt.";
        LookupSerialization: Codeunit "Lookup Serialization";
        ExitLoop: Boolean;
        ContinueLoop: Boolean;
        SkipItemID: Guid;
        SortingTxt: Label 'VERSION(1) SORTING(%1) ORDER(%2)', Locked = true;
}