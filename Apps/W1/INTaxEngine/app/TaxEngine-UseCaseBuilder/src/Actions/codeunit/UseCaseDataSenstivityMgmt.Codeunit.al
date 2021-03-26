codeunit 20285 "Use Case Data Senstivity Mgmt."
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Class. Eval. Data Country", 'OnAfterClassifyCountrySpecificTables', '', false, false)]
    local procedure OnAfterClassifyUseCaseSpecificTables()
    begin
        ClassifyTablesToNormal();
    end;

    local procedure ClassifyTablesToNormal()
    begin
        SetTableFieldsToNormal(Database::"Switch Case");
        SetTableFieldsToNormal(Database::"Tax Table Relation");
        SetTableFieldsToNormal(Database::"Use Case Tree Node");
        SetTableFieldsToNormal(Database::"Tax Use Case");
        SetTableFieldsToNormal(Database::"Use Case Component Calculation");
    end;

    local procedure SetTableFieldsToNormal(TableNo: Integer)
    var
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        DataClassificationMgt.SetTableFieldsToNormal(TableNo);
    end;
}