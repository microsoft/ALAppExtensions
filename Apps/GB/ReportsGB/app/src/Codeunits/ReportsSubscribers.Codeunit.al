// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using Microsoft.Sales.Document;

using Microsoft.FixedAssets.Reports;
using Microsoft.Purchases.Setup;
using Microsoft.Sales.Reports;
using Microsoft.Purchases.Document;
using Microsoft.CashFlow.Forecast;
using Microsoft.Sales.Reminder;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.CashFlow.Reports;
using Microsoft.Purchases.History;
using Microsoft.Foundation.Period;
using Microsoft.Inventory.Item;
using Microsoft.Purchases.Reports;

codeunit 10581 "Reports Subscribers"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Access = Internal;

    var
        Text10500Err: Label 'Reverse charge item - please check correct VAT rate is entered. Reverse Charge %1', Comment = '%1 = reverse charge value';

    [EventSubscriber(ObjectType::Report, Report::"Sales Document - Test", OnAfterSalesPostGetSalesLines, '', false, false)]
    local procedure OnAfterSalesPostGetSalesLines(var SalesHeader: Record "Sales Header"; var TempSalesLine: Record "Sales Line" temporary)
    begin
        if SalesHeader.GetReverseChargeApplies() then
            TempSalesLine.SetReverseChargeAppliesGB();
    end;

    [EventSubscriber(ObjectType::Report, Report::"Purchase Document - Test", OnAfterCheckPurchLine, '', false, false)]
    local procedure OnAfterCheckPurchLine(PurchaseLine: Record "Purchase Line"; var PurchaseHeader: Record "Purchase Header"; var ErrorCounter: Integer; var ErrorText: Text[250])
    var
        PurchLine: Record "Purchase Line";
        PurchSetup: Record "Purchases & Payables Setup";
        Item: Record Item;
    begin
        if not (PurchaseLine.Type = PurchaseLine.Type::Item) then
            exit;
        if (PurchaseLine."No." = '') and (PurchaseLine.Quantity = 0) then
            exit;
        if not (PurchaseLine."No." <> '') then
            exit;
        if not Item.Get(PurchaseLine."No.") then
            exit;

        PurchSetup.Get();
        PurchaseHeader.SetReverseCharge(0);
        if PurchaseLine."Reverse Charge Item GB" and
           (PurchaseHeader."VAT Bus. Posting Group" = PurchSetup."Domestic Vendors GB") and
           (PurchaseHeader."VAT Registration No." <> '')
        then
            if PurchSetup."Reverse Charge VAT Post. Gr." = PurchaseLine."VAT Bus. Posting Group" then begin
                PurchLine := PurchaseLine;
                PurchLine.SuspendStatusCheck(true);
                PurchLine.Validate("VAT Bus. Posting Group", PurchSetup."Domestic Vendors GB");
                PurchLine.Validate(Amount);
                PurchaseHeader.SetReverseCharge(Round(
                    (PurchLine."Amount Including VAT" - PurchLine.Amount) *
                    PurchLine."Qty. to Invoice" / PurchLine.Quantity));
                AddError(StrSubstNo(Text10500Err, PurchaseHeader.GetReverseCharge()), ErrorCounter, ErrorText);
                PurchaseHeader.SetTotalReverseCharge(PurchaseHeader.GetTotalReverseCharge() + PurchaseHeader.GetReverseCharge());
            end else
                AddError(StrSubstNo(Text10500Err, Round(0)), ErrorCounter, ErrorText);
    end;

    [EventSubscriber(ObjectType::Report, Report::"Fixed Asset - Projected Value", OnAfterAccountingPeriodSetFilter, '', false, false)]
    local procedure OnAfterAccountingPeriodSetFilter(var AccountingPeriod: Record "Accounting Period"; var PeriodEndingDate: Date; UseAccountingPeriod: Boolean; Year365Days: Boolean)
    begin
        if Year365Days then
            PeriodEndingDate := ToMorrow365(PeriodEndingDate)
        else begin
            PeriodEndingDate := PeriodEndingDate + 1;
            if (not UseAccountingPeriod) and (Date2DMY(PeriodEndingDate, 1) = 31) then
                PeriodEndingDate := PeriodEndingDate + 1;
        end;

        AccountingPeriod.SetFilter(
            "Starting Date", '>=%1', PeriodEndingDate + 1);
    end;

    [EventSubscriber(ObjectType::Report, Report::"Purchase - Receipt", OnAfterInitializeRequest, '', false, false)]
    local procedure OnAfterInitializeRequest(var NoOfCopies: Integer; var ShowInternalInfo: Boolean; var LogInteraction: Boolean; var ShowCorrectionLines: Boolean; var sender: Report "Purchase - Receipt")
    begin
        sender.SetLogInteraction(LogInteraction);
        sender.SetShowCorrectionLines(ShowCorrectionLines);
    end;

    [EventSubscriber(ObjectType::Report, Report::"Cash Flow Dimensions - Detail", OnAfterInitializeRequest, '', false, false)]
    local procedure OnAfter_InitializeRequest(var AnalysisViewCode: Code[10]; var CFFilter: Text[100]; var DateFilterv: Text[100]; var PrintEmptyLines: Boolean; var sender: Report "Cash Flow Dimensions - Detail")
    begin
        sender.SetPrintEmptyLines(PrintEmptyLines);
    end;

    [EventSubscriber(ObjectType::Report, Report::"Fixed Asset - Projected Value", OnBeforeCalculateFirstDeprAmount, '', false, false)]
    local procedure OnBeforeCalculateFirstDeprAmount(sender: Report "Fixed Asset - Projected Value"; var CalculateDepr: Codeunit "Calculate Depreciation"; var Custom1Amount: Decimal; var Custom1NumberOfDays: Integer; var DaysInFirstPeriod: Integer; var DeprAmount: Decimal; var DeprBookCode: Code[10]; var DepreciationCalculation: Codeunit "Depreciation Calculation"; var Done: Boolean; var EndingDate: Date; var EntryAmounts: array[4] of Decimal; var FirstTime: Boolean; var FixedAsset: Record "Fixed Asset"; var IsHandled: Boolean; var NumberOfDays: Integer; var StartingDate: Date; var UntilDate: Date)
    begin
        sender.SetUntilDate(UntilDate);
    end;

    [EventSubscriber(ObjectType::Report, Report::Reminder, OnAfterResetAmounts, '', false, false)]
    local procedure OnAfterResetAmounts(var VATInterest: Decimal; var AddFeeInclVAT: Decimal; var AddFeePerLineInclVAT: Decimal; var sender: Report Reminder)
    begin
        sender.SetAddFeeInclVAT(AddFeeInclVAT);
        sender.SetVATInterest(VATInterest);
    end;

    [EventSubscriber(ObjectType::Report, Report::"Cash Flow Dimensions - Detail", OnBeforeTempCFForecastEntryfind, '', false, false)]
    local procedure OnBeforeTempCFForecastEntryfind(TempCFForecastEntry: Record "Cash Flow Forecast Entry"; Level: Integer; var sender: Report "Cash Flow Dimensions - Detail")
    begin
        sender.SetTempCFForecastEntry(TempCFForecastEntry);
    end;

    [EventSubscriber(ObjectType::Report, Report::"Cash Flow Dimensions - Detail", OnBeforeTempCFForecastEntrynext, '', false, false)]
    local procedure OnBeforeTempCFForecastEntrynext(TempCFForecastEntry: Record "Cash Flow Forecast Entry"; Level: Integer; var sender: Report "Cash Flow Dimensions - Detail")
    begin
        sender.SetTempCFForecastEntry(TempCFForecastEntry);
    end;

    [EventSubscriber(ObjectType::Report, Report::"Cash Flow Dimensions - Detail", OnAfterCalcLine, '', false, false)]
    local procedure OnAfterCalcLine(DimCode: Text[30]; DimValCode: Code[20]; DimValName: Text[100]; Level: Integer; var sender: Report "Cash Flow Dimensions - Detail")
    begin
        sender.SetDim_Code_ValCode_ValName(DimCode, DimValCode, DimValName, Level);
    end;

    [EventSubscriber(ObjectType::Report, Report::"Fixed Asset - Projected Value", OnAfterTransferValues, '', false, false)]
    local procedure OnAfterTransferValues(GroupAmounts: array[4] of Decimal; TotalBookValue: array[2] of Decimal; var sender: Report "Fixed Asset - Projected Value")
    begin
        sender.SetGroupAmounts(GroupAmounts);
        sender.SetTotalBookValue(TotalBookValue);
    end;

    local procedure ToMorrow365(ThisDate: Date): Date
    begin
        ThisDate := ThisDate + 1;
        if (Date2DMY(ThisDate, 1) = 29) and (Date2DMY(ThisDate, 2) = 2) then
            ThisDate := ThisDate + 1;
        exit(ThisDate);
    end;

    local procedure AddError(Text: Text; var ErrorCounter: Integer; var ErrorText: Text[250])
    begin
        ErrorCounter := ErrorCounter + 1;
        ErrorText := CopyStr(Text, 1, MaxStrLen(ErrorText[ErrorCounter]));
    end;
}