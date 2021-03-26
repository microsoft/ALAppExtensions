page 20177 "Action Replace Substring Dlg"
{
    Caption = 'Find Substring in String';
    PageType = StandardDialog;
    DataCaptionExpression = '';
    SourceTable = "Action Replace Substring";
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

                            LookupMgmt.OpenLookupDialogOfType("Case ID", "Script ID", "Substring Lookup ID", "Symbol Data Type"::STRING);
                            Validate("Substring Lookup ID");
                        end;

                        FormatLine();
                    end;
                }
                field(NewString; NewStringVariable)
                {
                    Caption = 'with String';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the string value from which tax engine will get the Substring.';
                    trigger OnValidate();
                    begin
                        if LookupMgmt.ConvertLookupToConstant(
                            "Case ID",
                            "Script ID",
                            "New String Value Type",
                            "New String Value",
                            "New String Lookup ID",
                            NewStringVariable,
                            "Symbol Data Type"::STRING)
                        then
                            Validate("New String Value");

                        FormatLine();
                    end;

                    trigger OnAssistEdit();
                    begin
                        if LookupMgmt.ConvertConstantToLookup("Case ID", "Script ID", "New String Value Type", "New String Value", "New String Lookup ID") then begin
                            CurrPage.Update(true);
                            Commit();

                            LookupMgmt.OpenLookupDialogOfType("Case ID", "Script ID", "New String Lookup ID", "Symbol Data Type"::STRING);
                            Validate("New String Lookup ID");
                        end;

                        FormatLine();
                    end;
                }
                field(String; StringVariable)
                {
                    Caption = 'In String';
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
                        if LookupMgmt.ConvertConstantToLookup("Case ID", "Script ID", "String Value Type", "String Value", "String Lookup ID") then begin
                            CurrPage.Update(true);
                            Commit();

                            LookupMgmt.OpenLookupDialogOfType("Case ID", "Script ID", "String Lookup ID", "Symbol Data Type"::STRING);
                            Validate("String Lookup ID");
                        end;

                        FormatLine();
                    end;
                }
            }
        }
    }

    procedure SetCurrentRecord(var ActionReplaceSubstring2: Record "Action Replace Substring");
    begin
        ActionReplaceSubstring := ActionReplaceSubstring2;

        TestRecord();

        FilterGroup := 2;
        SetRange("Case ID", ActionReplaceSubstring."Case ID");
        SetRange("Script ID", ActionReplaceSubstring."Script ID");
        SetRange(ID, ActionReplaceSubstring.ID);
        FilterGroup := 0;
        ScriptSymbolsMgmt.SetContext(ActionReplaceSubstring."Case ID", ActionReplaceSubstring."Script ID");
    end;

    local procedure TestRecord();
    begin
        ActionReplaceSubstring.TestField("Case ID");
        ActionReplaceSubstring.TestField("Script ID");
        ActionReplaceSubstring.TestField(ID);
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

        NewStringVariable := LookupSerialization.ConstantOrLookupText(
            "Case ID",
            "Script ID",
            "New String Value Type",
            "New String Value",
            "New String Lookup ID",
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
        ActionReplaceSubstring: Record "Action Replace Substring";
        LookupSerialization: Codeunit "Lookup Serialization";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        SubstringVariable: Text;
        NewStringVariable: Text;
        VariableName2: Text[30];
        StringVariable: Text;
}