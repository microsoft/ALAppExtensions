page 20165 "Action Find Date Interval Dlg"
{
    Caption = 'Find Inverval Between Dates';
    PageType = StandardDialog;
    DataCaptionExpression = '';
    SourceTable = "Action Find Date Interval";

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
                            "Symbol Data Type"::NUMBER,
                            "Variable ID",
                            VariableName2);

                        Validate("Variable ID");

                        FormatLine();
                    end;

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        ScriptSymbolsMgmt.OpenSymbolsLookupOfType(
                            "Symbol Type"::Variable,
                            Text,
                            "Symbol Data Type"::NUMBER,
                            "Variable ID",
                            VariableName2);

                        Validate("Variable ID");

                        FormatLine();
                    end;
                }
                field(Inverval; Inverval)
                {
                    Visible = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of Interval whether it is Days,Hours or Minutes';
                }
                field(Date1; Date1Variable)
                {
                    Caption = 'From Date';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the From Date.';
                    trigger OnValidate();
                    begin
                        if LookupMgmt.ConvertLookupToConstant(
                            "Case ID",
                            "Script ID",
                            "Date1 Value Type",
                            "Date1 Value",
                            "Date1 Lookup ID",
                            Date1Variable,
                            "Symbol Data Type"::DATE)
                        then
                            Validate("Date1 Value");

                        FormatLine();
                    end;

                    trigger OnAssistEdit();
                    begin
                        if LookupMgmt.ConvertConstantToLookup(
                            "Case ID",
                            "Script ID",
                            "Date1 Value Type",
                            "Date1 Value",
                            "Date1 Lookup ID")
                        then begin
                            CurrPage.Update(true);
                            Commit();

                            LookupMgmt.OpenLookupDialogOfType(
                                "Case ID",
                                "Script ID",
                                "Date1 Lookup ID",
                                "Symbol Data Type"::DATE);

                            Validate("Date1 Lookup ID");
                        end;

                        FormatLine();
                    end;
                }
                field(Date2; Date2Variable)
                {
                    Caption = 'To Date';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the To Date.';
                    trigger OnValidate();
                    begin
                        if LookupMgmt.ConvertLookupToConstant(
                            "Case ID",
                            "Script ID",
                            "Date2 Value Type",
                            "Date2 Value",
                            "Date2 Lookup ID",
                            Date2Variable,
                            "Symbol Data Type"::DATE)
                        then
                            Validate("Date2 Value");

                        FormatLine();
                    end;

                    trigger OnAssistEdit();
                    begin
                        if LookupMgmt.ConvertConstantToLookup(
                            "Case ID",
                            "Script ID",
                            "Date2 Value Type",
                            "Date2 Value",
                            "Date2 Lookup ID")
                        then begin
                            CurrPage.Update(true);
                            Commit();

                            LookupMgmt.OpenLookupDialogOfType(
                                "Case ID",
                                "Script ID",
                                "Date2 Lookup ID",
                                "Symbol Data Type"::DATE);

                            Validate("Date2 Lookup ID");
                        end;

                        FormatLine();
                    end;
                }
            }
        }
    }

    procedure SetCurrentRecord(var ActionFindDateInterval2: Record "Action Find Date Interval");
    begin
        ActionFindDateInterval := ActionFindDateInterval2;

        TestRecord();

        FilterGroup := 2;
        SetRange("Case ID", ActionFindDateInterval."Case ID");
        SetRange("Script ID", ActionFindDateInterval."Script ID");
        SetRange(ID, ActionFindDateInterval.ID);
        FilterGroup := 0;
        ScriptSymbolsMgmt.SetContext(ActionFindDateInterval."Case ID", ActionFindDateInterval."Script ID");
    end;


    local procedure TestRecord();
    begin
        ActionFindDateInterval.TestField("Case ID");
        ActionFindDateInterval.TestField("Script ID");
        ActionFindDateInterval.TestField(ID);
    end;

    local procedure FormatLine();
    begin
        Date1Variable := LookupSerialization.ConstantOrLookupText(
            "Case ID",
            "Script ID",
            "Date1 Value Type",
            "Date1 Value",
            "Date1 Lookup ID",
            "Symbol Data Type"::DATE);

        Date2Variable := LookupSerialization.ConstantOrLookupText(
            "Case ID",
            "Script ID",
            "Date2 Value Type",
            "Date2 Value",
            "Date2 Lookup ID",
            "Symbol Data Type"::DATE);

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
        ActionFindDateInterval: Record "Action Find Date Interval";
        LookupSerialization: Codeunit "Lookup Serialization";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        VariableName2: Text[30];
        Date1Variable: Text;
        Date2Variable: Text;
}