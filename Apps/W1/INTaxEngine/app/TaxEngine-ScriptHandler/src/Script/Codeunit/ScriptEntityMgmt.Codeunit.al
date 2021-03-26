codeunit 20166 "Script Entity Mgmt."
{
    /// Comments
    procedure CreateComment(CaseID: Guid; ScriptID: Guid; Comment: Text[250]): Guid;
    var
        ActionComment: Record "Action Comment";
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed(CaseID);
        ActionComment.Init();
        ActionComment."Case ID" := CaseID;
        ActionComment."Script ID" := ScriptID;
        ActionComment.ID := CreateGuid();
        ActionComment.Text := Comment;
        ActionComment.Insert(true);

        exit(ActionComment.ID);
    end;

    procedure DeleteComment(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionComment: Record "Action Comment";
    begin
        if IsNullGuid(ID) then
            Exit;

        ActionComment.GET(CaseID, ScriptID, ID);
        ActionComment.Delete(true);
    end;

    procedure UpdateComment(CaseID: Guid; ScriptID: Guid; ID: Guid; Comment: Text);
    var
        ActionComment: Record "Action Comment";
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed(CaseID);
        ActionComment.GET(CaseID, ScriptID, ID);
        ActionComment.Text := CopyStr(Comment, 1, 250);
        ActionComment.Modify();
    end;

    /// Calculation

    procedure CreateNumberCalculation(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionNumberCalculation: Record "Action Number Calculation";
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed(CaseID);
        ActionNumberCalculation.Init();
        ActionNumberCalculation."Case ID" := CaseID;
        ActionNumberCalculation."Script ID" := ScriptID;
        ActionNumberCalculation.ID := CreateGuid();
        ActionNumberCalculation.Insert(true);

        exit(ActionNumberCalculation.ID);
    end;

    procedure DeleteNumberCalculation(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionNumberCalculation: Record "Action Number Calculation";
    begin
        if IsNullGuid(ID) then
            Exit;

        ActionNumberCalculation.GET(CaseID, ScriptID, ID);
        ActionNumberCalculation.Delete(true);
    end;

    /// If Calculation

    procedure CreateIfCondition(CaseID: Guid; ScriptID: Guid; ParentID: Guid): Guid;
    var
        ActionIfStatement: Record "Action If Statement";
        ParentIfStatement: Record "Action If Statement";
        ScriptSymbolStore: Codeunit "Script Symbol Store";
        ElseAlreadyExistErr: Label 'Else Condition already exists for this branch.';
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed(CaseID);
        if not IsNullGuid(ParentID) then begin
            ParentIfStatement.GET(CaseID, ScriptID, ParentID);
            if not IsNullGuid(ParentIfStatement."Else If Block ID") then
                Error(ElseAlreadyExistErr);
        end;

        ActionIfStatement.Init();
        ActionIfStatement."Case ID" := CaseID;
        ActionIfStatement."Script ID" := ScriptID;
        ActionIfStatement.ID := CreateGuid();
        ActionIfStatement."Parent If Block ID" := ParentID;
        ActionIfStatement."Condition ID" := CreateCondition(CaseID, ScriptID);
        ActionIfStatement.Insert(true);

        if not IsNullGuid(ParentID) then begin
            ParentIfStatement."Else If Block ID" := ActionIfStatement.ID;
            ParentIfStatement.Modify();
        end;

        exit(ActionIfStatement.ID);
    end;

    procedure DeleteIfCondition(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionIfStatement: Record "Action If Statement";
        ParentIfStatement: Record "Action If Statement";
        ChildIfStatement: Record "Action If Statement";
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed(CaseID);
        if IsNullGuid(ID) then
            Exit;

        ActionIfStatement.GET(CaseID, ScriptID, ID);

        if not IsNullGuid(ActionIfStatement."Parent If Block ID") then begin
            ParentIfStatement.GET(
                ActionIfStatement."Case ID",
                ActionIfStatement."Script ID",
                ActionIfStatement."Parent If Block ID");
            ParentIfStatement."Else If Block ID" := ActionIfStatement."Else If Block ID";
            ParentIfStatement.Modify();
        end;

        if not IsNullGuid(ActionIfStatement."Else If Block ID") then begin
            ChildIfStatement.GET(
                ActionIfStatement."Case ID",
                ActionIfStatement."Script ID",
                ActionIfStatement."Else If Block ID");
            ChildIfStatement."Parent If Block ID" := ParentIfStatement.ID;
            ChildIfStatement.Modify();
        end;

        ActionIfStatement.Delete(true);
    end;

    procedure AddElseIfCondition(CaseID: Guid; ScriptID: Guid; ItemID: Guid);
    var
        ActionContainer: Record "Action Container";
        ActionContainer2: Record "Action Container";
        TempActionContainer: Record "Action Container" Temporary;
        ScriptSymbolStore: Codeunit "Script Symbol Store";
        NextLineNo: Integer;
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed(CaseID);
        ActionContainer.Reset();
        ActionContainer.SetRange("Case ID", CaseID);
        ActionContainer.SetRange("Script ID", ScriptID);
        ActionContainer.SetRange("Action Type", "Action Type"::IFSTATEMENT);
        ActionContainer.SetRange("Action ID", ItemID);
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
                TempActionContainer.Insert(true);
                ActionContainer2.Delete();
            until ActionContainer2.Next() = 0;

        NextLineNo += 10000;
        ActionContainer."Line No." := NextLineNo;
        ActionContainer."Action ID" := CreateIfCondition(CaseID, ScriptID, ItemID);
        ActionContainer.Insert(true);

        TempActionContainer.Reset();
        if TempActionContainer.FindSet() then
            repeat
                NextLineNo += 10000;
                ActionContainer2 := TempActionContainer;
                ActionContainer2."Line No." := NextLineNo;
                ActionContainer2.Insert(true);
            until TempActionContainer.Next() = 0;
    end;

    /// Loop N Times
    procedure CreateLoopNTimes(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionLoopNTimes: Record "Action Loop N Times";
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed(CaseID);
        ActionLoopNTimes.Init();
        ActionLoopNTimes."Case ID" := CaseID;
        ActionLoopNTimes."Script ID" := ScriptID;
        ActionLoopNTimes.ID := CreateGuid();
        ActionLoopNTimes.Insert(true);

        exit(ActionLoopNTimes.ID);
    end;

    procedure DeleteLoopNTimes(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionLoopNTimes: Record "Action Loop N Times";
    begin
        if IsNullGuid(ID) then
            Exit;

        ActionLoopNTimes.GET(CaseID, ScriptID, ID);
        ActionLoopNTimes.Delete(true);
    end;

    /// Loop with Condition

    procedure CreateLoopWithCondition(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionLoopWithCondition: Record "Action Loop With Condition";
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed(CaseID);
        ActionLoopWithCondition.Init();
        ActionLoopWithCondition."Case ID" := CaseID;
        ActionLoopWithCondition."Script ID" := ScriptID;
        ActionLoopWithCondition.ID := CreateGuid();
        ActionLoopWithCondition."Condition ID" := CreateCondition(CaseID, ScriptID);
        ActionLoopWithCondition.Insert(true);

        exit(ActionLoopWithCondition.ID);
    end;

    procedure DeleteLoopWithCondition(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionLoopWithCondition: Record "Action Loop With Condition";
    begin
        if IsNullGuid(ID) then
            Exit;

        ActionLoopWithCondition.GET(CaseID, ScriptID, ID);
        ActionLoopWithCondition.Delete(true);
    end;

    procedure CreateScriptContext(CaseID: Guid): Guid;
    var
        ScriptContext: Record "Script Context";
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed(CaseID);
        ScriptContext.Init();
        ScriptContext.ID := CreateGuid();
        ScriptContext."Case ID" := CaseID;
        ScriptContext.Insert(true);

        exit(ScriptContext.ID);
    end;

    procedure DeleteScriptContext(CaseID: Guid; ID: Guid);
    var
        ScriptContext: Record "Script Context";
    begin
        if IsNullGuid(ID) then
            Exit;

        ScriptContext.GET(ID);
        ScriptContext.Delete(true);
    end;


    /// Date Function
    procedure CreateFindDateInterval(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionFindDateInterval: Record "Action Find Date Interval";
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed(CaseID);
        ActionFindDateInterval.Init();
        ActionFindDateInterval."Case ID" := CaseID;
        ActionFindDateInterval."Script ID" := ScriptID;
        ActionFindDateInterval.ID := CreateGuid();
        ActionFindDateInterval.Insert(true);

        exit(ActionFindDateInterval.ID);
    end;

    procedure DeleteFindDateInterval(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionFindDateInterval: Record "Action Find Date Interval";
    begin
        if IsNullGuid(ID) then
            Exit;

        ActionFindDateInterval.GET(CaseID, ScriptID, ID);
        ActionFindDateInterval.Delete(true);
    end;

    /// Condition
    procedure CreateCondition(CaseID: Guid; ScriptID: Guid): Guid;
    var
        Condition: Record "Tax Test Condition";
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed(CaseID);
        Condition.Init();
        Condition."Case ID" := CaseID;
        Condition."Script ID" := ScriptID;
        Condition.ID := CreateGuid();
        Condition.Insert(true);

        exit(Condition.ID);
    end;

    procedure DeleteCondition(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        Condition: Record "Tax Test Condition";
    begin
        if IsNullGuid(ID) then
            Exit;

        Condition.GET(CaseID, ScriptID, ID);
        Condition.Delete(true);
    end;

    procedure CreateContainerItem(CaseID: Guid; ScriptID: Guid; ActionType: Enum "Action Type"): Guid;
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";
        ActionID: Guid;
        CreateContainerItemErr: Label 'Cannot Create Action ''%1''.', Comment = '%1 - Action Type';
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed(CaseID);
        case ActionType of
            ActionType::COMMENT:
                ActionID := CreateComment(CaseID, ScriptID, '');
            ActionType::NUMBERCALCULATION:
                ActionID := CreateNumberCalculation(CaseID, ScriptID);
            ActionType::IFSTATEMENT:
                ActionID := CreateIfCondition(CaseID, ScriptID, EmptyGuid);
            ActionType::LOOPNTIMES:
                ActionID := CreateLoopNTimes(CaseID, ScriptID);
            ActionType::LOOPWITHCONDITION:
                ActionID := CreateLoopWithCondition(CaseID, ScriptID);
            ActionType::EXTRACTSUBSTRINGFROMPOSITION:
                ActionID := CreateExtSubstrFromPos(CaseID, ScriptID);
            ActionType::FINDINTERVALBETWEENDATES:
                ActionID := CreateFindDateInterval(CaseID, ScriptID);
            ActionType::SETVARIABLE:
                ActionID := CreateSetVariable(CaseID, ScriptID);
            ActionType::CONCATENATE:
                ActionID := CreateConcatenate(CaseID, ScriptID);
            ActionType::FINDSUBSTRINGINSTRING:
                ActionID := CreateFindSubstrInString(CaseID, ScriptID);
            ActionType::REPLACESUBSTRINGINSTRING:
                ActionID := CreateReplaceSubstring(CaseID, ScriptID);
            ActionType::EXTRACTSUBSTRINGFROMINDEXOFSTRING:
                ActionID := CreateExtSubstrFromIndex(CaseID, ScriptID);
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
                ActionID := CreateNumericExpression(CaseID, ScriptID);
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

    procedure DeleteContainerItem(
        CaseID: Guid;
        ScriptID: Guid;
        ActionType: Enum "Action Type";
        ActionID: Guid);
    begin
        case ActionType of
            ActionType::DRAFTROW,
          ActionType::EXITLOOP,
          ActionType::CONTINUE:
                ; // Ignore
            ActionType::COMMENT:
                DeleteComment(CaseID, ScriptID, ActionID);
            ActionType::NUMBERCALCULATION:
                DeleteNumberCalculation(CaseID, ScriptID, ActionID);
            ActionType::LOOPNTIMES:
                DeleteLoopNTimes(CaseID, ScriptID, ActionID);
            ActionType::LOOPWITHCONDITION:
                DeleteLoopWithCondition(CaseID, ScriptID, ActionID);
            ActionType::EXTRACTSUBSTRINGFROMPOSITION:
                DeleteExtSubstrFromPos(CaseID, ScriptID, ActionID);
            ActionType::FINDINTERVALBETWEENDATES:
                DeleteFindDateInterval(CaseID, ScriptID, ActionID);
            ActionType::IFSTATEMENT:
                DeleteIfCondition(CaseID, ScriptID, ActionID);
            ActionType::SETVARIABLE:
                DeleteSetVariable(CaseID, ScriptID, ActionID);
            ActionType::CONCATENATE:
                DeleteConcatenate(CaseID, ScriptID, ActionID);
            ActionType::FINDSUBSTRINGINSTRING:
                DeleteFindSubstrInString(CaseID, ScriptID, ActionID);
            ActionType::REPLACESUBSTRINGINSTRING:
                DeleteReplaceSubstring(CaseID, ScriptID, ActionID);
            ActionType::EXTRACTSUBSTRINGFROMINDEXOFSTRING:
                DeleteExtSubstrFromIndex(CaseID, ScriptID, ActionID);
            ActionType::DATECALCULATION:
                DeleteDateCalculation(CaseID, ScriptID, ActionID);
            ActionType::DATETODATETIME:
                DeleteDateToDateTime(CaseID, ScriptID, ActionID);
            ActionType::ALERTMESSAGE:
                DeleteAlertMessage(CaseID, ScriptID, ActionID);
            ActionType::LOOPTHROUGHRECORDS:
                DeleteLoopThroughRecords(CaseID, ScriptID, ActionID);
            ActionType::EXTRACTDATEPART:
                DeleteExtractDatePart(CaseID, ScriptID, ActionID);
            ActionType::EXTRACTDATETIMEPART:
                DeleteExtractDateTimePart(CaseID, ScriptID, ActionID);
            ActionType::LENGTHOFSTRING:
                DeleteLengthOfString(CaseID, ScriptID, ActionID);
            ActionType::CONVERTCASEOFSTRING:
                DeleteConvertCaseOfString(CaseID, ScriptID, ActionID);
            ActionType::ROUNDNUMBER:
                DeleteRoundNumber(CaseID, ScriptID, ActionID);
            ActionType::NUMERICEXPRESSION:
                DeleteNumericExpression(CaseID, ScriptID, ActionID);
            ActionType::STRINGEXPRESSION:
                DeleteStringExpression(CaseID, ScriptID, ActionID);
        end;
    end;

    /// Set Rule Variable

    procedure CreateSetVariable(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionSetVariable: Record "Action Set Variable";
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed(CaseID);
        ActionSetVariable.Init();
        ActionSetVariable."Case ID" := CaseID;
        ActionSetVariable."Script ID" := ScriptID;
        ActionSetVariable.ID := CreateGuid();
        ActionSetVariable.Insert(true);

        exit(ActionSetVariable.ID);
    end;

    procedure DeleteSetVariable(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionSetVariable: Record "Action Set Variable";
    begin
        if IsNullGuid(ID) then
            Exit;

        ActionSetVariable.GET(CaseID, ScriptID, ID);
        ActionSetVariable.Delete(true);
    end;

    /// Rule Concatenate

    procedure CreateConcatenate(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionConcatenate: Record "Action Concatenate";
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed(CaseID);
        ActionConcatenate.Init();
        ActionConcatenate."Case ID" := CaseID;
        ActionConcatenate."Script ID" := ScriptID;
        ActionConcatenate.ID := CreateGuid();
        ActionConcatenate.Insert(true);

        exit(ActionConcatenate.ID);
    end;

    procedure DeleteConcatenate(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionConcatenate: Record "Action Concatenate";
    begin
        if IsNullGuid(ID) then
            Exit;

        ActionConcatenate.GET(CaseID, ScriptID, ID);
        ActionConcatenate.Delete(true);
    end;

    /// Find Substring In String

    procedure CreateFindSubstrInString(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionFindSubstring: Record "Action Find Substring";
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed(CaseID);
        ActionFindSubstring.Init();
        ActionFindSubstring."Case ID" := CaseID;
        ActionFindSubstring."Script ID" := ScriptID;
        ActionFindSubstring.ID := CreateGuid();
        ActionFindSubstring.Insert(true);

        exit(ActionFindSubstring.ID);
    end;

    procedure DeleteFindSubstrInString(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionFindSubstring: Record "Action Find Substring";
    begin
        if IsNullGuid(ID) then
            Exit;

        ActionFindSubstring.GET(CaseID, ScriptID, ID);
        ActionFindSubstring.Delete(true);
    end;

    /// Replace Substring In String
    procedure CreateReplaceSubstring(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionReplaceSubstring: Record "Action Replace Substring";
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed(CaseID);
        ActionReplaceSubstring.Init();
        ActionReplaceSubstring."Case ID" := CaseID;
        ActionReplaceSubstring."Script ID" := ScriptID;
        ActionReplaceSubstring.ID := CreateGuid();
        ActionReplaceSubstring.Insert(true);

        exit(ActionReplaceSubstring.ID);
    end;

    procedure DeleteReplaceSubstring(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionReplaceSubstring: Record "Action Replace Substring";
    begin
        if IsNullGuid(ID) then
            Exit;

        ActionReplaceSubstring.GET(CaseID, ScriptID, ID);
        ActionReplaceSubstring.Delete(true);
    end;

    //// Extract Substring From Index of String
    procedure CreateExtSubstrFromIndex(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionExtSubstrFromIndex: Record "Action Ext. Substr. From Index";
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed(CaseID);
        ActionExtSubstrFromIndex.Init();
        ActionExtSubstrFromIndex."Case ID" := CaseID;
        ActionExtSubstrFromIndex."Script ID" := ScriptID;
        ActionExtSubstrFromIndex.ID := CreateGuid();
        ActionExtSubstrFromIndex.Insert(true);

        exit(ActionExtSubstrFromIndex.ID);
    end;

    procedure DeleteExtSubstrFromIndex(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionExtSubstrFromIndex: Record "Action Ext. Substr. From Index";
    begin
        if IsNullGuid(ID) then
            Exit;

        ActionExtSubstrFromIndex.GET(CaseID, ScriptID, ID);
        ActionExtSubstrFromIndex.Delete(true);
    end;

    // Extract Substring From Position

    procedure CreateExtSubstrFromPos(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionExtSubstrFromPos: Record "Action Ext. Substr. From Pos.";
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed(CaseID);
        ActionExtSubstrFromPos.Init();
        ActionExtSubstrFromPos."Case ID" := CaseID;
        ActionExtSubstrFromPos."Script ID" := ScriptID;
        ActionExtSubstrFromPos.ID := CreateGuid();
        ActionExtSubstrFromPos.Insert(true);

        exit(ActionExtSubstrFromPos.ID);
    end;

    procedure DeleteExtSubstrFromPos(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionExtSubstrFromPos: Record "Action Ext. Substr. From Pos.";
    begin
        if IsNullGuid(ID) then
            Exit;

        ActionExtSubstrFromPos.GET(CaseID, ScriptID, ID);
        ActionExtSubstrFromPos.Delete(true);
    end;

    /// Date Calculation
    procedure CreateDateCalculation(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionDateCalculation: Record "Action Date Calculation";
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed(CaseID);
        ActionDateCalculation.Init();
        ActionDateCalculation."Case ID" := CaseID;
        ActionDateCalculation."Script ID" := ScriptID;
        ActionDateCalculation.ID := CreateGuid();
        ActionDateCalculation.Insert(true);

        exit(ActionDateCalculation.ID);
    end;

    procedure DeleteDateCalculation(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionDateCalculation: Record "Action Date Calculation";
    begin
        if IsNullGuid(ID) then
            Exit;

        ActionDateCalculation.GET(CaseID, ScriptID, ID);
        ActionDateCalculation.Delete(true);
    end;

    /// Date To DateTime

    procedure CreateDateToDateTime(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionDateToDateTime: Record "Action Date To DateTime";
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed(CaseID);
        ActionDateToDateTime.Init();
        ActionDateToDateTime."Case ID" := CaseID;
        ActionDateToDateTime."Script ID" := ScriptID;
        ActionDateToDateTime.ID := CreateGuid();
        ActionDateToDateTime.Insert(true);

        exit(ActionDateToDateTime.ID);
    end;

    procedure DeleteDateToDateTime(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionDateToDateTime: Record "Action Date To DateTime";
    begin
        if IsNullGuid(ID) then
            Exit;

        ActionDateToDateTime.GET(CaseID, ScriptID, ID);
        ActionDateToDateTime.Delete(true);
    end;

    /// Alert Message
    procedure CreateAlertMessage(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionMessage: Record "Action Message";
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed(CaseID);
        ActionMessage.Init();
        ActionMessage."Case ID" := CaseID;
        ActionMessage."Script ID" := ScriptID;
        ActionMessage.ID := CreateGuid();
        ActionMessage.Insert(true);

        exit(ActionMessage.ID);
    end;

    procedure DeleteAlertMessage(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionMessage: Record "Action Message";
    begin
        if IsNullGuid(ID) then
            Exit;

        ActionMessage.GET(CaseID, ScriptID, ID);
        ActionMessage.Delete(true);
    end;

    /// Loop Through Records

    procedure CreateLoopThroughRecords(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionLoopThroughRecords: Record "Action Loop Through Records";
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed(CaseID);
        ActionLoopThroughRecords.Init();
        ActionLoopThroughRecords."Case ID" := CaseID;
        ActionLoopThroughRecords."Script ID" := ScriptID;
        ActionLoopThroughRecords.ID := CreateGuid();
        ActionLoopThroughRecords.Insert(true);

        exit(ActionLoopThroughRecords.ID);
    end;

    procedure DeleteLoopThroughRecords(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionLoopThroughRecords: Record "Action Loop Through Records";
    begin
        if IsNullGuid(ID) then
            Exit;

        ActionLoopThroughRecords.GET(CaseID, ScriptID, ID);
        ActionLoopThroughRecords.Delete(true);
    end;

    /// Extract Date Part

    procedure CreateExtractDatePart(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionExtractDatePart: Record "Action Extract Date Part";
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed(CaseID);
        ActionExtractDatePart.Init();
        ActionExtractDatePart."Case ID" := CaseID;
        ActionExtractDatePart."Script ID" := ScriptID;
        ActionExtractDatePart.ID := CreateGuid();
        ActionExtractDatePart.Insert(true);

        exit(ActionExtractDatePart.ID);
    end;

    procedure DeleteExtractDatePart(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionExtractDatePart: Record "Action Extract Date Part";
    begin
        if IsNullGuid(ID) then
            Exit;

        ActionExtractDatePart.GET(CaseID, ScriptID, ID);
        ActionExtractDatePart.Delete(true);
    end;

    /// Extract Date Time Part

    procedure CreateExtractDateTimePart(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionExtractDateTimePart: Record "Action Extract DateTime Part";
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed(CaseID);
        ActionExtractDateTimePart.Init();
        ActionExtractDateTimePart."Case ID" := CaseID;
        ActionExtractDateTimePart."Script ID" := ScriptID;
        ActionExtractDateTimePart.ID := CreateGuid();
        ActionExtractDateTimePart.Insert(true);

        exit(ActionExtractDateTimePart.ID);
    end;

    procedure DeleteExtractDateTimePart(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionExtractDateTimePart: Record "Action Extract DateTime Part";
    begin
        if IsNullGuid(ID) then
            Exit;

        ActionExtractDateTimePart.GET(CaseID, ScriptID, ID);
        ActionExtractDateTimePart.Delete(true);
    end;

    /// Length of String
    procedure CreateLengthOfString(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionLengthOfString: Record "Action Length Of String";
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed(CaseID);
        ActionLengthOfString.Init();
        ActionLengthOfString."Case ID" := CaseID;
        ActionLengthOfString."Script ID" := ScriptID;
        ActionLengthOfString.ID := CreateGuid();
        ActionLengthOfString.Insert(true);

        exit(ActionLengthOfString.ID);
    end;

    procedure DeleteLengthOfString(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionLengthOfString: Record "Action Length Of String";
    begin
        if IsNullGuid(ID) then
            Exit;

        ActionLengthOfString.GET(CaseID, ScriptID, ID);
        ActionLengthOfString.Delete(true);
    end;

    /// Convert case of String
    procedure CreateConvertCaseOfString(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionConvertCase: Record "Action Convert Case";
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed(CaseID);
        ActionConvertCase.Init();
        ActionConvertCase."Case ID" := CaseID;
        ActionConvertCase."Script ID" := ScriptID;
        ActionConvertCase.ID := CreateGuid();
        ActionConvertCase.Insert(true);

        exit(ActionConvertCase.ID);
    end;

    procedure DeleteConvertCaseOfString(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionConvertCase: Record "Action Convert Case";
    begin
        if IsNullGuid(ID) then
            Exit;

        ActionConvertCase.GET(CaseID, ScriptID, ID);
        ActionConvertCase.Delete(true);
    end;

    /// Round Number
    procedure CreateRoundNumber(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionRoundNumber: Record "Action Round Number";
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed(CaseID);
        ActionRoundNumber.Init();
        ActionRoundNumber."Case ID" := CaseID;
        ActionRoundNumber."Script ID" := ScriptID;
        ActionRoundNumber.ID := CreateGuid();
        ActionRoundNumber.Insert(true);

        exit(ActionRoundNumber.ID);
    end;

    procedure DeleteRoundNumber(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionRoundNumber: Record "Action Round Number";
    begin
        if IsNullGuid(ID) then
            Exit;

        ActionRoundNumber.GET(CaseID, ScriptID, ID);
        ActionRoundNumber.Delete(true);
    end;

    /// Numeric Expression
    procedure CreateNumericExpression(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionNumberExpression: Record "Action Number Expression";
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed(CaseID);
        ActionNumberExpression.Init();
        ActionNumberExpression."Case ID" := CaseID;
        ActionNumberExpression."Script ID" := CaseID;
        ActionNumberExpression.ID := CreateGuid();
        ActionNumberExpression."Script ID" := ScriptID;
        ActionNumberExpression.Insert(true);

        exit(ActionNumberExpression.ID);
    end;

    procedure DeleteNumericExpression(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionNumberExpression: Record "Action Number Expression";
    begin
        if IsNullGuid(ID) then
            Exit;

        ActionNumberExpression.GET(CaseID, ScriptID, ID);
        ActionNumberExpression.Delete(true);
    end;

    /// String Expression
    procedure CreateStringExpression(CaseID: Guid; ScriptID: Guid): Guid;
    var
        ActionStringExpression: Record "Action String Expression";
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed(CaseID);
        ActionStringExpression.Init();
        ActionStringExpression."Case ID" := CaseID;
        ActionStringExpression."Script ID" := ScriptID;
        ActionStringExpression.ID := CreateGuid();
        ActionStringExpression.Insert(true);

        exit(ActionStringExpression.ID);
    end;

    procedure DeleteStringExpression(CaseID: Guid; ScriptID: Guid; ID: Guid);
    var
        ActionStringExpression: Record "Action String Expression";
    begin
        if IsNullGuid(ID) then
            Exit;

        ActionStringExpression.GET(CaseID, ScriptID, ID);
        ActionStringExpression.Delete(true);
    end;

    var
        ScriptActionHelper: Codeunit "Script Action Helper";
        EmptyGuid: Guid;
}