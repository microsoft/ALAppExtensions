table 20309 "Use Case Rate Column Relation"
{
    Caption = 'Use Case Rate Column Relation';
    DataClassification = EndUserIdentifiableInformation;
    Access = Public;
    Extensible = false;
    fields
    {
        field(1; "Case ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Case ID';
            TableRelation = "Tax Use Case".ID;
        }
        field(2; "ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'ID';
        }
        field(3; "Column ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Column ID';
        }
        field(4; "Switch Statement ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Switch Statement ID';
        }
    }
    keys
    {
        key(PK; "Case ID", ID)
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed("Case ID");
        if IsNullGuid(id) then
            ID := CreateGuid();
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

        if not IsNullGuid("Switch Statement ID") then
            SwitchStatementHelper.DeleteSwitchStatement("Case ID", "Switch Statement ID");
    end;

    var
        SwitchStatementHelper: Codeunit "Switch Statement Helper";
}