table 20141 "Lookup Field Sorting"
{
    Caption = 'Lookup Field Sorting';
    DataClassification = CustomerContent;
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
        field(3; "Table Sorting ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Table Sorting ID';
            TableRelation = "Lookup Table Sorting".ID where(
                "Case ID" = field("Case ID"),
                "Script ID" = field("Script ID"));
        }
        field(4; "Line No."; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Line No.';
        }
        field(5; "Table ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Table ID';
            TableRelation = AllObj."Object ID" where("Object Type" = const(Table));
        }
        field(6; "Field ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Field ID';
            NotBlank = true;
            TableRelation = Field."No." where(TableNo = Field("Table ID"));
        }
    }

    keys
    {
        key(K0; "Case ID", "Script ID", "Table Sorting ID", "Line No.")
        {
            Clustered = True;
        }
    }
    trigger OnInsert()
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed("Case ID");
    end;

    trigger OnModify();
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed("Case ID");
    end;

    trigger OnDelete()
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed("Case ID");
    end;
}