page 20140 "Lookup Field Filter Dialog"
{
    Caption = 'Table Filters';
    PageType = StandardDialog;
    DataCaptionExpression = '';
    AutoSplitKey = true;
    PopulateAllFields = true;
    SourceTable = "Lookup Field Filter";
    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(TableFieldName; TableFieldName2)
                {
                    Caption = 'Field';
                    ToolTip = 'Specifies the name of field of filter table.';
                    ApplicationArea = Basic, Suite;
                    LookupPageID = "Field Lookup";
                    Lookup = true;

                    trigger OnValidate();
                    begin
                        AppObjectHelper.SearchTableField("Table ID", "Field ID", TableFieldName2);
                        Validate("Field ID");
                        CurrPage.SaveRecord();
                    end;

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        AppObjectHelper.OpenFieldLookup("Table ID", "Field ID", TableFieldName2, Text);
                        Validate("Field ID");
                        CurrPage.SaveRecord();
                    end;
                }
                field("Filter Type"; "Filter Type")
                {
                    Caption = 'Type';
                    ToolTip = 'Specifies the type of filter which will be applied on the field.';
                    ApplicationArea = Basic, Suite;
                }
                field(FilterValue; FilterValue2)
                {
                    Caption = 'Value';
                    ToolTip = 'Specifies the value of filter, it can be a constant value or derived from a Lookup.';
                    ApplicationArea = Basic, Suite;

                    trigger OnValidate();
                    var
                        FieldDataType: Enum "Symbol Data Type";
                    begin
                        FieldDataType := DataTypeMgmt.GetFieldDatatype("Table ID", "Field ID");
                        if LookupMgmt.ConvertLookupToConstant(
                            "Case ID",
                            "Script ID",
                            "Value Type",
                            Value,
                            "Lookup ID",
                            FilterValue2,
                            FieldDataType)
                        then
                            Validate(Value);

                        FormatLine();
                    end;

                    trigger OnAssistEdit();
                    var
                        FieldDataType: Enum "Symbol Data Type";
                    begin
                        if LookupMgmt.ConvertConstantToLookup(
                            "Case ID",
                            "Script ID",
                            "Value Type",
                            Value,
                            "Lookup ID")
                        then begin
                            CurrPage.SaveRecord();
                            Commit();

                            if "Filter Type" <> "Filter Type"::"CAL Filter" then begin
                                FieldDataType := DataTypeMgmt.GetFieldDatatype("Table ID", "Field ID");
                                LookupMgmt.OpenLookupDialogOfType(
                                    "Case ID",
                                    "Script ID",
                                    "Lookup ID",
                                    FieldDataType);
                            end else
                                LookupMgmt.OpenLookupDialogOfType(
                                    "Case ID",
                                    "Script ID",
                                    "Lookup ID",
                                    SymbolDataType::String);

                            Validate("Lookup ID");
                        end;

                        FormatLine();
                    end;
                }
            }
        }
    }

    var
        LookupTableFilter: Record "Lookup Table Filter";
        AppObjectHelper: Codeunit "App Object Helper";
        LookupSerialization: Codeunit "Lookup Serialization";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        DataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        TableFieldName2: Text[30];
        FilterValue2: Text;
        SymbolDataType: Enum "Symbol Data Type";


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
        TableFieldName2 := '';
        FilterValue2 := '';
        "Case ID" := LookupTableFilter."Case ID";
        "Script ID" := LookupTableFilter."Script ID";
        "Table Filter ID" := LookupTableFilter.ID;
        "Table ID" := LookupTableFilter."Table ID";
    end;

    trigger OnAfterGetCurrRecord();
    begin
        FormatLine();
    end;

    procedure SetCurrentRecord(var LookupTableFilter2: Record "Lookup Table Filter");
    begin
        LookupTableFilter := LookupTableFilter2;
        TestRecord();

        FilterGroup := 2;
        SetRange("Case ID", LookupTableFilter."Case ID");
        SetRange("Script ID", LookupTableFilter."Script ID");
        SetRange("Table Filter ID", LookupTableFilter.ID);
        SetRange("Table ID", LookupTableFilter."Table ID");
        FilterGroup := 0;
    end;

    local procedure TestRecord();
    begin
        LookupTableFilter.TestField("Case ID");
        LookupTableFilter.TestField(ID);
        LookupTableFilter.TestField("Table ID");
    end;

    local procedure FormatLine();
    var
        FieldDataType: Enum "Symbol Data Type";
    begin
        TableFieldName2 := AppObjectHelper.GetFieldName("Table ID", "Field ID");
        if "Field ID" <> 0 then begin
            FieldDataType := DataTypeMgmt.GetFieldDatatype("Table ID", "Field ID");
            FilterValue2 := LookupSerialization.ConstantOrLookupText(
                "Case ID",
                "Script ID",
                "Value Type",
                Value,
                "Lookup ID",
                FieldDataType);
        end else
            FilterValue2 := '';
    end;
}