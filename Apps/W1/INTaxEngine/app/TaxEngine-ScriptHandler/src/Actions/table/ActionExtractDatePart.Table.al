table 20163 "Action Extract Date Part"
{
    Caption = 'Action Extract Date Part';
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
            TableRelation = "Script Variable".ID where("Script ID" = field("Script ID"));
        }
        field(5; "Value Type"; Option)
        {
            DataClassification = SystemMetadata;
            Caption = 'Value Type';
            OptionMembers = Constant,"Lookup";
        }
        field(6; Value; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Value';
        }
        field(7; "Lookup ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Lookup ID';
            TableRelation = "Script Symbol Lookup".ID;
        }
        field(8; "Date Part"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Date Part';
            OptionMembers = Year,Month,Day;
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