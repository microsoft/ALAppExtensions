codeunit 18549 "IN Tax Data Sensitivity Mgmt."
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Class. Eval. Data Country", 'OnAfterClassifyCountrySpecificTables', '', false, false)]
    local procedure CreateSenstiviteDataTaxType()
    begin
        ClassifyCustLedgerEntry();
    end;

    local procedure ClassifyCustLedgerEntry()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
        TableNo: Integer;
    begin
        TableNo := Database::"Cust. Ledger Entry";
        DataClassificationMgt.SetTableFieldsToNormal(TableNo);
        DataClassificationMgt.SetFieldToPersonal(TableNo, CustLedgerEntry.FieldNo("TCS Nature of Collection"));
        DataClassificationMgt.SetFieldToPersonal(TableNo, CustLedgerEntry.FieldNo("Total TCS Including SHE CESS"));
    end;
}