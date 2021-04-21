table 20173 "Action Loop N Times"
{
    Caption = 'Action Loop N Times';
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
        field(4; "Value Type"; Option)
        {
            DataClassification = SystemMetadata;
            Caption = 'Value Type';
            OptionMembers = Constant,"Lookup";
        }
        field(5; Value; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Value';
            trigger OnValidate();
            begin
                ValidateValue();
            end;
        }
        field(6; "Lookup ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Lookup ID';
            TableRelation = "Script Symbol Lookup".ID;
        }
        field(7; "Index Variable"; Integer)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Index Variable';
        }
    }

    keys
    {
        key(K0; "Case ID", "Script ID", ID)
        {
            Clustered = True;
        }
    }

    local procedure ValidateValue();
    begin
        ScriptDataTypeMgmt.CheckConstantDatatype(Value, "Symbol Data Type"::NUMBER, '');
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
        ActionContainer: Record "Action Container";
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed("Case ID");
        if "Value Type" = "Value Type"::Lookup then
            LookupEntityMgmt.DeleteLookup("Case ID", "Script ID", "Lookup ID");

        ActionContainer.Reset();
        ActionContainer.SetRange("Case ID", "Case ID");
        ActionContainer.SetRange("Script ID", "Script ID");
        ActionContainer.SetRange("Container Type", "Container Action Type"::LOOPNTIMES);
        ActionContainer.SetRange("Container Action ID", ID);
        ActionContainer.DeleteAll(true);
    end;

    var
        LookupEntityMgmt: Codeunit "Lookup Entity Mgmt.";
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
}