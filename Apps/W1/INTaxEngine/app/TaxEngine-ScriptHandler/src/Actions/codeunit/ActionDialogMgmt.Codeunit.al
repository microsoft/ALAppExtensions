codeunit 20156 "Action Dialog Mgmt."
{
    procedure OpenActionAssistEdit(
        CaseID: Guid;
        ScriptID: Guid;
        ActionType: Enum "Action Type";
        ActionID: Guid;
        GroupType: Enum "Action Group Type");
    begin
        case ActionType of
            ActionType::IFSTATEMENT:
                OpenIfConditionDialog(CaseID, ScriptID, ActionID);
            ActionType::LOOPNTIMES:
                if GroupType = ActionGroupType::"Loop N Times" then
                    OpenLoopNTimesDialog(CaseID, ScriptID, ActionID);
            ActionType::LOOPWITHCONDITION:
                if GroupType = ActionGroupType::"Loop with Condition" then
                    OpenLoopWithConditionDialog(CaseID, ScriptID, ActionID);
            ActionType::NUMBERCALCULATION:
                OpenNumberCalculationDialog(CaseID, ScriptID, ActionID);
            ActionType::SETVARIABLE:
                OpenSetVariableDialog(CaseID, ScriptID, ActionID);
            ActionType::CONCATENATE:
                OpenConcatenateDialog(CaseID, ScriptID, ActionID);
            ActionType::FINDSUBSTRINGINSTRING:
                OpenFindSubstrInStringDialog(CaseID, ScriptID, ActionID);
            ActionType::REPLACESUBSTRINGINSTRING:
                OpenReplaceSubstringDialog(CaseID, ScriptID, ActionID);
            ActionType::EXTRACTSUBSTRINGFROMINDEXOFSTRING:
                OpenExtractSubstringFromIndexDialog(CaseID, ScriptID, ActionID);
            ActionType::EXTRACTSUBSTRINGFROMPOSITION:
                OpenExtractSubstringFromPositionDialog(CaseID, ScriptID, ActionID);
            ActionType::FINDINTERVALBETWEENDATES:
                OpenActionFindDateIntervalDialog(CaseID, ScriptID, ActionID);
            ActionType::DATECALCULATION:
                OpenDateCalculationDialog(CaseID, ScriptID, ActionID);
            ActionType::DATETODATETIME:
                OpenDateToDateTimeDialog(CaseID, ScriptID, ActionID);
            ActionType::ALERTMESSAGE:
                OpenAlertMessageDialog(CaseID, ScriptID, ActionID);
            ActionType::LOOPTHROUGHRECORDS:
                OpenLoopThroughRecordsDialog(CaseID, ScriptID, ActionID);
            ActionType::EXTRACTDATEPART:
                OpenExtractDatePartDialog(CaseID, ScriptID, ActionID);
            ActionType::EXTRACTDATETIMEPART:
                OpenExtractDateTimePartDialog(CaseID, ScriptID, ActionID);
            ActionType::LENGTHOFSTRING:
                OpenLengthOfStringDialog(CaseID, ScriptID, ActionID);
            ActionType::CONVERTCASEOFSTRING:
                OpenConvertCaseOfStringDialog(CaseID, ScriptID, ActionID);
            ActionType::ROUNDNUMBER:
                OpenRoundNumberDialog(CaseID, ScriptID, ActionID);
            ActionType::NUMERICEXPRESSION:
                OpenNumericExprDialog(CaseID, ScriptID, ActionID);
            ActionType::STRINGEXPRESSION:
                OpenStringExprDialog(CaseID, ScriptID, ActionID);
        end;
    end;

    procedure OpenIfConditionDialog(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionIfStatement: Record "Action If Statement";
    begin
        ActionIfStatement.GET(CaseID, ScriptID, ID);
        if not IsNullGuid(ActionIfStatement."Condition ID") then
            ScriptConditionMgmt.OpenConditionsDialog(CaseID, ScriptID, ActionIfStatement."Condition ID");
    end;

    procedure OpenLoopNTimesDialog(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionLoopNTimes: Record "Action Loop N Times";
        LoopNTimesDialog: Page "Action Loop N Times Dialog";
    begin
        ActionLoopNTimes.GET(CaseID, ScriptID, ID);
        LoopNTimesDialog.SetCurrentRecord(ActionLoopNTimes);
        LoopNTimesDialog.RunModal();
    end;

    procedure OpenLoopWithConditionDialog(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionLoopWithCondition: Record "Action Loop With Condition";
    begin
        ActionLoopWithCondition.GET(CaseID, ScriptID, ID);
        if not IsNullGuid(ActionLoopWithCondition."Condition ID") then
            ScriptConditionMgmt.OpenConditionsDialog(CaseID, ScriptID, ActionLoopWithCondition."Condition ID");
    end;

    procedure OpenNumberCalculationDialog(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionNumberCalculation: Record "Action Number Calculation";
        NumberCalculationDialog: Page "Action Number Calc. Dialog";
    begin
        ActionNumberCalculation.GET(CaseID, ScriptID, ID);
        NumberCalculationDialog.SetCurrentRecord(ActionNumberCalculation);
        NumberCalculationDialog.RunModal();
    end;

    procedure OpenSetVariableDialog(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionSetVariable: Record "Action Set Variable";
        ActionSetVariableDialog: Page "Action Set Variable Dialog";
    begin
        ActionSetVariable.GET(CaseID, ScriptID, ID);
        ActionSetVariableDialog.SetCurrentRecord(ActionSetVariable);
        ActionSetVariableDialog.RunModal();
    end;

    procedure OpenConcatenateDialog(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionConcatenate: Record "Action Concatenate";
        ConcatenateDialog: Page "Action Concatenate Dialog";
    begin
        ActionConcatenate.GET(CaseID, ScriptID, ID);
        ConcatenateDialog.SetCurrentRecord(ActionConcatenate);
        ConcatenateDialog.RunModal();
    end;

    procedure OpenFindSubstrInStringDialog(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionFindSubstring: Record "Action Find Substring";
        ActionFindSubstringDialog: Page "Action Find Substring Dialog";
    begin
        ActionFindSubstring.GET(CaseID, ScriptID, ID);
        ActionFindSubstringDialog.SetCurrentRecord(ActionFindSubstring);
        ActionFindSubstringDialog.RunModal();
    end;

    procedure OpenReplaceSubstringDialog(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionReplaceSubstring: Record "Action Replace Substring";
        ReplaceSubstringDialog: Page "Action Replace Substring Dlg";
    begin
        ActionReplaceSubstring.GET(CaseID, ScriptID, ID);
        ReplaceSubstringDialog.SetCurrentRecord(ActionReplaceSubstring);
        ReplaceSubstringDialog.RunModal();
    end;

    procedure OpenExtractSubstringFromIndexDialog(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionExtSubstrFromIndex: Record "Action Ext. Substr. From Index";
        ActionExtSubstrFromIndexDialog: Page "Action Ext. Substr. From Index";
    begin
        ActionExtSubstrFromIndex.GET(CaseID, ScriptID, ID);
        ActionExtSubstrFromIndexDialog.SetCurrentRecord(ActionExtSubstrFromIndex);
        ActionExtSubstrFromIndexDialog.RunModal();
    end;

    procedure OpenExtractSubstringFromPositionDialog(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionExtSubstrFromPos: Record "Action Ext. Substr. From Pos.";
        ActionExtSubstrFromPosDialog: Page "Action Ext. Substr. From Pos.";
    begin
        ActionExtSubstrFromPos.GET(CaseID, ScriptID, ID);
        ActionExtSubstrFromPosDialog.SetCurrentRecord(ActionExtSubstrFromPos);
        ActionExtSubstrFromPosDialog.RunModal();
    end;

    procedure OpenActionFindDateIntervalDialog(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionFindDateInterval: Record "Action Find Date Interval";
        FindDateIntervalDlg: Page "Action Find Date Interval Dlg";
    begin
        ActionFindDateInterval.GET(CaseID, ScriptID, ID);
        FindDateIntervalDlg.SetCurrentRecord(ActionFindDateInterval);
        FindDateIntervalDlg.RunModal();
    end;

    procedure OpenDateCalculationDialog(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionDateCalculation: Record "Action Date Calculation";
        DateCalculationDialog: Page "Action Date Calculation Dialog";
    begin
        ActionDateCalculation.GET(CaseID, ScriptID, ID);
        DateCalculationDialog.SetCurrentRecord(ActionDateCalculation);
        DateCalculationDialog.RunModal();
    end;

    procedure OpenDateToDateTimeDialog(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionDateToDateTime: Record "Action Date To DateTime";
        DateToDateTimeDialog: Page "Action Date To DateTime Dialog";
    begin
        ActionDateToDateTime.GET(CaseID, ScriptID, ID);
        DateToDateTimeDialog.SetCurrentRecord(ActionDateToDateTime);
        DateToDateTimeDialog.RunModal();
    end;

    procedure OpenAlertMessageDialog(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionMessage: Record "Action Message";
        AlertMessageDialog: Page "Action Message Dialog";
    begin
        ActionMessage.GET(CaseID, ScriptID, ID);
        AlertMessageDialog.SetCurrentRecord(ActionMessage);
        AlertMessageDialog.RunModal();
    end;

    procedure OpenLoopThroughRecordsDialog(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionLoopThroughRecords: Record "Action Loop Through Records";
        LoopThroughRecordsDialog: Page "Action Loop Through Rec. Dlg";
    begin
        ActionLoopThroughRecords.GET(CaseID, ScriptID, ID);
        LoopThroughRecordsDialog.SetCurrentRecord(ActionLoopThroughRecords);
        LoopThroughRecordsDialog.RunModal();
    end;

    procedure OpenExtractDatePartDialog(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionExtractDatePart: Record "Action Extract Date Part";
        ExtractDatePartDialog: Page "Action Extract Date Part Dlg";
    begin
        ActionExtractDatePart.GET(CaseID, ScriptID, ID);
        ExtractDatePartDialog.SetCurrentRecord(ActionExtractDatePart);
        ExtractDatePartDialog.RunModal();
    end;

    procedure OpenExtractDateTimePartDialog(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionExtractDateTimePart: Record "Action Extract DateTime Part";
        ExtractDateTimeDialog: Page "Action Extract DateTime Dialog";
    begin
        ActionExtractDateTimePart.GET(CaseID, ScriptID, ID);
        ExtractDateTimeDialog.SetCurrentRecord(ActionExtractDateTimePart);
        ExtractDateTimeDialog.RunModal();
    end;

    procedure OpenLengthOfStringDialog(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionLengthOfString: Record "Action Length Of String";
        LengthOfStringDialog: Page "Action Length Of String Dialog";
    begin
        ActionLengthOfString.GET(CaseID, ScriptID, ID);
        LengthOfStringDialog.SetCurrentRecord(ActionLengthOfString);
        LengthOfStringDialog.RunModal();
    end;

    procedure OpenConvertCaseOfStringDialog(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionConvertCase: Record "Action Convert Case";
        RuleConvertCaseDialog: Page "Action Convert Case Dialog";
    begin
        ActionConvertCase.GET(CaseID, ScriptID, ID);
        RuleConvertCaseDialog.SetCurrentRecord(ActionConvertCase);
        RuleConvertCaseDialog.RunModal();
    end;

    procedure OpenRoundNumberDialog(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionRoundNumber: Record "Action Round Number";
        RoundNumberDialog: Page "Action Round Number Dialog";
    begin
        ActionRoundNumber.GET(CaseID, ScriptID, ID);
        RoundNumberDialog.SetCurrentRecord(ActionRoundNumber);
        RoundNumberDialog.RunModal();
    end;

    procedure OpenNumericExprDialog(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionNumberExpression: Record "Action Number Expression";
        RuleNumericExprDialog: Page "Action Number Expr. Dialog";
    begin
        ActionNumberExpression.GET(CaseID, ScriptID, ID);
        RuleNumericExprDialog.SetCurrentRecord(ActionNumberExpression);
        RuleNumericExprDialog.RunModal();
    end;

    procedure OpenStringExprDialog(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionStringExpression: Record "Action String Expression";
        ActionStringExprDialog: Page "Action String Expr. Dialog";
    begin
        ActionStringExpression.GET(CaseID, ScriptID, ID);
        ActionStringExprDialog.SetCurrentRecord(ActionStringExpression);
        ActionStringExprDialog.RunModal();
    end;

    var
        ScriptConditionMgmt: Codeunit "Condition Mgmt.";
        ActionGroupType: Enum "Action Group Type";

}