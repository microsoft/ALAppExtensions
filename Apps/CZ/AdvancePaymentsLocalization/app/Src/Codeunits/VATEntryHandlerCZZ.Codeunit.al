// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Reporting;
using Microsoft.Finance.VAT.Setup;

codeunit 31011 "VAT Entry Handler CZZ"
{
    [EventSubscriber(ObjectType::Table, Database::"VAT Entry", 'OnAfterCopyFromGenJnlLine', '', false, false)]
    local procedure VATEntryOnAfterCopyFromGenJnlLine(var VATEntry: Record "VAT Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        VATEntry."Advance Letter No. CZZ" := GenJournalLine."Adv. Letter No. (Entry) CZZ";
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Entry", 'OnAfterGetIsAdvanceEntryCZL', '', false, false)]
    local procedure IsAdvanceOnAfterGetIsAdvanceEntryCZL(VATEntry: Record "VAT Entry"; var AdvanceEntry: Boolean)
    begin
        AdvanceEntry := AdvanceEntry or (VATEntry."Advance Letter No. CZZ" <> '');
    end;

    [EventSubscriber(ObjectType::Report, Report::"Calc. and Post VAT Settl. CZL", 'OnBeforeGetVATAccountNo', '', false, false)]
    local procedure GetVATAccountNo(VATEntry: Record "VAT Entry"; VATPostingSetup: Record "VAT Posting Setup"; var VATAccountNo: Code[20]; var IsHandled: Boolean)
    begin
        if VATEntry."Advance Letter No. CZZ" = '' then
            exit;

        case VATEntry.Type of
            VATEntry.Type::Purchase:
                begin
                    VATPostingSetup.TestField("Purch. Adv.Letter VAT Acc. CZZ");
                    VATAccountNo := VATPostingSetup."Purch. Adv.Letter VAT Acc. CZZ";
                end;
            VATEntry.Type::Sale:
                begin
                    VATPostingSetup.TestField("Sales Adv. Letter VAT Acc. CZZ");
                    VATAccountNo := VATPostingSetup."Sales Adv. Letter VAT Acc. CZZ";
                end;
        end;
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Amount Line", 'OnInsertLineOnBeforeModify', '', false, false)]
    local procedure UpdateLCYAmountsOnInsertLineOnBeforeModify(var VATAmountLine: Record "VAT Amount Line"; FromVATAmountLine: Record "VAT Amount Line")
    begin
        VATAmountLine."VAT Base (LCY) CZL" += FromVATAmountLine."VAT Base (LCY) CZL";
        VATAmountLine."VAT Amount (LCY) CZL" += FromVATAmountLine."VAT Amount (LCY) CZL";
    end;
}
