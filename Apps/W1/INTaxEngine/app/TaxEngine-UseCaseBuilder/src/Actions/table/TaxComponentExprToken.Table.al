table 20286 "Tax Component Expr. Token"
{
    Caption = 'Tax Component Expr. Token';
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
        field(3; "Component Expr. ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Component Expr. ID';
            TableRelation = "Tax Component Expression".ID WHERE("Case ID" = Field("Case ID"));
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
        key(K0; "Case ID", "Script ID", "Component Expr. ID", Token)
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
    begin
        if "Value Type" = "Value Type"::Lookup then
            LookupEntityMgmt.DeleteLookup("Case ID", "Script ID", "Lookup ID");
    end;
}