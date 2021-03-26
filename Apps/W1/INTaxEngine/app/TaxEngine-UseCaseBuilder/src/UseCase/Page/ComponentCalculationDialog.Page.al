page 20306 "Component Calculation Dialog"
{
    PageType = ListPart;
    SourceTable = "Use Case Component Calculation";
    SourceTableView = sorting(Sequence);
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Name; ComponentName)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Component Name';
                    ToolTip = 'Specifies the name of component.';
                    trigger OnValidate();
                    var
                        UseCase: Record "Tax Use Case";
                    begin
                        if UseCase.Get("Case ID") then begin
                            clear(ScriptSymbolsMgmt);
                            ScriptSymbolsMgmt.SetContext(UseCase."Tax Type", "Case ID", UseCase."Computation Script ID");
                            ScriptSymbolsMgmt.SearchSymbol("Symbol Type"::Component, "Component ID", ComponentName);
                            Validate("Component ID");
                            FormatLine();
                        end;
                    end;

                    trigger OnLookup(var Text: Text): Boolean;
                    var
                        UseCase: Record "Tax Use Case";
                    begin
                        if UseCase.Get("Case ID") then begin
                            clear(ScriptSymbolsMgmt);
                            ScriptSymbolsMgmt.SetContext(UseCase."Tax Type", "Case ID", UseCase."Computation Script ID");
                            ScriptSymbolsMgmt.OpenSymbolsLookup("Symbol Type"::Component, Text, "Component ID", ComponentName);
                            Validate("Component ID");
                            FormatLine();
                        end;
                    end;
                }
                field(Sequence; Sequence)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the sequence for calculation of component.';
                }
                field(Formula; FormulaText)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Formula';
                    ToolTip = 'Specifies the calculation formula of component.';
                    ShowCaption = false;
                    Editable = false;
                    StyleExpr = true;
                    Style = Subordinate;

                    trigger OnAssistEdit()
                    begin
                        if IsNullGuid(ID) then begin
                            "Case ID" := GetFilter("Case ID");
                            ID := CreateGuid();
                            Insert();
                        end;

                        if IsNullGuid("Formula ID") then begin
                            "Formula ID" := UseCaseEntityMgmt.CreateComponentExpression(
                                "Case ID",
                                "Component ID");
                            Commit();
                        end;
                        UseCaseMgmt.OpenComponentExprDialog("Case ID", "Formula ID");
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

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ComponentName := '';
        FormulaText := '';
    end;

    local procedure FormatLine()
    var

    begin
        clear(ScriptSymbolsMgmt);
        ScriptSymbolsMgmt.SetContext("Case ID", EmptyGuid);
        if "Component ID" <> 0 then
            ComponentName := ScriptSymbolsMgmt.GetSymbolName("Symbol Type"::Component, "Component ID")
        else
            ComponentName := '';

        if not IsNullGuid("Formula ID") then
            FormulaText := UseCaseSerialization.ComponentExpressionToString("Case ID", "Formula ID")
        else
            FormulaText := 'Click here to defined Calculation formula.';
    end;

    var
        UseCaseMgmt: Codeunit "Use Case Mgmt.";
        UseCaseEntityMgmt: Codeunit "Use Case Entity Mgmt.";
        UseCaseSerialization: Codeunit "Use Case Serialization";
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        EmptyGuid: Guid;
        ComponentName: Text[30];
        FormulaText: Text;
}