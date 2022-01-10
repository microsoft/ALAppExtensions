codeunit 20239 "Tax Type Data Senstivity Mgmt."
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Class. Eval. Data Country", 'OnAfterClassifyCountrySpecificTables', '', false, false)]
    local procedure OnAfterClassifyTaxTypeSpecificTables()
    begin
        ClassifyTablesToNormal();
        ClassifyCompanyConfidentialFields();
    end;

    local procedure ClassifyTablesToNormal()
    begin
        SetTableFieldsToNormal(Database::"Tax Attribute");
        SetTableFieldsToNormal(Database::"Tax Attribute Value");
        SetTableFieldsToNormal(Database::"Tax Component");
        SetTableFieldsToNormal(Database::"Tax Rate Column Setup");
        SetTableFieldsToNormal(Database::"Tax Rate Filter");
        SetTableFieldsToNormal(Database::"Tax Acc. Period Setup");
        SetTableFieldsToNormal(Database::"Tax Entity");
        SetTableFieldsToNormal(Database::"Tax Type");
    end;

    local procedure SetTableFieldsToNormal(TableNo: Integer)
    var
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        DataClassificationMgt.SetTableFieldsToNormal(TableNo);
    end;

    local procedure ClassifyCompanyConfidentialFields()
    var
        TaxTransactionValue: Record "Tax Transaction Value";
        RecordAttributeMapping: Record "Record Attribute Mapping";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        SetTableFieldsToNormal(Database::"Tax Transaction Value");
        SetTableFieldsToNormal(Database::"Record Attribute Mapping");
        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"Tax Transaction Value", TaxTransactionValue.FieldNo("Tax Record ID"));
        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"Record Attribute Mapping", RecordAttributeMapping.FieldNo("Attribute Record ID"));
    end;
}