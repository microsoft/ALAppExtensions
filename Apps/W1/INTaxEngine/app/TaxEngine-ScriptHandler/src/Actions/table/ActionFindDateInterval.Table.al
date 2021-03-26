table 20167 "Action Find Date Interval"
{
    Caption = 'Action Find Date Interval';
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
            TableRelation = "Script Variable".ID where("Case ID" = field("Case ID"), "Script ID" = field("Script ID"));
        }
        field(4; "Date1 Value Type"; Option)
        {
            DataClassification = SystemMetadata;
            Caption = 'Date1 Value Type';
            OptionMembers = Constant,"Lookup";
        }
        field(5; "Date1 Value"; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Date1 Value';
        }
        field(6; "Date1 Lookup ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Date1 Lookup ID';
            TableRelation = "Script Symbol Lookup".ID;
        }
        field(7; "Date2 Value Type"; Option)
        {
            DataClassification = SystemMetadata;
            Caption = 'Date2 Value Type';
            OptionMembers = Constant,"Lookup";
        }
        field(8; "Date2 Value"; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Date2 Value';
        }
        field(9; "Date2 Lookup ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Date2 Lookup ID';
            TableRelation = "Script Symbol Lookup".ID;
        }
        field(10; Inverval; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Interval';
            OptionMembers = Days,Hours,Minutes;
        }
        field(11; "Case ID"; Guid)
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
        if "Date1 Value Type" = "Date1 Value Type"::Lookup then
            LookupEntityMgmt.DeleteLookup("Case ID", "Script ID", "Date1 Lookup ID");
        if "Date2 Value Type" = "Date2 Value Type"::Lookup then
            LookupEntityMgmt.DeleteLookup("Case ID", "Script ID", "Date2 Lookup ID");
    end;
}