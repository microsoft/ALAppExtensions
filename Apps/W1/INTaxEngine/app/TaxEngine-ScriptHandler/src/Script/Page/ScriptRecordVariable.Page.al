page 20201 "Script Record Variable"
{
    PageType = Card;
    DataCaptionExpression = "Name";
    InsertAllowed = false;
    DeleteAllowed = false;
    SourceTable = "Script Variable";

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(TableName; RecordTableName)
                {
                    Caption = 'Table';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the table name on record.';
                    trigger OnValidate();
                    begin
                        AppObjectHelper.SearchObject(ObjectType::Table, "Table ID", RecordTableName);
                        if xRec."Table ID" <> "Table ID" then
                            UpdateDictionary();
                        UpdateControls();
                    end;

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        AppObjectHelper.OpenObjectLookup(ObjectType::Table, Text, "Table ID", RecordTableName);
                        if xRec."Table ID" <> "Table ID" then
                            UpdateDictionary();
                    end;
                }
            }
            part(TableFields; "Script Record Fields Subform")
            {
                Caption = 'Fields';
                ApplicationArea = Basic, Suite;
                SubPageLink = TableNo = field("Table ID");
                ShowFilter = false;
            }
        }
    }

    var
        AppObjectHelper: Codeunit "App Object Helper";
        RecordTableName: Text[30];

    local procedure UpdateControls();
    begin
        RecordTableName := AppObjectHelper.GetObjectName(ObjectType::Table, "Table ID");
        CurrPage.TableFields.Page.SetVariable(Rec);
    end;

    local procedure UpdateDictionary();
    var
        ScriptRecordVariable: Record "Script Record Variable";
    begin
        ScriptRecordVariable.Reset();
        ScriptRecordVariable.SetRange("Script ID", "Script ID");
        ScriptRecordVariable.SetRange("Variable ID", ID);
        ScriptRecordVariable.DeleteAll();
    end;

    trigger OnAfterGetRecord();
    begin
        UpdateControls();
    end;

    trigger OnAfterGetCurrRecord();
    begin
        UpdateControls();
    end;
}