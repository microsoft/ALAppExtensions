table 20335 "Tax Insert Record Field"
{
    Caption = 'Tax Insert Record Field';
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
        field(2; "Insert Record ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Insert Record ID';
            TableRelation = "Tax Insert Record".ID WHERE("Case ID" = Field("Case ID"));
        }
        field(3; "Field ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Field ID';
            NotBlank = true;
            TableRelation = Field."No." WHERE(TableNo = Field("Table ID"));
        }
        field(4; "Value Type"; Option)
        {
            DataClassification = SystemMetadata;
            Caption = 'Value Type';
            OptionMembers = Constant,"Lookup";
        }
        field(5; Value; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Value';
        }
        field(6; "Lookup ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Lookup ID';
            TableRelation = "Script Symbol Lookup".ID;
        }
        field(7; "Table ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Table ID';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Table));
        }
        field(8; "Run Validate"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Run Validate';
        }
        field(9; "Sequence No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Sequence No.';
            BlankZero = true;
        }
        field(10; "Column No."; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Column No.';
            AutoIncrement = true;
        }
        field(11; "Column Name"; Text[200])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Column Name';
        }
        field(12; "Script ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Script ID';
        }
        field(13; "Reverse Sign"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Reverse Sign';
        }
    }

    keys
    {
        key(K0; "Case ID", "Script ID", "Insert Record ID", "Field ID", "Column No.")
        {
            Clustered = True;
        }
        key(UI; "Sequence No.", "Field ID")
        {

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