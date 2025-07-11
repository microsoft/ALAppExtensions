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
            VATEntry.SetFilter("VAT Reporting Date", '<>%1', DummyDate);
        if TaxPaymentDueDate <> DummyDate then begin
            CashFlowSetup.GetTaxPeriodStartEndDates(TaxPaymentDueDate, StartDate, EndDate);
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
        case SourceTableNum of
            Database::"VAT Entry":
                DocumentDate := VATEntry."VAT Reporting Date";
        end;
    end;
}
