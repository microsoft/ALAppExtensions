table 20166 "Action Ext. Substr. From Pos."
{
    Caption = 'Action Ext. Substr. From Pos.';
    DataClassification = EndUserIdentifiableInformation;
    Access = Public;
    Extensible = false;
    fields
    {
        field(1; "Script ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Script ID';
        }
        field(2; ID; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'ID';
        }
        field(3; "Variable ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Variable ID';
            TableRelation = "Script Variable".ID where("Script ID" = field("Script ID"));
        }
        field(4; "String Value Type"; Option)
        {
            DataClassification = SystemMetadata;
            Caption = 'String Value Type';
            OptionMembers = Constant,"Lookup";
        }
        field(5; "String Value"; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'String Value';
        }
        field(6; "String Lookup ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'String Lookup ID';
            TableRelation = "Script Symbol Lookup".ID;
        }
        field(7; Position; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Position';
            OptionMembers = start,end;
        }
        field(10; "Length Value Type"; Option)
        {
            DataClassification = SystemMetadata;
            Caption = 'Length Value Type';
            OptionMembers = Constant,"Lookup";
        }
        field(11; "Length Value"; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Length Value';
        }
        field(12; "Length Lookup ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Length Lookup ID';
            TableRelation = "Script Symbol Lookup".ID;
        }
        field(13; "Case ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Case ID';
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
        if "String Value Type" = "String Value Type"::Lookup then
            LookupEntityMgmt.DeleteLookup("Case ID", "Script ID", "String Lookup ID");
        if "Length Value Type" = "Length Value Type"::Lookup then
            LookupEntityMgmt.DeleteLookup("Case ID", "Script ID", "Length Lookup ID");
    end;
}