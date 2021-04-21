table 20252 "Tax Rate Column Setup"
{
    Caption = 'Tax Rate Column Setup';
    DataClassification = EndUserIdentifiableInformation;
    Access = Public;
    Extensible = false;
    fields
    {
        field(1; "Tax Type"; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Tax Type';
            TableRelation = "Tax Type".Code;
        }
        field(2; "Column ID"; Integer)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Column ID';
            AutoIncrement = true;
        }
        field(3; "Column Name"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Column Name';
            trigger OnValidate()
            begin
                GetColumnName(false);
            end;

            trigger OnLookup()
            begin
                GetColumnName(true);
            end;
        }
        field(4; "Attribute ID"; Integer)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Attribute ID';
        }
        field(5; "Column Type"; Enum "Column Type")
        {
            Caption = 'Column Type';
            DataClassification = CustomerContent;
        }
        field(6; Sequence; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Sequence';
        }
        field(7; Type; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Type';
            InitValue = "Text";
            OptionMembers = Option,Text,Integer,Decimal,Boolean,Date;
            OptionCaption = 'Option,Text,Integer,Decimal,Boolean,Date';
        }
        field(9; "Linked Attribute ID"; Integer)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Linked Attribute ID';
        }
        field(10; "Visible On Interface"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Visible On Interface';
        }
        field(11; "Allow Blank"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Allow Blank';
        }
    }

    keys
    {
        key(PK; "Tax Type", "Column ID")
        {
            Clustered = true;
        }
        key(Sequence; Sequence) { }
        key(ColumnName; "Column Name") { }
    }
    trigger OnDelete()
    var
        TaxRate: Record "Tax Rate";
        TaxRateValue: Record "Tax Rate Value";
    begin
        TaxRateValue.SetRange("Tax Type", "Tax Type");
        TaxRateValue.SetRange("Column ID", "Column ID");
        if TaxRateValue.IsEmpty then
            exit;

        TaxRateValue.DeleteAll();

        TaxRateValue.Reset();
        TaxRateValue.SetRange("Tax Type", "Tax Type");
        if TaxRateValue.IsEmpty() then begin
            TaxRate.SetRange("Tax Type", "Tax Type");
            if not TaxRate.IsEmpty() then
                TaxRate.DeleteAll();
        end;
    end;

    trigger OnModify()
    begin
        UpdateTransactionKeys();
    end;

    procedure UpdateTransactionKeys()
    var
        TaxRate: Record "Tax Rate";
        TaxSetupMatrixMgmt: Codeunit "Tax Setup Matrix Mgmt.";
    begin
        TaxRate.SetRange("Tax Type", "Tax Type");
        if TaxRate.FindSet() then
            repeat
                TaxRate."Tax Setup ID" := TaxSetupMatrixMgmt.GenerateTaxSetupID(TaxRate.ID, TaxRate."Tax Type");
                TaxRate."Tax Rate ID" := TaxSetupMatrixMgmt.GenerateTaxRateID(TaxRate.ID, TaxRate."Tax Type");
                TaxRate.Modify();
                UpdateRateIDOnRateValue(TaxRate.ID, TaxRate."Tax Rate ID");
            until TaxRate.Next() = 0;
    end;

    local procedure UpdateRateIDOnRateValue(ConfigId: Guid; KeyValue: Text[2000])
    var
        TaxRateValue: Record "Tax Rate Value";
    begin
        //This will be used to find exact line of Tax Rate on calculation.
        TaxRateValue.SetRange("Config ID", ConfigId);
        if not TaxRateValue.IsEmpty() then
            TaxRateValue.ModifyAll("Tax Rate ID", KeyValue);
    end;

    local procedure GetColumnName(IsLookup: Boolean)
    var
        TaxComponent: Record "Tax Component";
        TaxAttribute: Record "Tax Attribute";
    begin
        ScriptSymbolsMgmt.SetContext("Tax Type", EmptyGuid, EmptyGuid);
        case "Column Type" of
            "Column Type"::Component:
                begin
                    if IsLookup then
                        ScriptSymbolsMgmt.OpenSymbolsLookup("Symbol Type"::Component, "Column Name", "Attribute ID", "Column Name")
                    else
                        ScriptSymbolsMgmt.SearchSymbol("Symbol Type"::Component, "Attribute ID", "Column Name");

                    if TaxComponent.Get("Tax Type", "Attribute ID") then
                        Type := TaxComponent.Type;
                end;
            "Column Type"::"Tax Attributes":
                begin
                    if IsLookup then
                        ScriptSymbolsMgmt.OpenSymbolsLookup("Symbol Type"::"Tax Attributes", "Column Name", "Attribute ID", "Column Name")
                    else
                        ScriptSymbolsMgmt.SearchSymbol("Symbol Type"::"Tax Attributes", "Attribute ID", "Column Name");

                    if TaxAttribute.Get("Tax Type", "Attribute ID") then
                        Type := TaxAttribute.Type;
                end;
        end;
    end;

    var
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        EmptyGuid: Guid;
}