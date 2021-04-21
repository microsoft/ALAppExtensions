page 20199 "Script Editor Part"
{
    DelayedInsert = true;
    Caption = 'Script Editor';
    PageType = ListPart;
    InsertAllowed = false;
    DeleteAllowed = false;
    ShowFilter = false;
    SourceTableTemporary = true;
    LinksAllowed = false;
    SourceTable = "Script Editor Line";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                IndentationColumn = "Indent";
                IndentationControls = Description, Action;
                field("Line No."; "Line No.")
                {
                    Visible = false;
                    Editable = false;
                    Width = 1;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the line no. of the script.';
                }
                field(Action; ActionText)
                {
                    Caption = 'Action';
                    Editable = SearchEditable;
                    ApplicationArea = Basic, Suite;
                    StyleExpr = ActionTextStyle;
                    ToolTip = 'Specifies the action name.';
                    trigger OnValidate();
                    begin
                        if Indent = 0 then
                            Exit;

                        if ("Action Type" = "Action Type"::DRAFTROW) and (ActionText <> '') then begin
                            Postition := GetPosition();
                            ScriptEditorMgmt.UpdateDraftRow(Rec, ActionText);
                            SETPOSITION(Postition);
                        end;
                    end;

                    trigger OnLookup(var Text: Text): Boolean;
                    var
                        ActionText2: Text;
                    begin
                        if Indent = 0 then
                            Exit;

                        if ("Action Type" = "Action Type"::DRAFTROW) then begin
                            Postition := GetPosition();
                            ScriptEditorMgmt.UpdateDraftRow(Rec, ActionText2);
                            SETPOSITION(Postition);
                        end;
                    end;
                }
                field(Description; DescriptionText)
                {
                    Caption = 'Description';
                    Editable = TextEditable;
                    ApplicationArea = Basic, Suite;
                    StyleExpr = DescriptionStyle;
                    ToolTip = 'Specifies the description of the action.';
                    trigger OnValidate();
                    begin
                        if "Action Type" = "Action Type"::COMMENT then
                            ScriptEntityMgmt.UpdateComment("Case ID", "Script ID", "Action ID", DescriptionText);
                    end;

                    trigger OnAssistEdit();
                    begin
                        ActionDialogMgmt.OpenActionAssistEdit("Case ID", "Script ID", "Action Type", "Action ID", "Group Type");
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Action27)
            {
                Enabled = EnableAddElseIFAction;
                ApplicationArea = Basic, Suite;
                Image = "BOM";
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Add a else condition in the script.';
                trigger OnAction();
                begin
                    AddElseCondition();
                end;
            }
            group(ActionGroup8)
            {
                action(Action7)
                {
                    ApplicationArea = Basic, Suite;
                    Image = "Insert";
                    Promoted = true;
                    PromotedIsBig = true;
                    Scope = Repeater;
                    ShortCutKey = "Ctrl+Insert";
                    ToolTip = 'Insert a new action in the script';
                    trigger OnAction();
                    begin
                        InsertNewLine(Rec);
                    end;
                }
                action(Action9)
                {
                    Image = Insert;
                    ApplicationArea = Basic, Suite;
                    Promoted = true;
                    ShortCutKey = "Ctrl+N";
                    ToolTip = 'Insert a new action to script.';
                    trigger OnAction();
                    begin
                        InsertNewLine(Rec);
                    end;
                }
                action(Action10)
                {
                    ApplicationArea = Basic, Suite;
                    Image = "Delete";
                    ShortCutKey = "Ctrl+Delete";
                    ToolTip = 'Deletes a action from script.';
                    trigger OnAction();
                    begin
                        DeleteLine(Rec);
                    end;
                }
            }
        }
    }

    local procedure FormatLine(): Text;
    var
        ActionIfStatement: Record "Action If Statement";
    begin
        case "Action Type" of
            "Action Type"::IFSTATEMENT,
          "Action Type"::LOOPNTIMES,
          "Action Type"::LOOPWITHCONDITION,
          "Action Type"::LOOPTHROUGHRECORDS:
                DescriptionStyle := 'StrongAccent';
            "Action Type"::DRAFTROW:
                DescriptionStyle := 'None';
            "Action Type"::COMMENT:
                DescriptionStyle := 'AttentionAccent';
            else
                DescriptionStyle := '';
        end;

        if "Group Type" = "Group Type"::" " then
            ActionTextStyle := 'Subordinate'
        else
            ActionTextStyle := 'Favorable';

        if "Has Errors" then
            ActionTextStyle := 'Attention';

        case "Action Type" of
            "Action Type"::COMMENT:
                TextEditable := true;
            else
                TextEditable := false;
        end;

        DescriptionText := ScriptSerialization.RuleActionToText(
            "Case ID",
            "Script ID",
            "Action Type",
            "Action ID",
            "Group Type");

        ActionText := GetActionName();
        SearchEditable := "Action Type" = "Action Type"::DRAFTROW;
        EnableAddElseIFAction := false;
        if "Action Type" = "Action Type"::IFSTATEMENT then begin
            ActionIfStatement.GET("Case ID", "Script ID", "Action ID");
            EnableAddElseIFAction := IsNullGuid(ActionIfStatement."Else If Block ID");
        end;
    end;

    procedure UpdateEditorLines(ScriptID: Guid);
    begin
        Rec.DeleteAll();
        ScriptContext.Get(ScriptID);
        ScriptEditorMgmt.BuildEditorLines(ScriptContext, Rec);
        if FindFirst() then;
    end;

    local procedure GetActionName(): Text;
    begin
        case "Action Type" of

            "Action Type"::IFSTATEMENT,
          "Action Type"::LOOPNTIMES,
          "Action Type"::LOOPWITHCONDITION,
          "Action Type"::LOOPTHROUGHRECORDS:
                exit(Format("Group Type"));
            "Action Type"::DRAFTROW:
                exit('');
            else
                exit(Format("Action Type"));
        end;
    end;

    local procedure AddElseCondition();
    begin
        if "Action Type" <> "Action Type"::IFSTATEMENT then
            Exit;

        ScriptEntityMgmt.AddElseIfCondition("Case ID", "Script ID", "Action ID");
        ScriptEditorMgmt.RefreshEditorLines(Rec);
    end;

    local procedure InsertNewLine(var ScriptEditorLine: Record "Script Editor Line" Temporary);
    var
        TempScriptEditorLine2: Record "Script Editor Line" Temporary;
        TempScriptEditorLine3: Record "Script Editor Line" Temporary;
    begin
        TempScriptEditorLine2.COPY(ScriptEditorLine, true);
        TempScriptEditorLine2.GET(xRec."Script ID", xRec."Line No.");
        repeat
            TempScriptEditorLine3 := TempScriptEditorLine2;
            TempScriptEditorLine3.Insert();
            TempScriptEditorLine2.Delete();
        until TempScriptEditorLine2.Next() = 0;

        ScriptEditorLine."Script ID" := ScriptContext.ID;
        ScriptEditorLine."Line No." := xRec."Line No.";
        ScriptEditorLine."Action Type" := "Action Type"::DRAFTROW;
        //ScriptEditorLine."Action ID" := EmptyGuid; Dont have to assign blank value to Guid.
        ScriptEditorLine."Group Type" := ScriptEditorLine."Group Type"::" ";
        ScriptEditorLine.Indent := xRec.Indent;
        ScriptEditorLine."Container Type" := xRec."Container Type";
        ScriptEditorLine."Container Action ID" := xRec."Container Action ID";
        ScriptEditorLine.Insert();

        TempScriptEditorLine3.Reset();
        if TempScriptEditorLine3.FindSet() then
            repeat
                TempScriptEditorLine2 := TempScriptEditorLine3;
                TempScriptEditorLine2."Line No." += 1;
                TempScriptEditorLine2.Insert();
                TempScriptEditorLine3.Delete();
            until TempScriptEditorLine3.Next() = 0;

        Clear(TempScriptEditorLine2);
    end;

    local procedure DeleteLine(var ScriptEditorLine: Record "Script Editor Line" Temporary);
    var
        LineNo: Integer;
        LineNo2: Integer;
    begin
        LineNo := ScriptEditorLine."Line No.";
        ScriptEditorMgmt.DeleteItemFromContainer(ScriptEditorLine);
        ScriptEditorLine.Reset();
        ScriptEditorLine.DeleteAll();
        ScriptEditorMgmt.AddContainerItemsToEditorLines(Rec, ContainerActionType, ContainerActionID, LineNo2, 0);

        CurrPage.ACTIVATE(true);
        GET("Script ID", LineNo);
    end;


    trigger OnFindRecord(Which: Text): Boolean;
    var
        LineNo: Integer;
    begin
        FilterGroup(4);
        if GETFILTER("Script ID") <> '' then
            if ScriptID <> GETRANGEMAX("Script ID") then
                ScriptID := GETRANGEMAX("Script ID");

        if GETFILTER("Container Type") <> '' then
            if ContainerActionType <> GETRANGEMAX("Container Type") then
                ContainerActionType := GETRANGEMAX("Container Type");

        if GETFILTER("Container Action ID") <> '' then
            if ContainerActionID <> GETRANGEMAX("Container Action ID") then begin
                ContainerActionID := GETRANGEMAX("Container Action ID");
                Reset();
                DeleteAll();
                ScriptContext.GET(ScriptID);
                "Script ID" := ScriptID;
                ScriptEditorMgmt.SetEditorRootAction(ContainerActionType, ContainerActionID);
                ScriptEditorMgmt.AddContainerItemsToEditorLines(Rec, ContainerActionType, ContainerActionID, LineNo, 0);
            end;

        Reset();
        exit(Find(Which));
    end;

    trigger OnAfterGetRecord();
    begin
        CALCFIELDS("Has Errors");
        FormatLine();
    end;

    trigger OnAfterGetCurrRecord();
    begin
        CALCFIELDS("Has Errors");
        FormatLine();
    end;

    var
        ScriptContext: Record "Script Context";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        ScriptEditorMgmt: Codeunit "Script Editor Mgmt.";
        ScriptSerialization: Codeunit "Script Serialization";
        ActionDialogMgmt: Codeunit "Action Dialog Mgmt.";
        ScriptID: Guid;
        ContainerActionID: Guid;
        ContainerActionType: Enum "Container Action Type";
        DescriptionStyle: Text;
        TextEditable: Boolean;
        [InDataSet]
        SearchEditable: Boolean;
        DescriptionText: Text;
        ActionText: Text;
        [InDataSet]
        EnableAddElseIFAction: Boolean;
        ActionTextStyle: Text;
        Postition: Text;
}