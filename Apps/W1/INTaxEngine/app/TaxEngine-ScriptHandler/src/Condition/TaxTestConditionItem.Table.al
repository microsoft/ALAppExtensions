table 20191 "Tax Test Condition Item"
{
    Caption = 'Condition Item';
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
        field(3; "Condition ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Condition ID';
            TableRelation = "Tax Test Condition".ID where("Case ID" = field("Case ID"));
        }
        field(4; ID; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'ID';
        }
        field(5; "Logical Operator"; Option)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Logical Operator';
            OptionMembers = " ",and,or;
        }
        field(6; "LHS Lookup ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'LHS Lookup ID';
            TableRelation = "Script Symbol Lookup".ID;
        }
        field(8; "Conditional Operator"; Enum "Conditional Operator")
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Conditional Operator';
        }
        field(9; "RHS Type"; Option)
        {
            DataClassification = SystemMetadata;
            Caption = 'RHS Type';
            OptionMembers = Constant,"Lookup";
        }
        field(10; "RHS Value"; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'RHS Value';
            trigger OnValidate();
            begin
                ValidateRHSValue();
            end;
        }
        field(11; "RHS Lookup ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'RHS Lookup ID';
            TableRelation = "Script Symbol Lookup".ID;
        }
    }

    keys
    {
        key(K0; "Case ID", "Script ID", "Condition ID", ID)
        {
            Clustered = True;
        }
    }

    local procedure ValidateRHSValue();
    var
        Datatype: Enum "Symbol Data Type";
        FieldOptionString: Text;
    begin
        if not IsNullGuid("LHS Lookup ID") then begin
            Datatype := LookupMgmt.GetLookupDatatype("Case ID", "Script ID", "LHS Lookup ID");
            FieldOptionString := ScriptDataTypeMgmt.GetLookupOptionString("Case ID", "Script ID", "LHS Lookup ID");
        end;

        ScriptDataTypeMgmt.CheckConstantDatatype("RHS Value", Datatype, FieldOptionString);
    end;

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
        if not IsNullGuid("LHS Lookup ID") then
            LookupEntityMgmt.DeleteLookup("Case ID", "Script ID", "LHS Lookup ID");
        if "RHS Type" = "RHS Type"::Lookup then
            LookupEntityMgmt.DeleteLookup("Case ID", "Script ID", "RHS Lookup ID");
    end;

    var
        LookupEntityMgmt: Codeunit "Lookup Entity Mgmt.";
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        LookupMgmt: Codeunit "Lookup Mgmt.";
}