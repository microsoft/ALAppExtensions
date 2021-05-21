page 20160 "Action Date To DateTime Dialog"
{
    Caption = 'Date To DateTime Calculation Dialog';
    PageType = StandardDialog;
    DataCaptionExpression = '';
    SourceTable = "Action Date To DateTime";

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(VariableName; VariableName2)
                {
                    Caption = 'Output To Variable';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the vairable which will store the output.';
                    trigger OnValidate();
                    begin
                        ScriptSymbolsMgmt.SearchSymbolOfType(
                            "Symbol Type"::Variable,
                            "Symbol Data Type"::DATETIME,
                            "Variable ID",
                            VariableName2);

                        Validate("Variable ID");
                    end;

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        ScriptSymbolsMgmt.OpenSymbolsLookupOfType(
                            "Symbol Type"::Variable,
                            Text,
                            "Symbol Data Type"::DATETIME,
                            "Variable ID",
                            VariableName2);

                        Validate("Variable ID");
                    end;
                }
                field(Date; DateVariable)
                {
                    Caption = 'Date';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of Date value.';
                    trigger OnValidate();
                    begin
                        if LookupMgmt.ConvertLookupToConstant(
                            "Case ID",
                            "Script ID",
                            "Date Value Type",
                            "Date Value",
                            "Date Lookup ID",
                            DateVariable,
                            "Symbol Data Type"::DATE)
                        then
                            Validate("Date Value");

                        FormatLine();
                    end;

                    trigger OnAssistEdit();
                    begin
                        if LookupMgmt.ConvertConstantToLookup(
                            "Case ID",
                            "Script ID",
                            "Date Value Type",
                            "Date Value",
                            "Date Lookup ID")
                        then begin
                            CurrPage.Update(true);
                            Commit();

                            LookupMgmt.OpenLookupDialogOfType(
                                "Case ID",
                                "Script ID",
                                "Date Lookup ID",
                                "Symbol Data Type"::DATE);
                            Validate("Date Lookup ID");
                        end;

                        FormatLine();
                    end;
                }
                field(TimeVariable; TimeVariable2)
                {
                    Caption = 'Time';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of time.';
                    trigger OnValidate();
                    begin
                        if LookupMgmt.ConvertLookupToConstant(
                            "Case ID",
                            "Script ID",
                            "Time Value Type",
                            "Time Value",
                            "Time Lookup ID",
                            TimeVariable2,
                            "Symbol Data Type"::TIME)
                        then
                            Validate("Time Value");

                        FormatLine();
                    end;

                    trigger OnAssistEdit();
                    begin
                        if LookupMgmt.ConvertConstantToLookup(
                            "Case ID",
                            "Script ID",
                            "Time Value Type",
                            "Time Value",
                            "Time Lookup ID")
                        then begin
                            CurrPage.Update(true);
                            Commit();

                            LookupMgmt.OpenLookupDialogOfType(
                                "Case ID",
                                "Script ID",
                                "Time Lookup ID",
                                "Symbol Data Type"::TIME);
                            Validate("Time Lookup ID");
                        end;

                        FormatLine();
                    end;
                }
            }
        }
    }

    procedure SetCurrentRecord(var ActionDateToDateTime2: Record "Action Date To DateTime");
    begin
        ActionDateToDateTime := ActionDateToDateTime2;

        TestRecord();

        FilterGroup := 2;
        SetRange("Case ID", ActionDateToDateTime."Case ID");
        SetRange("Script ID", ActionDateToDateTime."Script ID");
        SetRange(ID, ActionDateToDateTime.ID);
        FilterGroup := 0;

        ScriptSymbolsMgmt.SetContext(ActionDateToDateTime."Case ID", ActionDateToDateTime."Script ID");
    end;

    local procedure TestRecord();
    begin
        ActionDateToDateTime.TestField("Case ID");
        ActionDateToDateTime.TestField("Script ID");
        ActionDateToDateTime.TestField(ID);
    end;

    local procedure FormatLine();
    begin
        DateVariable := LookupSerialization.ConstantOrLookupText(
            "Case ID",
            "Script ID",
            "Date Value Type",
            "Date Value",
            "Date Lookup ID",
            "Symbol Data Type"::DATE);
        TimeVariable2 := LookupSerialization.ConstantOrLookupText(
            "Case ID",
            "Script ID",
            "Time Value Type",
            "Time Value",
            "Time Lookup ID",
            "Symbol Data Type"::TIME);
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
        ActionDateToDateTime: Record "Action Date To DateTime";
        LookupSerialization: Codeunit "Lookup Serialization";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        DateVariable: Text;
        TimeVariable2: Text;
        VariableName2: Text[30];
}