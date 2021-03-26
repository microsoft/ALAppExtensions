table 20283 "Switch Case"
{
    Caption = 'Switch Case';
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
        field(2; "Switch Statement ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Switch Statement ID';
        }
        field(3; "ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'ID';
        }
        field(4; "Condition ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Condition ID';
        }
        field(5; "Action Type"; Enum "Switch Case Action Type")
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Action Type';
        }
        field(6; "Action ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Action ID';
        }
        field(7; "Sequence"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Sequence';
        }
    }

    keys
    {
        key(PK; "Case ID", "Switch Statement ID", ID)
        {
            Clustered = true;
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
        TaxUseCase: Record "Tax Use Case";
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed("Case ID");

        TaxUseCase.Get("Case ID");
        if not IsNullGuid("Condition ID") then
            ScriptEntityMgmt.DeleteCondition("Case ID", Emptyguid, "Condition ID");

        if not IsNullGuid("Action ID") then
            case "Action Type" of
                "Action Type"::Relation:
                    UseCaseEntityMgmt.DeleteTableRelation("Case ID", "Action ID");
                "Action Type"::Lookup:
                    LookupEntityMgmt.DeleteLookup("Case ID", EmptyGuid, "Action ID");
            end;
    end;

    var
        UseCaseEntityMgmt: Codeunit "Use Case Entity Mgmt.";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        LookupEntityMgmt: Codeunit "Lookup Entity Mgmt.";
        EmptyGuid: Guid;
}