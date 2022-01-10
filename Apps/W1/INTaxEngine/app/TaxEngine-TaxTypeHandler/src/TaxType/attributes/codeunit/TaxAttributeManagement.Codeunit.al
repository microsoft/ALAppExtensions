codeunit 20234 "Tax Attribute Management"
{
    procedure GetAttributeName(AttributeID: Integer): Text[30];
    var
        TaxAttribute: Record "Tax Attribute";
    begin
        TaxAttribute.SetRange(ID, AttributeID);
        if TaxAttribute.FindFirst() then
            exit(TaxAttribute.Name);
    end;

    procedure GetAttributeOptionValue(TaxType: Code[20]; AttributeID: Integer; var Value: Text[250]);
    var
        AttributeValue: Record "Tax Attribute Value";
        TaxAttribute: Record "Tax Attribute";
    begin
        TaxAttribute.SetFilter("Tax Type", '%1|%2', TaxType, '');
        TaxAttribute.SetRange(ID, AttributeID);
        TaxAttribute.FindFirst();
        if TaxAttribute.Type <> TaxAttribute.Type::Option then
            exit;

        AttributeValue.SetRange("Attribute ID", TaxAttribute.ID);
        if Page.RunModal(0, AttributeValue) = ACTION::LookupOK then
            Value := AttributeValue.Value;
    end;

#if not CLEAN20
    [Obsolete('Replaced by GetTaxRateAttributeLookupValue function with TaxTypeCode parameter.', '20.0')]
    procedure GetTaxRateAttributeLookupValue(AttributeName: Text; var Value: Text): Boolean
    var
        TaxRateSetup: Record "Tax Rate Column Setup";
        OldValue: Text;
        AttributeID: Integer;
    begin
        OldValue := Value;
        TaxRateSetup.SetRange("Column Name", AttributeName);
        TaxRateSetup.FindFirst();

        ValidateTaxRateSetup(TaxRateSetup);

        if TaxRateSetup."Linked Attribute ID" <> 0 then
            AttributeID := TaxRateSetup."Linked Attribute ID";

        if TaxRateSetup."Attribute ID" <> 0 then
            AttributeID := TaxRateSetup."Attribute ID";

        if AttributeID <> 0 then
            ManageAttributeLookup(AttributeID, Value);

        exit(OldValue <> Value);
    end;
#endif
    procedure GetTaxRateAttributeLookupValue(TaxTypeCode: Code[20]; AttributeName: Text; var Value: Text): Boolean
    var
        TaxRateSetup: Record "Tax Rate Column Setup";
        OldValue: Text;
        AttributeID: Integer;
    begin
        OldValue := Value;

        TaxRateSetup.SetRange("Tax Type", TaxTypeCode);
        TaxRateSetup.SetRange("Column Name", AttributeName);
        TaxRateSetup.FindFirst();

        ValidateTaxRateSetup(TaxRateSetup);

        if TaxRateSetup."Linked Attribute ID" <> 0 then
            AttributeID := TaxRateSetup."Linked Attribute ID";

        if TaxRateSetup."Attribute ID" <> 0 then
            AttributeID := TaxRateSetup."Attribute ID";

        if AttributeID <> 0 then
            ManageAttributeLookup(AttributeID, Value);

        exit(OldValue <> Value);
    end;

    local procedure ValidateTaxRateSetup(TaxRateSetup: Record "Tax Rate Column Setup")
    begin
        case TaxRateSetup."Column Type" of
            TaxRateSetup."Column Type"::Value:
                TaxRateSetup.TestField("Linked Attribute ID");
            TaxRateSetup."Column Type"::"Tax Attributes":
                TaxRateSetup.TestField("Attribute ID");
        end;
    end;

    local procedure ManageAttributeLookup(AttributeID: Integer; var Value: Text)
    var
        TaxAttribute: Record "Tax Attribute";
        TaxAttributeValue: Record "Tax Attribute Value";
        RecRef: RecordRef;
        RecordVariant: Variant;
    begin
        TaxAttribute.SetRange(ID, AttributeID);
        TaxAttribute.FindFirst();

        if not AttributeLookupAvailable(TaxAttribute) then
            exit;

        if TaxAttribute.Type = TaxAttribute.Type::Option then begin
            TaxAttributeValue.SetRange("Tax Type", TaxAttribute."Tax Type");
            TaxAttributeValue.SetRange("Attribute ID", TaxAttribute.ID);
            Commit();
            OpenAttributeValues(TaxAttributeValue, Value);
        end else begin
            RecRef.Open(TaxAttribute."Refrence Table ID");
            if RecRef.FindFirst() then;
            RecordVariant := RecRef;
            Commit();
            OpenTableLookupPage(TaxAttribute, RecordVariant, Value);
        end;
    end;

    local procedure OpenAttributeValues(var TaxAttributeValue: Record "Tax Attribute Value"; var Value: Text)
    begin
        if Page.RunModal(0, TaxAttributeValue) = ACTION::LookupOK then
            Value := TaxAttributeValue.Value;
    end;

    local procedure OpenTableLookupPage(var TaxAttribute: Record "Tax Attribute"; var RecordVariant: Variant; var Value: Text)
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        if Page.RunModal(TaxAttribute."Lookup Page ID", RecordVariant) = ACTION::LookupOK then begin
            clear(RecRef);
            RecRef.GetTable(RecordVariant);
            FldRef := RecRef.Field(TaxAttribute."Refrence Field ID");
            Value := Format(FldRef.Value());
        end;
    end;

    local procedure AttributeLookupAvailable(TaxAttribute: Record "Tax Attribute"): Boolean
    begin
        if TaxAttribute.Type = TaxAttribute.Type::Option then
            exit(true);

        if TaxAttribute."Refrence Table ID" = 0 then
            exit(false);

        TaxAttribute.TestField("Refrence Field ID");
        exit(true);
    end;

    procedure GetAttributeOptionIndex(TaxType: Code[20]; AttributeID: Integer; OptionText: Text[30]): Integer
    var
        TaxAttributeValue: Record "Tax Attribute Value";
    begin
        if OptionText = '' then
            exit(0);
        TaxAttributeValue.SetFilter("Tax Type", '%1|%2', TaxType, '');
        TaxAttributeValue.SetRange("Attribute ID", AttributeID);
        TaxAttributeValue.SetRange(Value, OptionText);
        TaxAttributeValue.FindFirst();
        exit(TaxAttributeValue.ID);
    end;

    procedure GetAttributeOptionText(TaxType: Code[20]; AttributeID: Integer; Index: Integer): Text[30]
    var
        TaxAttributeValue: Record "Tax Attribute Value";
    begin
        TaxAttributeValue.SetFilter("Tax Type", '%1|%2', TaxType, '');
        TaxAttributeValue.SetRange("Attribute ID", AttributeID);
        TaxAttributeValue.SetRange(id, Index);
        TaxAttributeValue.FindFirst();
        exit(TaxAttributeValue.Value);
    end;

    procedure UpdateTaxAttributeFactbox(Record: Variant)
    var
        RecordAttributeMapping: Record "Record Attribute Mapping";
        EntityAttributeMapping: Record "Entity Attribute Mapping";
        TaxAttribute: Record "Tax Attribute";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Record);
        if not RecRef.Find() then
            exit;
        if StrLen(Format(RecRef.RecordId(), 9)) = 0 then
            exit;
        EntityAttributeMapping.SetRange("Entity ID", RecRef.Number());
        EntityAttributeMapping.SetFilter("Mapping Field ID", '%1', 0);
        if EntityAttributeMapping.FindSet() then
            repeat
                TaxAttribute.Reset();
                TaxAttribute.SetRange(ID, EntityAttributeMapping."Attribute ID");
                TaxAttribute.FindFirst();

                RecordAttributeMapping.Reset();
                RecordAttributeMapping.SetRange("Tax Type", TaxAttribute."Tax Type");
                RecordAttributeMapping.SetRange("Attribute ID", EntityAttributeMapping."Attribute ID");
                RecordAttributeMapping.SetRange("Attribute Record ID", RecRef.RecordId());
                if not RecordAttributeMapping.FindSet() then begin
                    RecordAttributeMapping.Init();
                    RecordAttributeMapping."Tax Type" := TaxAttribute."Tax Type";
                    RecordAttributeMapping."Attribute ID" := EntityAttributeMapping."Attribute ID";
                    RecordAttributeMapping."Attribute Record ID" := RecRef.RecordId();
                    RecordAttributeMapping.Insert();
                end;
            until EntityAttributeMapping.Next() = 0;
    end;
}