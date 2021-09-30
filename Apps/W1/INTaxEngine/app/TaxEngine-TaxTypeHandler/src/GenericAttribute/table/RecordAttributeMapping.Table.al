table 20233 "Record Attribute Mapping"
{
    Caption = 'Record Attribtue Mapping';
    DataClassification = EndUserIdentifiableInformation;
    Access = Public;
    Extensible = false;
    fields
    {
        field(1; "Attribute Record ID"; RecordId)
        {
            DataClassification = CustomerContent;
            Caption = 'Attribute Record ID';
        }
        field(2; "Attribute ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Attribute ID';
        }
        field(5; "Tax Type"; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Tax Type';
            TableRelation = "Tax Type".Code;
        }
        field(4; "Attribute Value"; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Attribute Value';
            trigger OnValidate()
            var
                Attribute: Record "Tax Attribute";
            begin
                Attribute.SetFilter("Tax Type", '%1:%2', "Tax Type", '');
                Attribute.SetRange(ID, "Attribute ID");
                Attribute.FindFirst();
                ScriptDataTypeMgmt.FormatAttributeValue(Attribute.Type, "Attribute Value");

                if Attribute.Type = Attribute.Type::Option then
                    TaxTypeObjectHelper.SearchTaxOptionAttribute("Tax Type", "Attribute ID", "Attribute Value");
            end;

            trigger OnLookup()
            var
                AttributeManagement: Codeunit "Tax Attribute Management";
            begin
                AttributeManagement.GetAttributeOptionValue("Tax Type", "Attribute ID", "Attribute Value");
            end;
        }
    }

    keys
    {
        key(PK; "Attribute Record ID", "Attribute ID")
        {
            Clustered = true;
        }
    }

    procedure ValidateAttributeValue(ValueTxt: Text[250])
    var
        TaxAttribute: Record "Tax Attribute";
        XmlValue: Text;
        XmlValue2: Text;
    begin
        TaxAttribute.SetRange(ID, "Attribute ID");
        TaxAttribute.FindFirst();
        if TaxAttribute.Type = TaxAttribute.Type::Option then
            TaxTypeObjectHelper.SearchTaxOptionAttribute("Tax Type", "Attribute ID", ValueTxt);

        XmlValue2 := ValueTxt;
        XmlValue := ScriptDataTypeMgmt.ConvertLocalToXmlFormat(
            XmlValue2,
            UseCaseDataTypeMgmt.GetAttributeDataTypeToVariableDataType(TaxAttribute.Type));

        ValueTxt := CopyStr(XmlValue2, 1, 250);
        "Attribute Value" := CopyStr(XmlValue, 1, 250);
    end;

    procedure GetAttributeValue(ValueTxt: Text[250]): Text[250]
    var
        TaxAttribute: Record "Tax Attribute";
        LocalValue: Text;
    begin

        TaxAttribute.SetRange(ID, "Attribute ID");
        if not TaxAttribute.FindFirst() then
            exit;

        if TaxAttribute.Type = TaxAttribute.Type::Option then
            TaxTypeObjectHelper.SearchTaxOptionAttribute("Tax Type", "Attribute ID", ValueTxt);
        LocalValue := ScriptDataTypeMgmt.ConvertXmlToLocalFormat(
            ValueTxt,
            UseCaseDataTypeMgmt.GetAttributeDataTypeToVariableDataType(TaxAttribute.Type));
        exit(CopyStr(LocalValue, 1, 250));
    end;

    trigger OnInsert()
    begin
        TaxTypeObjectHelper.OnBeforeValidateIfUpdateIsAllowed(Rec."Tax Type");
    end;

    trigger OnDelete()
    begin
        TaxTypeObjectHelper.OnBeforeValidateIfUpdateIsAllowed(Rec."Tax Type");
    end;

    trigger OnModify()
    begin
        TaxTypeObjectHelper.OnBeforeValidateIfUpdateIsAllowed(Rec."Tax Type");
    end;

    var
        TaxTypeObjectHelper: Codeunit "Tax Type Object Helper";
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        UseCaseDataTypeMgmt: Codeunit "Use Case Data Type Mgmt.";
}