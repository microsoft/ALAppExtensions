table 20171 "Action If Statement"
{
    Caption = 'Action If Statement';
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
        field(4; "Condition ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Condition ID';
            TableRelation = "Tax Test Condition".ID where("Script ID" = field("Script ID"));
        }
        field(5; "Else If Block ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Else If Block ID';
            TableRelation = "Action If Statement".ID where("Script ID" = field("Script ID"));
        }
        field(6; "Parent If Block ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Parent If Block ID';
        }
    }

    keys
    {
        key(K0; "Case ID", "Script ID", ID)
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

    trigger OnDelete();
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed("Case ID");

        if not IsNullGuid("Condition ID") then
            ScriptEntityMgmt.DeleteCondition("Case ID", "Script ID", "Condition ID");

        ActionContainer.Reset();
        ActionContainer.SetRange("Case ID", "Case ID");
        ActionContainer.SetRange("Script ID", "Script ID");
        ActionContainer.SetRange("Container Type", "Container Action Type"::IFSTATEMENT);
        ActionContainer.SetRange("Container Action ID", ID);
        ActionContainer.DeleteAll(true);
    end;

    var
        ActionContainer: Record "Action Container";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
}