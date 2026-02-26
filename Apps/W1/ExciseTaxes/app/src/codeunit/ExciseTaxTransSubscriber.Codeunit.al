// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.ExciseTaxes;

using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Inventory.Item;
using Microsoft.Sustainability.ExciseTax;

codeunit 7413 "Excise Tax Trans Subscriber"
{
    [EventSubscriber(ObjectType::Table, Database::"Sust. Excise Taxes Trans. Log", OnAfterCopyFromSustainabilityExciseJnlLine, '', false, false)]
    local procedure OnAfterCopyFromSustainabilityExciseJnlLine(var SustExciseTaxesTransactionLog: Record "Sust. Excise Taxes Trans. Log"; SustainabilityExciseJnlLine: Record "Sust. Excise Jnl. Line")
    var
        ExciseTaxCalculation: Codeunit "Excise Tax Calculation";
    begin
        if not ExciseTaxCalculation.IsExciseTaxEntry(SustainabilityExciseJnlLine) then
            exit;

        SustExciseTaxesTransactionLog."Excise Tax Type" := SustainabilityExciseJnlLine."Excise Tax Type";
        SustExciseTaxesTransactionLog."Excise Duty" := SustainabilityExciseJnlLine."Excise Duty";
        SustExciseTaxesTransactionLog."Tax Amount" := SustainabilityExciseJnlLine."Tax Amount";
        SustExciseTaxesTransactionLog."Quantity for Excise Tax" := SustainabilityExciseJnlLine."Quantity for Excise Tax";
        SustExciseTaxesTransactionLog."Excise Unit of Measure Code" := SustainabilityExciseJnlLine."Excise Unit of Measure Code";
        SustExciseTaxesTransactionLog."Excise Entry Type" := SustainabilityExciseJnlLine."Excise Entry Type";
        SustExciseTaxesTransactionLog."FA Ledger Entry No." := SustainabilityExciseJnlLine."FA Ledger Entry No.";
        ExciseTaxCalculation.UpdateItemLedgerEntryExciseTaxInfo(SustExciseTaxesTransactionLog);
        ExciseTaxCalculation.UpdateFALedgerEntryExciseTaxInfo(SustExciseTaxesTransactionLog);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sust. Excise Jnl.-Check", OnBeforeTestEmissionAmount, '', false, false)]
    local procedure OnBeforeTestEmissionAmount(SustainabilityExciseJnlLine: Record "Sust. Excise Jnl. Line"; var IsHandled: Boolean)
    var
        ExciseTaxCalculation: Codeunit "Excise Tax Calculation";
    begin
        if ExciseTaxCalculation.IsExciseTaxEntry(SustainabilityExciseJnlLine) then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sust. Excise Jnl. Line", OnValidateSourceNoBeforeTestFieldPartnerNo, '', false, false)]
    local procedure OnValidateSourceNoBeforeTestFieldPartnerNo(var SustainabilityExciseJnlLine: Record "Sust. Excise Jnl. Line"; var IsHandled: Boolean)
    var
        ExciseTaxCalculation: Codeunit "Excise Tax Calculation";
    begin
        if ExciseTaxCalculation.IsExciseTaxEntry(SustainabilityExciseJnlLine) then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sust. Excise Jnl. Line", OnValidateSustainabilityExciseJournalLineByFieldOnBeforeShowUnsupportedEntryError, '', false, false)]
    local procedure OnValidateSustainabilityExciseJournalLineByFieldOnBeforeShowUnsupportedEntryError(var ExciseJournalLine: Record "Sust. Excise Jnl. Line"; var IsHandled: Boolean)
    var
        ExciseTaxCalculation: Codeunit "Excise Tax Calculation";
    begin
        if ExciseTaxCalculation.IsExciseTaxEntry(ExciseJournalLine) then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sust. Excise Jnl. Line", OnAfterCopyFromItem, '', false, false)]
    local procedure OnAfterCopyFromItem(var ExciseJournalLine: Record "Sust. Excise Jnl. Line"; Item: Record Item)
    var
        ExciseTaxCalculation: Codeunit "Excise Tax Calculation";
    begin
        if not ExciseTaxCalculation.IsExciseTaxEntry(ExciseJournalLine) then
            exit;

        ExciseJournalLine.Validate("Excise Unit of Measure Code", Item."Excise Unit of Measure Code");
        ExciseJournalLine.Validate("Quantity for Excise Tax", Item."Quantity for Excise Tax");
        ExciseJournalLine.Validate("Excise Duty", GetExciseDutyForSource(ExciseJournalLine."Excise Tax Type", ExciseJournalLine."Source Type", ExciseJournalLine."Source No.", ExciseJournalLine."Posting Date"));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sust. Excise Jnl. Line", OnAfterCopyFromFixedAsset, '', false, false)]
    local procedure OnAfterCopyFromFixedAsset(var ExciseJournalLine: Record "Sust. Excise Jnl. Line"; FixedAsset: Record "Fixed Asset")
    var
        ExciseTaxCalculation: Codeunit "Excise Tax Calculation";
    begin
        if not ExciseTaxCalculation.IsExciseTaxEntry(ExciseJournalLine) then
            exit;

        ExciseJournalLine.TestField("Excise Tax Type");
        ExciseJournalLine.Validate("Excise Unit of Measure Code", FixedAsset."Excise Unit of Measure Code");
        ExciseJournalLine.Validate("Quantity for Excise Tax", FixedAsset."Quantity for Excise Tax");
        ExciseJournalLine.Validate("Excise Duty", GetExciseDutyForSource(ExciseJournalLine."Excise Tax Type", ExciseJournalLine."Source Type", ExciseJournalLine."Source No.", ExciseJournalLine."Posting Date"));
    end;

    local procedure GetExciseDutyForSource(TaxTypeCode: Code[20]; SourceType: Enum "Sust. Excise Jnl. Source Type"; SourceNo: Code[20]; EffectiveDate: Date): Decimal
    var
        ExciseTaxItemFARate: Record "Excise Tax Item/FA Rate";
        ExciseDuty: Decimal;
        ExciseSourceType: Enum "Excise Source Type";
    begin
        ExciseSourceType := ExciseTaxItemFARate.ConvertSustSourceTypeToExciseSourceType(SourceType);
        if ExciseTaxItemFARate.GetEffectiveExciseDuty(TaxTypeCode, ExciseSourceType, SourceNo, EffectiveDate, ExciseDuty) then
            exit(ExciseDuty);
    end;
}