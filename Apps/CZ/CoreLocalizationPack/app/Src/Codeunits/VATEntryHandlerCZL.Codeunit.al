// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Ledger;

using Microsoft.Finance.GeneralLedger.Journal;

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
#if not CLEAN22
#pragma warning disable AL0432
        VATEntry."VAT Date CZL" := GenJournalLine."VAT Date CZL";
#pragma warning restore AL0432
#endif
        VATEntry."Original Doc. VAT Date CZL" := GenJournalLine."Original Doc. VAT Date CZL";
        VATEntry."EU 3-Party Intermed. Role CZL" := GenJournalLine."EU 3-Party Intermed. Role CZL";
        VATEntry."VAT Delay CZL" := GenJournalLine."VAT Delay CZL";
        VATEntry."Registration No. CZL" := GenJournalLine."Registration No. CZL";
        VATEntry."Tax Registration No. CZL" := GenJournalLine."Tax Registration No. CZL";
        if VATEntry."Bill-to/Pay-to No." = '' then
            VATEntry."Bill-to/Pay-to No." := GenJournalLine."Original Doc. Partner No. CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VAT Entry - Edit", 'OnBeforeVATEntryModify', '', false, false)]
    local procedure EditEU3PartyIntermedRoleOnBeforeVATEntryModify(var VATEntry: Record "VAT Entry"; FromVATEntry: Record "VAT Entry")
    begin
        VATEntry."EU 3-Party Intermed. Role CZL" := FromVATEntry."EU 3-Party Intermed. Role CZL";
#if not CLEAN22
#pragma warning disable AL0432
        VATEntry."VAT Date CZL" := FromVATEntry."VAT Date CZL";
#pragma warning restore AL0432
#endif
    end;
}
