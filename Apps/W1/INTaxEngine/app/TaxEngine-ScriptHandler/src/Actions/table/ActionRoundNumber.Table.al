table 20182 "Action Round Number"
{
    Caption = 'Action Round Number';
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
        field(4; "Number Value Type"; Option)
        {
            DataClassification = SystemMetadata;
            Caption = 'Number Value Type';
            OptionMembers = Constant,"Lookup";
        }
        field(5; "Number Value"; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Number Value';
        }
        field(6; "Number Lookup ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Number Lookup ID';
            TableRelation = "Script Symbol Lookup".ID;
        }
        field(7; "Variable ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Variable ID';
            TableRelation = "Script Variable".ID where("Script ID" = field("Script ID"));
        }
        field(8; "Precision Value Type"; Option)
        {
            DataClassification = SystemMetadata;
            Caption = 'Precision Value Type';
            OptionMembers = Constant,"Lookup";
        }
        field(9; "Precision Value"; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Precision Value';
        }
        field(10; "Precision Lookup ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Precision Lookup ID';
            TableRelation = "Script Symbol Lookup".ID;
        }
        field(11; Direction; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Direction';
            OptionMembers = Nearest,Up,Down;
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

        if "Number Value Type" = "Number Value Type"::Lookup then
            LookupEntityMgmt.DeleteLookup("Case ID", "Script ID", "Number Lookup ID");
        if "Precision Value Type" = "Precision Value Type"::Lookup then
            LookupEntityMgmt.DeleteLookup("Case ID", "Script ID", "Precision Lookup ID");
    end;
}