table 20174 "Action Loop Through Rec. Field"
{
    DataClassification = EndUserIdentifiableInformation;
    Access = Public;
    Extensible = false;
    fields
    {
        field(1; "Script ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Script ID';
        }
        field(2; "Loop ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Loop ID';
            TableRelation = "Action Loop Through Records".ID where("Script ID" = field("Script ID"));
        }
        field(3; "Field ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Field ID';
            NotBlank = false;
            TableRelation = Field."No." where(TableNo = field("Table ID"));
        }
        field(4; "Variable ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Variable ID';
            NotBlank = true;
            TableRelation = "Script Variable".ID where("Script ID" = field("Script ID"), ID = field("Variable ID"));
        }
        field(7; "Table ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Table ID';
            TableRelation = AllObj."Object ID" where("Object Type" = CONST(Table));
        }
        field(8; "Calculate Sum"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Calculate Sum';
        }
        field(9; "Case ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Case ID';
        }
    }

    keys
    {
        key(K0; "Case ID", "Script ID", "Loop ID", "Field ID")
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

    trigger OnModify()
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