page 20156 "Action Concatenate Dialog"
{
    Caption = 'String Concatenate';
    PageType = StandardDialog;
    DataCaptionExpression = '';
    PopulateAllFields = true;
    SourceTable = "Action Concatenate";

    layout
    {
        area(Content)
        {
            group(Group)
            {
                field(VariableName; VariableName2)
                {
                    Caption = 'Output Variable';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the variable name which will store the output.';
                    trigger OnValidate();
                    begin
                        ScriptSymbolsMgmt.SearchSymbolOfType(
                            "Symbol Type"::Variable,
                            "Symbol Data Type"::STRING,
                            "Variable ID",
                            VariableName2);

                        Validate("Variable ID");
                    end;

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        ScriptSymbolsMgmt.OpenSymbolsLookupOfType(
                            "Symbol Type"::Variable,
                            Text,
                            "Symbol Data Type"::STRING,
                            "Variable ID",
                            VariableName2);

                        Validate("Variable ID");
                    end;
                }
            }
            part("Concatenate Subform"; "Action Concatenate Subform")
            {
                Caption = 'Lines';
                ApplicationArea = Basic, Suite;
                SubPageLink = "Case ID" = field("Case ID"), "Script ID" = field("Script ID"), "Concatenate ID" = field(ID);
            }
        }
    }

    procedure SetCurrentRecord(var ActionConcatenate2: Record "Action Concatenate");
    begin
        ActionConcatenate := ActionConcatenate2;

        TestRecord();

        FilterGroup := 2;
        SetRange("Case ID", ActionConcatenate."Case ID");
        SetRange("Script ID", ActionConcatenate."Script ID");
        SetRange(ID, ActionConcatenate.ID);
        FilterGroup := 0;
        ScriptSymbolsMgmt.SetContext(ActionConcatenate."Case ID", ActionConcatenate."Script ID");
    end;

    local procedure TestRecord();
    begin
        ActionConcatenate.TestField("Case ID");
        ActionConcatenate.TestField("Script ID");
        ActionConcatenate.TestField(ID);
    end;

    local procedure FormatLine();
    begin
        VariableName2 := ScriptSymbolsMgmt.GetSymbolName("Symbol Type"::Variable, "Variable ID");
    end;

    trigger OnOpenPage();
    begin
        TestRecord();
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
        ActionConcatenate: Record "Action Concatenate";
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        VariableName2: Text[30];
}