page 20190 "Conditions Dialog"
{
    DelayedInsert = true;
    Caption = 'Conditions';
    PageType = StandardDialog;
    DataCaptionExpression = '';
    AutoSplitKey = true;
    PopulateAllFields = true;
    SourceTable = "Tax Test Condition Item";
    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Logical Operator"; "Logical Operator")
                {
                    Caption = 'Operator';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the "and" , "or" operator for the condition.';
                }
                field(LHSValue; LHSValue2)
                {
                    Caption = 'Value 1';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of LHS in a condition statement.';
                    trigger OnAssistEdit();
                    var
                        RHSDatatype: Enum "Symbol Data Type";
                    begin
                        if IsNullGuid("LHS Lookup ID") then begin
                            "LHS Lookup ID" := LookupEntityMgmt.CreateLookup("Case ID", "Script ID");
                            Commit();
                        end;

                        if not IsNullGuid("RHS Lookup ID") then begin
                            RHSDatatype := LookupMgmt.GetLookupDatatype("Case ID", "Script ID", "RHS Lookup ID");
                            LookupMgmt.OpenLookupDialogOfType(
                                "Case ID",
                                "Script ID",
                                "LHS Lookup ID",
                                RHSDatatype);
                        end else
                            LookupMgmt.OpenLookupDialog("Case ID", "Script ID", "LHS Lookup ID");

                        Validate("LHS Lookup ID");
                        FormatLine();
                    end;
                }
                field("Conditional Operator"; "Conditional Operator")
                {
                    Caption = 'Condition';
                    ToolTip = 'Specifies the conditional operator such as "Equal To", "Is Greater than" etc. for the condition.';
                    ApplicationArea = Basic, Suite;
                }
                field(RHSValue; RHSValue2)
                {
                    Caption = 'Value 2';
                    ToolTip = 'Specifies the value of RHS in a condition statement.';
                    ApplicationArea = Basic, Suite;

                    trigger OnValidate();
                    var
                        LHSDatatype: Enum "Symbol Data Type";
                    begin
                        LHSDatatype := LookupMgmt.GetLookupDatatype("Case ID", "Script ID", "LHS Lookup ID");
                        if LookupMgmt.ConvertLookupToConstant(
                            "Case ID",
                            "Script ID",
                            "RHS Type",
                            "RHS Value",
                            "RHS Lookup ID",
                            RHSValue2,
                            LHSDatatype)
                        then
                            Validate("RHS Value");

                        FormatLine();
                    end;

                    trigger OnAssistEdit();
                    var
                        LHSDatatype: Enum "Symbol Data Type";
                        NullLHSLookupErr: Label 'Please select LHS value.';
                    begin
                        if IsNullGuid("LHS Lookup ID") then
                            Error(NullLHSLookupErr);

                        if LookupMgmt.ConvertConstantToLookup(
                            "Case ID",
                            "Script ID",
                            "RHS Type",
                            "RHS Value",
                            "RHS Lookup ID")
                        then begin
                            Commit();

                            LHSDatatype := LookupMgmt.GetLookupDatatype("Case ID", "Script ID", "LHS Lookup ID");
                            LookupMgmt.OpenLookupDialogOfType(
                                "Case ID",
                                "Script ID",
                                "RHS Lookup ID",
                                LHSDatatype);

                            Validate("RHS Lookup ID");
                        end;

                        FormatLine();
                    end;
                }
            }
        }
    }

    var
        Condition: Record "Tax Test Condition";
        LookupEntityMgmt: Codeunit "Lookup Entity Mgmt.";
        LookupSerialization: Codeunit "Lookup Serialization";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        LHSValue2: Text;
        RHSValue2: Text;

    procedure SetCurrentRecord(var Condition2: Record "Tax Test Condition");
    begin
        Condition := Condition2;
        TestRecord();

        FilterGroup := 2;
        SetRange("Case ID", Condition."Case ID");
        SetRange("Script ID", Condition."Script ID");
        SetRange("Condition ID", Condition.ID);
        FilterGroup := 0;
    end;


    local procedure TestRecord();
    begin
        Condition.TestField("Case ID");
        Condition.TestField(ID);
    end;

    local procedure FormatLine();
    var
        LHSDatatype: Enum "Symbol Data Type";
    begin
        if not IsNullGuid("LHS Lookup ID") then begin
            LHSValue2 := LookupSerialization.LookupToString("Case ID", "Script ID", "LHS Lookup ID");
            LHSDatatype := LookupMgmt.GetLookupDatatype("Case ID", "Script ID", "LHS Lookup ID");

            RHSValue2 := LookupSerialization.ConstantOrLookupText(
                "Case ID",
                "Script ID",
                "RHS Type",
                "RHS Value",
                "RHS Lookup ID",
                LHSDatatype);
        end else begin
            LHSValue2 := '';
            RHSValue2 := '';
        end;
    end;

    trigger OnOpenPage();
    begin
        TestRecord();
    end;

    trigger OnAfterGetRecord();
    begin
        FormatLine();
    end;

    trigger OnNewRecord(BelowxRec: Boolean);
    begin
        "Case ID" := Condition."Case ID";
        "Condition ID" := Condition.ID;
    end;

    trigger OnAfterGetCurrRecord();
    begin
        FormatLine();
    end;
}