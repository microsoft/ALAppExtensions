table 20201 "Script Editor Line"
{
    Caption = 'Script Editor Line';
    DataClassification = EndUserIdentifiableInformation;
    Access = Internal;
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
        field(3; "Line No."; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Line No.';
        }
        field(4; Indent; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Indent';
        }
        field(5; "Action Type"; Enum "Action Type")
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Action Type';
        }
        field(6; "Action ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Action ID';
        }
        field(7; "Group Type"; Enum "Action Group Type")
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Group Type';
        }
        field(8; "Container Action ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Container Action ID';
        }
        field(9; "Container Type"; Enum "Container Action Type")
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Container Type';
        }
        field(10; "Has Errors"; Boolean)
        {
            FieldClass = FlowField;
            Caption = 'Has Errors';
        }
        field(12; "Action ID Filter"; Guid)
        {
            FieldClass = FlowFilter;
            Caption = 'Action ID Filter';
        }
    }

    keys
    {
        key(K0; "Case ID", "Script ID", "Line No.")
        {
            Clustered = True;
        }
    }
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

    trigger OnDelete()
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed("Case ID");
    end;
}