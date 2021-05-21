codeunit 20239 "Tax Type Data Senstivity Mgmt."
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Class. Eval. Data Country", 'OnAfterClassifyCountrySpecificTables', '', false, false)]
    local procedure OnAfterClassifyTaxTypeSpecificTables()
    begin
        ClassifyTablesToNormal();
    end;

    local procedure ClassifyTablesToNormal()
    begin
        SetTableFieldsToNormal(Database::"Tax Attribute");
        SetTableFieldsToNormal(Database::"Tax Attribute Value");
        SetTableFieldsToNormal(Database::"Tax Component");
        SetTableFieldsToNormal(Database::"Tax Rate Column Setup");
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
}