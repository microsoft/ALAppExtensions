table 20180 "Action Number Expr. Token"
{
    Caption = 'Action Number Expr. Token';
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
        field(3; "Numeric Expr. ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Numeric Expr. ID';
            TableRelation = "Action Number Expression".ID where("Case ID" = field("Case ID"));
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
        }
    }

    keys
    {
        key(K0; "Case ID", "Script ID", "Numeric Expr. ID", Token)
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