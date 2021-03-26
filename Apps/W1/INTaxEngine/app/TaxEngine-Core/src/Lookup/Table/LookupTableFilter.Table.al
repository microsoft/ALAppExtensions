table 20142 "Lookup Table Filter"
{
    Caption = 'Lookup Table Filter';
    DataClassification = CustomerContent;
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
        field(3; "ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'ID';
        }
        field(4; "Table ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Table ID';
        }
        field(5; "Attribtue ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Attribute ID';
        }
    }

    keys
    {
        key(PK; "Case ID", "Script ID", ID)
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed("Case ID");
    end;

    trigger OnDelete()
    var
        LookupFieldFilter: Record "Lookup Field Filter";
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed("Case ID");

        LookupFieldFilter.SetRange("Case ID", "Case ID");
        LookupFieldFilter.SetRange("Table Filter ID", ID);
        if not LookupFieldFilter.IsEmpty() then
            LookupFieldFilter.DeleteAll(true);
    end;
}