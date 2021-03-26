table 20307 "Use Case Attribute Mapping"
{
    Caption = 'Use Case Attribute Mapping';
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
        field(3; "Tax Type"; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Tax Type';
            TableRelation = "Tax Type".Code;
        }
        field(4; "Attribtue ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Attribute ID';
            trigger OnValidate()
            var
                UseCaseAttributeMapping: Record "Use Case Attribute Mapping";
                AttributeMappingAlreadyExistErr: Label 'Attribute Mapping already exist.';
            begin
                if "Attribtue ID" = 0 then
                    exit;

                UseCaseAttributeMapping.SetRange("Case ID", "Case ID");
                UseCaseAttributeMapping.SetRange("Attribtue ID", "Attribtue ID");
                UseCaseAttributeMapping.SetFilter(ID, '<>%1', ID);
                if not UseCaseAttributeMapping.IsEmpty() then
                    Error(AttributeMappingAlreadyExistErr);
            end;
        }
        field(6; "Switch Statement ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Switch Statement ID';
        }
    }

    keys
    {
        key(PK; "Case ID", ID)
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        TaxUseCase: Record "Tax Use Case";
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed("Case ID");
        if IsNullGuid(ID) then begin
            ID := CreateGuid();
            TaxUseCase.Get("Case ID");
            "Tax Type" := TaxUseCase."Tax Type";
        end;
    end;

    trigger OnModify()
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed("Case ID");
    end;

    trigger OnDelete()
    var
    begin
        SwitchStatementHelper.DeleteSwitchStatement("Case ID", "Switch Statement ID");
    end;

    var
        SwitchStatementHelper: Codeunit "Switch Statement Helper";
}