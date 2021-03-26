table 20144 "Script Symbol Lookup"
{
    Caption = 'Script Symbol Lookup';
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
        field(3; ID; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'ID';
        }
        field(4; "Source Type"; Enum "Symbol Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Source Type';
            trigger OnValidate();
            begin
                if ("Source Type" <> "Source Type"::Table) and (not IsNullGuid("Table Filter ID")) then
                    EntityMgmt.DeleteTableFilters("Case ID", "Script ID", "Table Filter ID");
            end;
        }

        field(5; "Source ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Source ID';
        }
        field(6; "Source Field ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Source Field ID';
        }
        field(7; "Table Filter ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Table Filter ID';
        }
        field(8; "Table Method"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Table Method';
            OptionMembers = " ",First,Last,"Sum","Average","Min","Max","Count","Exist";
        }
        field(9; "Table Sorting ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Table Sorting ID';
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
        EntityMgmt: Codeunit "Lookup Entity Mgmt.";

    trigger OnInsert();
    var
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed("Case ID");
    end;

    trigger OnModify();
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

        if not IsNullGuid("Table Filter ID") then
            EntityMgmt.DeleteTableFilters("Case ID", "Script ID", "Table Filter ID");
    end;
}