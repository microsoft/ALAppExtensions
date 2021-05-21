table 20308 "Use Case Component Calculation"
{
    Caption = 'Use Case Component Calculation';
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
        field(3; "Component ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Component ID';
        }
        field(4; "Formula ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Formula ID';
            TableRelation = "Tax Attribute".ID;
        }
        field(5; Sequence; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Sequence';
        }
    }
    keys
    {
        key(PK; "Case ID", ID)
        {
            Clustered = true;
        }
        key(Sequence; Sequence)
        {

        }
    }

    var
        UseCaseEntityMgmt: Codeunit "Use Case Entity Mgmt.";

    trigger OnInsert()
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed("Case ID");
        if IsNullGuid(ID) then
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

        if not IsNullGuid("Formula ID") then
            UseCaseEntityMgmt.DeleteTaxComponentExpression("Case ID", "Formula ID");
    end;
}