table 20178 "Action Number Calculation"
{
    Caption = 'Action Number Calculation';
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
        field(4; "Variable ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Variable ID';
            TableRelation = "Script Variable".ID where("Script ID" = field("Case ID"));
        }
        field(5; "LHS Type"; Option)
        {
            DataClassification = SystemMetadata;
            Caption = 'LHS Type';
            OptionMembers = Constant,"Lookup";
        }
        field(6; "LHS Value"; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'LHS Value';
        }
        field(7; "LHS Lookup ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'LHS Lookup ID';
            TableRelation = "Script Symbol Lookup".ID;
        }
        field(8; "Arithmetic Operator"; Enum "Arithmetic Operator")
        {
            DataClassification = CustomerContent;
            Caption = 'Arithmetic operators';
        }
        field(9; "RHS Type"; Option)
        {
            DataClassification = SystemMetadata;
            Caption = 'RHS Type';
            OptionMembers = Constant,"Lookup";
        }
        field(10; "RHS Value"; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'RHS Value';
        }
        field(11; "RHS Lookup ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'RHS Lookup ID';
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
        LookupEntityMgmt: Codeunit "Lookup Entity Mgmt.";

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
        if "LHS Type" = "LHS Type"::Lookup then
            LookupEntityMgmt.DeleteLookup("Case ID", "Script ID", "LHS Lookup ID");
        if "RHS Type" = "RHS Type"::Lookup then
            LookupEntityMgmt.DeleteLookup("Case ID", "Script ID", "RHS Lookup ID");
    end;
}