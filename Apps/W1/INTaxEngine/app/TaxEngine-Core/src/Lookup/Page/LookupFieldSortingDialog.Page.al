page 20141 "Lookup Field Sorting Dialog"
{
    DelayedInsert = true;
    Caption = 'Table Filters';
    PageType = StandardDialog;
    DataCaptionExpression = '';
    AutoSplitKey = true;
    PopulateAllFields = true;
    SourceTable = "Lookup Field Sorting";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(TableFieldName; TableFieldName2)
                {
                    Caption = 'Field';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the field name of the table.';
                    LookupPageID = "Field Lookup";
                    Lookup = true;

                    trigger OnValidate();
                    begin
                        AppObjectHelper.SearchTableField("Table ID", "Field ID", TableFieldName2);
                        Validate("Field ID");
                    end;

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        AppObjectHelper.OpenFieldLookup("Table ID", "Field ID", TableFieldName2, Text);
                        Validate("Field ID");
                    end;
                }
            }
        }
    }

    var
        LookupTableSorting: Record "Lookup Table Sorting";
        AppObjectHelper: Codeunit "App Object Helper";
        TableFieldName2: Text[30];

    procedure SetCurrentRecord(var LookupTableSorting2: Record "Lookup Table Sorting");
    begin
        LookupTableSorting := LookupTableSorting2;

        TestRecord();

        FilterGroup := 2;
        SetRange("Case ID", LookupTableSorting."Case ID");
        SetRange("Script ID", LookupTableSorting."Script ID");
        SetRange("Table Sorting ID", LookupTableSorting.ID);
        SetRange("Table ID", LookupTableSorting."Table ID");
        FilterGroup := 0;
    end;


    local procedure TestRecord();
    begin
        LookupTableSorting.TestField(ID);
        LookupTableSorting.TestField("Table ID");
    end;

    local procedure FormatLine();
    begin
        TableFieldName2 := AppObjectHelper.GetFieldName("Table ID", "Field ID");
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
        "Case ID" := LookupTableSorting."Case ID";
        "Script ID" := LookupTableSorting."Script ID";
        "Table Sorting ID" := LookupTableSorting.ID;
        "Table ID" := LookupTableSorting."Table ID";
    end;

    trigger OnAfterGetCurrRecord();
    begin
        FormatLine();
    end;
}