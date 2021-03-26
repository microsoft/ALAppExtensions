page 20198 "Script Editor"
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
                IndentationColumn = Indent;
                IndentationControls = Description;
                field("Line No."; "Line No.")
                {
                    Editable = false;
                    Width = 1;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Sequence of activities on script.';
                }
                field(Action; ActionText)
                {
                    Caption = 'Action';
                    Editable = SearchEditable;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of actiivity on Script.';
                    StyleExpr = ActionTextStyle;
                    trigger OnValidate();
                    begin
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
                    ToolTip = 'Specifies the description of activity.';
                    Editable = TextEditable;
                    ApplicationArea = Basic, Suite;
                    StyleExpr = DescriptionStyle;
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
            action("Add Else Condition")
            {
                Enabled = EnableAddElseIFAction;
                ApplicationArea = Basic, Suite;
                Image = "BOM";
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Add a else condition to an If statement.';
                trigger OnAction();
                begin
                    AddElseCondition();
                end;
            }
            group(Manage)
            {
                Caption = 'Action';
                action("Insert Action")
                {
                    ApplicationArea = Basic, Suite;
                    Image = "Insert";
                    Promoted = true;
                    PromotedIsBig = true;
                    Scope = Repeater;
                    ShortCutKey = "Ctrl+Insert";
                    ToolTip = 'Add a new line in script editor.';
                    trigger OnAction();
                    begin
                        InsertNewLine(Rec);
                    end;
                }
                action("Delete Action")
                {
                    ApplicationArea = Basic, Suite;
                    Image = "Delete";
                    ShortCutKey = "Ctrl+Delete";
                    ToolTip = 'Deletes the action from script line.';
                    trigger OnAction();
                    begin
                        DeleteLine(Rec);
                    end;
                }
            }
        }
    }

    var
        ScriptContext: Record "Script Context";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        ScriptEditorMgmt: Codeunit "Script Editor Mgmt.";
        ScriptSerialization: Codeunit "Script Serialization";
        ActionDialogMgmt: Codeunit "Action Dialog Mgmt.";
        ScriptID: Guid;
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
        DeleteConfirmTxt: Label 'Do you want to Delete ?', Locked = true;

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

    procedure UpdateEditorLines(var ScriptContext2: Record "Script Context");
    begin
        ScriptContext := ScriptContext2;
        Rec.DeleteAll();
        ScriptEditorMgmt.BuildEditorLines(ScriptContext, Rec);
        if FindFirst() then;
    end;

    local procedure GetActionName(): Text;
    var
        ScriptAction2: Record "Script Action";
    begin
        case "Action Type" of
            "Action Type"::IFSTATEMENT,
          "Action Type"::LOOPNTIMES,
          "Action Type"::LOOPWITHCONDITION,
          "Action Type"::LOOPTHROUGHRECORDS:
                exit(Format("Group Type"));
            "Action Type"::DRAFTROW:
                exit('');
            else begin
                    ScriptAction2.GET("Action Type");
                    exit(Format(ScriptAction2.Text));
                end;
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
        TempScriptEditorLine2.GET(xRec."Case ID", xRec."Script ID", xRec."Line No.");
        repeat
            TempScriptEditorLine3 := TempScriptEditorLine2;
            TempScriptEditorLine3.Insert();
            TempScriptEditorLine2.Delete();
        until TempScriptEditorLine2.Next() = 0;

        ScriptEditorLine."Case ID" := ScriptContext."Case ID";
        ScriptEditorLine."Script ID" := ScriptContext.ID;
        ScriptEditorLine."Line No." := xRec."Line No.";
        ScriptEditorLine."Action Type" := "Action Type"::DRAFTROW;
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
    begin
        if not Confirm(DeleteConfirmTxt) then
            Exit;
        LineNo := ScriptEditorLine."Line No.";
        ScriptEditorMgmt.DeleteItemFromContainer(ScriptEditorLine);
        ScriptEditorMgmt.BuildEditorLines(ScriptContext, ScriptEditorLine);

        CurrPage.ACTIVATE(true);
        GET("Case ID", "Script ID", LineNo);
    end;

    trigger OnFindRecord(Which: Text): Boolean;
    begin
        FilterGroup(4);
        if ScriptID <> GETRANGEMAX("Script ID") then begin
            ScriptID := GETRANGEMAX("Script ID");
            Reset();
            DeleteAll();
        end;
        FilterGroup(0);
        if IsEmpty() and (not IsNullGuid(ScriptID)) then begin
            ScriptContext.GET(ScriptID);
            UpdateEditorLines(ScriptContext)
        end;

        exit(Find(Which));
    end;

    trigger OnAfterGetRecord();
    begin
        FormatLine();
    end;

    trigger OnAfterGetCurrRecord();
    begin
        FormatLine();
    end;

    trigger OnOpenPage();
    begin
        ScriptEditorMgmt.InitActions();
    end;
}