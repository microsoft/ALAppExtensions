page 20164 "Action Ext. Substr. From Pos."
{
    Caption = 'Extract Substring From Start Or End';
    PageType = StandardDialog;
    DataCaptionExpression = '';
    SourceTable = "Action Ext. Substr. From Pos.";

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
                    ToolTip = 'Specifies the variable which will store the output value.';
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
                field(String; StringVariable)
                {
                    Caption = 'String';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of string variabe for extraction.';
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
                field(Position; Position)
                {
                    Caption = 'From';
                    ToolTip = 'Specifies the position of extraction.';
                    ApplicationArea = Basic, Suite;
                }
                field(Length; LengthVariable)
                {
                    Caption = 'Length';
                    ToolTip = 'Specifies the length of string variabe for extraction.';
                    ApplicationArea = Basic, Suite;

                    trigger OnValidate();
                    begin
                        if LookupMgmt.ConvertLookupToConstant(
                            "Case ID",
                            "Script ID",
                            "Length Value Type",
                            "Length Value",
                            "Length Lookup ID",
                            LengthVariable,
                            "Symbol Data Type"::NUMBER)
                        then
                            Validate("Length Value");

                        FormatLine();
                    end;

                    trigger OnAssistEdit();
                    begin
                        if LookupMgmt.ConvertConstantToLookup(
                            "Case ID",
                            "Script ID",
                            "Length Value Type",
                            "Length Value",
                            "Length Lookup ID")
                        then begin
                            CurrPage.Update(true);
                            Commit();

                            LookupMgmt.OpenLookupDialogOfType(
                                "Case ID",
                                "Script ID",
                                "Length Lookup ID",
                                "Symbol Data Type"::NUMBER);

                            Validate("Length Lookup ID");
                        end;
                        FormatLine();
                    end;
                }
            }
        }
    }

    procedure SetCurrentRecord(var ActionExtSubstrFromPos2: Record "Action Ext. Substr. From Pos.");
    begin
        ActionExtSubstrFromPos := ActionExtSubstrFromPos2;

        TestRecord();

        FilterGroup := 2;
        SetRange("Case ID", ActionExtSubstrFromPos."Case ID");
        SetRange("Script ID", ActionExtSubstrFromPos."Script ID");
        SetRange(ID, ActionExtSubstrFromPos.ID);
        FilterGroup := 0;
        ScriptSymbolsMgmt.SetContext(ActionExtSubstrFromPos."Case ID", ActionExtSubstrFromPos."Script ID");
    end;

    local procedure TestRecord();
    begin
        ActionExtSubstrFromPos.TestField("Case ID");
        ActionExtSubstrFromPos.TestField("Script ID");
        ActionExtSubstrFromPos.TestField(ID);
    end;

    local procedure FormatLine();
    begin
        StringVariable := LookupSerialization.ConstantOrLookupText(
            "Case ID",
            "Script ID",
            "String Value Type",
            "String Value",
            "String Lookup ID",
            "Symbol Data Type"::STRING);

        LengthVariable := LookupSerialization.ConstantOrLookupText(
            "Case ID",
            "Script ID",
            "Length Value Type",
            "Length Value",
            "Length Lookup ID",
            "Symbol Data Type"::NUMBER);

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
        ActionExtSubstrFromPos: Record "Action Ext. Substr. From Pos.";
        LookupSerialization: Codeunit "Lookup Serialization";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        VariableName2: Text[30];
        StringVariable: Text;
        LengthVariable: Text;
}