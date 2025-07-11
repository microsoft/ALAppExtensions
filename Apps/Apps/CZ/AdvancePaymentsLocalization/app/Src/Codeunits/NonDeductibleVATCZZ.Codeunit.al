// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.Enums;

codeunit 31157 "Non-Deductible VAT CZZ"
{
    var
        NonDeductibleVATCZL: Codeunit "Non-Deductible VAT CZL";

    procedure IsNonDeductibleVATEnabled(): Boolean
    var
        VATSetup: Record "VAT Setup";
    begin
        if not NonDeductibleVATCZL.IsNonDeductibleVATEnabled() then
            exit(false);
        VATSetup.Get();
        exit(VATSetup."Use For Advances CZZ");
    end;

    internal procedure GetNonDeductibleVATPct(AdvancePostingBuffer: Record "Advance Posting Buffer CZZ"; ToDate: Date): Decimal
    begin
        exit(GetNonDeductibleVATPct(
            AdvancePostingBuffer."VAT Bus. Posting Group",
            AdvancePostingBuffer."VAT Prod. Posting Group",
            "General Posting Type"::Purchase, ToDate));
    end;

    procedure GetNonDeductibleVATPct(VATBusPostGroupCode: Code[20]; VATProdPostGroupCode: Code[20]; GeneralPostingType: Enum "General Posting Type"; ToDate: Date): Decimal
    begin
        if not IsNonDeductibleVATEnabled() then
            exit(0);
        exit(NonDeductibleVATCZL.GetNonDeductibleVATPct(VATBusPostGroupCode, VATProdPostGroupCode, GeneralPostingType, ToDate));
    end;

    internal procedure Calculate(var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ")
    var
        Currency: Record Currency;
    begin
        if not IsNonDeductibleVATEnabled() then
            exit;
        Currency.InitRoundingPrecision();
        UpdateNonDeductibleAmounts(
            AdvancePostingBufferCZZ."Non-Deductible VAT Base", AdvancePostingBufferCZZ."Non-Deductible VAT Amount",
            AdvancePostingBufferCZZ."VAT Base Amount", AdvancePostingBufferCZZ."VAT Amount",
            AdvancePostingBufferCZZ."Non-Deductible VAT %", Currency."Amount Rounding Precision");
        UpdateNonDeductibleAmounts(
            AdvancePostingBufferCZZ."Non-Deductible VAT Base ACY", AdvancePostingBufferCZZ."Non-Deductible VAT Amount ACY",
            AdvancePostingBufferCZZ."VAT Base Amount (ACY)", AdvancePostingBufferCZZ."VAT Amount (ACY)",
            AdvancePostingBufferCZZ."Non-Deductible VAT %", Currency."Amount Rounding Precision");
    end;

    local procedure UpdateNonDeductibleAmounts(var NonDeductibleBase: Decimal; var NonDeductibleAmount: Decimal; VATBase: Decimal; VATAmount: Decimal; NonDeductibleVATPct: Decimal; AmountRoundingPrecision: Decimal)
    begin
        if not IsNonDeductibleVATEnabled() then begin
            NonDeductibleBase := 0;
            NonDeductibleAmount := 0;
            exit;
        end;
        NonDeductibleBase :=
            Round(VATBase * NonDeductibleVATPct / 100, AmountRoundingPrecision);
        NonDeductibleAmount :=
            Round(VATAmount * NonDeductibleVATPct / 100, AmountRoundingPrecision);
    end;

    internal procedure Copy(var GenJournalLine: Record "Gen. Journal Line"; AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ")
    begin
        GenJournalLine."Non-Deductible VAT %" := AdvancePostingBufferCZZ."Non-Deductible VAT %";
        GenJournalLine."Non-Deductible VAT Base" := AdvancePostingBufferCZZ."Non-Deductible VAT Base";
        GenJournalLine."Non-Deductible VAT Amount" := AdvancePostingBufferCZZ."Non-Deductible VAT Amount";
        GenJournalLine."Non-Deductible VAT Base LCY" := AdvancePostingBufferCZZ."Non-Deductible VAT Base ACY";
        GenJournalLine."Non-Deductible VAT Amount LCY" := AdvancePostingBufferCZZ."Non-Deductible VAT Amount ACY";
    end;
}