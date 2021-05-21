table 20175 "Action Loop Through Records"
{
    Caption = 'Action Loop Through Records';
    DataClassification = EndUserIdentifiableInformation;
    Access = Public;
    Extensible = false;
    fields
    {
        field(1; "Case ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Case ID';
        }
        field(2; "Script ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Script ID';
        }
        field(3; ID; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'ID';
        }
        field(4; "Table ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Table ID';
            TableRelation = AllObj."Object ID" where("Object Type" = CONST(Table));
        }
        field(5; "Table Filter ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Table Filter ID';
            TableRelation = "Lookup Table Filter".ID where(
                "Case ID" = field("Case ID"),
                "Script ID" = field("Script ID"));
        }
        field(6; Order; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Order';
            OptionMembers = "Ascending","Descending";
        }
        field(7; "Table Sorting ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Table Sorting ID';
            TableRelation = "Lookup Table Sorting".ID where(
                "Case ID" = field("Case ID"),
                "Script ID" = field("Script ID"));
        }
        field(8; Distinct; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Distinct';
            trigger OnValidate();
            begin
                if Distinct then
                    "Count Variable" := 0;
            end;
        }
        field(9; "Index Variable"; Integer)
        {
            TableRelation = "Script Variable".ID where("Script ID" = field("Script ID"));
            DataClassification = SystemMetadata;
            Caption = 'Index Variable';
        }
        field(10; "Count Variable"; Integer)
        {
            TableRelation = "Script Variable".ID where("Script ID" = field("Script ID"));
            DataClassification = SystemMetadata;
            Caption = 'Count Variable';
        }
    }

    keys
    {
        key(K0; "Case ID", "Script ID", ID)
        {
            Clustered = True;
        }
    }

    var
        ActionContainer: Record "Action Container";
        ActionLoopThroughRecField: Record "Action Loop Through Rec. Field";
        LookupEntityMgmt: Codeunit "Lookup Entity Mgmt.";

    procedure DeleteFields();
    begin
        ActionLoopThroughRecField.Reset();
        ActionLoopThroughRecField.SetRange("Case ID", "Case ID");
        ActionLoopThroughRecField.SetRange("Script ID", "Script ID");
        ActionLoopThroughRecField.SetRange("Loop ID", ID);
        ActionLoopThroughRecField.DeleteAll(true);
    end;

    trigger OnInsert()
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed("Case ID");
    end;

    trigger OnModify()
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed("Case ID");
    end;

    trigger OnDelete();
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed("Case ID");
        if not IsNullGuid("Table Filter ID") then
            LookupEntityMgmt.DeleteTableFilters("Case ID", "Script ID", "Table Filter ID");

        if not IsNullGuid("Table Sorting ID") then
            LookupEntityMgmt.DeleteTableSorting("Case ID", "Script ID", "Table Sorting ID");

        DeleteFields();

        ActionContainer.Reset();
        ActionContainer.SetRange("Case ID", "Case ID");
        ActionContainer.SetRange("Script ID", "Script ID");
        ActionContainer.SetRange("Container Type", "Container Action Type"::LOOPTHROUGHRECORDS);
        ActionContainer.SetRange("Container Action ID", ID);
        ActionContainer.DeleteAll(true);
    end;
}