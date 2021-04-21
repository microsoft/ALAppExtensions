page 20170 "Action Loop N Times Dialog"
{
    Caption = 'Loop N Times Dialog';
    PageType = StandardDialog;
    DataCaptionExpression = '';
    SourceTable = "Action Loop N Times";

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(NValue; NValue2)
                {
                    Caption = 'Number of Iterations';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of Iteration in a loop.';
                    trigger OnValidate();
                    begin
                        if LookupMgmt.ConvertLookupToConstant(
                            "Case ID",
                            "Script ID",
                            "Value Type",
                            Value,
                            "Lookup ID",
                            NValue2,
                            "Symbol Data Type"::NUMBER)
                        then
                            Validate(Value);

                        FormatLine();
                    end;

                    trigger OnAssistEdit();
                    var

                    begin
                        if LookupMgmt.ConvertConstantToLookup(
                            "Case ID",
                            "Script ID",
                            "Value Type",
                            Value,
                            "Lookup ID")
                        then begin
                            CurrPage.Update(true);
                            Commit();

                            LookupMgmt.OpenLookupDialogOfType(
                                "Case ID",
                                "Script ID",
                                "Lookup ID",
                                "Symbol Data Type"::NUMBER);
                            Validate("Lookup ID");
                        end;

                        FormatLine();
                    end;
                }
            }
            group(Counters)
            {
                field(IndexVariable; IndexVariable2)
                {
                    Caption = 'Index Variable';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the variable name where curent iteration of loop can be stored.';
                    trigger OnValidate();
                    begin
                        ScriptSymbolsMgmt.SearchSymbolOfType(
                            "Symbol Type"::Variable,
                            "Symbol Data Type"::NUMBER,
                            "Index Variable",
                            IndexVariable2);

                        Validate("Index Variable");
                    end;

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        ScriptSymbolsMgmt.OpenSymbolsLookupOfType(
                            "Symbol Type"::Variable,
                            Text,
                            "Symbol Data Type"::NUMBER,
                            "Index Variable",
                            IndexVariable2);
                        Validate("Index Variable");
                    end;
                }
            }
        }
    }

    procedure SetCurrentRecord(var ActionLoopNTimes2: Record "Action Loop N Times");
    begin
        ActionLoopNTimes := ActionLoopNTimes2;

        TestRecord();

        FilterGroup := 2;
        SetRange("Case ID", ActionLoopNTimes."Case ID");
        SetRange("Script ID", ActionLoopNTimes."Script ID");
        SetRange(ID, ActionLoopNTimes.ID);
        FilterGroup := 0;
        ScriptSymbolsMgmt.SetContext(ActionLoopNTimes."Case ID", ActionLoopNTimes."Script ID");
    end;

    local procedure TestRecord();
    begin
        ActionLoopNTimes.TestField("Script ID");
        ActionLoopNTimes.TestField(ID);
    end;

    local procedure FormatLine();
    begin
        NValue2 := LookupSerialization.ConstantOrLookupText(
            "Case ID",
            "Script ID",
            "Value Type",
            Value,
            "Lookup ID",
            "Symbol Data Type"::NUMBER);
        IndexVariable2 := ScriptSymbolsMgmt.GetSymbolName("Symbol Type"::Variable, "Index Variable");
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
        ActionLoopNTimes: Record "Action Loop N Times";
        LookupSerialization: Codeunit "Lookup Serialization";
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        NValue2: Text;
        IndexVariable2: Text[30];
}