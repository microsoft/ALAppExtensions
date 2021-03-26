table 20334 "Tax Insert Record"
{
    Caption = 'Tax Insert Record';
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
        field(2; ID; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'ID';
        }
        field(3; "Table ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Table ID';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Table));
        }
        field(4; "Run Trigger"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Run Trigger';
        }
        field(12; "Script ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Script ID';
        }
        field(13; "Sub Ledger Group By"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Sub Ledger Group By';
            OptionMembers = "Component","Line / Component";
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
        InsertRecordField: Record "Tax Insert Record Field";

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

        InsertRecordField.Reset();
        InsertRecordField.SetRange("Case ID", "Case ID");
        InsertRecordField.SetRange("Script ID", "Script ID");
        InsertRecordField.SetRange("Insert Record ID", ID);
        InsertRecordField.DeleteAll(true);
    end;
}