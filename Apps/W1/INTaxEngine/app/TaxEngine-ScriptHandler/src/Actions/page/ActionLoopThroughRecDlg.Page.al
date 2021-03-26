page 20171 "Action Loop Through Rec. Dlg"
{
    Caption = 'Loop Records';
    PageType = StandardDialog;
    DataCaptionExpression = FromTableName;
    PopulateAllFields = true;
    SourceTable = "Action Loop Through Records";
    layout
    {
        area(Content)
        {
            group(General)
            {
                field(GetRecordFromTableName; FromTableName)
                {
                    Caption = 'Table Name';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the table name for Looping through the records.';
                    trigger OnValidate();
                    begin
                        AppObjectHelper.SearchObject(ObjectType::Table, "Table ID", FromTableName);
                        ResetFields();
                    end;

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        AppObjectHelper.OpenObjectLookup(ObjectType::Table, Text, "Table ID", FromTableName);
                        ResetFields();
                    end;
                }
                field(Order; Order)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies ascending or descending order.';
                }
                field("Table Filters"; TableFilters)
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the filter applied on table for Looping through the records.';
                    Caption = 'Table Filters';
                    trigger OnAssistEdit();
                    begin
                        if IsNullGuid("Table Filter ID") then
                            "Table Filter ID" := LookupEntityMgmt.CreateTableFilters("Case ID", "Script ID", "Table ID");

                        LookupDialogMgmt.OpenTableFilterDialog("Case ID", "Script ID", "Table Filter ID");

                        if not IsNullGuid("Table Filter ID") then
                            TableFilters := LookupSerialization.TableFilterToString("Case ID", "Script ID", Rec."Table Filter ID")
                    end;
                }
                field(TableSorting; TableSorting2)
                {
                    Caption = 'Sorting';
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the sorting applied to table for Looping through the records.';
                    trigger OnAssistEdit();
                    begin
                        if IsNullGuid("Table Sorting ID") then
                            "Table Sorting ID" := LookupEntityMgmt.CreateTableSorting("Case ID", "Script ID", "Table ID");

                        LookupDialogMgmt.OpenTableSortingDialog("Case ID", "Script ID", "Table Sorting ID");

                        if not IsNullGuid("Table Sorting ID") then
                            TableSorting2 := LookupSerialization.TableSortingToString("Case ID", "Script ID", Rec."Table Sorting ID")
                    end;
                }
                field(Distinct; Distinct)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether records will be distinct or not.';
                    trigger OnValidate();
                    begin
                        CounterVisible := not Distinct;
                    end;
                }
            }
            group(Counters)
            {
                field(IndexVariable; IndexVariable2)
                {
                    Caption = 'Index Variable';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies count of iteration in the loop.';
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
                field(CountVariable; CountVariable2)
                {
                    Caption = 'Count Variable';
                    Enabled = CounterVisible;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies count of records.';
                    trigger OnValidate();
                    begin
                        ScriptSymbolsMgmt.SearchSymbolOfType(
                            "Symbol Type"::Variable,
                            "Symbol Data Type"::NUMBER,
                            "Count Variable",
                            CountVariable2);

                        Validate("Count Variable");
                    end;

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        ScriptSymbolsMgmt.OpenSymbolsLookupOfType(
                            "Symbol Type"::Variable,
                            Text,
                            "Symbol Data Type"::NUMBER,
                            "Count Variable",
                            CountVariable2);

                        Validate("Count Variable");
                    end;
                }
            }
            part("Loop Through Rec. Subform"; "Action Loop Thr. Rec. Field")
            {
                Caption = 'Set Variables';
                ApplicationArea = Basic, Suite;
                SubPageLink = "Case ID" = field("Case ID"), "Script ID" = field("Script ID"), "Loop ID" = field(ID), "Table ID" = field("Table ID");
                ShowFilter = false;
            }
        }
    }

    procedure SetCurrentRecord(var ActionLoopThroughRecords2: Record "Action Loop Through Records");
    begin
        ActionLoopThroughRecords := ActionLoopThroughRecords2;

        TestRecord();

        FilterGroup := 2;
        SetRange("Case ID", ActionLoopThroughRecords."Case ID");
        SetRange("Script ID", ActionLoopThroughRecords."Script ID");
        SetRange(ID, ActionLoopThroughRecords.ID);
        FilterGroup := 0;

        ScriptSymbolsMgmt.SetContext(ActionLoopThroughRecords."Case ID", ActionLoopThroughRecords."Script ID");
    end;

    local procedure TestRecord();
    begin
        ActionLoopThroughRecords.TestField("Case ID");
        ActionLoopThroughRecords.TestField("Script ID");
        ActionLoopThroughRecords.TestField(ID);
    end;

    local procedure FormatLine();
    begin
        FromTableName := AppObjectHelper.GetObjectName(ObjectType::Table, "Table ID");
        if not IsNullGuid("Table Filter ID") then
            TableFilters := LookupSerialization.TableFilterToString("Case ID", "Script ID", Rec."Table Filter ID")
        else
            TableFilters := '';
        if not IsNullGuid("Table Sorting ID") then
            TableSorting2 := LookupSerialization.TableSortingToString("Case ID", "Script ID", Rec."Table Sorting ID")
        else
            TableSorting2 := '';

        IndexVariable2 := ScriptSymbolsMgmt.GetSymbolName("Symbol Type"::Variable, "Index Variable");
        CountVariable2 := ScriptSymbolsMgmt.GetSymbolName("Symbol Type"::Variable, "Count Variable");
        CounterVisible := not Distinct;
    end;

    local procedure ResetFields();
    begin
        if "Table ID" = xRec."Table ID" then
            Exit;

        LookupEntityMgmt.DeleteTableFilters("Case ID", "Script ID", "Table Filter ID");
        LookupEntityMgmt.DeleteTableSorting("Case ID", "Script ID", "Table Sorting ID");
        DeleteFields();
        FormatLine();
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
        ActionLoopThroughRecords: Record "Action Loop Through Records";
        AppObjectHelper: Codeunit "App Object Helper";
        LookupEntityMgmt: Codeunit "Lookup Entity Mgmt.";
        LookupSerialization: Codeunit "Lookup Serialization";
        LookupDialogMgmt: Codeunit "Lookup Dialog Mgmt.";
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        FromTableName: Text[30];
        TableFilters: Text;
        TableSorting2: Text;
        IndexVariable2: Text[30];
        CountVariable2: Text[30];
        [InDataSet]
        CounterVisible: Boolean;
}