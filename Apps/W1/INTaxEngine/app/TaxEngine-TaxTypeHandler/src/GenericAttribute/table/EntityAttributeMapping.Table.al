table 20232 "Entity Attribute Mapping"
{
    Caption = 'Entity Attribute Mapping';
    DataClassification = EndUserIdentifiableInformation;
    Access = Public;
    Extensible = false;
    fields
    {
        field(1; "Attribute ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Attribute ID';
        }
        field(2; "Entity ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Entity ID';
        }
        field(3; "Attribute Name"; Text[2000])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Attribute Name';
        }
        field(4; "Entity Name"; Text[30])
        {
            DataClassification = SystemMetadata;
            Caption = 'Entity Name';
            trigger OnValidate()
            var
                GenericAttribute: Record "Tax Attribute";
            begin
                GenericAttribute.SetRange(ID, "Attribute ID");
                GenericAttribute.FindFirst();
                if GenericAttribute."Tax Type" = '' then
                    AppObjectHelper.SearchObject(ObjectType::Table, "Entity ID", "Entity Name")
                else
                    TaxTypeObjectHelper.SearchTaxTypeTable("Entity ID", "Entity Name", GenericAttribute."Tax Type", false);
            end;

            trigger OnLookup()
            var
                GenericAttribute: Record "Tax Attribute";
            begin
                GenericAttribute.SetRange(ID, "Attribute ID");
                GenericAttribute.FindFirst();
                if GenericAttribute."Tax Type" = '' then
                    AppObjectHelper.OpenObjectLookup(ObjectType::Table, "Entity Name", "Entity ID", "Entity Name")
                else
                    TaxTypeObjectHelper.OpenTaxTypeTableLookup("Entity ID", "Entity Name", "Entity Name", GenericAttribute."Tax Type");
            end;
        }
        field(5; ID; Guid)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'ID';
        }
        field(6; "Mapping Field ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Mapping Field ID';
        }
        field(7; "Mapping Field Name"; Text[30])
        {
            DataClassification = SystemMetadata;
            Caption = 'Mapping Field Name';
            trigger OnValidate()
            var
                GenericAttribute: Record "Tax Attribute";
            begin
                GetTaxAttribute(GenericAttribute);
                AppObjectHelper.SearchTableFieldOfType("Entity ID", "Mapping Field ID", "Mapping Field Name", DataTypeMgmt.GetAttributeDataTypeToVariableDataType(GenericAttribute.Type));
            end;

            trigger OnLookup()
            var
                GenericAttribute: Record "Tax Attribute";
                DataType: Text;
            begin
                GetTaxAttribute(GenericAttribute);

                DataType := Format(GenericAttribute.Type);
                AppObjectHelper.OpenFieldLookupOfType("Entity ID", "Mapping Field ID", "Mapping Field Name", "Mapping Field Name", DataTypeMgmt.GetAttributeDataTypeToVariableDataType(GenericAttribute.Type));
            end;
        }
    }

    keys
    {
        key(PK; "Attribute ID", "Entity ID", ID)
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        GenericAttribute: Record "Tax Attribute";
    begin
        GetTaxAttribute(GenericAttribute);
        TaxTypeObjectHelper.OnBeforeValidateIfUpdateIsAllowed(GenericAttribute."Tax Type");
        "Attribute Name" := GenericAttribute.Name;

        ID := CreateGuid();
    end;

    trigger OnModify()
    var
        GenericAttribute: Record "Tax Attribute";
    begin
        GetTaxAttribute(GenericAttribute);
        TaxTypeObjectHelper.OnBeforeValidateIfUpdateIsAllowed(GenericAttribute."Tax Type");
    end;

    trigger OnDelete()
    var
        GenericAttribute: Record "Tax Attribute";
    begin
        GetTaxAttribute(GenericAttribute);
        TaxTypeObjectHelper.OnBeforeValidateIfUpdateIsAllowed(GenericAttribute."Tax Type");
    end;

    local procedure GetTaxAttribute(var GenericAttribute: Record "Tax Attribute")
    begin
        GenericAttribute.SetRange(id, "Attribute ID");
        GenericAttribute.FindFirst();
    end;

    var
        DataTypeMgmt: Codeunit "Use Case Data Type Mgmt.";
        AppObjectHelper: Codeunit "App Object Helper";
        TaxTypeObjectHelper: Codeunit "Tax Type Object Helper";
}