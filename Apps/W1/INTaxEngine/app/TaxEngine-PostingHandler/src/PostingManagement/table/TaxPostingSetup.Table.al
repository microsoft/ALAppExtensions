table 20338 "Tax Posting Setup"
{
    Caption = 'Tax Posting Setup';
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
        field(4; "Table ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Table ID';
        }
        field(5; "Field ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Field ID';
        }
        field(6; "Accounting Impact"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Accounting Impact';
            OptionMembers = Debit,Credit;
            OptionCaption = 'Debit,Credit';
        }
        field(7; "Switch Statement ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Switch Statement ID';
        }
        field(9; "Table Filter ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Table Filter ID';
        }
        field(10; "Reverse Charge"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Reverse Charge';
            trigger OnValidate()
            begin
                if not "Reverse Charge" then
                    Validate("Reverse Charge Field ID", 0);
            end;
        }
        field(11; "Reverse Charge Field ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Reverse Charge Field ID';
            trigger OnValidate()
            var
                LookupEntityMgmt: Codeunit "Lookup Entity Mgmt.";
            begin
                if "Reverse Charge Field ID" = 0 then begin
                    if not IsNullGuid("Reversal Account Lookup ID") then
                        LookupEntityMgmt.DeleteLookup("Case ID", EmptyGuid, "Reversal Account Lookup ID");
                    "Reversal Account Source Type" := "Reversal Account Source Type"::Field;
                end;
            end;
        }
        field(12; "Account Source Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Account Source Type';
            OptionMembers = "Field","Lookup";
            OptionCaption = 'Field,Lookup';
            trigger OnValidate()
            begin
                if ("Account Source Type" = "Account Source Type"::Lookup) then
                    ClearTableFilers()
                else
                    ClearLookup("Account Lookup ID");
            end;
        }
        field(13; "Reversal Account Source Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Reversal Account Source Type';
            OptionMembers = "Field","Lookup";
            OptionCaption = 'Field,Lookup';
            trigger OnValidate()
            begin
                if ("Account Source Type" = "Account Source Type"::Field) then
                    ClearLookup("Reversal Account Lookup ID");
            end;
        }
        field(14; "Account Lookup ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Account LookupID';
        }
        field(15; "Reversal Account Lookup ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Reversal Account LookupID';
        }
    }

    keys
    {
        key(PK; "Case ID", ID)
        {
            Clustered = true;
        }
        key(ComponentKey; "Component ID")
        {

        }
    }

    var
        SwitchStatementHelper: Codeunit "Switch Statement Helper";
        LookupEntityMgmt: Codeunit "Lookup Entity Mgmt.";
        EmptyGuid: Guid;

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
        UseCase: Record "Tax Use Case";
        ScriptSymbolStore: Codeunit "Script Symbol Store";
    begin
        ScriptSymbolStore.OnBeforeValidateIfUpdateIsAllowed("Case ID");

        if not IsNullGuid("Switch Statement ID") then
            SwitchStatementHelper.DeleteSwitchStatement("Case ID", "Switch Statement ID");

        if not IsNullGuid("Table Filter ID") then
            LookupEntityMgmt.DeleteTableFilters("Case ID", EmptyGuid, "Table Filter ID");

        if not IsNullGuid("Account Lookup ID") then begin
            UseCase.Get("Case ID");
            LookupEntityMgmt.DeleteLookup("Case ID", EmptyGuid, "Account Lookup ID");
        end;

        if not IsNullGuid("Reversal Account Lookup ID") then begin
            UseCase.Get("Case ID");
            LookupEntityMgmt.DeleteLookup("Case ID", EmptyGuid, "Reversal Account Lookup ID");
        end;
    end;

    local procedure ClearTableFilers()
    begin
        if not IsNullGuid("Table Filter ID") then
            LookupEntityMgmt.DeleteTableFilters("Case ID", EmptyGuid, "Table Filter ID");
    end;

    local procedure ClearLookup(LookupID: Guid)
    begin
        if not IsNullGuid(LookupID) then
            LookupEntityMgmt.DeleteLookup("Case ID", EmptyGuid, LookupID);
    end;
}