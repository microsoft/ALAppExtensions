table 20190 "Tax Test Condition"
{
    Caption = 'Condition';
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
    }

    keys
    {
        key(K0; "Case ID", "Script ID", ID)
        {
            Clustered = True;
        }
    }

    var
        ConditionItem: Record "Tax Test Condition Item";

    trigger OnInsert()
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

        ConditionItem.Reset();
        ConditionItem.SetRange("Case ID", "Case ID");
        ConditionItem.SetRange("Condition ID", ID);
        ConditionItem.DeleteAll(true);
    end;
}