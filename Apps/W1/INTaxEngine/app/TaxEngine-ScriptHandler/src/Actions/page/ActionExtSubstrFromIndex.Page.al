page 20163 "Action Ext. Substr. From Index"
{
    Caption = 'Extract Substring From Index In String';
    PageType = StandardDialog;
    DataCaptionExpression = '';
    SourceTable = "Action Ext. Substr. From Index";
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
                field(FromIndex; IndexVariable)
                {
                    Caption = 'From Index';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Index value of substring.';
                    trigger OnValidate();
                    begin
                        if LookupMgmt.ConvertLookupToConstant(
                            "Case ID",
                            "Script ID",
                            "Index Value Type",
                            "Index Value",
                            "Index Lookup ID",
                            IndexVariable,
                            "Symbol Data Type"::NUMBER)
                        then
                            Validate("Index Value");

                        FormatLine();
                    end;

                    trigger OnAssistEdit();
                    begin
                        if LookupMgmt.ConvertConstantToLookup(
                            "Case ID",
                            "Script ID",
                            "Index Value Type",
                            "Index Value",
                            "Index Lookup ID")
                        then begin
                            CurrPage.Update(true);
                            Commit();

                            LookupMgmt.OpenLookupDialogOfType(
                                "Case ID",
                                "Script ID",
                                "Index Lookup ID",
                                "Symbol Data Type"::NUMBER);

                            Validate("Index Lookup ID");
                        end;

                        FormatLine();
                    end;
                }
                field(Length; LengthVariable)
                {
                    Caption = 'Length';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the length of Extract.';
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

    procedure SetCurrentRecord(var ActionExtSubstrFromIndex2: Record "Action Ext. Substr. From Index");
    begin
        ActionExtSubstrFromIndex := ActionExtSubstrFromIndex2;

        TestRecord();

        FilterGroup := 2;
        SetRange("Case ID", ActionExtSubstrFromIndex."Case ID");
        SetRange("Script ID", ActionExtSubstrFromIndex."Script ID");
        SetRange(ID, ActionExtSubstrFromIndex.ID);
        FilterGroup := 0;
        ScriptSymbolsMgmt.SetContext(ActionExtSubstrFromIndex."Case ID", ActionExtSubstrFromIndex."Script ID");
    end;

    local procedure TestRecord();
    begin
        ActionExtSubstrFromIndex.TestField("Case ID");
        ActionExtSubstrFromIndex.TestField("Script ID");
        ActionExtSubstrFromIndex.TestField(ID);
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

        IndexVariable := LookupSerialization.ConstantOrLookupText(
            "Case ID",
            "Script ID",
            "Index Value Type",
            "Index Value",
            "Index Lookup ID",
            "Symbol Data Type"::NUMBER);

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
        ActionExtSubstrFromIndex: Record "Action Ext. Substr. From Index";
        LookupSerialization: Codeunit "Lookup Serialization";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        IndexVariable: Text;
        VariableName2: Text[30];
        StringVariable: Text;
        LengthVariable: Text;
}