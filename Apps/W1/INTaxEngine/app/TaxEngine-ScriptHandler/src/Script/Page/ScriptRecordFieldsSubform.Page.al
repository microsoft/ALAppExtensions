page 20200 "Script Record Fields Subform"
{
    PageType = ListPart;
    DeleteAllowed = false;
    AutoSplitKey = true;
    SourceTable = Field;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(FieldSelected; FieldSelected2)
                {
                    Caption = 'Selected';
                    Enabled = IsSelectionEditable;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the selected field on record.';
                    trigger OnValidate();
                    begin
                        ChangeFieldSelection(Rec);
                    end;
                }
                field(FieldName; FieldName)
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    StyleExpr = FieldStyle;
                    ToolTip = 'Specifies the field name.';
                }
                field(Type; Type)
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    StyleExpr = FieldStyle;
                    ToolTip = 'Specifies the datatype of record field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Select All")
            {
                ApplicationArea = Basic, Suite;
                Image = "AllLines";
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Select all fields from tables as part of record variable.';
                trigger OnAction();
                begin
                    SelectAll();
                end;
            }
            action("Unselect All")
            {
                ApplicationArea = Basic, Suite;
                Image = "CancelAllLines";
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'UnSelect all fields from tables as part of record variable.';
                trigger OnAction();
                begin
                    UnselectAll();
                end;
            }
        }
    }

    local procedure UpdateControls();
    var
        ScriptRecordVariable: Record "Script Record Variable";
    begin
        FieldSelected2 := ScriptRecordVariable.GET(ScriptVariable."Script ID", ScriptVariable.ID, "No.");
        IsSelectionEditable := true;
    end;

    procedure SetVariable(var Variable2: Record "Script Variable");
    begin
        ScriptVariable := Variable2;
        FilterGroup := 4;
        SetRange(TableNo, ScriptVariable."Table ID");
        FilterGroup := 0;
        CurrPage.ACTIVATE(true);
    end;

    local procedure ChangeFieldSelection(Field: Record Field);
    var
        ScriptRecordVariable: Record "Script Record Variable";
    begin
        if not FieldSelected2 then begin
            ScriptRecordVariable.GET(ScriptVariable."Script ID", ScriptVariable.ID, "No.");
            ScriptRecordVariable.Delete();
        end else begin
            ScriptRecordVariable.Init();
            ScriptRecordVariable."Script ID" := ScriptVariable."Script ID";
            ScriptRecordVariable."Variable ID" := ScriptVariable.ID;
            ScriptRecordVariable.ID := Field."No.";
            ScriptRecordVariable.Name := Field.FieldName;
            ScriptRecordVariable.Datatype := ScriptDataTypeMgmt.GetFieldDatatype(TableNo, "No.");
            ScriptRecordVariable.Insert();
        end;
    end;

    local procedure SelectAll();
    var
        ScriptRecordVariable: Record "Script Record Variable";
        Field: Record Field;
    begin
        ScriptRecordVariable.Reset();
        ScriptRecordVariable.SetRange("Script ID", ScriptVariable."Script ID");
        ScriptRecordVariable.SetRange("Variable ID", ScriptVariable.ID);
        ScriptRecordVariable.DeleteAll();

        if (ScriptVariable."Table ID" = 0) then
            Exit;

        Field.Reset();
        Field.SetRange(TableNo, ScriptVariable."Table ID");
        if Field.FindSet() then
            repeat
                ScriptRecordVariable.Init();
                ScriptRecordVariable."Script ID" := ScriptVariable."Script ID";
                ScriptRecordVariable."Variable ID" := ScriptVariable.ID;
                ScriptRecordVariable.ID := Field."No.";
                ScriptRecordVariable.Name := Field.FieldName;
                ScriptRecordVariable.Datatype := ScriptDataTypeMgmt.GetFieldDatatype(Field.TableNo, Field."No.");
                ScriptRecordVariable.Insert();
            until Field.Next() = 0;
        CurrPage.ACTIVATE(true);
    end;

    local procedure UnselectAll();
    var
        ScriptRecordVariable: Record "Script Record Variable";
    begin
        ScriptRecordVariable.Reset();
        ScriptRecordVariable.SetRange("Script ID", ScriptVariable."Script ID");
        ScriptRecordVariable.SetRange("Variable ID", ScriptVariable.ID);
        ScriptRecordVariable.DeleteAll();
        CurrPage.ACTIVATE(true);
    end;

    trigger OnAfterGetRecord();
    begin
        UpdateControls();
    end;

    trigger OnAfterGetCurrRecord();
    begin
        UpdateControls();
    end;

    var
        ScriptVariable: Record "Script Variable";
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        FieldSelected2: Boolean;
        [InDataSet]
        IsSelectionEditable: Boolean;
        FieldStyle: Text;
}