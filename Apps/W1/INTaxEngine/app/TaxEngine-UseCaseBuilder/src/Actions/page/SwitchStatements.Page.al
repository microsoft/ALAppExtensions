page 20283 "Switch Statements"
{
    PageType = List;
    SourceTable = "Switch Case";
    RefreshOnActivate = true;
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Case Condition"; ConditionText)
                {
                    Caption = 'Case';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the case to qualify a switch statement.';
                    Editable = false;
                    trigger OnAssistEdit();
                    begin
                        CreateRecord();
                        if IsNullGuid("Condition ID") then
                            "Condition ID" := ScriptEntityMgmt.CreateCondition("Case ID", EmptyGuid);
                        Commit();

                        ConditionMgmt.OpenConditionsDialog("Case ID", EmptyGuid, "Condition ID");
                        FormatLine();
                    end;
                }
                field(Sequence; Sequence)
                {
                    Caption = 'Sequence';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the sequence of case validation.';
                }
                field(Mapping; ActivityTextValue)
                {
                    Caption = 'Statement';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the statement of the switch statement';
                    Editable = false;
                    trigger OnAssistEdit();
                    begin
                        CreateRecord();

                        Case ValueType of
                            "Action Type"::Relation:
                                OpenTableRelationDialog();
                            "Action Type"::Lookup:
                                OpenLookupDialog();
                            else
                                OnMappingAssitEdit(Rec);
                        end;

                        FormatLine();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        FormatLine();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        FormatLine();
    end;

    local procedure FormatLine()
    begin
        if not IsNullGuid("Condition ID") then
            ConditionText := ScriptSerialization.ConditionToString("Case ID", EmptyGuid, "Condition ID")
        else
            ConditionText := AlwaysLbl;

        if not IsNullGuid("Action ID") then
            case ValueType of
                "Action Type"::Relation:
                    ActivityTextValue := UseCaseSerialization.TableRelationToString("Case ID", "Action ID");
                "Action Type"::Lookup:
                    ActivityTextValue := LookupSerialization.LookupToString("Case ID", EmptyGuid, "Action ID");
                else
                    OnSwitchCaseFormat(Rec, ActivityTextValue);
            end
        else
            ActivityTextValue := BlankLbl;
    end;

    procedure SetCurrentRecord(var SwitchStatement2: Record "Switch Statement"; SwitchCaseActionType: Enum "Switch Case Action Type");
    begin
        SwitchStatement := SwitchStatement2;
        TestRecord();

        FilterGroup := 2;
        SetRange("Case ID", SwitchStatement."Case ID");
        SetRange("Switch Statement ID", SwitchStatement.ID);
        SetRange("Action Type", SwitchCaseActionType);
        FilterGroup := 0;
        SetType(SwitchCaseActionType);
    end;

    local procedure TestRecord();
    begin
        SwitchStatement.TestField("Case ID");
        SwitchStatement.TestField(ID);
    end;

    procedure SetType(NewType: Enum "Switch Case Action Type")
    begin
        ValueType := NewType;
    end;

    trigger OnInsertRecord(Belowxrec: Boolean): Boolean
    begin
        "Action Type" := ValueType;
        "Case ID" := GetFilter("Case ID");
        if IsNullGuid(ID) then
            ID := CreateGuid();
    end;

    local procedure CreateRecord()
    begin
        if IsNullGuid(ID) then begin
            "Case ID" := SwitchStatement."Case ID";
            id := CreateGuid();
            "Action Type" := ValueType;
            "Switch Statement ID" := SwitchStatement.ID;
            Insert(true);
        end;
    end;

    local procedure OpenTableRelationDialog()
    begin
        if IsNullGuid("Action ID") then begin
            "Action ID" := UseCaseEntityMgmt.CreateTableRelation("Case ID");
            Commit();
        end;

        UseCaseMgmt.OpenTableRelationDialog("Case ID", "Action ID");
    end;

    local procedure OpenLookupDialog()
    begin
        if IsNullGuid("Action ID") then begin
            "Action ID" := LookupEntityMgmt.CreateLookup("Case ID", EmptyGuid);
            Commit();
        end;

        LookupMgmt.OpenLookupDialog("Case ID", EmptyGuid, "Action ID");
    end;

    [IntegrationEvent(true, false)]
    procedure OnMappingAssitEdit(var SwitchCase: Record "Switch Case");
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnSwitchCaseFormat(SwitchCase: Record "Switch Case"; var LookupValue: Text);
    begin
    end;

    var
        SwitchStatement: Record "Switch Statement";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        ConditionMgmt: Codeunit "Condition Mgmt.";
        ScriptSerialization: Codeunit "Script Serialization";
        LookupSerialization: Codeunit "Lookup Serialization";
        UseCaseSerialization: Codeunit "Use Case Serialization";
        UseCaseEntityMgmt: Codeunit "Use Case Entity Mgmt.";
        LookupEntityMgmt: Codeunit "Lookup Entity Mgmt.";
        UseCaseMgmt: Codeunit "Use Case Mgmt.";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        ValueType: Enum "Switch Case Action Type";
        ActivityTextValue: Text;
        ConditionText: Text;
        EmptyGuid: Guid;
        BlankLbl: Label '<Blank>';
        AlwaysLbl: Label '< Always >';
}