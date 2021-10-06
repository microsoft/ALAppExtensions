table 20234 "Tax Attribute Value Mapping"
{
    Caption = 'Tax Attribute Value Mapping';
    DataClassification = EndUserIdentifiableInformation;
    Access = Internal;
    Extensible = false;
    fields
    {
        field(1; "Table ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Table ID';
        }
        field(2; "No."; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'No.';
        }
        field(3; "Attribute ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Attribute ID';
            TableRelation = "Tax Attribute";
        }
        field(4; "Attribute Value ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Attribute Value ID';
            TableRelation = "Tax Attribute Value".ID;
        }
    }

    keys
    {
        key(K0; "Table ID", "No.", "Attribute ID")
        {
            Clustered = True;
        }
        key(K1; "Attribute ID", "Attribute Value ID")
        {
        }
    }
    trigger OnDelete();
    var
        GenericAttribute: Record "Tax Attribute";
        GenericAttributeValue: Record "Tax Attribute Value";
        AttributeValueMapping: Record "Tax Attribute Value Mapping";
        TaxTypeObjectHelper: Codeunit "Tax Type Object Helper";
    begin
        GenericAttribute.SetRange(ID, "Attribute ID");
        GenericAttribute.FindFirst();

        TaxTypeObjectHelper.OnBeforeValidateIfUpdateIsAllowed(GenericAttribute."Tax Type");

        if GenericAttribute.Type = GenericAttribute.Type::Option then
            Exit;

        if not GenericAttributeValue.GET("Attribute ID", "Attribute Value ID") then
            Exit;

        AttributeValueMapping.SetRange("Attribute ID", "Attribute ID");
        AttributeValueMapping.SetRange("Attribute Value ID", "Attribute Value ID");
        if AttributeValueMapping.Count() <> 1 then
            Exit;

        AttributeValueMapping := Rec;
        if not AttributeValueMapping.IsEmpty() then
            GenericAttributeValue.Delete();
    end;
}