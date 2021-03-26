table 20284 "Switch Statement"
{
    Caption = 'Switch Statement';
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
        field(2; "ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'ID';
        }
    }

    keys
    {
        key(PK; "Case ID", ID)
        {
            Clustered = true;
        }
    }

    var
        SwitchCase: Record "Switch Case";

    trigger OnInsert()
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

        SwitchCase.Reset();
        SwitchCase.SetRange("Case ID", "Case ID");
        SwitchCase.SetRange("Switch Statement ID", ID);
        SwitchCase.DeleteAll(true);
    end;
}