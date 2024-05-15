// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Calculation;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.Enums;
using Microsoft.Purchases.Document;

codeunit 31147 "Non-Deductible VAT CZL"
{
    var
        NonDeductibleVAT: Codeunit "Non-Deductible VAT";
        PurchaseSettlementOnlyErr: Label 'Non-deductible VAT is supported only for purchase and settlement transactions.';

    procedure GetNonDeductibleVATPct(PurchaseLine: Record "Purchase Line"): Decimal
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        if not NonDeductibleVAT.IsNonDeductibleVATEnabled() then
            exit(0);
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        exit(GetNonDeductibleVATPct(
            PurchaseLine."VAT Bus. Posting Group", PurchaseLine."VAT Prod. Posting Group",
            "General Posting Type"::Purchase, PurchaseHeader."VAT Reporting Date"));
    end;

    procedure GetNonDeductibleVATPct(GenJournalLine: Record "Gen. Journal Line"): Decimal
    begin
        if not NonDeductibleVAT.IsNonDeductibleVATEnabled() then
            exit(0);
        if not (GenJournalLine."VAT Calculation Type" in [GenJournalLine."VAT Calculation Type"::"Normal VAT", GenJournalLine."VAT Calculation Type"::"Reverse Charge VAT"]) then
            exit(0);
        exit(GetNonDeductibleVATPct(
            GenJournalLine."VAT Bus. Posting Group", GenJournalLine."VAT Prod. Posting Group",
            GenJournalLine."Gen. Posting Type", GenJournalLine."VAT Reporting Date"));
    end;

    procedure GetNonDeductibleVATPct(VATBusPostGroupCode: Code[20]; VATProdPostGroupCode: Code[20]; GeneralPostingType: Enum "General Posting Type"; ToDate: Date): Decimal
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if not NonDeductibleVAT.IsNonDeductibleVATEnabled() then
            exit(0);
        if not VATPostingSetup.Get(VATBusPostGroupCode, VATProdPostGroupCode) then
            exit(0);
        exit(GetNonDeductibleVATPct(VATPostingSetup, GeneralPostingType, ToDate));
    end;

    procedure GetNonDeductibleVATPct(VATPostingSetup: Record "VAT Posting Setup"; GeneralPostingType: Enum "General Posting Type"; ToDate: Date) NonDeductibleVATPct: Decimal
    var
        NonDeductibleVATSetupCZL: Record "Non-Deductible VAT Setup CZL";
        IsHandled: Boolean;
    begin
        if not NonDeductibleVAT.IsNonDeductibleVATEnabled() then
            exit(0);
        OnBeforeGetNonDeductibleVATPct(VATPostingSetup, GeneralPostingType, ToDate, NonDeductibleVATPct, IsHandled);
        if IsHandled then
            exit(NonDeductibleVATPct);
        if not (VATPostingSetup."VAT Calculation Type" in [VATPostingSetup."VAT Calculation Type"::"Normal VAT", VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT"]) then
            exit(0);
        if GeneralPostingType <> GeneralPostingType::Purchase then
            exit(0);
        case VATPostingSetup."Allow Non-Deductible VAT" of
            VATPostingSetup."Allow Non-Deductible VAT"::"Do Not Allow":
                exit(0);
            VATPostingSetup."Allow Non-Deductible VAT"::Allow:
                begin
                    if not NonDeductibleVATSetupCZL.FindToDate(ToDate) then
                        exit(0);
                    NonDeductibleVATSetupCZL.TestField("Advance Coefficient");
                    exit(NonDeductibleVATSetupCZL."Advance Coefficient");
                end;
            VATPostingSetup."Allow Non-Deductible VAT"::"Do not apply CZL":
                exit(100);
        end;
    end;

    procedure CheckGeneralPostingType(GenJournalLine: Record "Gen. Journal Line")
    begin
        CheckGeneralPostingType(
            GenJournalLine."VAT Bus. Posting Group", GenJournalLine."VAT Prod. Posting Group", GenJournalLine."Gen. Posting Type");
    end;

    procedure CheckGeneralPostingType(VATBusPostGroupCode: Code[20]; VATProdPostGroupCode: Code[20]; GeneralPostingType: Enum "General Posting Type")
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if not NonDeductibleVAT.IsNonDeductibleVATEnabled() then
            exit;
        if not VATPostingSetup.Get(VATBusPostGroupCode, VATProdPostGroupCode) then
            exit;
        CheckGeneralPostingType(VATPostingSetup, GeneralPostingType);
    end;

    procedure CheckGeneralPostingType(VATPostingSetup: Record "VAT Posting Setup"; GeneralPostingType: Enum "General Posting Type")
    begin
        if not NonDeductibleVAT.IsNonDeductibleVATEnabled() then
            exit;
        if not (VATPostingSetup."VAT Calculation Type" in [VATPostingSetup."VAT Calculation Type"::"Normal VAT", VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT"]) then
            exit;
        if (not (GeneralPostingType in [GeneralPostingType::Purchase, GeneralPostingType::Settlement])) and
           (VATPostingSetup."Allow Non-Deductible VAT" <> VATPostingSetup."Allow Non-Deductible VAT"::"Do Not Allow")
        then
            Error(PurchaseSettlementOnlyErr);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetNonDeductibleVATPct(VATPostingSetup: Record "VAT Posting Setup"; GeneralPostingType: Enum "General Posting Type"; ToDate: Date; var NonDeductibleVATPct: Decimal; var IsHandled: Boolean)
    begin
    end;
}