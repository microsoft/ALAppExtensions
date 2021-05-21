page 20142 "Script Symbol Lookup Dialog"
{
    Caption = 'Lookup Dialog';
    PageType = StandardDialog;
    DataCaptionExpression = '';
    SourceTable = "Script Symbol Lookup";
    layout
    {
        area(Content)
        {
            field("Source Type"; "Source Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Source type of the Lookup.';
                trigger OnValidate();
                begin
                    HandleSourceTypeChange();
                    UpdatePageControls();
                end;
            }
            group(Group3)
            {
                Caption = 'Current Record';
                Visible = "Source Type" = "Source Type"::"Current Record";
                field(FieldName; RecordFieldName)
                {
                    Caption = 'Field Name';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Source field of the Lookup.';
                    trigger OnValidate();
                    begin
                        if "Source Type" = "Source Type"::"Current Record" then begin
                            if ApplyDatatypeFilter then
                                AppObjectHelper.SearchTableFieldOfType(
                                    "Source ID",
                                    "Source Field ID",
                                    RecordFieldName,
                                    ExpectedDatatype)
                            else
                                AppObjectHelper.SearchTableField(
                                    "Source ID",
                                    "Source Field ID",
                                    RecordFieldName);

                            Validate("Source Field ID");
                        end;
                    end;

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        if "Source Type" = "Source Type"::"Current Record" then begin
                            if ApplyDatatypeFilter then
                                AppObjectHelper.OpenFieldLookupOfType(
                                    "Source ID",
                                    "Source Field ID",
                                    RecordFieldName,
                                    Text,
                                    ExpectedDatatype)
                            else
                                AppObjectHelper.OpenFieldLookup(
                                    "Source ID",
                                    "Source Field ID",
                                    RecordFieldName,
                                    Text);

                            Validate("Source Field ID");
                        end;
                    end;
                }
            }
            group(Group5)
            {
                Caption = 'Lookup Table';
                Visible = "Source Type" = "Source Type"::Table;
                field("Lookup Table"; LookupTableName)
                {
                    Caption = 'Table Name';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Source table of the Lookup. It is required only when source type is either "Current Record" or "table".';
                    trigger OnValidate();
                    var
                        xTableID: Integer;
                    begin
                        if "Source Type" = "Source Type"::Table then begin
                            xTableID := "Source ID";
                            if GetShowFullLookup() then
                                AppObjectHelper.SearchObject(ObjectType::Table, "Source ID", LookupTableName)
                            else
                                OnValidateLookupTableName("Case ID", "Script ID", "Source ID", LookupTableName, false);

                            HandleTableChange(xTableID)
                        end;
                    end;

                    trigger OnLookup(var Text: Text): Boolean;

                    var
                        xTableID: Integer;
                    begin
                        if "Source Type" = "Source Type"::Table then begin
                            xTableID := "Source ID";
                            if GetShowFullLookup() then
                                AppObjectHelper.OpenObjectLookup(ObjectType::Table, Text, "Source ID", LookupTableName)
                            else
                                OnLookupLookupTableName("Case ID", "Script ID", "Source ID", LookupTableName, Text);

                            HandleTableChange(xTableID);
                        end;
                    end;
                }
                field(Method; "Table Method")
                {
                    Caption = 'Method';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Method to get the value from table. It is required only when Source type is either "Current Record" or "table".';
                }
                field("Lookup Table Field"; LookupTableFieldName)
                {
                    Caption = 'Field Name';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Source field of the Lookup.';
                    trigger OnValidate();
                    begin
                        if "Source Type" = "Source Type"::Table then begin
                            case "Table Method" of
                                "Table Method"::First, "Table Method"::Last:
                                    if GetApplyDatatypeFilter() then
                                        AppObjectHelper.SearchTableFieldOfType(
                                            "Source ID",
                                            "Source Field ID",
                                            LookupTableFieldName,
                                            GetExpectedDatatype())
                                    else
                                        AppObjectHelper.SearchTableField(
                                            "Source ID",
                                            "Source Field ID",
                                            LookupTableFieldName)
                                else
                                    AppObjectHelper.SearchTableFieldOfType(
                                        "Source ID",
                                        "Source Field ID",
                                        LookupTableFieldName,
                                        "Symbol Data Type"::NUMBER)
                            end;
                            Validate("Source Field ID");
                        end;
                    end;

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        if "Source Type" = "Source Type"::Table then begin
                            case "Table Method" of
                                "Table Method"::First, "Table Method"::Last:
                                    if GetApplyDatatypeFilter() then
                                        AppObjectHelper.OpenFieldLookupOfType(
                                            "Source ID",
                                            "Source Field ID",
                                            LookupTableFieldName,
                                            Text,
                                            GetExpectedDatatype())
                                    else
                                        AppObjectHelper.OpenFieldLookup(
                                            "Source ID",
                                            "Source Field ID",
                                            LookupTableFieldName,
                                            Text)
                                else
                                    AppObjectHelper.OpenFieldLookupOfType(
                                        "Source ID",
                                        "Source Field ID",
                                        LookupTableFieldName,
                                        Text,
                                        "Symbol Data Type"::NUMBER)
                            end;

                            Validate("Source Field ID");
                        end;
                    end;
                }
                field("Lookup Table Filters"; LookupTableFilters2)
                {
                    Caption = 'Table Filters';
                    ToolTip = 'Specifies the table filters applied on a table.';
                    Editable = false;
                    Width = 1024;
                    ApplicationArea = Basic, Suite;
                    trigger OnAssistEdit();
                    begin
                        if ("Source Type" <> "Source Type"::Table) or ("Source ID" = 0) then
                            Exit;

                        if IsNullGuid("Table Filter ID") then
                            "Table Filter ID" := LookupEntityMgmt.CreateTableFilters(
                                "Case ID",
                                "Script ID",
                                "Source ID");

                        LookupDialogMgmt.OpenTableFilterDialog("Case ID", "Script ID", "Table Filter ID");

                        UpdatePageControls();
                    end;
                }
                field("Lookup Table Sorting"; LookupTableSorting2)
                {
                    Caption = 'Table Sorting';
                    Editable = false;
                    Width = 1024;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Sorting applied on table to get the lookup value. It is required only when Source type is either "Current Record" or "table".';
                    trigger OnAssistEdit();
                    begin
                        if ("Source Type" <> "Source Type"::Table) or ("Source ID" = 0) then
                            Exit;

                        if IsNullGuid("Table Sorting ID") then
                            "Table Sorting ID" := LookupEntityMgmt.CreateTableSorting("Case ID", "Script ID", "Source ID");

                        LookupDialogMgmt.OpenTableSortingDialog("Case ID", "Script ID", "Table Sorting ID");

                        UpdatePageControls();
                    end;
                }
            }
            group(Group10)
            {
                Caption = 'Symbol';
                Visible = IsSymbolType;
                field(VariableName; VariableName2)
                {
                    Caption = 'Name';
                    ToolTip = 'Specifies the symbol name of the Lookup.';
                    ApplicationArea = Basic, Suite;
                    trigger OnValidate();

                    begin
                        if ApplyDatatypeFilter then
                            ScriptSymbolsMgmt.SearchSymbolOfType(
                                "Source Type",
                                ExpectedDatatype,
                                "Source Field ID",
                                VariableName2)
                        else
                            ScriptSymbolsMgmt.SearchSymbol(
                                "Source Type",
                                "Source Field ID",
                                VariableName2);

                        Validate("Source Field ID");
                    end;

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        if ApplyDatatypeFilter then
                            ScriptSymbolsMgmt.OpenSymbolsLookupOfType(
                                "Source Type",
                                Text,
                                ExpectedDatatype,
                                "Source Field ID",
                                VariableName2)
                        else
                            ScriptSymbolsMgmt.OpenSymbolsLookup(
                                "Source Type",
                                Text,
                                "Source Field ID",
                                VariableName2);

                        Validate("Source Field ID");
                    end;
                }
            }
            group(Group11)
            {
                Caption = 'Table Attribtues';
                Visible = "Source Type" = "Source Type"::"Attribute Table";
                field("Attribute Table"; LookupTableName)
                {
                    Caption = 'Table Name';
                    ToolTip = 'Specifies the Source table of the Lookup. It is required only when source type is either "Current Record" or "table".';
                    ApplicationArea = Basic, Suite;
                    trigger OnValidate();
                    var
                        xTableID: Integer;
                    begin

                        if "Source Type" = "Source Type"::"Attribute Table" then begin
                            xTableID := "Source ID";
                            if GetShowFullLookup() then
                                AppObjectHelper.SearchObject(ObjectType::Table, "Source ID", LookupTableName)
                            else
                                OnValidateLookupTableName("Case ID", "Script ID", "Source ID", LookupTableName, false);

                            HandleTableChange(xTableID)
                        end;
                    end;

                    trigger OnLookup(var Text: Text): Boolean;
                    var
                        xTableID: Integer;
                    begin
                        if "Source Type" = "Source Type"::"Attribute Table" then begin
                            xTableID := "Source ID";

                            if GetShowFullLookup() then
                                AppObjectHelper.OpenObjectLookup(ObjectType::Table, Text, "Source ID", LookupTableName)
                            else
                                OnLookupLookupTableName("Case ID", "Script ID", "Source ID", LookupTableName, Text);

                            HandleTableChange(xTableID);
                        end;
                    end;
                }
                field(TableAttributeName; AttributeName2)
                {

                    Caption = 'Table Attribute Name';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the table attribute.';
                    trigger OnValidate();
                    begin

                        if "Source Type" in ["Source Type"::"Attribute Table"] then begin
                            if GetApplyDatatypeFilter() then
                                ScriptSymbolsMgmt.SearchSymbolOfType(
                                    "Symbol Type"::"Tax Attributes",
                                    GetExpectedDatatype(),
                                    "Source Field ID",
                                    AttributeName2)
                            else
                                ScriptSymbolsMgmt.SearchSymbol(
                                    "Symbol Type"::"Tax Attributes",
                                    "Source Field ID",
                                    AttributeName2);

                            Validate("Source Field ID");
                        end;
                    end;

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        if "Source Type" in ["Source Type"::"Attribute Table"] then begin
                            if GetApplyDatatypeFilter() then
                                ScriptSymbolsMgmt.OpenSymbolsLookupOfType(
                                    "Symbol Type"::"Tax Attributes",
                                    Text,
                                    GetExpectedDatatype(),
                                    "Source Field ID",
                                    AttributeName2)
                            else
                                ScriptSymbolsMgmt.OpenSymbolsLookup(
                                    "Symbol Type"::"Tax Attributes",
                                    Text,
                                    "Source Field ID",
                                    AttributeName2);

                            Validate("Source Field ID");
                        end;
                    end;
                }
                field("Attribute Table Filters"; LookupTableFilters2)
                {
                    Caption = 'Table Filters';
                    Editable = false;
                    Width = 1024;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Filter applied on table to get the lookup value. It is required only when Source type is either "Current Record" or "table".';
                    trigger OnAssistEdit();
                    begin
                        if ("Source Type" <> "Source Type"::"Attribute Table") or ("Source ID" = 0) then
                            Exit;

                        if IsNullGuid("Table Filter ID") then
                            "Table Filter ID" := LookupEntityMgmt.CreateTableFilters(
                                "Case ID",
                                "Script ID",
                                "Source ID");

                        LookupDialogMgmt.OpenTableFilterDialog("Case ID", "Script ID", "Table Filter ID");

                        UpdatePageControls();
                    end;
                }

            }
        }
    }

    procedure SetCurrentRecord(var ScriptSymbolLookup2: Record "Script Symbol Lookup");
    begin
        ScriptSymbolLookup := ScriptSymbolLookup2;
        TestRecord();

        FilterGroup := 2;
        SetRange("Case ID", ScriptSymbolLookup."Case ID");
        SetRange("Script ID", ScriptSymbolLookup."Script ID");
        SetRange(ID, ScriptSymbolLookup.ID);
        FilterGroup := 0;

        ShowFullLoookup := not IsNullGuid(ScriptSymbolLookup."Script ID");
        IsSymbolType := IsSourceTypeSymbolType(ScriptSymbolLookup."Source Type");
        ScriptSymbolsMgmt.SetContext(ScriptSymbolLookup."Case ID", ScriptSymbolLookup."Script ID");
    end;

    local procedure HandleTableChange(xTableID: Integer);
    begin
        if xTableID = "Source ID" then
            Exit;

        if "Source Type" <> "Source Type"::"Tax Attributes" then
            "Source Field ID" := 0;
        LookupTableFieldName := '';
        LookupTableFilters2 := '';

        if not IsNullGuid("Table Filter ID") then
            LookupEntityMgmt.DeleteTableFilters("Case ID", "Script ID", "Table Filter ID");
    end;

    local procedure TestRecord();
    begin
        ScriptSymbolLookup.TestField("Case ID");
        ScriptSymbolLookup.TestField(ID);
    end;

    local procedure HandleSourceTypeChange();
    begin
        IsSymbolType := IsSourceTypeSymbolType("Source Type");
        "Source ID" := LookupMgmt.GetSourceTable("Case ID");
        "Source Field ID" := 0;
        if not IsNullGuid("Table Filter ID") then
            EntityMgmt.DeleteTableFilters("Case ID", "Script ID", "Table Filter ID");
    end;

    local procedure UpdatePageControls()
    var
        UnhandledSourceTypeErr: Label 'Unhandled source type %1', Comment = '%1 = Source Type';
    begin
        case "Source Type" of
            "Source Type"::"Current Record":
                begin
                    "Source ID" := LookupMgmt.GetSourceTable("Case ID");
                    RecordFieldName := AppObjectHelper.GetFieldName("Source ID", "Source Field ID");
                end;
            "Source Type"::Table:
                begin
                    LookupTableName := AppObjectHelper.GetObjectName(ObjectType::Table, "Source ID");
                    LookupTableFieldName := AppObjectHelper.GetFieldName("Source ID", "Source Field ID");

                    if not IsNullGuid("Table Filter ID") then
                        LookupTableFilters2 := LookupSerialization.TableFilterToString(
                            "Case ID",
                            "Script ID",
                            Rec."Table Filter ID")
                    else
                        LookupTableFilters2 := '';

                    if not IsNullGuid("Table Sorting ID") then
                        LookupTableSorting2 := LookupSerialization.TableSortingToString(
                            "Case ID",
                            "Script ID",
                            Rec."Table Sorting ID")
                    else
                        LookupTableSorting2 := '';
                end;
            "Source Type"::"Attribute Table":
                begin
                    LookupTableName := AppObjectHelper.GetObjectName(ObjectType::Table, "Source ID");
                    AttributeName2 := ScriptSymbolsMgmt.GetSymbolName("Symbol Type"::"Tax Attributes", "Source Field ID");

                    if not IsNullGuid("Table Filter ID") then
                        LookupTableFilters2 := LookupSerialization.TableFilterToString(
                            "Case ID",
                            "Script ID",
                            Rec."Table Filter ID")
                    else
                        LookupTableFilters2 := '';
                end;
            else
                if IsSymbolType then
                    VariableName2 := ScriptSymbolsMgmt.GetSymbolName("Source Type", "Source Field ID")
                else
                    Error(UnhandledSourceTypeErr, "Source Type");
        end;
    end;

    local procedure IsSourceTypeSymbolType(SourceType: Enum "Symbol Type"): Boolean
    var
        Handled: Boolean;
        IsSymbol: Boolean;
        InvalidSourceTypeErr: Label 'Source Type %1 is not handled.', Comment = '%1 = Source Type';
    begin
        case SourceType of
            SourceType::"Current Record", SourceType::Table, SourceType::"Record Variable":
                exit(false);
            SourceType::Database,
            SourceType::System:
                exit(true);
            else begin
                    OnIsSourceTypeSymbolType(SourceType, Handled, IsSymbol);
                    if not Handled then
                        Error(InvalidSourceTypeErr, SourceType);

                    exit(IsSymbol);
                end;
        end;
    end;

    procedure SetDatatype(ExpectedDatatype2: Enum "Symbol Data Type");
    begin
        ExpectedDatatype := ExpectedDatatype2;
        ApplyDatatypeFilter := true;
    end;

    procedure GetApplyDatatypeFilter(): Boolean
    begin
        exit(ApplyDatatypeFilter);
    end;

    procedure GetShowFullLookup(): Boolean
    begin
        exit(ShowFullLoookup);
    end;

    procedure GetExpectedDatatype(): Enum "Symbol Data Type";
    begin
        exit(ExpectedDatatype);
    end;

    [IntegrationEvent(true, false)]
    procedure OnIsSourceTypeSymbolType(
        SymbolType: Enum "Symbol Type";
        var IsHandled: Boolean;
        var IsSymbol: Boolean);
    begin
    end;

    trigger OnAfterGetCurrRecord();
    begin
        UpdatePageControls();
    end;

    trigger OnAfterGetRecord()
    begin
        UpdatePageControls();
    end;

    [IntegrationEvent(false, false)]
    procedure OnValidateLookupTableName(CaseID: Guid; ScriptID: Guid; var TableID: Integer; var TableName: Text[30]; IsTransactionTable: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnLookupLookupTableName(CaseID: Guid; ScriptID: Guid; var TableID: Integer; var TableName: Text[30]; SearchText: Text)
    begin
    end;

    var
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        EntityMgmt: Codeunit "Lookup Entity Mgmt.";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        LookupDialogMgmt: Codeunit "Lookup Dialog Mgmt.";
        AppObjectHelper: Codeunit "App Object Helper";
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        LookupEntityMgmt: Codeunit "Lookup Entity Mgmt.";
        LookupSerialization: Codeunit "Lookup Serialization";
        VariableName2: Text[30];
        RecordFieldName: Text[30];
        ExpectedDatatype: Enum "Symbol Data Type";
        ApplyDatatypeFilter: Boolean;
        [InDataSet]
        ShowFullLoookup: Boolean;
        [InDataSet]
        IsSymbolType: Boolean;
        LookupTableName: Text[30];
        LookupTableFieldName: Text[30];
        AttributeName2: Text[30];
        LookupTableFilters2: Text;
        LookupTableSorting2: Text;
}