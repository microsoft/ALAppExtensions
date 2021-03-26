codeunit 20165 "Script Editor Mgmt."
{
    var
        ScriptAction: Record "Script Action";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        RootContainerActionType: Enum "Container Action Type";
        RootActionID: Guid;
        EmptyGuid: Guid;
        ActionsLoaded: Boolean;

    procedure InitActions();
    begin
        if ActionsLoaded then
            exit;
        InsertAction("Action Type"::COMMENT, 'Comment', DATABASE::"Action Comment", 1);
        InsertAction("Action Type"::NUMBERCALCULATION, 'Number Calculation', DATABASE::"Action Number Calculation", 1);
        InsertAction("Action Type"::IFSTATEMENT, 'if Statement', DATABASE::"Action If Statement", 1);
        InsertAction("Action Type"::LOOPNTIMES, 'Loop n Times', DATABASE::"Action Loop N Times", 1);
        InsertAction("Action Type"::LOOPWITHCONDITION, 'Loop With Condition', DATABASE::"Action Loop With Condition", 1);
        InsertAction("Action Type"::FINDINTERVALBETWEENDATES, 'Find Interval Between Dates', DATABASE::"Action Find Date Interval", 1);
        InsertAction("Action Type"::SETVARIABLE, 'Set Variable', DATABASE::"Action Set Variable", 1);
        InsertAction("Action Type"::CONCATENATE, 'Concatenate', DATABASE::"Action Concatenate", 1);
        InsertAction("Action Type"::FINDSUBSTRINGINSTRING, 'Find Substring In String', DATABASE::"Action Find Substring", 1);
        InsertAction("Action Type"::REPLACESUBSTRINGINSTRING, 'Replace Substring', DATABASE::"Action Replace Substring", 1);
        InsertAction("Action Type"::EXTRACTSUBSTRINGFROMINDEXOFSTRING, 'Extract Substring From Index', DATABASE::"Action Ext. Substr. From Index", 1);
        InsertAction("Action Type"::EXTRACTSUBSTRINGFROMPOSITION, 'Extract Substring From Position', DATABASE::"Action Ext. Substr. From Pos.", 1);
        InsertAction("Action Type"::DATECALCULATION, 'Date Calculation', DATABASE::"Action Date Calculation", 1);
        InsertAction("Action Type"::DATETODATETIME, 'Date To DateTime', DATABASE::"Action Date To DateTime", 1);
        InsertAction("Action Type"::ALERTMESSAGE, 'Message', DATABASE::"Action Message", 1);
        InsertAction("Action Type"::LOOPTHROUGHRECORDS, 'Loop Through Records', DATABASE::"Action Loop Through Records", 1);
        InsertAction("Action Type"::EXTRACTDATEPART, 'Extract Date Part', DATABASE::"Action Extract Date Part", 1);
        InsertAction("Action Type"::EXTRACTDATETIMEPART, 'Extract Date Time Part', DATABASE::"Action Extract DateTime Part", 1);
        InsertAction("Action Type"::LENGTHOFSTRING, 'Length Of String', DATABASE::"Action Length Of String", 1);
        InsertAction("Action Type"::CONVERTCASEOFSTRING, 'Convert Case', DATABASE::"Action Convert Case", 1);
        InsertAction("Action Type"::ROUNDNUMBER, 'Round Number', DATABASE::"Action Round Number", 1);
        InsertAction("Action Type"::NUMERICEXPRESSION, 'Numeric Expression', DATABASE::"Action Number Expression", 1);
        InsertAction("Action Type"::STRINGEXPRESSION, 'String Expression', DATABASE::"Action String Expression", 1);
        InsertAction("Action Type"::EXITLOOP, 'Exit Loop', 0, 0);
        InsertAction("Action Type"::CONTINUE, 'Skip Next Activities', 0, 0);
        ActionsLoaded := true;
    end;

    procedure BuildEditorLines(
        var ScriptContext: Record "Script Context";
        var ScriptEditorLine: Record "Script Editor Line" Temporary);
    var
        NextLineNo: Integer;
    begin
        ScriptEditorLine.SetRange("Case ID", ScriptContext."Case ID");
        ScriptEditorLine.SetRange("Script ID", ScriptContext.ID);
        ScriptEditorLine.DeleteAll();
        ScriptEditorLine."Case ID" := ScriptContext."Case ID";
        ScriptEditorLine."Script ID" := ScriptContext.ID;

        NextLineNo := 1;
        AddContainerItemsToEditorLines(ScriptEditorLine, "Container Action Type"::USECASE, ScriptContext."Case ID", NextLineNo, 0);

        InsertEditorLine(
            ScriptEditorLine,
            ScriptContext."Case ID",
            ScriptContext.ID,
            "Action Type"::DRAFTROW,
            EmptyGuid,
            "Container Action Type"::USECASE,
            ScriptContext."Case ID",
            NextLineNo,
            0);
    end;

    procedure SearchActionType(var Text: Text; var ActionType: Enum "Action Type"): Boolean;
    begin
        if StrLen(Text) > 5 then begin
            ScriptAction.Reset();
            ScriptAction.SetFilter(Text, '@' + Text + '*');
            if (ScriptAction.FindFirst()) and (ScriptAction.Count() = 1) then begin
                Text := ScriptAction.Text;
                ActionType := ScriptAction.ID;
                exit(true);
            end;
        end;

        ScriptAction.Reset();
        if Page.RunModal(Page::"Script Actions", ScriptAction) = ACTION::LookupOK then begin
            Text := ScriptAction.Text;
            ActionType := ScriptAction.ID;
            exit(true);
        end;

        exit(false);
    end;

    procedure UpdateDraftRow(
        var ScriptEditorLine: Record "Script Editor Line" Temporary;
        var ActionText: Text): Text;
    var
        ScriptContext: Record "Script Context";
        ActionType2: Enum "Action Type";
        LineNo: Integer;
        ActionID: Guid;
    begin

        if not SearchActionType(ActionText, ActionType2) then begin
            ActionText := '';
            Exit;
        end;

        ScriptEditorLine."Action Type" := ActionType2;
        ScriptEditorLine."Action ID" := ScriptEntityMgmt.CreateContainerItem(
            ScriptEditorLine."Case ID",
            ScriptEditorLine."Script ID",
            ActionType2);
        ActionID := ScriptEditorLine."Action ID";
        AddItemToContainer(ScriptEditorLine);

        ScriptContext.GET(ScriptEditorLine."Script ID");
        if IsNullGuid(RootActionID) then
            BuildEditorLines(ScriptContext, ScriptEditorLine)
        else begin
            ScriptEditorLine.Reset();
            ScriptEditorLine.DeleteAll();
            AddContainerItemsToEditorLines(ScriptEditorLine, RootContainerActionType, RootActionID, LineNo, 0);
        end;

        ScriptEditorLine.SetRange("Script ID", ScriptContext.ID);
        ScriptEditorLine.SetRange("Action ID", ActionID);
        ScriptEditorLine.FindFirst();
        ScriptEditorLine.SetRange("Action ID");

        exit(ScriptEditorLine.GetPosition());
    end;

    local procedure AddItemToContainer(var ScriptEditorLine: Record "Script Editor Line" Temporary);
    var
        TempScriptEditorLine2: Record "Script Editor Line" Temporary;
        ActionContainer: Record "Action Container";
        TempActionContainer: Record "Action Container" Temporary;
        NextLineNo: Integer;
    begin
        TempScriptEditorLine2 := ScriptEditorLine;

        if ScriptEditorLine.Next(-1) <> 0 then begin
            ActionContainer.Reset();
            ActionContainer.SetRange("Case ID", ScriptEditorLine."Case ID");
            ActionContainer.SetRange("Script ID", ScriptEditorLine."Script ID");
            ActionContainer.SetRange("Container Type", ScriptEditorLine."Container Type");
            ActionContainer.SetRange("Container Action ID", ScriptEditorLine."Container Action ID");
            ActionContainer.SetRange("Action Type", ScriptEditorLine."Action Type");
            ActionContainer.SetRange("Action ID", ScriptEditorLine."Action ID");
            if ActionContainer.FindFirst() then
                NextLineNo := ActionContainer."Line No.";
        end;

        ScriptEditorLine := TempScriptEditorLine2;

        // Transfer to Temp Table
        ActionContainer.Reset();
        ActionContainer.SetRange("Case ID", ScriptEditorLine."Case ID");
        ActionContainer.SetRange("Script ID", ScriptEditorLine."Script ID");
        ActionContainer.SetRange("Container Type", ScriptEditorLine."Container Type");
        ActionContainer.SetRange("Container Action ID", ScriptEditorLine."Container Action ID");
        ActionContainer.SetFilter("Line No.", '>%1', NextLineNo);
        if ActionContainer.FindSet() then
            repeat
                TempActionContainer := ActionContainer;
                TempActionContainer.Insert();
                ActionContainer.Delete();
            until ActionContainer.Next() = 0;

        NextLineNo := NextLineNo + 10000;

        ActionContainer.Init();
        ActionContainer."Case ID" := ScriptEditorLine."Case ID";
        ActionContainer."Script ID" := ScriptEditorLine."Script ID";
        ActionContainer."Container Type" := ScriptEditorLine."Container Type";
        ActionContainer."Container Action ID" := ScriptEditorLine."Container Action ID";
        ActionContainer."Line No." := NextLineNo;
        ActionContainer."Action Type" := ScriptEditorLine."Action Type";
        ActionContainer."Action ID" := ScriptEditorLine."Action ID";
        ActionContainer.Insert();

        NextLineNo += 10000;

        // Transfer from Temp to Actual
        TempActionContainer.Reset();
        if TempActionContainer.FindSet() then
            repeat
                ActionContainer := TempActionContainer;
                ActionContainer."Line No." := NextLineNo;
                ActionContainer.Insert();
                NextLineNo += 10000;
            until TempActionContainer.Next() = 0;
    end;

    procedure DeleteItemFromContainer(var ScriptEditorLine: Record "Script Editor Line" Temporary);
    var
        ActionContainer: Record "Action Container";
    begin
        ActionContainer.Reset();
        ActionContainer.SetRange("Case ID", ScriptEditorLine."Case ID");
        ActionContainer.SetRange("Script ID", ScriptEditorLine."Script ID");
        ActionContainer.SetRange("Action Type", ScriptEditorLine."Action Type");
        ActionContainer.SetRange("Action ID", ScriptEditorLine."Action ID");
        if ActionContainer.FindFirst() then
            ActionContainer.Delete(true);
    end;

    procedure AddContainerItemsToEditorLines(
        var ScriptEditorLine: Record "Script Editor Line" Temporary;
        ContainerType: Enum "Container Action Type";
        ContainerActionID: Guid;
        var LineNo: Integer;
        Indent: Integer);
    var
        ActionContainer: Record "Action Container";
    begin
        ActionContainer.Reset();
        ActionContainer.SetRange("Case ID", ScriptEditorLine."Case ID");
        ActionContainer.SetRange("Script ID", ScriptEditorLine."Script ID");
        ActionContainer.SetRange("Container Type", ContainerType);
        ActionContainer.SetRange("Container Action ID", ContainerActionID);
        if ActionContainer.FindSet() then
            repeat
                case ActionContainer."Action Type" of
                    "Action Type"::IFSTATEMENT:
                        AddIfConditionToEditorLines(
                            ScriptEditorLine,
                            ActionContainer."Case ID",
                            ActionContainer."Script ID",
                            ActionContainer."Action ID",
                            ContainerType,
                            ContainerActionID,
                            LineNo,
                            Indent);

                    "Action Type"::LOOPNTIMES:
                        AddLoopNTimesToEditorLines(
                            ScriptEditorLine,
                            ActionContainer."Case ID",
                            ActionContainer."Script ID",
                            ActionContainer."Action ID",
                            ContainerType,
                            ContainerActionID,
                            LineNo,
                            Indent);
                    "Action Type"::LOOPWITHCONDITION:
                        AddLoopWithConditionToEditorLines(
                            ScriptEditorLine,
                            ActionContainer."Case ID",
                            ActionContainer."Script ID",
                            ActionContainer."Action ID",
                            ContainerType,
                            ContainerActionID,
                            LineNo,
                            Indent);
                    "Action Type"::LOOPTHROUGHRECORDS:
                        AddLoopThroughRecordsToEditorLines(
                            ScriptEditorLine,
                            ActionContainer."Case ID",
                            ActionContainer."Script ID",
                            ActionContainer."Action ID",
                            ContainerType,
                            ContainerActionID,
                            LineNo,
                            Indent);
                    else
                        InsertEditorLine(
                            ScriptEditorLine,
                            ActionContainer."Case ID",
                            ActionContainer."Script ID",
                            ActionContainer."Action Type",
                            ActionContainer."Action ID",
                            ActionContainer."Container Type",
                            ActionContainer."Container Action ID",
                            LineNo,
                            Indent);
                end;
            until ActionContainer.Next() = 0;

    end;

    /// Lookup Functions
    procedure RefreshEditorLines(var ScriptEditorLine: Record "Script Editor Line" Temporary);
    var
        ScriptContext: Record "Script Context";
        TempScriptEditorLineLatest: Record "Script Editor Line" Temporary;
    begin
        ScriptContext.GET(ScriptEditorLine."Script ID");
        BuildEditorLines(ScriptContext, TempScriptEditorLineLatest);
        ScriptEditorLine.Reset();
        ScriptEditorLine.DeleteAll();
        ScriptEditorLine.COPY(TempScriptEditorLineLatest, true);
    end;

    procedure SetEditorRootAction(ActionType: Enum "Container Action Type"; ActionID: Guid);
    begin
        RootActionID := ActionID;
        RootContainerActionType := ActionType;
    end;

    local procedure AddIfConditionToEditorLines(
    var ScriptEditorLine: Record "Script Editor Line" Temporary;
    CaseID: Guid;
    ScriptID: Guid;
    ActionID: Guid;
    ContainerType: Enum "Container Action Type";
    ContainerActionID: Guid;
    var LineNo: Integer;
    Indent: Integer);
    var
        ActionIfStatement: Record "Action If Statement";
        GroupType: Enum "Action Group Type";
    begin
        ActionIfStatement.GET(CaseID, ScriptID, ActionID);
        if IsNullGuid(ActionIfStatement."Parent If Block ID") then
            GroupType := ScriptEditorLine."Group Type"::"if Statement"
        else
            if not IsNullGuid(ActionIfStatement."Else If Block ID") then
                GroupType := ScriptEditorLine."Group Type"::"Else if Statement"
            else
                GroupType := ScriptEditorLine."Group Type"::"Else Statement";

        InsertGroupEditorLine(
            ScriptEditorLine,
            ActionIfStatement."Case ID",
            ActionIfStatement."Script ID",
            GroupType,
            "Action Type"::IFSTATEMENT,
            ActionIfStatement.ID,
            ContainerType,
            ContainerActionID,
            LineNo,
            Indent);

        if IsNullGuid(RootActionID) then begin
            Indent += 1;
            AddContainerItemsToEditorLines(ScriptEditorLine, "Container Action Type"::IFSTATEMENT, ActionIfStatement.ID, LineNo, Indent);

            InsertEditorLine(
                ScriptEditorLine,
                ActionIfStatement."Case ID",
                ActionIfStatement."Script ID",
                "Action Type"::DRAFTROW,
                EmptyGuid,
                "Container Action Type"::IFSTATEMENT,
                ActionIfStatement.ID,
                LineNo,
                Indent);
            Indent -= 1;

            if IsNullGuid(ActionIfStatement."Else If Block ID") then
                InsertGroupEditorLine(
                    ScriptEditorLine,
                    ActionIfStatement."Case ID",
                    ActionIfStatement."Script ID",
                    ScriptEditorLine."Group Type"::"End if Statement",
                    "Action Type"::IFSTATEMENT,
                    ActionIfStatement.ID,
                    ContainerType,
                    ContainerActionID,
                    LineNo,
                    Indent);
        end;

    end;

    local procedure AddLoopNTimesToEditorLines(
        var ScriptEditorLine: Record "Script Editor Line" Temporary;
        CaseID: Guid;
        ScriptID: Guid;
        ActionID: Guid;
        ContainerType: Enum "Container Action Type";
        ContainerActionID: Guid;
        var LineNo: Integer;
        Indent: Integer);
    var
        ActionLoopNTimes: Record "Action Loop N Times";
    begin
        ActionLoopNTimes.GET(CaseID, ScriptID, ActionID);
        InsertGroupEditorLine(
            ScriptEditorLine,
            ActionLoopNTimes."Case ID",
            ActionLoopNTimes."Script ID",
            ScriptEditorLine."Group Type"::"Loop N Times",
            "Action Type"::LOOPNTIMES,
            ActionLoopNTimes.ID,
            ContainerType,
            ContainerActionID,
            LineNo,
            Indent);

        if IsNullGuid(RootActionID) then begin
            Indent += 1;
            AddContainerItemsToEditorLines(ScriptEditorLine, "Container Action Type"::LOOPNTIMES, ActionLoopNTimes.ID, LineNo, Indent);
            InsertEditorLine(
                ScriptEditorLine,
                ActionLoopNTimes."Case ID",
                ActionLoopNTimes."Script ID",
                "Action Type"::DRAFTROW,
                EmptyGuid,
                "Container Action Type"::LOOPNTIMES,
                ActionLoopNTimes.ID,
                LineNo,
                Indent);
            Indent -= 1;
            InsertGroupEditorLine(
                ScriptEditorLine,
                ActionLoopNTimes."Case ID",
                ActionLoopNTimes."Script ID",
                ScriptEditorLine."Group Type"::"End Loop N Times",
                "Action Type"::LOOPNTIMES,
                ActionLoopNTimes.ID,
                ContainerType,
                ContainerActionID,
                LineNo,
                Indent);
        end;

    end;

    local procedure AddLoopWithConditionToEditorLines(
        var ScriptEditorLine: Record "Script Editor Line" Temporary;
        CaseID: Guid;
        ScriptID: Guid;
        ActionID: Guid;
        ContainerType: Enum "Container Action Type";
        ContainerActionID: Guid;
        var LineNo: Integer;
        Indent: Integer);
    var
        ActionLoopWithCondition: Record "Action Loop With Condition";
    begin
        ActionLoopWithCondition.GET(CaseID, ScriptID, ActionID);
        InsertGroupEditorLine(
            ScriptEditorLine,
            ActionLoopWithCondition."Case ID",
            ActionLoopWithCondition."Script ID",
            ScriptEditorLine."Group Type"::"Loop with Condition",
            "Action Type"::LOOPWITHCONDITION,
            ActionLoopWithCondition.ID,
            ContainerType,
            ContainerActionID,
            LineNo,
            Indent);

        if IsNullGuid(RootActionID) then begin
            Indent += 1;
            AddContainerItemsToEditorLines(ScriptEditorLine, "Container Action Type"::LOOPWITHCONDITION, ActionLoopWithCondition.ID, LineNo, Indent);
            InsertEditorLine(
                ScriptEditorLine,
                ActionLoopWithCondition."Case ID",
                ActionLoopWithCondition."Script ID",
                "Action Type"::DRAFTROW,
                EmptyGuid,
                "Container Action Type"::LOOPWITHCONDITION,
                ActionLoopWithCondition.ID,
                LineNo,
                Indent);
            Indent -= 1;
            InsertGroupEditorLine(
                ScriptEditorLine,
                ActionLoopWithCondition."Case ID",
                ActionLoopWithCondition."Script ID",
                ScriptEditorLine."Group Type"::"End Loop with Condition",
                "Action Type"::LOOPWITHCONDITION,
                ActionLoopWithCondition.ID,
                ContainerType,
                ContainerActionID,
                LineNo,
                Indent);
        end;

    end;

    local procedure AddLoopThroughRecordsToEditorLines(
        var ScriptEditorLine: Record "Script Editor Line" Temporary;
        CaseID: Guid;
        ScriptID: Guid;
        ActionID: Guid;
        ContainerType: Enum "Container Action Type";
        ContainerActionID: Guid;
        var LineNo: Integer;
        Indent: Integer);
    var
        ActionLoopThroughRecords: Record "Action Loop Through Records";
    begin
        ActionLoopThroughRecords.GET(CaseID, ScriptID, ActionID);
        InsertGroupEditorLine(
            ScriptEditorLine,
            ActionLoopThroughRecords."Case ID",
            ActionLoopThroughRecords."Script ID",
            ScriptEditorLine."Group Type"::"Loop Through Records",
            "Action Type"::LOOPTHROUGHRECORDS, ActionLoopThroughRecords.ID,
            ContainerType, ContainerActionID, LineNo, Indent);

        if IsNullGuid(RootActionID) then begin
            Indent += 1;
            AddContainerItemsToEditorLines(ScriptEditorLine, "Container Action Type"::LOOPTHROUGHRECORDS, ActionLoopThroughRecords.ID, LineNo, Indent);
            InsertEditorLine(
                ScriptEditorLine,
                ActionLoopThroughRecords."Case ID",
                ActionLoopThroughRecords."Script ID",
                "Action Type"::DRAFTROW,
                EmptyGuid,
                "Container Action Type"::LOOPTHROUGHRECORDS,
                ActionLoopThroughRecords.ID,
                LineNo,
                Indent);

            Indent -= 1;
            InsertGroupEditorLine(
                ScriptEditorLine,
                ActionLoopThroughRecords."Case ID",
                ActionLoopThroughRecords."Script ID",
                ScriptEditorLine."Group Type"::"End Loop Through Records",
                "Action Type"::LOOPTHROUGHRECORDS,
                ActionLoopThroughRecords.ID,
                ContainerType,
                ContainerActionID,
                LineNo,
                Indent);
        end;
    end;

    local procedure InsertEditorLine(
        var ScriptEditorLine: Record "Script Editor Line" Temporary;
        CaseID: Guid;
        ScriptID: Guid;
        ActionType: Enum "Action Type";
        ActionID: Guid;
        ContainerType: Enum "Container Action Type";
        ContainerActionID: Guid;
        var LineNo: Integer;
        Indent2: Integer);
    begin
        ScriptEditorLine.Init();
        ScriptEditorLine."Case ID" := CaseID;
        ScriptEditorLine."Script ID" := ScriptID;
        ScriptEditorLine."Line No." := LineNo;
        ScriptEditorLine.Indent := Indent2;
        ScriptEditorLine."Action Type" := ActionType;
        ScriptEditorLine."Action ID" := ActionID;
        ScriptEditorLine."Container Action ID" := ContainerActionID;
        ScriptEditorLine."Container Type" := ContainerType;
        ScriptEditorLine.Insert();
        LineNo += 1;
    end;

    local procedure InsertGroupEditorLine(
        var ScriptEditorLine: Record "Script Editor Line" Temporary;
        CaseID: Guid;
        ScriptID: Guid;
        GroupType: Enum "Action Group Type";
        ActionType: Enum "Action Type";
        ActionID: Guid;
        ContainerType: Enum "Container Action Type";
        ContainerActionID: Guid;
        var LineNo: Integer;
        Indent2: Integer);
    begin
        ScriptEditorLine.Init();
        ScriptEditorLine."Case ID" := CaseID;
        ScriptEditorLine."Script ID" := ScriptID;
        ScriptEditorLine."Line No." := LineNo;
        ScriptEditorLine.Indent := Indent2;
        ScriptEditorLine."Group Type" := GroupType;
        ScriptEditorLine."Action Type" := ActionType;
        ScriptEditorLine."Action ID" := ActionID;
        ScriptEditorLine."Container Type" := ContainerType;
        ScriptEditorLine."Container Action ID" := ContainerActionID;
        ScriptEditorLine.Insert();
        LineNo += 1;
    end;

    local procedure InsertAction(ID: Enum "Action Type"; Command: Text[250]; TableID: Integer; RuleFieldID: Integer);
    begin
        if ScriptAction.GET(ID) then
            Exit;
        ScriptAction.Init();
        ScriptAction.ID := ID;
        ScriptAction.Text := Command;
        ScriptAction."Table ID" := TableID;
        ScriptAction."Rule ID Field No." := RuleFieldID;
        ScriptAction.Insert();

        OnAfterInsertAction(ID, TableID, RuleFieldID);
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterInsertAction(ActionID: Enum "Action Type"; TableID: Integer; FieldID: Integer);
    begin
    end;
}