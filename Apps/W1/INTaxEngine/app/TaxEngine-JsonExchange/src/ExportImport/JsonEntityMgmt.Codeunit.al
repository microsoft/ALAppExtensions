codeunit 20360 "Json Entity Mgmt."
{
    procedure CreateTableSorting(CaseID: Guid; ScriptID: Guid; TableID: Integer): Guid;
    var
        LookupTableSorting: Record "Lookup Table Sorting";
    begin
        LookupTableSorting.Init();
        LookupTableSorting."Case ID" := CaseID;
        LookupTableSorting."Script ID" := ScriptID;
        LookupTableSorting.ID := CreateGuid();
        LookupTableSorting."Table ID" := TableID;
        LookupTableSorting.Insert(true);
        exit(LookupTableSorting.ID);
    end;

    procedure CreateTableFilters(CaseID: Guid; ScriptID: Guid; TableID: Integer): Guid;
    var
        LookupTableFilter: Record "Lookup Table Filter";
    begin
        LookupTableFilter.Init();
        LookupTableFilter."Case ID" := CaseID;
        LookupTableFilter."Script ID" := ScriptID;
        LookupTableFilter.ID := CreateGuid();
        LookupTableFilter."Table ID" := TableID;
        LookupTableFilter.Insert(true);
        exit(LookupTableFilter.ID);
    end;

    procedure CreateLookup(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ScriptSymbolLookup: Record "Script Symbol Lookup";
    begin
        ScriptSymbolLookup.Init();
        ScriptSymbolLookup."Case ID" := CaseID;
        ScriptSymbolLookup."Script ID" := ScriptID;
        ScriptSymbolLookup.ID := CreateGuid();
        ScriptSymbolLookup."Source Type" := ScriptSymbolLookup."Source Type"::Database;
        ScriptSymbolLookup.Insert();
        exit(ScriptSymbolLookup.ID);
    end;

    procedure CreateTableRelation(CaseID: Guid): Guid;
    var
        TaxTableRelation: Record "Tax Table Relation";
    begin
        TaxTableRelation.Init();
        TaxTableRelation."Case ID" := CaseID;
        TaxTableRelation.ID := CreateGuid();
        TaxTableRelation.Insert();
        exit(TaxTableRelation.ID);
    end;

    procedure CreateComment(CaseID: Guid; ScriptID: Guid; Comment: Text[250]): Guid;
    var
        ActionComment: Record "Action Comment";
    begin
        ActionComment.Init();
        ActionComment."Case ID" := CaseID;
        ActionComment."Script ID" := ScriptID;
        ActionComment.ID := CreateGuid();
        ActionComment.Text := Comment;
        ActionComment.Insert();

        exit(ActionComment.ID);
    end;

    procedure CreateCalculation(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionNumberCalculation: Record "Action Number Calculation";
    begin
        ActionNumberCalculation.Init();
        ActionNumberCalculation."Case ID" := CaseID;
        ActionNumberCalculation."Script ID" := ScriptID;
        ActionNumberCalculation.ID := CreateGuid();
        ActionNumberCalculation.Insert();

        exit(ActionNumberCalculation.ID);
    end;

    procedure CreateIfStatement(CaseID: Guid; ScriptID: Guid; ParentID: Guid): Guid;
    var
        ActionIfStatement: Record "Action If Statement";
        ParentIfStatement: Record "Action If Statement";
        ElseConditionAlreadyExistErr: Label 'Else Condition already exists for this branch.';
    begin
        if not IsNullGuid(ParentID) then begin
            ParentIfStatement.GET(CaseID, ScriptID, ParentID);
            if not IsNullGuid(ParentIfStatement."Else If Block ID") then
                Error(ElseConditionAlreadyExistErr);
        end;

        ActionIfStatement.Init();
        ActionIfStatement."Case ID" := CaseID;
        ActionIfStatement."Script ID" := ScriptID;
        ActionIfStatement.ID := CreateGuid();
        ActionIfStatement."Parent If Block ID" := ParentID;
        ActionIfStatement."Condition ID" := CreateCondition(CaseID, ScriptID);
        ActionIfStatement.Insert();

        if not IsNullGuid(ParentID) then begin
            ParentIfStatement."Else If Block ID" := ActionIfStatement.ID;
            ParentIfStatement.Modify();
        end;

        exit(ActionIfStatement.ID);
    end;

    procedure AddAndGetElseIfStatement(CaseID: Guid; ScriptID: Guid; ActionID: Guid) ElseIfID: Guid
    var
        ActionContainer: Record "Action Container";
        ActionContainer2: Record "Action Container";
        TempActionContainer: Record "Action Container" Temporary;
        NextLineNo: Integer;
    begin
        ActionContainer.Reset();
        ActionContainer.SetRange("Case ID", CaseID);
        ActionContainer.SetRange("Script ID", ScriptID);
        ActionContainer.SetRange("Action Type", "Action Type"::IFSTATEMENT);
        ActionContainer.SetRange("Action ID", ActionID);
        ActionContainer.FindFirst();
        NextLineNo := ActionContainer."Line No.";

        ActionContainer2.Reset();
        ActionContainer2.SetRange("Case ID", CaseID);
        ActionContainer2.SetRange("Script ID", ScriptID);
        ActionContainer2.SetRange("Container Type", ActionContainer."Container Type");
        ActionContainer2.SetRange("Container Action ID", ActionContainer."Container Action ID");
        ActionContainer2.SetFilter("Line No.", '>%1', NextLineNo);
        if ActionContainer2.FindSet() then
            repeat
                TempActionContainer := ActionContainer2;
                TempActionContainer.Insert();
                ActionContainer2.Delete();
            until ActionContainer2.Next() = 0;

        NextLineNo += 10000;
        ActionContainer."Line No." := NextLineNo;
        ActionContainer."Action ID" := CreateIfStatement(CaseID, ScriptID, ActionID);
        ElseIfID := ActionContainer."Action ID";
        ActionContainer.Insert();

        TempActionContainer.Reset();
        if TempActionContainer.FindSet() then
            repeat
                NextLineNo += 10000;
                ActionContainer2 := TempActionContainer;
                ActionContainer2."Line No." := NextLineNo;
                ActionContainer2.Insert();
            until TempActionContainer.Next() = 0;
    end;

    procedure CreateLoopNTimes(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionLoopNTimes: Record "Action Loop N Times";
    begin
        ActionLoopNTimes.Init();
        ActionLoopNTimes."Case ID" := CaseID;
        ActionLoopNTimes."Script ID" := ScriptID;
        ActionLoopNTimes.ID := CreateGuid();
        ActionLoopNTimes.Insert();

        exit(ActionLoopNTimes.ID);
    end;

    procedure CreateLoopWithCondition(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionLoopWithCondition: Record "Action Loop With Condition";
    begin
        ActionLoopWithCondition.Init();
        ActionLoopWithCondition."Case ID" := CaseID;
        ActionLoopWithCondition."Script ID" := ScriptID;
        ActionLoopWithCondition.ID := CreateGuid();
        ActionLoopWithCondition."Condition ID" := CreateCondition(CaseID, ScriptID);
        ActionLoopWithCondition.Insert();

        exit(ActionLoopWithCondition.ID);
    end;

    procedure CreateScriptContext(CaseID: Guid): Guid;
    var
        ScriptContext: Record "Script Context";
    begin
        ScriptContext.Init();
        ScriptContext.ID := CreateGuid();
        ScriptContext."Case ID" := CaseID;
        ScriptContext.Insert();

        exit(ScriptContext.ID);
    end;

    procedure CreateFindIntervalBetweenDates(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionFindDateInterval: Record "Action Find Date Interval";
    begin
        ActionFindDateInterval.Init();
        ActionFindDateInterval."Case ID" := CaseID;
        ActionFindDateInterval."Script ID" := ScriptID;
        ActionFindDateInterval.ID := CreateGuid();
        ActionFindDateInterval.Insert();

        exit(ActionFindDateInterval.ID);
    end;

    procedure CreateCondition(CaseID: Guid; ScriptID: Guid): Guid;
    var
        Condition: Record "Tax Test Condition";
    begin
        Condition.Init();
        Condition."Case ID" := CaseID;
        Condition."Script ID" := ScriptID;
        Condition.ID := CreateGuid();
        Condition.Insert();

        exit(Condition.ID);
    end;

    procedure CreateContainerItem(CaseID: Guid; ScriptID: Guid; ActionType: Enum "Action Type"): Guid;
    var
        ActionID: Guid;
        CreateContainerItemErr: Label 'Cannot create rule Action ''%1''.', Comment = '%1 - Action Type';
    begin
        case ActionType of
            ActionType::COMMENT:
                ActionID := CreateComment(CaseID, ScriptID, '');
            ActionType::NUMBERCALCULATION:
                ActionID := CreateCalculation(CaseID, ScriptID);
            ActionType::IFSTATEMENT:
                ActionID := CreateIfStatement(CaseID, ScriptID, EmptyGuid);
            ActionType::LOOPNTIMES:
                ActionID := CreateLoopNTimes(CaseID, ScriptID);
            ActionType::LOOPWITHCONDITION:
                ActionID := CreateLoopWithCondition(CaseID, ScriptID);
            ActionType::EXTRACTSUBSTRINGFROMPOSITION:
                ActionID := CreateExtractSubstringFromPosition(CaseID, ScriptID);
            ActionType::FINDINTERVALBETWEENDATES:
                ActionID := CreateFindIntervalBetweenDates(CaseID, ScriptID);
            ActionType::SETVARIABLE:
                ActionID := CreateSetVariable(CaseID, ScriptID);
            ActionType::CONCATENATE:
                ActionID := CreateConcatenate(CaseID, ScriptID);
            ActionType::FINDSUBSTRINGINSTRING:
                ActionID := CreateFindSubstringInString(CaseID, ScriptID);
            ActionType::REPLACESUBSTRINGINSTRING:
                ActionID := CreateReplaceSubstring(CaseID, ScriptID);
            ActionType::EXTRACTSUBSTRINGFROMINDEXOFSTRING:
                ActionID := CreateExtractSubstringFromIndexOfString(CaseID, ScriptID);
            ActionType::DATECALCULATION:
                ActionID := CreateDateCalculation(CaseID, ScriptID);
            ActionType::DATETODATETIME:
                ActionID := CreateDateToDateTime(CaseID, ScriptID);
            ActionType::ALERTMESSAGE:
                ActionID := CreateAlertMessage(CaseID, ScriptID);
            ActionType::LOOPTHROUGHRECORDS:
                ActionID := CreateLoopThroughRecords(CaseID, ScriptID);
            ActionType::EXTRACTDATEPART:
                ActionID := CreateExtractDatePart(CaseID, ScriptID);
            ActionType::EXTRACTDATETIMEPART:
                ActionID := CreateExtractDateTimePart(CaseID, ScriptID);
            ActionType::LENGTHOFSTRING:
                ActionID := CreateLengthOfString(CaseID, ScriptID);
            ActionType::CONVERTCASEOFSTRING:
                ActionID := CreateConvertCaseOfString(CaseID, ScriptID);
            ActionType::ROUNDNUMBER:
                ActionID := CreateRoundNumber(CaseID, ScriptID);
            ActionType::NUMERICEXPRESSION:
                ActionID := CreateNumberExpression(CaseID, ScriptID);
            ActionType::STRINGEXPRESSION:
                ActionID := CreateStringExpression(CaseID, ScriptID);
            ActionType::EXITLOOP:
                ActionID := ScriptActionHelper.ExitLoopActionID();
            ActionType::CONTINUE:
                ActionID := ScriptActionHelper.ContinueActionID();
            else
                Error(CreateContainerItemErr, ActionType);
        end;

        exit(ActionID);
    end;

    procedure CreateSetVariable(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionSetVariable: Record "Action Set Variable";
    begin
        ActionSetVariable.Init();
        ActionSetVariable."Case ID" := CaseID;
        ActionSetVariable."Script ID" := ScriptID;
        ActionSetVariable.ID := CreateGuid();
        ActionSetVariable.Insert();

        exit(ActionSetVariable.ID);
    end;

    procedure CreateConcatenate(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionConcatenate: Record "Action Concatenate";
    begin
        ActionConcatenate.Init();
        ActionConcatenate."Case ID" := CaseID;
        ActionConcatenate."Script ID" := ScriptID;
        ActionConcatenate.ID := CreateGuid();
        ActionConcatenate.Insert();

        exit(ActionConcatenate.ID);
    end;

    procedure CreateFindSubstringInString(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionFindSubstring: Record "Action Find Substring";
    begin
        ActionFindSubstring.Init();
        ActionFindSubstring."Case ID" := CaseID;
        ActionFindSubstring."Script ID" := ScriptID;
        ActionFindSubstring.ID := CreateGuid();
        ActionFindSubstring.Insert();

        exit(ActionFindSubstring.ID);
    end;

    procedure CreateReplaceSubstring(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionReplaceSubstring: Record "Action Replace Substring";
    begin
        ActionReplaceSubstring.Init();
        ActionReplaceSubstring."Case ID" := CaseID;
        ActionReplaceSubstring."Script ID" := ScriptID;
        ActionReplaceSubstring.ID := CreateGuid();
        ActionReplaceSubstring.Insert();

        exit(ActionReplaceSubstring.ID);
    end;

    procedure CreateExtractSubstringFromIndexOfString(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionExtSubstrFromIndex: Record "Action Ext. Substr. From Index";
    begin
        ActionExtSubstrFromIndex.Init();
        ActionExtSubstrFromIndex."Case ID" := CaseID;
        ActionExtSubstrFromIndex."Script ID" := ScriptID;
        ActionExtSubstrFromIndex.ID := CreateGuid();
        ActionExtSubstrFromIndex.Insert();

        exit(ActionExtSubstrFromIndex.ID);
    end;

    procedure CreateExtractSubstringFromPosition(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionExtSubstrFromPos: Record "Action Ext. Substr. From Pos.";
    begin
        ActionExtSubstrFromPos.Init();
        ActionExtSubstrFromPos."Case ID" := CaseID;
        ActionExtSubstrFromPos."Script ID" := ScriptID;
        ActionExtSubstrFromPos.ID := CreateGuid();
        ActionExtSubstrFromPos.Insert();

        exit(ActionExtSubstrFromPos.ID);
    end;

    procedure CreateDateCalculation(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionDateCalculation: Record "Action Date Calculation";
    begin
        ActionDateCalculation.Init();
        ActionDateCalculation."Case ID" := CaseID;
        ActionDateCalculation."Script ID" := ScriptID;
        ActionDateCalculation.ID := CreateGuid();
        ActionDateCalculation.Insert();

        exit(ActionDateCalculation.ID);
    end;

    procedure CreateDateToDateTime(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionDateToDateTime: Record "Action Date To DateTime";
    begin
        ActionDateToDateTime.Init();
        ActionDateToDateTime."Case ID" := CaseID;
        ActionDateToDateTime."Script ID" := ScriptID;
        ActionDateToDateTime.ID := CreateGuid();
        ActionDateToDateTime.Insert();

        exit(ActionDateToDateTime.ID);
    end;

    procedure CreateAlertMessage(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionMessage: Record "Action Message";
    begin
        ActionMessage.Init();
        ActionMessage."Case ID" := CaseID;
        ActionMessage."Script ID" := ScriptID;
        ActionMessage.ID := CreateGuid();
        ActionMessage.Insert();

        exit(ActionMessage.ID);
    end;

    procedure CreateLoopThroughRecords(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionLoopThroughRecords: Record "Action Loop Through Records";
    begin
        ActionLoopThroughRecords.Init();
        ActionLoopThroughRecords."Case ID" := CaseID;
        ActionLoopThroughRecords."Script ID" := ScriptID;
        ActionLoopThroughRecords.ID := CreateGuid();
        ActionLoopThroughRecords.Insert();

        exit(ActionLoopThroughRecords.ID);
    end;

    procedure CreateExtractDatePart(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionExtractDatePart: Record "Action Extract Date Part";
    begin
        ActionExtractDatePart.Init();
        ActionExtractDatePart."Case ID" := CaseID;
        ActionExtractDatePart."Script ID" := ScriptID;
        ActionExtractDatePart.ID := CreateGuid();
        ActionExtractDatePart.Insert();

        exit(ActionExtractDatePart.ID);
    end;

    procedure CreateExtractDateTimePart(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionExtractDateTimePart: Record "Action Extract DateTime Part";
    begin
        ActionExtractDateTimePart.Init();
        ActionExtractDateTimePart."Case ID" := CaseID;
        ActionExtractDateTimePart."Script ID" := ScriptID;
        ActionExtractDateTimePart.ID := CreateGuid();
        ActionExtractDateTimePart.Insert();

        exit(ActionExtractDateTimePart.ID);
    end;

    procedure CreateLengthOfString(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionLengthOfString: Record "Action Length Of String";
    begin
        ActionLengthOfString.Init();
        ActionLengthOfString."Case ID" := CaseID;
        ActionLengthOfString."Script ID" := ScriptID;
        ActionLengthOfString.ID := CreateGuid();
        ActionLengthOfString.Insert();

        exit(ActionLengthOfString.ID);
    end;

    procedure CreateConvertCaseOfString(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionConvertCase: Record "Action Convert Case";
    begin
        ActionConvertCase.Init();
        ActionConvertCase."Case ID" := CaseID;
        ActionConvertCase."Script ID" := ScriptID;
        ActionConvertCase.ID := CreateGuid();
        ActionConvertCase.Insert();

        exit(ActionConvertCase.ID);
    end;

    procedure CreateRoundNumber(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionRoundNumber: Record "Action Round Number";
    begin
        ActionRoundNumber.Init();
        ActionRoundNumber."Case ID" := CaseID;
        ActionRoundNumber."Script ID" := ScriptID;
        ActionRoundNumber.ID := CreateGuid();
        ActionRoundNumber.Insert();

        exit(ActionRoundNumber.ID);
    end;

    procedure CreateNumberExpression(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionNumberExpression: Record "Action Number Expression";
    begin
        ActionNumberExpression.Init();
        ActionNumberExpression."Case ID" := CaseID;
        ActionNumberExpression."Script ID" := CaseID;
        ActionNumberExpression.ID := CreateGuid();
        ActionNumberExpression."Script ID" := ScriptID;
        ActionNumberExpression.Insert();

        exit(ActionNumberExpression.ID);
    end;

    procedure CreateStringExpression(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionStringExpression: Record "Action String Expression";
    begin
        ActionStringExpression.Init();
        ActionStringExpression."Case ID" := CaseID;
        ActionStringExpression."Script ID" := ScriptID;
        ActionStringExpression.ID := CreateGuid();
        ActionStringExpression.Insert();

        exit(ActionStringExpression.ID);
    end;

    var
        ScriptActionHelper: Codeunit "Script Action Helper";
        EmptyGuid: Guid;
}