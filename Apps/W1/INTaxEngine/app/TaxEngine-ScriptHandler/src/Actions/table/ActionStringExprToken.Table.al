table 20185 "Action String Expr. Token"
{
    Caption = 'Action String Expr. Token';
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
        field(3; "String Expr. ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'String Expr. ID';
            TableRelation = "Action String Expression".ID where("Script ID" = field("Script ID"));
        }
        field(4; Token; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Token';
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
        field(9; "Format String"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Format String';
        }
    }

    keys
    {
        key(K0; "Case ID", "Script ID", "String Expr. ID", Token)
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