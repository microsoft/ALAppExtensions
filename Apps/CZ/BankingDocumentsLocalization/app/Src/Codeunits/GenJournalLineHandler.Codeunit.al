codeunit 31453 "Gen. Journal Line Handler CZB"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnSetJournalLineFieldsFromApplicationOnAfterFindFirstCustLedgEntryWithAppliesToID', '', false, false)]
    local procedure SetDimensionOnSetJournalLineFieldsFromApplicationOnAfterFindFirstCustLedgEntryWithAppliesToID(var GenJournalLine: Record "Gen. Journal Line"; CustLedgEntry: Record "Cust. Ledger Entry")
    begin
        if GenJournalLine.IsDimensionFromApplyEntryEnabledCZB() then
            GenJournalLine.Validate("Dimension Set ID", CustLedgEntry."Dimension Set ID");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnSetJournalLineFieldsFromApplicationOnAfterFindFirstCustLedgEntryWithAppliesToDocNo', '', false, false)]
    local procedure SetDimensionOnSetJournalLineFieldsFromApplicationOnAfterFindFirstCustLedgEntryWithAppliesToDocNo(var GenJournalLine: Record "Gen. Journal Line"; CustLedgEntry: Record "Cust. Ledger Entry")
    begin
        if GenJournalLine.IsDimensionFromApplyEntryEnabledCZB() then
            GenJournalLine.Validate("Dimension Set ID", CustLedgEntry."Dimension Set ID");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnSetJournalLineFieldsFromApplicationOnAfterFindFirstVendLedgEntryWithAppliesToID', '', false, false)]
    local procedure SetDimensionOnSetJournalLineFieldsFromApplicationOnAfterFindFirstVendLedgEntryWithAppliesToID(var GenJournalLine: Record "Gen. Journal Line"; VendLedgEntry: Record "Vendor Ledger Entry")
    begin
        if GenJournalLine.IsDimensionFromApplyEntryEnabledCZB() then
            GenJournalLine.Validate("Dimension Set ID", VendLedgEntry."Dimension Set ID");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnSetJournalLineFieldsFromApplicationOnAfterFindFirstVendLedgEntryWithAppliesToDocNo', '', false, false)]
    local procedure SetDimensionOnSetJournalLineFieldsFromApplicationOnAfterFindFirstVendLedgEntryWithAppliesToDocNo(var GenJournalLine: Record "Gen. Journal Line"; VendLedgEntry: Record "Vendor Ledger Entry")
    begin
        if GenJournalLine.IsDimensionFromApplyEntryEnabledCZB() then
            GenJournalLine.Validate("Dimension Set ID", VendLedgEntry."Dimension Set ID");
    end;
}