codeunit 20348 "Posting Data Senstivity Mgmt."
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Class. Eval. Data Country", 'OnAfterClassifyCountrySpecificTables', '', false, false)]
    local procedure OnAfterClassifyPostingSpecificTables()
    begin
        ClassifyTablesToNormal();
        ClassifyCompanyConfidentialFields();
    end;

    local procedure ClassifyTablesToNormal()
    begin
        SetTableFieldsToNormal(Database::"Tax Insert Record");
        SetTableFieldsToNormal(Database::"Tax Insert Record Field");
        SetTableFieldsToNormal(Database::"Tax Posting Setup");
    end;

    local procedure SetTableFieldsToNormal(TableNo: Integer)
    var
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        DataClassificationMgt.SetTableFieldsToNormal(TableNo);
    end;

    local procedure ClassifyCompanyConfidentialFields()
    var
        TaxPostingKeysBuffer: Record "Tax Posting Keys Buffer";
        TransactionPostingBuffer: Record "Transaction Posting Buffer";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        SetTableFieldsToNormal(Database::"Tax Posting Keys Buffer");
        SetTableFieldsToNormal(Database::"Transaction Posting Buffer");
        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"Tax Posting Keys Buffer", TaxPostingKeysBuffer.FieldNo("Record ID"));
        DataClassificationMgt.SetFieldToCompanyConfidential(Database::"Transaction Posting Buffer", TransactionPostingBuffer.FieldNo("Tax Record ID"));
    end;
}