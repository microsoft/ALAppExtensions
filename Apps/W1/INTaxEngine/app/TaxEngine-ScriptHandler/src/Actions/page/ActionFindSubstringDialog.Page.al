page 20166 "Action Find Substring Dialog"
{
    Caption = 'Find Substring in String';
    PageType = StandardDialog;
    DataCaptionExpression = '';
    SourceTable = "Action Find Substring";

    layout
    {
        area(Content)
        {
            group(General)
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
                            "Symbol Data Type"::String,
                            "Variable ID",
                            VariableName2);

                        Validate("Variable ID");
                    end;

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        ScriptSymbolsMgmt.OpenSymbolsLookupOfType(
                            "Symbol Type"::Variable,
                            Text,
                            "Symbol Data Type"::String,
                            "Variable ID",
                            VariableName2);

                        Validate("Variable ID");
                    end;
                }
                field(Substring; SubstringVariable)
                {
                    Caption = 'Substring';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Substring value.';
                    trigger OnValidate();
                    begin
                        if LookupMgmt.ConvertLookupToConstant(
                            "Case ID",
                            "Script ID",
                            "Substring Value Type",
                            "Substring Value",
                            "Substring Lookup ID",
                            SubstringVariable,
                            "Symbol Data Type"::STRING)
                        then
                            Validate("Substring Value");

                        FormatLine();
                    end;

                    trigger OnAssistEdit();
                    begin
                        if LookupMgmt.ConvertConstantToLookup(
                            "Case ID",
                            "Script ID",
                            "Substring Value Type",
                            "Substring Value",
                            "Substring Lookup ID")
                        then begin
                            CurrPage.Update(true);
                            Commit();

                            LookupMgmt.OpenLookupDialogOfType(
                                "Case ID",
                                "Script ID",
                                "Substring Lookup ID",
                                "Symbol Data Type"::STRING);

                            Validate("Substring Lookup ID");
                        end;

                        FormatLine();
                    end;
                }
                field(String; StringVariable)
                {
                    Caption = 'String';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the string value from which tax engine will get the Substring.';
                    trigger OnValidate();
                    begin
                        if LookupMgmt.ConvertLookupToConstant(
                            "Case ID",
                            "Script ID",
                            "String Value Type",
                            "String Value",
                            "String Lookup ID",
                            StringVariable,
                            "Symbol Data Type"::STRING)
                        then
                            Validate("String Value");

                        FormatLine();
                    end;

                    trigger OnAssistEdit();
                    begin
                        if LookupMgmt.ConvertConstantToLookup(
                            "Case ID",
                            "Script ID",
                            "String Value Type",
                            "String Value",
                            "String Lookup ID")
                        then begin
                            CurrPage.Update(true);
                            Commit();

                            LookupMgmt.OpenLookupDialogOfType(
                                "Case ID",
                                "Script ID",
                                "String Lookup ID",
                                "Symbol Data Type"::STRING);

                            Validate("String Lookup ID");
                        end;

                        FormatLine();
                    end;
                }
            }
        }
    }

    procedure SetCurrentRecord(var ActionFindSubstring2: Record "Action Find Substring");
    begin
        ActionFindSubstring := ActionFindSubstring2;

        TestRecord();

        FilterGroup := 2;
        SetRange("Case ID", ActionFindSubstring."Case ID");
        SetRange("Script ID", ActionFindSubstring."Script ID");
        SetRange(ID, ActionFindSubstring.ID);
        FilterGroup := 0;
        ScriptSymbolsMgmt.SetContext(ActionFindSubstring."Case ID", ActionFindSubstring."Script ID");
    end;

    local procedure TestRecord();
    begin
        ActionFindSubstring.TestField("Case ID");
        ActionFindSubstring.TestField("Script ID");
        ActionFindSubstring.TestField(ID);
    end;

    local procedure FormatLine();
    begin
        SubstringVariable := LookupSerialization.ConstantOrLookupText(
            "Case ID",
            "Script ID",
            "Substring Value Type",
            "Substring Value",
            "Substring Lookup ID",
            "Symbol Data Type"::STRING);

        StringVariable := LookupSerialization.ConstantOrLookupText(
            "Case ID",
            "Script ID",
            "String Value Type",
            "String Value",
            "String Lookup ID",
            "Symbol Data Type"::STRING);

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
        ActionFindSubstring: Record "Action Find Substring";
        LookupSerialization: Codeunit "Lookup Serialization";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        SubstringVariable: Text;
        VariableName2: Text[30];
        StringVariable: Text;
}