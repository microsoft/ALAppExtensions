// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.CashFlow;

using Microsoft.CashFlow.Forecast;
using Microsoft.CashFlow.Setup;
using Microsoft.CashFlow.Worksheet;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Finance.VAT.Ledger;

codeunit 31045 "Cash Flow Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cash Flow Management", 'OnAfterSetViewOnVATEntryForTaxCalc', '', false, false)]
    local procedure VATDateCZLFilterOnAfterSetViewOnVATEntryForTaxCalc(var VATEntry: Record "VAT Entry"; TaxPaymentDueDate: Date; DummyDate: Date)
    var
        CashFlowSetup: Record "Cash Flow Setup";
        VATReportingDateMgt: Codeunit "VAT Reporting Date Mgt";
        StartDate: Date;
        EndDate: Date;
    begin
        if not VATReportingDateMgt.IsVATDateEnabled() then
            exit;

        VATEntry.Setrange("Document Date");
#if not CLEAN22
#pragma warning disable AL0432
        if not VATEntry.IsReplaceVATDateEnabled() then
            VATEntry.SetFilter("VAT Date CZL", '<>%1', DummyDate)
        else
#pragma warning restore AL0432
#endif
            VATEntry.SetFilter("VAT Reporting Date", '<>%1', DummyDate);
        if TaxPaymentDueDate <> DummyDate then begin
            CashFlowSetup.GetTaxPeriodStartEndDates(TaxPaymentDueDate, StartDate, EndDate);
#if not CLEAN22
#pragma warning disable AL0432
            if not VATEntry.IsReplaceVATDateEnabled() then
                VATEntry.SetRange("VAT Date CZL", StartDate, EndDate)
            else
#pragma warning restore AL0432
#endif
                VATEntry.SetRange("VAT Reporting Date", StartDate, EndDate)
        end;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Suggest Worksheet Lines", 'OnGetTaxPayableDateFromSourceOnBeforeExit', '', false, false)]
    local procedure VATDateCZLOnGetTaxPayableDateFromSourceOnBeforeExit(SourceTableNum: Integer; VATEntry: Record "VAT Entry"; var DocumentDate: Date)
    var
        VATReportingDateMgt: Codeunit "VAT Reporting Date Mgt";
    begin
        if not VATReportingDateMgt.IsVATDateEnabled() then
            exit;
#if not CLEAN22
#pragma warning disable AL0432
        if not VATEntry.IsReplaceVATDateEnabled() then
            VATEntry."VAT Reporting Date" := VATEntry."VAT Date CZL";
#pragma warning restore AL0432
#endif
        case SourceTableNum of
            Database::"VAT Entry":
                DocumentDate := VATEntry."VAT Reporting Date";
        end;
    end;
}
