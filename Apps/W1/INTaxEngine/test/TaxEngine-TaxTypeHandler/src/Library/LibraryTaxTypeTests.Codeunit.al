codeunit 136810 "Library - Tax Type Tests"
{
    procedure CreateTaxType(TaxTypeCode: Code[20]; Desc: Text[80])
    var
        TaxType: Record "Tax Type";
    begin
        if TaxType.Get(TaxTypeCode) then
            exit;
        TaxType.Validate(Code, TaxTypeCode);
        TaxType.Validate(Description, Desc);
        TaxType.Insert(true);
    end;

    procedure CreateTaxEntntiy(TaxTypeCode: Code[20]; TableID: Integer; TableName: Text[30]; IsTransactionTable: Boolean)
    var
        TaxEntity: Record "Tax Entity";
    begin
        if TaxEntity.Get(TableID, TaxTypeCode) then
            exit;
        TaxEntity.Validate("Tax Type", TaxTypeCode);
        TaxEntity.Validate("Table ID", TableID);
        TaxEntity.Validate("Table Name", TableName);
        if IsTransactionTable then
            TaxEntity.Validate("Entity Type", TaxEntity."Entity Type"::Transaction)
        else
            TaxEntity.Validate("Entity Type", TaxEntity."Entity Type"::Master);
        TaxEntity.Insert(true);
    end;

    procedure CreateTaxAttribute(TaxTypeCode: Code[20]; AttributeName: Text[30]; Type: Option Option,Text,Integer,Decimal,Boolean,Date; RefTableID: Integer; RefFieldID: Integer; LookupPageID: Integer; GroupInTaxLedger: Boolean): Integer
    var
        TaxAttribute: Record "Tax Attribute";
    begin
        TaxAttribute.SetRange("Tax Type", TaxTypeCode);
        TaxAttribute.SetRange(Name, AttributeName);
        if TaxAttribute.FindFirst() then
            exit(TaxAttribute.ID);

        TaxAttribute.Init();
        TaxAttribute.Validate("Tax Type", TaxTypeCode);
        TaxAttribute.Validate(Name, AttributeName);
        TaxAttribute.Validate(Type, Type);
        TaxAttribute.Insert(true);
        TaxAttribute.Validate("Refrence Table ID", RefTableID);
        TaxAttribute.Validate("Refrence Field ID", RefFieldID);
        TaxAttribute.Validate("Lookup Page ID", LookupPageID);
        TaxAttribute.Modify(true);
        exit(TaxAttribute.ID);
    end;

    procedure CreateEntityAttributeMapping(AttributeID: Integer; TableID: Integer)
    var
        EntityAttributeMapping: Record "Entity Attribute Mapping";
    begin
        EntityAttributeMapping.Init();
        EntityAttributeMapping."Attribute ID" := AttributeID;
        EntityAttributeMapping."Entity ID" := TableID;
        EntityAttributeMapping.Insert(true);
    end;

    procedure CreateTaxAttributeValue(AttributeID: Integer; Index: Integer; Value: Text[30])
    var
        TaxAttributeValue: Record "Tax Attribute Value";
    begin
        TaxAttributeValue.SetRange("Attribute ID", AttributeID);
        if not TaxAttributeValue.IsEmpty() then
            exit;
        TaxAttributeValue.Init();
        TaxAttributeValue."Attribute ID" := AttributeID;
        TaxAttributeValue.Value := Value;
        TaxAttributeValue.ID := Index;
        TaxAttributeValue.Insert();
    end;

    procedure CreateTransactionValue(TaxTypeCode: Code[20]; CaseID: Guid; RecID: RecordId; ValueID: Integer; ValueType: Enum "Transaction Value Type"; Value: Text)
    var
        TaxTransactionValue: Record "Tax Transaction Value";
    begin
        TaxTransactionValue."Case ID" := CaseID;
        TaxTransactionValue."Tax Record ID" := RecID;
        TaxTransactionValue."Tax Type" := TaxTypeCode;
        TaxTransactionValue."Value ID" := ValueID;
        TaxTransactionValue."Value Type" := ValueType;
        TaxTransactionValue."Column Value" := Value;
        TaxTransactionValue.Insert(true);
    end;

    procedure CreateTaxRateColumnSetup(
        TaxTypeCode: Code[20];
        ColumnType: Enum "Column Type";
                        ID: Integer;
                        Sequence: Integer;
        Type: Option Option,Text,Integer,Decimal,Boolean,Date;
        LinkedAttrID: Integer;
        ColumnName: Text[30]): Integer
    var
        TaxRateColumnSetup: Record "Tax Rate Column Setup";
    begin
        TaxRateColumnSetup.SetRange("Tax Type", TaxTypeCode);
        TaxRateColumnSetup.SetRange("Column Type", ColumnType);
        TaxRateColumnSetup.SetRange("Attribute ID", ID);
        if TaxRateColumnSetup.FindFirst() then
            exit(TaxRateColumnSetup."Column ID");

        TaxRateColumnSetup.Init();
        TaxRateColumnSetup.Validate("Tax Type", TaxTypeCode);
        TaxRateColumnSetup.Validate("Attribute ID", ID);
        TaxRateColumnSetup.Validate(Sequence, Sequence);
        TaxRateColumnSetup.Validate("Column Type", ColumnType);
        TaxRateColumnSetup.Validate("Column Name", ColumnName);
        TaxRateColumnSetup.Validate(Type, Type);
        TaxRateColumnSetup.Validate("Linked Attribute ID", LinkedAttrID);
        TaxRateColumnSetup.Insert(true);
        exit(TaxRateColumnSetup."Column ID");
    end;

    procedure CreateComponent(TaxTypeCode: Code[20]; Name: Text[30]; RoundingDirection: Enum "Rounding Direction"; Precision: Decimal;
                                                                                            SkipPosting: Boolean): Integer
    var
        TaxComponent: Record "Tax Component";
    begin
        TaxComponent.SetRange("Tax Type", TaxTypeCode);
        TaxComponent.SetRange(Name, Name);
        if TaxComponent.FindFirst() then
            exit(TaxComponent.ID);

        TaxComponent.Validate("Tax Type", TaxTypeCode);
        TaxComponent.Validate(Name, Name);
        TaxComponent.ID := 10;
        TaxComponent.Validate(Direction, RoundingDirection);
        TaxComponent.Validate("Rounding Precision", Precision);
        TaxComponent."Skip Posting" := SkipPosting;
        TaxComponent.Insert(true);
        exit(TaxComponent.ID);
    end;
}