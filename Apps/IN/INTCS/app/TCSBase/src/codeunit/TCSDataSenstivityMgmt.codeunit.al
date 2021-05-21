codeunit 18813 "TCS Data Senstivity Mgmt."
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Class. Eval. Data Country", 'OnAfterClassifyCountrySpecificTables', '', false, false)]
    local procedure OnAfterClassifyScriptSpecificTables()
    begin
        ClassifyTablesToNormal();
    end;

    local procedure ClassifyTablesToNormal()
    begin
        SetTableFieldsToNormal(Database::"Allowed NOC");
        SetTableFieldsToNormal(Database::"Customer Concessional Code");
        SetTableFieldsToNormal(Database::"T.C.A.N. No.");
        SetTableFieldsToNormal(Database::"TCS Entry");
        SetTableFieldsToNormal(Database::"TCS Nature Of Collection");
        SetTableFieldsToNormal(Database::"TCS Posting Setup");
        SetTableFieldsToNormal(Database::"TCS Setup");
        SetTableFieldsToNormal(Database::"Sales Header");
        SetTableFieldsToNormal(Database::"Sales Line");
        SetTableFieldsToNormal(Database::"TCS Challan Register");
        SetTableFieldsToNormal(Database::"TCS Journal Batch");
        SetTableFieldsToNormal(Database::"TCS Journal Line");
        SetTableFieldsToNormal(Database::"TCS Journal Template");
    end;

    local procedure SetTableFieldsToNormal(TableNo: Integer)
    var
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        DataClassificationMgt.SetTableFieldsToNormal(TableNo);
    end;
}