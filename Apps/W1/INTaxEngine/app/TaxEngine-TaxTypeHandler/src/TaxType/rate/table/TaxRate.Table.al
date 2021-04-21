table 20251 "Tax Rate"
{
    Caption = 'Tax Configuration';
    DataClassification = EndUserIdentifiableInformation;
    Access = Public;
    Extensible = false;
    fields
    {
        field(1; ID; Guid)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'ID';
        }
        field(5; "Tax Type"; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Tax Type';
            TableRelation = "Tax Type".Code;
        }
        field(7; "Tax Setup ID"; Text[2000])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Tax Set ID';
        }
        field(8; "Tax Rate ID"; Text[2000])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Tax Rate ID';
        }
    }

    keys
    {
        key(PK; "Tax Type", ID)
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        ID := CreateGuid();
    end;

    trigger OnDelete()
    var
        TaxConfigurationValue: Record "Tax Rate Value";
    begin
        TaxConfigurationValue.SetRange("Config ID", ID);
        if not TaxConfigurationValue.IsEmpty() then
            TaxConfigurationValue.DeleteAll();
    end;
}