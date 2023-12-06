// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.CashFlow.Account;
using Microsoft.CashFlow.Forecast;
using Microsoft.CashFlow.Setup;
using Microsoft.CashFlow.Worksheet;
using Microsoft.Finance.Analysis;
using Microsoft.Foundation.Enums;

codeunit 31404 "Cash Flow Handler CZZ"
{
    var
        CashFlowManagement: Codeunit "Cash Flow Management";
        MatrixManagementCZZ: Codeunit "Matrix Management";
        SourceDataDoesNotExistErr: Label 'Source data does not exist for %1: %2.', Comment = '%1 = caption of table, %2 = code of record, example: Source data doesn''t exist for G/L Account: 8210.';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cash Flow Management", 'OnShowSourceLocalSourceTypeCase', '', false, false)]
    local procedure ShowAdvanceLettersOnShowSourceLocalSourceTypeCase(SourceType: Enum "Cash Flow Source Type"; SourceNo: Code[20]; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;

        IsHandled := true;
        case SourceType of
            Enum::"Cash Flow Source Type"::"Sales Advance Letters CZZ":
                ShowSalesAdvanceLetters(SourceNo);
            Enum::"Cash Flow Source Type"::"Purchase Advance Letters CZZ":
                ShowPurchAdvanceLetters(SourceNo);
            else
                IsHandled := false;
        end
    end;

    local procedure ShowSalesAdvanceLetters(SourceNo: Code[20])
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvanceLetterCZZ: Page "Sales Advance Letter CZZ";
    begin
        SalesAdvLetterHeaderCZZ.SetRange("No.", SourceNo);
        if not SalesAdvLetterHeaderCZZ.FindFirst() then
            Error(SourceDataDoesNotExistErr, SalesAdvanceLetterCZZ.Caption, SourceNo);
        SalesAdvanceLetterCZZ.SetTableView(SalesAdvLetterHeaderCZZ);
        SalesAdvanceLetterCZZ.Run();
    end;

    local procedure ShowPurchAdvanceLetters(SourceNo: Code[20])
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvanceLetterCZZ: Page "Purch. Advance Letter CZZ";
    begin
        PurchAdvLetterHeaderCZZ.SetRange("No.", SourceNo);
        if not PurchAdvLetterHeaderCZZ.FindFirst() then
            Error(SourceDataDoesNotExistErr, PurchAdvanceLetterCZZ.Caption, SourceNo);
        PurchAdvanceLetterCZZ.SetTableView(PurchAdvLetterHeaderCZZ);
        PurchAdvanceLetterCZZ.Run();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Cash Flow Availability Lines", 'OnAfterCalcLine', '', false, false)]
    local procedure CalcAdvancePaymentAmountOnAfterCalcLine(var CashFlowForecast: Record "Cash Flow Forecast"; var CashFlowAvailabilityBuffer: Record "Cash Flow Availability Buffer"; RoundingFactor: Option "None","1","1000","1000000")
    begin
        CashFlowAvailabilityBuffer."Sales Advances CZZ" := GetAmount(Enum::"Cash Flow Source Type"::"Sales Advance Letters CZZ", CashFlowForecast, RoundingFactor);
        CashFlowAvailabilityBuffer."Purchase Advances CZZ" := GetAmount(Enum::"Cash Flow Source Type"::"Purchase Advance Letters CZZ", CashFlowForecast, RoundingFactor);
    end;

    local procedure GetAmount(SourceType: Enum "Cash Flow Source Type"; var CashFlowForecast: Record "Cash Flow Forecast"; RoundingFactor: Option "None","1","1000","1000000"): Decimal
    begin
        exit(MatrixManagementCZZ.RoundAmount(CashFlowForecast.CalcSourceTypeAmount(SourceType), Enum::"Analysis Rounding Factor".FromInteger(RoundingFactor)));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cash Flow Management", 'OnAfterCreateCashFlowAccounts', '', false, false)]
    local procedure CreateCashFlowAccountsForAdvanceLetters()
    begin
        CashFlowManagement.CreateCashFlowAccount(Enum::"Cash Flow Source Type"::"Sales Advance Letters CZZ", '');
        CashFlowManagement.CreateCashFlowAccount(Enum::"Cash Flow Source Type"::"Purchase Advance Letters CZZ", '')
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cash Flow Management", 'OnBeforeInsertOnCreateCashFlowSetup', '', false, false)]
    local procedure CreateCashFlowSetupForAdvanceLetters(var CashFlowSetup: Record "Cash Flow Setup")
    begin
        CashFlowSetup.Validate("S. Adv. Letter CF Acc. No. CZZ", GetNoFromSourceType(Enum::"Cash Flow Source Type"::"Sales Advance Letters CZZ"));
        CashFlowSetup.Validate("P. Adv. Letter CF Acc. No. CZZ", GetNoFromSourceType(Enum::"Cash Flow Source Type"::"Purchase Advance Letters CZZ"));
    end;

    local procedure GetNoFromSourceType(CashFlowSourceType: Enum "Cash Flow Source Type"): Text
    var
        DummyCashFlowAccount: Record "Cash Flow Account";
        CashFlowAccountNoFormatTxt: Label '%1-%2', Comment = '%1 = number of type, %2 = name of type', Locked = true;
    begin
        exit(CopyStr(StrSubstNo(CashFlowAccountNoFormatTxt, CashFlowSourceType.AsInteger(), Format(CashFlowSourceType)), 1, MaxStrLen(DummyCashFlowAccount."No.")));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cash Flow Management", 'OnBeforeRunSuggestWorksheetLinesOnUpdateCashFlowForecast', '', false, false)]
    local procedure InitializeRequestOnBeforeRunSuggestWorksheetLinesOnUpdateCashFlowForecast(var SuggestWorksheetLines: Report "Suggest Worksheet Lines")
    begin
        SuggestWorksheetLines.InitializeRequestCZZ(true, true);
    end;
}
