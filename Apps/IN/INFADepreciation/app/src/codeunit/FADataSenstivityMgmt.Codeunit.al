codeunit 18639 "FA Data Senstivity Mgmt."
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Class. Eval. Data Country", 'OnAfterClassifyCountrySpecificTables', '', false, false)]
    local procedure OnAfterClassifyScriptSpecificTables()
    begin
        ClassifyTablesToNormal();
    end;

    local procedure ClassifyTablesToNormal()
    begin
        SetTableFieldsToNormal(Database::"FA Accounting Period Inc. Tax");
        SetTableFieldsToNormal(Database::"Fixed Asset Block");
        SetTableFieldsToNormal(Database::"Depreciation Book");
        SetTableFieldsToNormal(Database::"Fixed Asset Shift");
        SetTableFieldsToNormal(Database::"FA Depreciation Book");
        SetTableFieldsToNormal(Database::"FA Journal Line");
        SetTableFieldsToNormal(Database::"FA Ledger Entry");
        SetTableFieldsToNormal(Database::"Fixed Asset");
        SetTableFieldsToNormal(Database::"Gen. Journal Line");
    end;

    local procedure SetTableFieldsToNormal(TableNo: Integer)
    var
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        DataClassificationMgt.SetTableFieldsToNormal(TableNo);
    end;
}