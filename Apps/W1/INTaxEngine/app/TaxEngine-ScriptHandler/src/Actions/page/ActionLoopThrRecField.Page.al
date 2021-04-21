page 20172 "Action Loop Thr. Rec. Field"
{
    Caption = 'Mapping';
    PageType = ListPart;
    DataCaptionExpression = '';
    ShowFilter = false;
    PopulateAllFields = true;
    SourceTable = "Action Loop Through Rec. Field";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(TableFieldName; TableFieldName2)
                {
                    Caption = 'Field';
                    ApplicationArea = Basic, Suite;
                    LookupPageID = "Field Lookup";
                    Lookup = true;
                    ToolTip = 'Specifies field name of the record.';
                    trigger OnValidate();
                    begin
                        AppObjectHelper.SearchTableField("Table ID", "Field ID", TableFieldName2);
                        Validate("Field ID");
                    end;

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        AppObjectHelper.OpenFieldLookup("Table ID", "Field ID", TableFieldName2, Text);
                        Validate("Field ID");
                    end;
                }
                field(VariableName; VariableName2)
                {
                    Caption = 'Output Variable';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the variable name which will store the output.';
                    trigger OnValidate();
                    var
                        FieldDatatype: Enum "Symbol Data Type";
                    begin
                        FieldDatatype := ScriptDataTypeMgmt.GetFieldDatatype("Table ID", "Field ID");
                        case FieldDatatype of
                            "Symbol Data Type"::STRING:
                                FieldDatatype := "Symbol Data Type"::STRING;
                            "Symbol Data Type"::NUMBER:
                                FieldDatatype := "Symbol Data Type"::NUMBER;
                        end;

                        ScriptSymbolsMgmt.SearchSymbolOfType(
                            "Symbol Type"::Variable,
                            FieldDatatype,
                            "Variable ID",
                            VariableName2);

                        Validate("Variable ID");
                    end;

                    trigger OnLookup(var Text: Text): Boolean;
                    var
                        FieldDatatype: Enum "Symbol Data Type";
                    begin
                        FieldDatatype := ScriptDataTypeMgmt.GetFieldDatatype("Table ID", "Field ID");
                        case FieldDatatype of
                            "Symbol Data Type"::STRING:
                                FieldDatatype := "Symbol Data Type"::STRING;
                            "Symbol Data Type"::NUMBER:
                                FieldDatatype := "Symbol Data Type"::NUMBER;
                        end;
                        ScriptSymbolsMgmt.SetContext("Case ID", "Script ID");
                        ScriptSymbolsMgmt.OpenSymbolsLookupOfType(
                            "Symbol Type"::Variable,
                            Text,
                            FieldDatatype,
                            "Variable ID",
                            VariableName2);

                        Validate("Variable ID");
                    end;
                }
                field("Calculate Sum"; "Calculate Sum")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if Tax Engine should store sum of the decimal values.';
                }
            }
        }
    }

    local procedure FormatLine();
    begin
        if IsNullGuid("Case ID") then
            exit;
        ScriptSymbolsMgmt.SetContext("Case ID", "Script ID");
        VariableName2 := ScriptSymbolsMgmt.GetSymbolName("Symbol Type"::Variable, "Variable ID");
        TableFieldName2 := AppObjectHelper.GetFieldName("Table ID", "Field ID");
    end;

    trigger OnAfterGetRecord();
    begin
        FormatLine();
    end;

    trigger OnAfterGetCurrRecord();
    begin
        FormatLine();
    end;

    var
        AppObjectHelper: Codeunit "App Object Helper";
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        TableFieldName2: Text[30];
        VariableName2: Text[30];
}