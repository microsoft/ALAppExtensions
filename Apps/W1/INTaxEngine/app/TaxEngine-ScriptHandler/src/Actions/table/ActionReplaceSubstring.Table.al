table 20181 "Action Replace Substring"
{
    Caption = 'Action Replace Substring';
    DataClassification = EndUserIdentifiableInformation;
    Access = Public;
    Extensible = true;
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
            Caption = 'Vairiable ID';
            TableRelation = "Script Variable".ID where("Script ID" = field("Script ID"));
        }
        field(5; "Substring Value Type"; Option)
        {
            DataClassification = SystemMetadata;
            Caption = 'Substring Value Type';
            OptionMembers = Constant,"Lookup";
        }
        field(6; "Substring Value"; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Substring Value';
        }
        field(7; "Substring Lookup ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Substring Lookup ID';
            TableRelation = "Script Symbol Lookup".ID;
        }
        field(8; "String Value Type"; Option)
        {
            DataClassification = SystemMetadata;
            Caption = 'String Value Type';
            OptionMembers = Constant,"Lookup";
        }
        field(9; "String Value"; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'String Value';
        }
        field(10; "String Lookup ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'String Lookup ID';
            TableRelation = "Script Symbol Lookup".ID;
        }
        field(11; "New String Value Type"; Option)
        {
            DataClassification = SystemMetadata;
            Caption = 'New String Value Type';
            OptionMembers = Constant,"Lookup";
        }
        field(12; "New String Value"; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'New String Value';
        }
        field(13; "New String Lookup ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'New String Lookup ID';
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
        EmptyGuid: Guid;

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
            LookupEntityMgmt.DeleteLookup(EmptyGuid, "Script ID", "Substring Lookup ID");
        if "String Value Type" = "String Value Type"::Lookup then
            LookupEntityMgmt.DeleteLookup(EmptyGuid, "Script ID", "String Lookup ID");
        if "New String Value Type" = "New String Value Type"::Lookup then
            LookupEntityMgmt.DeleteLookup(EmptyGuid, "Script ID", "New String Lookup ID");
    end;
}