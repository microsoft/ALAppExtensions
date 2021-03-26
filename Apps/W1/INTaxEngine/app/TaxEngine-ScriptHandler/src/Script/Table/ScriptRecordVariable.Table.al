table 20202 "Script Record Variable"
{
    Caption = 'Script Record Variable';
    DataClassification = EndUserIdentifiableInformation;
    Access = Internal;
    Extensible = false;
    fields
    {
        field(1; "Script ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Script ID';
        }
        field(2; "Variable ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Variable ID';
        }
        field(3; ID; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'ID';
        }
        field(4; Name; Text[50])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Name';
        }
        field(5; Datatype; Enum "Symbol Data Type")
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Datatype';
        }
        field(6; "Case ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Case ID';
        }
    }
    keys
    {
        key(K0; "Case ID", "Script ID", "Variable ID", ID)
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