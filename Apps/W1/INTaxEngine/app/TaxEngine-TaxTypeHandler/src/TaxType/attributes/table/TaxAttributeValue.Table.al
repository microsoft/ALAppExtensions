table 20242 "Tax Attribute Value"
{
    Caption = 'Attribute Value';
    LookupPageID = "Tax Attribute Values";
    DrillDownPageID = "Tax Attribute Values";
    DataCaptionFields = Value;
    DataClassification = EndUserIdentifiableInformation;
    Access = Internal;
    Extensible = false;
    fields
    {
        field(1; "Attribute ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Attribute ID';
            NotBlank = true;
            TableRelation = "Tax Attribute".ID;
        }
        field(2; ID; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'ID';
        }
        field(3; Value; Text[30])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Value';
            trigger OnValidate();
            begin
                if xRec.Value = Value then
                    Exit;

                TestField(Value);
                if HasBeenUsed() then
                    if not Confirm(RenameUsedAttributeValueQst) then
                        Error('');

                CheckValueUniqueness(Rec, Value);
            end;
        }
        field(10; "Attribute Name"; Text[250])
        {
            Caption = 'Attribute Name';
            FieldClass = FlowField;
            CalcFormula = Lookup("Tax Attribute".Name WHERE(ID = Field("Attribute ID")));
        }
        field(11; Description; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(12; "Tax Type"; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Tax Type';
            TableRelation = "Tax Type".Code;
        }
    }

    keys
    {
        key(K0; "Tax Type", "Attribute ID", ID)
        {
            Clustered = True;
        }
        key(K1; Value)
        {
        }
    }

    var
        NameAlreadyExistsErr: Label 'The item attribute value with value ''%1'' already exists.', Comment = '%1 - arbitrary name';
        RenameUsedAttributeValueQst: Label 'This item attribute value has been assigned to at least one item.\\Are you sure you want to rename it?';

    procedure HasBeenUsed(): Boolean;
    var
        AttributeValueMapping: Record "Tax Attribute Value Mapping";
    begin
        AttributeValueMapping.SetRange("Attribute ID", "Attribute ID");
        AttributeValueMapping.SetRange("Attribute Value ID", ID);
        exit(not AttributeValueMapping.IsEmpty());
    end;

    local procedure CheckValueUniqueness(TaxAttributeValue: Record "Tax Attribute Value"; NameToCheck: Text[250]);
    begin
        TaxAttributeValue.SetRange("Attribute ID", "Attribute ID");
        TaxAttributeValue.SetFilter(ID, '<>%1', TaxAttributeValue.ID);
        TaxAttributeValue.SetRange(Value, NameToCheck);
        if not TaxAttributeValue.IsEmpty() then
            Error(NameAlreadyExistsErr, NameToCheck);
    end;
}