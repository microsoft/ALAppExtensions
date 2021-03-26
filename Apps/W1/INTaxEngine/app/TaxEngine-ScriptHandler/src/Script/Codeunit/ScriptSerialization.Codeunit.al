codeunit 20167 "Script Serialization"
{
    var
        AppObjectHelper: Codeunit "App Object Helper";
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        LookupSerialization: Codeunit "Lookup Serialization";
        LookupMgmt: Codeunit "Lookup Mgmt.";

    procedure RuleActionToText(
        CaseID: Guid;
        ScriptID: Guid;
        ActionType: Enum "Action Type";
        ActionID: Guid;
        GroupType: Enum "Action Group Type"): Text;
    var
        EditorLineItemText: Text;
        ActionConversionErr: Label 'Action Type ''%1'' ToString Conversion not implemented.', Comment = '%1 - Action Type';
    begin
        Clear(ScriptSymbolsMgmt);
        ScriptSymbolsMgmt.SetContext(CaseID, ScriptID);
        EditorLineItemText := StrSubstNo(ActionConversionErr, ActionType);
        case ActionType of
            ActionType::IFSTATEMENT:
                if GroupType in ["Action Group Type"::" ", "Action Group Type"::"if Statement", "Action Group Type"::"Else if Statement", "Action Group Type"::"Else Statement"] then
                    EditorLineItemText := IfConditionToString(CaseID, ScriptID, ActionID)
                else
                    if GroupType = "Action Group Type"::"End if Statement" then
                        EditorLineItemText := 'End If';
            ActionType::LOOPNTIMES:
                if GroupType in ["Action Group Type"::" ", "Action Group Type"::"Loop N Times"] then
                    EditorLineItemText := LoopNTimesToString(CaseID, ScriptID, ActionID)
                else
                    if GroupType = "Action Group Type"::"End Loop N Times" then
                        EditorLineItemText := 'End Loop';
            ActionType::LOOPWITHCONDITION:
                if GroupType in ["Action Group Type"::" ", "Action Group Type"::"Loop with Condition"] then
                    EditorLineItemText := LoopWithConditionToString(CaseID, ScriptID, ActionID)
                else
                    if GroupType = "Action Group Type"::"End Loop with Condition" then
                        EditorLineItemText := 'End Loop';
            ActionType::LOOPTHROUGHRECORDS:
                if GroupType in ["Action Group Type"::" ", "Action Group Type"::"Loop Through Records"] then
                    EditorLineItemText := LoopThroughRecordsToString(CaseID, ScriptID, ActionID)
                else
                    if GroupType = "Action Group Type"::"End Loop Through Records" then
                        EditorLineItemText := 'End Loop';
            ActionType::DRAFTROW:
                EditorLineItemText := '';
            ActionType::COMMENT:
                EditorLineItemText := CommentToString(CaseID, ScriptID, ActionID);
            ActionType::NUMBERCALCULATION:
                EditorLineItemText := NumberCalculationToString(CaseID, ScriptID, ActionID);
            ActionType::EXTRACTSUBSTRINGFROMPOSITION:
                EditorLineItemText := ExtractSubstringFromPositionToString(CaseID, ScriptID, ActionID);
            ActionType::FINDINTERVALBETWEENDATES:
                EditorLineItemText := FindDateIntervalToString(CaseID, ScriptID, ActionID);
            ActionType::SETVARIABLE:
                EditorLineItemText := SetVariableToString(CaseID, ScriptID, ActionID);
            ActionType::CONCATENATE:
                EditorLineItemText := ConcatenateToString(CaseID, ScriptID, ActionID);
            ActionType::FINDSUBSTRINGINSTRING:
                EditorLineItemText := FindSubstringToString(CaseID, ScriptID, ActionID);
            ActionType::REPLACESUBSTRINGINSTRING:
                EditorLineItemText := RepaceSubstringInStringToString(CaseID, ScriptID, ActionID);
            ActionType::EXTRACTSUBSTRINGFROMINDEXOFSTRING:
                EditorLineItemText := ExtractSubstringFromIndexToString(CaseID, ScriptID, ActionID);
            ActionType::DATECALCULATION:
                EditorLineItemText := DateCalculationToString(CaseID, ScriptID, ActionID);
            ActionType::DATETODATETIME:
                EditorLineItemText := DateToDateTimeToString(CaseID, ScriptID, ActionID);
            ActionType::ALERTMESSAGE:
                EditorLineItemText := AlertMessageToString(CaseID, ScriptID, ActionID);
            ActionType::EXTRACTDATEPART:
                EditorLineItemText := ExtractDatePartToString(CaseID, ScriptID, ActionID);
            ActionType::EXTRACTDATETIMEPART:
                EditorLineItemText := ExtractDateTimePartToString(CaseID, ScriptID, ActionID);
            ActionType::LENGTHOFSTRING:
                EditorLineItemText := LengthOfStringToString(CaseID, ScriptID, ActionID);
            ActionType::CONVERTCASEOFSTRING:
                EditorLineItemText := ConvertCaseToString(CaseID, ScriptID, ActionID);
            ActionType::ROUNDNUMBER:
                EditorLineItemText := RoundNumberToString(CaseID, ScriptID, ActionID);
            ActionType::NUMERICEXPRESSION:
                EditorLineItemText := NumberExpressionToString(CaseID, ScriptID, ActionID);
            ActionType::STRINGEXPRESSION:
                EditorLineItemText := StringExpressionToString(CaseID, ScriptID, ActionID);
            ActionType::EXITLOOP:
                EditorLineItemText := 'Exit current loop';
            ActionType::CONTINUE:
                EditorLineItemText := 'Skip Next Activites in the current loop';
        end;

        exit(EditorLineItemText);
    end;

    procedure IfConditionToString(CaseID: Guid; ScriptID: Guid; ID: Guid): Text;
    var
        ActionIfStatement: Record "Action If Statement";
        ConditionText: Text;
        IfStatementLbl: Label 'If %1', Comment = '%1 = Condition Text';
        ElseIfStatementLbl: Label 'Else If %1', Comment = '%1 = Condition Text';
    begin
        ActionIfStatement.GET(CaseID, ScriptID, ID);
        ConditionText := ConditionToString(ActionIfStatement."Case ID", ScriptID, ActionIfStatement."Condition ID");

        if (IsNullGuid(ActionIfStatement."Else If Block ID")) and (not IsNullGuid(ActionIfStatement."Parent If Block ID")) and (ConditionText in ['', '< Always >']) then
            exit('Else');

        if not IsNullGuid(ActionIfStatement."Parent If Block ID") then
            exit(StrSubstNo(ElseIfStatementLbl, ConditionText))
        else
            exit(StrSubstNo(IfStatementLbl, ConditionText));

    end;

    procedure ConditionToString(CaseID: Guid; ScriptID: Guid; ID: Guid): Text;
    var
        ConditionItem: Record "Tax Test Condition Item";
        ConditionText: Text;
    begin
        ConditionItem.Reset();
        ConditionItem.SetRange("Case ID", CaseID);
        ConditionItem.SetRange("Script ID", ScriptID);
        ConditionItem.SetRange("Condition ID", ID);
        if ConditionItem.FindSet() then
            repeat
                if ConditionText = '' then
                    ConditionText := ConditionItemToString(ConditionItem)
                else
                    ConditionText := ConditionText + ' ' + ConditionItemToString(ConditionItem);
            until ConditionItem.Next() = 0;

        if ConditionText = '' then
            ConditionText := '< Always >';
        exit(ConditionText);
    end;

    procedure LoopNTimesToString(CaseID: Guid; ScriptID: Guid; ID: Guid): Text;
    var
        ActionLoopNTimes: Record "Action Loop N Times";
        NValueText: Text;
        LoopNTimesLbl: Label 'Loop: (%1) times', Comment = '%1 = Variable Name';
    begin
        ActionLoopNTimes.GET(CaseID, ScriptID, ID);
        NValueText := LookupSerialization.ConstantOrLookupText(
            ActionLoopNTimes."Case ID",
            ActionLoopNTimes."Script ID",
            ActionLoopNTimes."Value Type",
            ActionLoopNTimes.Value,
            ActionLoopNTimes."Lookup ID",
            "Symbol Data Type"::NUMBER);

        exit(StrSubstNo(LoopNTimesLbl, NValueText));
    end;

    procedure LoopWithConditionToString(CaseID: Guid; ScriptID: Guid; ID: Guid): Text;
    var
        ActionLoopWithCondition: Record "Action Loop With Condition";
        ConditionText: Text;
        LoopWithConditionLbl: Label 'Loop: unitl %1', Comment = '%1 = Condtion';
    begin
        ActionLoopWithCondition.GET(CaseID, ScriptID, ID);
        ConditionText := ConditionToString(CaseID, ScriptID, ActionLoopWithCondition."Condition ID");
        exit(StrSubstNo(LoopWithConditionLbl, ConditionText));
    end;

    procedure LoopThroughRecordsToString(CaseID: Guid; ScriptID: Guid; ID: Guid): Text;
    var
        ActionLoopThroughRecords: Record "Action Loop Through Records";
        ActionLoopThroughRecField: Record "Action Loop Through Rec. Field";
        TableName: Text;
        TableFilters: Text;
        FieldName2: Text;
        VariableName: Text;
        RecordFieldText: Text;
        FieldRecordText: Text;
        RecordVariable: Text;
        LoopThroughRecordsLbl: Label 'Loop through %1 %2%3%4',
            Comment = '%1 = Table Name, %2 = Table Filters, %3 = Record Variable, %4 = Record Field Name';
        RecordVariableLbl: Label 'Assign Values to Variable: %1', Comment = '%1 = Record Variable';
        FieldRecordLbl: Label 'Field: %1 to Variable: %2', Comment = '%1 - Field Name, %2 - Variable Name';
        AssignLbl: Label '(Assign %1)', Comment = '%1 Variable names';
    begin
        ActionLoopThroughRecords.GET(CaseID, ScriptID, ID);
        TableName := AppObjectHelper.GetObjectName(ObjectType::Table, ActionLoopThroughRecords."Table ID");
        TableFilters := LookupSerialization.TableFilterToString(CaseID, ScriptID, ActionLoopThroughRecords."Table Filter ID");

        ActionLoopThroughRecField.Reset();
        ActionLoopThroughRecField.SetRange("Case ID", CaseID);
        ActionLoopThroughRecField.SetRange("Script ID", ScriptID);
        ActionLoopThroughRecField.SetRange("Loop ID", ID);
        if ActionLoopThroughRecField.FindSet() then
            repeat
                FieldName2 := AppObjectHelper.GetFieldName(
                    ActionLoopThroughRecField."Table ID",
                    ActionLoopThroughRecField."Field ID");

                VariableName := ScriptSymbolsMgmt.GetSymbolName(
                    "Symbol Type"::Variable,
                    ActionLoopThroughRecField."Variable ID");

                FieldRecordText := StrSubstNo(
                    FieldRecordLbl,
                    EncodeName(FieldName2),
                    EncodeName(VariableName));

                if RecordFieldText <> '' then
                    RecordFieldText += ', ';

                RecordFieldText += FieldRecordText;
            until ActionLoopThroughRecField.Next() = 0;


        if TableFilters <> '' then
            TableFilters := 'where ' + TableFilters;

        if RecordFieldText <> '' then
            RecordFieldText := StrSubstNo(AssignLbl, RecordFieldText);

        if RecordVariable <> '' then
            RecordVariable := StrSubstNo(RecordVariableLbl, EncodeName(RecordVariable));

        exit(StrSubstNo(
            LoopThroughRecordsLbl,
            EncodeName(TableName),
            TableFilters,
            RecordVariable,
            RecordFieldText));
    end;

    procedure CommentToString(CaseID: Guid; ScriptID: Guid; ID: Guid): Text;
    var
        ActionComment: Record "Action Comment";
    begin
        ActionComment.GET(CaseID, ScriptID, ID);
        exit(ActionComment.Text);
    end;

    procedure NumberCalculationToString(CaseID: Guid; ScriptID: Guid; ID: Guid): Text;
    var
        ActionNumberCalculation: Record "Action Number Calculation";
        LHSText: Text;
        RHSText: Text;
        VariableName: Text;
        NumberCalculationLbl: Label 'Calculate %1 %2 %3 (Output to Variable: %4)',
            Comment = '%1 = left, %2 = Operator Name, %3 = right, %4 = Output Variable';
    begin
        ActionNumberCalculation.GET(CaseID, ScriptID, ID);
        LHSText := LookupSerialization.ConstantOrLookupText(
            ActionNumberCalculation."Case ID",
            ActionNumberCalculation."Script ID",
            ActionNumberCalculation."LHS Type",
            ActionNumberCalculation."LHS Value",
            ActionNumberCalculation."LHS Lookup ID",
            "Symbol Data Type"::NUMBER);

        RHSText := LookupSerialization.ConstantOrLookupText(
            ActionNumberCalculation."Case ID",
            ActionNumberCalculation."Script ID",
            ActionNumberCalculation."RHS Type",
            ActionNumberCalculation."RHS Value",
            ActionNumberCalculation."RHS Lookup ID",
            "Symbol Data Type"::NUMBER);

        VariableName := ScriptSymbolsMgmt.GetSymbolName(
            "Symbol Type"::Variable,
            ActionNumberCalculation."Variable ID");

        exit(
            StrSubstNo(
                NumberCalculationLbl,
                LHSText,
                ActionNumberCalculation."Arithmetic Operator",
                RHSText, EncodeName(VariableName)));
    end;

    procedure ExtractSubstringFromPositionToString(CaseID: Guid; ScriptID: Guid; ID: Guid): Text;
    var
        ActionExtSubstrFromPos: Record "Action Ext. Substr. From Pos.";
        VariableName: Text;
        StringText: Text;
        LengthText: Text;
        PositionText: Text;
        ExtractSubstringFromPositionLbl: Label 'Copy %1 characters from %2 of %3 (Output to Variable: %4)',
            Comment = '%1 = Length, %2 = Position, %3 = Variable Name, %4 = Output Variable';
    begin
        ActionExtSubstrFromPos.GET(CaseID, ScriptID, ID);
        StringText := LookupSerialization.ConstantOrLookupText(
            ActionExtSubstrFromPos."Case ID",
            ActionExtSubstrFromPos."Script ID",
            ActionExtSubstrFromPos."String Value Type",
            ActionExtSubstrFromPos."String Value",
            ActionExtSubstrFromPos."String Lookup ID",
            "Symbol Data Type"::STRING);

        LengthText := LookupSerialization.ConstantOrLookupText(
            ActionExtSubstrFromPos."Case ID",
            ActionExtSubstrFromPos."Script ID",
            ActionExtSubstrFromPos."Length Value Type",
            ActionExtSubstrFromPos."Length Value",
            ActionExtSubstrFromPos."Length Lookup ID",
            "Symbol Data Type"::NUMBER);

        VariableName := ScriptSymbolsMgmt.GetSymbolName(
            "Symbol Type"::Variable,
            ActionExtSubstrFromPos."Variable ID");

        PositionText := LOWERCASE(Format(ActionExtSubstrFromPos.Position));
        exit(StrSubstNo(
            ExtractSubstringFromPositionLbl,
            LengthText,
            PositionText,
            StringText,
            EncodeName(VariableName)))
    end;

    procedure FindDateIntervalToString(CaseID: Guid; ScriptID: Guid; ID: Guid): Text;
    var
        ActionFindDateInterval: Record "Action Find Date Interval";
        Date1Text: Text;
        Date2Text: Text;
        VariableName: Text;
        InvervalText: Text;
        FindDateIntervalLbl: Label 'Find %1 between %2 and %3 (Output to Variable: %4)',
            Comment = '%1 = Inverval, %2 = Date 1, %3 = Date 2, %4 = Output Variable';
    begin
        ActionFindDateInterval.GET(CaseID, ScriptID, ID);
        Date1Text := LookupSerialization.ConstantOrLookupText(
            ActionFindDateInterval."Case ID",
            ActionFindDateInterval."Script ID",
            ActionFindDateInterval."Date1 Value Type",
            ActionFindDateInterval."Date1 Value",
            ActionFindDateInterval."Date1 Lookup ID",
            "Symbol Data Type"::DATE);

        Date2Text := LookupSerialization.ConstantOrLookupText(
            ActionFindDateInterval."Case ID",
            ActionFindDateInterval."Script ID",
            ActionFindDateInterval."Date2 Value Type",
            ActionFindDateInterval."Date2 Value",
            ActionFindDateInterval."Date2 Lookup ID",
            "Symbol Data Type"::DATE);

        VariableName := ScriptSymbolsMgmt.GetSymbolName(
            "Symbol Type"::Variable,
            ActionFindDateInterval."Variable ID");

        InvervalText := LOWERCASE(Format(ActionFindDateInterval.Inverval));
        exit(StrSubstNo(FindDateIntervalLbl, InvervalText, Date1Text, Date2Text, EncodeName(VariableName)));

    end;

    procedure SetVariableToString(CaseID: Guid; ScriptID: Guid; ID: Guid): Text;
    var
        ActionSetVariable: Record "Action Set Variable";
        VariableDataType: Enum "Symbol Data Type";
        ValueText: Text;
        VariableName: Text;
        SetVariableLbl: Label 'Set Variable: %1 to %2',
            Comment = '%1 = Variable Name, %2 = Value';
    begin
        ActionSetVariable.GET(CaseID, ScriptID, ID);
        VariableDataType := ScriptSymbolsMgmt.GetSymbolDataType("Symbol Type"::Variable, ActionSetVariable."Variable ID");
        ValueText := LookupSerialization.ConstantOrLookupText(
            ActionSetVariable."Case ID",
            ActionSetVariable."Script ID",
            ActionSetVariable."Value Type",
            ActionSetVariable.Value,
            ActionSetVariable."Lookup ID",
            VariableDataType);

        VariableName := ScriptSymbolsMgmt.GetSymbolName("Symbol Type"::Variable, ActionSetVariable."Variable ID");
        exit(StrSubstNo(SetVariableLbl, VariableName, ValueText));
    end;

    procedure ConcatenateToString(CaseID: Guid; ScriptID: Guid; ID: Guid): Text;
    var
        ActionConcatenate: Record "Action Concatenate";
        ActionConcatenateLine: Record "Action Concatenate Line";
        ConcatenateText: Text;
        VariableName: Text;
        SetVariableLbl: Label 'Concatenate: %1 (Output to Variable: %2)',
            Comment = '%1 = Concatenate Text, %2 = Output Variable';
    begin
        ActionConcatenate.GET(CaseID, ScriptID, ID);
        VariableName := ScriptSymbolsMgmt.GetSymbolName("Symbol Type"::Variable, ActionConcatenate."Variable ID");

        ActionConcatenateLine.Reset();
        ActionConcatenateLine.SetRange("Case ID", CaseID);
        ActionConcatenateLine.SetRange("Script ID", ScriptID);
        ActionConcatenateLine.SetRange("Concatenate ID", ID);
        if ActionConcatenateLine.FindSet() then
            repeat
                if ConcatenateText <> '' then
                    ConcatenateText += ',';

                ConcatenateText += ConcatenateLineToString(ActionConcatenateLine);
            until ActionConcatenateLine.Next() = 0;
        exit(StrSubstNo(SetVariableLbl, ConcatenateText, EncodeName(VariableName)));
    end;

    procedure FindSubstringToString(CaseID: Guid; ScriptID: Guid; ID: Guid): Text;
    var
        ActionFindSubstring: Record "Action Find Substring";
        VariableName: Text;
        SubstringText: Text;
        StringText: Text;
        FindSubstringLbl: Label 'Find %1 in %2 (Output to Variable: %3)',
            Comment = '%1 = Substring Variable, %2 = String Variable, %3 = Output Variable';
    begin
        ActionFindSubstring.GET(CaseID, ScriptID, ID);
        SubstringText := LookupSerialization.ConstantOrLookupText(
            ActionFindSubstring."Case ID",
            ScriptID,
            ActionFindSubstring."Substring Value Type",
            ActionFindSubstring."Substring Value",
            ActionFindSubstring."Substring Lookup ID",
            "Symbol Data Type"::STRING);

        StringText := LookupSerialization.ConstantOrLookupText(
            ActionFindSubstring."Case ID",
            ScriptID,
            ActionFindSubstring."String Value Type",
            ActionFindSubstring."String Value",
            ActionFindSubstring."String Lookup ID",
            "Symbol Data Type"::STRING);

        VariableName := ScriptSymbolsMgmt.GetSymbolName("Symbol Type"::Variable, ActionFindSubstring."Variable ID");
        exit(StrSubstNo(FindSubstringLbl, SubstringText, StringText, EncodeName(VariableName)));
    end;

    procedure RepaceSubstringInStringToString(CaseID: Guid; ScriptID: Guid; ID: Guid): Text;
    var
        ActionReplaceSubstring: Record "Action Replace Substring";
        VariableName: Text;
        SubstringText: Text;
        StringText: Text;
        NewStringText: Text;
        ReplaceSubstringLbl: Label 'Replace %1 with %2 in %3 (Output to Variable: %4)',
            Comment = '%1 = Substring Variable, %2 = New String Variable, %3 = String Variable, %4 = Output Variable';
    begin
        ActionReplaceSubstring.GET(CaseID, ScriptID, ID);
        SubstringText := LookupSerialization.ConstantOrLookupText(
            ActionReplaceSubstring."Case ID",
            ActionReplaceSubstring."Script ID",
            ActionReplaceSubstring."Substring Value Type",
            ActionReplaceSubstring."Substring Value",
            ActionReplaceSubstring."Substring Lookup ID",
            "Symbol Data Type"::STRING);

        StringText := LookupSerialization.ConstantOrLookupText(
            ActionReplaceSubstring."Case ID",
            ActionReplaceSubstring."Script ID",
            ActionReplaceSubstring."String Value Type",
            ActionReplaceSubstring."String Value",
            ActionReplaceSubstring."String Lookup ID",
            "Symbol Data Type"::STRING);

        NewStringText := LookupSerialization.ConstantOrLookupText(
            ActionReplaceSubstring."Case ID",
            ActionReplaceSubstring."Script ID",
            ActionReplaceSubstring."New String Value Type",
            ActionReplaceSubstring."New String Value",
            ActionReplaceSubstring."New String Lookup ID",
            "Symbol Data Type"::STRING);

        VariableName := ScriptSymbolsMgmt.GetSymbolName("Symbol Type"::Variable, ActionReplaceSubstring."Variable ID");


        exit(StrSubstNo(
            ReplaceSubstringLbl,
            SubstringText,
            NewStringText,
            StringText,
            EncodeName(VariableName)));
    end;

    procedure ExtractSubstringFromIndexToString(CaseID: Guid; ScriptID: Guid; ID: Guid): Text;
    var
        ActionExtSubstrFromIndex: Record "Action Ext. Substr. From Index";
        VariableName: Text;
        StringText: Text;
        IndexText: Text;
        LengthText: Text;
        ExtractSubstringFromIndexLbl: Label 'Copy from %1, starting at %2 (Output to Variable: %3)',
            Comment = '%1 = String Variable, %2 = Index Variable, %3 = Output Variable';
        ExtractSubstringFromIndexWithLengthFormatLbl: Label 'Copy from %1, starting at %2 for %3 characters (Output to Variable: %4)',
            Comment = '%1 = String Variable, %2 = Index Variable, %3 = Length, %4 = Output Variable';
    begin
        ActionExtSubstrFromIndex.GET(CaseID, ScriptID, ID);
        StringText := LookupSerialization.ConstantOrLookupText(
            ActionExtSubstrFromIndex."Case ID",
            ActionExtSubstrFromIndex."Script ID",
            ActionExtSubstrFromIndex."String Value Type",
            ActionExtSubstrFromIndex."String Value",
            ActionExtSubstrFromIndex."String Lookup ID",
            "Symbol Data Type"::STRING);

        IndexText := LookupSerialization.ConstantOrLookupText(
            ActionExtSubstrFromIndex."Case ID",
            ActionExtSubstrFromIndex."Script ID",
            ActionExtSubstrFromIndex."Index Value Type",
            ActionExtSubstrFromIndex."Index Value",
            ActionExtSubstrFromIndex."Index Lookup ID",
            "Symbol Data Type"::NUMBER);

        LengthText := LookupSerialization.ConstantOrLookupText(
            ActionExtSubstrFromIndex."Case ID",
            ActionExtSubstrFromIndex."Script ID",
            ActionExtSubstrFromIndex."Length Value Type",
            ActionExtSubstrFromIndex."Length Value",
            ActionExtSubstrFromIndex."Length Lookup ID",
            "Symbol Data Type"::NUMBER);

        VariableName := ScriptSymbolsMgmt.GetSymbolName("Symbol Type"::Variable, ActionExtSubstrFromIndex."Variable ID");

        if LengthText = '' then
            exit(StrSubstNo(ExtractSubstringFromIndexLbl, StringText, IndexText, EncodeName(VariableName)))
        else
            exit(StrSubstNo(ExtractSubstringFromIndexWithLengthFormatLbl, StringText, IndexText, LengthText, EncodeName(VariableName)))
    end;

    procedure DateCalculationToString(CaseID: Guid; ScriptID: Guid; ID: Guid): Text;
    var
        ActionDateCalculation: Record "Action Date Calculation";
        VariableName: Text;
        DateText: Text;
        NumberText: Text;
        OperatorText: Text;
        PeriodText: Text;
        DateCalculationLbl: Label 'Calculate %1 %2 %3 %4 (Output to Variable: %5)',
            Comment = '%1 = Date Variable, %2 = Operator, %3 = Number Variable, %4 = Period, %5 = Output Variable';
    begin
        ActionDateCalculation.GET(CaseID, ScriptID, ID);
        DateText := LookupSerialization.ConstantOrLookupText(
            ActionDateCalculation."Case ID",
            ActionDateCalculation."Script ID",
            ActionDateCalculation."Date Value Type",
            ActionDateCalculation."Date Value",
            ActionDateCalculation."Date Lookup ID",
            "Symbol Data Type"::DATE);

        NumberText := LookupSerialization.ConstantOrLookupText(
            ActionDateCalculation."Case ID",
            ActionDateCalculation."Script ID",
            ActionDateCalculation."Number Value Type",
            ActionDateCalculation."Number Value",
            ActionDateCalculation."Number Lookup ID",
            "Symbol Data Type"::NUMBER);

        VariableName := ScriptSymbolsMgmt.GetSymbolName("Symbol Type"::Variable, ActionDateCalculation."Variable ID");
        OperatorText := LOWERCASE(Format(ActionDateCalculation."Arithmetic operators"));
        PeriodText := LOWERCASE(Format(ActionDateCalculation.Duration));

        exit(StrSubstNo(
            DateCalculationLbl,
            DateText,
            OperatorText,
            NumberText,
            PeriodText,
            EncodeName(VariableName)))
    end;

    procedure DateToDateTimeToString(CaseID: Guid; ScriptID: Guid; ID: Guid): Text;
    var
        ActionDateToDateTime: Record "Action Date To DateTime";
        VariableName: Text;
        DateText: Text;
        TimeText: Text;
        DateToDateTimeLbl: Label 'Calculate DateTime from Date %1, Time %2 (Output to Variable: %3)',
            Comment = '%1 = Date Variable, %2 = Time Variabel, %3 = Output Variable Name';
    begin
        ActionDateToDateTime.GET(CaseID, ScriptID, ID);
        DateText := LookupSerialization.ConstantOrLookupText(
            ActionDateToDateTime."Case ID",
            ActionDateToDateTime."Script ID",
            ActionDateToDateTime."Date Value Type",
            ActionDateToDateTime."Date Value",
            ActionDateToDateTime."Date Lookup ID",
            "Symbol Data Type"::DATE);

        TimeText := LookupSerialization.ConstantOrLookupText(
            ActionDateToDateTime."Case ID",
            ActionDateToDateTime."Script ID",
            ActionDateToDateTime."Time Value Type",
            ActionDateToDateTime."Time Value",
            ActionDateToDateTime."Time Lookup ID",
            "Symbol Data Type"::TIME);

        VariableName := ScriptSymbolsMgmt.GetSymbolName("Symbol Type"::Variable, ActionDateToDateTime."Variable ID");

        exit(StrSubstNo(DateToDateTimeLbl, DateText, TimeText, EncodeName(VariableName)))
    end;

    procedure AlertMessageToString(CaseID: Guid; ScriptID: Guid; ID: Guid): Text;
    var
        ActionMessage: Record "Action Message";
        MessageText: Text;
        ToStringFormatTxt: Label 'Throw Error Message: %1', Comment = '%1 = Message';
        AlertToStringFormatTxt: Label 'Show Message: %1', Comment = '%1 = Message';
    begin
        ActionMessage.GET(CaseID, ScriptID, ID);
        MessageText := LookupSerialization.ConstantOrLookupText(
            ActionMessage."Case ID",
            ActionMessage."Script ID",
            ActionMessage."Value Type",
            ActionMessage.Value,
            ActionMessage."Lookup ID",
            "Symbol Data Type"::STRING);

        if ActionMessage."Throw Error" then
            exit(StrSubstNo(ToStringFormatTxt, MessageText))
        else
            exit(StrSubstNo(AlertToStringFormatTxt, MessageText));
    end;

    procedure ExtractDatePartToString(CaseID: Guid; ScriptID: Guid; ID: Guid): Text;
    var
        ActionExtractDatePart: Record "Action Extract Date Part";
        DateLookupText: Text;
        VariableName: Text;
        PartType: Text;
        ExtractDatePartLbl: Label 'Extract %1 from %2 (Output to Variable: %3)',
            Comment = '%1 = Part Type, %2 = Date Variabel, %3 = Output Variable Name';
    begin
        ActionExtractDatePart.GET(CaseID, ScriptID, ID);
        DateLookupText := LookupSerialization.ConstantOrLookupText(
            ActionExtractDatePart."Case ID",
            ActionExtractDatePart."Script ID",
            ActionExtractDatePart."Value Type",
            ActionExtractDatePart.Value,
            ActionExtractDatePart."Lookup ID",
            "Symbol Data Type"::DATE);

        VariableName := ScriptSymbolsMgmt.GetSymbolName("Symbol Type"::Variable, ActionExtractDatePart."Variable ID");
        PartType := LOWERCASE(Format(ActionExtractDatePart."Date Part"));
        exit(StrSubstNo(ExtractDatePartLbl, PartType, DateLookupText, VariableName));
    end;

    procedure ExtractDateTimePartToString(CaseID: Guid; ScriptID: Guid; ID: Guid): Text;
    var
        ActionExtractDateTimePart: Record "Action Extract DateTime Part";
        DateLookupText: Text;
        VariableName: Text;
        PartType: Text;
        ExtractDateTimePartLbl: Label 'Extract %1 from %2 (Output to Variable: %3)',
            Comment = '%1 = Date / Time, %2 = Date / Time Variabel, %3 = Output Variable Name';
    begin
        ActionExtractDateTimePart.GET(CaseID, ScriptID, ID);
        DateLookupText := LookupSerialization.ConstantOrLookupText(
            ActionExtractDateTimePart."Case ID",
            ActionExtractDateTimePart."Script ID",
            ActionExtractDateTimePart."Value Type",
            ActionExtractDateTimePart.Value,
            ActionExtractDateTimePart."Lookup ID",
            "Symbol Data Type"::DATETIME);

        VariableName := ScriptSymbolsMgmt.GetSymbolName(
            "Symbol Type"::Variable,
            ActionExtractDateTimePart."Variable ID");

        PartType := LOWERCASE(Format(ActionExtractDateTimePart."Part Type"));
        exit(StrSubstNo(ExtractDateTimePartLbl, PartType, DateLookupText, VariableName));
    end;

    procedure LengthOfStringToString(CaseID: Guid; ScriptID: Guid; ID: Guid): Text;
    var
        ActionLengthOfString: Record "Action Length Of String";
        VariableName: Text;
        LookupVariableName: Text;
        LengthOfStringLbl: Label 'Extract length of %1 (Output to Variable: %2)',
            Comment = '%1 = Variable Name, %2 = Output Variable Name';
    begin
        ActionLengthOfString.GET(CaseID, ScriptID, ID);
        VariableName := ScriptSymbolsMgmt.GetSymbolName("Symbol Type"::Variable, ActionLengthOfString."Variable ID");
        LookupVariableName := LookupSerialization.ConstantOrLookupText(
            ActionLengthOfString."Case ID",
            ActionLengthOfString."Script ID",
            ActionLengthOfString."Value Type",
            ActionLengthOfString.Value,
            ActionLengthOfString."Lookup ID",
            "Symbol Data Type"::STRING);

        exit(StrSubstNo(LengthOfStringLbl, LookupVariableName, VariableName));
    end;

    procedure ConvertCaseToString(CaseID: Guid; ScriptID: Guid; ID: Guid): Text;
    var
        ActionConvertCase: Record "Action Convert Case";
        VariableName: Text;
        LookupVariableName: Text;
        ConvertToCaseText: Text;
        ConvertCaseLbl: Label 'Convert %1 to %2 (Output to Variable: %3)',
            Comment = '%1 = Variable Name, %2 = Case, %3 = Output Variable Name';
    begin
        ActionConvertCase.GET(CaseID, ScriptID, ID);
        VariableName := ScriptSymbolsMgmt.GetSymbolName("Symbol Type"::Variable, ActionConvertCase."Variable ID");
        LookupVariableName := LookupSerialization.ConstantOrLookupText(
            ActionConvertCase."Case ID",
            ActionConvertCase."Script ID",
            ActionConvertCase."Value Type",
            ActionConvertCase.Value,
            ActionConvertCase."Lookup ID",
            "Symbol Data Type"::STRING);

        ConvertToCaseText := LOWERCASE(Format(ActionConvertCase."Convert To Case"));
        exit(StrSubstNo(ConvertCaseLbl, LookupVariableName, ConvertToCaseText, VariableName));
    end;

    procedure RoundNumberToString(CaseID: Guid; ScriptID: Guid; ID: Guid): Text;
    var
        ActionRoundNumber: Record "Action Round Number";
        VariableName: Text;
        NumberLookupName: Text;
        PrecisionLookupName: Text;
        DirectionText: Text;
        RoundNumberLbl: Label 'Round %1 to %2 with precision %3 (Output to Variable: %4)',
            Comment = '%1 = Number, %2 = Direction, %3 = Precision, %4 = Output Variable Name';
    begin
        ActionRoundNumber.GET(CaseID, ScriptID, ID);
        VariableName := ScriptSymbolsMgmt.GetSymbolName("Symbol Type"::Variable, ActionRoundNumber."Variable ID");
        NumberLookupName := LookupSerialization.ConstantOrLookupText(
            ActionRoundNumber."Case ID",
            ActionRoundNumber."Script ID",
            ActionRoundNumber."Number Value Type",
            ActionRoundNumber."Number Value",
            ActionRoundNumber."Number Lookup ID",
            "Symbol Data Type"::NUMBER);

        PrecisionLookupName := LookupSerialization.ConstantOrLookupText(
            ActionRoundNumber."Case ID",
            ActionRoundNumber."Script ID",
            ActionRoundNumber."Precision Value Type",
            ActionRoundNumber."Precision Value",
            ActionRoundNumber."Precision Lookup ID",
            "Symbol Data Type"::NUMBER);

        DirectionText := LOWERCASE(Format(ActionRoundNumber.Direction));
        exit(StrSubstNo(RoundNumberLbl, NumberLookupName, DirectionText, PrecisionLookupName, VariableName));
    end;

    procedure NumberExpressionToString(CaseID: Guid; ScriptID: Guid; ID: Guid): Text;
    var
        ActionNumberExpression: Record "Action Number Expression";
        VariableName: Text;
        NumberExpressionLbl: Label 'Evaluate "%1", %2 (Output to Variable: %3)', Comment = '%1 = Expression, %2 = Token String, %3 = Variable Name';
    begin
        ActionNumberExpression.GET(CaseID, ScriptID, ID);
        VariableName := ScriptSymbolsMgmt.GetSymbolName("Symbol Type"::Variable, ActionNumberExpression."Variable ID");
        exit(StrSubstNo(
            NumberExpressionLbl,
            ActionNumberExpression.Expression,
            NumberExprTokenToString(ActionNumberExpression),
            VariableName));
    end;

    procedure StringExpressionToString(CaseID: Guid; ScriptID: Guid; ID: Guid): Text;
    var
        ActionStringExpression: Record "Action String Expression";
        VariableName: Text;
        StringExpressionLbl: Label 'Evaluate "%1", %2 (Output to Variable: %3)', Comment = '%1 = Expression, %2 = Token String, %3 = Variable Name';
    begin
        ActionStringExpression.GET(CaseID, ScriptID, ID);
        VariableName := ScriptSymbolsMgmt.GetSymbolName("Symbol Type"::Variable, ActionStringExpression."Variable ID");
        exit(StrSubstNo(
            StringExpressionLbl, ActionStringExpression.Expression,
            StringExprTokenToString(ActionStringExpression),
            VariableName));
    end;

    procedure ConcatenateLineToString(ActionConcatenateLine: Record "Action Concatenate Line"): Text;
    var
        ValueText: Text;
    begin
        ValueText := LookupSerialization.ConstantOrLookupText(
            ActionConcatenateLine."Case ID",
            ActionConcatenateLine."Script ID",
            ActionConcatenateLine."Value Type",
            ActionConcatenateLine.Value,
            ActionConcatenateLine."Lookup ID",
            "Symbol Data Type"::STRING);

        exit(ValueText);
    end;

    procedure LookupTableToString(ScriptSymbolLookup: Record "Script Symbol Lookup"): Text;
    var
        TableName2: Text;
        FieldName2: Text;
        TableFilters: Text;
        MethodText: Text;
        FromFieldName: Text;
        TableLookupWithFiltersLbl: Label '%1 of %2 from %3 (where %4)', Comment = '%1 = Method, %2 = Field Name, %3 = Table Name, %4 = Table Filters';
        TableLookupLbl: Label '%1 of %2 from %3', Comment = '%1 = Method, %2 = Field Name, %3 = Table Name';
    begin
        TableName2 := AppObjectHelper.GetObjectName(ObjectType::Table, ScriptSymbolLookup."Source ID");
        FieldName2 := AppObjectHelper.GetFieldName(
            ScriptSymbolLookup."Source ID",
            ScriptSymbolLookup."Source Field ID");

        MethodText := LOWERCASE(Format(ScriptSymbolLookup."Table Method"));

        if ScriptSymbolLookup."Table Method" = ScriptSymbolLookup."Table Method"::Count then
            FromFieldName := 'records'
        else
            FromFieldName := EncodeName(FieldName2);

        if not IsNullGuid(ScriptSymbolLookup."Table Filter ID") then begin
            TableFilters := LookupSerialization.TableFilterToString(ScriptSymbolLookup."Case ID", ScriptSymbolLookup."Script ID", ScriptSymbolLookup."Table Filter ID");
            if TableFilters <> '' then
                exit(StrSubstNo(TableLookupWithFiltersLbl, MethodText, FromFieldName, EncodeName(TableName2), TableFilters));
        end;

        exit(StrSubstNo(TableLookupLbl, MethodText, FromFieldName, EncodeName(TableName2)));

    end;

    procedure TableSortingToString(CaseID: Guid; ScriptID: Guid; ID: Guid): Text;
    var
        LookupTableSorting: Record "Lookup Table Sorting";
        LookupFieldSorting: Record "Lookup Field Sorting";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        KeyRef: KeyRef;
        j: Integer;
        TableKeys: Text;
    begin

        LookupFieldSorting.Reset();
        LookupFieldSorting.SetRange("Case ID", CaseID);
        LookupFieldSorting.SetRange("Script ID", ScriptID);
        LookupFieldSorting.SetRange("Table Sorting ID", ID);
        if LookupFieldSorting.FindSet() then
            repeat
                if TableKeys <> '' then
                    TableKeys += ',';

                TableKeys += EncodeName(AppObjectHelper.GetFieldName(LookupFieldSorting."Table ID", LookupFieldSorting."Field ID"));
            until LookupFieldSorting.Next() = 0;

        if TableKeys = '' then begin
            LookupTableSorting.Get(CaseID, ScriptID, ID);
            RecRef.Open(LookupTableSorting."Table ID");

            KeyRef := RecRef.KeyIndex(1);
            for j := 1 TO KeyRef.FieldCount() do begin
                Clear(FieldRef);
                FieldRef := KeyRef.FieldIndex(j);
                TableKeys += EncodeName(AppObjectHelper.GetFieldName(RecRef.Number(), FieldRef.Number()));
            end;
        end;

        exit(TableKeys);
    end;

    local procedure NumberExprTokenToString(var ActionNumberExpression: Record "Action Number Expression"): Text;
    var
        ActionNumberExprToken: Record "Action Number Expr. Token";
        LookupVariableName: Text;
        LineText: Text;
        ToStringText: Text;
        AssignmentLbl: Label '%1 equals %2', Comment = '%1 = Token, %2 = Lookup / Variable';
    begin
        ActionNumberExprToken.Reset();
        ActionNumberExprToken.SetRange("Case ID", ActionNumberExpression."Case ID");
        ActionNumberExprToken.SetRange("Numeric Expr. ID", ActionNumberExpression.ID);
        if ActionNumberExprToken.FindSet() then
            repeat
                LookupVariableName := LookupSerialization.ConstantOrLookupText(
                    ActionNumberExprToken."Case ID",
                    ActionNumberExprToken."Script ID",
                    ActionNumberExprToken."Value Type",
                    ActionNumberExprToken.Value,
                    ActionNumberExprToken."Lookup ID",
                    "Symbol Data Type"::NUMBER);

                LineText := StrSubstNo(AssignmentLbl, ActionNumberExprToken.Token, LookupVariableName);
                if ToStringText <> '' then
                    ToStringText += ', ';
                ToStringText += LineText;
            until ActionNumberExprToken.Next() = 0;

        exit(ToStringText);
    end;

    local procedure StringExprTokenToString(var ActionStringExpression: Record "Action String Expression"): Text;
    var
        ActionStringExprToken: Record "Action String Expr. Token";
        LookupVariableName: Text;
        LineText: Text;
        ToStringText: Text;
        AssignmentLbl: Label '%1 equals %2', Comment = '%1 = Token, %2 = Lookup / Variable';
    begin
        ActionStringExprToken.Reset();
        ActionStringExprToken.SetRange("Case ID", ActionStringExpression."Script ID");
        ActionStringExprToken.SetRange("String Expr. ID", ActionStringExpression.ID);
        if ActionStringExprToken.FindSet() then
            repeat
                LookupVariableName := LookupSerialization.ConstantOrLookupText(
                    ActionStringExprToken."Case ID",
                    ActionStringExprToken."Script ID",
                    ActionStringExprToken."Value Type",
                    ActionStringExprToken.Value,
                    ActionStringExprToken."Lookup ID",
                    "Symbol Data Type"::STRING);

                LineText := StrSubstNo(AssignmentLbl, ActionStringExprToken.Token, LookupVariableName);
                if ToStringText <> '' then
                    ToStringText += ', ';
                ToStringText += LineText;
            until ActionStringExprToken.Next() = 0;

        exit(ToStringText);
    end;

    local procedure EncodeName(Name: Text): Text;
    var
        TempName: Text;
        NameLbl: Label '"%1"', Comment = '%1 = Name';
    begin
        TempName := DELCHR(Name, '<>=', '."\/''%][ ');
        if TempName <> Name then
            exit(StrSubstNo(NameLbl, Name))
        else
            exit(Name);
    end;

    local procedure ConditionItemToString(ConditionItem: Record "Tax Test Condition Item"): Text;
    var
        LHSDataType: Enum "Symbol Data Type";
        LHSText: Text;
        RHSText: Text;
        ConditionText: Text;
        ConditionWithLogicalOperatorLbl: Label '%1 %2 %3 %4', Comment = '%1 = Logical Operator", %2 = left, %3 = Conditional Operator, %4 = right';
        ConditionWithOutLogicalOperatorLbl: Label '%1 %2 %3', Comment = '%1 = left, %2 = Conditional Operator, %3 = right';
    begin
        if not IsNullGuid(ConditionItem."LHS Lookup ID") then begin
            LHSText := LookupSerialization.LookupToString(
                ConditionItem."Case ID",
                ConditionItem."Script ID",
                ConditionItem."LHS Lookup ID");

            LHSDatatype := LookupMgmt.GetLookupDatatype(ConditionItem."Case ID", ConditionItem."Script ID", ConditionItem."LHS Lookup ID");

            RHSText := LookupSerialization.ConstantOrLookupText(
                ConditionItem."Case ID",
                ConditionItem."Script ID",
                ConditionItem."RHS Type",
                ConditionItem."RHS Value",
                ConditionItem."RHS Lookup ID",
                LHSDataType);
        end;
        if ConditionItem."Logical Operator" = ConditionItem."Logical Operator"::" " then
            ConditionText := StrSubstNo(ConditionWithOutLogicalOperatorLbl, LHSText, ConditionItem."Conditional Operator", RHSText)
        else
            ConditionText := StrSubstNo(
                ConditionWithLogicalOperatorLbl,
                ConditionItem."Logical Operator",
                LHSText,
                ConditionItem."Conditional Operator",
                RHSText);

        exit(ConditionText);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Lookup Serialization", 'OnSerializeLookupToString', '', false, false)]
    local procedure OnSerializeLookupToString(
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        var SerializedText: Text)
    var
        TableFieldName: Text;
        SymbolLbl: Label '%1: %2', Comment = '%1 = Source type, %2 = Variable name';
    begin
        ScriptSymbolsMgmt.SetContext(ScriptSymbolLookup."Case ID", ScriptSymbolLookup."Script ID");
        case ScriptSymbolLookup."Source Type" of
            ScriptSymbolLookup."Source Type"::Variable:
                begin
                    TableFieldName := ScriptSymbolsMgmt.GetSymbolName(ScriptSymbolLookup."Source Type", ScriptSymbolLookup."Source Field ID");
                    SerializedText := StrSubstNo(SymbolLbl, EncodeName(TableFieldName), ScriptSymbolLookup."Source Type");
                end;
        end;

    end;
}

