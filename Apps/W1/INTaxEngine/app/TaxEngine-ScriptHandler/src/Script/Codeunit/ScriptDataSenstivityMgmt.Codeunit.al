codeunit 20169 "Script Data Senstivity Mgmt."
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Class. Eval. Data Country", 'OnAfterClassifyCountrySpecificTables', '', false, false)]
    local procedure OnAfterClassifyScriptSpecificTables()
    begin
        ClassifyTablesToNormal();
    end;

    local procedure ClassifyTablesToNormal()
    begin
        SetTableFieldsToNormal(Database::"Action Comment");
        SetTableFieldsToNormal(Database::"Action Convert Case");
        SetTableFieldsToNormal(Database::"Action Date Calculation");
        SetTableFieldsToNormal(Database::"Action Extract Date Part");
        SetTableFieldsToNormal(Database::"Action Extract DateTime Part");
        SetTableFieldsToNormal(Database::"Action Ext. Substr. From Pos.");
        SetTableFieldsToNormal(Database::"Action Find Date Interval");
        SetTableFieldsToNormal(Database::"Action Loop Through Rec. Field");
        SetTableFieldsToNormal(Database::"Action Loop Through Records");
        SetTableFieldsToNormal(Database::"Action Message");
        SetTableFieldsToNormal(Database::"Action Number Calculation");
        SetTableFieldsToNormal(Database::"Action Round Number");
        SetTableFieldsToNormal(Database::"Action String Expr. Token");
    end;

    local procedure SetTableFieldsToNormal(TableNo: Integer)
    var
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        DataClassificationMgt.SetTableFieldsToNormal(TableNo);
    end;
}