table 20162 "Action Date To DateTime"
{
    Caption = 'Action Date To DateTime';
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
        field(5; "Date Value Type"; Option)
        {
            DataClassification = SystemMetadata;
            Caption = 'Date Value Type';
            OptionMembers = Constant,"Lookup";
        }
        field(6; "Date Value"; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Date Value';
        }
        field(7; "Date Lookup ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Date Lookup ID';
            TableRelation = "Script Symbol Lookup".ID;
        }
        field(10; "Time Value Type"; Option)
        {
            DataClassification = SystemMetadata;
            Caption = 'Time Value Type';
            OptionMembers = Constant,"Lookup";
        }
        field(11; "Time Value"; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Time Value';
        }
        field(12; "Time Lookup ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Time Lookup ID';
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
        if "Date Value Type" = "Date Value Type"::Lookup then
            LookupEntityMgmt.DeleteLookup("Case ID", "Script ID", "Date Lookup ID");
        if "Time Value Type" = "Time Value Type"::Lookup then
            LookupEntityMgmt.DeleteLookup("Case ID", "Script ID", "Time Lookup ID");
    end;
}