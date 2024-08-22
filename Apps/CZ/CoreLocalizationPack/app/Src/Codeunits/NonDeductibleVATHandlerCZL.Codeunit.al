// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Calculation;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Purchases.Document;

codeunit 31146 "Non-Deductible VAT Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Non-Deductible VAT", 'OnBeforeGetNonDeductibleVATPctForPurchLine', '', false, false)]
    local procedure OnBeforeGetNonDeductibleVATPctForPurchLine(PurchaseLine: Record "Purchase Line"; var NonDeductibleVATPct: Decimal; var IsHandled: Boolean)
    var
        NonDeductibleVATCZL: Codeunit "Non-Deductible VAT CZL";
    begin
        if IsHandled then
            exit;
        if not NonDeductibleVATCZL.IsNonDeductibleVATEnabled() then
            exit;
        NonDeductibleVATPct := NonDeductibleVATCZL.GetNonDeductibleVATPct(PurchaseLine);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Non-Deductible VAT", 'OnBeforeGetNonDedVATPctForGenJnlLine', '', false, false)]
    local procedure OnBeforeGetNonDedVATPctForGenJnlLine(GenJournalLine: Record "Gen. Journal Line"; var NonDeductibleVATPct: Decimal; var IsHandled: Boolean)
    var
        NonDeductibleVATCZL: Codeunit "Non-Deductible VAT CZL";
    begin
        if IsHandled then
            exit;
        if not NonDeductibleVATCZL.IsNonDeductibleVATEnabled() then
            exit;
        NonDeductibleVATPct := NonDeductibleVATCZL.GetNonDeductibleVATPct(GenJournalLine);
        IsHandled := true;
    end;
}