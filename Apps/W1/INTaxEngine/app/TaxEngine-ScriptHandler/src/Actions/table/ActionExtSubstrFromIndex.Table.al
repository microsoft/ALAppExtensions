table 20165 "Action Ext. Substr. From Index"
{
    Caption = 'Action Ext. Substr. From Index';
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
        field(5; "String Value Type"; Option)
        {
            DataClassification = SystemMetadata;
            Caption = 'String Value Type';
            OptionMembers = Constant,"Lookup";
        }
        field(6; "String Value"; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'String Value';
        }
        field(7; "String Lookup ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'String Lookup ID';
            TableRelation = "Script Symbol Lookup".ID;
        }
        field(8; "Index Value Type"; Option)
        {
            DataClassification = SystemMetadata;
            Caption = 'Index Value Type';
            OptionMembers = Constant,"Lookup";
        }
        field(9; "Index Value"; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Index Value';
        }
        field(10; "Index Lookup ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Index Lookup ID';
            TableRelation = "Script Symbol Lookup".ID;
        }
        field(11; "Length Value Type"; Option)
        {
            DataClassification = SystemMetadata;
            Caption = 'Length Value Type';
            OptionMembers = Constant,"Lookup";
        }
        field(12; "Length Value"; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Length Value';
        }
        field(13; "Length Lookup ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Length Lookup ID';
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
        if "String Value Type" = "String Value Type"::Lookup then
            LookupEntityMgmt.DeleteLookup("Case ID", "Script ID", "String Lookup ID");
        if "Index Value Type" = "Index Value Type"::Lookup then
            LookupEntityMgmt.DeleteLookup("Case ID", "Script ID", "Index Lookup ID");
        if "Length Value Type" = "Length Value Type"::Lookup then
            LookupEntityMgmt.DeleteLookup("Case ID", "Script ID", "Length Lookup ID");
    end;
}