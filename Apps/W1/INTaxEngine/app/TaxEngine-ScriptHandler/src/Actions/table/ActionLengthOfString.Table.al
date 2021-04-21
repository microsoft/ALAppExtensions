table 20172 "Action Length Of String"
{
    Caption = 'Action Length Of String';
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
        }
        field(6; "Lookup ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Lookup ID';
            TableRelation = "Script Symbol Lookup".ID;
        }
        field(7; "Variable ID"; Integer)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Variable ID';
            TableRelation = "Script Variable".ID where("Script ID" = field("Script ID"));
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

        if "Value Type" = "Value Type"::Lookup then
            LookupEntityMgmt.DeleteLookup("Case ID", "Script ID", "Lookup ID");
    end;
}