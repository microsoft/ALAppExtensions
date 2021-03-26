table 20176 "Action Loop With Condition"
{
    Caption = 'Action Loop With Condition';
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
        ActionContainer.SetRange("Container Type", "Container Action Type"::LOOPWITHCONDITION);
        ActionContainer.SetRange("Container Action ID", ID);
        ActionContainer.DeleteAll(true);
    end;

    var
        ActionContainer: Record "Action Container";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
}