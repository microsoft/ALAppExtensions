codeunit 136756 "Library - Script Tests"
{
    EventSubscriberInstance = Manual;

    var
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        Initilized: Boolean;
        GlobalCaseID: Guid;
        GlobalScriptID: Guid;

    procedure CreateScriptEditorLine(CaseID: Guid; ScriptID: Guid; ActionType: Enum "Action Type"; ActionID: Guid)
    var
        ScriptEditorLine: Record "Script Editor Line";
    begin
        ScriptEditorLine."Case ID" := CaseID;
        ScriptEditorLine."Script ID" := ScriptID;
        ScriptEditorLine."Action Type" := ActionType;
        ScriptEditorLine."Action ID" := ActionID;
        ScriptEditorLine.Insert();
    end;

    procedure CreateActivityContianer(
        CaseID: Guid;
        ScriptID: Guid;
        ContainerActionType: Enum "Container Action Type";
        ContainerActionID: Guid;
        ActionType: Enum "Action Type";
        ActionID: Guid)
    var
        ActionContainer: Record "Action Container";
    begin
        ActionContainer."Case ID" := CaseID;
        ActionContainer."Script ID" := ScriptID;
        ActionContainer."Action Type" := ActionType;
        ActionContainer."Action ID" := ActionID;
        ActionContainer."Container Action ID" := ContainerActionID;
        ActionContainer."Container Type" := ContainerActionType;
        ActionContainer.Insert();
    end;

    procedure CreateScriptVariable(var CaseID: Guid; var ScriptID: Guid; VariableID: Integer; VariableName: Text[30]; Datatype: Enum "Symbol Data Type")
    var
        ScriptVariable: Record "Script Variable";
    begin
        Init(CaseID, ScriptID);
        ScriptVariable."Case ID" := CaseID;
        ScriptVariable."Script ID" := ScriptID;
        ScriptVariable.ID := VariableID;
        ScriptVariable.Name := VariableName;
        ScriptVariable.Datatype := Datatype;
        ScriptVariable.Insert();
    end;

    procedure CreateSetVariable(var CaseID: Guid; var ScriptID: Guid; var ActionID: Guid)
    begin
        Init(CaseID, ScriptID);
        ActionID := ScriptEntityMgmt.CreateSetVariable(CaseID, ScriptID);
    end;

    procedure CreateConditionItem(CaseID: Guid; ScriptID: Guid; ConditionID: Guid; LHSLookupID: Guid; RHSLookupID: Guid; ConditionalOperator: Enum "Conditional Operator")
    var
        ConditionItem: Record "Tax Test Condition Item";
    begin
        ConditionItem.Init();
        ConditionItem."Case ID" := CaseID;
        ConditionItem."Script ID" := ScriptID;
        ConditionItem."LHS Lookup ID" := LHSLookupID;
        ConditionItem."RHS Type" := ConditionItem."RHS Type"::Lookup;
        ConditionItem."RHS Lookup ID" := RHSLookupID;
        ConditionItem."Condition ID" := ConditionID;
        ConditionItem."Conditional Operator" := ConditionalOperator;
        ConditionItem.Insert();
    end;

    procedure CreateConditionItem(CaseID: Guid; ScriptID: Guid; ConditionID: Guid; LHSLookupID: Guid; RHSValue: Text[250]; ConditionalOperator: Enum "Conditional Operator")
    var
        ConditionItem: Record "Tax Test Condition Item";
    begin
        ConditionItem.Init();
        ConditionItem."Case ID" := CaseID;
        ConditionItem."Script ID" := ScriptID;
        ConditionItem."LHS Lookup ID" := LHSLookupID;
        ConditionItem."RHS Type" := ConditionItem."RHS Type"::Constant;
        ConditionItem."RHS Value" := RHSValue;
        ConditionItem."Condition ID" := ConditionID;
        ConditionItem."Conditional Operator" := ConditionalOperator;
        ConditionItem.Insert();
    end;

    procedure CreateConditionItemConstant(CaseID: Guid; ScriptID: Guid; ConditionID: Guid; LHSLookupID: Guid; RHSValue: Text[250]; ConditionalOperator: Enum "Conditional Operator")
    var
        ConditionItem: Record "Tax Test Condition Item";
    begin
        ConditionItem.Init();
        ConditionItem."Case ID" := CaseID;
        ConditionItem."Script ID" := ScriptID;
        ConditionItem."LHS Lookup ID" := LHSLookupID;
        ConditionItem."RHS Type" := ConditionItem."RHS Type"::Constant;
        ConditionItem."RHS Value" := RHSValue;
        ConditionItem."Condition ID" := ConditionID;
        ConditionItem."Conditional Operator" := ConditionalOperator;
        ConditionItem.Insert();
    end;

    procedure CreateIfCondition(var CaseID: Guid; var ScriptID: Guid; var ActionID: Guid)
    var
        EmptyGuid: Guid;
    begin
        Init(CaseID, ScriptID);
        ActionID := ScriptEntityMgmt.CreateIfCondition(CaseID, ScriptID, EmptyGuid);
    end;

    procedure CreateLoopNTimes(var CaseID: Guid; var ScriptID: Guid; var ActionID: Guid)
    begin
        Init(CaseID, ScriptID);
        ActionID := ScriptEntityMgmt.CreateLoopNTimes(CaseID, ScriptID);
    end;

    procedure CreateLoopWithCondition(var CaseID: Guid; var ScriptID: Guid; var ActionID: Guid)
    begin
        Init(CaseID, ScriptID);
        ActionID := ScriptEntityMgmt.CreateLoopWithCondition(CaseID, ScriptID);
    end;

    procedure CreateNumberCalculation(var CaseID: Guid; var ScriptID: Guid; var ActionID: Guid)
    begin
        Init(CaseID, ScriptID);
        ActionID := ScriptEntityMgmt.CreateNumberCalculation(CaseID, ScriptID);
    end;

    procedure CreateConcatenate(var CaseID: Guid; var ScriptID: Guid; var ActionID: Guid)
    begin
        Init(CaseID, ScriptID);
        ActionID := ScriptEntityMgmt.CreateConcatenate(CaseID, ScriptID);
    end;

    procedure AddConcatenateLine(var CaseID: Guid; var ScriptID: Guid; var ConcatenateID: Guid; LookupID: Guid)
    var
        ActionConcatenateLine: Record "Action Concatenate Line";
        NextLineNo: Integer;
    begin
        Init(CaseID, ScriptID);

        ActionConcatenateLine.Reset();
        ActionConcatenateLine.SetRange("Case ID", CaseID);
        ActionConcatenateLine.SetRange("Script ID", ScriptID);
        ActionConcatenateLine.SetRange("Concatenate ID", ConcatenateID);
        if ActionConcatenateLine.FindLast() then
            NextLineNo := ActionConcatenateLine."Line No." + 10000
        else
            NextLineNo := 10000;

        ActionConcatenateLine.Init();
        ActionConcatenateLine."Case ID" := CaseID;
        ActionConcatenateLine."Script ID" := ScriptID;
        ActionConcatenateLine."Concatenate ID" := ConcatenateID;
        ActionConcatenateLine."Line No." := NextLineNo;
        ActionConcatenateLine."Value Type" := ActionConcatenateLine."Value Type"::Lookup;
        ActionConcatenateLine."Lookup ID" := LookupID;
        ActionConcatenateLine.Insert();
    end;

    procedure CreateFindSubstrInString(var CaseID: Guid; var ScriptID: Guid; var ActionID: Guid)
    begin
        Init(CaseID, ScriptID);
        ActionID := ScriptEntityMgmt.CreateFindSubstrInString(CaseID, ScriptID);
    end;

    procedure CreateReplaceSubstring(var CaseID: Guid; var ScriptID: Guid; var ActionID: Guid)
    begin
        Init(CaseID, ScriptID);
        ActionID := ScriptEntityMgmt.CreateReplaceSubstring(CaseID, ScriptID);
    end;

    procedure CreateExtSubstrFromIndex(var CaseID: Guid; var ScriptID: Guid; var ActionID: Guid)
    begin
        Init(CaseID, ScriptID);
        ActionID := ScriptEntityMgmt.CreateExtSubstrFromIndex(CaseID, ScriptID);
    end;

    procedure CreateExtSubstrFromPos(var CaseID: Guid; var ScriptID: Guid; var ActionID: Guid)
    begin
        Init(CaseID, ScriptID);
        ActionID := ScriptEntityMgmt.CreateExtSubstrFromPos(CaseID, ScriptID);
    end;

    procedure CreateFindDateInterval(var CaseID: Guid; var ScriptID: Guid; var ActionID: Guid)
    begin
        Init(CaseID, ScriptID);
        ActionID := ScriptEntityMgmt.CreateFindDateInterval(CaseID, ScriptID);
    end;

    procedure CreateDateCalculation(var CaseID: Guid; var ScriptID: Guid; var ActionID: Guid)
    begin
        Init(CaseID, ScriptID);
        ActionID := ScriptEntityMgmt.CreateDateCalculation(CaseID, ScriptID);
    end;

    procedure CreateDateToDateTime(var CaseID: Guid; var ScriptID: Guid; var ActionID: Guid)
    begin
        Init(CaseID, ScriptID);
        ActionID := ScriptEntityMgmt.CreateDateToDateTime(CaseID, ScriptID);
    end;

    procedure CreateAlertMessage(var CaseID: Guid; var ScriptID: Guid; var ActionID: Guid)
    begin
        Init(CaseID, ScriptID);
        ActionID := ScriptEntityMgmt.CreateAlertMessage(CaseID, ScriptID);
    end;

    procedure CreateLoopThroughRecords(var CaseID: Guid; var ScriptID: Guid; var ActionID: Guid)
    begin
        Init(CaseID, ScriptID);
        ActionID := ScriptEntityMgmt.CreateLoopThroughRecords(CaseID, ScriptID);
    end;

    procedure CreateComment(var CaseID: Guid; var ScriptID: Guid; var ActionID: Guid; Comment: Text[250])
    begin
        Init(CaseID, ScriptID);
        ActionID := ScriptEntityMgmt.CreateComment(CaseID, ScriptID, Comment);
    end;

    procedure CreateExtractDatePart(var CaseID: Guid; var ScriptID: Guid; var ActionID: Guid)
    begin
        Init(CaseID, ScriptID);
        ActionID := ScriptEntityMgmt.CreateExtractDatePart(CaseID, ScriptID);
    end;

    procedure CreateExtractDateTimePart(var CaseID: Guid; var ScriptID: Guid; var ActionID: Guid)
    begin
        Init(CaseID, ScriptID);
        ActionID := ScriptEntityMgmt.CreateExtractDateTimePart(CaseID, ScriptID);
    end;

    procedure CreateLengthOfString(var CaseID: Guid; var ScriptID: Guid; var ActionID: Guid)
    begin
        Init(CaseID, ScriptID);
        ActionID := ScriptEntityMgmt.CreateLengthOfString(CaseID, ScriptID);
    end;

    procedure CreateConvertCaseOfString(var CaseID: Guid; var ScriptID: Guid; var ActionID: Guid)
    begin
        Init(CaseID, ScriptID);
        ActionID := ScriptEntityMgmt.CreateConvertCaseOfString(CaseID, ScriptID);
    end;

    procedure CreateNumericExpression(var CaseID: Guid; var ScriptID: Guid; var ActionID: Guid)
    begin
        Init(CaseID, ScriptID);
        ActionID := ScriptEntityMgmt.CreateNumericExpression(CaseID, ScriptID);
    end;

    procedure AddNumericExpression(var CaseID: Guid; var ScriptID: Guid; var ExpressionID: Guid; Name: Text[250]; LookupID: Guid)
    var
        ActionNumberExprToken: Record "Action Number Expr. Token";
    begin
        ActionNumberExprToken.Init();
        ActionNumberExprToken."Case ID" := CaseID;
        ActionNumberExprToken."Script ID" := ScriptID;
        ActionNumberExprToken."Numeric Expr. ID" := ExpressionID;
        ActionNumberExprToken.Token := Name;
        ActionNumberExprToken."Value Type" := ActionNumberExprToken."Value Type"::Lookup;
        ActionNumberExprToken."Lookup ID" := LookupID;
        ActionNumberExprToken.Insert();
    end;

    procedure AddStringExpression(var CaseID: Guid; var ScriptID: Guid; var ExpressionID: Guid; Name: Text[250]; LookupID: Guid)
    var
        ActionStringExprToken: Record "Action String Expr. Token";
    begin
        ActionStringExprToken.Init();
        ActionStringExprToken."Case ID" := CaseID;
        ActionStringExprToken."Script ID" := ScriptID;
        ActionStringExprToken."String Expr. ID" := ExpressionID;
        ActionStringExprToken.Token := Name;
        ActionStringExprToken."Value Type" := ActionStringExprToken."Value Type"::Lookup;
        ActionStringExprToken."Lookup ID" := LookupID;
        ActionStringExprToken.Insert();
    end;

    procedure CreateStringExpression(var CaseID: Guid; var ScriptID: Guid; var ActionID: Guid)
    begin
        Init(CaseID, ScriptID);
        ActionID := ScriptEntityMgmt.CreateStringExpression(CaseID, ScriptID);
    end;

    procedure CreateRoundNumber(var CaseID: Guid; var ScriptID: Guid; var ActionID: Guid)
    begin
        Init(CaseID, ScriptID);
        ActionID := ScriptEntityMgmt.CreateRoundNumber(CaseID, ScriptID);
    end;

    procedure CreateLookupTableFilter(var CaseID: Guid; var ScriptID: Guid; var TableFilterID: Guid; TableID: Integer)
    var
        LookupTableFilter: Record "Lookup Table Filter";
    begin
        Init(CaseID, ScriptID);
        TableFilterID := CreateGuid();

        LookupTableFilter.Init();
        LookupTableFilter."Case ID" := CaseID;
        LookupTableFilter."Script ID" := ScriptID;
        LookupTableFilter.ID := TableFilterID;
        LookupTableFilter."Table ID" := TableID;
        LookupTableFilter.Insert();
    end;

    procedure AddFieldFilter(var CaseID: Guid; var ScriptID: Guid; TableFilterID: Guid; TableID: Integer; FieldID: Integer; FilterValue: Text[250])
    var
        LookupFieldFilter: Record "Lookup Field Filter";
    begin
        Init(CaseID, ScriptID);

        LookupFieldFilter.Init();
        LookupFieldFilter."Case ID" := CaseID;
        LookupFieldFilter."Script ID" := ScriptID;
        LookupFieldFilter."Table Filter ID" := TableFilterID;
        LookupFieldFilter."Table ID" := TableID;
        LookupFieldFilter."Field ID" := FieldID;
        LookupFieldFilter."Value Type" := LookupFieldFilter."Value Type"::Constant;
        LookupFieldFilter.Value := FilterValue;
        LookupFieldFilter.Insert();
    end;

    procedure CreateLookupTableSorting(var CaseID: Guid; var ScriptID: Guid; var TableSortingID: Guid; TableID: Integer)
    var
        LookupTableSorting: Record "Lookup Table Sorting";
    begin
        Init(CaseID, ScriptID);
        TableSortingID := CreateGuid();

        LookupTableSorting.Init();
        LookupTableSorting."Case ID" := CaseID;
        LookupTableSorting."Script ID" := ScriptID;
        LookupTableSorting.ID := TableSortingID;
        LookupTableSorting."Table ID" := TableID;
        LookupTableSorting.Insert();
    end;

    procedure AddFieldSorting(var CaseID: Guid; var ScriptID: Guid; TableSortingID: Guid; TableID: Integer; FieldID: Integer)
    var
        LookupFieldSorting: Record "Lookup Field Sorting";
        NextLineNo: Integer;
    begin
        Init(CaseID, ScriptID);

        LookupFieldSorting.Reset();
        LookupFieldSorting.SetRange("Case ID", CaseID);
        LookupFieldSorting.SetRange("Script ID", ScriptID);
        LookupFieldSorting.SetRange("Table Sorting ID", TableSortingID);
        if LookupFieldSorting.FindLast() then
            NextLineNo := LookupFieldSorting."Line No." + 10000
        else
            NextLineNo := 10000;

        LookupFieldSorting.Init();
        LookupFieldSorting."Case ID" := CaseID;
        LookupFieldSorting."Script ID" := ScriptID;
        LookupFieldSorting."Table Sorting ID" := TableSortingID;
        LookupFieldSorting."Line No." := NextLineNo;
        LookupFieldSorting."Table ID" := TableID;
        LookupFieldSorting."Field ID" := FieldID;
        LookupFieldSorting.Insert();
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Script Symbols Mgmt.", 'OnGetTaxType', '', false, false)]
    local procedure OnGetTaxType(CaseID: Guid; var TaxType: Code[20]; var Handled: Boolean)
    begin
        if (CaseID = GlobalCaseID) then
            TaxType := 'TAX';

        Handled := true;
    end;

    local procedure Init(var CaseID2: Guid; var ScriptID2: Guid)
    begin
        if Initilized then begin
            CaseID2 := GlobalCaseID;
            ScriptID2 := GlobalScriptID;
            exit;
        end;

        GlobalCaseID := CreateGuid();
        GlobalScriptID := CreateGuid();

        Initilized := true;
        CaseID2 := GlobalCaseID;
        ScriptID2 := GlobalScriptID;
    end;
}