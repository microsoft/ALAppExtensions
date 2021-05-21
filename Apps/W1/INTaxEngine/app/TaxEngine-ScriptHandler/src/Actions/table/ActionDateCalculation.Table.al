table 20161 "Action Date Calculation"
{
    Caption = 'Action Date Calculation';
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
        field(8; "Arithmetic operators"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Arithmetic operators';
            OptionMembers = plus,minus;
        }
        field(9; Duration; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Duration';
            OptionMembers = Days,Weeks,Months,Years;
        }
        field(10; "Number Value Type"; Option)
        {
            DataClassification = SystemMetadata;
            Caption = 'Number Value Type';
            OptionMembers = Constant,"Lookup";
        }
        field(11; "Number Value"; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Number Value Type';
        }
        field(12; "Number Lookup ID"; Guid)
        {
            DataClassification = SystemMetadata;
            TableRelation = "Script Symbol Lookup".ID;
            Caption = 'Number Lookup ID';
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
        if "Number Value Type" = "Number Value Type"::Lookup then
            LookupEntityMgmt.DeleteLookup("Case ID", "Script ID", "Number Lookup ID");
    end;
}