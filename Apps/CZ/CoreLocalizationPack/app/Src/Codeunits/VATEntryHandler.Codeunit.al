codeunit 11741 "VAT Entry Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"VAT Entry", 'OnBeforeValidateEvent', 'EU 3-Party Trade', false, false)]
    local procedure UpdateEU3PartyIntermedRoleOnBeforeEU3PartyTradeValidate(var Rec: Record "VAT Entry")
    begin
        if not Rec."EU 3-Party Trade" then
            Rec."EU 3-Party Intermed. Role CZL" := false;
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Entry", 'OnAfterCopyFromGenJnlLine', '', false, false)]
    local procedure UpdateFieldsOnAfterCopyFromGenJnlLine(var VATEntry: Record "VAT Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        VATEntry."VAT Date CZL" := GenJournalLine."VAT Date CZL";
        VATEntry."Original Doc. VAT Date CZL" := GenJournalLine."Original Doc. VAT Date CZL";
        VATEntry."EU 3-Party Intermed. Role CZL" := GenJournalLine."EU 3-Party Intermed. Role CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VAT Entry - Edit", 'OnBeforeVATEntryModify', '', false, false)]
    local procedure EditEU3PartyIntermedRoleOnBeforeVATEntryModify(var VATEntry: Record "VAT Entry"; FromVATEntry: Record "VAT Entry")
    begin
        VATEntry."EU 3-Party Intermed. Role CZL" := FromVATEntry."EU 3-Party Intermed. Role CZL";
    end;
}