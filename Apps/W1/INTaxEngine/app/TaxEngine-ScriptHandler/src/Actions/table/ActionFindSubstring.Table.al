table 20168 "Action Find Substring"
{
    Caption = 'Action Find Substring';
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
        field(4; ID; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'ID';
        }
        field(5; "Variable ID"; Integer)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Variable ID';
            TableRelation = "Script Variable".ID where("Script ID" = field("Script ID"));
        }
        field(6; "Substring Value Type"; Option)
        {
            DataClassification = SystemMetadata;
            Caption = 'Substring Value Type';
            OptionMembers = Constant,"Lookup";
        }
        field(7; "Substring Value"; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Substring Value';
        }
        field(8; "Substring Lookup ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Substring Lookup ID';
            TableRelation = "Script Symbol Lookup".ID;
        }
        field(9; "String Value Type"; Option)
        {
            DataClassification = SystemMetadata;
            Caption = 'String Value Type';
            OptionMembers = Constant,"Lookup";
        }
        field(10; "String Value"; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'String Value';
        }
        field(11; "String Lookup ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'String Lookup ID';
            TableRelation = "Script Symbol Lookup".ID;
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
        if "Substring Value Type" = "Substring Value Type"::Lookup then
            LookupEntityMgmt.DeleteLookup("Case ID", "Script ID", "Substring Lookup ID");
        if "String Value Type" = "String Value Type"::Lookup then
            LookupEntityMgmt.DeleteLookup("Case ID", "Script ID", "String Lookup ID");
    end;
}